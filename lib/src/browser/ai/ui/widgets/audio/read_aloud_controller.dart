import 'dart:async';
import 'dart:io';

import 'package:belnet_lib/belnet_lib.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

// Keep your existing BelnetLib import.
//import 'package:beldex_browser/src/.../belnet_lib.dart';

class ReadAloudController extends ChangeNotifier
    with WidgetsBindingObserver {
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  String? _activeMessageId;

  int _operationId = 0;

  bool _isReading = false;
  bool _isGeneratingAudio = false;

  double _playbackSpeed = 1.0;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  bool get isVisible => _activeMessageId != null;

  bool get isReading => _isReading;

  bool get isGeneratingAudio => _isGeneratingAudio;



  ///////////////////////////
  bool _isPlaying = false;

bool get isPlaying => _isPlaying;
  //bool get isPlaying => _audioPlayer.playing;

  String? get activeMessageId => _activeMessageId;

  double get playbackSpeed => _playbackSpeed;

  Duration get position => _position;

  Duration get duration => _duration;

  ReadAloudController() {
    // Listen to application lifecycle.
    WidgetsBinding.instance.addObserver(this);

    _positionSubscription =
        _audioPlayer.positionStream.listen((position) {
      // Don't update the UI if there is no active reader.
      if (_activeMessageId == null) return;

      _position = position;
      notifyListeners();
    });

    // _durationSubscription =
    //     _audioPlayer.durationStream.listen((duration) {
    //   if (_activeMessageId == null) return;

    //   _duration = duration ?? Duration.zero;
    //   notifyListeners();
    // });

    _durationSubscription =
    _audioPlayer.durationStream.listen((duration) {
  if (_activeMessageId == null) return;

  // Do not reset a valid duration when the stream emits null.
  if (duration != null && duration > Duration.zero) {
    _duration = duration;

    print(
      'Audio duration updated: ${formatDuration(duration)}',
    );

    notifyListeners();
  }
});

    // _playerStateSubscription =
    //     _audioPlayer.playerStateStream.listen((state) {
    //   if (_activeMessageId == null) return;

    //   if (state.processingState == ProcessingState.completed) {
    //     _finishPlayback();
    //   } else {
    //     notifyListeners();
    //   }
    // });


_playerStateSubscription =
    _audioPlayer.playerStateStream.listen((state) {
  if (_activeMessageId == null) return;

  // Synchronise the UI with the actual audio player state.
  _isPlaying = state.playing;
  _isReading = state.playing;

  print(
    'Audio state: ${state.processingState}, '
    'playing: ${state.playing}, '
    'position: ${_audioPlayer.position}, '
    'duration: ${_audioPlayer.duration}',
  );

  if (state.processingState == ProcessingState.completed) {
    if (_isGeneratingAudio) return;

    final actualDuration =
        _audioPlayer.duration ?? _duration;

    final actualPosition = _audioPlayer.position;

    if (actualDuration > Duration.zero &&
        actualPosition >=
            actualDuration -
                const Duration(milliseconds: 500)) {
      _finishPlayback();
      return;
    }

    _isPlaying = false;
    _isReading = false;

    notifyListeners();
    return;
  }

  // Refresh the UI whenever the player's state changes.
  notifyListeners();
});

//     _playerStateSubscription =
//     _audioPlayer.playerStateStream.listen((state) {
//   if (_activeMessageId == null) return;

//   print(
//     'Audio state: ${state.processingState}, '
//     'playing: ${state.playing}, '
//     'position: ${_audioPlayer.position}, '
//     'duration: ${_audioPlayer.duration}',
//   );

//   if (state.processingState == ProcessingState.completed) {
//     // Ignore completion events during audio generation.
//     if (_isGeneratingAudio) return;

//     final actualDuration =
//         _audioPlayer.duration ?? _duration;

//     final actualPosition = _audioPlayer.position;

//     // A stop operation can also produce a completed state.
//     // Only close the player if playback genuinely reached
//     // the end of the audio.
//     if (actualDuration > Duration.zero &&
//         actualPosition >=
//             actualDuration - const Duration(milliseconds: 500)) {
//       _finishPlayback();
//       return;
//     }

//     // Do not close the player for an unexpected completion event.
//     _isReading = false;
//     notifyListeners();
//     return;
//   }

//   notifyListeners();
// });
  }

  // ============================================================
  // APP LIFECYCLE
  // ============================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(
      'ReadAloudController lifecycle state: $state',
    );

    switch (state) {
      case AppLifecycleState.inactive: break;
      case AppLifecycleState.paused: break;
      case AppLifecycleState.detached:
        print(
          'Read Aloud: App inactive/paused/detached -> STOP',
        );

        // Do not await from the lifecycle callback.
        unawaited(_stopForLifecycle());

        break;

      case AppLifecycleState.resumed:
        print(
          'Read Aloud: App resumed',
        );
        break;

      case AppLifecycleState.hidden:
        print(
          'Read Aloud: App hidden -> STOP',
        );

       // unawaited(_stopForLifecycle());

        break;
    }
  }

  Future<void> _stopForLifecycle() async {
    // ----------------------------------------------------------
    // VERY IMPORTANT
    //
    // Increment operation ID BEFORE awaiting anything.
    //
    // If synthesizeToFile() is currently running, this invalidates
    // that operation immediately.
    // ----------------------------------------------------------

    ++_operationId;

    print(
      'Read Aloud lifecycle stop. '
      'New operationId=$_operationId',
    );

    // Immediately clear UI state.
    _activeMessageId = null;
    _isReading = false;
    _isGeneratingAudio = false;
    _position = Duration.zero;
    _duration = Duration.zero;

    notifyListeners();

    // Stop Flutter TTS.
    try {
      await _flutterTts.stop();
    } catch (e) {
      print(
        'Read Aloud FlutterTts stop error: $e',
      );
    }

    // Stop just_audio.
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print(
        'Read Aloud AudioPlayer stop error: $e',
      );
    }

    print(
      'Read Aloud lifecycle stop completed',
    );
  }

  // ============================================================
  // PLAY / TOGGLE
  // ============================================================

  /// Called by an individual MessagePair's Read Aloud button.
  ///
  /// Same message:
  ///   playing -> pause
  ///   paused  -> resume
  ///
  /// Different message:
  ///   stop old reader
  ///   start new reader
  Future<void> playOrToggle({
    required String messageId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    // Same response.
    if (_activeMessageId == messageId) {
      // Don't allow toggling while TTS audio is being generated.
      if (_isGeneratingAudio) return;

      // Playing -> pause.
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();

        if (_activeMessageId == messageId) {
          _isReading = false;
          notifyListeners();
        }

        return;
      }

      // Paused -> resume.
      if (_audioPlayer.processingState !=
          ProcessingState.completed) {
        await _audioPlayer.play();

        if (_activeMessageId == messageId) {
          _isReading = true;
          notifyListeners();
        }

        return;
      }
    }

    // Different response.
    await _startNewMessage(
      messageId: messageId,
      text: text,
    );
  }

  // ============================================================
  // START NEW MESSAGE
  // ============================================================

  Future<void> _startNewMessage({
    required String messageId,
    required String text,
  }) async {
    // Every new request gets a unique operation ID.
    final int operation = ++_operationId;

    print(
      'Read Aloud start: '
      'message=$messageId '
      'operation=$operation',
    );

    // Stop the previous audio immediately.
    await _stopAudioOnly();

    // The app may have been paused while stopping the audio.
    if (operation != _operationId) {
      print(
        'Read Aloud start cancelled after stopAudioOnly',
      );
      return;
    }

    final cleanText = _removeSpecialFormatting(text);

    if (cleanText.trim().isEmpty) {
      _clearState(notify: true);
      return;
    }

    _activeMessageId = messageId;
    _isReading = true;
    _isGeneratingAudio = true;

    _position = Duration.zero;
    _duration = Duration.zero;

    notifyListeners();

    try {
      // --------------------------------------------------------
      // STOP PREVIOUS TTS
      // --------------------------------------------------------

      await _flutterTts.stop();

      if (operation != _operationId) {
        print(
          'Read Aloud cancelled after TTS stop',
        );
        return;
      }

      // --------------------------------------------------------
      // TTS CONFIG
      // --------------------------------------------------------

      await _flutterTts.setLanguage('en-US');

      if (operation != _operationId) return;

      await _flutterTts.setSpeechRate(0.48);

      if (operation != _operationId) return;

      await _flutterTts.setPitch(1.0);

      if (operation != _operationId) return;

      await _flutterTts.setVolume(1.0);

      if (operation != _operationId) return;

      await _flutterTts.awaitSynthCompletion(true);

      if (operation != _operationId) {
        print(
          'Read Aloud cancelled before synthesis',
        );
        return;
      }

      // --------------------------------------------------------
      // SYNTHESIZE AUDIO
      // --------------------------------------------------------

      final fileName =
          'beldex_ai_${DateTime.now().millisecondsSinceEpoch}.wav';

      print(
        'TTS FILE NAME: $fileName',
      );

      final result = await _flutterTts.synthesizeToFile(
        cleanText,
        fileName,
        false,
      );

      print(
        'TTS SYNTH RESULT: $result',
      );

      // IMPORTANT:
      // If app was paused while synthesizeToFile() was running,
      // operation ID will have changed and we return here.
      if (operation != _operationId) {
        print(
          'Read Aloud cancelled after synthesis',
        );
        return;
      }

      // --------------------------------------------------------
      // WAIT FOR FILE
      // --------------------------------------------------------

      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      if (operation != _operationId) {
        print(
          'Read Aloud cancelled during file wait',
        );
        return;
      }

      // --------------------------------------------------------
      // GET AUDIO FILE PATH
      // --------------------------------------------------------

      final audioPath =
          await BelnetLib.audioFileGen(fileName);

      print(
        'TTS CACHE PATH: $audioPath',
      );

      if (operation != _operationId) {
        print(
          'Read Aloud cancelled after audioFileGen',
        );
        return;
      }

      if (audioPath == null || audioPath.isEmpty) {
        throw Exception(
          'Unable to retrieve TTS audio path',
        );
      }

      // --------------------------------------------------------
      // CHECK FILE
      // --------------------------------------------------------

      final audioFile = File(audioPath);

      if (!await audioFile.exists()) {
        throw Exception(
          'TTS cache file does not exist',
        );
      }

      if (operation != _operationId) return;

      final fileSize = await audioFile.length();

      print(
        'TTS CACHE FILE SIZE: $fileSize',
      );

      if (fileSize == 0) {
        throw Exception(
          'TTS cache file is empty',
        );
      }

      if (operation != _operationId) return;

      // --------------------------------------------------------
      // LOAD AUDIO
      // --------------------------------------------------------

      // final duration = await _audioPlayer.setFilePath(
      //   audioPath,
      //   preload: true,
      // );

      // if (operation != _operationId) {
      //   // If lifecycle changed while loading audio,
      //   // stop the player immediately.
      //   await _audioPlayer.stop();
      //   return;
      // }

      // debugPrint(
      //   'AUDIO DURATION: $duration',
      // );

      // if (duration == null ||
      //     duration == Duration.zero) {
      //   throw Exception(
      //     'Invalid audio duration',
      //   );
      // }


// --------------------------------------------------------
// LOAD AUDIO
// --------------------------------------------------------

final loadedDuration = await _audioPlayer.setFilePath(
  audioPath,
  preload: true,
);

if (operation != _operationId) {
  await _audioPlayer.stop();
  return;
}

// Read the duration from the loaded audio source.
final actualDuration =
    loadedDuration ?? _audioPlayer.duration;

if (actualDuration == null ||
    actualDuration <= Duration.zero) {
  throw Exception(
    'Unable to determine audio duration. '
    'Path: $audioPath',
  );
}

_duration = actualDuration;
_position = Duration.zero;

print(
  'Loaded audio duration: ${actualDuration.inMilliseconds} ms',
);

print(
  'Loaded audio duration formatted: '
  '${formatDuration(actualDuration)}',
);

notifyListeners();

      // --------------------------------------------------------
      // SET SPEED
      // --------------------------------------------------------

      await _audioPlayer.setSpeed(
        _playbackSpeed,
      );

      if (operation != _operationId) {
        await _audioPlayer.stop();
        return;
      }

      // --------------------------------------------------------
      // READY
      // --------------------------------------------------------

      // _isGeneratingAudio = false;
      // _isReading = true;
      // _duration = duration;
      // _position = Duration.zero;

      // notifyListeners();

      // if (operation != _operationId) {
      //   await _audioPlayer.stop();
      //   return;
      // }

      // // --------------------------------------------------------
      // // START PLAYBACK
      // // --------------------------------------------------------

      // print(
      //   'STARTING AUDIO PLAYBACK',
      // );

      // await _audioPlayer.play();

// --------------------------------------------------------
// READY
// --------------------------------------------------------



_isGeneratingAudio = false;
_isReading = true;
_isPlaying = true;

_duration = actualDuration;
_position = Duration.zero;

notifyListeners();

// --------------------------------------------------------
// START PLAYBACK
// --------------------------------------------------------

print('STARTING AUDIO PLAYBACK');

try {
  // Update the UI before starting playback.
  // The pause icon appears immediately.
  await _audioPlayer.play();
} finally {
  // Update the state only if this is still the active operation.
  if (operation == _operationId) {
    _isPlaying = _audioPlayer.playing;
    _isReading = _isPlaying;

    notifyListeners();
  }
}











      // The app could have been paused while play() was starting.
      if (operation != _operationId) {
        await _audioPlayer.stop();
        return;
      }
    } catch (e, stackTrace) {
      print(
        'TTS ERROR: $e',
      );

      print(
        'TTS STACKTRACE: $stackTrace',
      );

      // Ignore errors caused by a newer operation.
      if (operation != _operationId) {
        return;
      }

      await _stopAudioOnly();

      _clearState(
        notify: true,
      );
    }
  }

  // ============================================================
  // PLAY / PAUSE
  // ============================================================

//   Future<void> togglePlayPause() async {
//   if (!isVisible || _isGeneratingAudio) {
//     return;
//   }

//   try {
//     if (_audioPlayer.playing) {
//       await _audioPlayer.pause();

//       // Pausing must not clear the active message.
//       if (_activeMessageId != null) {
//         _isReading = false;
//         notifyListeners();
//       }

//       print(
//         'Audio paused at ${_audioPlayer.position}',
//       );

//       return;
//     }

//     // If playback reached the end, restart from the beginning.
//     if (_audioPlayer.processingState ==
//         ProcessingState.completed) {
//       await _audioPlayer.seek(Duration.zero);
//     }

//     await _audioPlayer.play();

//     if (_activeMessageId != null) {
//       _isReading = true;
//       notifyListeners();
//     }

//     print('Audio resumed.');
//   } catch (e) {
//     print('Play/pause error: $e');
//   }
// }


Future<void> togglePlayPause() async {
  if (!isVisible || _isGeneratingAudio) {
    return;
  }

  try {
    if (_isPlaying) {
      // Update the UI immediately.
      _isPlaying = false;
      _isReading = false;
      notifyListeners();

      await _audioPlayer.pause();

      print(
        'Audio paused at ${_audioPlayer.position}',
      );

      return;
    }

    // Restart if playback has already completed.
    if (_audioPlayer.processingState ==
        ProcessingState.completed) {
      await _audioPlayer.seek(Duration.zero);
    }

    // Update the UI immediately, before awaiting play().
    _isPlaying = true;
    _isReading = true;
    notifyListeners();

    await _audioPlayer.play();

    print('Audio resumed.');
  } catch (e) {
    print('Play/pause error: $e');

    // Reconcile the UI with the actual player state.
    _isPlaying = _audioPlayer.playing;
    _isReading = _isPlaying;

    notifyListeners();
  }
}





  // ============================================================
  // REWIND
  // ============================================================

  // Future<void> rewind15() async {
  //   if (!isVisible || _isGeneratingAudio) {
  //     return;
  //   }

  //   final newPosition =
  //       _position - const Duration(seconds: 15);

  //   await _audioPlayer.seek(
  //     newPosition < Duration.zero
  //         ? Duration.zero
  //         : newPosition,
  //   );
  // }

  Future<void> rewind10() async {
  if (!isVisible || _isGeneratingAudio) {
    return;
  }

  try {
    final currentPosition = _audioPlayer.position;

    final newPosition =
        currentPosition - const Duration(seconds: 10);

    final targetPosition =
        newPosition < Duration.zero
            ? Duration.zero
            : newPosition;

    print(
      'Rewind: $currentPosition -> $targetPosition',
    );

    await _audioPlayer.seek(targetPosition);
  } catch (e) {
    print('Rewind seek error: $e');
  }
}

  // ============================================================
  // FORWARD
  // ============================================================

  Future<void> forward10() async {
  if (!isVisible || _isGeneratingAudio) {
    return;
  }

  try {
    final actualDuration =
        _audioPlayer.duration ?? _duration;

    if (actualDuration <= Duration.zero) {
      print(
        'Forward skipped: audio duration is unavailable.',
      );
      return;
    }

    final currentPosition = _audioPlayer.position;

    final newPosition =
        currentPosition + const Duration(seconds: 10);

    final targetPosition =
        newPosition > actualDuration
            ? actualDuration
            : newPosition;

    print(
      'Forward: $currentPosition -> $targetPosition '
      '(duration: $actualDuration)',
    );

    await _audioPlayer.seek(targetPosition);
  } catch (e) {
    print('Forward seek error: $e');
  }
}

  // ============================================================
  // SPEED
  // ============================================================

  Future<void> changePlaybackSpeed() async {
    if (!isVisible || _isGeneratingAudio) {
      return;
    }

    const speeds = <double>[
      0.75,
      1.0,
      1.25,
      1.5,
      2.0,
    ];

    final currentIndex =
        speeds.indexOf(_playbackSpeed);

    final nextIndex =
        (currentIndex + 1) % speeds.length;

    _playbackSpeed = speeds[nextIndex];

    await _audioPlayer.setSpeed(
      _playbackSpeed,
    );

    notifyListeners();
  }

  // ============================================================
  // CLOSE
  // ============================================================

  // /// Stops the current response and closes the floating player.
  // Future<void> close() async {
  //   print(
  //     'Read Aloud close()',
  //   );

  //   // Invalidate any running TTS/audio generation.
  //   ++_operationId;

  //   print(
  //     'Read Aloud close operationId=$_operationId',
  //   );

  //   // Immediately clear state so the floating panel disappears.
  //   _clearState(
  //     notify: true,
  //   );

  //   // Stop Flutter TTS.
  //   try {
  //     await _flutterTts.stop();
  //   } catch (e) {
  //     print(
  //       'TTS STOP ERROR: $e',
  //     );
  //   }

  //   // Stop just_audio.
  //   await _stopAudioOnly();

  //   print(
  //     'Read Aloud close completed',
  //   );
  // }
Future<void> close() async {
  print('Read Aloud: closing player');

  // Invalidate any ongoing audio generation or playback operation.
  ++_operationId;

  // Hide the floating player immediately.
  _activeMessageId = null;
  _isReading = false;
  _isGeneratingAudio = false;
  _position = Duration.zero;
  _duration = Duration.zero;

   _playbackSpeed = 1.0;
  // If you have added this field, reset it too.
  _isPlaying = false;

  notifyListeners();

  // Stop just_audio immediately.
  try {
    await _audioPlayer.stop();
    await _audioPlayer.setSpeed(1.0);
    print('Read Aloud: just_audio stopped');
  } catch (e) {
    print('Read Aloud: just_audio stop error: $e');
  }

  // Stop Flutter TTS.
  try {
    await _flutterTts.stop();
    print('Read Aloud: Flutter TTS stopped');
  } catch (e) {
    print('Read Aloud: Flutter TTS stop error: $e');
  }

  // Ensure the UI remains in the closed state.
  _activeMessageId = null;
  _isReading = false;
  _isGeneratingAudio = false;
  _isPlaying = false;
  _position = Duration.zero;
  _duration = Duration.zero;

  notifyListeners();

  print('Read Aloud: player closed');
}

/// Stops the current response and closes the floating player.
// Future<void> close() async {
//   print('Read Aloud close()');

//   // 1. Invalidate ongoing TTS generation and playback operations.
//   ++_operationId;

//   print('Read Aloud close operationId=$_operationId');

//   // 2. Immediately hide the player and reset its state.
//   _clearState(notify: true);

//   // 3. Stop audio playback immediately.
//   await _stopAudioOnly();

//   // 4. Stop ongoing TTS synthesis or speech.
//   try {
//     await _flutterTts.stop();
//   } catch (e) {
//     print('TTS STOP ERROR: $e');
//   }

//   // 5. Ensure the player remains closed.
//   _clearState(notify: true);

//   print('Read Aloud close completed');
// }
  // ============================================================
  // STOP AUDIO
  // ============================================================

  Future<void> _stopAudioOnly() async {

    _isPlaying = false;
  _isReading = false;

  notifyListeners();
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print(
        'AUDIO STOP ERROR: $e',
      );
    }
  }

  // ============================================================
  // PLAYBACK COMPLETED
  // ============================================================

  void _finishPlayback() {
  if (_activeMessageId == null) {
    return;
  }

  // Do not clear the UI while audio is still being generated.
  if (_isGeneratingAudio) {
    return;
  }

  // Confirm that the player has genuinely reached the end.
  final actualDuration =
      _audioPlayer.duration ?? _duration;

  final actualPosition = _audioPlayer.position;

  if (actualDuration <= Duration.zero ||
      actualPosition <
          actualDuration - const Duration(milliseconds: 500)) {
    print(
      'Ignoring completion event: '
      'position=$actualPosition, duration=$actualDuration',
    );

    return;
  }

  print('Read Aloud playback completed naturally.');

  _activeMessageId = null;
  _isReading = false;
  _isGeneratingAudio = false;
  _isPlaying = false;
  _position = Duration.zero;
  _duration = Duration.zero;

  notifyListeners();
}

  // ============================================================
  // CLEAR STATE
  // ============================================================

  void _clearState({
    required bool notify,
  }) {
    _activeMessageId = null;
    _isReading = false;
    _isGeneratingAudio = false;
 _isPlaying = false;
    _position = Duration.zero;
    _duration = Duration.zero;

    if (notify) {
      notifyListeners();
    }
  }

  // ============================================================
  // CLEAN TEXT
  // ============================================================

  String _removeSpecialFormatting(String text) {
    return text
        .replaceAllMapped(
          RegExp(r'\*\*(.*?)\*\*'),
          (match) => match.group(1) ?? '',
        )
        .replaceAllMapped(
          RegExp(r'\*(.*?)\*'),
          (match) => match.group(1) ?? '',
        )
        .replaceAll(
          RegExp(r'^•\s+', multiLine: true),
          '',
        )
        .replaceAll(
          RegExp(r'\$1'),
          '',
        )
        .replaceAll(
          RegExp(r'^\d+\.\s+', multiLine: true),
          '',
        )
        .replaceAll(
          RegExp(r'^#+ ', multiLine: true),
          '',
        )
        .replaceAll(
          RegExp(r'\n{2,}'),
          '\n',
        )
        .trim();
  }

  // ============================================================
  // FORMAT DURATION
  // ============================================================

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    final seconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return '$minutes:$seconds';
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    print(
      'ReadAloudController dispose()',
    );

    // Invalidate any currently running async operation.
    ++_operationId;

    // Stop receiving lifecycle events.
    WidgetsBinding.instance.removeObserver(this);

    // Cancel stream subscriptions.
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();

    // These methods return Future, but dispose() cannot await them.
    // Calling them here still requests an immediate stop.
    _flutterTts.stop();
    _audioPlayer.stop();

    // Dispose audio player.
    _audioPlayer.dispose();

    super.dispose();
  }
}


// import 'dart:async';
// import 'dart:io';

// import 'package:belnet_lib/belnet_lib.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:just_audio/just_audio.dart';

// /// Owns the single Read Aloud/TTS player for the whole AI screen.
// ///
// /// There must only be one instance of this controller while the AI screen
// /// is open. MessagePair widgets only request playback from this controller.
// class ReadAloudController extends ChangeNotifier {
//   final FlutterTts _flutterTts = FlutterTts();
//   final AudioPlayer _audioPlayer = AudioPlayer();

//   StreamSubscription<Duration>? _positionSubscription;
//   StreamSubscription<Duration?>? _durationSubscription;
//   StreamSubscription<PlayerState>? _playerStateSubscription;

//   String? _activeMessageId;
//   int _operationId = 0;

//   bool _isReading = false;
//   bool _isGeneratingAudio = false;

//   double _playbackSpeed = 1.0;
//   Duration _position = Duration.zero;
//   Duration _duration = Duration.zero;

//   bool get isVisible => _activeMessageId != null;
//   bool get isReading => _isReading;
//   bool get isGeneratingAudio => _isGeneratingAudio;
//   bool get isPlaying => _audioPlayer.playing;

//   String? get activeMessageId => _activeMessageId;
//   double get playbackSpeed => _playbackSpeed;
//   Duration get position => _position;
//   Duration get duration => _duration;

//   ReadAloudController() {
//     _positionSubscription = _audioPlayer.positionStream.listen((position) {
//       _position = position;
//       notifyListeners();
//     });

//     _durationSubscription = _audioPlayer.durationStream.listen((duration) {
//       _duration = duration ?? Duration.zero;
//       notifyListeners();
//     });

//     _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
//       if (state.processingState == ProcessingState.completed) {
//         _finishPlayback();
//       } else {
//         notifyListeners();
//       }
//     });
//   }

//   /// Called by an individual MessagePair's Read Aloud button.
//   ///
//   /// - Same message + playing -> pause.
//   /// - Same message + paused -> resume.
//   /// - Different message -> stop the old reader and start the new one.
//   Future<void> playOrToggle({
//     required String messageId,
//     required String text,
//   }) async {
//     if (text.trim().isEmpty) return;

//     // Same response: toggle pause/resume.
//     if (_activeMessageId == messageId) {
//       if (_isGeneratingAudio) return;

//       if (_audioPlayer.playing) {
//         await _audioPlayer.pause();
//         notifyListeners();
//         return;
//       }

//       if (_audioPlayer.processingState != ProcessingState.completed) {
//         await _audioPlayer.play();
//         notifyListeners();
//         return;
//       }
//     }

//     // A different response was selected. Stop the previous response first.
//     await _startNewMessage(
//       messageId: messageId,
//       text: text,
//     );
//   }

//   Future<void> _startNewMessage({
//     required String messageId,
//     required String text,
//   }) async {
//     final int operation = ++_operationId;

//     // Immediately remove the old floating player state.
//     await _stopAudioOnly();

//     if (operation != _operationId) return;

//     final cleanText = _removeSpecialFormatting(text);
//     if (cleanText.trim().isEmpty) {
//       _clearState(notify: true);
//       return;
//     }

//     _activeMessageId = messageId;
//     _isReading = true;
//     _isGeneratingAudio = true;
//     _position = Duration.zero;
//     _duration = Duration.zero;
//     notifyListeners();

//     try {
//       await _flutterTts.stop();
//       if (operation != _operationId) return;

//       await _flutterTts.setLanguage('en-US');
//       await _flutterTts.setSpeechRate(0.48);
//       await _flutterTts.setPitch(1.0);
//       await _flutterTts.setVolume(1.0);
//       await _flutterTts.awaitSynthCompletion(true);

//       if (operation != _operationId) return;

//       final fileName =
//           'beldex_ai_${DateTime.now().millisecondsSinceEpoch}.wav';

//       debugPrint('TTS FILE NAME: $fileName');

//       final result = await _flutterTts.synthesizeToFile(
//         cleanText,
//         fileName,
//         false,
//       );

//       debugPrint('TTS SYNTH RESULT: $result');

//       if (operation != _operationId) return;

//       await Future.delayed(const Duration(milliseconds: 300));

//       if (operation != _operationId) return;

//       final audioPath = await BelnetLib.audioFileGen(fileName);

//       debugPrint('TTS CACHE PATH: $audioPath');

//       if (operation != _operationId) return;

//       if (audioPath == null || audioPath.isEmpty) {
//         throw Exception('Unable to retrieve TTS audio path');
//       }

//       final audioFile = File(audioPath);

//       if (!await audioFile.exists()) {
//         throw Exception('TTS cache file does not exist');
//       }

//       final fileSize = await audioFile.length();
//       debugPrint('TTS CACHE FILE SIZE: $fileSize');

//       if (fileSize == 0) {
//         throw Exception('TTS cache file is empty');
//       }

//       if (operation != _operationId) return;

//       final duration = await _audioPlayer.setFilePath(
//         audioPath,
//         preload: true,
//       );

//       if (operation != _operationId) return;

//       debugPrint('AUDIO DURATION: $duration');

//       if (duration == null || duration == Duration.zero) {
//         throw Exception('Invalid audio duration');
//       }

//       await _audioPlayer.setSpeed(_playbackSpeed);

//       if (operation != _operationId) return;

//       _isGeneratingAudio = false;
//       _isReading = true;
//       _duration = duration;
//       _position = Duration.zero;
//       notifyListeners();

//       debugPrint('STARTING AUDIO PLAYBACK');
//       await _audioPlayer.play();
//     } catch (e, stackTrace) {
//       debugPrint('TTS ERROR: $e');
//       debugPrint('TTS STACKTRACE: $stackTrace');

//       // Ignore errors from an operation that was already replaced by another
//       // Read Aloud request.
//       if (operation != _operationId) return;

//       await _stopAudioOnly();
//       _clearState(notify: true);
//     }
//   }

//   Future<void> togglePlayPause() async {
//     if (!isVisible || _isGeneratingAudio) return;

//     if (_audioPlayer.playing) {
//       await _audioPlayer.pause();
//     } else if (_audioPlayer.processingState != ProcessingState.completed) {
//       await _audioPlayer.play();
//     }

//     notifyListeners();
//   }

//   Future<void> rewind15() async {
//     if (!isVisible || _isGeneratingAudio) return;

//     final newPosition = _position - const Duration(seconds: 15);
//     await _audioPlayer.seek(
//       newPosition < Duration.zero ? Duration.zero : newPosition,
//     );
//   }

//   Future<void> forward15() async {
//     if (!isVisible || _isGeneratingAudio) return;

//     final newPosition = _position + const Duration(seconds: 15);
//     final maxPosition = _duration;

//     await _audioPlayer.seek(
//       newPosition > maxPosition ? maxPosition : newPosition,
//     );
//   }

//   Future<void> changePlaybackSpeed() async {
//     if (!isVisible || _isGeneratingAudio) return;

//     const speeds = <double>[0.75, 1.0, 1.25, 1.5, 2.0];
//     final currentIndex = speeds.indexOf(_playbackSpeed);
//     final nextIndex = (currentIndex + 1) % speeds.length;

//     _playbackSpeed = speeds[nextIndex];
//     await _audioPlayer.setSpeed(_playbackSpeed);
//     notifyListeners();
//   }

//   /// Stops the current response and closes the floating player.
//   Future<void> close() async {
//     // Invalidate any TTS generation that is still running.
//     ++_operationId;

//     await _flutterTts.stop();
//     await _stopAudioOnly();
//     _clearState(notify: true);
//   }

//   Future<void> _stopAudioOnly() async {
//     try {
//       await _audioPlayer.stop();
//     } catch (e) {
//       debugPrint('AUDIO STOP ERROR: $e');
//     }
//   }

//   void _finishPlayback() {
//     _activeMessageId = null;
//     _isReading = false;
//     _isGeneratingAudio = false;
//     _position = Duration.zero;
//     _duration = Duration.zero;
//     notifyListeners();
//   }

//   void _clearState({required bool notify}) {
//     _activeMessageId = null;
//     _isReading = false;
//     _isGeneratingAudio = false;
//     _position = Duration.zero;
//     _duration = Duration.zero;

//     if (notify) {
//       notifyListeners();
//     }
//   }

//   String _removeSpecialFormatting(String text) {
//     return text
//         .replaceAllMapped(
//           RegExp(r'\*\*(.*?)\*\*'),
//           (match) => match.group(1) ?? '',
//         )
//         .replaceAllMapped(
//           RegExp(r'\*(.*?)\*'),
//           (match) => match.group(1) ?? '',
//         )
//         .replaceAll(RegExp(r'^•\s+', multiLine: true), '')
//         .replaceAll(RegExp(r'\$1'), '')
//         .replaceAll(RegExp(r'^\d+\.\s+', multiLine: true), '')
//         .replaceAll(RegExp(r'^#+ ', multiLine: true), '')
//         .replaceAll(RegExp(r'\n{2,}'), '\n')
//         .trim();
//   }

//   String formatDuration(Duration duration) {
//     final minutes =
//         duration.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final seconds =
//         duration.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return '$minutes:$seconds';
//   }

//   @override
//   void dispose() {
//     ++_operationId;
//     _positionSubscription?.cancel();
//     _durationSubscription?.cancel();
//     _playerStateSubscription?.cancel();
//     _audioPlayer.dispose();
//     _flutterTts.stop();
//     super.dispose();
//   }
// }