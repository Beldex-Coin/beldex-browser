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
import kotlin.math.roundToLong

import android.content.ServiceConnection

import android.view.WindowManager
import android.app.Activity
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

    private var mIsConnectedObserver = Observer<Boolean> { newIsConnected ->
        mEventSink?.success(newIsConnected)
    }

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        System.loadLibrary("belnet-android")

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

                val belnetIntent = Intent(activityBinding.activity.applicationContext, BelnetDaemon::class.java)
                belnetIntent.action = BelnetDaemon.ACTION_CONNECT
                belnetIntent.putExtra(BelnetDaemon.EXIT_NODE, exitNode)
                belnetIntent.putExtra(BelnetDaemon.UPSTREAM_DNS, upstreamDNS)

                activityBinding.activity.applicationContext.startService(belnetIntent)
                doBindService()
                result.success(true)
            }

            "disconnect" -> {
                val intent = VpnService.prepare(activityBinding.activity.applicationContext)
                if (intent != null) {
                    result.success(false)
                    return
                }

                val belnetIntent = Intent(activityBinding.activity.applicationContext, BelnetDaemon::class.java)
                belnetIntent.action = BelnetDaemon.ACTION_DISCONNECT

                activityBinding.activity.applicationContext.startService(belnetIntent)
                doUnbindService()
                Log.d("Test", "inside disconnect function")
                result.success(true)
            }

            "isRunning" -> {
                result.success(mBoundService?.IsRunning() ?: false)
            }

            "getStatus" -> {
                result.success(mBoundService?.DumpStatus() ?: false)
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
                result.success(false)
            }

            "getMap" -> {
                val swapNode = call.argument<String>("swap_node")
                Log.d("Test", "Swap Node from un map")
                result.success(mBoundService?.unmappingNode(swapNode) ?: false)
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

            else -> result.notImplemented()
        }
    }

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
