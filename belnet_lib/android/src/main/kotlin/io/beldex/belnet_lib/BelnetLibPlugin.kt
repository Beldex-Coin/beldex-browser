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
        // Audio phone call
        registerCallAndAudioReceivers()
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        mMethodChannel.setMethodCallHandler(null)
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
            Log.d("CallState", "📶 VoIP or Internet call in progress")
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
