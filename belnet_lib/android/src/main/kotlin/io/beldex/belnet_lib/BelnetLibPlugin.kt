package io.beldex.belnet_lib

import android.annotation.SuppressLint
import android.app.Activity.RESULT_OK
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.TrafficStats
import android.net.VpnService
import android.os.IBinder
import android.os.SystemClock
import android.provider.Settings
import android.util.Log
import androidx.annotation.NonNull
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Observer
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry
import network.beldex.belnet.BelnetDaemon
import network.beldex.belnet.ConnectionTools
import androidx.core.content.ContextCompat
import org.json.JSONObject
import kotlin.math.roundToLong

import android.content.ServiceConnection

import android.view.WindowManager
import android.app.Activity






import android.content.*
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.os.Build
import android.os.Looper
import android.os.Handler









import android.content.BroadcastReceiver
import android.content.IntentFilter
import android.telephony.TelephonyManager


/** BelnetLibPlugin */
open class BelnetLibPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private var mShouldUnbind: Boolean = false
    private var mBoundService: BelnetDaemon? = null
    private var lastTimestamp = 0L
    private lateinit var activityBinding: ActivityPluginBinding
   private lateinit var lifecycleOwner: LifecycleOwner

    private var activity: Activity? = null

    private var sessionDownloaded = 0L
    private var sessionUploaded = 0L
    private var lastTotalDownload = 0L
    private var lastTotalUpload = 0L
    private var sessionStart = 0L
    private var logData: String = ""
    lateinit var notificationManager: NotificationManager
    lateinit var notificationChannel: NotificationChannel
    lateinit var builder: Notification.Builder
    lateinit var myD: String
    var mutableString: MutableLiveData<String> = MutableLiveData()

    private lateinit var mMethodChannel: MethodChannel
    private lateinit var mIsConnectedEventChannel: EventChannel

    private var mEventSink: EventChannel.EventSink? = null



    // Ported from belnet-app commit df16d27 (audit F4): underlying-network
    // change events forwarded from BelnetDaemon to the Flutter layer.
    private lateinit var networkChangeEventChannel: EventChannel
    private var networkChangeEventSink: EventChannel.EventSink? = null
    private var networkChangeReceiver: BroadcastReceiver? = null

    // Ported from belnet-app commit df16d27 (audit F9): consolidated 1 Hz
    // status feed - one GetStatus() JNI call and one TrafficStats sample per
    // second, pushed to Dart.
    private lateinit var statusEventChannel: EventChannel
    private var statusEventSink: EventChannel.EventSink? = null
    private var statusHandler: Handler? = null
    private var statusRunnable: Runnable? = null
    private val speedMeter = SpeedMeter()

    private lateinit var notificationDisconnectEventChannel: EventChannel

     private lateinit var notificationDisconnectReceiver: BroadcastReceiver
     private var disconnectEventSink: EventChannel.EventSink? = null


  // Audio Focus
    private var focusRequest: AudioFocusRequest? = null
    private var audioFocusChangeListener: AudioManager.OnAudioFocusChangeListener? = null
    private lateinit var context: Context
    private lateinit var messenger: io.flutter.plugin.common.BinaryMessenger




    private var mIsConnectedObserver = Observer<Boolean> { newIsConnected ->
        mEventSink?.success(newIsConnected)
    }


// 📞 Call & audio route broadcast receiver
    private val callReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                AudioManager.ACTION_SCO_AUDIO_STATE_UPDATED -> {
                    val state = intent.getIntExtra(AudioManager.EXTRA_SCO_AUDIO_STATE, -1)
                    if (state == AudioManager.SCO_AUDIO_STATE_CONNECTED ||
                        state == AudioManager.SCO_AUDIO_STATE_CONNECTING
                    ) {
                        Log.d("CallState", " SCO audio active — stopping TTS.")
                        sendFocusEventToFlutter("focusLost")
                    }
                }

                AudioManager.ACTION_AUDIO_BECOMING_NOISY -> {
                    Log.d("CallState", " Headphones unplugged / route changed.")
                    //sendFocusEventToFlutter("audio_noisy")
                }

                TelephonyManager.ACTION_PHONE_STATE_CHANGED -> {
                    val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
                    if (state == TelephonyManager.EXTRA_STATE_RINGING ||
                        state == TelephonyManager.EXTRA_STATE_OFFHOOK
                    ) {
                        Log.d("CallState", " Incoming or ongoing phone call — stop TTS.")
                        sendFocusEventToFlutter("focusLost")
                    }
                }
            }
        }
    }











    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        System.loadLibrary("belnet-android")


          context = binding.applicationContext
         messenger = binding.binaryMessenger



        mMethodChannel = MethodChannel(binding.binaryMessenger, "belnet_lib_method_channel")
        mMethodChannel.setMethodCallHandler(this)

        mIsConnectedEventChannel =
            EventChannel(binding.binaryMessenger, "belnet_lib_is_connected_event_channel")
        mIsConnectedEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                mEventSink = events
            }

            override fun onCancel(arguments: Any?) {
                mEventSink?.endOfStream()
                mEventSink = null
            }
        })



    notificationDisconnectEventChannel = EventChannel(binding.binaryMessenger, "belnet_lib_notification_disconnect_event_channel")
        notificationDisconnectEventChannel.setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    disconnectEventSink = events
                    notificationDisconnectReceiver = object : BroadcastReceiver() {
                        override fun onReceive(context: Context?, intent: Intent?) {
                            if (intent?.action == "com.belnet.NOTIFICATION_DISCONNECTED") {
                                Log.d("BelnetLibPlugin", "Received notification disconnect broadcast")
                                disconnectEventSink?.success("notification_disconnect")
                            }
                        }
                    }
                    val filter = IntentFilter("com.belnet.NOTIFICATION_DISCONNECTED")
                    context.registerReceiver(notificationDisconnectReceiver, filter)
                }

                override fun onCancel(arguments: Any?) {
                    disconnectEventSink = null
                    try {
                        notificationDisconnectReceiver?.let {
                            context.unregisterReceiver(it)
                        }
                    } catch (e: Exception) {
                        Log.e("BelnetLibPlugin", "Receiver already unregistered: ${e.message}")
                    }
                }
            }
        )




    // Ported from belnet-app commit df16d27 (audit F4): underlying-network
        // change events from BelnetDaemon (Wi-Fi <-> mobile handover). The
        // Flutter side uses this to run an immediate tunnel health probe
        // instead of waiting for the next periodic one.
        networkChangeEventChannel =
            EventChannel(binding.binaryMessenger, "belnet_lib_network_change_event_channel")
        networkChangeEventChannel.setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    networkChangeEventSink = events
                    networkChangeReceiver = object : BroadcastReceiver() {
                        override fun onReceive(ctx: Context?, intent: Intent?) {
                            if (intent?.action == BelnetDaemon.ACTION_NETWORK_CHANGED) {
                                Log.d("BelnetLibPlugin", "Received network change broadcast")
                                networkChangeEventSink?.success("network_changed")
                            }
                        }
                    }
                    val filter = IntentFilter(BelnetDaemon.ACTION_NETWORK_CHANGED)
                    ContextCompat.registerReceiver(
                        context,
                        networkChangeReceiver,
                        filter,
                        ContextCompat.RECEIVER_NOT_EXPORTED
                    )
                }

                override fun onCancel(arguments: Any?) {
                    networkChangeEventSink = null
                    try {
                        networkChangeReceiver?.let { context.unregisterReceiver(it) }
                    } catch (e: Exception) {
                        Log.e("BelnetLibPlugin", "network change receiver already unregistered: ${e.message}")
                    }
                    networkChangeReceiver = null
                }
            }
        )

        // Ported from belnet-app commit df16d27 (audit F9): consolidated
        // status feed - one 1 Hz tick doing ONE GetStatus() JNI call and ONE
        // TrafficStats sample, pushed to Dart. Replaces independent Dart
        // timers each crossing the platform channel every 1-2 seconds.
        statusEventChannel =
            EventChannel(binding.binaryMessenger, "belnet_lib_status_event_channel")
        statusEventChannel.setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    statusEventSink = events
                    statusHandler = Handler(Looper.getMainLooper())
                    statusRunnable = object : Runnable {
                        override fun run() {
                            emitStatus()
                            statusHandler?.postDelayed(this, 1000)
                        }
                    }
                    statusHandler?.post(statusRunnable!!)
                }

                override fun onCancel(arguments: Any?) {
                    statusRunnable?.let { statusHandler?.removeCallbacks(it) }
                    statusRunnable = null
                    statusHandler = null
                    statusEventSink = null
                }
            }
        )






        // Audio phone call
        registerCallAndAudioReceivers()
    }

    private fun emitStatus() {
        val sink = statusEventSink ?: return
        val speeds = speedMeter.sample()
        val payload = JSONObject()
        try {
            // getStatusSafe(): GetStatus() (belnet-app df16d27) with an
            // automatic DumpStatus() fallback if the native lib doesn't
            // export the GetStatus JNI symbol.
            val raw = mBoundService?.getStatusSafe()
            payload.put(
                "status",
                if (raw.isNullOrEmpty()) JSONObject.NULL else JSONObject(raw)
            )
        } catch (e: Exception) {
            payload.put("status", JSONObject.NULL)
        }
        payload.put("upload", speeds.first)
        payload.put("download", speeds.second)
        payload.put("isRunning", mBoundService?.IsRunning() ?: false)
        sink.success(payload.toString())
    }

    /**
     * Ported from belnet-app commit df16d27 (audit F9): device-level
     * throughput sampling shared by the status feed. Values are halved
     * because with the VPN active TrafficStats counts every payload byte
     * twice (once on the tun device, once on the physical interface).
     */
    private class SpeedMeter {
        private var lastTimestamp = 0L
        private var lastRx = 0L
        private var lastTx = 0L

        /** Returns Pair(uploadBytesPerSec, downloadBytesPerSec). */
        fun sample(): Pair<Long, Long> {
            val now = SystemClock.elapsedRealtime()
            val rx = TrafficStats.getTotalRxBytes()
            val tx = TrafficStats.getTotalTxBytes()
            if (lastTimestamp == 0L) {
                lastTimestamp = now
                lastRx = rx
                lastTx = tx
                return Pair(0L, 0L)
            }
            val dt = (now - lastTimestamp) / 1000f
            if (dt <= 0f) return Pair(0L, 0L)
            val up = (((tx - lastTx).coerceAtLeast(0) / 2) / dt).roundToLong()
            val down = (((rx - lastRx).coerceAtLeast(0) / 2) / dt).roundToLong()
            lastTimestamp = now
            lastRx = rx
            lastTx = tx
            return Pair(up, down)
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        mMethodChannel.setMethodCallHandler(null)
        // Ported from belnet-app commit df16d27: stop the 1 Hz status ticker
        // and unregister the network-change receiver so nothing leaks across
        // engine restarts.
        statusRunnable?.let { statusHandler?.removeCallbacks(it) }
        statusRunnable = null
        statusHandler = null
        statusEventSink = null
        try {
            networkChangeReceiver?.let { context.unregisterReceiver(it) }
            notificationDisconnectReceiver?.let {context.unregisterReceiver(it) }

        } catch (e: Exception) {
            Log.w("BelnetLibPlugin", "network change receiver already unregistered: ${e.message}")
        }
        networkChangeReceiver = null
        networkChangeEventSink = null
        doUnbindService()
        unregisterReceivers()
    }


private fun registerCallAndAudioReceivers() {
        val filter = IntentFilter().apply {
            addAction(AudioManager.ACTION_SCO_AUDIO_STATE_UPDATED)
            //addAction(AudioManager.ACTION_AUDIO_BECOMING_NOISY)
            addAction(TelephonyManager.ACTION_PHONE_STATE_CHANGED)
        }
        context.registerReceiver(callReceiver, filter)
    }

    private fun unregisterReceivers() {
        try {
            context.unregisterReceiver(callReceiver)
        } catch (e: Exception) {
            Log.w("CelnetLibPlugin", "Receiver already unregistered or not initialized.")
        }
    }










    @SuppressLint("NewApi")
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            "prepare" -> {
                val intent = VpnService.prepare(activityBinding.activity.applicationContext)
                if (intent != null) {
                    var listener: PluginRegistry.ActivityResultListener? = null
                    listener = PluginRegistry.ActivityResultListener { req, res, _ ->
                        if (req == 0 && res == RESULT_OK) {
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                        listener?.let { activityBinding.removeActivityResultListener(it) }
                        true
                    }
                    activityBinding.addActivityResultListener(listener)
                    activityBinding.activity.startActivityForResult(intent, 0)
                } else {
                    result.success(true)
                }
            }

            "isPrepared" -> {
                val intent = VpnService.prepare(activityBinding.activity.applicationContext)
                result.success(intent == null)
            }

            "connect" -> {
                val intent = VpnService.prepare(activityBinding.activity.applicationContext)
                if (intent != null) {
                    result.success(false)
                    return
                }

                val exitNode = call.argument<String>("exit_node")
                val upstreamDNS = call.argument<String>("upstream_dns")
                // Ported from belnet-app commit df16d27 (audit F5/F12/F13).
                val logLevel = call.argument<String>("log_level")
                val mtu = call.argument<Int>("mtu")
                val routeIpv6 = call.argument<Boolean>("route_ipv6")



                val belnetIntent = Intent(activityBinding.activity.applicationContext, BelnetDaemon::class.java)
                belnetIntent.action = BelnetDaemon.ACTION_CONNECT
                belnetIntent.putExtra(BelnetDaemon.EXIT_NODE, exitNode)
                belnetIntent.putExtra(BelnetDaemon.UPSTREAM_DNS, upstreamDNS)
                belnetIntent.putExtra(BelnetDaemon.LOG_LEVEL, logLevel ?: "warn")
                belnetIntent.putExtra(BelnetDaemon.MTU, mtu ?: 1400)
                belnetIntent.putExtra(BelnetDaemon.ROUTE_IPV6, routeIpv6 ?: true)

                activityBinding.activity.applicationContext.startService(belnetIntent)
                doBindService()
                result.success(true)
            }

            "disconnect" -> {
                // val intent = VpnService.prepare(activityBinding.activity.applicationContext)
                // if (intent != null) {
                //     result.success(false)
                //     return
                // }

                // val belnetIntent = Intent(activityBinding.activity.applicationContext, BelnetDaemon::class.java)
                // belnetIntent.action = BelnetDaemon.ACTION_DISCONNECT

                // activityBinding.activity.applicationContext.startService(belnetIntent)
                // doUnbindService()
                // Log.d("Test", "inside disconnect function")
                // result.success(true)
                  val ctx = activityBinding.activity.applicationContext
                val belnetIntent = Intent(ctx, BelnetDaemon::class.java).apply {
                    action = BelnetDaemon.ACTION_DISCONNECT
                }
                ctx.startService(belnetIntent)
                doBindService()
                Log.d("BelnetLibPlugin", "Disconnect called")
                result.success(true)
            }

            "isRunning" -> {
                result.success(mBoundService?.IsRunning() ?: false)
            }

            "getStatus" -> {
                 // Ported from belnet-app commit df16d27 (audit F9): return
                // null (not false) when unbound so the Dart layer never
                // crashes on a bool-to-String cast.
                result.success(mBoundService?.DumpStatus())
            }

            "getUploadSpeed" -> {
                val timestamp = SystemClock.elapsedRealtime()
                val elapsedMillis = timestamp - lastTimestamp
                val elapsedSeconds = elapsedMillis / 1000f
                val totalUpload = TrafficStats.getTotalTxBytes()
                val uploaded = (totalUpload - lastTotalUpload).coerceAtLeast(0) / 2
                val uploadSpeed = (uploaded / elapsedSeconds).roundToLong()
                sessionUploaded += uploaded

                val uploadString = ConnectionTools.bytesToSize(uploadSpeed) + "ps"
                result.success(uploadString)

                lastTotalUpload = totalUpload
                lastTimestamp = timestamp
            }

            "getDownloadSpeed" -> {
                val timestamp = SystemClock.elapsedRealtime()
                val elapsedMillis = timestamp - lastTimestamp
                val elapsedSeconds = elapsedMillis / 1000f
                val totalDownload = TrafficStats.getTotalRxBytes()
                val totalUpload = TrafficStats.getTotalTxBytes()
                val downloaded = (totalDownload - lastTotalDownload).coerceAtLeast(0) / 2
                val uploaded = (totalUpload - lastTotalUpload).coerceAtLeast(0) / 2
                val downloadSpeed = (downloaded / elapsedSeconds).roundToLong()
                val uploadSpeed = (uploaded / elapsedSeconds).roundToLong()

                sessionDownloaded += downloaded
                sessionUploaded += uploaded

                val downloadString = ConnectionTools.bytesToSize(downloadSpeed) + "ps"
                Log.d("TagDownload", "This is downloadString$downloadString")
                result.success(downloadString)

                lastTotalDownload = totalDownload
                lastTotalUpload = totalUpload
                lastTimestamp = timestamp
            }

            "getDataStatus" -> {
                // Ported from belnet-app commit df16d27 (audit F9): this was
                // a stub returning `false`. Used by the Dart-side status
                // consumers; must return null (never `false`) when the
                // service is not bound so callers keep polling instead of
                // crashing on a cast.
                val service = mBoundService
                if (service == null) {
                    Log.w("BelnetLibPlugin", "getDataStatus: Service not bound yet")
                    result.success(null)
                    return
                }
                try {
                    // getStatusSafe(): GetStatus() (belnet-app df16d27)
                    // with automatic DumpStatus() fallback.
                    result.success(service.getStatusSafe())
                } catch (e: Exception) {
                    Log.e("BelnetLibPlugin", "Exception in getDataStatus", e)
                    result.success(null)
                }
            }

            "getMap" -> {
               val swapNode = call.argument<String>("swap_node")
                val service = mBoundService
                if (service == null || swapNode == null) {
                    // Ported from belnet-app commit df16d27: also guard a
                    // null swap_node argument.
                    Log.w("BelnetLibPlugin", "getMap: service not bound or no swap_node")
                    result.success(null)
                } else {
                    // Deliver the REAL remap result asynchronously; the old
                    // code returned a stale field before the worker finished.
                    // The `replied` flag (belnet-app) protects against a
                    // double result.success() if the callback ever fires
                    // twice, which crashes the method channel.
                    var replied = false
                    service.unmappingNode(swapNode) { r ->
                        if (!replied) {
                            replied = true
                            result.success(r)
                        }
                    }
                }
            }

            "isExitReady" -> {
                result.success(mBoundService?.isExitReady() ?: false)
            }

            "getUnmapStatus" -> {
                result.success(mBoundService?.Status() ?: false)
            }

            "setDefaultBrowser" -> {
                val intent = Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS)
                activityBinding.activity.startActivityForResult(intent, 0)
                result.success(true)
            }

            "disconnectForNotification" -> {
                result.success(mBoundService != null)
            }
             "enableSecure" -> {
                    // activityBinding.activity.window.setFlags(
                    //     WindowManager.LayoutParams.FLAG_SECURE,
                    //     WindowManager.LayoutParams.FLAG_SECURE
                    // )
                    // Log.d("Test", "ENABLEDDDDDDDD SCREEN")
                    // result.success(true)


                     try {
                            println("Enabling screen security")
                             activityBinding.activity.window.setFlags(
                                WindowManager.LayoutParams.FLAG_SECURE,
                                WindowManager.LayoutParams.FLAG_SECURE
                            )
                            result.success(true)
                        } catch (e: Exception) {
                            println("Error enabling screen security: ${e.message}")
                            result.error("SCREEN_SECURITY_ERROR", "Failed to enable screen security", e.message)
                        }
                }
                "disableSecure" -> {
                    try {
                            println("Disabling screen security")
                            activityBinding.activity.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                            result.success(true)
                        } catch (e: Exception) {
                            println("Error disabling screen security: ${e.message}")
                            result.error("SCREEN_SECURITY_ERROR", "Failed to disable screen security", e.message)
                        }
                }
             "requestAudioFocus" -> {
                requestAudioFocus()
                result.success(true)
            }
            "abandonAudioFocus" -> {
                abandonAudioFocus()
                result.success(true)
            }
            "isCallActive" -> {
                
                result.success(isCallActive())
            }

            else -> result.notImplemented()
        }
    }


private fun requestAudioFocus() {
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager

        audioFocusChangeListener = AudioManager.OnAudioFocusChangeListener { focusChange ->
            when (focusChange) {
                AudioManager.AUDIOFOCUS_LOSS -> {
                    Log.d("AudioFocus", "Permanent loss. Stop TTS.")
                    sendFocusEventToFlutter("focusLost")
                }
                AudioManager.AUDIOFOCUS_LOSS_TRANSIENT,
                AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> {
                    Log.d("AudioFocus", "Transient loss.")
                    //sendFocusEventToFlutter("focusTransient")
                }
                AudioManager.AUDIOFOCUS_GAIN -> {
                    Log.d("AudioFocus", "Focus regained. Resume TTS if paused.")
                    //sendFocusEventToFlutter("focusGained")
                }
            }
        }

        focusRequest = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE)
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ASSISTANT)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                        .build()
                )
                .setOnAudioFocusChangeListener(audioFocusChangeListener!!)
                .setWillPauseWhenDucked(true)
                .build()
        } else null

        val result = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && focusRequest != null) {
            audioManager.requestAudioFocus(focusRequest!!)
        } else {
            @Suppress("DEPRECATION")
            audioManager.requestAudioFocus(
                audioFocusChangeListener,
                AudioManager.STREAM_MUSIC,
                AudioManager.AUDIOFOCUS_GAIN_TRANSIENT
            )
        }

        if (result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
            Log.d("AudioFocus", " Focus granted")
        }
    }

    private fun abandonAudioFocus() {
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && focusRequest != null) {
            audioManager.abandonAudioFocusRequest(focusRequest!!)
        } else {
            @Suppress("DEPRECATION")
            audioManager.abandonAudioFocus(audioFocusChangeListener)
        }
    }

    private fun sendFocusEventToFlutter(event: String) {
        Handler(Looper.getMainLooper()).post {
            MethodChannel(messenger, "belnet_lib_method_channel").invokeMethod("focusLost", null)
        }
    }


@SuppressLint("MissingPermission")
private fun isCallActive(): Boolean {
    try {
        val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        val state = telephonyManager.callState
        if (state == TelephonyManager.CALL_STATE_OFFHOOK || state == TelephonyManager.CALL_STATE_RINGING) {
            Log.d("CallState", "📞 Regular phone call active or ringing")
            return true
        }
    } catch (e: Exception) {
        Log.e("CallState", "Error checking call state: ${e.message}")
    }

    // --- Optional: detect ongoing VoIP (e.g., WhatsApp, Zoom) ---
    try {
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val isVoipActive = audioManager.mode == AudioManager.MODE_IN_COMMUNICATION ||
                           audioManager.mode == AudioManager.MODE_RINGTONE
        if (isVoipActive) {
            Log.d("CallState", "VoIP or Internet call in progress")
            return true
        }
    } catch (e: Exception) {
        Log.e("CallState", "Error checking VoIP call state: ${e.message}")
    }

    return false
}


// private fun isCallActive(): Boolean {
//     val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
//     return telephonyManager.callState == TelephonyManager.CALL_STATE_OFFHOOK ||
//            telephonyManager.callState == TelephonyManager.CALL_STATE_RINGING
// }



override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activityBinding = binding
    val hiddenLifecycle = binding.lifecycle as HiddenLifecycleReference
    lifecycleOwner = object : LifecycleOwner {
        override val lifecycle: Lifecycle = hiddenLifecycle.lifecycle
    }
    doBindService()
}

override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activityBinding = binding
    val hiddenLifecycle = binding.lifecycle as HiddenLifecycleReference
    lifecycleOwner = object : LifecycleOwner {
        override val lifecycle: Lifecycle = hiddenLifecycle.lifecycle
    }
    doBindService()
}



    override fun onDetachedFromActivity() {}
    override fun onDetachedFromActivityForConfigChanges() {}

    private val mConnection: ServiceConnection = object : ServiceConnection {
        override fun onServiceConnected(className: ComponentName, service: IBinder) {
            mBoundService = (service as BelnetDaemon.LocalBinder).getService()
            mBoundService?.isConnected()?.observe(lifecycleOwner, mIsConnectedObserver)

        }

        override fun onServiceDisconnected(className: ComponentName) {
            mBoundService = null
        }
    }

    fun doBindService() {
        if (activityBinding.activity.applicationContext.bindService(
                Intent(activityBinding.activity.applicationContext, BelnetDaemon::class.java),
                mConnection,
                Context.BIND_AUTO_CREATE
            )
        ) {
            mShouldUnbind = true
        } else {
            Log.e(BelnetDaemon.LOG_TAG, "Error: The requested service doesn't exist, or this client isn't allowed access to it.")
        }
    }

    fun doUnbindService() {
        if (mShouldUnbind) {
            activityBinding.activity.applicationContext.unbindService(mConnection)
            mShouldUnbind = false
        }
    }

    fun logDataToFrontend(sampleData: String): String {
        logData = sampleData
        Log.d("backtracking", logData)
        return logData
    }
}
