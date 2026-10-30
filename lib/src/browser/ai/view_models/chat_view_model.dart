import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/src/browser/ai/ai_model_provider.dart';
import 'package:beldex_browser/src/browser/ai/constants/string_constants.dart';
import 'package:beldex_browser/src/browser/ai/enums/roles.dart';
import 'package:beldex_browser/src/browser/ai/models/chat_model.dart';
import 'package:beldex_browser/src/browser/ai/repositories/openai_repository.dart';
import 'package:beldex_browser/src/browser/ai/view_models/base_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/utils/show_message.dart';
import 'package:belnet_lib/belnet_lib.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatViewModel extends BaseModel {
  final OpenAIRepository apiRepository = OpenAIRepository();
  final TextEditingController messageController = TextEditingController();
   ScrollController scrollController = ScrollController();

final DraggableScrollableController draggableController =
      DraggableScrollableController();

  late List<ChatModel> _messages;
  late String _sumResponse;


  File? _imageFile;
  bool? _showEmoji;
  int? _modelResponseIndex;

bool _isTyping = false; 

  String? _summariseText;

  String? get summariseText => _summariseText;

  set summariseText(String? value) {
    _summariseText = value;
    updateUI();
  }

 //show first time 

bool _canshowWelcome = false;
bool get canshowWelcome => _canshowWelcome;

 set canshowWelcome(bool value){
   _canshowWelcome = value;
   updateUI();
 }


/// Prevent storing data after new chat 
bool _isSummariseCancelled = false;
bool get isSummariseCancelled => _isSummariseCancelled;

set isSummariseCancelled(bool value){
  _isSummariseCancelled = value;
  updateUI();
}










 bool _isSummariseAvailable = false;

 bool get isSummariseAvailable => _isSummariseAvailable;

 set isSummariseAvailable(bool value){
   _isSummariseAvailable = value;
   updateUI();
 }


  List<ChatModel> get messages => _messages;

  set messages(List<ChatModel> value) {
    _messages = value;
    updateUI();
  }


  deleteChatMessage(int index){
    messages.removeAt(index);
    updateUI();
  }

 // Response for summarise in floating action button

 String get sumResponse => _sumResponse;

 set sumResponse(String value){
  _sumResponse = value;
  updateUI();
 }



  File? get imageFile => _imageFile;

  set imageFile(File? value) {
    _imageFile = value;
    updateUI();
  }

  bool? get showEmoji => _showEmoji;

  set setShowEmoji(bool? value) {
    _showEmoji = value;
    updateUI();
  }

  int? get modelResponseIndex => _modelResponseIndex;

  set modelResponseIndex(int? value) {
    _modelResponseIndex = value;
    updateUI();
  }




bool get isTyping => _isTyping;

  set isTyping(bool value) {
    _isTyping = value;
    updateUI();
  }

  ChatViewModel() {
    _messages = [];
    _sumResponse = '';
    _isTyping = false;
    initializeDailyAttachmentLimit();
  }


// Summarise in floating action button
Future<void> getSummariseForFloatingActionButton(WebViewModel webViewModel)async{
   String response = await apiRepository.fetchAndSummarize('', webViewModel);
   sumResponse = response;
   updateUI();
}



// ---------------------------------------------------------------------------
// Voice input
// ---------------------------------------------------------------------------

final stt.SpeechToText speechToText = stt.SpeechToText();

String _textBeforeVoiceInput = '';

bool isListening = false;
bool isTranscribing = false;

double soundLevel = 0.0;

String _recognizedText = '';

bool _speechInitialized = false;

int _voiceSessionId = 0;

bool _isStoppingVoice = false;


bool _isRestartingSpeech = false;

Future<bool> initializeSpeech() async {
  if (_speechInitialized) {
    return true;
  }

  try {
    final available = await speechToText.initialize(
      debugLogging: false,

      // onStatus: (status) {
      //   debugPrint(
      //     '[VOICE] Speech status: $status',
      //   );

      //   // IMPORTANT:
      //   //
      //   // Do not modify isListening here.
      //   //
      //   // Android can send "done" / "notListening"
      //   // automatically after a pause.
      //   //
      //   // The UI state is controlled by our own
      //   // start/stop methods.
      // },
      onStatus: (status) {
  debugPrint('[VOICE] Speech status: $status');

  if (status != 'done' && status != 'notListening') {
    return;
  }

  final sessionId = _voiceSessionId;

  Future.delayed(const Duration(milliseconds: 500), () async {
    if (!isListening ||
        isTranscribing ||
        _isStoppingVoice ||
        _isRestartingSpeech ||
        sessionId != _voiceSessionId) {
      return;
    }

    if (speechToText.isListening) {
      return;
    }

    _isRestartingSpeech = true;

    try {
      debugPrint(
        '[VOICE] Restarting after silence: $sessionId',
      );

      await _listenForSession(sessionId);
    } finally {
      _isRestartingSpeech = false;
    }
  });
},

      onError: (error) {
        debugPrint(
          '[VOICE] Speech error: '
          '${error.errorMsg}',
        );

        if (_isStoppingVoice) {
          return;
        }

        isListening = false;
        isTranscribing = false;
        soundLevel = 0.0;

        notifyListeners();
      },
    );

    _speechInitialized = available;

    debugPrint(
      '[VOICE] Speech available: $available',
    );

    return available;
  } catch (e) {
    debugPrint(
      '[VOICE] initialize error: $e',
    );

    _speechInitialized = false;

    return false;
  }
}


// Future<bool> _checkWaveformPermission() async {
//   try {
//     // final hasPermission =
//     //     await recorderController.checkPermission();

//     debugPrint(
//       'Waveform microphone permission: $hasPermission',
//     );

//     return hasPermission;
//   } catch (e) {
//     debugPrint(
//       'Waveform permission error: $e',
//     );

//     return false;
//   }
// }



Future<void> startVoiceSearch() async {
  if (isListening ||
      isTranscribing ||
      _isStoppingVoice) {
    debugPrint('[VOICE] Start ignored - already active');
    return;
  }

  final sessionId = ++_voiceSessionId;

  debugPrint('[VOICE] START session=$sessionId');

  final available = await initializeSpeech();

  if (!available || sessionId != _voiceSessionId) {
    debugPrint('[VOICE] Speech recognition unavailable');
    return;
  }

  // Preserve the existing prompt exactly as entered.
  _textBeforeVoiceInput = messageController.text;

  _recognizedText = '';
  soundLevel = 0.0;

  _isStoppingVoice = false;
  isListening = true;
  isTranscribing = false;

  notifyListeners();

  await _listenForSession(sessionId);
}


// WORKING ONE


// Future<void> startVoiceSearch() async {
//   if (isListening || isTranscribing) {
//     debugPrint(
//       '[VOICE] Start ignored - already active',
//     );

//     return;
//   }

//   final sessionId = ++_voiceSessionId;

//   debugPrint(
//     '[VOICE] START session=$sessionId',
//   );

//   final available = await initializeSpeech();

//   if (!available) {
//     debugPrint(
//       '[VOICE] Speech recognition unavailable',
//     );

//     return;
//   }

//   try {


//     // Save whatever the user has already typed.
//     _textBeforeVoiceInput =
//         messageController.text.trim();

//     _isStoppingVoice = false;

//     _recognizedText = '';

//     soundLevel = 0.0;

//     isListening = true;
//     isTranscribing = false;

//     notifyListeners();

//     await speechToText.listen(
//      // localeId: selectedSpeechLocale,

//       // listenFor: const Duration(
//       //   seconds: 60,
//       // ),

//       pauseFor: const Duration(
//         seconds: 10,
//       ),

//       onResult: (result) {
//         // Ignore callbacks from an old session.
//         if (sessionId != _voiceSessionId) {
//           debugPrint(
//             '[VOICE] Ignoring old result '
//             'session=$sessionId',
//           );

//           return;
//         }

//         final words =
//             result.recognizedWords.trim();

//         debugPrint(
//           '[VOICE] RESULT '
//           'final=${result.finalResult} '
//           'words="$words"',
//         );

//         if (words.isNotEmpty) {
//           _recognizedText = words;
//         }

//         // Do NOT update TextField while recording.
//       },

//       onSoundLevelChange: (level) {
//         if (sessionId != _voiceSessionId) {
//           return;
//         }

//         // speech_to_text generally reports approximately
//         // -40 to 0 dB on Android.
//         //
//         // Convert it to 0.0 -> 1.0.

//         final normalized =
//             ((level + 40) / 40)
//                 .clamp(0.0, 1.0);

//         soundLevel = normalized;

//         notifyListeners();
//       },

//       listenOptions: stt.SpeechListenOptions(
//         listenMode:
//             stt.ListenMode.dictation,

//         partialResults: true,

//         cancelOnError: false,

//         autoPunctuation: true,
//       ),
//     );

//     debugPrint(
//       '[VOICE] listen() started '
//       'session=$sessionId',
//     );
//   } catch (e, stackTrace) {
//     debugPrint(
//       '[VOICE] START ERROR: $e',
//     );

//     debugPrint(
//       '$stackTrace',
//     );

//     if (sessionId == _voiceSessionId) {
//       isListening = false;
//       isTranscribing = false;
//       soundLevel = 0.0;

//       notifyListeners();
//     }
//   }
// }


Future<void> stopVoiceSearch() async {
  if (!isListening || _isStoppingVoice) {
    print(
      '[VOICE] Stop ignored '
      'isListening=$isListening '
      'isStopping=$_isStoppingVoice',
    );

    return;
  }

  _isStoppingVoice = true;

  final sessionId = _voiceSessionId;

  print(
    '[VOICE] STOP session=$sessionId',
  );

  // Immediately change the UI.
  isListening = false;
  isTranscribing = true;
  soundLevel = 0.0;

  notifyListeners();

  try {
    // Ask Android speech recogniser to stop.
    await speechToText.stop();

    print(
      '[VOICE] speechToText.stop() completed',
    );

    // Give the platform recogniser time to send
    // its final SpeechRecognitionResult.
    await Future.delayed(
      const Duration(
        milliseconds: 800,
      ),
    );

    if (sessionId != _voiceSessionId) {
      print(
        '[VOICE] Session changed while stopping',
      );

      return;
    }

    // final finalText =
    //     _recognizedText.trim();

 final spokenText =
        _recognizedText.trim();

    final existingText =
        _textBeforeVoiceInput.trim();
        
String finalText;

    if (existingText.isEmpty) {
      // Nothing was typed before voice input.
      finalText = spokenText;
    } else if (spokenText.isEmpty) {
      // User didn't speak anything.
      finalText = existingText;
    } else {
      // Existing text + spoken text.
      finalText =
          '$existingText $spokenText';
    }



    print(
      '[VOICE] FINAL TEXT: "$finalText"',
    );

    // Put the final transcription into the TextField.
    messageController.value =
        TextEditingValue(
      text: finalText,
      selection:
          TextSelection.collapsed(
        offset: finalText.length,
      ),
    );
  } catch (e, stackTrace) {
    print(
      '[VOICE] STOP ERROR: $e',
    );

    print(
      '$stackTrace',
    );
  } finally {
    if (sessionId == _voiceSessionId) {
      isListening = false;
      isTranscribing = false;
      soundLevel = 0.0;

      _isStoppingVoice = false;

      notifyListeners();
    }
  }
}


Future<void> cancelVoiceSearch() async {
  if (_isStoppingVoice) {
    return;
  }

  _isStoppingVoice = true;

  // Invalidate callbacks from the current session.
  _voiceSessionId++;

  _isRestartingSpeech = false;

  print('[VOICE] Cancelling voice input');

  // Restore the original prompt and discard the speech.
  messageController.value = TextEditingValue(
    text: _textBeforeVoiceInput,
    selection: TextSelection.collapsed(
      offset: _textBeforeVoiceInput.length,
    ),
  );

  _recognizedText = '';
  soundLevel = 0.0;

  isListening = false;
  isTranscribing = false;

  notifyListeners();

  try {
    await speechToText.cancel();

    debugPrint('[VOICE] Voice input cancelled');
  } catch (e) {
    debugPrint('[VOICE] Cancel error: $e');
  } finally {
    _isStoppingVoice = false;

    isListening = false;
    isTranscribing = false;
    soundLevel = 0.0;

    notifyListeners();
  }
}

// WORKING ONE 

// Future<void> cancelVoiceSearch() async {
//   // if (_isStoppingVoice) {
//   //   return;
//   // }
  
//   // await stopVoiceSearch();
//   // isTranscribing = false;
//   // notifyListeners();
//   if (_isStoppingVoice) {
//     return;
//   }

//   // Invalidate callbacks from the current voice session.
//  // _voiceSessionId++;

//   _isStoppingVoice = true;

//   debugPrint('[VOICE] Cancelling voice input');

//   // Immediately hide the listening and transcribing widgets.
//   isListening = false;
//   isTranscribing = false;
//   soundLevel = 0.0;

//   // Discard the voice input.
//   _recognizedText = '';

//   notifyListeners();

//   try {
//     // Cancel recognition without processing the final transcription.
//     await speechToText.cancel();

//     debugPrint('[VOICE] Voice input cancelled');
//   } catch (e) {
//     debugPrint('[VOICE] Cancel error: $e');
//   } finally {
//     _isStoppingVoice = false;

//     isListening = false;
//     isTranscribing = false;
//     soundLevel = 0.0;

//     notifyListeners();
//   }

// }



Future<void> toggleVoiceSearch() async {
  if (_isStoppingVoice) {
    return;
  }

  if (isListening) {
    await stopVoiceSearch();
  } else if (!isTranscribing) {
    await startVoiceSearch();
  }
}





Future<void> _listenForSession(int sessionId) async {
  if (sessionId != _voiceSessionId ||
      !isListening ||
      _isStoppingVoice ||
      isTranscribing) {
    return;
  }

  try {
    await speechToText.listen(
      onResult: (result) {
        if (sessionId != _voiceSessionId ||
            _isStoppingVoice) {
          return;
        }

        final words = result.recognizedWords.trim();

        print(
          '[VOICE] RESULT '
          'final=${result.finalResult} '
          'words="$words"',
        );

        if (words.isNotEmpty) {
          _recognizedText = words;
        }
      },

      onSoundLevelChange: (level) {
        if (sessionId != _voiceSessionId ||
            !isListening) {
          return;
        }

        soundLevel = ((level + 40) / 40)
            .clamp(0.0, 1.0);

        notifyListeners();
      },
      listenFor: const Duration(hours: 1),

      pauseFor: const Duration(hours: 1),

      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        cancelOnError: false,
        autoPunctuation: true,
      ),
    );

    print(
      '[VOICE] Listening started '
      'session=$sessionId',
    );
  } catch (e, stackTrace) {
    print('[VOICE] Listen error: $e');
    print('$stackTrace');
  }
}




///////////////////////////////////////////////////////
///
// ============================================================
// ATTACHMENT LIMITS
// ============================================================
static const int maxAttachmentsPerChat = 10;
static const int maxAttachmentsPerDay = 20;

static const Duration attachmentWindow = Duration(hours: 24);

static const String _attachmentTimestampsKey =
    'ai_attachment_timestamps_v1';

/// Timestamp for each attachment that has been successfully
/// sent to the AI and received a successful response.
///
/// One timestamp represents one attachment.
final List<DateTime> _attachmentTimestamps = [];

Timer? _attachmentExpiryTimer;

bool _dailyAttachmentLimitLoaded = false;

/// Prevents the user from adding attachments while the daily
/// limit is loading from storage.
bool get isDailyAttachmentLimitLoaded =>
    _dailyAttachmentLimitLoaded;

/// Remove timestamps older than 24 hours.
void _removeExpiredAttachmentTimestamps() {
  final now = DateTime.now();

  _attachmentTimestamps.removeWhere(
    (timestamp) =>
        !now.isBefore(
          timestamp.add(attachmentWindow),
        ),
  );
}


/// Number of attachments that can still be selected
/// for the current request.
int get remainingImageSlots {
  final remainingChatSlots =
      maxAttachmentsPerChat - _imageFiles.length;

  return remainingChatSlots.clamp(0, maxAttachmentsPerChat);
}

/// Number of attachments available during the rolling
/// 24-hour window.
int get remainingDailyAttachmentSlots {
  _removeExpiredAttachmentTimestamps();

  return (maxAttachmentsPerDay - _attachmentTimestamps.length)
      .clamp(0, maxAttachmentsPerDay);
}

/// Number of attachments that can still be added to
/// the current request, considering both limits.
int get remainingChatAttachmentSlots {
  if (!_dailyAttachmentLimitLoaded) {
    return 0;
  }

  final requestSlots = remainingImageSlots;
  final dailySlots = remainingDailyAttachmentSlots;

  return requestSlots < dailySlots ? requestSlots : dailySlots;
}

/// Whether the user can add another attachment.
bool get canAddMoreImages {
  return _dailyAttachmentLimitLoaded &&
      remainingChatAttachmentSlots > 0;
}

/// Whether the daily limit has been reached.
bool get hasReachedDailyAttachmentLimit {
  return remainingDailyAttachmentSlots == 0;
}









/// Number of attachments successfully processed during
/// the current rolling 24-hour window.
int get dailyAttachmentCount {
  _removeExpiredAttachmentTimestamps();

  return _attachmentTimestamps.length;
}

/// Remaining attachments available during the rolling
/// 24-hour window.
// int get remainingDailyAttachmentSlots {
//   return (
//     maxAttachmentsPerDay - dailyAttachmentCount
//   ).clamp(0, maxAttachmentsPerDay);
// }

// /// Whether the user has reached the daily attachment limit.
// bool get hasReachedDailyAttachmentLimit =>
//     remainingDailyAttachmentSlots == 0;

/// Number of attachments the user can currently select,
/// considering both limits.
// int get remainingChatAttachmentSlots {
//   final chatSlots =
//       maxAttachmentsPerChat - _imageFiles.length;

//   return chatSlots
//       .clamp(0, maxAttachmentsPerChat)
//       .clamp(0, remainingDailyAttachmentSlots);
// }

// int get remainingChatAttachmentSlots {
//   if (!_dailyAttachmentLimitLoaded) {
//     return 0;
//   }

//   final chatSlots =
//       maxAttachmentsPerChat - _imageFiles.length;

//   final dailySlots = remainingDailyAttachmentSlots;

//   return chatSlots.clamp(0, maxAttachmentsPerChat) < dailySlots
//       ? chatSlots.clamp(0, maxAttachmentsPerChat)
//       : dailySlots;
// }

// /// Whether another attachment can be added.
// bool get canAddMoreImages {
//   return _dailyAttachmentLimitLoaded &&
//       remainingChatAttachmentSlots > 0;
// }

/// Load saved timestamps when the ViewModel is created.
// ChatViewModel() {
//   initializeDailyAttachmentLimit();
// }

Future<void> initializeDailyAttachmentLimit() async {
  if (_dailyAttachmentLimitLoaded) return;

  try {
    final preferences =
        await SharedPreferences.getInstance();

    final savedTimestamps =
        preferences.getStringList(
      _attachmentTimestampsKey,
    ) ?? <String>[];

    _attachmentTimestamps
      ..clear()
      ..addAll(
        savedTimestamps
            .map(DateTime.tryParse)
            .whereType<DateTime>()
            .map((timestamp) => timestamp.toLocal()),
      );

    _removeExpiredAttachmentTimestamps();

    _dailyAttachmentLimitLoaded = true;

    await _saveAttachmentTimestamps();

    _scheduleAttachmentExpiry();
  } catch (e) {
    print(
      'Failed to load daily attachment limit: $e',
    );

    // Fail closed so the user cannot bypass the daily limit
    // while its saved state is unavailable.
    _dailyAttachmentLimitLoaded = false;
  }

  updateUI();
}

/// Persist all unexpired attachment timestamps.
Future<void> _saveAttachmentTimestamps() async {
  final preferences =
      await SharedPreferences.getInstance();

  await preferences.setStringList(
    _attachmentTimestampsKey,
    _attachmentTimestamps
        .map((timestamp) => timestamp.toIso8601String())
        .toList(),
  );
}

/// Schedule a UI update for when the next attachment
/// timestamp expires.
void _scheduleAttachmentExpiry() {
  _attachmentExpiryTimer?.cancel();

  _removeExpiredAttachmentTimestamps();

  if (_attachmentTimestamps.isEmpty) {
    updateUI();
    return;
  }

  final oldestTimestamp = _attachmentTimestamps.reduce(
    (a, b) => a.isBefore(b) ? a : b,
  );

  final expiryTime =
      oldestTimestamp.add(attachmentWindow);

  final duration =
      expiryTime.difference(DateTime.now());

  _attachmentExpiryTimer = Timer(
    duration.isNegative
        ? Duration.zero
        : duration + const Duration(milliseconds: 100),
    () {
      _removeExpiredAttachmentTimestamps();

      _saveAttachmentTimestamps();

      _scheduleAttachmentExpiry();

      updateUI();
    },
  );
}

/// Call ONLY after the AI request has completed successfully.
///
/// Every attachment in the request receives its own timestamp.
/// Failed requests and unsuccessful responses must not call this.
// Future<void> _recordSuccessfulAttachments(
//   int attachmentCount,
// ) async {
//   if (attachmentCount <= 0) return;

//   if (!_dailyAttachmentLimitLoaded) {
//     throw StateError(
//       'Daily attachment limit has not been loaded.',
//     );
//   }

//   _removeExpiredAttachmentTimestamps();

//   // Never exceed the daily limit.
//   final allowedCount =
//       remainingDailyAttachmentSlots;

//   final count = attachmentCount.clamp(
//     0,
//     allowedCount,
//   );

//   if (count == 0) return;

//   final now = DateTime.now();

//   for (int i = 0; i < count; i++) {
//     _attachmentTimestamps.add(now);
//   }

//   await _saveAttachmentTimestamps();

//   _scheduleAttachmentExpiry();

//   updateUI();

//   print(
//     'Successfully processed attachments: $count',
//   );

//   print(
//     'Daily attachment count: $dailyAttachmentCount/20',
//   );
// }
Future<void> _recordSuccessfulAttachments(
  int attachmentCount,
) async {
  if (attachmentCount <= 0) return;

  if (!_dailyAttachmentLimitLoaded) {
    throw StateError(
      'Daily attachment limit has not been loaded.',
    );
  }

  _removeExpiredAttachmentTimestamps();

  final int remaining = remainingDailyAttachmentSlots;

  final int count = attachmentCount.clamp(
    0,
    remaining,
  );

  if (count == 0) return;

  final DateTime now = DateTime.now();

  for (int i = 0; i < count; i++) {
    _attachmentTimestamps.add(now);
  }

  await _saveAttachmentTimestamps();

  _scheduleAttachmentExpiry();

  updateUI();

  print(
    'Successfully processed attachments: $count',
  );

  print(
    'Daily attachment count: '
    '$dailyAttachmentCount/$maxAttachmentsPerDay',
  );

  print(
    'Remaining daily attachment slots: '
    '$remainingDailyAttachmentSlots',
  );

  print(
    'Can add more attachments: $canAddMoreImages',
  );
}

//// CODE FOR 24 HOURS END //////////////////////////////////////////


List<File> _imageFiles = [];

List<File> get imageFiles => _imageFiles;

void removeFileAttachment(int index) {
  if (index >= 0 && index < _imageFiles.length) {
    _imageFiles.removeAt(index);
    updateUI();
  }
}

void clearAttachments() {
  _imageFiles.clear();
  updateUI();
}






bool get canAddMoreImagess => _imageFiles.length < 10;

//int get remainingImageSlots => 10 - _imageFiles.length;

Future<void> pickFromCamera() async {
  // try {
  //   if (_imageFiles.length >= 10) {
  //     debugPrint('Maximum 10 images allowed');
  //     return;
  //   }

  //   final ImagePicker picker = ImagePicker();

  //   final XFile? pickedFile = await picker.pickImage(
  //     source: ImageSource.camera,
  //     imageQuality: 85,
  //   );

  //   if (pickedFile == null) {
  //     return;
  //   }

  //   final file = File(pickedFile.path);

  //   if (!_imageFiles.any((existing) =>
  //       existing.path == file.path)) {
  //     _imageFiles.add(file);
  //   }

  //   updateUI();
  // } catch (e) {
  //   debugPrint('Camera error: $e');
  // }


await initializeDailyAttachmentLimit();

  if (!canAddMoreImages) {
    debugPrint(
      'Attachment limit reached. '
      'Daily remaining: $remainingDailyAttachmentSlots',
    );
    return;
  }

  try {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    // Recheck after the asynchronous picker operation.
    if (!canAddMoreImages) {
      updateUI();
      return;
    }

    if (!_imageFiles.any(
      (existing) => existing.path == file.path,
    )) {
      _imageFiles.add(file);
    }

    updateUI();
  } catch (e) {
    debugPrint('Camera error: $e');
  }








}


// For single image

// Future<void> pickFromGallery() async {
//   try {
//     final ImagePicker picker = ImagePicker();

//     final XFile? pickedFile = await picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 85,
//     );

//     if (pickedFile == null) {
//       return;
//     }

//    // setState(() {
//       _imageFile = File(pickedFile.path);
//     //});
//     updateUI();
//   } catch (e) {
//     debugPrint('Gallery error: $e');
//   }
// }


Future<void> pickFromGallery() async {
  // try {
  //   final ImagePicker picker = ImagePicker();

  //   final List<XFile> pickedFiles =
  //       await picker.pickMultiImage(
  //     imageQuality: 85,
  //     limit: 10
  //   );

  //   if (pickedFiles.isEmpty) {
  //     return;
  //   }

  //   for (final pickedFile in pickedFiles) {
  //     if (_imageFiles.length >= 10) {
  //       break;
  //     }

  //     final file = File(pickedFile.path);

  //     if (!_imageFiles.any((existing) =>
  //         existing.path == file.path)) {
  //       _imageFiles.add(file);
  //     }
  //   }

  //   updateUI();
  // } catch (e) {
  //   debugPrint('Gallery error: $e');
  // }



///// WORKING CODE BEFORE ADD 24 HOURS Limit /////////

  // try {

  //   final remaining =
  //       10 - _imageFiles.length;

  //   if (remaining <= 0) {
  //     debugPrint(
  //       'Maximum 10 images reached',
  //     );
  //     return;
  //   }

  //   final files =
  //       await BelnetLib.pickImages(
  //     maxImages: remaining,
  //   );

  //   for (final file in files) {

  //     if (_imageFiles.length >= 10) {
  //       break;
  //     }

  //     if (!_imageFiles.any(
  //       (existing) =>
  //           existing.path == file.path,
  //     )) {
  //       _imageFiles.add(file);
  //     }
  //   }

  //   updateUI();

  // } catch (e) {

  //   debugPrint(
  //     'Gallery error: $e',
  //   );
  // }

  ///////////////////////
  ///
  await initializeDailyAttachmentLimit();

  final remaining = remainingChatAttachmentSlots;

  if (remaining <= 0) {
    debugPrint('Attachment limit reached');
    return;
  }

  try {
    final files = await BelnetLib.pickImages(
      maxImages: remaining,
    );

    for (final file in files) {
      if (!canAddMoreImages) break;

      if (!_imageFiles.any(
        (existing) => existing.path == file.path,
      )) {
        _imageFiles.add(file);
      }
    }

    updateUI();
  } catch (e) {
    debugPrint('Gallery error: $e');
  }

}

Future<void> pickFromFiles() async {

  // try {

  //   final remaining =
  //       10 - _imageFiles.length;

  //   if (remaining <= 0) {
  //     return;
  //   }

  //   final files =
  //       await BelnetLib.pickFiles(
  //     maxFiles: remaining,
  //   );

  //   for (final file in files) {

  //     if (_imageFiles.length >= 10) {
  //       break;
  //     }

  //     if (!_imageFiles.any(
  //       (existing) =>
  //           existing.path == file.path,
  //     )) {
  //       _imageFiles.add(file);
  //     }
  //   }

  //   updateUI();

  // } catch (e) {

  //   debugPrint(
  //     'Files error: $e',
  //   );
  // }



 await initializeDailyAttachmentLimit();

  final remaining = remainingChatAttachmentSlots;

  if (remaining <= 0) {
    debugPrint('Attachment limit reached');
    return;
  }

  try {
    final files = await BelnetLib.pickFiles(
      maxFiles: remaining,
    );

    for (final file in files) {
      if (!canAddMoreImages) break;

      if (!_imageFiles.any(
        (existing) => existing.path == file.path,
      )) {
        _imageFiles.add(file);
      }
    }

    updateUI();
  } catch (e) {
    debugPrint('Files error: $e');
  }
}


Future<void> pickFile() async {
  try {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'jpg',
        'jpeg',
        'png',
        'webp',
        'txt',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'ppt',
        'pptx',
      ],
    );

    if (result == null || result.files.single.path == null) {
      return;
    }

   // setState(() {
      _imageFile =
          File(result.files.single.path!);
   // });
   updateUI();
  } catch (e) {
    debugPrint('File picker error: $e');
  }
}












 String? _lastSummariseMessage; 
////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
/// 

// For summarise 
// Future<void> getTextAndSummariseInfo(WebViewModel webViewModel,String modelType,{String? sumText}) async {
//     //File? sendFile;


//     String? summariseUrlText;
//     summariseUrlText = summariseText;
//     //sendFile = imageFile;
//     if(summariseUrlText != null){
//   messages.add(ChatModel(
//       text:"${webViewModel.title.toString()} - Summarise page",
//       role: Roles.user,
//       isTypingComplete: true,
//       canShowRegenerate: false,
//       isRetry: false,
//       istyping: false,
//       isSummariseResult: false,
//      // image: sendFile,
//     ));
//     }else{
//       messages.add(ChatModel(
//       text: messageController.text,
//       role: Roles.user,
//       isTypingComplete: true,
//       canShowRegenerate: false,
//       isRetry: false,
//       istyping: false,
//       isSummariseResult: false,
//      // image: sendFile,
//     ));
//     }
   
//     imageFile = null;
//     summariseText = null;
//     messages.add(ChatModel(
//       role: Roles.model,
//       text: "",
//       isTypingComplete: false,
//       canShowRegenerate: false,
//       isSummariseResult: false,
//       isRetry: false,
//       istyping: true
//     ));
//     modelResponseIndex = messages.length;
//     scrollMessages();
//     updateUI();
//     isTyping = true;
//     String response = await apiRepository.fetchAndSummarizeContent("${webViewModel.title.toString()} - Summarise this webpage",webViewModel,modelType);  //sendTextForSummarise("${webViewModel.title.toString()} - Summarise this webpage"); //await apiRepository.sendTextAndImage(messageController.text, sendFile)
     
//      isTyping = false;
//     messages.removeAt(messages.length - 1);
//     if(response == 'Erroring'){
//         messages.add(ChatModel(
//       role: Roles.model,
//       text: 'There was an error generating response',
//       isTypingComplete: true,
//       canShowRegenerate: false,
//       isRetry: true,
//       isSummariseResult: true, //isInterrupted: false
//     ));
//     updateUI();
//     }else{
//       messages.add(ChatModel(
//       role: Roles.model,
//       text: response,
//       isTypingComplete: true,
//       canShowRegenerate: false,
//       isSummariseResult: true,
//       isRetry: false,
//       istyping: false
//     ));
//     updateUI();
//     }
   
//     scrollMessages();
//     updateUI();
//   }



// void retrySummariseResponse(){
// if (modelResponseIndex == null || _lastUserMessage == null) return;
//   messages[modelResponseIndex!] = ChatModel(
//     role: Roles.model,
//     text: "",
//     isTypingComplete: false,
//     canShowRegenerate: false,
//     isLoading: true,
//     isSummariseResult: false,
//   );

// }


Future<void> getTextAndSummariseInfo(WebViewModel webViewModel, String modelType,AppLocalizations loc, {String? sumText, bool isRegenerate = false}) async {
    String summariseUrlText = sumText ?? summariseText ?? "";

    if (!isRegenerate) {
        // Add user message only if it's not a regeneration request
        messages.add(ChatModel(
            text: "${webViewModel.title.toString()} - Summarise page",
            role: Roles.user,
            isTypingComplete: true,
            canShowRegenerate: false,
            isRetry: false,
            istyping: false,
            isSummariseResult: false,
        ));
    }

    // Reset temporary variables
    imageFile = null;
    summariseText = null;

    // Add loading indicator (only if not regenerating)
    if (!isRegenerate) {
        messages.add(ChatModel(
            role: Roles.model,
            text: "",
            isTypingComplete: false,
            canShowRegenerate: false,
            isSummariseResult: false,
            isRetry: false,
            istyping: true
        ));
    }

    modelResponseIndex = messages.length - 1;
   // scrollMessages();
    updateUI();
    isTyping = true;

    try {
        //  Await API response properly
        String response = await apiRepository.fetchAndSummarizeContent(
            "${webViewModel.url.toString()} - Summarise this webpage",
            webViewModel,
            modelType
        );

        //  Ensure function properly waits for API call before handling response
        isTyping = false;
        messages.removeAt(messages.length - 1); // Remove loading indicator
         print("I am Printing the response ------$response");
        // if(!isSummariseCancelled){
          if (response.isEmpty || response == 'Erroring') {
            //  Show retry only if API explicitly fails
            addSummarizeRetryMessage(webViewModel, modelType, sumText,loc);
        } else {
            // Display the valid response
            messages.add(ChatModel(
                role: Roles.model,
                text: response,
                isTypingComplete: true,
                canShowRegenerate: false,
                isSummariseResult: true,
                isRetry: false,
                istyping: false
            ));
        }
        // }else{
        //   return;
        // }
         
        
    } catch (e) {
        //  Catch API errors properly and show retry
        print("Error during summarization: $e");
        addSummarizeRetryMessage(webViewModel, modelType, sumText,loc);
    }

    updateUI();
    scrollMessages();
}


void addSummarizeRetryMessage(WebViewModel webViewModel, String modelType, String? sumText,AppLocalizations loc) {
    messages.add(ChatModel(
        role: Roles.model,
        text: loc.thereWasAnErrorGenerateResponse, //StringConstants.retryMessage,
        isTypingComplete: true,
        canShowRegenerate: false,
        isRetry: true,
        isSummariseResult: true,
    ));

    updateUI();
}


void regenerateSummarization(WebViewModel webViewModel, String modelType,AppLocalizations loc) {
    if (modelResponseIndex == null) return;

    // Reset only the last AI message instead of adding a new one
    messages[modelResponseIndex!] = ChatModel(
        role: Roles.model,
        text: "",
        isTypingComplete: false,
        canShowRegenerate: false,
        isSummariseResult: false,
        isRetry: false,
        istyping: true
    );

    updateUI();
    getTextAndSummariseInfo(webViewModel, modelType,loc, isRegenerate: true); // Restart response
}












/////////////////////////////////////////////////////
///
///
///////////////////////////////////

Future<String> extractContentFromUrl(String url)async{
  try{
    final response = await dio.get(url);
    if(response.statusCode == 200){
      return response.data;
    }
    return response.data;
  }catch(e){
    final host = WebUri(url).host;
     return host;
  }
}


// randomly select model
List<String> aiRandomModels = ['openai', 'gemini'];

String getRandomItem(List<String> items) {
  return items[Random().nextInt(items.length)];
}



/// get the stream type 

 StreamSubscription<String>? _streamSubscription;
 String? _lastUserMessage; // Store last user message

//String? _lastUserMessage; // Store the last user message

Future<void> getTextForUser({String? userMessage, bool isRegenerate = false,String modelType= 'openai'}) async {
  File? sendFile = _imageFile;
 print('The Default Model type -----> $modelType');



await initializeDailyAttachmentLimit();




  // Use the stored last message if regenerating, otherwise get from input field
  String messageToSend = userMessage ?? messageController.text;
  _lastUserMessage = messageToSend; // Save the last message

  



//  String text= messageController.text;

// // Extract potential URL from the message
//       RegExp urlPattern = RegExp(r'http[s]?:\/\/[^\s]+', caseSensitive: false);
//       Match? match = urlPattern.firstMatch(text);
//       String? extractedUrl = match?.group(0);

//       if (extractedUrl != null) {
//         // Remove the URL from the message and get additional user input if any
//         String additionalText = text.replaceFirst(extractedUrl, '').trim();

//         // Extract content from URL
//         String? extractedContent = await extractContentFromUrl(extractedUrl);

//         if (extractedContent != null && extractedContent.isNotEmpty) {
//           // If additional text exists, append it to the extracted content
//           String finalContent = additionalText.isNotEmpty
//               ? "$extractedContent\nUser Input: $additionalText"
//               : extractedContent;

//           getTextFromAskBeldexAI(finalContent,WebViewModel(),modelType);
//           return;
//         } else {
//           print("Could not extract content from URL.");
//          getTextFromAskBeldexAI("$extractedUrl .provide some details about this",WebViewModel(),modelType);
//          return;
          
//         }

//       } 


// ============================================================
  // ATTACHMENTS
  // ============================================================

  List<File> sendFiles;



  if (isRegenerate) {
    ChatModel? lastUserMessage;

    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i].role == Roles.user) {
        lastUserMessage = messages[i];
        break;
      }
    }

    sendFiles = List<File>.from(
      lastUserMessage?.images ?? <File>[],
    );

    print(
      'REGENERATE: ${sendFiles.length} attachments',
    );
  } else {
    sendFiles = List<File>.from(_imageFiles);

    print(
      'NEW REQUEST: ${sendFiles.length} attachments',
    );
  }



// Capture the count before clearing the selected attachments.
//
// This is NOT added to the daily limit yet.
// It will only be counted after a successful AI response.
final int attachmentCountForRequest = sendFiles.length;

  if (!isRegenerate) {
    // Add a new user message only if it's a fresh request
    messages.add(ChatModel(
      text: messageToSend,
      role: Roles.user,
      images: sendFiles,
      isTypingComplete: true,
      canShowRegenerate: false,
      isSummariseResult: false,
    ));
  }

  _imageFile = null;
   _imageFiles.clear();


  if (!isRegenerate) {
    // Add an empty AI response only if it's a fresh request
    messages.add(ChatModel(
      role: Roles.model,
      text: "",
      isTypingComplete: false,
      canShowRegenerate: false,
      isSummariseResult: false,
      istyping: true,
       // Image generation state
        isImageGeneration: false,
        isGeneratingImage: false,

        generatedImageBase64: null,
        generatedImageFile: null,
    ));
  }

  modelResponseIndex = messages.length - 1;
  //scrollMessages();
  updateUI();
    ///"Note: If this content contains only url then provide general information about the domain from the given URL as summarise, such as its purpose, industry, or key features." 
  isTyping = true;
  String wrd = '';


 // ============================================================
  // STREAM STATE
  // ============================================================

  bool hasError = false;
  bool hasImage = false;

  // ============================================================
  // AI STREAM
  // ============================================================

String? intent;
if (modelType != 'gemini' && modelType != 'openai') {
  intent = await apiRepository.detectUserIntent(
    userMessage: messageToSend,
    modelType: modelType,
  );

  if (intent == 'image_generation') {
    print('User requested image generation');
  } else {
    print('User requested a normal text response');
  }
}

// Select the model to use for the request.
final String selectedModel =
    (modelType == 'mistral' || modelType == 'deepseek') &&
           ( intent == 'image_generation'  || sendFiles.isNotEmpty)
        ? getRandomItem(aiRandomModels)
        : modelType;

print('Original model: $modelType');
print('Detected intent: $intent');
print('Selected model: $selectedModel');



  // Listen to the streaming response and update existing message
   _streamSubscription =
      apiRepository
          .sendTextForStreamWithModel( selectedModel,
            //'gemini',
            messageToSend,
            attachmentFiles: sendFiles,
          )
          .listen(
    (event) {
      if (modelResponseIndex == null) {
        return;
      }

      final index = modelResponseIndex!;

      final message = messages[index];

      print(
        "OPENAI EVENT ---> $event",
      );

      // ========================================================
      // IMAGE GENERATION STARTED
      // ========================================================

      if (event == "__IMAGE_GENERATING__") {
        message.isImageGeneration = true;
        message.isGeneratingImage = true;

        message.istyping = true;
        message.isTypingComplete = false;

        updateUI();

        scrollMessages();

        return;
      }

      // ========================================================
      // PARTIAL IMAGE
      // ========================================================
      //
      // IMPORTANT:
      //
      // Do NOT assign partial base64 to generatedImageBase64.
      //
      // A partial image may not be a valid PNG/JPEG yet and
      // Image.memory() can throw:
      //
      // Invalid image data
      //
      // Just keep the loading state.
      // ========================================================

      if (event.startsWith("__IMAGE_PARTIAL__")) {
        message.isImageGeneration = true;
        message.isGeneratingImage = true;
        message.istyping = true;

        updateUI();

        return;
      }

      // ========================================================
      // FINAL IMAGE
      // ========================================================

      if (event.startsWith("__IMAGE_COMPLETE__")) {
        final imageBase64 =
            event.substring(
          "__IMAGE_COMPLETE__".length,
        );

        if (imageBase64.isEmpty) {
          return;
        }

        hasImage = true;

        message.isImageGeneration = true;
        message.isGeneratingImage = false;

        // IMPORTANT:
        // Only store the COMPLETE image.
        message.generatedImageBase64 =
            imageBase64;

        message.generatedImageFile = null;

        message.istyping = false;
        message.isTypingComplete = true;
        message.canShowRegenerate = false;
        message.isRetry = false;

        isTyping = false;

        updateUI();

        scrollMessages();

        return;
      }

      // ========================================================
      // IMAGE ERROR
      // ========================================================

      if (event == "__IMAGE_ERROR__") {
        hasError = true;

        message.isGeneratingImage = false;
        message.isImageGeneration = true;

        message.istyping = false;
        message.isTypingComplete = true;

        message.isRetry = true;
        message.canShowRegenerate = false;

        message.text =
            StringConstants.retryMessage;

        isTyping = false;

        updateUI();

        return;
      }


   if(event == "Erroring"){
    message.istyping = false;
        message.isTypingComplete = true;

        message.isRetry = true;
        message.canShowRegenerate = false;

        message.text =
            StringConstants.retryMessage;

        isTyping = false;

        updateUI();

        return;
   }



      // ========================================================
      // NORMAL TEXT
      // ========================================================

      message.text += event;

      message.istyping = true;

      updateUI();
    },

    // ==========================================================
    // DONE  WORKING BEFORE ADD NEW 24 HOURS 
    // ==========================================================

    // onDone: () {
    //   print(
    //     "OpenAI response completed",
    //   );

    //   if (modelResponseIndex != null) {
    //     final index = modelResponseIndex!;

    //     final message = messages[index];

    //     message.istyping = false;

    //     message.isTypingComplete = true;

    //     message.canShowRegenerate = false;

    //     message.isGeneratingImage = false;

    //     // Don't overwrite a successfully generated image.
    //     if (hasImage) {
    //       message.isImageGeneration = true;
    //     }

    //     if (hasError) {
    //       message.isRetry = true;
    //     }
    //   }

    //   isTyping = false;

    //   updateUI();

    //   scrollMessages();

    //   _streamSubscription?.cancel();
    //   _streamSubscription = null;
    // },


onDone: () async {
  debugPrint('AI response stream completed');

  bool responseSuccessful = false;

  if (modelResponseIndex != null) {
    final index = modelResponseIndex!;

    final message = messages[index];

    message.istyping = false;
    message.isTypingComplete = true;
    message.canShowRegenerate = false;
    message.isGeneratingImage = false;

    // A successfully generated image is a valid response.
    if (hasImage) {
      message.isImageGeneration = true;
    }

    if (hasError) {
      message.isRetry = true;
    }

    // A response is successful if it contains text or a
    // completed image, and no image-generation error occurred.
    responseSuccessful = !hasError &&
        (message.text.trim().isNotEmpty || hasImage);
  }

  isTyping = false;

  // Count attachments ONLY for successful, new requests.
  //
  // Regeneration does not count previously sent attachments
  // again.
  if (!isRegenerate &&
      responseSuccessful &&
      attachmentCountForRequest > 0) {
    try {
      await _recordSuccessfulAttachments(
        attachmentCountForRequest,
      );
    } catch (e) {
      debugPrint(
        'Failed to save attachment usage: $e',
      );
    }
  }

  updateUI();

  scrollMessages();

  _streamSubscription?.cancel();
  _streamSubscription = null;
},


    // ==========================================================
    // ERROR
    // ==========================================================

    onError: (error) {
      print(
        "OpenAI stream error: $error",
      );

      if (modelResponseIndex != null) {
        final index = modelResponseIndex!;

        final message = messages[index];

        message.isGeneratingImage = false;
        message.istyping = false;

        message.isRetry = true;
        message.isTypingComplete = true;

        message.text = error.toString();
      }

      isTyping = false;

      updateUI();

      _streamSubscription?.cancel();
      _streamSubscription = null;
    },
  );
}

Future<void> downloadGeneratedImage(ChatModel message) async {
  try {
    if (message.generatedImageBase64 == null ||
        message.generatedImageBase64!.isEmpty) {
      print("No generated image available");
      return;
    }

    // Remove data URL prefix if present.
    String base64Image = message.generatedImageBase64!;

    if (base64Image.contains(",")) {
      base64Image = base64Image.split(",").last;
    }

    final bytes = base64Decode(base64Image);

    // Android Downloads directory
    final downloadDirectory =
        Directory("/storage/emulated/0/Download");

    if (!await downloadDirectory.exists()) {
      await downloadDirectory.create(
        recursive: true,
      );
    }

    final fileName =
        "AI_Image_${DateTime.now().millisecondsSinceEpoch}.png";

    final file = File(
      "${downloadDirectory.path}/$fileName",
    );

    await file.writeAsBytes(
      bytes,
      flush: true,
    );

    print(
      "Generated image saved: ${file.path}",
    );

    // Optional: keep reference in ChatModel
    message.generatedImageFile = file;

    updateUI();

  } catch (e) {
    print(
      "Download generated image error: $e",
    );
  }
}


void stopResponse() {
  _streamSubscription?.cancel();
  if (modelResponseIndex != null) {
    //isTyping = false;
   // messages[modelResponseIndex!].canShowRegenerate = true;
  }
  updateUI();
}

void regenerateResponse() {
  if (modelResponseIndex == null || _lastUserMessage == null) return;

  // Reset only the last AI message instead of adding a new one
  messages[modelResponseIndex!] = ChatModel(
    role: Roles.model,
    text: "",
    isTypingComplete: false,
    canShowRegenerate: false,
    isLoading: true,
    isSummariseResult: false,
  );

  updateUI();
  getTextForUser(userMessage: _lastUserMessage!, isRegenerate: true); // Restart response
}



void retryResponse(AIModelProvider aiModelProvider) async{
  if (modelResponseIndex == null || _lastUserMessage == null) return;
  
  // Reset only the last AI message instead of adding a new one
  messages[modelResponseIndex!] = ChatModel(
    role: Roles.model,
    text: "",
    isTypingComplete: false,
    canShowRegenerate: false,
    isRetry: false, // Hide retry button
    isLoading: true,
    isSummariseResult: false,
  );

  updateUI();

       // Retry with Gemini model
  getTextForUser(userMessage: _lastUserMessage!, modelType: aiModelProvider.selectedModel, isRegenerate: true);




 
}



//// Checing Network errors
///
void checkNetworkConnectivity(AppLocalizations loc)async{
  final connectivityResult = await Connectivity().checkConnectivity();

  if(connectivityResult == ConnectivityResult.none){
    showMessage(loc.youAreNotConnectedToInternet);
    return;
  }else{
    // Step 2: Test Actual Internet Access
  bool hasInternet = await _hasInternetAccess();

  if (!hasInternet) {
    showMessage(loc.unprecidentedTrafficExitNodeError);
    print("Network is ON & Internet is Working");
  }
  }

   
  // else {
    
  //   print("Network is ON but No Internet (Possible VPN Issue)");
  // }
}

Dio dio = Dio();

Future<bool> _hasInternetAccess() async {
  try {
    final response = await dio.get("https://www.google.com")
        .timeout(Duration(seconds: 5)); // Timeout to avoid long waits

    if (response.statusCode == 200) {
      return true; // Internet is working
    } else {
      return false; // Response but no internet access
    }
  } on SocketException catch (_) {
    return false; // No Internet (VPN, Firewall, or DNS issue)
  } on TimeoutException catch (_) {
    return false; // Timeout means no internet
  }
}






















// For Ask Beldex AI

Future<void> getTextFromAskBeldexAI(String question, WebViewModel webViewModel,String modelType) async {
  try {
    // Strict URL detection regex (only detects URLs with "http://" or "https://")
    // final urlRegex = RegExp(
    //   r'\b(https?|ftp):\/\/[^\s/$.?#].[^\s]*\b',
    //   caseSensitive: false,
    // );

    // final match = urlRegex.firstMatch(question);
    // bool containsUrl = match != null;

    // String? extractedUrl = containsUrl ? match!.group(0) : null;

    messages.add(ChatModel(
      text: question, // Keep the original text without modification
      role: Roles.user,
      isTypingComplete: true,
      canShowRegenerate: false,
      isRetry: false,
      istyping: false,
      isSummariseResult: false,
    ));
   // print("The content contains url ? --> $containsUrl");
    imageFile = null;
    summariseText = null;
    messages.add(ChatModel(
    role: Roles.model, 
    text: "",
    isTypingComplete: false,
      canShowRegenerate: false,
      isSummariseResult: false,
      isRetry: false,
      istyping: true
    ));
    modelResponseIndex = messages.length;
   // scrollMessages();
    updateUI();
   isTyping = true;
    String response = //containsUrl ?
         await apiRepository.fetchAndSummarizeUrls("$question - provide some details regarding this url content in natural and human write artical in summarise form.please do not mention in the response that you cannot access this url",webViewModel,modelType);
        //: await apiRepository.sendText(question);
    isTyping = false;
    messages.removeAt(messages.length - 1);
   if(response == 'Erroring'){
        messages.add(ChatModel(
      role: Roles.model,
      text: StringConstants.retryMessage,
      isTypingComplete: true,
      canShowRegenerate: false,
      isRetry: true,
      isSummariseResult: true, //isInterrupted: false
    ));
    updateUI();
    }else{
      messages.add(ChatModel(
      role: Roles.model,
      text: response,
      isTypingComplete: true,
      canShowRegenerate: false,
      isSummariseResult: false,
      isRetry: false,
      istyping: false
    ));
    updateUI();
    }
    
    scrollMessages();
    updateUI();
  } catch (e) {
    print("Exception in Beldex AI: $e");
  }
}






// Future<void> getTextFromAskBeldexAI(String question,WebViewModel webViewModel) async {
//    // File? sendFile;
   
// final uri = Uri.parse(question);
//      if(uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')){
//       // sendFile = imageFile;
//       messages.add(ChatModel(
//       text: '$uri',
//       role: Roles.user,
//       //image: null,// sendFile,
//     ));
   
//      }else{
//       // sendFile = imageFile;
//       messages.add(ChatModel(
//       text: question,
//       role: Roles.user,
//       //image: null,// sendFile,
//     ));
   
//      }





   
//     imageFile = null;
//     summariseText = null;
//     messages.add(ChatModel(
//       role: Roles.model,
//       text: "",
//     ));
//     modelResponseIndex = messages.length;
//     scrollMessages();
//     updateUI();
//     String response = uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https') ?
//      await apiRepository.sendTextForSummarise("${uri.toString()} - Summarise this webpage")
//     : await apiRepository.sendText(question); //await apiRepository.sendTextAndImage(messageController.text, sendFile)
//         //: await apiRepository.sendText(messageController.text);
//     messages.removeAt(messages.length - 1);
//     messages.add(ChatModel(
//       role: Roles.model,
//       text: response,
//     ));
//     scrollMessages();
//     updateUI();
//   }











  Future<void> getTextAndImageInfo() async {
    File? sendFile;
    sendFile = imageFile;
    messages.add(ChatModel(
      text: messageController.text,
      role: Roles.user,
      image: sendFile,
    ));
    imageFile = null;

    messages.add(ChatModel(
      role: Roles.model,
      text: "",
    ));
    modelResponseIndex = messages.length;
    scrollMessages();
    updateUI();
    String response = sendFile != null
        ? ''//await apiRepository.sendTextAndImage(messageController.text, sendFile)
        : await apiRepository.sendText(messageController.text);
    messages.removeAt(messages.length - 1);
    messages.add(ChatModel(
      role: Roles.model,
      text: response,
    ));
    scrollMessages();
    updateUI();
  }

  scrollMessages() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent + 120,
      duration: const Duration(milliseconds: 50),
      curve: Curves.easeOut,
    );
  }

  // pickImage(ImageSource source) async {
  //   try {
  //     final pickedImage = await ImagePicker().pickImage(source: source);
  //     if (pickedImage != null) {
  //       imageFile = File(pickedImage.path);

  //       updateUI();
  //       return imageFile;
  //     } else {
  //       log(' Chat: User didnt pick any image.');
  //     }
  //     imageFile = null;
  //   } catch (e) {
  //     log(" Chat: " + e.toString());
  //   }
  // }
}

// Check whether user message contains url or not
 bool containsUrl(String input) {
  final urlPattern = RegExp(
    r'((http|https):\/\/)?[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}(\S*)',
    caseSensitive: false,
  );
  return urlPattern.hasMatch(input);
}

