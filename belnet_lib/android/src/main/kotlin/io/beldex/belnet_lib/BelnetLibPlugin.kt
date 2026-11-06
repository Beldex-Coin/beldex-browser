
package io.beldex.belnet_lib

import android.annotation.SuppressLint
import android.app.Activity
import android.app.Activity.RESULT_OK
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.ClipData
import android.content.ComponentName
import android.content.ContentUris
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.ServiceConnection
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Matrix
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.ExifInterface
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.TrafficStats
import android.net.Uri
import android.net.VpnService
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.SystemClock
import android.provider.MediaStore
import android.provider.Settings
import android.telephony.TelephonyManager
import android.text.Html
import android.util.Base64
import android.util.Log
import android.util.Xml
import android.view.WindowManager
import android.widget.Toast

import androidx.annotation.NonNull
import androidx.core.content.ContextCompat
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
import io.flutter.plugin.common.PluginRegistry

import network.beldex.belnet.BelnetDaemon
import network.beldex.belnet.ConnectionTools

import org.json.JSONObject
import org.xmlpull.v1.XmlPullParser

import com.tom_roush.pdfbox.android.PDFBoxResourceLoader
import com.tom_roush.pdfbox.io.MemoryUsageSetting
import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.pdmodel.encryption.InvalidPasswordException
import com.tom_roush.pdfbox.text.PDFTextStripper

import java.io.File
import java.io.FileOutputStream
import java.io.FilterInputStream
import java.io.IOException
import java.io.InputStream
import java.nio.ByteBuffer
import java.nio.charset.CharacterCodingException
import java.nio.charset.CodingErrorAction
import java.util.zip.ZipFile

import kotlin.math.roundToLong


/** BelnetLibPlugin */
open class BelnetLibPlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler,
    ActivityAware {

    // ============================================================
    // CONSTANTS
    // ============================================================

    companion object {

        private const val PHOTO_PICKER_REQUEST_CODE = 5001
        private const val FILE_PICKER_REQUEST_CODE = 5002

        private const val MAX_ATTACHMENTS = 10

        // --------------------------------------------------------
        // FILE SIZE LIMITS
        // --------------------------------------------------------

        // Image = 5 MB
        private const val MAX_IMAGE_SIZE =
            5L * 1024L * 1024L

        // TXT / CSV = 5 MB
        private const val MAX_TEXT_SIZE =
            5L * 1024L * 1024L

        // PDF / DOC / DOCX = 10 MB
        private const val MAX_DOCUMENT_SIZE =
            10L * 1024L * 1024L

        // XLS / XLSX = 10 MB
        private const val MAX_SPREADSHEET_SIZE =
            10L * 1024L * 1024L

        /*
         * Fallback for an unknown extension.
         *
         * Since your picker currently allows all files,
         * keep a 10 MB safety limit for unknown files.
         */
        private const val MAX_UNKNOWN_FILE_SIZE =
            10L * 1024L * 1024L

        // --------------------------------------------------------
        // IMAGE SANITISING
        // --------------------------------------------------------

        /*
         * Every image attachment is decoded and re-encoded before
         * it can be sent, so EXIF / XMP / IPTC metadata (GPS,
         * device make/model, capture time, thumbnails) is dropped.
         *
         * Files with this prefix are the only images the Dart side
         * will upload (see OpenAIRepository._isSendableAttachment).
         */
        const val CLEAN_IMAGE_PREFIX = "chatimg_"

        // Longest side of a cleaned image, in pixels.
        private const val MAX_IMAGE_DIMENSION = 2048

        private const val CLEAN_JPEG_QUALITY = 90

        private val IMAGE_EXTENSIONS =
            setOf("jpg", "jpeg", "png", "webp", "gif", "bmp", "heic", "heif")

        // --------------------------------------------------------
        // AI TEMPORARY FILES
        // --------------------------------------------------------

        // Read-aloud WAVs: "beldex_ai_<millis>.wav".
        private val TTS_FILE_REGEX =
            Regex("^beldex_ai_\\d+\\.wav$")

        /*
         * Files in cacheDir that belong to the AI chat and may be
         * deleted on chat reset / app start.
         */
        private val AI_CACHE_FILE_PATTERNS = listOf(
            // Attachment copies (documents) from the pickers.
            Regex("^chat_\\d+_\\d+_.*"),
            // Metadata-stripped images.
            Regex("^${CLEAN_IMAGE_PREFIX}.*"),
            // Per-document text files sent to the AI.
            Regex("^chatdoc_\\d+_\\d+\\.txt$"),
            // Read-aloud audio copied into the cache.
            TTS_FILE_REGEX,
            // Generated images written for the share sheet.
            Regex("^beldex_ai_image_\\d+\\.png$"),
            // image_picker camera captures: <uuid><digits>.jpg and
            // the resized "scaled_" copy.
            Regex(
                "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-" +
                        "[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\\d*\\.(jpg|jpeg|png)$"
            ),
            Regex("^scaled_.*\\.(jpg|jpeg|png)$")
        )

        // --------------------------------------------------------
        // DOCUMENT TEXT EXTRACTION
        // --------------------------------------------------------

        // Default and hard upper limit for extracted characters.
        private const val DEFAULT_EXTRACT_MAX_CHARS = 60_000
        private const val MAX_EXTRACT_CHARS = 1_000_000

        // Max bytes read from one entry inside a docx/xlsx/pptx.
        private const val MAX_ZIP_ENTRY_BYTES = 50L * 1024L * 1024L

        // PdfBox keeps up to this much in memory, the rest in a
        // temp file in the cache dir (deleted when closed).
        private const val PDF_MAX_MAIN_MEMORY_BYTES = 16L * 1024L * 1024L

        // Ignore cell references beyond column XFD.
        private const val MAX_XLSX_COLUMNS = 16_384
    }


    // ============================================================
    // ATTACHMENT PICKER STATE
    // ============================================================

    private var attachmentPickerResult: MethodChannel.Result? = null

    private var attachmentPickerType: String? = null

    private var attachmentPickerMax =
        MAX_ATTACHMENTS


    // ============================================================
    // BELNET STATE
    // ============================================================

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

    var mutableString: MutableLiveData<String> =
        MutableLiveData()


    // ============================================================
    // FLUTTER CHANNELS
    // ============================================================

    private lateinit var mMethodChannel: MethodChannel

    private lateinit var mIsConnectedEventChannel: EventChannel

    private var mEventSink: EventChannel.EventSink? = null


    // Network change channel

    private lateinit var networkChangeEventChannel: EventChannel

    private var networkChangeEventSink:
            EventChannel.EventSink? = null

    private var networkChangeReceiver:
            BroadcastReceiver? = null


    // Status channel

    private lateinit var statusEventChannel: EventChannel

    private var statusEventSink:
            EventChannel.EventSink? = null

    private var statusHandler: Handler? = null

    private var statusRunnable: Runnable? = null

    private val speedMeter =
        SpeedMeter()


    // Notification disconnect channel

    private lateinit var notificationDisconnectEventChannel

        : EventChannel

    private lateinit var notificationDisconnectReceiver:
            BroadcastReceiver

    private var disconnectEventSink:
            EventChannel.EventSink? = null


    // ============================================================
    // AUDIO
    // ============================================================

    private var focusRequest:
            AudioFocusRequest? = null

    private var audioFocusChangeListener:
            AudioManager.OnAudioFocusChangeListener? = null

    private lateinit var context: Context

    private lateinit var messenger:
            io.flutter.plugin.common.BinaryMessenger


    // ============================================================
    // CONNECTION OBSERVER
    // ============================================================

    private var mIsConnectedObserver =
        Observer<Boolean> { newIsConnected ->

            mEventSink?.success(
                newIsConnected
            )
        }


    // ============================================================
    // PHONE / AUDIO RECEIVER
    // ============================================================

    private val callReceiver =
        object : BroadcastReceiver() {

            override fun onReceive(
                context: Context?,
                intent: Intent?
            ) {

                when (intent?.action) {

                    AudioManager.ACTION_SCO_AUDIO_STATE_UPDATED -> {

                        val state =
                            intent.getIntExtra(
                                AudioManager.EXTRA_SCO_AUDIO_STATE,
                                -1
                            )

                        if (
                            state ==
                            AudioManager.SCO_AUDIO_STATE_CONNECTED ||

                            state ==
                            AudioManager.SCO_AUDIO_STATE_CONNECTING
                        ) {

                            Log.d(
                                "CallState",
                                "SCO audio active — stopping TTS."
                            )

                            sendFocusEventToFlutter(
                                "focusLost"
                            )
                        }
                    }


                    AudioManager.ACTION_AUDIO_BECOMING_NOISY -> {

                        Log.d(
                            "CallState",
                            "Headphones unplugged / route changed."
                        )
                    }


                    TelephonyManager.ACTION_PHONE_STATE_CHANGED -> {

                        val state =
                            intent.getStringExtra(
                                TelephonyManager.EXTRA_STATE
                            )

                        if (
                            state ==
                            TelephonyManager.EXTRA_STATE_RINGING ||

                            state ==
                            TelephonyManager.EXTRA_STATE_OFFHOOK
                        ) {

                            Log.d(
                                "CallState",
                                "Incoming or ongoing phone call — stop TTS."
                            )

                            sendFocusEventToFlutter(
                                "focusLost"
                            )
                        }
                    }
                }
            }
        }


    // ============================================================
    // FLUTTER ENGINE ATTACHED
    // ============================================================

    override fun onAttachedToEngine(
        @NonNull binding:
        FlutterPlugin.FlutterPluginBinding
    ) {

        System.loadLibrary(
            "belnet-android"
        )

        context =
            binding.applicationContext

        messenger =
            binding.binaryMessenger


        // --------------------------------------------------------
        // Method channel
        // --------------------------------------------------------

        mMethodChannel =
            MethodChannel(
                binding.binaryMessenger,
                "belnet_lib_method_channel"
            )

        mMethodChannel.setMethodCallHandler(
            this
        )


        // --------------------------------------------------------
        // Connection event channel
        // --------------------------------------------------------

        mIsConnectedEventChannel =
            EventChannel(
                binding.binaryMessenger,
                "belnet_lib_is_connected_event_channel"
            )

        mIsConnectedEventChannel.setStreamHandler(
            object : EventChannel.StreamHandler {

                override fun onListen(
                    arguments: Any?,
                    events: EventChannel.EventSink?
                ) {

                    mEventSink =
                        events
                }

                override fun onCancel(
                    arguments: Any?
                ) {

                    mEventSink?.endOfStream()

                    mEventSink = null
                }
            }
        )


        // --------------------------------------------------------
        // Notification disconnect
        // --------------------------------------------------------

        notificationDisconnectEventChannel =
            EventChannel(
                binding.binaryMessenger,
                "belnet_lib_notification_disconnect_event_channel"
            )

        notificationDisconnectEventChannel.setStreamHandler(
            object : EventChannel.StreamHandler {

                override fun onListen(
                    arguments: Any?,
                    events: EventChannel.EventSink?
                ) {

                    disconnectEventSink =
                        events

                    notificationDisconnectReceiver =
                        object : BroadcastReceiver() {

                            override fun onReceive(
                                context: Context?,
                                intent: Intent?
                            ) {

                                if (
                                    intent?.action ==
                                    "com.belnet.NOTIFICATION_DISCONNECTED"
                                ) {

                                    Log.d(
                                        "BelnetLibPlugin",
                                        "Received notification disconnect broadcast"
                                    )

                                    disconnectEventSink?.success(
                                        "notification_disconnect"
                                    )
                                }
                            }
                        }

                    val filter =
                        IntentFilter(
                            "com.belnet.NOTIFICATION_DISCONNECTED"
                        )

                    ContextCompat.registerReceiver(
                        context,
                        notificationDisconnectReceiver,
                        filter,
                        ContextCompat.RECEIVER_NOT_EXPORTED
                    )
                }


                override fun onCancel(
                    arguments: Any?
                ) {

                    disconnectEventSink = null

                    try {

                        notificationDisconnectReceiver.let {

                            context.unregisterReceiver(
                                it
                            )
                        }

                    } catch (e: Exception) {

                        Log.e(
                            "BelnetLibPlugin",
                            "Receiver already unregistered: ${e.message}"
                        )
                    }
                }
            }
        )


        // --------------------------------------------------------
        // Network change channel
        // --------------------------------------------------------

        networkChangeEventChannel =
            EventChannel(
                binding.binaryMessenger,
                "belnet_lib_network_change_event_channel"
            )

        networkChangeEventChannel.setStreamHandler(
            object : EventChannel.StreamHandler {

                override fun onListen(
                    arguments: Any?,
                    events: EventChannel.EventSink?
                ) {

                    networkChangeEventSink =
                        events

                    networkChangeReceiver =
                        object : BroadcastReceiver() {

                            override fun onReceive(
                                ctx: Context?,
                                intent: Intent?
                            ) {

                                if (
                                    intent?.action ==
                                    BelnetDaemon.ACTION_NETWORK_CHANGED
                                ) {

                                    Log.d(
                                        "BelnetLibPlugin",
                                        "Received network change broadcast"
                                    )

                                    networkChangeEventSink?.success(
                                        "network_changed"
                                    )
                                }
                            }
                        }

                    val filter =
                        IntentFilter(
                            BelnetDaemon.ACTION_NETWORK_CHANGED
                        )

                    ContextCompat.registerReceiver(
                        context,
                        networkChangeReceiver,
                        filter,
                        ContextCompat.RECEIVER_NOT_EXPORTED
                    )
                }


                override fun onCancel(
                    arguments: Any?
                ) {

                    networkChangeEventSink = null

                    try {

                        networkChangeReceiver?.let {

                            context.unregisterReceiver(
                                it
                            )
                        }

                    } catch (e: Exception) {

                        Log.e(
                            "BelnetLibPlugin",
                            "Network receiver already unregistered: ${e.message}"
                        )
                    }

                    networkChangeReceiver = null
                }
            }
        )


        // --------------------------------------------------------
        // Status channel
        // --------------------------------------------------------

        statusEventChannel =
            EventChannel(
                binding.binaryMessenger,
                "belnet_lib_status_event_channel"
            )

        statusEventChannel.setStreamHandler(
            object : EventChannel.StreamHandler {

                override fun onListen(
                    arguments: Any?,
                    events: EventChannel.EventSink?
                ) {

                    statusEventSink =
                        events

                    statusHandler =
                        Handler(
                            Looper.getMainLooper()
                        )

                    statusRunnable =
                        object : Runnable {

                            override fun run() {

                                emitStatus()

                                statusHandler?.postDelayed(
                                    this,
                                    1000
                                )
                            }
                        }

                    statusHandler?.post(
                        statusRunnable!!
                    )
                }


                override fun onCancel(
                    arguments: Any?
                ) {

                    statusRunnable?.let {

                        statusHandler?.removeCallbacks(
                            it
                        )
                    }

                    statusRunnable = null

                    statusHandler = null

                    statusEventSink = null
                }
            }
        )


        // --------------------------------------------------------
        // Audio / phone call receivers
        // --------------------------------------------------------

        registerCallAndAudioReceivers()
    }


    // ============================================================
    // STATUS
    // ============================================================

    private fun emitStatus() {

        val sink =
            statusEventSink
                ?: return

        val speeds =
            speedMeter.sample()

        val payload =
            JSONObject()

        try {

            val raw =
                mBoundService?.getStatusSafe()

            payload.put(
                "status",
                if (raw.isNullOrEmpty())
                    JSONObject.NULL
                else
                    JSONObject(raw)
            )

        } catch (e: Exception) {

            payload.put(
                "status",
                JSONObject.NULL
            )
        }

        payload.put(
            "upload",
            speeds.first
        )

        payload.put(
            "download",
            speeds.second
        )

        payload.put(
            "isRunning",
            mBoundService?.IsRunning()
                ?: false
        )

        sink.success(
            payload.toString()
        )
    }


    // ============================================================
    // SPEED METER
    // ============================================================

    private class SpeedMeter {

        private var lastTimestamp = 0L

        private var lastRx = 0L

        private var lastTx = 0L


        fun sample():
                Pair<Long, Long> {

            val now =
                SystemClock.elapsedRealtime()

            val rx =
                TrafficStats.getTotalRxBytes()

            val tx =
                TrafficStats.getTotalTxBytes()


            if (lastTimestamp == 0L) {

                lastTimestamp = now

                lastRx = rx

                lastTx = tx

                return Pair(
                    0L,
                    0L
                )
            }


            val dt =
                (now - lastTimestamp) /
                        1000f


            if (dt <= 0f) {

                return Pair(
                    0L,
                    0L
                )
            }


            val up =
                (
                    (
                        (tx - lastTx)
                            .coerceAtLeast(0)
                            / 2
                    ) / dt
                ).roundToLong()


            val down =
                (
                    (
                        (rx - lastRx)
                            .coerceAtLeast(0)
                            / 2
                    ) / dt
                ).roundToLong()


            lastTimestamp = now

            lastRx = rx

            lastTx = tx


            return Pair(
                up,
                down
            )
        }
    }


    // ============================================================
    // ENGINE DETACHED
    // ============================================================

    override fun onDetachedFromEngine(
        @NonNull binding:
        FlutterPlugin.FlutterPluginBinding
    ) {

        mMethodChannel.setMethodCallHandler(
            null
        )


        statusRunnable?.let {

            statusHandler?.removeCallbacks(
                it
            )
        }

        statusRunnable = null

        statusHandler = null

        statusEventSink = null


        try {

            networkChangeReceiver?.let {

                context.unregisterReceiver(
                    it
                )
            }

            notificationDisconnectReceiver.let {

                context.unregisterReceiver(
                    it
                )
            }

        } catch (e: Exception) {

            Log.w(
                "BelnetLibPlugin",
                "Receiver already unregistered: ${e.message}"
            )
        }


        networkChangeReceiver = null

        networkChangeEventSink = null


        doUnbindService()

        unregisterReceivers()
    }


    // ============================================================
    // CALL / AUDIO RECEIVERS
    // ============================================================

    private fun registerCallAndAudioReceivers() {

        val filter =
            IntentFilter().apply {

                addAction(
                    AudioManager.ACTION_SCO_AUDIO_STATE_UPDATED
                )

                addAction(
                    TelephonyManager.ACTION_PHONE_STATE_CHANGED
                )
            }

        context.registerReceiver(
            callReceiver,
            filter
        )
    }


    private fun unregisterReceivers() {

        try {

            context.unregisterReceiver(
                callReceiver
            )

        } catch (e: Exception) {

            Log.w(
                "BelnetLibPlugin",
                "Receiver already unregistered or not initialized."
            )
        }
    }


    // ============================================================
    // ATTACHMENT ACTIVITY RESULT
    // ============================================================

    private val attachmentActivityResultListener =
        PluginRegistry.ActivityResultListener {

                requestCode,
                resultCode,
                data ->

            if (
                requestCode !=
                PHOTO_PICKER_REQUEST_CODE &&

                requestCode !=
                FILE_PICKER_REQUEST_CODE
            ) {

                return@ActivityResultListener false
            }


            handleAttachmentResult(
                requestCode,
                resultCode,
                data
            )


            true
        }


    // ============================================================
    // METHOD CALL
    // ============================================================

    @SuppressLint("NewApi")
    override fun onMethodCall(
        @NonNull call: MethodCall,
        @NonNull result: MethodChannel.Result
    ) {

        when (call.method) {

            // ====================================================
            // VPN PREPARE
            // ====================================================

            "prepare" -> {

                val intent =
                    VpnService.prepare(
                        activityBinding.activity
                            .applicationContext
                    )

                if (intent != null) {

                    var listener:
                            PluginRegistry.ActivityResultListener? =
                        null

                    listener =
                        PluginRegistry.ActivityResultListener {

                                req,
                                res,
                                _ ->

                            if (
                                req == 0 &&
                                res == RESULT_OK
                            ) {

                                result.success(
                                    true
                                )

                            } else {

                                result.success(
                                    false
                                )
                            }


                            listener?.let {

                                activityBinding
                                    .removeActivityResultListener(
                                        it
                                    )
                            }

                            true
                        }


                    activityBinding.addActivityResultListener(
                        listener
                    )


                    activityBinding.activity
                        .startActivityForResult(
                            intent,
                            0
                        )

                } else {

                    result.success(
                        true
                    )
                }
            }


            // ====================================================
            // IS PREPARED
            // ====================================================

            "isPrepared" -> {

                val intent =
                    VpnService.prepare(
                        activityBinding.activity
                            .applicationContext
                    )

                result.success(
                    intent == null
                )
            }


            // ====================================================
            // CONNECT
            // ====================================================

            "connect" -> {

                val intent =
                    VpnService.prepare(
                        activityBinding.activity
                            .applicationContext
                    )

                if (intent != null) {

                    result.success(
                        false
                    )

                    return
                }


                val exitNode =
                    call.argument<String>(
                        "exit_node"
                    )

                val upstreamDNS =
                    call.argument<String>(
                        "upstream_dns"
                    )

                val logLevel =
                    call.argument<String>(
                        "log_level"
                    )

                val mtu =
                    call.argument<Int>(
                        "mtu"
                    )

                val routeIpv6 =
                    call.argument<Boolean>(
                        "route_ipv6"
                    )


                val belnetIntent =
                    Intent(
                        activityBinding.activity
                            .applicationContext,
                        BelnetDaemon::class.java
                    )


                belnetIntent.action =
                    BelnetDaemon.ACTION_CONNECT


                belnetIntent.putExtra(
                    BelnetDaemon.EXIT_NODE,
                    exitNode
                )


                belnetIntent.putExtra(
                    BelnetDaemon.UPSTREAM_DNS,
                    upstreamDNS
                )


                belnetIntent.putExtra(
                    BelnetDaemon.LOG_LEVEL,
                    logLevel ?: "warn"
                )


                belnetIntent.putExtra(
                    BelnetDaemon.MTU,
                    mtu ?: 1400
                )


                belnetIntent.putExtra(
                    BelnetDaemon.ROUTE_IPV6,
                    routeIpv6 ?: true
                )


                activityBinding.activity
                    .applicationContext
                    .startService(
                        belnetIntent
                    )


                doBindService()


                result.success(
                    true
                )
            }


            // ====================================================
            // DISCONNECT
            // ====================================================

            "disconnect" -> {

                val ctx =
                    activityBinding.activity
                        .applicationContext


                val belnetIntent =
                    Intent(
                        ctx,
                        BelnetDaemon::class.java
                    ).apply {

                        action =
                            BelnetDaemon.ACTION_DISCONNECT
                    }


                ctx.startService(
                    belnetIntent
                )


                doBindService()


                Log.d(
                    "BelnetLibPlugin",
                    "Disconnect called"
                )


                result.success(
                    true
                )
            }


            // ====================================================
            // IS RUNNING
            // ====================================================

            "isRunning" -> {

                result.success(
                    mBoundService?.IsRunning()
                        ?: false
                )
            }


            // ====================================================
            // GET STATUS
            // ====================================================

            "getStatus" -> {

                result.success(
                    mBoundService?.DumpStatus()
                )
            }


            // ====================================================
            // UPLOAD SPEED
            // ====================================================

            "getUploadSpeed" -> {

                val timestamp =
                    SystemClock.elapsedRealtime()

                val elapsedMillis =
                    timestamp -
                            lastTimestamp

                val elapsedSeconds =
                    elapsedMillis /
                            1000f

                val totalUpload =
                    TrafficStats
                        .getTotalTxBytes()

                val uploaded =
                    (
                        totalUpload -
                                lastTotalUpload
                    )
                        .coerceAtLeast(0) / 2

                val uploadSpeed =
                    if (elapsedSeconds > 0) {

                        (
                            uploaded /
                                    elapsedSeconds
                        ).roundToLong()

                    } else {

                        0L
                    }


                sessionUploaded +=
                    uploaded


                val uploadString =
                    ConnectionTools.bytesToSize(
                        uploadSpeed
                    ) + "ps"


                result.success(
                    uploadString
                )


                lastTotalUpload =
                    totalUpload

                lastTimestamp =
                    timestamp
            }


            // ====================================================
            // DOWNLOAD SPEED
            // ====================================================

            "getDownloadSpeed" -> {

                val timestamp =
                    SystemClock.elapsedRealtime()

                val elapsedMillis =
                    timestamp -
                            lastTimestamp

                val elapsedSeconds =
                    elapsedMillis /
                            1000f

                val totalDownload =
                    TrafficStats
                        .getTotalRxBytes()

                val totalUpload =
                    TrafficStats
                        .getTotalTxBytes()


                val downloaded =
                    (
                        totalDownload -
                                lastTotalDownload
                    )
                        .coerceAtLeast(0) / 2


                val uploaded =
                    (
                        totalUpload -
                                lastTotalUpload
                    )
                        .coerceAtLeast(0) / 2


                val downloadSpeed =
                    if (elapsedSeconds > 0) {

                        (
                            downloaded /
                                    elapsedSeconds
                        ).roundToLong()

                    } else {

                        0L
                    }


                val uploadSpeed =
                    if (elapsedSeconds > 0) {

                        (
                            uploaded /
                                    elapsedSeconds
                        ).roundToLong()

                    } else {

                        0L
                    }


                sessionDownloaded +=
                    downloaded

                sessionUploaded +=
                    uploaded


                val downloadString =
                    ConnectionTools.bytesToSize(
                        downloadSpeed
                    ) + "ps"


                Log.d(
                    "TagDownload",
                    "This is downloadString $downloadString"
                )


                result.success(
                    downloadString
                )


                lastTotalDownload =
                    totalDownload

                lastTotalUpload =
                    totalUpload

                lastTimestamp =
                    timestamp
            }


            // ====================================================
            // GET DATA STATUS
            // ====================================================

            "getDataStatus" -> {

                val service =
                    mBoundService


                if (service == null) {

                    Log.w(
                        "BelnetLibPlugin",
                        "getDataStatus: Service not bound yet"
                    )

                    result.success(
                        null
                    )

                    return
                }


                try {

                    result.success(
                        service.getStatusSafe()
                    )

                } catch (e: Exception) {

                    Log.e(
                        "BelnetLibPlugin",
                        "Exception in getDataStatus",
                        e
                    )

                    result.success(
                        null
                    )
                }
            }


            // ====================================================
            // GET MAP
            // ====================================================

            "getMap" -> {

                val swapNode =
                    call.argument<String>(
                        "swap_node"
                    )

                val service =
                    mBoundService


                if (
                    service == null ||
                    swapNode == null
                ) {

                    Log.w(
                        "BelnetLibPlugin",
                        "getMap: service not bound or no swap_node"
                    )

                    result.success(
                        null
                    )

                } else {

                    var replied =
                        false


                    service.unmappingNode(
                        swapNode
                    ) { r ->

                        if (!replied) {

                            replied = true

                            result.success(
                                r
                            )
                        }
                    }
                }
            }


            // ====================================================
            // EXIT READY
            // ====================================================

            "isExitReady" -> {

                result.success(
                    mBoundService?.isExitReady()
                        ?: false
                )
            }


            // ====================================================
            // UNMAP STATUS
            // ====================================================

            "getUnmapStatus" -> {

                result.success(
                    mBoundService?.Status()
                        ?: false
                )
            }


            // ====================================================
            // DEFAULT BROWSER
            // ====================================================

            "setDefaultBrowser" -> {

                val intent =
                    Intent(
                        Settings
                            .ACTION_MANAGE_DEFAULT_APPS_SETTINGS
                    )


                activityBinding.activity
                    .startActivityForResult(
                        intent,
                        0
                    )


                result.success(
                    true
                )
            }


            // ====================================================
            // NOTIFICATION DISCONNECT
            // ====================================================

            "disconnectForNotification" -> {

                result.success(
                    mBoundService != null
                )
            }


            // ====================================================
            // SECURE SCREEN
            // ====================================================

            "enableSecure" -> {

                try {

                    activityBinding.activity.window.setFlags(
                        WindowManager.LayoutParams.FLAG_SECURE,
                        WindowManager.LayoutParams.FLAG_SECURE
                    )

                    result.success(
                        true
                    )

                } catch (e: Exception) {

                    result.error(
                        "SCREEN_SECURITY_ERROR",
                        "Failed to enable screen security",
                        e.message
                    )
                }
            }


            "disableSecure" -> {

                try {

                    activityBinding.activity.window.clearFlags(
                        WindowManager.LayoutParams.FLAG_SECURE
                    )

                    result.success(
                        true
                    )

                } catch (e: Exception) {

                    result.error(
                        "SCREEN_SECURITY_ERROR",
                        "Failed to disable screen security",
                        e.message
                    )
                }
            }


            // ====================================================
            // AUDIO FOCUS
            // ====================================================

            "requestAudioFocus" -> {

                requestAudioFocus()

                result.success(
                    true
                )
            }


            "abandonAudioFocus" -> {

                abandonAudioFocus()

                result.success(
                    true
                )
            }


            "isCallActive" -> {

                result.success(
                    isCallActive()
                )
            }


            // ====================================================
            // PICK MULTIPLE IMAGES
            // ====================================================

            "pickMultipleImages" -> {

                if (
                    attachmentPickerResult != null
                ) {

                    result.error(
                        "PICKER_ALREADY_OPEN",
                        "An attachment picker is already open.",
                        null
                    )

                    return
                }


                val requestedMax =
                    call.argument<Int>(
                        "maxImages"
                    )
                        ?: MAX_ATTACHMENTS


                attachmentPickerMax =
                    requestedMax.coerceIn(
                        1,
                        MAX_ATTACHMENTS
                    )


                attachmentPickerResult =
                    result


                attachmentPickerType =
                    "image"


                openImagePicker(
                    attachmentPickerMax
                )
            }


            // ====================================================
            // PICK MULTIPLE FILES
            // ====================================================

            "pickMultipleFiles" -> {

                if (
                    attachmentPickerResult != null
                ) {

                    result.error(
                        "PICKER_ALREADY_OPEN",
                        "An attachment picker is already open.",
                        null
                    )

                    return
                }


                val requestedMax =
                    call.argument<Int>(
                        "maxFiles"
                    )
                        ?: MAX_ATTACHMENTS


                attachmentPickerMax =
                    requestedMax.coerceIn(
                        1,
                        MAX_ATTACHMENTS
                    )


                attachmentPickerResult =
                    result


                attachmentPickerType =
                    "file"


                openFilePicker()
            }


            // ====================================================
            // IS THIS APP'S TRAFFIC ON A VPN RIGHT NOW?
            // ====================================================

            "isVpnTransportActive" -> {

                result.success(
                    isVpnTransportActive()
                )
            }


            // ====================================================
            // DELETE AI TEMPORARY FILES
            // ====================================================

            "purgeAiTempFiles" -> {

                val keepPaths =
                    call.argument<List<String>>("keepPaths")
                        ?.toSet()
                        ?: emptySet()

                Thread {

                    val deleted =
                        purgeAiTempFiles(keepPaths)

                    Handler(Looper.getMainLooper()).post {
                        result.success(deleted)
                    }

                }.start()
            }


            // ====================================================
            // DELETE READ-ALOUD COPIES IN SHARED STORAGE
            // ====================================================

            "deleteTtsSharedCopies" -> {

                Thread {

                    val deleted =
                        deleteTtsSharedCopies()

                    Handler(Looper.getMainLooper()).post {
                        result.success(deleted)
                    }

                }.start()
            }


            // ====================================================
            // EXTRACT TEXT FROM A DOCUMENT (on device)
            // ====================================================

            "extractDocumentText" -> {

                val path =
                    call.argument<String>("path")

                val maxChars =
                    (call.argument<Int>("maxChars") ?: DEFAULT_EXTRACT_MAX_CHARS)
                        .coerceIn(1, MAX_EXTRACT_CHARS)

                if (path.isNullOrBlank()) {
                    result.error(
                        "INVALID_PATH",
                        "No document path given.",
                        null
                    )
                    return
                }

                val source = File(path)

                // Only attachment copies in this app's cache.
                val insideCache =
                    try {
                        source.canonicalPath.startsWith(
                            context.cacheDir.canonicalPath + File.separator
                        )
                    } catch (e: Exception) {
                        false
                    }

                if (!insideCache || !source.isFile) {
                    result.error(
                        "INVALID_PATH",
                        "Document must be in the app cache.",
                        null
                    )
                    return
                }

                Thread {

                    var payload: Map<String, Any>? = null
                    var errorCode = "FAILED"
                    var errorMessage = "Document could not be read."

                    try {

                        payload =
                            extractDocumentText(source, maxChars)

                    } catch (e: ExtractionFailure) {

                        errorCode = e.code
                        errorMessage = e.message ?: errorMessage

                    } catch (t: Throwable) {

                        // Includes OutOfMemoryError. Never log the
                        // document's name or contents.
                        Log.e("BelnetLibPlugin", "Document text extraction failed", t)
                    }

                    val done = payload
                    val code = errorCode
                    val message = errorMessage

                    Handler(Looper.getMainLooper()).post {
                        if (done != null) {
                            result.success(done)
                        } else {
                            result.error(code, message, null)
                        }
                    }

                }.start()
            }


            // ====================================================
            // SANITISE A SINGLE IMAGE (camera captures)
            // ====================================================

            "sanitizeImageFile" -> {

                val path =
                    call.argument<String>("path")

                if (path.isNullOrBlank()) {
                    result.error(
                        "INVALID_PATH",
                        "No image path given.",
                        null
                    )
                    return
                }

                val source = File(path)

                /*
                 * Only accept files inside this app's cache
                 * directory (where image_picker writes captures).
                 */
                val insideCache =
                    try {
                        source.canonicalPath.startsWith(
                            context.cacheDir.canonicalPath + File.separator
                        )
                    } catch (e: Exception) {
                        false
                    }

                if (!insideCache || !source.isFile) {
                    result.error(
                        "INVALID_PATH",
                        "Image must be in the app cache.",
                        null
                    )
                    return
                }

                Thread {

                    val cleaned =
                        sanitizeImage(source, 0, "camera")

                    // The capture still carries EXIF (incl. GPS).
                    source.delete()

                    Handler(Looper.getMainLooper()).post {
                        if (cleaned != null) {
                            result.success(cleaned.absolutePath)
                        } else {
                            result.error(
                                "IMAGE_CLEAN_FAILED",
                                "Image metadata could not be removed.",
                                null
                            )
                        }
                    }

                }.start()
            }


            // ====================================================
            // SAVE IMAGE TO GALLERY
            // ====================================================

            "saveImageToGallery" -> {

                try {

                    val base64Image =
                        call.argument<String>(
                            "base64Image"
                        )


                    val fileName =
                        call.argument<String>(
                            "fileName"
                        )
                            ?: "AI_Image_${System.currentTimeMillis()}.png"


                    if (
                        base64Image.isNullOrEmpty()
                    ) {

                        result.error(
                            "INVALID_IMAGE",
                            "Base64 image is empty",
                            null
                        )

                        return
                    }


                    val cleanBase64 =
                        if (
                            base64Image.contains(",")
                        ) {

                            base64Image
                                .substringAfter(",")

                        } else {

                            base64Image
                        }


                    val imageBytes =
                        Base64.decode(
                            cleanBase64,
                            Base64.DEFAULT
                        )


                    val savedUri =
                        saveImageToGallery(
                            imageBytes,
                            fileName
                        )


                    if (
                        savedUri != null
                    ) {

                        result.success(
                            mapOf(
                                "success" to true,
                                "uri" to savedUri,
                                "fileName" to fileName
                            )
                        )

                    } else {

                        result.error(
                            "SAVE_FAILED",
                            "Unable to save image to Gallery",
                            null
                        )
                    }

                } catch (e: Exception) {

                    Log.e(
                        "BelnetLibPlugin",
                        "saveImageToGallery error",
                        e
                    )

                    result.error(
                        "SAVE_FAILED",
                        e.message,
                        null
                    )
                }
            }


            // ====================================================
            // TTS AUDIO
            // ====================================================

            "getTtsAudioPath" -> {

                val fileName =
                    call.argument<String>(
                        "fileName"
                    )


                if (
                    fileName.isNullOrBlank()
                ) {

                    result.error(
                        "INVALID_FILENAME",
                        "TTS filename is required",
                        null
                    )

                    return
                }


                val audioPath =
                    getTtsAudioPath(
                        fileName
                    )


                if (
                    audioPath != null
                ) {

                    result.success(
                        audioPath
                    )

                } else {

                    result.error(
                        "TTS_FILE_NOT_FOUND",
                        "Unable to find generated TTS audio: $fileName",
                        null
                    )
                }
            }


            // ====================================================
            // UNKNOWN
            // ====================================================

            else -> {

                result.notImplemented()
            }
        }
    }


    // ============================================================
    // AUDIO FOCUS
    // ============================================================

    private fun requestAudioFocus() {

        val audioManager =
            context.getSystemService(
                Context.AUDIO_SERVICE
            ) as AudioManager


        audioFocusChangeListener =
            AudioManager.OnAudioFocusChangeListener {

                focusChange ->

                when (focusChange) {

                    AudioManager.AUDIOFOCUS_LOSS -> {

                        Log.d(
                            "AudioFocus",
                            "Permanent loss. Stop TTS."
                        )

                        sendFocusEventToFlutter(
                            "focusLost"
                        )
                    }


                    AudioManager.AUDIOFOCUS_LOSS_TRANSIENT,

                    AudioManager
                        .AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> {

                        Log.d(
                            "AudioFocus",
                            "Transient loss."
                        )
                    }


                    AudioManager.AUDIOFOCUS_GAIN -> {

                        Log.d(
                            "AudioFocus",
                            "Focus regained."
                        )
                    }
                }
            }


        focusRequest =
            if (
                Build.VERSION.SDK_INT >=
                Build.VERSION_CODES.O
            ) {

                AudioFocusRequest.Builder(
                    AudioManager
                        .AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE
                )
                    .setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(
                                AudioAttributes.USAGE_ASSISTANT
                            )
                            .setContentType(
                                AudioAttributes.CONTENT_TYPE_SPEECH
                            )
                            .build()
                    )
                    .setOnAudioFocusChangeListener(
                        audioFocusChangeListener!!
                    )
                    .setWillPauseWhenDucked(
                        true
                    )
                    .build()

            } else {

                null
            }


        val requestResult =

            if (
                Build.VERSION.SDK_INT >=
                Build.VERSION_CODES.O &&
                focusRequest != null
            ) {

                audioManager.requestAudioFocus(
                    focusRequest!!
                )

            } else {

                @Suppress("DEPRECATION")

                audioManager.requestAudioFocus(
                    audioFocusChangeListener,
                    AudioManager.STREAM_MUSIC,
                    AudioManager.AUDIOFOCUS_GAIN_TRANSIENT
                )
            }


        if (
            requestResult ==
            AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        ) {

            Log.d(
                "AudioFocus",
                "Focus granted"
            )
        }
    }


    private fun abandonAudioFocus() {

        val audioManager =
            context.getSystemService(
                Context.AUDIO_SERVICE
            ) as AudioManager


        if (
            Build.VERSION.SDK_INT >=
            Build.VERSION_CODES.O &&
            focusRequest != null
        ) {

            audioManager.abandonAudioFocusRequest(
                focusRequest!!
            )

        } else {

            @Suppress("DEPRECATION")

            audioManager.abandonAudioFocus(
                audioFocusChangeListener
            )
        }
    }


    private fun sendFocusEventToFlutter(
        event: String
    ) {

        Handler(
            Looper.getMainLooper()
        ).post {

            MethodChannel(
                messenger,
                "belnet_lib_method_channel"
            ).invokeMethod(
                "focusLost",
                null
            )
        }
    }


    // ============================================================
    // CALL ACTIVE
    // ============================================================

    @SuppressLint("MissingPermission")
    private fun isCallActive(): Boolean {

        try {

            val telephonyManager =
                context.getSystemService(
                    Context.TELEPHONY_SERVICE
                ) as TelephonyManager


            val state =
                telephonyManager.callState


            if (
                state ==
                TelephonyManager.CALL_STATE_OFFHOOK ||

                state ==
                TelephonyManager.CALL_STATE_RINGING
            ) {

                Log.d(
                    "CallState",
                    "Regular phone call active or ringing"
                )

                return true
            }

        } catch (e: Exception) {

            Log.e(
                "CallState",
                "Error checking call state: ${e.message}"
            )
        }


        try {

            val audioManager =
                context.getSystemService(
                    Context.AUDIO_SERVICE
                ) as AudioManager


            val isVoipActive =
                audioManager.mode ==
                        AudioManager.MODE_IN_COMMUNICATION ||

                audioManager.mode ==
                        AudioManager.MODE_RINGTONE


            if (isVoipActive) {

                Log.d(
                    "CallState",
                    "VoIP or Internet call in progress"
                )

                return true
            }

        } catch (e: Exception) {

            Log.e(
                "CallState",
                "Error checking VoIP call state: ${e.message}"
            )
        }


        return false
    }


    // ============================================================
    // ACTIVITY ATTACHED
    // ============================================================

    override fun onAttachedToActivity(
        binding: ActivityPluginBinding
    ) {

        activityBinding =
            binding


        binding.addActivityResultListener(
            attachmentActivityResultListener
        )


        val hiddenLifecycle =
            binding.lifecycle as HiddenLifecycleReference


        lifecycleOwner =
            object : LifecycleOwner {

                override val lifecycle:
                        Lifecycle =
                    hiddenLifecycle.lifecycle
            }


        doBindService()
    }


    override fun onReattachedToActivityForConfigChanges(
        binding: ActivityPluginBinding
    ) {

        activityBinding =
            binding


        binding.addActivityResultListener(
            attachmentActivityResultListener
        )


        val hiddenLifecycle =
            binding.lifecycle as HiddenLifecycleReference


        lifecycleOwner =
            object : LifecycleOwner {

                override val lifecycle:
                        Lifecycle =
                    hiddenLifecycle.lifecycle
            }


        doBindService()
    }


    override fun onDetachedFromActivity() {

        try {

            activityBinding
                .removeActivityResultListener(
                    attachmentActivityResultListener
                )

        } catch (e: Exception) {

            Log.w(
                "BelnetLibPlugin",
                "Failed to remove attachment activity listener",
                e
            )
        }


        clearAttachmentPicker()
    }


    override fun onDetachedFromActivityForConfigChanges() {

        try {

            activityBinding
                .removeActivityResultListener(
                    attachmentActivityResultListener
                )

        } catch (e: Exception) {

            Log.w(
                "BelnetLibPlugin",
                "Failed to remove attachment activity listener",
                e
            )
        }


        clearAttachmentPicker()
    }


    // ============================================================
    // SERVICE CONNECTION
    // ============================================================

    private val mConnection:
            ServiceConnection =
        object : ServiceConnection {

            override fun onServiceConnected(
                className: ComponentName,
                service: IBinder
            ) {

                mBoundService =
                    (
                        service as
                                BelnetDaemon.LocalBinder
                    ).getService()


                mBoundService
                    ?.isConnected()
                    ?.observe(
                        lifecycleOwner,
                        mIsConnectedObserver
                    )
            }


            override fun onServiceDisconnected(
                className: ComponentName
            ) {

                mBoundService =
                    null
            }
        }


    fun doBindService() {

        if (
            activityBinding.activity
                .applicationContext
                .bindService(
                    Intent(
                        activityBinding.activity
                            .applicationContext,
                        BelnetDaemon::class.java
                    ),
                    mConnection,
                    Context.BIND_AUTO_CREATE
                )
        ) {

            mShouldUnbind =
                true

        } else {

            Log.e(
                BelnetDaemon.LOG_TAG,
                "Error: The requested service doesn't exist, " +
                        "or this client isn't allowed access to it."
            )
        }
    }


    fun doUnbindService() {

        if (mShouldUnbind) {

            try {

                activityBinding.activity
                    .applicationContext
                    .unbindService(
                        mConnection
                    )

            } catch (e: Exception) {

                Log.w(
                    "BelnetLibPlugin",
                    "Failed to unbind service: ${e.message}"
                )
            }


            mShouldUnbind =
                false
        }
    }


    // ============================================================
    // LOG
    // ============================================================

    fun logDataToFrontend(
        sampleData: String
    ): String {

        logData =
            sampleData

        Log.d(
            "backtracking",
            logData
        )

        return logData
    }


    // ============================================================
    // ATTACHMENT RESULT
    // ============================================================

    private fun handleAttachmentResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?
    ) {

        val result =
            attachmentPickerResult
                ?: return


        if (
            resultCode != RESULT_OK ||
            data == null
        ) {

            result.success(
                emptyList<String>()
            )

            clearAttachmentPicker()

            return
        }


        val maxItems =
            attachmentPickerMax


        val uris =
            mutableListOf<Uri>()


        // --------------------------------------------------------
        // Multiple selection
        // --------------------------------------------------------

        val clipData =
            data.clipData


        if (clipData != null) {

            for (
                i in 0 until clipData.itemCount
            ) {

                if (
                    uris.size >= maxItems
                ) {

                    break
                }


                val uri =
                    clipData
                        .getItemAt(i)
                        .uri


                uris.add(
                    uri
                )
            }

        } else {

            // ----------------------------------------------------
            // Single selection
            // ----------------------------------------------------

            data.data?.let { uri ->

                uris.add(
                    uri
                )
            }
        }


        val limitedUris =
            uris.take(
                maxItems
            )


        Log.d(
            "BelnetLibPlugin",
            "Selected ${limitedUris.size} attachments"
        )


        val isImagePicker =
            requestCode ==
                    PHOTO_PICKER_REQUEST_CODE


        /*
         * Copying and re-encoding images is too slow for the main
         * thread (up to 10 files), so do it in the background and
         * post the result back. attachmentPickerResult stays set
         * until then, which keeps a second picker from opening.
         */
        Thread {

        val filePaths =
            mutableListOf<String>()


        /*
         * Store all invalid files so we can show
         * one useful Toast instead of many Toasts.
         */
        val invalidMessages =
            mutableListOf<String>()


        /*
         * Images whose metadata could not be removed. They are
         * never returned to Flutter.
         */
        val cleanFailedNames =
            mutableListOf<String>()


        // ========================================================
        // VALIDATE EACH FILE
        // ========================================================

        limitedUris.forEachIndexed {

                index,
                uri ->


            val fileName =
                getDisplayName(uri)
                    ?: "Selected file"


            val fileSize =
                getFileSize(uri)


            val maxSize =
                getMaxFileSize(
                    uri,
                    isImagePicker
                )


            /*
             * If Android gives us a valid file size,
             * validate before copying.
             */
            if (
                fileSize > 0 &&
                maxSize != null &&
                fileSize > maxSize
            ) {

                invalidMessages.add(
                    "$fileName is ${formatFileSize(fileSize)}. " +
                            "Maximum allowed is ${formatMaxSize(maxSize)}."
                )


                Log.w(
                    "BelnetLibPlugin",
                    "Attachment rejected: " +
                            "size=${formatFileSize(fileSize)} " +
                            "limit=${formatMaxSize(maxSize)}"
                )


                return@forEachIndexed
            }


            /*
             * File is within the limit OR
             * Android did not provide the size.
             *
             * copyUriToCache() performs a second
             * safety check while copying.
             */
            val copyResult =
                copyUriToCache(
                    uri,
                    index,
                    isImagePicker
                )


            when (copyResult) {

                is CopyResult.Success -> {

                    filePaths.add(
                        copyResult.path
                    )
                }


                is CopyResult.TooLarge -> {

                    invalidMessages.add(
                        "${copyResult.fileName} is too large. " +
                                "Maximum allowed is " +
                                formatMaxSize(
                                    copyResult.maxSize
                                ) + "."
                    )
                }


                is CopyResult.CleanFailed -> {

                    cleanFailedNames.add(
                        copyResult.fileName
                    )
                }


                CopyResult.Failed -> {

                    Log.w(
                        "BelnetLibPlugin",
                        "Failed to copy attachment #$index"
                    )
                }
            }
        }


        // ========================================================
        // SHOW METADATA-CLEAN ERROR
        // ========================================================

        if (
            cleanFailedNames.isNotEmpty()
        ) {

            showToast(
                if (cleanFailedNames.size == 1) {
                    "${cleanFailedNames.first()} could not be processed " +
                            "and was not attached."
                } else {
                    "${cleanFailedNames.size} images could not be " +
                            "processed and were not attached."
                }
            )
        }


        // ========================================================
        // SHOW SIZE ERROR
        // ========================================================

        if (
            invalidMessages.isNotEmpty()
        ) {

            val message =

                if (
                    invalidMessages.size == 1
                ) {

                    invalidMessages.first()

                } else {

                    "${invalidMessages.size} selected files " +
                            "exceed the allowed size limit."
                }


            showToast(
                message
            )
        }


        // ========================================================
        // RETURN VALID FILES TO FLUTTER
        // ========================================================

        Log.d(
            "BelnetLibPlugin",
            "Returning ${filePaths.size} valid attachment paths"
        )


        Handler(
            Looper.getMainLooper()
        ).post {

            result.success(
                filePaths
            )

            clearAttachmentPicker()
        }

        }.start()
    }


    // ============================================================
    // COPY RESULT
    // ============================================================

    private sealed class CopyResult {

        data class Success(
            val path: String
        ) : CopyResult()


        data class TooLarge(
            val fileName: String,
            val maxSize: Long
        ) : CopyResult()


        /*
         * The file is an image but its metadata could not be
         * removed. It has been deleted and must not be sent.
         */
        data class CleanFailed(
            val fileName: String
        ) : CopyResult()


        object Failed : CopyResult()
    }


    // ============================================================
    // COPY URI TO CACHE
    // ============================================================

    private fun copyUriToCache(
        uri: Uri,
        index: Int,
        isImage: Boolean
    ): CopyResult {

        return try {

            val inputStream =
                context.contentResolver
                    .openInputStream(uri)
                    ?: return CopyResult.Failed


            val mimeType =
                context.contentResolver.getType(
                    uri
                )


            val extension =
                getFileExtension(
                    uri,
                    mimeType,
                    isImage
                )


            val maxFileSize =
                getMaxFileSize(
                    uri,
                    isImage
                )
                    ?: MAX_UNKNOWN_FILE_SIZE


            val originalName =
                getDisplayName(uri)


            val safeName =
                originalName
                    ?.substringBeforeLast(".")
                    ?.replace(
                        Regex(
                            "[^a-zA-Z0-9_-]"
                        ),
                        "_"
                    )
                    ?.take(50)
                    ?: "attachment"


            val fileName =
                "chat_${System.currentTimeMillis()}_${index}_${safeName}.$extension"


            val outputFile =
                File(
                    context.cacheDir,
                    fileName
                )


            var totalBytes =
                0L


            try {

                FileOutputStream(
                    outputFile
                ).use { outputStream ->

                    inputStream.use { input ->

                        val buffer =
                            ByteArray(
                                8192
                            )


                        while (true) {

                            val length =
                                input.read(
                                    buffer
                                )


                            if (
                                length == -1
                            ) {

                                break
                            }


                            totalBytes +=
                                length


                            /*
                             * SECOND SIZE CHECK
                             *
                             * This protects against providers
                             * that don't report file size.
                             */
                            if (
                                totalBytes >
                                maxFileSize
                            ) {

                                outputFile.delete()


                                Log.w(
                                    "BelnetLibPlugin",
                                    "Attachment exceeded limit while copying: " +
                                            "${formatFileSize(totalBytes)} > " +
                                            formatMaxSize(maxFileSize)
                                )


                                return CopyResult.TooLarge(
                                    fileName =
                                        originalName
                                            ?: "Selected file",
                                    maxSize =
                                        maxFileSize
                                )
                            }


                            outputStream.write(
                                buffer,
                                0,
                                length
                            )
                        }
                    }
                }


                // Do not log the path: it contains the user's file name.
                Log.d(
                    "BelnetLibPlugin",
                    "Attachment copied (${formatFileSize(totalBytes)})"
                )


                /*
                 * Images may come from the photo picker OR the
                 * generic file picker, so detect them by MIME type
                 * and extension, not only by which picker was used.
                 */
                val looksLikeImage =
                    isImage ||
                            mimeType?.startsWith("image/") == true ||
                            extension.lowercase() in IMAGE_EXTENSIONS


                if (looksLikeImage) {

                    val cleaned =
                        sanitizeImage(
                            outputFile,
                            index,
                            safeName
                        )

                    // The raw copy still has the original metadata.
                    outputFile.delete()

                    if (cleaned == null) {

                        CopyResult.CleanFailed(
                            originalName ?: "Selected image"
                        )

                    } else {

                        CopyResult.Success(
                            cleaned.absolutePath
                        )
                    }

                } else {

                    CopyResult.Success(
                        outputFile.absolutePath
                    )
                }

            } catch (e: Exception) {

                outputFile.delete()

                throw e
            }

        } catch (e: Exception) {

            Log.e(
                "BelnetLibPlugin",
                "Failed to copy attachment",
                e
            )

            CopyResult.Failed
        }
    }


    // ============================================================
    // VPN TRANSPORT CHECK
    // ============================================================

    /**
     * True when this app's active network is a VPN. Belnet's
     * VpnService only admits this app (addAllowedApplication), so
     * together with IsRunning() this means our sockets go through
     * the tunnel. When Belnet drops, Android silently falls back to
     * the normal network, which is what the AI guard must catch.
     */
    private fun isVpnTransportActive(): Boolean {

        return try {

            val cm =
                context.getSystemService(
                    Context.CONNECTIVITY_SERVICE
                ) as ConnectivityManager

            val network =
                cm.activeNetwork
                    ?: return false

            val caps =
                cm.getNetworkCapabilities(network)
                    ?: return false

            caps.hasTransport(
                NetworkCapabilities.TRANSPORT_VPN
            )

        } catch (e: Exception) {

            Log.w("BelnetLibPlugin", "VPN transport check failed", e)

            false
        }
    }


    // ============================================================
    // AI TEMPORARY FILE CLEANUP
    // ============================================================

    /**
     * Deletes AI chat temporary files from the app cache (attachment
     * copies, cleaned images, camera captures, read-aloud WAVs, share
     * images) and any read-aloud WAVs left in shared storage.
     *
     * [keepPaths] are skipped (e.g. the WAV that is playing now).
     * Returns the number of files deleted.
     */
    private fun purgeAiTempFiles(
        keepPaths: Set<String>
    ): Int {

        var deleted = 0

        val keep =
            keepPaths.mapNotNull { path ->
                try {
                    File(path).canonicalPath
                } catch (e: Exception) {
                    null
                }
            }.toSet()

        try {

            context.cacheDir.listFiles()?.forEach { file ->

                if (!file.isFile) return@forEach

                if (
                    AI_CACHE_FILE_PATTERNS.none { pattern ->
                        pattern.matches(file.name)
                    }
                ) {
                    return@forEach
                }

                val canonical =
                    try {
                        file.canonicalPath
                    } catch (e: Exception) {
                        return@forEach
                    }

                if (canonical in keep) return@forEach

                if (file.delete()) deleted++
            }

        } catch (e: Exception) {

            Log.w("BelnetLibPlugin", "AI cache cleanup failed", e)
        }

        deleted += deleteTtsSharedCopies()

        Log.d("BelnetLibPlugin", "AI temp files deleted: $deleted")

        return deleted
    }


    /**
     * Removes read-aloud WAVs that flutter_tts wrote to shared
     * storage (synthesizeToFile with isFullPath = false):
     *  - Android 10+: rows this app inserted into MediaStore Audio.
     *  - Android 9 and below: files in the public Music directory.
     */
    private fun deleteTtsSharedCopies(): Int {

        var deleted = 0

        // ---- MediaStore rows (all versions; only our own rows) ----
        try {

            val collection =
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI

            val ids =
                mutableListOf<Long>()

            context.contentResolver.query(
                collection,
                arrayOf(
                    MediaStore.Audio.Media._ID,
                    MediaStore.Audio.Media.DISPLAY_NAME
                ),
                "${MediaStore.Audio.Media.DISPLAY_NAME} LIKE ?",
                arrayOf("beldex_ai_%.wav"),
                null
            )?.use { cursor ->

                val idIndex =
                    cursor.getColumnIndex(MediaStore.Audio.Media._ID)

                val nameIndex =
                    cursor.getColumnIndex(MediaStore.Audio.Media.DISPLAY_NAME)

                while (cursor.moveToNext()) {

                    if (idIndex < 0 || nameIndex < 0) break

                    val name =
                        cursor.getString(nameIndex) ?: continue

                    // LIKE treats "_" as a wildcard; match exactly.
                    if (TTS_FILE_REGEX.matches(name)) {
                        ids.add(cursor.getLong(idIndex))
                    }
                }
            }

            for (id in ids) {

                try {

                    deleted +=
                        context.contentResolver.delete(
                            ContentUris.withAppendedId(collection, id),
                            null,
                            null
                        )

                } catch (e: Exception) {

                    // e.g. a row from a previous install we no
                    // longer own (RecoverableSecurityException).
                    Log.w("BelnetLibPlugin", "Could not delete TTS row", e)
                }
            }

        } catch (e: Exception) {

            Log.w("BelnetLibPlugin", "TTS MediaStore cleanup failed", e)
        }


        // ---- Legacy public Music directory (Android 9 and below) --
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {

            try {

                @Suppress("DEPRECATION")
                val musicDir =
                    Environment.getExternalStoragePublicDirectory(
                        Environment.DIRECTORY_MUSIC
                    )

                musicDir.listFiles()?.forEach { file ->

                    if (
                        file.isFile &&
                        TTS_FILE_REGEX.matches(file.name) &&
                        file.delete()
                    ) {
                        deleted++
                    }
                }

            } catch (e: Exception) {

                Log.w("BelnetLibPlugin", "Legacy TTS cleanup failed", e)
            }
        }

        return deleted
    }


    // ============================================================
    // DOCUMENT TEXT EXTRACTION (on device)
    // ============================================================

    /*
     * Documents are never uploaded to an AI provider as files. Their
     * text is extracted here, on the device, and only that text is
     * sent. Nothing in this section uses the network.
     */

    private class ExtractionFailure(
        val code: String,
        message: String
    ) : Exception(message)


    /** Collects extracted text up to [maxChars]. */
    private class TextBudget(
        private val maxChars: Int
    ) {

        val text = StringBuilder()

        var truncated = false
            private set

        val isFull: Boolean
            get() = text.length >= maxChars

        fun append(value: CharSequence) {

            if (value.isEmpty()) return

            val room = maxChars - text.length

            if (room <= 0) {
                truncated = true
                return
            }

            if (value.length > room) {
                text.append(value, 0, room)
                truncated = true
            } else {
                text.append(value)
            }
        }

        fun markTruncated() {
            truncated = true
        }
    }


    /**
     * Stops reading a ZIP entry once it has produced more than
     * [limit] bytes (protects against ZIP bombs).
     */
    private class BoundedInputStream(
        input: InputStream,
        private val limit: Long
    ) : FilterInputStream(input) {

        private var count = 0L

        override fun read(): Int {
            val b = super.read()
            if (b >= 0) addCount(1)
            return b
        }

        override fun read(b: ByteArray, off: Int, len: Int): Int {
            val n = super.read(b, off, len)
            if (n > 0) addCount(n.toLong())
            return n
        }

        private fun addCount(n: Long) {
            count += n
            if (count > limit) {
                throw ExtractionFailure(
                    "TOO_LARGE",
                    "Document is too large to read."
                )
            }
        }
    }


    /**
     * Returns {"text", "truncated", "format"} or throws
     * [ExtractionFailure] with a code the Dart side maps to a message.
     */
    private fun extractDocumentText(
        file: File,
        maxChars: Int
    ): Map<String, Any> {

        val format =
            file.name.substringAfterLast('.', "").lowercase()

        val budget = TextBudget(maxChars)

        when (format) {

            "txt", "csv", "tsv", "md", "json", "xml", "log" ->
                budget.append(readTextFile(file))

            "html", "htm" ->
                budget.append(htmlToText(readTextFile(file)))

            "pdf" ->
                extractPdfText(file, budget)

            "docx" ->
                extractDocxText(file, budget)

            "xlsx" ->
                extractXlsxText(file, budget)

            "pptx" ->
                extractPptxText(file, budget)

            "doc", "xls", "ppt" ->
                throw ExtractionFailure(
                    "LEGACY_FORMAT",
                    "Old Office formats are not supported."
                )

            else ->
                throw ExtractionFailure(
                    "UNSUPPORTED",
                    "This file type is not supported."
                )
        }

        val text = normalizeExtractedText(budget.text.toString())

        if (text.isBlank()) {
            throw ExtractionFailure(
                "NO_TEXT",
                "No readable text found."
            )
        }

        return mapOf(
            "text" to text,
            "truncated" to budget.truncated,
            "format" to format
        )
    }


    // ---- Plain text ------------------------------------------------

    private fun readTextFile(file: File): String {

        val bytes = file.readBytes()

        // Byte-order marks.
        if (
            bytes.size >= 3 &&
            bytes[0] == 0xEF.toByte() &&
            bytes[1] == 0xBB.toByte() &&
            bytes[2] == 0xBF.toByte()
        ) {
            return String(bytes, 3, bytes.size - 3, Charsets.UTF_8)
        }

        if (
            bytes.size >= 2 &&
            bytes[0] == 0xFF.toByte() &&
            bytes[1] == 0xFE.toByte()
        ) {
            return String(bytes, 2, bytes.size - 2, Charsets.UTF_16LE)
        }

        if (
            bytes.size >= 2 &&
            bytes[0] == 0xFE.toByte() &&
            bytes[1] == 0xFF.toByte()
        ) {
            return String(bytes, 2, bytes.size - 2, Charsets.UTF_16BE)
        }

        // A NUL byte early on means this is not a text file.
        val probe = minOf(bytes.size, 8192)

        for (i in 0 until probe) {
            if (bytes[i] == 0.toByte()) {
                throw ExtractionFailure(
                    "NOT_TEXT",
                    "File is not a text file."
                )
            }
        }

        return try {
            Charsets.UTF_8.newDecoder()
                .onMalformedInput(CodingErrorAction.REPORT)
                .onUnmappableCharacter(CodingErrorAction.REPORT)
                .decode(ByteBuffer.wrap(bytes))
                .toString()
        } catch (e: CharacterCodingException) {
            // Not UTF-8: treat as Latin-1 so no bytes are lost.
            String(bytes, Charsets.ISO_8859_1)
        }
    }


    // ---- HTML ------------------------------------------------------

    private fun htmlToText(html: String): String {

        // Drop script/style blocks and comments before converting.
        val cleaned =
            html
                .replace(
                    Regex(
                        "(?is)<(script|style|noscript|template)\\b[^>]*>.*?</\\1\\s*>"
                    ),
                    " "
                )
                .replace(Regex("(?s)<!--.*?-->"), " ")

        // No ImageGetter: images are never loaded.
        return fromHtmlCompat(cleaned)
            .replace("￼", "")
    }


    @Suppress("DEPRECATION")
    private fun fromHtmlCompat(html: String): String {

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            Html.fromHtml(html, Html.FROM_HTML_MODE_COMPACT).toString()
        } else {
            Html.fromHtml(html).toString()
        }
    }


    // ---- PDF -------------------------------------------------------

    private fun extractPdfText(
        file: File,
        budget: TextBudget
    ) {

        if (!PDFBoxResourceLoader.isReady()) {
            PDFBoxResourceLoader.init(context.applicationContext)
        }

        val document =
            try {
                PDDocument.load(
                    file,
                    MemoryUsageSetting.setupMixed(PDF_MAX_MAIN_MEMORY_BYTES)
                )
            } catch (e: InvalidPasswordException) {
                throw ExtractionFailure(
                    "ENCRYPTED",
                    "PDF is password-protected."
                )
            } catch (e: IOException) {
                throw ExtractionFailure(
                    "CORRUPT",
                    "PDF could not be opened."
                )
            }

        document.use { doc ->

            val stripper = PDFTextStripper()
            stripper.setSortByPosition(true)

            val pageCount = doc.getNumberOfPages()

            for (page in 1..pageCount) {

                if (budget.isFull) {
                    budget.markTruncated()
                    break
                }

                stripper.setStartPage(page)
                stripper.setEndPage(page)

                budget.append(stripper.getText(doc))
                budget.append("\n")
            }
        }
    }


    // ---- Office Open XML (docx / xlsx / pptx) ----------------------

    private fun openZip(file: File): ZipFile {

        return try {
            ZipFile(file)
        } catch (e: IOException) {
            // e.g. an old .doc renamed to .docx.
            throw ExtractionFailure(
                "CORRUPT",
                "Document could not be opened."
            )
        }
    }


    /**
     * Opens [name] inside [zip] as an XML pull parser and runs
     * [block]. Returns null if the entry does not exist.
     */
    private fun <T> readZipXml(
        zip: ZipFile,
        name: String,
        block: (XmlPullParser) -> T
    ): T? {

        val entry = zip.getEntry(name) ?: return null

        BoundedInputStream(
            zip.getInputStream(entry),
            MAX_ZIP_ENTRY_BYTES
        ).use { stream ->

            val parser = Xml.newPullParser()

            // Keep prefixes ("w:t", "a:t") in tag names.
            parser.setFeature(
                XmlPullParser.FEATURE_PROCESS_NAMESPACES,
                false
            )

            parser.setInput(stream, null)

            return block(parser)
        }
    }


    /** Walks [parser] until the end, or until [budget] is full. */
    private fun walkXml(
        parser: XmlPullParser,
        budget: TextBudget,
        onStart: (String) -> Unit,
        onEnd: (String) -> Unit
    ) {

        var event = parser.eventType

        while (event != XmlPullParser.END_DOCUMENT) {

            if (budget.isFull) {
                budget.markTruncated()
                return
            }

            if (event == XmlPullParser.START_TAG) {
                onStart(parser.name)
            } else if (event == XmlPullParser.END_TAG) {
                onEnd(parser.name)
            }

            event = parser.next()
        }
    }


    private fun extractDocxText(
        file: File,
        budget: TextBudget
    ) {

        openZip(file).use { zip ->

            readZipXml(zip, "word/document.xml") { parser ->

                walkXml(
                    parser,
                    budget,
                    onStart = { tag ->
                        when (tag) {
                            "w:t" -> budget.append(parser.nextText())
                            "w:tab" -> budget.append("\t")
                            "w:br", "w:cr" -> budget.append("\n")
                        }
                    },
                    onEnd = { tag ->
                        if (tag == "w:p") budget.append("\n")
                    }
                )

            } ?: throw ExtractionFailure(
                "CORRUPT",
                "Not a valid Word document."
            )
        }
    }


    private fun extractPptxText(
        file: File,
        budget: TextBudget
    ) {

        openZip(file).use { zip ->

            val slideRegex = Regex("^ppt/slides/slide(\\d+)\\.xml$")

            val slides =
                zip.entries().asSequence()
                    .mapNotNull { entry ->
                        slideRegex.find(entry.name)
                            ?.groupValues
                            ?.get(1)
                            ?.toIntOrNull()
                            ?.let { number -> number to entry.name }
                    }
                    .sortedBy { it.first }
                    .toList()

            if (slides.isEmpty()) {
                throw ExtractionFailure(
                    "CORRUPT",
                    "Not a valid PowerPoint file."
                )
            }

            for ((number, entryName) in slides) {

                if (budget.isFull) {
                    budget.markTruncated()
                    break
                }

                budget.append("Slide $number\n")

                readZipXml(zip, entryName) { parser ->

                    walkXml(
                        parser,
                        budget,
                        onStart = { tag ->
                            when (tag) {
                                "a:t" -> budget.append(parser.nextText())
                                "a:br" -> budget.append("\n")
                            }
                        },
                        onEnd = { tag ->
                            if (tag == "a:p") budget.append("\n")
                        }
                    )
                }

                budget.append("\n")
            }
        }
    }


    private fun extractXlsxText(
        file: File,
        budget: TextBudget
    ) {

        openZip(file).use { zip ->

            // ---- Shared strings ----------------------------------
            val sharedStrings = mutableListOf<String>()

            readZipXml(zip, "xl/sharedStrings.xml") { parser ->

                var current: StringBuilder? = null
                var inPhonetic = false
                var event = parser.eventType

                while (event != XmlPullParser.END_DOCUMENT) {

                    if (event == XmlPullParser.START_TAG) {
                        when (parser.name) {
                            "si" -> current = StringBuilder()
                            "rPh" -> inPhonetic = true
                            "t" -> {
                                val text = parser.nextText()
                                val target = current
                                if (target != null && !inPhonetic) {
                                    target.append(text)
                                }
                            }
                        }
                    } else if (event == XmlPullParser.END_TAG) {
                        when (parser.name) {
                            "rPh" -> inPhonetic = false
                            "si" -> {
                                sharedStrings.add(current?.toString() ?: "")
                                current = null
                            }
                        }
                    }

                    event = parser.next()
                }
            }


            // ---- Sheet names and files ---------------------------
            val relTargets = mutableMapOf<String, String>()

            readZipXml(zip, "xl/_rels/workbook.xml.rels") { parser ->

                var event = parser.eventType

                while (event != XmlPullParser.END_DOCUMENT) {

                    if (
                        event == XmlPullParser.START_TAG &&
                        parser.name == "Relationship"
                    ) {
                        val id = parser.getAttributeValue(null, "Id")
                        val target = parser.getAttributeValue(null, "Target")
                        if (id != null && target != null) {
                            relTargets[id] = target
                        }
                    }

                    event = parser.next()
                }
            }

            val sheets = mutableListOf<Pair<String, String>>()

            readZipXml(zip, "xl/workbook.xml") { parser ->

                var event = parser.eventType

                while (event != XmlPullParser.END_DOCUMENT) {

                    if (
                        event == XmlPullParser.START_TAG &&
                        parser.name == "sheet"
                    ) {
                        val name =
                            parser.getAttributeValue(null, "name") ?: "Sheet"
                        val relId =
                            parser.getAttributeValue(null, "r:id")
                        val target =
                            relId?.let { relTargets[it] }

                        if (target != null) {
                            val path =
                                if (target.startsWith("/")) {
                                    target.removePrefix("/")
                                } else {
                                    "xl/" + target.removePrefix("./")
                                }
                            sheets.add(name to path)
                        }
                    }

                    event = parser.next()
                }
            }

            if (sheets.isEmpty()) {
                throw ExtractionFailure(
                    "CORRUPT",
                    "Not a valid Excel file."
                )
            }


            // ---- Cells -------------------------------------------
            for ((sheetName, sheetPath) in sheets) {

                if (budget.isFull) {
                    budget.markTruncated()
                    break
                }

                budget.append("Sheet: $sheetName\n")

                readZipXml(zip, sheetPath) { parser ->

                    val row = mutableListOf<String>()
                    var cellType: String? = null
                    var cellColumn = -1
                    var cellValue = ""

                    walkXml(
                        parser,
                        budget,
                        onStart = { tag ->
                            when (tag) {
                                "row" -> row.clear()
                                "c" -> {
                                    cellType = parser.getAttributeValue(null, "t")
                                    cellColumn = columnIndex(
                                        parser.getAttributeValue(null, "r")
                                    )
                                    cellValue = ""
                                }
                                "v" -> {
                                    val raw = parser.nextText()
                                    cellValue =
                                        when (cellType) {
                                            "s" -> raw.trim().toIntOrNull()
                                                ?.let { sharedStrings.getOrNull(it) }
                                                ?: ""
                                            "b" -> if (raw.trim() == "1") "TRUE" else "FALSE"
                                            else -> raw
                                        }
                                }
                                "t" -> {
                                    // Inline strings: <c t="inlineStr"><is><t>
                                    if (cellType == "inlineStr") {
                                        cellValue += parser.nextText()
                                    }
                                }
                            }
                        },
                        onEnd = { tag ->
                            when (tag) {
                                "c" -> {
                                    val column =
                                        if (cellColumn >= 0) cellColumn else row.size
                                    while (row.size < column) row.add("")
                                    if (row.size == column) {
                                        row.add(cellValue)
                                    } else {
                                        row[column] = cellValue
                                    }
                                }
                                "row" -> {
                                    if (row.any { it.isNotBlank() }) {
                                        budget.append(
                                            row.joinToString("\t").trimEnd() + "\n"
                                        )
                                    }
                                }
                            }
                        }
                    )
                }

                budget.append("\n")
            }
        }
    }


    /** "C12" -> 2 (zero-based). Returns -1 if missing. */
    private fun columnIndex(reference: String?): Int {

        if (reference.isNullOrEmpty()) return -1

        var index = 0
        var seenLetter = false

        for (ch in reference) {
            if (ch in 'A'..'Z') {
                index = index * 26 + (ch - 'A' + 1)
                seenLetter = true
            } else {
                break
            }
        }

        // Guard against nonsense references creating huge rows.
        return if (seenLetter && index in 1..MAX_XLSX_COLUMNS) index - 1 else -1
    }


    private fun normalizeExtractedText(text: String): String {

        return text
            .replace("\r\n", "\n")
            .replace('\r', '\n')
            // Control characters other than tab and newline.
            .replace(Regex("[\\u0000-\\u0008\\u000B\\u000C\\u000E-\\u001F\\u007F]"), "")
            .replace(Regex("[ \\t]+\\n"), "\n")
            .replace(Regex("\\n{3,}"), "\n\n")
            .trim()
    }


    // ============================================================
    // SANITISE IMAGE (strip EXIF / XMP / IPTC)
    // ============================================================

    /**
     * Decodes [source] to pixels and writes a brand-new JPEG.
     *
     * Bitmap.compress() writes no EXIF, XMP, IPTC, ICC-embedded
     * comments or thumbnails, so GPS position, camera make/model,
     * serial numbers and capture time are all dropped. The EXIF
     * orientation is applied to the pixels first so the cleaned
     * image is not shown rotated.
     *
     * Transparent images are flattened onto white; animated GIFs
     * keep their first frame. HEIC/HEIF only decodes on Android 9+.
     *
     * Returns null if the image cannot be decoded, encoded or
     * verified. The caller must then NOT send the original.
     */
    private fun sanitizeImage(
        source: File,
        index: Int,
        baseName: String
    ): File? {

        var output: File? = null

        // Only used by `finally` to free whatever bitmap is current.
        var toRecycle: Bitmap? = null

        try {

            // ---- 1. Read dimensions only -------------------------
            val bounds =
                BitmapFactory.Options().apply {
                    inJustDecodeBounds = true
                }

            BitmapFactory.decodeFile(
                source.absolutePath,
                bounds
            )

            if (bounds.outWidth <= 0 || bounds.outHeight <= 0) {
                Log.w("BelnetLibPlugin", "Image could not be decoded")
                return null
            }


            // ---- 2. Decode with subsampling (limits memory) ------
            var sampleSize = 1

            while (
                maxOf(bounds.outWidth, bounds.outHeight) /
                (sampleSize * 2) >= MAX_IMAGE_DIMENSION
            ) {
                sampleSize *= 2
            }

            val decodeOptions =
                BitmapFactory.Options().apply {
                    inSampleSize = sampleSize
                    inPreferredConfig = Bitmap.Config.ARGB_8888
                }

            val decoded: Bitmap =
                BitmapFactory.decodeFile(
                    source.absolutePath,
                    decodeOptions
                ) ?: return null

            /*
             * `current` is non-null, so it can be used inside
             * lambdas without a smart cast (Kotlin 1.9 rejects smart
             * casts on vars captured by a closure).
             */
            var current: Bitmap = decoded
            toRecycle = current


            // ---- 3. Apply EXIF orientation to the pixels ---------
            val orientation =
                try {
                    ExifInterface(source.absolutePath)
                        .getAttributeInt(
                            ExifInterface.TAG_ORIENTATION,
                            ExifInterface.ORIENTATION_NORMAL
                        )
                } catch (e: Exception) {
                    ExifInterface.ORIENTATION_NORMAL
                }

            current = replaceBitmap(
                current,
                applyExifOrientation(current, orientation)
            )
            toRecycle = current


            // ---- 4. Scale to the final size ----------------------
            val longest = maxOf(current.width, current.height)

            if (longest > MAX_IMAGE_DIMENSION) {

                val scale =
                    MAX_IMAGE_DIMENSION.toFloat() / longest

                current = replaceBitmap(
                    current,
                    Bitmap.createScaledBitmap(
                        current,
                        (current.width * scale).toInt().coerceAtLeast(1),
                        (current.height * scale).toInt().coerceAtLeast(1),
                        true
                    )
                )
                toRecycle = current
            }


            // ---- 5. Flatten transparency (JPEG has no alpha) -----
            if (current.hasAlpha()) {

                val withAlpha = current

                val flat =
                    Bitmap.createBitmap(
                        withAlpha.width,
                        withAlpha.height,
                        Bitmap.Config.ARGB_8888
                    )

                val canvas = Canvas(flat)
                canvas.drawColor(Color.WHITE)
                canvas.drawBitmap(withAlpha, 0f, 0f, null)

                current = replaceBitmap(withAlpha, flat)
                toRecycle = current
            }


            // ---- 6. Encode a new file ----------------------------
            val outFile =
                File(
                    context.cacheDir,
                    "${CLEAN_IMAGE_PREFIX}${System.currentTimeMillis()}" +
                            "_${index}_${baseName}.jpg"
                )

            output = outFile

            val toEncode: Bitmap = current

            val encoded =
                FileOutputStream(outFile).use { stream ->
                    toEncode.compress(
                        Bitmap.CompressFormat.JPEG,
                        CLEAN_JPEG_QUALITY,
                        stream
                    )
                }

            if (!encoded || outFile.length() == 0L) {
                outFile.delete()
                return null
            }


            // ---- 7. Verify nothing identifying survived ----------
            if (!hasNoIdentifyingMetadata(outFile)) {
                Log.w("BelnetLibPlugin", "Metadata still present after re-encode")
                outFile.delete()
                return null
            }

            return outFile

        } catch (t: Throwable) {

            // Includes OutOfMemoryError on very large images.
            Log.e("BelnetLibPlugin", "Image sanitise failed", t)

            output?.delete()

            return null

        } finally {

            toRecycle?.recycle()
        }
    }


    /**
     * Recycles [old] when [new] is a different Bitmap instance
     * (createBitmap/createScaledBitmap can return the same one).
     */
    private fun replaceBitmap(
        old: Bitmap,
        new: Bitmap
    ): Bitmap {

        if (new !== old) {
            old.recycle()
        }

        return new
    }


    private fun applyExifOrientation(
        bitmap: Bitmap,
        orientation: Int
    ): Bitmap {

        val matrix = Matrix()

        when (orientation) {
            ExifInterface.ORIENTATION_FLIP_HORIZONTAL ->
                matrix.setScale(-1f, 1f)
            ExifInterface.ORIENTATION_ROTATE_180 ->
                matrix.setRotate(180f)
            ExifInterface.ORIENTATION_FLIP_VERTICAL ->
                matrix.setScale(1f, -1f)
            ExifInterface.ORIENTATION_TRANSPOSE -> {
                matrix.setRotate(90f)
                matrix.postScale(-1f, 1f)
            }
            ExifInterface.ORIENTATION_ROTATE_90 ->
                matrix.setRotate(90f)
            ExifInterface.ORIENTATION_TRANSVERSE -> {
                matrix.setRotate(-90f)
                matrix.postScale(-1f, 1f)
            }
            ExifInterface.ORIENTATION_ROTATE_270 ->
                matrix.setRotate(-90f)
            else ->
                return bitmap
        }

        return Bitmap.createBitmap(
            bitmap,
            0,
            0,
            bitmap.width,
            bitmap.height,
            matrix,
            true
        )
    }


    /**
     * Defence in depth: re-read the encoded file and make sure the
     * tags that identify a person, place, device or time are gone.
     */
    private fun hasNoIdentifyingMetadata(
        file: File
    ): Boolean {

        return try {

            val exif = ExifInterface(file.absolutePath)

            val identifyingTags = listOf(
                ExifInterface.TAG_GPS_LATITUDE,
                ExifInterface.TAG_GPS_LONGITUDE,
                ExifInterface.TAG_GPS_ALTITUDE,
                ExifInterface.TAG_GPS_TIMESTAMP,
                ExifInterface.TAG_MAKE,
                ExifInterface.TAG_MODEL,
                ExifInterface.TAG_DATETIME,
                ExifInterface.TAG_DATETIME_ORIGINAL,
                ExifInterface.TAG_DATETIME_DIGITIZED,
                ExifInterface.TAG_SOFTWARE,
                ExifInterface.TAG_ARTIST,
                ExifInterface.TAG_COPYRIGHT,
                ExifInterface.TAG_IMAGE_DESCRIPTION,
                ExifInterface.TAG_USER_COMMENT
            )

            identifyingTags.none { tag ->
                !exif.getAttribute(tag).isNullOrBlank()
            } && !exif.hasThumbnail()

        } catch (e: Exception) {

            // A freshly encoded JPEG that cannot be parsed is
            // suspicious; fail closed.
            false
        }
    }


    // ============================================================
    // GET MAXIMUM FILE SIZE
    // ============================================================

    private fun getMaxFileSize(
        uri: Uri,
        isImage: Boolean
    ): Long? {

        /*
         * Image picker always contains images.
         */
        if (isImage) {

            return MAX_IMAGE_SIZE
        }


        val mimeType =
            context.contentResolver.getType(
                uri
            )


        return when (mimeType) {

            // ----------------------------------------------------
            // PDF
            // ----------------------------------------------------

            "application/pdf" -> {

                MAX_DOCUMENT_SIZE
            }


            // ----------------------------------------------------
            // DOC
            // ----------------------------------------------------

            "application/msword" -> {

                MAX_DOCUMENT_SIZE
            }


            // ----------------------------------------------------
            // DOCX
            // ----------------------------------------------------

            "application/vnd.openxmlformats-officedocument.wordprocessingml.document" -> {

                MAX_DOCUMENT_SIZE
            }


            // ----------------------------------------------------
            // TXT
            // ----------------------------------------------------

            "text/plain" -> {

                MAX_TEXT_SIZE
            }


            // ----------------------------------------------------
            // CSV
            // ----------------------------------------------------

            "text/csv" -> {

                MAX_TEXT_SIZE
            }


            // ----------------------------------------------------
            // XLS
            // ----------------------------------------------------

            "application/vnd.ms-excel" -> {

                MAX_SPREADSHEET_SIZE
            }


            // ----------------------------------------------------
            // XLSX
            // ----------------------------------------------------

            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" -> {

                MAX_SPREADSHEET_SIZE
            }


            // ----------------------------------------------------
            // MIME TYPE UNKNOWN
            // ----------------------------------------------------

            else -> {

                val extension =
                    getDisplayName(uri)
                        ?.substringAfterLast(
                            ".",
                            ""
                        )
                        ?.lowercase()


                when (extension) {

                    "pdf",
                    "doc",
                    "docx" -> {

                        MAX_DOCUMENT_SIZE
                    }


                    "txt",
                    "csv" -> {

                        MAX_TEXT_SIZE
                    }


                    "xls",
                    "xlsx" -> {

                        MAX_SPREADSHEET_SIZE
                    }


                    "jpg",
                    "jpeg",
                    "png",
                    "webp",
                    "gif",
                    "heic",
                    "heif" -> {

                        MAX_IMAGE_SIZE
                    }


                    else -> {

                        MAX_UNKNOWN_FILE_SIZE
                    }
                }
            }
        }
    }


    // ============================================================
    // GET FILE SIZE
    // ============================================================

    private fun getFileSize(
        uri: Uri
    ): Long {

        /*
         * First attempt:
         * OpenableColumns.SIZE
         */
        try {

            context.contentResolver.query(
                uri,
                arrayOf(
                    android.provider.OpenableColumns.SIZE
                ),
                null,
                null,
                null
            )?.use { cursor ->

                if (
                    cursor.moveToFirst()
                ) {

                    val sizeIndex =
                        cursor.getColumnIndex(
                            android.provider.OpenableColumns.SIZE
                        )


                    if (
                        sizeIndex >= 0 &&
                        !cursor.isNull(sizeIndex)
                    ) {

                        val size =
                            cursor.getLong(
                                sizeIndex
                            )


                        if (
                            size >= 0
                        ) {

                            return size
                        }
                    }
                }
            }

        } catch (e: Exception) {

            Log.w(
                "BelnetLibPlugin",
                "Unable to get file size from metadata",
                e
            )
        }


        /*
         * Second attempt:
         * AssetFileDescriptor
         */
        try {

            context.contentResolver
                .openAssetFileDescriptor(
                    uri,
                    "r"
                )
                ?.use { descriptor ->

                    if (
                        descriptor.length >= 0
                    ) {

                        return descriptor.length
                    }
                }

        } catch (e: Exception) {

            Log.w(
                "BelnetLibPlugin",
                "Unable to get AssetFileDescriptor size",
                e
            )
        }


        /*
         * -1 means the provider did not expose
         * the file size.
         *
         * copyUriToCache() will then enforce
         * the limit while copying.
         */
        return -1L
    }


    // ============================================================
    // FILE SIZE FORMAT
    // ============================================================

    private fun formatFileSize(
        bytes: Long
    ): String {

        return when {

            bytes >=
                    1024L * 1024L -> {

                String.format(
                    "%.2f MB",
                    bytes.toDouble() /
                            (
                                1024L *
                                        1024L
                            )
                )
            }


            bytes >= 1024L -> {

                String.format(
                    "%.2f KB",
                    bytes.toDouble() /
                            1024L
                )
            }


            else -> {

                "$bytes B"
            }
        }
    }


    // ============================================================
    // MAX SIZE FORMAT
    // ============================================================

    private fun formatMaxSize(
        maxBytes: Long
    ): String {

        return if (
            maxBytes %
                    (
                        1024L *
                                1024L
                    ) == 0L
        ) {

            "${maxBytes / (1024L * 1024L)} MB"

        } else {

            formatFileSize(
                maxBytes
            )
        }
    }


    // ============================================================
    // TOAST
    // ============================================================

    private fun showToast(
        message: String
    ) {

        Handler(
            Looper.getMainLooper()
        ).post {

            Toast.makeText(
                context,
                message,
                Toast.LENGTH_LONG
            ).show()
        }
    }


    // ============================================================
    // GET FILE EXTENSION
    // ============================================================

    private fun getFileExtension(
        uri: Uri,
        mimeType: String?,
        isImage: Boolean
    ): String {

        when (mimeType) {

            "image/jpeg" ->
                return "jpg"

            "image/png" ->
                return "png"

            "image/webp" ->
                return "webp"

            "image/gif" ->
                return "gif"

            "image/heic" ->
                return "heic"

            "image/heif" ->
                return "heif"


            "application/pdf" ->
                return "pdf"


            "text/plain" ->
                return "txt"


            "text/csv" ->
                return "csv"


            "application/msword" ->
                return "doc"


            "application/vnd.openxmlformats-officedocument.wordprocessingml.document" ->
                return "docx"


            "application/vnd.ms-excel" ->
                return "xls"


            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" ->
                return "xlsx"


            "application/vnd.ms-powerpoint" ->
                return "ppt"


            "application/vnd.openxmlformats-officedocument.presentationml.presentation" ->
                return "pptx"
        }


        /*
         * Fallback to original filename.
         */

        val name =
            getDisplayName(uri)


        if (
            name != null &&
            name.contains(".")
        ) {

            return name
                .substringAfterLast(".")
                .lowercase()
                .take(10)
        }


        return if (isImage) {

            "jpg"

        } else {

            "file"
        }
    }


    // ============================================================
    // GET DISPLAY NAME
    // ============================================================

    private fun getDisplayName(
        uri: Uri
    ): String? {

        return try {

            context.contentResolver
                .query(
                    uri,
                    arrayOf(
                        android.provider.OpenableColumns.DISPLAY_NAME
                    ),
                    null,
                    null,
                    null
                )
                ?.use { cursor ->

                    if (
                        cursor.moveToFirst()
                    ) {

                        val index =
                            cursor.getColumnIndex(
                                android.provider.OpenableColumns.DISPLAY_NAME
                            )


                        if (
                            index >= 0
                        ) {

                            return cursor.getString(
                                index
                            )
                        }
                    }


                    null
                }

        } catch (e: Exception) {

            Log.e(
                "BelnetLibPlugin",
                "Unable to get display name",
                e
            )

            null
        }
    }


    // ============================================================
    // CLEAR PICKER
    // ============================================================

    private fun clearAttachmentPicker() {

        attachmentPickerResult =
            null

        attachmentPickerType =
            null

        attachmentPickerMax =
            MAX_ATTACHMENTS
    }


    // ============================================================
    // OPEN IMAGE PICKER
    // ============================================================

    private fun openImagePicker(
        maxImages: Int
    ) {

        val currentActivity =
            activityBinding.activity


        if (
            Build.VERSION.SDK_INT >=
            Build.VERSION_CODES.TIRAMISU
        ) {

            try {

                val intent =
                    Intent(
                        MediaStore.ACTION_PICK_IMAGES
                    )


                intent.type =
                    "image/*"


                intent.putExtra(
                    Intent.EXTRA_ALLOW_MULTIPLE,
                    true
                )


                intent.putExtra(
                    MediaStore.EXTRA_PICK_IMAGES_MAX,
                    maxImages
                )


                if (
                    Build.VERSION.SDK_INT >= 34
                ) {

                    intent.putExtra(
                        MediaStore.EXTRA_PICK_IMAGES_IN_ORDER,
                        true
                    )
                }


                currentActivity
                    .startActivityForResult(
                        intent,
                        PHOTO_PICKER_REQUEST_CODE
                    )

            } catch (e: Exception) {

                Log.e(
                    "BelnetLibPlugin",
                    "Failed to open Photo Picker",
                    e
                )


                attachmentPickerResult?.error(
                    "PHOTO_PICKER_ERROR",
                    e.message,
                    null
                )


                clearAttachmentPicker()
            }

        } else {

            openLegacyImagePicker()
        }
    }


    // ============================================================
    // LEGACY IMAGE PICKER
    // ============================================================

    private fun openLegacyImagePicker() {

        try {

            val intent =
                Intent(
                    Intent.ACTION_OPEN_DOCUMENT
                )


            intent.type =
                "image/*"


            intent.putExtra(
                Intent.EXTRA_ALLOW_MULTIPLE,
                true
            )


            intent.addCategory(
                Intent.CATEGORY_OPENABLE
            )


            activityBinding.activity
                .startActivityForResult(
                    intent,
                    PHOTO_PICKER_REQUEST_CODE
                )

        } catch (e: Exception) {

            Log.e(
                "BelnetLibPlugin",
                "Failed to open legacy image picker",
                e
            )


            attachmentPickerResult?.error(
                "IMAGE_PICKER_ERROR",
                e.message,
                null
            )


            clearAttachmentPicker()
        }
    }


    // ============================================================
    // FILE PICKER
    // ============================================================

    private fun openFilePicker() {

        try {

            val intent =
                Intent(
                    Intent.ACTION_OPEN_DOCUMENT
                )


            intent.type =
                "*/*"


            intent.putExtra(
                Intent.EXTRA_ALLOW_MULTIPLE,
                true
            )


            intent.addCategory(
                Intent.CATEGORY_OPENABLE
            )


            activityBinding.activity
                .startActivityForResult(
                    intent,
                    FILE_PICKER_REQUEST_CODE
                )

        } catch (e: Exception) {

            Log.e(
                "BelnetLibPlugin",
                "Failed to open file picker",
                e
            )


            attachmentPickerResult?.error(
                "FILE_PICKER_ERROR",
                e.message,
                null
            )


            clearAttachmentPicker()
        }
    }


    // ============================================================
    // SAVE IMAGE TO GALLERY
    // ============================================================

    private fun saveImageToGallery(
        imageBytes: ByteArray,
        fileName: String
    ): String? {

        return try {

            val resolver =
                context.contentResolver


            val values =
                ContentValues().apply {

                    put(
                        MediaStore.Images.Media.DISPLAY_NAME,
                        fileName
                    )


                    put(
                        MediaStore.Images.Media.MIME_TYPE,
                        "image/png"
                    )


                    put(
                        MediaStore.Images.Media.RELATIVE_PATH,
                        Environment.DIRECTORY_PICTURES +
                                "/Beldex Browser/AI Images"
                    )


                    if (
                        Build.VERSION.SDK_INT >=
                        Build.VERSION_CODES.Q
                    ) {

                        put(
                            MediaStore.Images.Media.IS_PENDING,
                            1
                        )
                    }
                }


            val collection =

                if (
                    Build.VERSION.SDK_INT >=
                    Build.VERSION_CODES.Q
                ) {

                    MediaStore.Images.Media
                        .getContentUri(
                            MediaStore.VOLUME_EXTERNAL_PRIMARY
                        )

                } else {

                    MediaStore.Images.Media
                        .EXTERNAL_CONTENT_URI
                }


            val imageUri =
                resolver.insert(
                    collection,
                    values
                )
                    ?: throw Exception(
                        "Failed to create MediaStore entry"
                    )


            try {

                resolver
                    .openOutputStream(
                        imageUri
                    )
                    ?.use { outputStream ->

                        outputStream.write(
                            imageBytes
                        )

                        outputStream.flush()
                    }
                    ?: throw Exception(
                        "Failed to open image output stream"
                    )


                if (
                    Build.VERSION.SDK_INT >=
                    Build.VERSION_CODES.Q
                ) {

                    val completedValues =
                        ContentValues().apply {

                            put(
                                MediaStore.Images.Media.IS_PENDING,
                                0
                            )
                        }


                    resolver.update(
                        imageUri,
                        completedValues,
                        null,
                        null
                    )
                }


                Log.d(
                    "BelnetLibPlugin",
                    "Image saved to Gallery: $imageUri"
                )


                imageUri.toString()

            } catch (e: Exception) {

                resolver.delete(
                    imageUri,
                    null,
                    null
                )

                throw e
            }

        } catch (e: Exception) {

            Log.e(
                "BelnetLibPlugin",
                "Failed to save image to Gallery",
                e
            )

            null
        }
    }


    // ============================================================
    // TTS AUDIO PATH
    // ============================================================

    private fun getTtsAudioPath(
        fileName: String
    ): String? {

        return try {

            val outputFile =
                File(
                    context.cacheDir,
                    fileName
                )


            val collection =
                MediaStore.Audio.Media
                    .EXTERNAL_CONTENT_URI


            val projection =
                arrayOf(
                    MediaStore.Audio.Media._ID,
                    MediaStore.Audio.Media.DISPLAY_NAME
                )


            val selection =
                "${MediaStore.Audio.Media.DISPLAY_NAME} = ?"


            val selectionArgs =
                arrayOf(
                    fileName
                )


            var copied =
                false


            context.contentResolver
                .query(
                    collection,
                    projection,
                    selection,
                    selectionArgs,
                    "${MediaStore.Audio.Media.DATE_ADDED} DESC"
                )
                ?.use { cursor ->

                    if (
                        cursor.moveToFirst()
                    ) {

                        val idIndex =
                            cursor.getColumnIndex(
                                MediaStore.Audio.Media._ID
                            )


                        if (
                            idIndex >= 0
                        ) {

                            val id =
                                cursor.getLong(
                                    idIndex
                                )


                            val contentUri =
                                ContentUris.withAppendedId(
                                    collection,
                                    id
                                )


                            context.contentResolver
                                .openInputStream(
                                    contentUri
                                )
                                ?.use { input ->

                                    FileOutputStream(
                                        outputFile
                                    ).use { output ->

                                        input.copyTo(
                                            output
                                        )
                                    }


                                    copied =
                                        true
                                }


                            /*
                             * flutter_tts wrote this WAV into the
                             * shared Music collection, where other
                             * apps can read it. We have our private
                             * copy now, so remove the shared one.
                             */
                            try {
                                context.contentResolver.delete(
                                    contentUri,
                                    null,
                                    null
                                )
                            } catch (e: Exception) {
                                Log.w(
                                    "BelnetLibPlugin",
                                    "Could not delete shared TTS copy",
                                    e
                                )
                            }
                        }
                    }
                }


            if (
                copied &&
                outputFile.exists()
            ) {

                val fileSize =
                    outputFile.length()


                if (
                    fileSize > 0
                ) {

                    outputFile.absolutePath

                } else {

                    outputFile.delete()

                    null
                }

            } else {

                null
            }

        } catch (e: Exception) {

            Log.e(
                "BelnetLibPlugin",
                "Failed to copy generated TTS audio",
                e
            )

            null
        }
    }
}














// package io.beldex.belnet_lib

// import android.annotation.SuppressLint
// import android.app.Activity.RESULT_OK
// import android.app.Notification
// import android.app.NotificationChannel
// import android.app.NotificationManager
// import android.content.ComponentName
// import android.content.Context
// import android.content.Intent
// import android.net.TrafficStats
// import android.net.VpnService
// import android.os.IBinder
// import android.os.SystemClock
// import android.provider.Settings
// import android.util.Log
// import androidx.annotation.NonNull
// import androidx.lifecycle.Lifecycle
// import androidx.lifecycle.LifecycleOwner
// import androidx.lifecycle.MutableLiveData
// import androidx.lifecycle.Observer
// import io.flutter.embedding.engine.plugins.FlutterPlugin
// import io.flutter.embedding.engine.plugins.activity.ActivityAware
// import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
// import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference
// import io.flutter.plugin.common.EventChannel
// import io.flutter.plugin.common.MethodCall
// import io.flutter.plugin.common.MethodChannel
// import io.flutter.plugin.common.MethodChannel.MethodCallHandler
// import io.flutter.plugin.common.PluginRegistry
// import network.beldex.belnet.BelnetDaemon
// import network.beldex.belnet.ConnectionTools
// import androidx.core.content.ContextCompat
// import org.json.JSONObject
// import kotlin.math.roundToLong

// import android.content.ServiceConnection

// import android.view.WindowManager
// import android.app.Activity






// import android.content.*
// import android.media.AudioAttributes
// import android.media.AudioFocusRequest
// import android.media.AudioManager
// import android.os.Build
// import android.os.Looper
// import android.os.Handler




// import android.view.WindowManager
// import android.widget.Toast




// import android.content.BroadcastReceiver
// import android.content.IntentFilter
// import android.telephony.TelephonyManager


// /** BelnetLibPlugin */
// open class BelnetLibPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

//     // ============================================================
//     // CONSTANTS
//     // ============================================================

//     companion object {

//         private const val PHOTO_PICKER_REQUEST_CODE = 5001
//         private const val FILE_PICKER_REQUEST_CODE = 5002

//         private const val MAX_ATTACHMENTS = 10

//         // --------------------------------------------------------
//         // FILE SIZE LIMITS
//         // --------------------------------------------------------

//         // Image = 5 MB
//         private const val MAX_IMAGE_SIZE =
//             5L * 1024L * 1024L

//         // TXT / CSV = 5 MB
//         private const val MAX_TEXT_SIZE =
//             5L * 1024L * 1024L

//         // PDF / DOC / DOCX = 10 MB
//         private const val MAX_DOCUMENT_SIZE =
//             10L * 1024L * 1024L

//         // XLS / XLSX = 10 MB
//         private const val MAX_SPREADSHEET_SIZE =
//             10L * 1024L * 1024L

//         /*
//          * Fallback for an unknown extension.
//          *
//          * Since your picker currently allows all files,
//          * keep a 10 MB safety limit for unknown files.
//          */
//         private const val MAX_UNKNOWN_FILE_SIZE =
//             10L * 1024L * 1024L
//     }

//     private var mShouldUnbind: Boolean = false
//     private var mBoundService: BelnetDaemon? = null
//     private var lastTimestamp = 0L
//     private lateinit var activityBinding: ActivityPluginBinding
//    private lateinit var lifecycleOwner: LifecycleOwner

//     private var activity: Activity? = null

//     private var sessionDownloaded = 0L
//     private var sessionUploaded = 0L
//     private var lastTotalDownload = 0L
//     private var lastTotalUpload = 0L
//     private var sessionStart = 0L
//     private var logData: String = ""
//     lateinit var notificationManager: NotificationManager
//     lateinit var notificationChannel: NotificationChannel
//     lateinit var builder: Notification.Builder
//     lateinit var myD: String
//     var mutableString: MutableLiveData<String> = MutableLiveData()

//     private lateinit var mMethodChannel: MethodChannel
//     private lateinit var mIsConnectedEventChannel: EventChannel

//     private var mEventSink: EventChannel.EventSink? = null



//     // Ported from belnet-app commit df16d27 (audit F4): underlying-network
//     // change events forwarded from BelnetDaemon to the Flutter layer.
//     private lateinit var networkChangeEventChannel: EventChannel
//     private var networkChangeEventSink: EventChannel.EventSink? = null
//     private var networkChangeReceiver: BroadcastReceiver? = null

//     // Ported from belnet-app commit df16d27 (audit F9): consolidated 1 Hz
//     // status feed - one GetStatus() JNI call and one TrafficStats sample per
//     // second, pushed to Dart.
//     private lateinit var statusEventChannel: EventChannel
//     private var statusEventSink: EventChannel.EventSink? = null
//     private var statusHandler: Handler? = null
//     private var statusRunnable: Runnable? = null
//     private val speedMeter = SpeedMeter()

//     private lateinit var notificationDisconnectEventChannel: EventChannel

//      private lateinit var notificationDisconnectReceiver: BroadcastReceiver
//      private var disconnectEventSink: EventChannel.EventSink? = null


//   // Audio Focus
//     private var focusRequest: AudioFocusRequest? = null
//     private var audioFocusChangeListener: AudioManager.OnAudioFocusChangeListener? = null
//     private lateinit var context: Context
//     private lateinit var messenger: io.flutter.plugin.common.BinaryMessenger




//     private var mIsConnectedObserver = Observer<Boolean> { newIsConnected ->
//         mEventSink?.success(newIsConnected)
//     }


// // 📞 Call & audio route broadcast receiver
//     private val callReceiver = object : BroadcastReceiver() {
//         override fun onReceive(context: Context?, intent: Intent?) {
//             when (intent?.action) {
//                 AudioManager.ACTION_SCO_AUDIO_STATE_UPDATED -> {
//                     val state = intent.getIntExtra(AudioManager.EXTRA_SCO_AUDIO_STATE, -1)
//                     if (state == AudioManager.SCO_AUDIO_STATE_CONNECTED ||
//                         state == AudioManager.SCO_AUDIO_STATE_CONNECTING
//                     ) {
//                         Log.d("CallState", " SCO audio active — stopping TTS.")
//                         sendFocusEventToFlutter("focusLost")
//                     }
//                 }

//                 AudioManager.ACTION_AUDIO_BECOMING_NOISY -> {
//                     Log.d("CallState", " Headphones unplugged / route changed.")
//                     //sendFocusEventToFlutter("audio_noisy")
//                 }

//                 TelephonyManager.ACTION_PHONE_STATE_CHANGED -> {
//                     val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
//                     if (state == TelephonyManager.EXTRA_STATE_RINGING ||
//                         state == TelephonyManager.EXTRA_STATE_OFFHOOK
//                     ) {
//                         Log.d("CallState", " Incoming or ongoing phone call — stop TTS.")
//                         sendFocusEventToFlutter("focusLost")
//                     }
//                 }
//             }
//         }
//     }











//     override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
//         System.loadLibrary("belnet-android")


//           context = binding.applicationContext
//          messenger = binding.binaryMessenger



//         mMethodChannel = MethodChannel(binding.binaryMessenger, "belnet_lib_method_channel")
//         mMethodChannel.setMethodCallHandler(this)

//         mIsConnectedEventChannel =
//             EventChannel(binding.binaryMessenger, "belnet_lib_is_connected_event_channel")
//         mIsConnectedEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
//             override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
//                 mEventSink = events
//             }

//             override fun onCancel(arguments: Any?) {
//                 mEventSink?.endOfStream()
//                 mEventSink = null
//             }
//         })



//     notificationDisconnectEventChannel = EventChannel(binding.binaryMessenger, "belnet_lib_notification_disconnect_event_channel")
//         notificationDisconnectEventChannel.setStreamHandler(
//             object : EventChannel.StreamHandler {
//                 override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
//                     disconnectEventSink = events
//                     notificationDisconnectReceiver = object : BroadcastReceiver() {
//                         override fun onReceive(context: Context?, intent: Intent?) {
//                             if (intent?.action == "com.belnet.NOTIFICATION_DISCONNECTED") {
//                                 Log.d("BelnetLibPlugin", "Received notification disconnect broadcast")
//                                 disconnectEventSink?.success("notification_disconnect")
//                             }
//                         }
//                     }
//                     val filter = IntentFilter("com.belnet.NOTIFICATION_DISCONNECTED")
//                     context.registerReceiver(notificationDisconnectReceiver, filter)
//                 }

//                 override fun onCancel(arguments: Any?) {
//                     disconnectEventSink = null
//                     try {
//                         notificationDisconnectReceiver?.let {
//                             context.unregisterReceiver(it)
//                         }
//                     } catch (e: Exception) {
//                         Log.e("BelnetLibPlugin", "Receiver already unregistered: ${e.message}")
//                     }
//                 }
//             }
//         )




//     // Ported from belnet-app commit df16d27 (audit F4): underlying-network
//         // change events from BelnetDaemon (Wi-Fi <-> mobile handover). The
//         // Flutter side uses this to run an immediate tunnel health probe
//         // instead of waiting for the next periodic one.
//         networkChangeEventChannel =
//             EventChannel(binding.binaryMessenger, "belnet_lib_network_change_event_channel")
//         networkChangeEventChannel.setStreamHandler(
//             object : EventChannel.StreamHandler {
//                 override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
//                     networkChangeEventSink = events
//                     networkChangeReceiver = object : BroadcastReceiver() {
//                         override fun onReceive(ctx: Context?, intent: Intent?) {
//                             if (intent?.action == BelnetDaemon.ACTION_NETWORK_CHANGED) {
//                                 Log.d("BelnetLibPlugin", "Received network change broadcast")
//                                 networkChangeEventSink?.success("network_changed")
//                             }
//                         }
//                     }
//                     val filter = IntentFilter(BelnetDaemon.ACTION_NETWORK_CHANGED)
//                     ContextCompat.registerReceiver(
//                         context,
//                         networkChangeReceiver,
//                         filter,
//                         ContextCompat.RECEIVER_NOT_EXPORTED
//                     )
//                 }

//                 override fun onCancel(arguments: Any?) {
//                     networkChangeEventSink = null
//                     try {
//                         networkChangeReceiver?.let { context.unregisterReceiver(it) }
//                     } catch (e: Exception) {
//                         Log.e("BelnetLibPlugin", "network change receiver already unregistered: ${e.message}")
//                     }
//                     networkChangeReceiver = null
//                 }
//             }
//         )

//         // Ported from belnet-app commit df16d27 (audit F9): consolidated
//         // status feed - one 1 Hz tick doing ONE GetStatus() JNI call and ONE
//         // TrafficStats sample, pushed to Dart. Replaces independent Dart
//         // timers each crossing the platform channel every 1-2 seconds.
//         statusEventChannel =
//             EventChannel(binding.binaryMessenger, "belnet_lib_status_event_channel")
//         statusEventChannel.setStreamHandler(
//             object : EventChannel.StreamHandler {
//                 override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
//                     statusEventSink = events
//                     statusHandler = Handler(Looper.getMainLooper())
//                     statusRunnable = object : Runnable {
//                         override fun run() {
//                             emitStatus()
//                             statusHandler?.postDelayed(this, 1000)
//                         }
//                     }
//                     statusHandler?.post(statusRunnable!!)
//                 }

//                 override fun onCancel(arguments: Any?) {
//                     statusRunnable?.let { statusHandler?.removeCallbacks(it) }
//                     statusRunnable = null
//                     statusHandler = null
//                     statusEventSink = null
//                 }
//             }
//         )






//         // Audio phone call
//         registerCallAndAudioReceivers()
//     }

//     private fun emitStatus() {
//         val sink = statusEventSink ?: return
//         val speeds = speedMeter.sample()
//         val payload = JSONObject()
//         try {
//             // getStatusSafe(): GetStatus() (belnet-app df16d27) with an
//             // automatic DumpStatus() fallback if the native lib doesn't
//             // export the GetStatus JNI symbol.
//             val raw = mBoundService?.getStatusSafe()
//             payload.put(
//                 "status",
//                 if (raw.isNullOrEmpty()) JSONObject.NULL else JSONObject(raw)
//             )
//         } catch (e: Exception) {
//             payload.put("status", JSONObject.NULL)
//         }
//         payload.put("upload", speeds.first)
//         payload.put("download", speeds.second)
//         payload.put("isRunning", mBoundService?.IsRunning() ?: false)
//         sink.success(payload.toString())
//     }

//     /**
//      * Ported from belnet-app commit df16d27 (audit F9): device-level
//      * throughput sampling shared by the status feed. Values are halved
//      * because with the VPN active TrafficStats counts every payload byte
//      * twice (once on the tun device, once on the physical interface).
//      */
//     private class SpeedMeter {
//         private var lastTimestamp = 0L
//         private var lastRx = 0L
//         private var lastTx = 0L

//         /** Returns Pair(uploadBytesPerSec, downloadBytesPerSec). */
//         fun sample(): Pair<Long, Long> {
//             val now = SystemClock.elapsedRealtime()
//             val rx = TrafficStats.getTotalRxBytes()
//             val tx = TrafficStats.getTotalTxBytes()
//             if (lastTimestamp == 0L) {
//                 lastTimestamp = now
//                 lastRx = rx
//                 lastTx = tx
//                 return Pair(0L, 0L)
//             }
//             val dt = (now - lastTimestamp) / 1000f
//             if (dt <= 0f) return Pair(0L, 0L)
//             val up = (((tx - lastTx).coerceAtLeast(0) / 2) / dt).roundToLong()
//             val down = (((rx - lastRx).coerceAtLeast(0) / 2) / dt).roundToLong()
//             lastTimestamp = now
//             lastRx = rx
//             lastTx = tx
//             return Pair(up, down)
//         }
//     }

//     override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
//         mMethodChannel.setMethodCallHandler(null)
//         // Ported from belnet-app commit df16d27: stop the 1 Hz status ticker
//         // and unregister the network-change receiver so nothing leaks across
//         // engine restarts.
//         statusRunnable?.let { statusHandler?.removeCallbacks(it) }
//         statusRunnable = null
//         statusHandler = null
//         statusEventSink = null
//         try {
//             networkChangeReceiver?.let { context.unregisterReceiver(it) }
//             notificationDisconnectReceiver?.let {context.unregisterReceiver(it) }

//         } catch (e: Exception) {
//             Log.w("BelnetLibPlugin", "network change receiver already unregistered: ${e.message}")
//         }
//         networkChangeReceiver = null
//         networkChangeEventSink = null
//         doUnbindService()
//         unregisterReceivers()
//     }


// private fun registerCallAndAudioReceivers() {
//         val filter = IntentFilter().apply {
//             addAction(AudioManager.ACTION_SCO_AUDIO_STATE_UPDATED)
//             //addAction(AudioManager.ACTION_AUDIO_BECOMING_NOISY)
//             addAction(TelephonyManager.ACTION_PHONE_STATE_CHANGED)
//         }
//         context.registerReceiver(callReceiver, filter)
//     }

//     private fun unregisterReceivers() {
//         try {
//             context.unregisterReceiver(callReceiver)
//         } catch (e: Exception) {
//             Log.w("CelnetLibPlugin", "Receiver already unregistered or not initialized.")
//         }
//     }



// // ============================================================
//     // ATTACHMENT ACTIVITY RESULT
//     // ============================================================

//     private val attachmentActivityResultListener =
//         PluginRegistry.ActivityResultListener {

//                 requestCode,
//                 resultCode,
//                 data ->

//             if (
//                 requestCode !=
//                 PHOTO_PICKER_REQUEST_CODE &&

//                 requestCode !=
//                 FILE_PICKER_REQUEST_CODE
//             ) {

//                 return@ActivityResultListener false
//             }


//             handleAttachmentResult(
//                 requestCode,
//                 resultCode,
//                 data
//             )


//             true
//         }







//     @SuppressLint("NewApi")
//     override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
//         when (call.method) {
//             "prepare" -> {
//                 val intent = VpnService.prepare(activityBinding.activity.applicationContext)
//                 if (intent != null) {
//                     var listener: PluginRegistry.ActivityResultListener? = null
//                     listener = PluginRegistry.ActivityResultListener { req, res, _ ->
//                         if (req == 0 && res == RESULT_OK) {
//                             result.success(true)
//                         } else {
//                             result.success(false)
//                         }
//                         listener?.let { activityBinding.removeActivityResultListener(it) }
//                         true
//                     }
//                     activityBinding.addActivityResultListener(listener)
//                     activityBinding.activity.startActivityForResult(intent, 0)
//                 } else {
//                     result.success(true)
//                 }
//             }

//             "isPrepared" -> {
//                 val intent = VpnService.prepare(activityBinding.activity.applicationContext)
//                 result.success(intent == null)
//             }

//             "connect" -> {
//                 val intent = VpnService.prepare(activityBinding.activity.applicationContext)
//                 if (intent != null) {
//                     result.success(false)
//                     return
//                 }

//                 val exitNode = call.argument<String>("exit_node")
//                 val upstreamDNS = call.argument<String>("upstream_dns")
//                 // Ported from belnet-app commit df16d27 (audit F5/F12/F13).
//                 val logLevel = call.argument<String>("log_level")
//                 val mtu = call.argument<Int>("mtu")
//                 val routeIpv6 = call.argument<Boolean>("route_ipv6")



//                 val belnetIntent = Intent(activityBinding.activity.applicationContext, BelnetDaemon::class.java)
//                 belnetIntent.action = BelnetDaemon.ACTION_CONNECT
//                 belnetIntent.putExtra(BelnetDaemon.EXIT_NODE, exitNode)
//                 belnetIntent.putExtra(BelnetDaemon.UPSTREAM_DNS, upstreamDNS)
//                 belnetIntent.putExtra(BelnetDaemon.LOG_LEVEL, logLevel ?: "warn")
//                 belnetIntent.putExtra(BelnetDaemon.MTU, mtu ?: 1400)
//                 belnetIntent.putExtra(BelnetDaemon.ROUTE_IPV6, routeIpv6 ?: true)

//                 activityBinding.activity.applicationContext.startService(belnetIntent)
//                 doBindService()
//                 result.success(true)
//             }

//             "disconnect" -> {
//                 // val intent = VpnService.prepare(activityBinding.activity.applicationContext)
//                 // if (intent != null) {
//                 //     result.success(false)
//                 //     return
//                 // }

//                 // val belnetIntent = Intent(activityBinding.activity.applicationContext, BelnetDaemon::class.java)
//                 // belnetIntent.action = BelnetDaemon.ACTION_DISCONNECT

//                 // activityBinding.activity.applicationContext.startService(belnetIntent)
//                 // doUnbindService()
//                 // Log.d("Test", "inside disconnect function")
//                 // result.success(true)
//                   val ctx = activityBinding.activity.applicationContext
//                 val belnetIntent = Intent(ctx, BelnetDaemon::class.java).apply {
//                     action = BelnetDaemon.ACTION_DISCONNECT
//                 }
//                 ctx.startService(belnetIntent)
//                 doBindService()
//                 Log.d("BelnetLibPlugin", "Disconnect called")
//                 result.success(true)
//             }

//             "isRunning" -> {
//                 result.success(mBoundService?.IsRunning() ?: false)
//             }

//             "getStatus" -> {
//                  // Ported from belnet-app commit df16d27 (audit F9): return
//                 // null (not false) when unbound so the Dart layer never
//                 // crashes on a bool-to-String cast.
//                 result.success(mBoundService?.DumpStatus())
//             }

//             "getUploadSpeed" -> {
//                 val timestamp = SystemClock.elapsedRealtime()
//                 val elapsedMillis = timestamp - lastTimestamp
//                 val elapsedSeconds = elapsedMillis / 1000f
//                 val totalUpload = TrafficStats.getTotalTxBytes()
//                 val uploaded = (totalUpload - lastTotalUpload).coerceAtLeast(0) / 2
//                 val uploadSpeed = (uploaded / elapsedSeconds).roundToLong()
//                 sessionUploaded += uploaded

//                 val uploadString = ConnectionTools.bytesToSize(uploadSpeed) + "ps"
//                 result.success(uploadString)

//                 lastTotalUpload = totalUpload
//                 lastTimestamp = timestamp
//             }

//             "getDownloadSpeed" -> {
//                 val timestamp = SystemClock.elapsedRealtime()
//                 val elapsedMillis = timestamp - lastTimestamp
//                 val elapsedSeconds = elapsedMillis / 1000f
//                 val totalDownload = TrafficStats.getTotalRxBytes()
//                 val totalUpload = TrafficStats.getTotalTxBytes()
//                 val downloaded = (totalDownload - lastTotalDownload).coerceAtLeast(0) / 2
//                 val uploaded = (totalUpload - lastTotalUpload).coerceAtLeast(0) / 2
//                 val downloadSpeed = (downloaded / elapsedSeconds).roundToLong()
//                 val uploadSpeed = (uploaded / elapsedSeconds).roundToLong()

//                 sessionDownloaded += downloaded
//                 sessionUploaded += uploaded

//                 val downloadString = ConnectionTools.bytesToSize(downloadSpeed) + "ps"
//                 Log.d("TagDownload", "This is downloadString$downloadString")
//                 result.success(downloadString)

//                 lastTotalDownload = totalDownload
//                 lastTotalUpload = totalUpload
//                 lastTimestamp = timestamp
//             }

//             "getDataStatus" -> {
//                 // Ported from belnet-app commit df16d27 (audit F9): this was
//                 // a stub returning `false`. Used by the Dart-side status
//                 // consumers; must return null (never `false`) when the
//                 // service is not bound so callers keep polling instead of
//                 // crashing on a cast.
//                 val service = mBoundService
//                 if (service == null) {
//                     Log.w("BelnetLibPlugin", "getDataStatus: Service not bound yet")
//                     result.success(null)
//                     return
//                 }
//                 try {
//                     // getStatusSafe(): GetStatus() (belnet-app df16d27)
//                     // with automatic DumpStatus() fallback.
//                     result.success(service.getStatusSafe())
//                 } catch (e: Exception) {
//                     Log.e("BelnetLibPlugin", "Exception in getDataStatus", e)
//                     result.success(null)
//                 }
//             }

//             "getMap" -> {
//                val swapNode = call.argument<String>("swap_node")
//                 val service = mBoundService
//                 if (service == null || swapNode == null) {
//                     // Ported from belnet-app commit df16d27: also guard a
//                     // null swap_node argument.
//                     Log.w("BelnetLibPlugin", "getMap: service not bound or no swap_node")
//                     result.success(null)
//                 } else {
//                     // Deliver the REAL remap result asynchronously; the old
//                     // code returned a stale field before the worker finished.
//                     // The `replied` flag (belnet-app) protects against a
//                     // double result.success() if the callback ever fires
//                     // twice, which crashes the method channel.
//                     var replied = false
//                     service.unmappingNode(swapNode) { r ->
//                         if (!replied) {
//                             replied = true
//                             result.success(r)
//                         }
//                     }
//                 }
//             }

//             "isExitReady" -> {
//                 result.success(mBoundService?.isExitReady() ?: false)
//             }

//             "getUnmapStatus" -> {
//                 result.success(mBoundService?.Status() ?: false)
//             }

//             "setDefaultBrowser" -> {
//                 val intent = Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS)
//                 activityBinding.activity.startActivityForResult(intent, 0)
//                 result.success(true)
//             }

//             "disconnectForNotification" -> {
//                 result.success(mBoundService != null)
//             }
//              "enableSecure" -> {
//                     // activityBinding.activity.window.setFlags(
//                     //     WindowManager.LayoutParams.FLAG_SECURE,
//                     //     WindowManager.LayoutParams.FLAG_SECURE
//                     // )
//                     // Log.d("Test", "ENABLEDDDDDDDD SCREEN")
//                     // result.success(true)


//                      try {
//                             println("Enabling screen security")
//                              activityBinding.activity.window.setFlags(
//                                 WindowManager.LayoutParams.FLAG_SECURE,
//                                 WindowManager.LayoutParams.FLAG_SECURE
//                             )
//                             result.success(true)
//                         } catch (e: Exception) {
//                             println("Error enabling screen security: ${e.message}")
//                             result.error("SCREEN_SECURITY_ERROR", "Failed to enable screen security", e.message)
//                         }
//                 }
//                 "disableSecure" -> {
//                     try {
//                             println("Disabling screen security")
//                             activityBinding.activity.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
//                             result.success(true)
//                         } catch (e: Exception) {
//                             println("Error disabling screen security: ${e.message}")
//                             result.error("SCREEN_SECURITY_ERROR", "Failed to disable screen security", e.message)
//                         }
//                 }
//              "requestAudioFocus" -> {
//                 requestAudioFocus()
//                 result.success(true)
//             }
//             "abandonAudioFocus" -> {
//                 abandonAudioFocus()
//                 result.success(true)
//             }
//             "isCallActive" -> {
                
//                 result.success(isCallActive())
//             }



//        "pickMultipleImages" -> {

//                 if (
//                     attachmentPickerResult != null
//                 ) {

//                     result.error(
//                         "PICKER_ALREADY_OPEN",
//                         "An attachment picker is already open.",
//                         null
//                     )

//                     return
//                 }


//                 val requestedMax =
//                     call.argument<Int>(
//                         "maxImages"
//                     )
//                         ?: MAX_ATTACHMENTS


//                 attachmentPickerMax =
//                     requestedMax.coerceIn(
//                         1,
//                         MAX_ATTACHMENTS
//                     )


//                 attachmentPickerResult =
//                     result


//                 attachmentPickerType =
//                     "image"


//                 openImagePicker(
//                     attachmentPickerMax
//                 )
//             }


//             // ====================================================
//             // PICK MULTIPLE FILES
//             // ====================================================

//             "pickMultipleFiles" -> {

//                 if (
//                     attachmentPickerResult != null
//                 ) {

//                     result.error(
//                         "PICKER_ALREADY_OPEN",
//                         "An attachment picker is already open.",
//                         null
//                     )

//                     return
//                 }


//                 val requestedMax =
//                     call.argument<Int>(
//                         "maxFiles"
//                     )
//                         ?: MAX_ATTACHMENTS


//                 attachmentPickerMax =
//                     requestedMax.coerceIn(
//                         1,
//                         MAX_ATTACHMENTS
//                     )


//                 attachmentPickerResult =
//                     result


//                 attachmentPickerType =
//                     "file"


//                 openFilePicker()
//             }


//             // ====================================================
//             // SAVE IMAGE TO GALLERY
//             // ====================================================

//             "saveImageToGallery" -> {

//                 try {

//                     val base64Image =
//                         call.argument<String>(
//                             "base64Image"
//                         )


//                     val fileName =
//                         call.argument<String>(
//                             "fileName"
//                         )
//                             ?: "AI_Image_${System.currentTimeMillis()}.png"


//                     if (
//                         base64Image.isNullOrEmpty()
//                     ) {

//                         result.error(
//                             "INVALID_IMAGE",
//                             "Base64 image is empty",
//                             null
//                         )

//                         return
//                     }


//                     val cleanBase64 =
//                         if (
//                             base64Image.contains(",")
//                         ) {

//                             base64Image
//                                 .substringAfter(",")

//                         } else {

//                             base64Image
//                         }


//                     val imageBytes =
//                         Base64.decode(
//                             cleanBase64,
//                             Base64.DEFAULT
//                         )


//                     val savedUri =
//                         saveImageToGallery(
//                             imageBytes,
//                             fileName
//                         )


//                     if (
//                         savedUri != null
//                     ) {

//                         result.success(
//                             mapOf(
//                                 "success" to true,
//                                 "uri" to savedUri,
//                                 "fileName" to fileName
//                             )
//                         )

//                     } else {

//                         result.error(
//                             "SAVE_FAILED",
//                             "Unable to save image to Gallery",
//                             null
//                         )
//                     }

//                 } catch (e: Exception) {

//                     Log.e(
//                         "BelnetLibPlugin",
//                         "saveImageToGallery error",
//                         e
//                     )

//                     result.error(
//                         "SAVE_FAILED",
//                         e.message,
//                         null
//                     )
//                 }
//             }











//             else -> result.notImplemented()
//         }
//     }


// private fun requestAudioFocus() {
//         val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager

//         audioFocusChangeListener = AudioManager.OnAudioFocusChangeListener { focusChange ->
//             when (focusChange) {
//                 AudioManager.AUDIOFOCUS_LOSS -> {
//                     Log.d("AudioFocus", "Permanent loss. Stop TTS.")
//                     sendFocusEventToFlutter("focusLost")
//                 }
//                 AudioManager.AUDIOFOCUS_LOSS_TRANSIENT,
//                 AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> {
//                     Log.d("AudioFocus", "Transient loss.")
//                     //sendFocusEventToFlutter("focusTransient")
//                 }
//                 AudioManager.AUDIOFOCUS_GAIN -> {
//                     Log.d("AudioFocus", "Focus regained. Resume TTS if paused.")
//                     //sendFocusEventToFlutter("focusGained")
//                 }
//             }
//         }

//         focusRequest = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//             AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE)
//                 .setAudioAttributes(
//                     AudioAttributes.Builder()
//                         .setUsage(AudioAttributes.USAGE_ASSISTANT)
//                         .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
//                         .build()
//                 )
//                 .setOnAudioFocusChangeListener(audioFocusChangeListener!!)
//                 .setWillPauseWhenDucked(true)
//                 .build()
//         } else null

//         val result = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && focusRequest != null) {
//             audioManager.requestAudioFocus(focusRequest!!)
//         } else {
//             @Suppress("DEPRECATION")
//             audioManager.requestAudioFocus(
//                 audioFocusChangeListener,
//                 AudioManager.STREAM_MUSIC,
//                 AudioManager.AUDIOFOCUS_GAIN_TRANSIENT
//             )
//         }

//         if (result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
//             Log.d("AudioFocus", " Focus granted")
//         }
//     }

//     private fun abandonAudioFocus() {
//         val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && focusRequest != null) {
//             audioManager.abandonAudioFocusRequest(focusRequest!!)
//         } else {
//             @Suppress("DEPRECATION")
//             audioManager.abandonAudioFocus(audioFocusChangeListener)
//         }
//     }

//     private fun sendFocusEventToFlutter(event: String) {
//         Handler(Looper.getMainLooper()).post {
//             MethodChannel(messenger, "belnet_lib_method_channel").invokeMethod("focusLost", null)
//         }
//     }


// @SuppressLint("MissingPermission")
// private fun isCallActive(): Boolean {
//     try {
//         val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
//         val state = telephonyManager.callState
//         if (state == TelephonyManager.CALL_STATE_OFFHOOK || state == TelephonyManager.CALL_STATE_RINGING) {
//             Log.d("CallState", "📞 Regular phone call active or ringing")
//             return true
//         }
//     } catch (e: Exception) {
//         Log.e("CallState", "Error checking call state: ${e.message}")
//     }

//     // --- Optional: detect ongoing VoIP (e.g., WhatsApp, Zoom) ---
//     try {
//         val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
//         val isVoipActive = audioManager.mode == AudioManager.MODE_IN_COMMUNICATION ||
//                            audioManager.mode == AudioManager.MODE_RINGTONE
//         if (isVoipActive) {
//             Log.d("CallState", "VoIP or Internet call in progress")
//             return true
//         }
//     } catch (e: Exception) {
//         Log.e("CallState", "Error checking VoIP call state: ${e.message}")
//     }

//     return false
// }


// // private fun isCallActive(): Boolean {
// //     val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
// //     return telephonyManager.callState == TelephonyManager.CALL_STATE_OFFHOOK ||
// //            telephonyManager.callState == TelephonyManager.CALL_STATE_RINGING
// // }



// override fun onAttachedToActivity(binding: ActivityPluginBinding) {
//     activityBinding = binding

//     binding.addActivityResultListener(
//             attachmentActivityResultListener
//         )
//     val hiddenLifecycle = binding.lifecycle as HiddenLifecycleReference
//     lifecycleOwner = object : LifecycleOwner {
//         override val lifecycle: Lifecycle = hiddenLifecycle.lifecycle
//     }
//     doBindService()
// }

// override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
//     activityBinding = binding

//     binding.addActivityResultListener(
//             attachmentActivityResultListener
//         )


//     val hiddenLifecycle = binding.lifecycle as HiddenLifecycleReference
//     lifecycleOwner = object : LifecycleOwner {
//         override val lifecycle: Lifecycle = hiddenLifecycle.lifecycle
//     }
//     doBindService()
// }



//     override fun onDetachedFromActivity() {
//           try {

//             activityBinding
//                 .removeActivityResultListener(
//                     attachmentActivityResultListener
//                 )

//         } catch (e: Exception) {

//             Log.w(
//                 "BelnetLibPlugin",
//                 "Failed to remove attachment activity listener",
//                 e
//             )
//         }


//         clearAttachmentPicker()
//     }
//     override fun onDetachedFromActivityForConfigChanges() {
//            try {

//             activityBinding
//                 .removeActivityResultListener(
//                     attachmentActivityResultListener
//                 )

//         } catch (e: Exception) {

//             Log.w(
//                 "BelnetLibPlugin",
//                 "Failed to remove attachment activity listener",
//                 e
//             )
//         }


//         clearAttachmentPicker()
//     }

//     private val mConnection: ServiceConnection = object : ServiceConnection {
//         override fun onServiceConnected(className: ComponentName, service: IBinder) {
//             mBoundService = (service as BelnetDaemon.LocalBinder).getService()
//             mBoundService?.isConnected()?.observe(lifecycleOwner, mIsConnectedObserver)

//         }

//         override fun onServiceDisconnected(className: ComponentName) {
//             mBoundService = null
//         }
//     }

//     fun doBindService() {
//         if (activityBinding.activity.applicationContext.bindService(
//                 Intent(activityBinding.activity.applicationContext, BelnetDaemon::class.java),
//                 mConnection,
//                 Context.BIND_AUTO_CREATE
//             )
//         ) {
//             mShouldUnbind = true
//         } else {
//             Log.e(BelnetDaemon.LOG_TAG, "Error: The requested service doesn't exist, or this client isn't allowed access to it.")
//         }
//     }

//     fun doUnbindService() {
//         if (mShouldUnbind) {
//             activityBinding.activity.applicationContext.unbindService(mConnection)
//             mShouldUnbind = false
//         }
//     }

//     fun logDataToFrontend(sampleData: String): String {
//         logData = sampleData
//         Log.d("backtracking", logData)
//         return logData
//     }


//     // ============================================================
//     // ATTACHMENT RESULT
//     // ============================================================

//     private fun handleAttachmentResult(
//         requestCode: Int,
//         resultCode: Int,
//         data: Intent?
//     ) {

//         val result =
//             attachmentPickerResult
//                 ?: return


//         if (
//             resultCode != RESULT_OK ||
//             data == null
//         ) {

//             result.success(
//                 emptyList<String>()
//             )

//             clearAttachmentPicker()

//             return
//         }


//         val maxItems =
//             attachmentPickerMax


//         val uris =
//             mutableListOf<Uri>()


//         // --------------------------------------------------------
//         // Multiple selection
//         // --------------------------------------------------------

//         val clipData =
//             data.clipData


//         if (clipData != null) {

//             for (
//                 i in 0 until clipData.itemCount
//             ) {

//                 if (
//                     uris.size >= maxItems
//                 ) {

//                     break
//                 }


//                 val uri =
//                     clipData
//                         .getItemAt(i)
//                         .uri


//                 uris.add(
//                     uri
//                 )
//             }

//         } else {

//             // ----------------------------------------------------
//             // Single selection
//             // ----------------------------------------------------

//             data.data?.let { uri ->

//                 uris.add(
//                     uri
//                 )
//             }
//         }


//         val limitedUris =
//             uris.take(
//                 maxItems
//             )


//         Log.d(
//             "BelnetLibPlugin",
//             "Selected ${limitedUris.size} attachments"
//         )


//         val filePaths =
//             mutableListOf<String>()


//         val isImagePicker =
//             requestCode ==
//                     PHOTO_PICKER_REQUEST_CODE


//         /*
//          * Store all invalid files so we can show
//          * one useful Toast instead of many Toasts.
//          */
//         val invalidMessages =
//             mutableListOf<String>()


//         // ========================================================
//         // VALIDATE EACH FILE
//         // ========================================================

//         limitedUris.forEachIndexed {

//                 index,
//                 uri ->


//             val fileName =
//                 getDisplayName(uri)
//                     ?: "Selected file"


//             val fileSize =
//                 getFileSize(uri)


//             val maxSize =
//                 getMaxFileSize(
//                     uri,
//                     isImagePicker
//                 )


//             /*
//              * If Android gives us a valid file size,
//              * validate before copying.
//              */
//             if (
//                 fileSize > 0 &&
//                 maxSize != null &&
//                 fileSize > maxSize
//             ) {

//                 invalidMessages.add(
//                     "$fileName is ${formatFileSize(fileSize)}. " +
//                             "Maximum allowed is ${formatMaxSize(maxSize)}."
//                 )


//                 Log.w(
//                     "BelnetLibPlugin",
//                     "File rejected: $fileName " +
//                             "size=${formatFileSize(fileSize)} " +
//                             "limit=${formatMaxSize(maxSize)}"
//                 )


//                 return@forEachIndexed
//             }


//             /*
//              * File is within the limit OR
//              * Android did not provide the size.
//              *
//              * copyUriToCache() performs a second
//              * safety check while copying.
//              */
//             val copyResult =
//                 copyUriToCache(
//                     uri,
//                     index,
//                     isImagePicker
//                 )


//             when (copyResult) {

//                 is CopyResult.Success -> {

//                     filePaths.add(
//                         copyResult.path
//                     )
//                 }


//                 is CopyResult.TooLarge -> {

//                     invalidMessages.add(
//                         "${copyResult.fileName} is too large. " +
//                                 "Maximum allowed is " +
//                                 formatMaxSize(
//                                     copyResult.maxSize
//                                 ) + "."
//                     )
//                 }


//                 CopyResult.Failed -> {

//                     Log.w(
//                         "BelnetLibPlugin",
//                         "Failed to copy: $fileName"
//                     )
//                 }
//             }
//         }


//         // ========================================================
//         // SHOW SIZE ERROR
//         // ========================================================

//         if (
//             invalidMessages.isNotEmpty()
//         ) {

//             val message =

//                 if (
//                     invalidMessages.size == 1
//                 ) {

//                     invalidMessages.first()

//                 } else {

//                     "${invalidMessages.size} selected files " +
//                             "exceed the allowed size limit."
//                 }


//             showToast(
//                 message
//             )
//         }


//         // ========================================================
//         // RETURN VALID FILES TO FLUTTER
//         // ========================================================

//         Log.d(
//             "BelnetLibPlugin",
//             "Returning ${filePaths.size} valid attachment paths"
//         )


//         result.success(
//             filePaths
//         )


//         clearAttachmentPicker()
//     }


//     // ============================================================
//     // COPY RESULT
//     // ============================================================

//     private sealed class CopyResult {

//         data class Success(
//             val path: String
//         ) : CopyResult()


//         data class TooLarge(
//             val fileName: String,
//             val maxSize: Long
//         ) : CopyResult()


//         object Failed : CopyResult()
//     }


//     // ============================================================
//     // COPY URI TO CACHE
//     // ============================================================

//     private fun copyUriToCache(
//         uri: Uri,
//         index: Int,
//         isImage: Boolean
//     ): CopyResult {

//         return try {

//             val inputStream =
//                 context.contentResolver
//                     .openInputStream(uri)
//                     ?: return CopyResult.Failed


//             val mimeType =
//                 context.contentResolver.getType(
//                     uri
//                 )


//             val extension =
//                 getFileExtension(
//                     uri,
//                     mimeType,
//                     isImage
//                 )


//             val maxFileSize =
//                 getMaxFileSize(
//                     uri,
//                     isImage
//                 )
//                     ?: MAX_UNKNOWN_FILE_SIZE


//             val originalName =
//                 getDisplayName(uri)


//             val safeName =
//                 originalName
//                     ?.substringBeforeLast(".")
//                     ?.replace(
//                         Regex(
//                             "[^a-zA-Z0-9_-]"
//                         ),
//                         "_"
//                     )
//                     ?.take(50)
//                     ?: "attachment"


//             val fileName =
//                 "chat_${System.currentTimeMillis()}_${index}_${safeName}.$extension"


//             val outputFile =
//                 File(
//                     context.cacheDir,
//                     fileName
//                 )


//             var totalBytes =
//                 0L


//             try {

//                 FileOutputStream(
//                     outputFile
//                 ).use { outputStream ->

//                     inputStream.use { input ->

//                         val buffer =
//                             ByteArray(
//                                 8192
//                             )


//                         while (true) {

//                             val length =
//                                 input.read(
//                                     buffer
//                                 )


//                             if (
//                                 length == -1
//                             ) {

//                                 break
//                             }


//                             totalBytes +=
//                                 length


//                             /*
//                              * SECOND SIZE CHECK
//                              *
//                              * This protects against providers
//                              * that don't report file size.
//                              */
//                             if (
//                                 totalBytes >
//                                 maxFileSize
//                             ) {

//                                 outputFile.delete()


//                                 Log.w(
//                                     "BelnetLibPlugin",
//                                     "Attachment exceeded limit while copying: " +
//                                             "$fileName " +
//                                             "${formatFileSize(totalBytes)} > " +
//                                             formatMaxSize(maxFileSize)
//                                 )


//                                 return CopyResult.TooLarge(
//                                     fileName =
//                                         originalName
//                                             ?: "Selected file",
//                                     maxSize =
//                                         maxFileSize
//                                 )
//                             }


//                             outputStream.write(
//                                 buffer,
//                                 0,
//                                 length
//                             )
//                         }
//                     }
//                 }


//                 Log.d(
//                     "BelnetLibPlugin",
//                     "Attachment copied: ${outputFile.absolutePath}"
//                 )


//                 Log.d(
//                     "BelnetLibPlugin",
//                     "Attachment size: ${formatFileSize(totalBytes)}"
//                 )


//                 CopyResult.Success(
//                     outputFile.absolutePath
//                 )

//             } catch (e: Exception) {

//                 outputFile.delete()

//                 throw e
//             }

//         } catch (e: Exception) {

//             Log.e(
//                 "BelnetLibPlugin",
//                 "Failed to copy attachment: $uri",
//                 e
//             )

//             CopyResult.Failed
//         }
//     }


//     // ============================================================
//     // GET MAXIMUM FILE SIZE
//     // ============================================================

//     private fun getMaxFileSize(
//         uri: Uri,
//         isImage: Boolean
//     ): Long? {

//         /*
//          * Image picker always contains images.
//          */
//         if (isImage) {

//             return MAX_IMAGE_SIZE
//         }


//         val mimeType =
//             context.contentResolver.getType(
//                 uri
//             )


//         return when (mimeType) {

//             // ----------------------------------------------------
//             // PDF
//             // ----------------------------------------------------

//             "application/pdf" -> {

//                 MAX_DOCUMENT_SIZE
//             }


//             // ----------------------------------------------------
//             // DOC
//             // ----------------------------------------------------

//             "application/msword" -> {

//                 MAX_DOCUMENT_SIZE
//             }


//             // ----------------------------------------------------
//             // DOCX
//             // ----------------------------------------------------

//             "application/vnd.openxmlformats-officedocument.wordprocessingml.document" -> {

//                 MAX_DOCUMENT_SIZE
//             }


//             // ----------------------------------------------------
//             // TXT
//             // ----------------------------------------------------

//             "text/plain" -> {

//                 MAX_TEXT_SIZE
//             }


//             // ----------------------------------------------------
//             // CSV
//             // ----------------------------------------------------

//             "text/csv" -> {

//                 MAX_TEXT_SIZE
//             }


//             // ----------------------------------------------------
//             // XLS
//             // ----------------------------------------------------

//             "application/vnd.ms-excel" -> {

//                 MAX_SPREADSHEET_SIZE
//             }


//             // ----------------------------------------------------
//             // XLSX
//             // ----------------------------------------------------

//             "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" -> {

//                 MAX_SPREADSHEET_SIZE
//             }


//             // ----------------------------------------------------
//             // MIME TYPE UNKNOWN
//             // ----------------------------------------------------

//             else -> {

//                 val extension =
//                     getDisplayName(uri)
//                         ?.substringAfterLast(
//                             ".",
//                             ""
//                         )
//                         ?.lowercase()


//                 when (extension) {

//                     "pdf",
//                     "doc",
//                     "docx" -> {

//                         MAX_DOCUMENT_SIZE
//                     }


//                     "txt",
//                     "csv" -> {

//                         MAX_TEXT_SIZE
//                     }


//                     "xls",
//                     "xlsx" -> {

//                         MAX_SPREADSHEET_SIZE
//                     }


//                     "jpg",
//                     "jpeg",
//                     "png",
//                     "webp",
//                     "gif",
//                     "heic",
//                     "heif" -> {

//                         MAX_IMAGE_SIZE
//                     }


//                     else -> {

//                         MAX_UNKNOWN_FILE_SIZE
//                     }
//                 }
//             }
//         }
//     }


//     // ============================================================
//     // GET FILE SIZE
//     // ============================================================

//     private fun getFileSize(
//         uri: Uri
//     ): Long {

//         /*
//          * First attempt:
//          * OpenableColumns.SIZE
//          */
//         try {

//             context.contentResolver.query(
//                 uri,
//                 arrayOf(
//                     android.provider.OpenableColumns.SIZE
//                 ),
//                 null,
//                 null,
//                 null
//             )?.use { cursor ->

//                 if (
//                     cursor.moveToFirst()
//                 ) {

//                     val sizeIndex =
//                         cursor.getColumnIndex(
//                             android.provider.OpenableColumns.SIZE
//                         )


//                     if (
//                         sizeIndex >= 0 &&
//                         !cursor.isNull(sizeIndex)
//                     ) {

//                         val size =
//                             cursor.getLong(
//                                 sizeIndex
//                             )


//                         if (
//                             size >= 0
//                         ) {

//                             return size
//                         }
//                     }
//                 }
//             }

//         } catch (e: Exception) {

//             Log.w(
//                 "BelnetLibPlugin",
//                 "Unable to get file size from metadata: $uri",
//                 e
//             )
//         }


//         /*
//          * Second attempt:
//          * AssetFileDescriptor
//          */
//         try {

//             context.contentResolver
//                 .openAssetFileDescriptor(
//                     uri,
//                     "r"
//                 )
//                 ?.use { descriptor ->

//                     if (
//                         descriptor.length >= 0
//                     ) {

//                         return descriptor.length
//                     }
//                 }

//         } catch (e: Exception) {

//             Log.w(
//                 "BelnetLibPlugin",
//                 "Unable to get AssetFileDescriptor size: $uri",
//                 e
//             )
//         }


//         /*
//          * -1 means the provider did not expose
//          * the file size.
//          *
//          * copyUriToCache() will then enforce
//          * the limit while copying.
//          */
//         return -1L
//     }


//     // ============================================================
//     // FILE SIZE FORMAT
//     // ============================================================

//     private fun formatFileSize(
//         bytes: Long
//     ): String {

//         return when {

//             bytes >=
//                     1024L * 1024L -> {

//                 String.format(
//                     "%.2f MB",
//                     bytes.toDouble() /
//                             (
//                                 1024L *
//                                         1024L
//                             )
//                 )
//             }


//             bytes >= 1024L -> {

//                 String.format(
//                     "%.2f KB",
//                     bytes.toDouble() /
//                             1024L
//                 )
//             }


//             else -> {

//                 "$bytes B"
//             }
//         }
//     }


//     // ============================================================
//     // MAX SIZE FORMAT
//     // ============================================================

//     private fun formatMaxSize(
//         maxBytes: Long
//     ): String {

//         return if (
//             maxBytes %
//                     (
//                         1024L *
//                                 1024L
//                     ) == 0L
//         ) {

//             "${maxBytes / (1024L * 1024L)} MB"

//         } else {

//             formatFileSize(
//                 maxBytes
//             )
//         }
//     }


//     // ============================================================
//     // TOAST
//     // ============================================================

//     private fun showToast(
//         message: String
//     ) {

//         Handler(
//             Looper.getMainLooper()
//         ).post {

//             Toast.makeText(
//                 context,
//                 message,
//                 Toast.LENGTH_LONG
//             ).show()
//         }
//     }


//     // ============================================================
//     // GET FILE EXTENSION
//     // ============================================================

//     private fun getFileExtension(
//         uri: Uri,
//         mimeType: String?,
//         isImage: Boolean
//     ): String {

//         when (mimeType) {

//             "image/jpeg" ->
//                 return "jpg"

//             "image/png" ->
//                 return "png"

//             "image/webp" ->
//                 return "webp"

//             "image/gif" ->
//                 return "gif"

//             "image/heic" ->
//                 return "heic"

//             "image/heif" ->
//                 return "heif"


//             "application/pdf" ->
//                 return "pdf"


//             "text/plain" ->
//                 return "txt"


//             "text/csv" ->
//                 return "csv"


//             "application/msword" ->
//                 return "doc"


//             "application/vnd.openxmlformats-officedocument.wordprocessingml.document" ->
//                 return "docx"


//             "application/vnd.ms-excel" ->
//                 return "xls"


//             "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" ->
//                 return "xlsx"


//             "application/vnd.ms-powerpoint" ->
//                 return "ppt"


//             "application/vnd.openxmlformats-officedocument.presentationml.presentation" ->
//                 return "pptx"
//         }


//         /*
//          * Fallback to original filename.
//          */

//         val name =
//             getDisplayName(uri)


//         if (
//             name != null &&
//             name.contains(".")
//         ) {

//             return name
//                 .substringAfterLast(".")
//                 .lowercase()
//                 .take(10)
//         }


//         return if (isImage) {

//             "jpg"

//         } else {

//             "file"
//         }
//     }


//     // ============================================================
//     // GET DISPLAY NAME
//     // ============================================================

//     private fun getDisplayName(
//         uri: Uri
//     ): String? {

//         return try {

//             context.contentResolver
//                 .query(
//                     uri,
//                     arrayOf(
//                         android.provider.OpenableColumns.DISPLAY_NAME
//                     ),
//                     null,
//                     null,
//                     null
//                 )
//                 ?.use { cursor ->

//                     if (
//                         cursor.moveToFirst()
//                     ) {

//                         val index =
//                             cursor.getColumnIndex(
//                                 android.provider.OpenableColumns.DISPLAY_NAME
//                             )


//                         if (
//                             index >= 0
//                         ) {

//                             return cursor.getString(
//                                 index
//                             )
//                         }
//                     }


//                     null
//                 }

//         } catch (e: Exception) {

//             Log.e(
//                 "BelnetLibPlugin",
//                 "Unable to get display name",
//                 e
//             )

//             null
//         }
//     }


//     // ============================================================
//     // CLEAR PICKER
//     // ============================================================

//     private fun clearAttachmentPicker() {

//         attachmentPickerResult =
//             null

//         attachmentPickerType =
//             null

//         attachmentPickerMax =
//             MAX_ATTACHMENTS
//     }


//     // ============================================================
//     // OPEN IMAGE PICKER
//     // ============================================================

//     private fun openImagePicker(
//         maxImages: Int
//     ) {

//         val currentActivity =
//             activityBinding.activity


//         if (
//             Build.VERSION.SDK_INT >=
//             Build.VERSION_CODES.TIRAMISU
//         ) {

//             try {

//                 val intent =
//                     Intent(
//                         MediaStore.ACTION_PICK_IMAGES
//                     )


//                 intent.type =
//                     "image/*"


//                 intent.putExtra(
//                     Intent.EXTRA_ALLOW_MULTIPLE,
//                     true
//                 )


//                 intent.putExtra(
//                     MediaStore.EXTRA_PICK_IMAGES_MAX,
//                     maxImages
//                 )


//                 if (
//                     Build.VERSION.SDK_INT >= 34
//                 ) {

//                     intent.putExtra(
//                         MediaStore.EXTRA_PICK_IMAGES_IN_ORDER,
//                         true
//                     )
//                 }


//                 currentActivity
//                     .startActivityForResult(
//                         intent,
//                         PHOTO_PICKER_REQUEST_CODE
//                     )

//             } catch (e: Exception) {

//                 Log.e(
//                     "BelnetLibPlugin",
//                     "Failed to open Photo Picker",
//                     e
//                 )


//                 attachmentPickerResult?.error(
//                     "PHOTO_PICKER_ERROR",
//                     e.message,
//                     null
//                 )


//                 clearAttachmentPicker()
//             }

//         } else {

//             openLegacyImagePicker()
//         }
//     }


//     // ============================================================
//     // LEGACY IMAGE PICKER
//     // ============================================================

//     private fun openLegacyImagePicker() {

//         try {

//             val intent =
//                 Intent(
//                     Intent.ACTION_OPEN_DOCUMENT
//                 )


//             intent.type =
//                 "image/*"


//             intent.putExtra(
//                 Intent.EXTRA_ALLOW_MULTIPLE,
//                 true
//             )


//             intent.addCategory(
//                 Intent.CATEGORY_OPENABLE
//             )


//             activityBinding.activity
//                 .startActivityForResult(
//                     intent,
//                     PHOTO_PICKER_REQUEST_CODE
//                 )

//         } catch (e: Exception) {

//             Log.e(
//                 "BelnetLibPlugin",
//                 "Failed to open legacy image picker",
//                 e
//             )


//             attachmentPickerResult?.error(
//                 "IMAGE_PICKER_ERROR",
//                 e.message,
//                 null
//             )


//             clearAttachmentPicker()
//         }
//     }


//     // ============================================================
//     // FILE PICKER
//     // ============================================================

//     private fun openFilePicker() {

//         try {

//             val intent =
//                 Intent(
//                     Intent.ACTION_OPEN_DOCUMENT
//                 )


//             intent.type =
//                 "*/*"


//             intent.putExtra(
//                 Intent.EXTRA_ALLOW_MULTIPLE,
//                 true
//             )


//             intent.addCategory(
//                 Intent.CATEGORY_OPENABLE
//             )


//             activityBinding.activity
//                 .startActivityForResult(
//                     intent,
//                     FILE_PICKER_REQUEST_CODE
//                 )

//         } catch (e: Exception) {

//             Log.e(
//                 "BelnetLibPlugin",
//                 "Failed to open file picker",
//                 e
//             )


//             attachmentPickerResult?.error(
//                 "FILE_PICKER_ERROR",
//                 e.message,
//                 null
//             )


//             clearAttachmentPicker()
//         }
//     }


//     // ============================================================
//     // SAVE IMAGE TO GALLERY
//     // ============================================================

//     private fun saveImageToGallery(
//         imageBytes: ByteArray,
//         fileName: String
//     ): String? {

//         return try {

//             val resolver =
//                 context.contentResolver


//             val values =
//                 ContentValues().apply {

//                     put(
//                         MediaStore.Images.Media.DISPLAY_NAME,
//                         fileName
//                     )


//                     put(
//                         MediaStore.Images.Media.MIME_TYPE,
//                         "image/png"
//                     )


//                     put(
//                         MediaStore.Images.Media.RELATIVE_PATH,
//                         Environment.DIRECTORY_PICTURES +
//                                 "/Beldex Browser/AI Images"
//                     )


//                     if (
//                         Build.VERSION.SDK_INT >=
//                         Build.VERSION_CODES.Q
//                     ) {

//                         put(
//                             MediaStore.Images.Media.IS_PENDING,
//                             1
//                         )
//                     }
//                 }


//             val collection =

//                 if (
//                     Build.VERSION.SDK_INT >=
//                     Build.VERSION_CODES.Q
//                 ) {

//                     MediaStore.Images.Media
//                         .getContentUri(
//                             MediaStore.VOLUME_EXTERNAL_PRIMARY
//                         )

//                 } else {

//                     MediaStore.Images.Media
//                         .EXTERNAL_CONTENT_URI
//                 }


//             val imageUri =
//                 resolver.insert(
//                     collection,
//                     values
//                 )
//                     ?: throw Exception(
//                         "Failed to create MediaStore entry"
//                     )


//             try {

//                 resolver
//                     .openOutputStream(
//                         imageUri
//                     )
//                     ?.use { outputStream ->

//                         outputStream.write(
//                             imageBytes
//                         )

//                         outputStream.flush()
//                     }
//                     ?: throw Exception(
//                         "Failed to open image output stream"
//                     )


//                 if (
//                     Build.VERSION.SDK_INT >=
//                     Build.VERSION_CODES.Q
//                 ) {

//                     val completedValues =
//                         ContentValues().apply {

//                             put(
//                                 MediaStore.Images.Media.IS_PENDING,
//                                 0
//                             )
//                         }


//                     resolver.update(
//                         imageUri,
//                         completedValues,
//                         null,
//                         null
//                     )
//                 }


//                 Log.d(
//                     "BelnetLibPlugin",
//                     "Image saved to Gallery: $imageUri"
//                 )


//                 imageUri.toString()

//             } catch (e: Exception) {

//                 resolver.delete(
//                     imageUri,
//                     null,
//                     null
//                 )

//                 throw e
//             }

//         } catch (e: Exception) {

//             Log.e(
//                 "BelnetLibPlugin",
//                 "Failed to save image to Gallery",
//                 e
//             )

//             null
//         }
//     }


//     // ============================================================
//     // TTS AUDIO PATH
//     // ============================================================

//     private fun getTtsAudioPath(
//         fileName: String
//     ): String? {

//         return try {

//             val outputFile =
//                 File(
//                     context.cacheDir,
//                     fileName
//                 )


//             val collection =
//                 MediaStore.Audio.Media
//                     .EXTERNAL_CONTENT_URI


//             val projection =
//                 arrayOf(
//                     MediaStore.Audio.Media._ID,
//                     MediaStore.Audio.Media.DISPLAY_NAME
//                 )


//             val selection =
//                 "${MediaStore.Audio.Media.DISPLAY_NAME} = ?"


//             val selectionArgs =
//                 arrayOf(
//                     fileName
//                 )


//             var copied =
//                 false


//             context.contentResolver
//                 .query(
//                     collection,
//                     projection,
//                     selection,
//                     selectionArgs,
//                     "${MediaStore.Audio.Media.DATE_ADDED} DESC"
//                 )
//                 ?.use { cursor ->

//                     if (
//                         cursor.moveToFirst()
//                     ) {

//                         val idIndex =
//                             cursor.getColumnIndex(
//                                 MediaStore.Audio.Media._ID
//                             )


//                         if (
//                             idIndex >= 0
//                         ) {

//                             val id =
//                                 cursor.getLong(
//                                     idIndex
//                                 )


//                             val contentUri =
//                                 ContentUris.withAppendedId(
//                                     collection,
//                                     id
//                                 )


//                             context.contentResolver
//                                 .openInputStream(
//                                     contentUri
//                                 )
//                                 ?.use { input ->

//                                     FileOutputStream(
//                                         outputFile
//                                     ).use { output ->

//                                         input.copyTo(
//                                             output
//                                         )
//                                     }


//                                     copied =
//                                         true
//                                 }
//                         }
//                     }
//                 }


//             if (
//                 copied &&
//                 outputFile.exists()
//             ) {

//                 val fileSize =
//                     outputFile.length()


//                 if (
//                     fileSize > 0
//                 ) {

//                     outputFile.absolutePath

//                 } else {

//                     outputFile.delete()

//                     null
//                 }

//             } else {

//                 null
//             }

//         } catch (e: Exception) {

//             Log.e(
//                 "BelnetLibPlugin",
//                 "Failed to copy generated TTS audio",
//                 e
//             )

//             null
//         }
//     }

// }
