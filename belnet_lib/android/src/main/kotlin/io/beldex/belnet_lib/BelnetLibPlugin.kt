package io.beldex.belnet_lib


//import android.R.attr.name

//import android.R.attr.name


//import android.content.Context

import android.annotation.SuppressLint
import android.app.Activity.RESULT_OK
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.net.TrafficStats
import android.net.VpnService

import android.os.IBinder
import android.os.SystemClock
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
import kotlin.math.roundToLong

import android.provider.Settings;

/** BelnetLibPlugin */
open class BelnetLibPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private var mShouldUnbind: Boolean = false
    private var mBoundService: BelnetDaemon? = null
    private var lastTimestamp = 0L
    private lateinit var activityBinding: ActivityPluginBinding
    private var sessionDownloaded = 0L
    private var sessionUploaded = 0L
    private var lastTotalDownload = 0L
    private var lastTotalUpload = 0L
    private var sessionStart = 0L
    private var logData:String = ""
    lateinit var notificationManager: NotificationManager
    lateinit var notificationChannel: NotificationChannel
    lateinit var builder: Notification.Builder
    lateinit var  myD:String
    var mutableString : MutableLiveData<String> = MutableLiveData()
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var mMethodChannel: MethodChannel
    private lateinit var mIsConnectedEventChannel: EventChannel

    private var mEventSink: EventChannel.EventSink? = null
    private var mIsConnectedObserver =
            Observer<Boolean> { newIsConnected ->
                // Propagate to the dart package.
                mEventSink?.success(newIsConnected)
            }



    private var mLifecycleOwner =
            object : LifecycleOwner {
                override fun getLifecycle(): Lifecycle {
                    return (activityBinding.lifecycle as HiddenLifecycleReference).lifecycle
                }
            }

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        System.loadLibrary("belnet-android")

        mMethodChannel = MethodChannel(binding.binaryMessenger, "belnet_lib_method_channel")
        mMethodChannel.setMethodCallHandler(this)

        mIsConnectedEventChannel =
                EventChannel(binding.binaryMessenger, "belnet_lib_is_connected_event_channel")
        mIsConnectedEventChannel.setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                        mEventSink = events
                    }

                    override fun onCancel(arguments: Any?) {
                        mEventSink?.endOfStream()
                        mEventSink = null
                    }
                }
        )

    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        mMethodChannel.setMethodCallHandler(null)

        doUnbindService()
    }

    @SuppressLint("NewApi")
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            "prepare" -> {
                val intent = VpnService.prepare(activityBinding.activity.applicationContext)
                if (intent != null) {
                    var listener: PluginRegistry.ActivityResultListener? = null
                    listener =
                            PluginRegistry.ActivityResultListener { req, res, _ ->
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
                    // If intent is null, already prepared
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
                    // Not prepared yet
                    result.success(false)
                    return
                }

                val exitNode = call.argument<String>("exit_node")
                val upstreamDNS = call.argument<String>("upstream_dns")

                val belnetIntent =
                        Intent(
                                activityBinding.activity.applicationContext,
                                BelnetDaemon::class.java
                        )
                belnetIntent.action = BelnetDaemon.ACTION_CONNECT
                belnetIntent.putExtra(BelnetDaemon.EXIT_NODE, exitNode)
                belnetIntent.putExtra(BelnetDaemon.UPSTREAM_DNS, upstreamDNS)

                activityBinding.activity.applicationContext.startService(belnetIntent)
                doBindService()
                result.success(true)
            }
            "disconnect" -> {
                var intent = VpnService.prepare(activityBinding.activity.applicationContext)
                if (intent != null) {
                    // Not prepared yet
                    result.success(false)
                    return
                }
                val belnetIntent =
                        Intent(
                                activityBinding.activity.applicationContext,
                                BelnetDaemon::class.java
                        )
               belnetIntent.action = BelnetDaemon.ACTION_DISCONNECT

                activityBinding.activity.applicationContext.startService(belnetIntent)

            doUnbindService()
                Log.d("Test","inside disconnect function")

                result.success(true)
            }
            "isRunning" -> {
                if (mBoundService != null) {
                    result.success(mBoundService!!.IsRunning())
                } else {
                    result.success(false)
                }
            }
            "getStatus" -> {
                if (mBoundService != null) {
                    result.success(mBoundService!!.DumpStatus())
                    Log.d("Test","mBoundService is " + mBoundService)
                } else {
                    result.success(false)
                }
            }
             "getUploadSpeed" -> {
                     val timestamp = SystemClock.elapsedRealtime()
                     val elapsedMillis = timestamp - lastTimestamp
                     val elapsedSeconds = elapsedMillis / 1000f

                     // Speeds need to be divided by two due to TrafficStats calculating both phone and VPN
                     // interfaces which leads to doubled data. NetworkStatsManager may have solved this
                     // problem but is only available from marshmallow.
                     val totalUpload = TrafficStats.getTotalTxBytes()
                     val uploaded = (totalUpload - lastTotalUpload).coerceAtLeast(0) / 2

                     val uploadSpeed = (uploaded / elapsedSeconds).roundToLong()

                     sessionUploaded += uploaded
                     val sessionTimeSeconds = (timestamp - sessionStart).toInt() / 1000
                 var sessionUploadString = ConnectionTools.bytesToSize(sessionUploaded)
                 var uploadSpeedString = ConnectionTools.bytesToSize(uploadSpeed) +"ps"
              //  UpdateNetwork(true).callfunctionContinuesly(uploadSpeedString)

                 val uploadString = ConnectionTools.bytesToSize(uploadSpeed) +"ps"
                 result.success(uploadString)

                // callFunction(uploadString);
                     lastTotalUpload = totalUpload
                     lastTimestamp = timestamp

             }
            "getDownloadSpeed" -> {
                val timestamp = SystemClock.elapsedRealtime()
                val elapsedMillis = timestamp - lastTimestamp
                val elapsedSeconds = elapsedMillis / 1000f

                // Speeds need to be divided by two due to TrafficStats calculating both phone and VPN
                // interfaces which leads to doubled data. NetworkStatsManager may have solved this
                // problem but is only available from marshmallow.
                val totalDownload = TrafficStats.getTotalRxBytes()
                val totalUpload = TrafficStats.getTotalTxBytes()
                val downloaded = (totalDownload - lastTotalDownload).coerceAtLeast(0) / 2
                val uploaded = (totalUpload - lastTotalUpload).coerceAtLeast(0) / 2
                val downloadSpeed = (downloaded / elapsedSeconds).roundToLong()
                val uploadSpeed = (uploaded / elapsedSeconds).roundToLong()

                sessionDownloaded += downloaded
                sessionUploaded += uploaded

                val sessionTimeSeconds = (timestamp - sessionStart).toInt() / 1000
                val downloadString = ConnectionTools.bytesToSize(downloadSpeed) + "ps"
                Log.d("TagDownload", "This is downloadString$downloadString")
                result.success(downloadString)


                lastTotalDownload = totalDownload
                lastTotalUpload = totalUpload
                lastTimestamp = timestamp
            }
            "getDataStatus"->{
                // if (mBoundService != null) {
                //     result.success(mBoundService!!.GetStatus())
                //     Log.d("Test","mBoundService is " + mBoundService!!.GetStatus())
                // } else {
                    result.success(false)
                //}
            }
            "getMap"-> {

                if (mBoundService != null) {

                    val swapNode = call.argument<String>("swap_node")
                    Log.d("Test","Swap Node from un map ")
                    result.success(mBoundService!!.unmappingNode(swapNode))
                   // result.success(mBoundService!!.Unmap(swapNode))
                } else {
                    result.success(false)
                }
            }
            "getUnmapStatus"->{
                 if (mBoundService != null) {
                    result.success(mBoundService!!.Status())
                } else {
                    result.success(false)
                }
            }
//             "logData" ->{

//                 Log.d("Testings","")
//                var datas = logDataToFrontend("")

// //             myD = LogDisplayForUi("").displayData()
// //             Log.d("Dis data",myD)
//                 result.success(datas)
//             }
             "setDefaultBrowser"->{
                 val intent = Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS)
                //  if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q){ //Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS)
                //   Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS).apply{
                //     putExtra(Settings.EXTRA_APP_PACKAGE,"android")
                //     putExtra("package_name",activityBinding.activity.applicationContext.packageName)
                //   }
                //  }else{
                //    Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS)
                //  }
                 
                activityBinding.activity.startActivityForResult(intent, 0)
                // intent.setData(Uri.parse("package:" + Activity.getPackageName()));
                // //Activity.startActivity(intent);
                // activityBinding.activity.applicationContext.startService(intent)
                result.success(true)
            }
             "disconnectForNotification" -> {
                 if(mBoundService != null){

                     result.success(true)
                 }else{
                     result.success(false)
                 }
             }
            else -> result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        doBindService()
    }

    override fun onDetachedFromActivity() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityBinding = binding
        doBindService()
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    private val mConnection: ServiceConnection =
            object : ServiceConnection {
                override fun onServiceConnected(className: ComponentName, service: IBinder) {
                    mBoundService = (service as BelnetDaemon.LocalBinder).getService()

                    mBoundService?.isConnected()?.observe(mLifecycleOwner, mIsConnectedObserver)
                }

                override fun onServiceDisconnected(className: ComponentName) {
                    mBoundService = null

                }
            }

    fun doBindService() {
        if (activityBinding.activity.applicationContext.bindService(
                        Intent(
                                activityBinding.activity.applicationContext,
                                BelnetDaemon::class.java
                        ),
                        mConnection,
                        Context.BIND_AUTO_CREATE
                )
        ) {
            mShouldUnbind = true
        } else {
            Log.e(
                    BelnetDaemon.LOG_TAG,
                    "Error: The requested service doesn't exist, or this client isn't allowed access to it."
            )
        }
    }

    fun doUnbindService() {
        if (mShouldUnbind) {
            activityBinding.activity.applicationContext.unbindService(mConnection)
            mShouldUnbind = false
        }
    }


    fun logDataToFrontend(sampleData : String):String{
     logData = sampleData
     Log.d("backtracking",logData)
      return logData
}

//    fun disConnectButtonCall(){
//        Log.e("call","this disconnectButtonCall")
//        var intent = VpnService.prepare(activityBinding.activity.applicationContext)
//        if (intent != null) {
//            // Not prepared yet
//            //result.success(false)
//           // return
//        }
//        val belnetIntent =
//            Intent(
//                activityBinding.activity.applicationContext,
//                BelnetDaemon::class.java
//            )
//        belnetIntent.action = BelnetDaemon.ACTION_DISCONNECT

//        activityBinding.activity.applicationContext.startService(belnetIntent)

//        doBindService()
//    }


}


