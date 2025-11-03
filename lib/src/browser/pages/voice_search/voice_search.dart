import 'dart:async';
import 'package:beldex_browser/src/browser/app_bar/search_screen.dart';
import 'package:beldex_browser/src/browser/pages/voice_search/language_picker.dart';
import 'package:beldex_browser/src/tts_provider.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// class SpeechController {
//   static final SpeechController _instance = SpeechController._internal();
//   factory SpeechController() => _instance;

//   final stt.SpeechToText _speech = stt.SpeechToText();
//   final StreamController<String> _statusController = StreamController.broadcast();
//   final StreamController<double> _soundLevelController = StreamController.broadcast();
//   final StreamController<String> _resultController = StreamController.broadcast();

//   Stream<String> get statusStream => _statusController.stream;
//   Stream<double> get soundLevelStream => _soundLevelController.stream;
//   Stream<String> get resultStream => _resultController.stream;

//   SpeechController._internal() {
//     //_init();
//   }

//   void init() async {
//     await _speech.initialize(
//       onStatus: (status) => _statusController.add(status),
//       onError: (error) => _statusController.add("error:${error.errorMsg}"),
//     );

    
//   }

//  void stopSpeech()async{
//   await _speech.stop();
//   await _speech.cancel();

//  }

//   void startListening({String localeId= 'en-US'}) {
//     _speech.listen(
//       localeId: localeId,
//       onResult: (result) {
//         _resultController.add(result.recognizedWords); // broadcast recognized text
//       },
//       listenOptions: stt.SpeechListenOptions(listenMode: stt.ListenMode.dictation),
//      // listenMode: stt.ListenMode.dictation,
//       onSoundLevelChange: (level) => _soundLevelController.add(level),
//     );
//   }

// Future<List<stt.LocaleName>> getAvailableLanguages() async {
//   return await _speech.locales();
// }


//   void restartListening(String localeId) {
//     stopListening();
//     //currentLocale = localeId;
//     startListening(localeId: localeId);
//   }

//   void stopListening() => _speech.stop();
//   bool get isListening => _speech.isListening;

//   void dispose() {
//     _statusController.close();
//     _soundLevelController.close();
//     _resultController.close();
//   }
// }

class SpeechController {
  static final SpeechController _instance = SpeechController._internal();
  factory SpeechController() => _instance;

  final stt.SpeechToText _speech = stt.SpeechToText();
  final StreamController<String> _statusController = StreamController.broadcast();
  final StreamController<double> _soundLevelController = StreamController.broadcast();
  final StreamController<String> _resultController = StreamController.broadcast();

  String _currentLocaleId = 'en-US'; // Default language for this app session

  Stream<String> get statusStream => _statusController.stream;
  Stream<double> get soundLevelStream => _soundLevelController.stream;
  Stream<String> get resultStream => _resultController.stream;

  SpeechController._internal();

  Future<void> init() async {
    await _speech.initialize(
      onStatus: (status) => _statusController.add(status),
      finalTimeout: Duration(seconds: 3),
      onError: (error) => _statusController.add("error:${error.errorMsg}"),
    );
  }

  Future<void> stopSpeech() async {
    await _speech.stop();
    await _speech.cancel();
  }

  void startListening({String? localeId}) {
    final locale = localeId ?? _currentLocaleId;
    print('THE LOCALE IS _______> $locale');
    _speech.listen(
      localeId: locale,
      onResult: (result) {
        _resultController.add(result.recognizedWords);
      },
      listenFor: Duration(seconds: 10),
      listenOptions: stt.SpeechListenOptions(listenMode: stt.ListenMode.search),
      onSoundLevelChange: (level) => _soundLevelController.add(level),
    );
  }

  Future<List<stt.LocaleName>> getAvailableLanguages() async {
    return await _speech.locales();
  }

  void restartListening(String localeId) {
    _currentLocaleId = localeId; //  Remember selected locale for this session
    stopSpeech();
    //stopListening();
    startListening(localeId: localeId);
  }

  void stopListening() => _speech.stop();
  bool get isListening => _speech.isListening;

  String get currentLocale => _currentLocaleId; //  Expose for UI if needed


void setCurrentLocale(String selectedLocale){
  _currentLocaleId = selectedLocale;
}






  void dispose() {
    _statusController.close();
    _soundLevelController.close();
    _resultController.close();
  }
}

String _getTrimmedText(String text) {
    const int maxChars = 40; // adjust as needed
    if (text.length <= maxChars) return text;
    return '...${text.substring(text.length - maxChars)}';
  }

Future<void> showVoiceDialog(
  BuildContext context,
  DarkThemeProvider themeProvider,TtsProvider ttsProvider, {
  required Function(String) onResult,
}) async {
  final speech = SpeechController();
  bool isDialogClosed = false;
  ttsProvider.updateHasResult(false);
  bool hasResult = false;
  bool isError = false;
  String message = getLocalizedMessage(speech.currentLocale,'speak'); //"Speak to search";

  await speech.init();
  speech.startListening();

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context,setstate) {
          // Lifecycle observer for app minimize
        final binding = WidgetsBinding.instance;
        final observer = _AppLifecycleObserver(
          onPaused: () async {
            // Close dialog and stop listening when app goes to background
            await speech.stopSpeech();
            print('SPEECH ONPAUSED');
            if (dialogContext.mounted && Navigator.of(dialogContext).canPop()) {
               print('SPEECH CAN POP');
              Navigator.of(dialogContext).pop();
            }
             print('SPEECH AFTERPAUSED');
          },
        );

        // Add observer when dialog opens
        binding.addObserver(observer);

        // Remove observer when dialog is disposed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // remove after dialog closes
          Future(() async {
            await Future.delayed(const Duration(milliseconds: 100));
            if (!dialogContext.mounted) {
              binding.removeObserver(observer);
            }
          });
        });
          return StreamBuilder<String>(
            stream: speech.statusStream,
            builder: (context, snapshot) {
              final status = snapshot.data ?? "";
          
              // Handle system-reported errors
              if (status.startsWith("error")) {
                message = getLocalizedMessage(speech.currentLocale,'tryAgain'); //"Couldn't hear that.\nTry again!";
                isError = true;
              }
          
              // Handle end of listening
              if (status == "done" || status == "notListening") {
                      print('Speech VALUE inside end of listener----> $isDialogClosed --- ${ttsProvider.hasVoiceResult} --- $isError');
  Future.delayed(const Duration(milliseconds: 450), () {
    if (!isDialogClosed && !ttsProvider.hasVoiceResult //hasResult 
    && !isError) {
      print('Speech VALUE IS HERE ----> $isDialogClosed --- ${ttsProvider.hasVoiceResult} --- $isError');
      isError = true;
      message = getLocalizedMessage(speech.currentLocale, 'tryAgain');
      if (context.mounted) (context as Element).markNeedsBuild();
    }
  });
}

              // if (status == "done" || status == "notListening") {
              //   // Wait briefly for last recognition event
              //   Future.delayed(const Duration(milliseconds: 400), () {
              //     if (!isDialogClosed && !hasResult && !isError) {
              //       // No words detected even after delay
              //       isError = true;
              //       message = getLocalizedMessage(speech.currentLocale,'tryAgain');// "No speech detected.\nTry again!";
              //       // Force UI rebuild
              //       (context as Element).markNeedsBuild();
              //     }
              //   });
              // }

              // Auto close only if we have valid recognized text
if (!isDialogClosed && ttsProvider.hasVoiceResult //hasResult
) {
        print('Speech VALUE inside auto close ----> $isDialogClosed --- ${ttsProvider.hasVoiceResult} --- $isError');

  isDialogClosed = true;

  // Stop speech completely before closing to prevent extra status events
  speech.stopSpeech();

  Future.microtask(() {
    if (dialogContext.mounted && Navigator.of(dialogContext).canPop()) {
            print('Speech VALUE is mounted ----> $isDialogClosed --- ${ttsProvider.hasVoiceResult} --- $isError');

      Navigator.of(dialogContext).pop();
    }
  });
}

              // if (!isDialogClosed && hasResult) {
              //   isDialogClosed = true;
              //   Future.microtask(() {
              //     if (Navigator.of(dialogContext).canPop()) {
              //       Navigator.of(dialogContext).pop();
              //     }
              //   });
              // }
          
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                backgroundColor: themeProvider.darkTheme
                    ? const Color(0xff282836)
                    : const Color(0xffFFFFFF),
                insetPadding: const EdgeInsets.only( left:20,right:20,top:20),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  width: MediaQuery.of(context).size.width,
                  height: 315,
                  //scolor: Colors.amber,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () async {
            // // Temporarily stop listening while user picks language
            // speech.stopListening();
          
            // final selectedLocale = await pickLanguage(context, themeProvider);
          
            // // If user selects a language, restart with that
            // if (selectedLocale != null) {
            //   hasResult = false;
            //   isError = false;
            //   message = getLocalizedMessage(selectedLocale,'speak'); //"Speak to search";
            //   print('Selected Locale is $selectedLocale -----> $message');
            //   speech.restartListening(selectedLocale);
              
            // } else {
            //   speech.stopSpeech();
            //   // If no language chosen, just resume listening normally
            //   speech.startListening();
            // }
          
            // // Refresh dialog UI
            // (context as Element).markNeedsBuild();
          
          
            //sspeech.stopListening();
           // await Future.delayed(const Duration(milliseconds: 100)); // small delay
          










            // final selectedLocale = await pickLanguage(context, themeProvider);
            //   hasResult = false;
            //                 isError = false;
            //                 message = getLocalizedMessage(speech.currentLocale,'speak'); //"Speak to search";
            //                 speech.startListening();
            //                 (context as Element).markNeedsBuild();


/////////////////////////////////////////////////////////////////////////////////////////////////

// await speech.stopSpeech();

//   //  Store a top-level valid context BEFORE closing the dialog
//   final rootContext = Navigator.of(context, rootNavigator: true).context;

//   //  Now close the dialog safely
//   if (context.mounted && Navigator.canPop(context)) {
//     Navigator.pop(context);
//   }

//   //  Give a short delay to allow route to pop cleanly
//   await Future.delayed(const Duration(milliseconds: 200));

//   //  Open the bottom sheet using the rootContext (not dialog context)
//   final selectedLocale = await pickLanguage(rootContext, themeProvider);
   
//   //  If a language was chosen, update speech and reopen dialog
//   // if (selectedLocale != null) {
//   //   speech.setCurrentLocale(selectedLocale);

//     await Future.delayed(const Duration(milliseconds: 200));

//     showVoiceDialog(rootContext, themeProvider, onResult: onResult);
  //}

//////////////////////////////////////////////////////////////////////////////////////////



 // Check if SearchScreen is active
 // Always check against the root navigator’s context
  final rootContext = Navigator.of(context, rootNavigator: true).context;

  // Check if the background (root) screen is SearchScreen
  if (!SearchScreen.isActive) {
    debugPrint("Voice dialog disabled — SearchScreen not active in background");
    return;
  }

  await speech.stopSpeech();

  // Close the dialog if open
  if (context.mounted && Navigator.canPop(context)) {
    Navigator.pop(context);
  }

  await Future.delayed(const Duration(milliseconds: 200));

  // Double-check again before showing picker
  if (!SearchScreen.isActive) return;
   if(!ttsProvider.hasVoiceResult)
  final selectedLocale = await pickLanguage(rootContext, themeProvider);

  // if (selectedLocale != null) {
  //   speech.setCurrentLocale(selectedLocale);

    //  Ensure still on SearchScreen before reopening
    if (SearchScreen.isActive && !ttsProvider.hasVoiceResult) {
      await Future.delayed(const Duration(milliseconds: 200));
      showVoiceDialog(rootContext, themeProvider,ttsProvider, onResult: onResult);
    }
  //}
            
            // // hasResult = false;
            // isError = false;
          
            // if (selectedLocale != null) {
            //   message = getLocalizedMessage(selectedLocale, 'speak');
            //   speech.restartListening(selectedLocale);
            // } else {
            //   message = getLocalizedMessage(speech.currentLocale, 'speak');
            //   speech.startListening();
            // }
          
            //(context as Element).markNeedsBuild();
          
          
          
          
          
          
                                // final selectedLocale =
                                //     await pickLanguage(context, themeProvider);
                                // if (selectedLocale != null) {
                                //   hasResult = false;
                                //   isError = false;
                                //   message = "Speak to search";
                                //   speech.restartListening(selectedLocale);
                                //   (context as Element).markNeedsBuild();
                                // }
                              },
                              child: SvgPicture.asset(
                                'assets/images/ai-icons/language_speech (1).svg',
                                color: themeProvider.darkTheme
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: ()async{
                               await speech.stopSpeech();
                                Navigator.pop(context);
                              },
                              child:SvgPicture.asset('assets/images/ai-icons/clear.svg', color: themeProvider.darkTheme ? Colors.white : Colors.black,) //const Icon(Icons.close),
                            ),
                          ),
                        ],
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      // Mic animation
                      isError
                          ? GestureDetector(
                            onTap: (){
                              ttsProvider.updateHasResult(false);
                              hasResult = false;
                            isError = false;
                            message = getLocalizedMessage(speech.currentLocale,'speak'); //"Speak to search";
                            speech.startListening();
                            (context as Element).markNeedsBuild();
                            },
                            child: Lottie.asset(
                                'assets/images/ai-icons/Red_mic.json',
                                height: 150,
                              ),
                          )
                          : Lottie.asset(
                              'assets/images/ai-icons/Mic.json',
                              height: 150,
                            ),
          
                      // Message text
                      // Text(
                      //   message,
                      //   textAlign: TextAlign.center,
                      //   style: TextStyle(
                      //     fontSize: 18,
                      //     color: themeProvider.darkTheme
                      //         ? Colors.white
                      //         : Colors.black,
                      //   ),
                      // ),
                    Spacer(flex: 1,),
                      //const SizedBox(height: 10),
          
                      // Retry button
                      // if (isError)
                      //   ElevatedButton.icon(
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: Colors.redAccent,
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(12),
                      //       ),
                      //     ),
                      //     onPressed: () {
                      //       hasResult = false;
                      //       isError = false;
                      //       message = "Speak to search";
                      //       speech.startListening();
                      //       (context as Element).markNeedsBuild();
                      //     },
                      //     icon: const Icon(Icons.refresh, color: Colors.white),
                      //     label: const Text(
                      //       "Retry",
                      //       style: TextStyle(color: Colors.white),
                      //     ),
                      //   ),
          
                      //const SizedBox(height: 10),
          
                      // Recognized text display
                      Flexible(
                        flex: 2,
                        child: Container(
                          height: 65,
                          margin: EdgeInsets.only(left: 20,right:20,bottom: 5),
                          //color: Colors.yellow,
                          child: StreamBuilder<String>(
                            stream: speech.resultStream,
                            builder: (context, snap) {
                              String recognized = snap.data ?? "";
                             print("Speech VALUE inside $recognized");
                          
                                if (recognized.isNotEmpty) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (!ttsProvider.hasVoiceResult) {
                                      ttsProvider.updateHasResult(true);
                                    }
                                    onResult(recognized);
                                  });
                                }
                              // if (recognized.isNotEmpty) {
                              //  ttsProvider.updateHasResult(true);
                              //   hasResult = true;
                              //   print("Speech VALUE inside hasvalue ${ttsProvider.hasVoiceResult}");
                              //   Future.microtask(() => onResult(recognized));
                              //   //recognized = "";
                              // }
                                    
                              return Text(
                               snap.data == null || snap.data!.isEmpty ? message : _getTrimmedText(snap.data ?? ""),
                                //recognized,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 15),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      //SizedBox(height: 10,)
                      //Spacer(flex: )
                    ],
                  ),
                ),
              );
            },
          );
        }
      );
    },
  );
   
}


//import 'package:flutter/material.dart';

class _AppLifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onPaused;

  _AppLifecycleObserver({required this.onPaused});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      onPaused();
    }
  }
}
