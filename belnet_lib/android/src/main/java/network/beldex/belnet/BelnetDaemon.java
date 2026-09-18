package network.beldex.belnet;
//
//import static io.beldex.belnet_lib.BelnetLibPluginKt.buildStatusForNotification;

import static android.content.Intent.getIntent;

import android.annotation.SuppressLint;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkRequest;
import android.net.TrafficStats;
import android.net.Uri;
import android.net.VpnService;
import android.os.Binder;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.os.ParcelFileDescriptor;
import android.os.SystemClock;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import org.json.JSONException;
import org.json.JSONObject;

import java.nio.ByteBuffer;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashSet;
import java.util.Locale;
import java.util.Set;
import java.util.Timer;
import java.util.TimerTask;
import java.util.stream.Stream;

import io.beldex.belnet_lib.BelnetLibPlugin;

import io.beldex.belnet_lib.DisconActionReceiver;
import io.beldex.belnet_lib.R;
import io.beldex.belnet_lib.UpdateNetwork;

import java.net.InetAddress;
import java.net.UnknownHostException;
public class BelnetDaemon extends VpnService{

  public static final String ACTION_CONNECT = "network.beldex.belnet.START";
  public static final String ACTION_DISCONNECT = "network.beldex.belnet.STOP";
  public static final String LOG_TAG = "BelnetDaemon";
  public static final String MESSAGE_CHANNEL = "BELNET_DAEMON";
  public static final String EXIT_NODE = "EXIT_NODE";
  public static final String UPSTREAM_DNS = "UPSTREAM_DNS";
  public static final String NOTIFICATION_ID = "NOTIFICATION_ID";
  // Ported from belnet-app commit df16d27 (audit F5/F12/F13): daemon log
  // level, TUN MTU and IPv6 routing are configurable via Intent extras.
  public static final String LOG_LEVEL = "LOG_LEVEL";
  public static final String MTU = "MTU";
  public static final String ROUTE_IPV6 = "ROUTE_IPV6";
  private static final String DEFAULT_EXIT_NODE = "7a4cpzri7qgqen9a3g3hgfjrijt9337qb19rhcdmx5y7yttak33o.bdx";
  // Keep in sync with the Dart-side default in belnet_lib.dart (was 1.1.1.1
  // here and 9.9.9.9 in Dart, which made DNS issues confusing to debug).
  // Ported from belnet-app commit df16d27 (audit F13).
  private static final String DEFAULT_UPSTREAM_DNS = "9.9.9.9";
  private static final String DEFAULT_LOG_LEVEL = "warn";
  // Latency audit: onion encapsulation overhead makes full-size 1500-byte
  // packets exceed the effective path MTU, causing fragmentation/drops and
  // stalls on large transfers. 1400 leaves headroom for the overlay headers.
  // Benchmark on real devices before changing again. Now the DEFAULT of a
  // configurable value (belnet-app F5): callers may pass 1280-1500.
  private static final int TUN_MTU = 1400;
  public static Boolean isCalling =false;
  public static final int NOTIFY_ID = 1;
  private static final int ERROR_NOTIFY_ID = 3;
  private final static String NOTIFICATION_CHANNEL_ID = "belnet_channel_1";
  public NotificationManager mNotificationManager = null;
  public NotificationCompat.Builder mNotifyBuilder;
  public String updateNotify;

  // Stream<String> myStream;

  private String actionState = "network.beldex.belnet.STOP";
  public String updata ="empty" ;
  static {
    System.loadLibrary("belnet-android");
  }

  private static native ByteBuffer Obtain();

  private static native void Free(ByteBuffer buf);

  public native boolean Configure(BelnetConfig config);

  public native int Mainloop();

  public native boolean IsRunning();

  public native String DumpStatus();

  public native boolean Stop();

  public native void InjectVPNFD();

  public native int GetUDPSocket();

  private static native String DetectFreeRange();

  //public final void stopSelf();
  // Ported from belnet-app commit df16d27 (audit F1/F9): the daemon status
  // JSON used by connection-readiness polling. Re-enabled from the
  // commented-out declaration above; belnet-app calls this same JNI symbol.
  public native String GetStatus();

  /**
   * Safe status accessor: prefers GetStatus() (belnet-app behaviour) and
   * falls back to DumpStatus() if the loaded libbelnet-android.so does not
   * export the GetStatus JNI symbol (UnsatisfiedLinkError) or it throws.
   * Never lets a status read crash a caller.
   */
  public String getStatusSafe() {
    try {
      return GetStatus();
    } catch (Throwable t) {
      Log.w(LOG_TAG, "GetStatus() unavailable, falling back to DumpStatus(): " + t);
      try {
        return DumpStatus();
      } catch (Throwable t2) {
        Log.w(LOG_TAG, "DumpStatus() also failed: " + t2);
        return null;
      }
    }
  }


  public native String Unmap(String exitvalue);
  public native String Status();

  ByteBuffer impl = null;
  ParcelFileDescriptor iface;
  int m_FD = -1;
  int m_UDPSocket = -1;

  private Timer mUpdateIsConnectedTimer;
  private MutableLiveData<Boolean> isConnected = new MutableLiveData<Boolean>();

  String results;

  // Ported from belnet-app commit df16d27 (audit F4): underlying-network
  // change detection for Wi-Fi <-> mobile handover recovery.
  public static final String ACTION_NETWORK_CHANGED = "network.beldex.belnet.NETWORK_CHANGED";
  private ConnectivityManager.NetworkCallback mNetworkCallback;
  private long mLastNetworkChangeMs = 0;

  private int mMtu = TUN_MTU;
  private boolean mRouteIpv6 = true;

  @Override
  public void onCreate() {
    isConnected.postValue(false);
    // Latency audit: the isConnected poller used to run every 500ms for the
    // whole service lifetime, even when disconnected. It is now started in
    // connect() and stopped in disconnect().
    registerNetworkCallback();
  //  createNotific();
//    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
//      createNotificationChannel();

    // new UpdateNetwork().callfunctionContinuesly();
    // callSpeedFunction(actionState);
    // showToolbarNotification("Connect to belnet",NOTIFY_ID,R.drawable.ic_stat);
    super.onCreate();
  }

  private synchronized void startIsConnectedTimer() {
    if (mUpdateIsConnectedTimer == null) {
      mUpdateIsConnectedTimer = new Timer();
      mUpdateIsConnectedTimer.schedule(new UpdateIsConnectedTask(), 0, 500);
    }
  }

  private synchronized void stopIsConnectedTimer() {
    if (mUpdateIsConnectedTimer != null) {
      mUpdateIsConnectedTimer.cancel();
      mUpdateIsConnectedTimer = null;
    }
  }

  @Override
  public void onDestroy() {
    stopIsConnectedTimer();
    unregisterNetworkCallback();
    // clearNotifications();
    disconnect();
Log.w(LOG_TAG, "onDestroy method calling ");
    super.onDestroy();

  }

  /**
   * Ported from belnet-app commit df16d27 (audit F4).
   *
   * Watch the underlying (non-VPN) network. On a Wi-Fi <-> mobile handover
   * the daemon's UDP flows to its first hop break silently: the daemon keeps
   * "running" but paths are dead - users see "Connected" with no internet.
   * When the underlying network changes we re-protect the daemon's UDP
   * socket against the new network and broadcast an event so the Flutter
   * layer can run an immediate tunnel health probe.
   */
  private void registerNetworkCallback() {
    ConnectivityManager cm = (ConnectivityManager) getSystemService(CONNECTIVITY_SERVICE);
    if (cm == null)
      return;
    mNetworkCallback = new ConnectivityManager.NetworkCallback() {
      @Override
      public void onAvailable(Network network) {
        handleNetworkChange("available");
      }

      @Override
      public void onLost(Network network) {
        handleNetworkChange("lost");
      }
    };
    try {
      NetworkRequest request = new NetworkRequest.Builder()
          .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
          .addCapability(NetworkCapabilities.NET_CAPABILITY_NOT_VPN)
          .build();
      cm.registerNetworkCallback(request, mNetworkCallback);
    } catch (Exception e) {
      Log.w(LOG_TAG, "could not register network callback: " + e);
      mNetworkCallback = null;
    }
  }

  private void unregisterNetworkCallback() {
    if (mNetworkCallback == null)
      return;
    ConnectivityManager cm = (ConnectivityManager) getSystemService(CONNECTIVITY_SERVICE);
    if (cm != null) {
      try {
        cm.unregisterNetworkCallback(mNetworkCallback);
      } catch (Exception e) {
        Log.w(LOG_TAG, "could not unregister network callback: " + e);
      }
    }
    mNetworkCallback = null;
  }

  private void handleNetworkChange(String why) {
    // Debounce: handovers produce a burst of callbacks.
    long now = SystemClock.elapsedRealtime();
    if (now - mLastNetworkChangeMs < 3000)
      return;
    mLastNetworkChangeMs = now;
    Log.d(LOG_TAG, "underlying network change (" + why + ")");
    if (IsRunning()) {
      new Thread(
          () -> {
            try {
              m_UDPSocket = GetUDPSocket();
              protect(m_UDPSocket);
              Log.d(LOG_TAG, "re-protected UDP socket after network change");
            } catch (Throwable t) {
              Log.w(LOG_TAG, "re-protect after network change failed: " + t);
            }
          },
          "belnet-netchange")
          .start();
    }
    sendBroadcast(new Intent(ACTION_NETWORK_CHANGED));
  }



  public void updateTheData(Boolean isRunning){
    updateNotify = new UpdateNetwork(isRunning).myData;
  }





  private void clearNotifications() {
    if (mNotificationManager != null)
     // mNotificationManager.cancelAll();   // i changed 1
      mNotificationManager.cancel(NOTIFY_ID);
  }



private void createNotific(){
    NotificationManager mNotificationManager = null;
    mNotificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
    String name = "Beldex Browser";
  NotificationChannel mChannel = null;
  if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
    mChannel = new NotificationChannel(NOTIFICATION_CHANNEL_ID,name, NotificationManager.IMPORTANCE_LOW);
  }
  if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

    mChannel.setDescription("Belnet is Connected");

    mChannel.enableLights(false);
    mChannel.enableVibration(false);
    mChannel.setShowBadge(false);
    mChannel.setLockscreenVisibility(Notification.VISIBILITY_SECRET);
    mNotificationManager.createNotificationChannel(mChannel);
  }
}























  public void displaySpeedData() {
    Timer t = new Timer();
    t.scheduleAtFixedRate(
            new TimerTask()
            {
              public void run()
              {
                if(IsRunning()) {
                  displayUploadData();
                }
                else
                {
                  clearNotifications();
                }
              }
            },
            0,      // run first occurrence immediatetly
            500);
  }

public void displayUploadData(){
  // try {

  //   String data = GetStatus();
  //   //jsonObject = null;
  //   JSONObject jsonObject = new JSONObject(data);
  //   int rxRate = jsonObject.getInt("rxRate");
  //   int txRate = jsonObject.getInt("txRate");

  //   String sValue = "↑" + makeRate(txRate) + "↓" + makeRate(rxRate);
  //   Log.d("MyStringForRX", String.valueOf(rxRate));
  //   Log.d("MyStringForTX", String.valueOf(txRate));
  //   jstUpdate(sValue);
  // } catch (JSONException e) {
  //   Log.e(LOG_TAG,e.toString());
  // }

}









  String makeRate(int originalValue) {
     final DecimalFormat df = new DecimalFormat("0.00");
    String[] units = new String[]{"b","Kb","Mb"};
    int unit_idx = 0;
    double value = (originalValue * 8);
    while (value > 1000.0 && unit_idx + 1 < units.length) {
      value /= 1000.0;
      unit_idx += 1;
    }

    String unitSpeed = units[unit_idx] + "ps";
    return df.format(value) + unitSpeed;
  }








  @SuppressLint("RestrictedApi")
  public void showToolbarNotification(String notifyMsg, int notifyType, int icon) {
//    Log.d("NotifyNet",networkSpeeds);
    displaySpeedData();
    Log.d("showToolbarNotification","notifymsg"+notifyMsg);
    Intent intent = null;
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.CUPCAKE) {
      intent = getPackageManager().getLaunchIntentForPackage(getPackageName());
    }
    PendingIntent pendIntent = PendingIntent.getActivity(BelnetDaemon.this, 0, intent, PendingIntent.FLAG_IMMUTABLE);


//    Intent disconIntent = new Intent(BelnetDaemon.this, ActionReceivers.class);
//    disconIntent.putExtra("test",false);
//    PendingIntent pIntent = PendingIntent.getActivity(BelnetDaemon.this,0,disconIntent,PendingIntent.FLAG_IMMUTABLE);

//     Intent disconIntent = DisconActionReceiver.Companion.createIntent(BelnetDaemon.this,DisconActionReceiver.DISCONNECT_ACTION);
//     PendingIntent disconPendingIntent = PendingIntent.getBroadcast(BelnetDaemon.this,NOTIFY_ID,disconIntent, PendingIntent.FLAG_MUTABLE );

    if (mNotifyBuilder == null) {
      mNotificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
      mNotifyBuilder = new NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
              .setSmallIcon(R.drawable.belnet_svg)
             .setContentIntent(pendIntent)
              .setCategory(Notification.CATEGORY_SERVICE);
    }
    mNotifyBuilder.mActions.clear();
    mNotifyBuilder.setOngoing(true);

//    String title ;
//
//  title= notifyMsg;

//    Intent notificationssIntent = new Intent(BelnetDaemon.this, NotifyButton.class);
//    notificationIntent.putExtra("fromNotification", true);
//    PendingIntent pendingIntent = PendingIntent.getActivity(BelnetDaemon.this, 0, notificationIntent,
//            PendingIntent.FLAG_UPDATE_CURRENT);

   // mNotifyBuilder.addAction(R.drawable.belnet_svg,"Disconnect",disconPendingIntent);
  // mNotifyBuilder.setContentIntent(disconPendingIntent);
   // mNotifyBuilder.setContentTitle("Belnet");
    mNotifyBuilder.setContentText(notifyMsg);
    //mNotifyBuilder.mActions.clear();
    mNotifyBuilder.setOnlyAlertOnce(true);

    mNotificationManager.notify(notifyType,mNotifyBuilder.build());
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.ECLAIR) {
      startForeground(NOTIFY_ID, mNotifyBuilder.build());
    }
  }


public void jstUpdate(String data){
    mNotifyBuilder.setContentText(data);
    mNotificationManager.notify(NOTIFY_ID, mNotifyBuilder.build());
}


//
//  public void notificationFunctionCall(String actionState,String data){
//
//    Intent intent = getPackageManager().getLaunchIntentForPackage(getPackageName());
//    PendingIntent pendIntent = PendingIntent.getActivity(BelnetDaemon.this, 0, intent, PendingIntent.FLAG_IMMUTABLE);
////                   long sessionDownloaded = 0L;
////                   long sessionUploaded = 0L;
////                   long lastTotalDownload = 0L;
////                   long lastTotalUpload = 0L;
////                   long sessionStart = 0L;
////                   long lastTimestamp = 0L;
////                   long timestamp = SystemClock.elapsedRealtime();
////                   long elapsedMillis = timestamp - lastTimestamp;
////                   float elapsedSeconds = elapsedMillis / 1000f;
////
////                   // Speeds need to be divided by two due to TrafficStats calculating both phone and VPN
////                   // interfaces which leads to doubled data. NetworkStatsManager may have solved this
////                   // problem but is only available from marshmallow.
////                   long totalDownload = TrafficStats.getTotalRxBytes();
////                   Log.d("rxbyte","byes"+totalDownload);
////
////                   long totalUpload = TrafficStats.getTotalTxBytes();
////                   Log.d("txbyte","byes"+totalUpload);
////                   long downloaded = (totalDownload - lastTotalDownload) / 2;
////                   long uploaded = (totalUpload - lastTotalUpload) / 2;
////                   long downloadSpeed = Math.round(downloaded / elapsedSeconds);
////                   long uploadSpeed = Math.round(uploaded / elapsedSeconds);
////                   String sessionUploadString = ConnectionTools.bytesToSize(sessionUploaded);
////                   String downloadSpeedString =ConnectionTools.bytesToSize(downloadSpeed) +"ps";
////                   String  sessionDownloadString = ConnectionTools.bytesToSize(sessionDownloaded);
////                   String uploadSpeedString = ConnectionTools.bytesToSize(uploadSpeed) +"ps";
////                   String notificationString = "↓ "+downloadSpeedString + " ↑ "+ uploadSpeedString;
//
//    //updata = notificationString;
//
//
//    if(BelnetDaemon.ACTION_CONNECT.equals(actionState)){
//      mNotifyBuilder.setContentText(data);
//      mNotifyBuilder.addAction(R.drawable.ic_stat,"Disconnect",pendIntent);
//      mNotificationManager.notify(NOTIFY_ID,mNotifyBuilder.build());
//    }else{
//      clearNotifications();
//    }
//
//
//
//  }



  public void disconnectNotificationButton(){
    Log.d("callingbelnetDeamon","true");
   // isCalling = false;
    disconnect();

    stopSelf();
    clearNotifications();

  }







  @Override
  public int onStartCommand(Intent intent, int flags, int startID) {
    Log.d(LOG_TAG, "onStartCommand()");
    String action = intent != null ? intent.getAction() : "";

    if (ACTION_DISCONNECT.equals(action)) {
      Log.d("callingbelnetDeamon","true");
      //isCalling = false;
      disconnect();
      //stopSelf();
   //  clearNotifications();

      return START_NOT_STICKY;
    } else {
      ArrayList<ConfigValue> configVals = new ArrayList<ConfigValue>();

      String exitNode = "7a4cpzri7qgqen9a3g3hgfjrijt9337qb19rhcdmx5y7yttak33o.bdx";
      String upstreamDNS = null;
      String logLevel = DEFAULT_LOG_LEVEL;

      SharedPreferences sharedPreferences = getSharedPreferences("belnet_lib", MODE_PRIVATE);

      if (ACTION_CONNECT.equals(action)) {

       // Belnet is connected
   //  showToolbarNotification("↑ 60.0Kb/s ↓12.3Kb/s", NOTIFY_ID,1);

        // started by the app
        exitNode = intent.getStringExtra(EXIT_NODE);
        upstreamDNS = intent.getStringExtra(UPSTREAM_DNS);
        logLevel = intent.getStringExtra(LOG_LEVEL);
        mMtu = intent.getIntExtra(MTU, TUN_MTU);
        mRouteIpv6 = intent.getBooleanExtra(ROUTE_IPV6, true);
       // isCalling = true;
        // save values
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(EXIT_NODE, exitNode);
        editor.putString(UPSTREAM_DNS, upstreamDNS);
        editor.putString(LOG_LEVEL, logLevel);
        editor.putInt(MTU, mMtu);
        editor.putBoolean(ROUTE_IPV6, mRouteIpv6);
        editor.commit();
      } else { // if started by the system because Always-on VPN setting is enabled
        // use the latest values
        exitNode = sharedPreferences.getString(EXIT_NODE, null);
        upstreamDNS = sharedPreferences.getString(UPSTREAM_DNS, null);
        logLevel = sharedPreferences.getString(LOG_LEVEL, DEFAULT_LOG_LEVEL);
        mMtu = sharedPreferences.getInt(MTU, TUN_MTU);
        mRouteIpv6 = sharedPreferences.getBoolean(ROUTE_IPV6, true);
      }

      if (exitNode == null || exitNode.isEmpty()) {
        exitNode = DEFAULT_EXIT_NODE;
        Log.e(LOG_TAG, "No exit-node configured! Proceeding with default.");
      }

      Log.e(LOG_TAG, "Using " + exitNode + " as exit-node.");

      configVals.add(new ConfigValue("network", "exit-node", exitNode));


      if (upstreamDNS == null || upstreamDNS.isEmpty()) {
        upstreamDNS = DEFAULT_UPSTREAM_DNS;
        Log.e(LOG_TAG, "No upstream DNS configured! Proceeding with default.");
        new BelnetLibPlugin().logDataToFrontend("No upstream DNS configured! Proceeding with default."); //i
      }

      Log.e(LOG_TAG, "Using " + upstreamDNS + " as upstream DNS.");
      configVals.add(new ConfigValue("dns", "upstream", upstreamDNS));

      // Ported from belnet-app commit df16d27 (audit F12): daemon log level
      // is "warn" by default so logging stays off the packet path in release
      // builds; callers may pass "info"/"debug" explicitly.
      if (logLevel == null || logLevel.isEmpty())
        logLevel = DEFAULT_LOG_LEVEL;
      Log.d(LOG_TAG, "Using daemon log level " + logLevel);
      configVals.add(new ConfigValue("logging", "level", logLevel));

      boolean connectedSuccessfully = connect(configVals);
      if (connectedSuccessfully){
        return START_STICKY;
      }

      else{
        return START_NOT_STICKY;
      }

    }
  }

  @Override
  public void onRevoke() {
    Log.d(LOG_TAG, "onRevoke()");
     // Send broadcast to notify plugin
        Intent intent = new Intent("com.belnet.NOTIFICATION_DISCONNECTED");
        sendBroadcast(intent);
    disconnect();
    super.onRevoke();
  }

  private class ConfigValue {
    final String Section;
    final String Key;
    final String Value;

    public ConfigValue(String section, String key, String value) {
      Section = section;
      Key = key;
      Value = value;
    }

    public boolean Valid() {
      if (Section == null || Key == null || Value == null)
        return false;
      if (Section.isEmpty() || Key.isEmpty() || Value.isEmpty())
        return false;
      return true;
    }
  }

  private boolean connect(ArrayList<ConfigValue> configVals) {
    if (!IsRunning()) {
      if (impl != null) {
        Free(impl);
        impl = null;
      }
      impl = Obtain();
      if (impl == null) {
        Log.e(LOG_TAG, "got nullptr when creating llarp::Context in jni");

        return false;
      }

      String dataDir = getFilesDir().toString();
      BelnetConfig config;
      try {
        config = new BelnetConfig(dataDir);
      } catch (RuntimeException ex) {
        Log.e(LOG_TAG, ex.toString());
        return false;
      }

      String ourRange = DetectFreeRange();

      if (ourRange.isEmpty()) {
        Log.e(LOG_TAG, "cannot detect free range");
        return false;
      }

      String upstreamDNS = DEFAULT_UPSTREAM_DNS;

      // set up config values
      if (configVals != null) {
        configVals.add(new ConfigValue("network", "ifaddr", ourRange));
        for (ConfigValue conf : configVals) {

          if (conf.Valid()) {
            config.AddDefaultValue(conf.Section, conf.Key, conf.Value);
            if (conf.Section.equals("dns") && conf.Key.equals("upstream"))
              upstreamDNS = conf.Value;
          }
        }
      }

      if (!config.Load()) {
        Log.e(
                LOG_TAG,
                "failed to load (or create) config file at: "
                        + dataDir
                        + "/beldex.network.beldex.belnet.ini");

        return false;
      }

      VpnService.Builder builder = new VpnService.Builder();

      // Ported from belnet-app commit df16d27 (audit F5): MTU is configurable
      // for benchmarking; out-of-range values fall back to the audited 1400.
      int mtu = mMtu;
      if (mtu < 1280 || mtu > 1500)
        mtu = TUN_MTU;
      Log.d(LOG_TAG, "Using MTU " + mtu);
      builder.setMtu(mtu);

      String[] parts = ourRange.split("/");
      String ourIP = parts[0];
      int ourMask = Integer.parseInt(parts[1]);

      builder.addAddress(ourIP, ourMask);
      try{
        // Check if the address is IPv4
        InetAddress address = InetAddress.getByName(ourIP);
        if (address instanceof java.net.Inet4Address) {
            builder.addRoute("0.0.0.0", 0);
            Log.e(LOG_TAG,"Address " + ourIP + " is IPv4.");
        }
        // Check if the address is IPv6
        else if (address instanceof java.net.Inet6Address) {
            // Ported from belnet-app commit df16d27 (audit F13): claiming
            // ::/0 prevents IPv6 leaks, but if the exit path does not carry
            // IPv6, apps that prefer IPv6 pay a Happy-Eyeballs fallback delay
            // per connection. Disable via connectToBelnet(routeIpv6: false)
            // to benchmark the difference.
            if (mRouteIpv6) {
              builder.addRoute("::", 0);
              Log.e(LOG_TAG,"Address " + ourIP + " is IPv6.");
            } else {
              Log.w(LOG_TAG, "IPv6 route NOT claimed (route_ipv6=false): IPv6 traffic will bypass the tunnel!");
            }
        }
    }catch (UnknownHostException e) {
        // Handle UnknownHostException
        Log.e(LOG_TAG,"Exception thrown while routing " + e);
       // e.printStackTrace();
    }
      builder.addDnsServer(upstreamDNS);
      builder.setSession("Belnet dVPN");
      builder.setConfigureIntent(null);
      try{
        builder.addAllowedApplication("io.beldex.beldex_browser");
        //builder.addAllowedApplication("com.android.chrome");
      }catch(Exception e){
        Log.e(LOG_TAG,"error"+ e);
      }

      iface = builder.establish();
      if (iface == null) {
        Log.e(LOG_TAG, "VPN Interface from builder.establish() came back null");
        return false;
      }

      m_FD = iface.detachFd();

      InjectVPNFD();
      new Thread(
              () -> {
                Configure(config);
                m_UDPSocket = GetUDPSocket();
                protect(m_UDPSocket);
                Mainloop();
              })
              .start();

      Log.d(LOG_TAG, "started successfully!");
      new BelnetLibPlugin().logDataToFrontend("started successfully!"); //i new BelnetLibPlugin().logDataToFrontend("started successfully!"); //i added
    } else {
      Log.d(LOG_TAG, "already running");
      new BelnetLibPlugin().logDataToFrontend("already running");
    }

    startIsConnectedTimer();
    updateIsConnected();
//    Intent browserI = new Intent(Intent.ACTION_VIEW,Uri.parse("https://whatismyipaddress.com/"));
//    startActivity(browserI);
    return true;

  }

  // private void disconnect() {
  //   if (IsRunning()) {
  //     Stop();
  //     // stopSelf();
  //     stopForeground(true);
  //   }
  //   // if (impl != null) {
  //   //   //Free(impl);
  //   //   impl = null;
  //   // }

  //   cancelSpeedNotification();
  //   updateIsConnected();
  //   stopIsConnectedTimer();

  // }


  private void disconnect() {
    boolean running = false;
    try {
      running = IsRunning();
    } catch (Throwable t) {
      Log.e(LOG_TAG, "IsRunning() threw during disconnect: " + t);
    }
    if (running) {
      try {
        Stop();
      } catch (Throwable t) {
        Log.e(LOG_TAG, "Stop() threw during disconnect: " + t);
      }
    }

    // Make sure the tun interface actually goes down.
    //
    // The system VPN (and its status-bar key icon) only disappears once the
    // tun fd is closed. That fd was detachFd()'d to the native daemon in
    // connect(); the daemon closes it during a *successful* graceful
    // shutdown, but:
    //   - if the daemon never finished starting (failed / timed-out connect,
    //     i.e. the "Could not establish Belnet connection" path), IsRunning()
    //     is false, Stop() was skipped above, and nothing ever closes it;
    //   - if the daemon's shutdown hangs (no built paths / no connectivity),
    //     Mainloop() never returns and the fd again never gets closed.
    // In both cases the VPN key icon stayed in the status bar forever while
    // the app already showed "Disconnected". So: give the graceful shutdown
    // a short window, then close the fd ourselves (guarded by a /proc check
    // so we never touch an fd the daemon already closed).
    final int fd = m_FD;
    m_FD = -1;
    iface = null;
    if (fd >= 0) {
      if (!running) {
        // Daemon never ran: the fd is definitely leaked; close it right away.
        closeTunFd(fd);
      } else {
        new Thread(
            () -> {
              // Wait up to 4s for the daemon to stop gracefully.
              for (int i = 0; i < 16; i++) {
                try {
                  if (!IsRunning())
                    break;
                } catch (Throwable t) {
                  break;
                }
                SystemClock.sleep(250);
              }
              closeTunFd(fd);
            },
            "belnet-tun-teardown")
            .start();
      }
    }

    stopForeground(true);
    cancelSpeedNotification();
    updateIsConnected();
  }

/**
   * Close {@code fd} if (and only if) it still refers to the tun device.
   * The native daemon may already have closed it during a graceful shutdown
   * (after which the number could even have been recycled for an unrelated
   * file), so verify what the fd points at via /proc/self/fd before closing.
   */
  private static synchronized void closeTunFd(int fd) {
    try {
      String link = android.system.Os.readlink("/proc/self/fd/" + fd);
      if (link == null || !link.contains("tun")) {
        Log.e(LOG_TAG, "tun fd " + fd + " already closed/recycled (" + link + "); leaving it alone");
        return;
      }
      ParcelFileDescriptor.adoptFd(fd).close();
      Log.e(LOG_TAG, "tun fd " + fd + " force-closed; VPN interface torn down");
    } catch (Exception e) {
      Log.e(LOG_TAG, "tun fd " + fd + " already closed: " + e);
    }
  }

  public MutableLiveData<Boolean> isConnected() {
    return isConnected;
  }

  private void updateIsConnected() {
    isConnected.postValue(IsRunning() && VpnService.prepare(BelnetDaemon.this) == null);
  }

  /** Callback used to deliver the async result of an exit-node remap. */
  public interface UnmapCallback {
    void onResult(String result);
  }

  /**
   * Remaps the exit node asynchronously and delivers the REAL result via the
   * callback on the main thread.
   *
   * The previous implementation started a worker thread and immediately
   * returned the shared {@code results} field, i.e. it always returned the
   * previous call's value (or null) — the actual outcome of the remap was
   * never observed by the caller (latency audit section 3.5).
   */
  public void unmappingNode(String newNode, UnmapCallback callback) {
    // Ported hardening from belnet-app commit df16d27: a throwing JNI call
    // must still deliver a (null) result instead of killing the thread and
    // leaving the method-channel Result hanging forever.
    new Thread(
      () -> {
        String r;
        try {
          r = Unmap(newNode);
        } catch (Throwable t) {
          Log.e(LOG_TAG, "Unmap(" + newNode + ") threw: " + t);
          r = null;
        }
        results = r;
        final String value = r;
        new Handler(Looper.getMainLooper()).post(() -> callback.onResult(value));
      },
      "belnet-unmap")
      .start();
  }

  /**
   * True when the daemon's own status dump indicates onion paths are built
   * and the exit is mapped. This is the signal the UI must gate "Connected"
   * on — {@link #IsRunning()} only means the mainloop thread is alive.
   */
  public boolean isExitReady() {
    if (!IsRunning())
      return false;
    try {
      String dump = DumpStatus();
      if (dump == null || dump.isEmpty())
        return false;
      JSONObject status = new JSONObject(dump);
      if (!status.optBoolean("running", true))
        return false;
      JSONObject services = status.optJSONObject("services");
      if (services == null)
        return false;
      java.util.Iterator<String> keys = services.keys();
      while (keys.hasNext()) {
        JSONObject svc = services.optJSONObject(keys.next());
        if (svc == null)
          continue;
        JSONObject exitMap = svc.optJSONObject("exitMap");
        if (exitMap != null && exitMap.length() > 0)
          return true;
      }
    } catch (JSONException e) {
      Log.w(LOG_TAG, "isExitReady: could not parse status dump: " + e);
    }
    return false;
  }

  /**
   * Class for clients to access. Because we know this service always runs in the
   * same process as its clients, we don't need to deal with IPC.
   */
  public class LocalBinder extends Binder {
    public BelnetDaemon getService() {
      return BelnetDaemon.this;
    }
  }

  @Override
  public IBinder onBind(Intent intent) {
    String action = intent != null ? intent.getAction() : "";

    if (VpnService.SERVICE_INTERFACE.equals(action)) {
      return super.onBind(intent);
    }

    return mBinder;
  }

  private final IBinder mBinder = new LocalBinder();

  private class UpdateIsConnectedTask extends TimerTask {
    public void run() {
      updateIsConnected();
     // maybeUpdateSpeedNotification();
    }
  }

  // ---------------------------------------------------------------------
  // Ported from belnet-app commit df16d27 (audit F11): speed notification
  // updated natively from the service's existing timer, throttled to every
  // 3 seconds with setOnlyAlertOnce, and it survives even if the Flutter
  // engine is killed. (In belnet-app this replaced a Dart loop that
  // re-CREATED the notification once per second via awesome_notifications.)
  //
  // NOTE: this intentionally does not call startForeground() - the service
  // semantics are unchanged. Promoting to a true foreground service (with
  // android:foregroundServiceType in the manifest) is a recommended
  // follow-up.
  // ---------------------------------------------------------------------
  private static final int SPEED_NOTIFY_ID = 10;
  private static final String SPEED_CHANNEL_ID = "belnets_channel";
  private long mLastNotifyMs = 0;
  private long mNotifyLastTs = 0;
  private long mNotifyLastRx = 0;
  private long mNotifyLastTx = 0;
  private boolean mSpeedChannelEnsured = false;

  /** The browser app does not pre-create "belnets_channel" the way the
   *  belnet-app does, so create it here on first use (no-op if it exists). */
  private void ensureSpeedChannel() {
    if (mSpeedChannelEnsured)
      return;
    mSpeedChannelEnsured = true;
    // if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
    //   try {
    //     NotificationManager nm =
    //         (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
    //     if (nm != null && nm.getNotificationChannel(SPEED_CHANNEL_ID) == null) {
    //       NotificationChannel channel = new NotificationChannel(
    //           SPEED_CHANNEL_ID, "Belnet speed",
    //           NotificationManager.IMPORTANCE_LOW);
    //       channel.setShowBadge(false);
    //       nm.createNotificationChannel(channel);
    //     }
    //   } catch (Throwable t) {
    //     Log.w(LOG_TAG, "could not ensure speed notification channel: " + t);
    //   }
    // }
  }

  private void maybeUpdateSpeedNotification() {
    if (!IsRunning())
      return;
    long now = SystemClock.elapsedRealtime();
    if (now - mLastNotifyMs < 3000)
      return;
    mLastNotifyMs = now;

    long rx = TrafficStats.getTotalRxBytes();
    long tx = TrafficStats.getTotalTxBytes();
    String body = "↑ 0.0 bps ↓ 0.0 bps";
    if (mNotifyLastTs != 0) {
      float dt = (now - mNotifyLastTs) / 1000f;
      if (dt > 0f) {
        // Halved: TrafficStats counts tunneled bytes twice (tun + physical).
        long up = (long) (Math.max(0, tx - mNotifyLastTx) / 2 / dt);
        long down = (long) (Math.max(0, rx - mNotifyLastRx) / 2 / dt);
        body = "↑ " + ConnectionTools.bytesToSize(up) + "ps ↓ "
            + ConnectionTools.bytesToSize(down) + "ps";
      }
    }
    mNotifyLastTs = now;
    mNotifyLastRx = rx;
    mNotifyLastTx = tx;

    try {
      ensureSpeedChannel();
      Intent launch = getPackageManager().getLaunchIntentForPackage(getPackageName());
      PendingIntent contentIntent = launch == null ? null
          : PendingIntent.getActivity(this, 0, launch,
              PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

      NotificationCompat.Builder builder =
          new NotificationCompat.Builder(this, SPEED_CHANNEL_ID)
              .setSmallIcon(io.beldex.belnet_lib.R.drawable.belnet_svg)
              .setContentTitle("Belnet dVPN")
              .setContentText(body)
              .setOngoing(true)
              .setOnlyAlertOnce(true)
              .setSilent(true)
              .setCategory(NotificationCompat.CATEGORY_SERVICE);
      if (contentIntent != null)
        builder.setContentIntent(contentIntent);
      NotificationManagerCompat.from(this).notify(SPEED_NOTIFY_ID, builder.build());
    } catch (Throwable t) {
      // Missing channel or notification permission: never let the
      // notification path take down the VPN timer.
      Log.w(LOG_TAG, "speed notification update failed: " + t);
    }
  }

  private void cancelSpeedNotification() {
    try {
      NotificationManagerCompat.from(this).cancel(SPEED_NOTIFY_ID);
    } catch (Throwable t) {
      Log.w(LOG_TAG, "speed notification cancel failed: " + t);
    }
    mNotifyLastTs = 0;
    mLastNotifyMs = 0;
  }


}

