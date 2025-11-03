// import 'dart:async';

// import 'package:beldex_browser/src/browser/models/webview_model.dart';
// import 'package:beldex_browser/src/browser/pages/reading_mode/lang_list.dart';
// import 'package:beldex_browser/src/browser/pages/reading_mode/lang_provider.dart';
// import 'package:beldex_browser/src/providers.dart';
// import 'package:beldex_browser/src/tts_provider.dart';
// import 'package:beldex_browser/src/utils/show_message.dart';
// import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:html/dom.dart' as dom;
// import 'package:html/parser.dart' as html_parser;
// import 'package:provider/provider.dart';


// // class Word {
// //   final dom.Text textNode;
// //   final int start;
// //   final int end;

// //   Word({required this.textNode, required this.start, required this.end});
// // }

// // class TtsHtmlScreen extends StatefulWidget {
// //   final Map<String, dynamic> article;
// //   const TtsHtmlScreen({super.key, required this.article});

// //   @override
// //   State<TtsHtmlScreen> createState() => _TtsHtmlScreenState();
// // }

// // class _TtsHtmlScreenState extends State<TtsHtmlScreen> {
// //  final FlutterTts _tts = FlutterTts();
// //   List<Word> _words = [];
// //   int _currentIndex = 0;
// //   bool _isPlaying = false;

// //   String _htmlContent = "";
// //   String _highlightedHtml = "";

// //   @override
// //   void initState() {
// //     super.initState();
// //     _htmlContent = widget.article['content'] ?? widget.article['textContent'] ?? "";
// //     _highlightedHtml = _htmlContent;
// //     _prepareWords();
// //     _configureTts();
// //   }

// //   void _configureTts() async {
// //     await _tts.setLanguage("en-US");
// //     await _tts.setPitch(1.0);
// //     await _tts.setVolume(1.0);
// //     await _tts.setSpeechRate(0.5);
// //     await _tts.setEngine("com.google.android.tts");
     
// //     // Set completion handler to speak the next word automatically
// //     _tts.setCompletionHandler(() {
// //       if (_isPlaying && _currentIndex < _words.length - 1) {
// //         _nextWord();
// //       } else {
// //         setState(() {
// //           _isPlaying = false;
// //         });
// //       }
// //     });
// //   }

// //   void _prepareWords() {
// //     final doc = html_parser.parse(_htmlContent);
// //     _words.clear();

// //     void walk(dom.Node node) {
// //       if (node is dom.Text && node.text.trim().isNotEmpty) {
// //         final text = node.text;
// //         final wordReg = RegExp(r'\S+');
// //         for (final match in wordReg.allMatches(text)) {
// //           _words.add(Word(textNode: node, start: match.start, end: match.end));
// //         }
// //       } else if (node.hasChildNodes()) {
// //         for (var child in node.nodes) {
// //           walk(child);
// //         }
// //       }
// //     }

// //     walk(doc.body!);
// //   }

// //   void _highlightWord(Word word) {
// //     final doc = html_parser.parse(_htmlContent);

// //     dom.Text? findNode(dom.Node node, dom.Text search) {
// //       if (node is dom.Text && node.text == search.text) return node;
// //       if (node.hasChildNodes()) {
// //         for (final child in node.nodes) {
// //           final result = findNode(child, search);
// //           if (result != null) return result;
// //         }
// //       }
// //       return null;
// //     }

// //     final target = findNode(doc.body!, word.textNode);
// //     if (target != null) {
// //       final text = target.text;
// //       final before = text.substring(0, word.start);
// //       final highlight = text.substring(word.start, word.end);
// //       final after = text.substring(word.end);
// //       final fragment = html_parser.parseFragment(
// //           "$before<mark style='background:yellow;'>$highlight</mark>$after");
// //       target.replaceWith(fragment);
// //     }

// //     setState(() {
// //       _highlightedHtml = doc.body?.innerHtml ?? _htmlContent;
// //     });
// //   }

// //   Future<void> _speakWord(Word word) async {
// //     await _tts.stop();
// //     await _tts.speak(word.textNode.text.substring(word.start, word.end));
// //     _highlightWord(word);
// //   }

// //   void _nextWord() {
// //     if (_currentIndex < _words.length - 1) {
// //       setState(() {
// //         _currentIndex++;
// //         _isPlaying = true;
// //       });
// //       _speakWord(_words[_currentIndex]);
// //     } else {
// //       setState(() {
// //         _isPlaying = false;
// //       });
// //     }
// //   }

// //   void _previousWord() {
// //     if (_currentIndex > 0) {
// //       setState(() {
// //         _currentIndex--;
// //         _isPlaying = true;
// //       });
// //       _speakWord(_words[_currentIndex]);
// //     } else {
// //       setState(() {
// //         _isPlaying = false;
// //       });
// //     }
// //   }

// //   void _togglePlayPause() {
// //     if (_isPlaying) {
// //       _tts.stop();
// //       setState(() {
// //         _isPlaying = false;
// //       });
// //     } else {
// //       setState(() {
// //         _isPlaying = true;
// //       });
// //       _speakWord(_words[_currentIndex]);
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _tts.stop();
// //     super.dispose();
// //   }
// //   @override
// //   Widget build(BuildContext context) {
// //     final themeProvider = Provider.of<DarkThemeProvider>(context);
// //     final width = MediaQuery.of(context).size.width;
// //     final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
// //     final ttsProvider = Provider.of<TtsProvider>(context);
// //     var webViewModel = Provider.of<WebViewModel>(context, listen: true);
// //     var webViewController = webViewModel.webViewController;

// //     return SafeArea(
// //       child: Container(
// //         child: DraggableScrollableSheet(
// //           initialChildSize: 0.95,
// //           minChildSize: 0.3,
// //           maxChildSize: 0.95,
// //           builder: (context, scrollController) {
// //             return LayoutBuilder(builder: (context, constraint) {
// //               return Container(
// //                 padding: EdgeInsets.only(
// //                     bottom: MediaQuery.of(context).viewInsets.bottom),
// //                 decoration: BoxDecoration(
// //                   borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //                   border: Border(
// //                       top: BorderSide(
// //                           color: themeProvider.darkTheme
// //                               ? Color(0xff42425F)
// //                               : Color(0xffDADADA),
// //                           width: 0.5)),
// //                   color: themeProvider.darkTheme
// //                       ? Color(0xff171720)
// //                       : Color(0xffFFFFFF),
// //                 ),
// //                 child: Stack(
// //                   children: [
// //                     Column(
// //                       children: [
// //                         Column(
// //                           children: [
// //                             vpnStatusProvider.changeReaderMenu
// //                                 ? Row(
// //                                     mainAxisAlignment:
// //                                         MainAxisAlignment.spaceBetween,
// //                                     children: [
// //                                       menuOptions('assets/images/back.svg',
// //                                           themeProvider, () {
// //                                         vpnStatusProvider
// //                                             .updateReaderMenu(false);
// //                                         _tts.stop();
// //                                       }),
// //                                       Row(
// //                                         mainAxisAlignment:
// //                                             MainAxisAlignment.center,
// //                                         children: [
// //                                           menuOptions(
// //                                               'assets/images/ai-icons/prev_enabled.svg',
// //                                               themeProvider,
// //                                               _previousWord),
// //                                           menuOptions(
// //                                               _isPlaying
// //                                                   ? 'assets/images/ai-icons/Pause.svg'
// //                                                   : 'assets/images/ai-icons/Play.svg',
// //                                               themeProvider,
// //                                               _togglePlayPause),
// //                                           menuOptions(
// //                                               'assets/images/ai-icons/end_enabled.svg',
// //                                               themeProvider,
// //                                               _nextWord)
// //                                         ],
// //                                       ),
// //                                       Icon(
// //                                         Icons.arrow_back,
// //                                         color: Colors.transparent,
// //                                       )
// //                                     ],
// //                                   )
// //                                 : Row(
// //                                     mainAxisAlignment: MainAxisAlignment.end,
// //                                     children: [
// //                                       menuOptions(
// //                                           'assets/images/ai-icons/translate.svg',
// //                                           themeProvider,
// //                                           () {
// //                                             // _translateWithAI(ttsProvider);
// //                                           }),
// //                                       menuOptions(
// //                                           'assets/images/ai-icons/read.svg',
// //                                           themeProvider,
// //                                           () => vpnStatusProvider
// //                                               .updateReaderMenu(true)),
// //                                       PopupMenuButton<String>(
// //                                         icon: SvgPicture.asset(
// //                                           'assets/images/ai-icons/font.svg',
// //                                           color: themeProvider.darkTheme
// //                                               ? Colors.white
// //                                               : Colors.black,
// //                                         ),
// //                                         color: themeProvider.darkTheme
// //                                             ? const Color(0xff282836)
// //                                             : const Color(0xffF3F3F3),
// //                                         offset: Offset(width / 5.0, width / 7.2),
// //                                         surfaceTintColor: themeProvider.darkTheme
// //                                             ? const Color(0xff282836)
// //                                             : const Color(0xffF3F3F3),
// //                                         elevation: 2,
// //                                         shape: const RoundedRectangleBorder(
// //                                           borderRadius: BorderRadius.only(
// //                                             bottomLeft: Radius.circular(15.0),
// //                                             bottomRight: Radius.circular(15.0),
// //                                             topLeft: Radius.circular(15.0),
// //                                             topRight: Radius.circular(15.0),
// //                                           ),
// //                                         ),
// //                                         itemBuilder: (context) => [
// //                                           PopupMenuItem(
// //                                             enabled: true,
// //                                             padding: EdgeInsets.zero,
// //                                             child: SizedBox(
// //                                               width: 220,
// //                                               child: Column(
// //                                                 crossAxisAlignment:
// //                                                     CrossAxisAlignment.start,
// //                                                 children: [
// //                                                   Padding(
// //                                                     padding:
// //                                                         EdgeInsets.symmetric(
// //                                                             horizontal: 8,
// //                                                             vertical: 8),
// //                                                     child: Text(
// //                                                       "Text Zoom",
// //                                                       style: TextStyle(
// //                                                           color: themeProvider
// //                                                                   .darkTheme
// //                                                               ? Colors.white
// //                                                               : Colors.black),
// //                                                     ),
// //                                                   ),
// //                                                   Consumer<VpnStatusProvider>(
// //                                                     builder: (context,
// //                                                         vpnStatusProvider, _) {
// //                                                       return SliderTheme(
// //                                                         data: SliderThemeData(
// //                                                           trackHeight: 3,
// //                                                           padding:
// //                                                               const EdgeInsets
// //                                                                   .symmetric(
// //                                                                   horizontal: 8),
// //                                                           inactiveTrackColor:
// //                                                               themeProvider
// //                                                                       .darkTheme
// //                                                                   ? const Color(
// //                                                                       0xff363645)
// //                                                                   : const Color(
// //                                                                       0xffDADADA),
// //                                                           thumbShape:
// //                                                               const RoundSliderThumbShape(
// //                                                             enabledThumbRadius:
// //                                                                 6.0,
// //                                                             pressedElevation: 2.0,
// //                                                           ),
// //                                                           trackShape:
// //                                                               const RoundedRectSliderTrackShape(),
// //                                                           overlayShape:
// //                                                               const RoundSliderOverlayShape(
// //                                                             overlayRadius: 12.0,
// //                                                           ),
// //                                                         ),
// //                                                         child: Slider(
// //                                                           value: vpnStatusProvider
// //                                                               .fontSize,
// //                                                           min: 8.0,
// //                                                           max: 20.0,
// //                                                           activeColor:
// //                                                               const Color(
// //                                                                   0xff00BD40),
// //                                                           divisions: 120,
// //                                                           onChanged: (value) {
// //                                                             vpnStatusProvider
// //                                                                 .updateReaderContentFontSize(
// //                                                                     value);
// //                                                           },
// //                                                         ),
// //                                                       );
// //                                                     },
// //                                                   ),
// //                                                   Padding(
// //                                                     padding: const EdgeInsets
// //                                                         .symmetric(
// //                                                         horizontal: 8.0),
// //                                                     child: Row(
// //                                                       mainAxisAlignment:
// //                                                           MainAxisAlignment
// //                                                               .spaceBetween,
// //                                                       children: [
// //                                                         percentageText(
// //                                                             themeProvider,
// //                                                             '50%'),
// //                                                         percentageText(
// //                                                             themeProvider,
// //                                                             '100%'),
// //                                                         percentageText(
// //                                                             themeProvider,
// //                                                             '200%'),
// //                                                       ],
// //                                                     ),
// //                                                   ),
// //                                                   SizedBox(height: 5),
// //                                                 ],
// //                                               ),
// //                                             ),
// //                                           ),
// //                                         ],
// //                                       ),
// //                                       menuOptions('assets/images/ai-icons/theme.svg',
// //                                           themeProvider, () {
// //                                         themeProvider.darkTheme =
// //                                             !themeProvider.darkTheme;
// //                                       }),
// //                                       menuOptions(
// //                                           'assets/images/ai-icons/clear.svg',
// //                                           themeProvider,
// //                                           () {
// //                                             Navigator.pop(context);
// //                                           }),
// //                                     ],
// //                                   ),
// //                             Divider(
// //                               color: themeProvider.darkTheme
// //                                   ? Color(0xff42425F)
// //                                   : Color(0xffDADADA),
// //                             ),
// //                           ],
// //                         ),
// //                         // if (title.isNotEmpty) ...[
// //                         //   Text(
// //                         //     title,
// //                         //     maxLines: 2,
// //                         //     overflow: TextOverflow.ellipsis,
// //                         //     style: TextStyle(
// //                         //         fontSize: vpnStatusProvider.fontSize + 12),
// //                         //   ),
// //                         // ],
// //                         Expanded(
// //                           child: SingleChildScrollView(
// //                             padding: const EdgeInsets.all(16),
// //                             child: Html(
// //                               data: _highlightedHtml,
// //                               style: {
// //                                 "body": Style(
// //                                   fontSize:
// //                                       FontSize(vpnStatusProvider.fontSize),
// //                                   textAlign: TextAlign.justify,
// //                                   lineHeight: LineHeight(1.5),
// //                                 ),
// //                                 "mark": Style(
// //                                     backgroundColor: Color(0xff00BD40),
// //                                     color: Colors.white),
// //                                 "img": Style(
// //                                   display: Display.block,
// //                                   margin: Margins.symmetric(
// //                                       horizontal: 12, vertical: 12),
// //                                   height: Height(
// //                                       MediaQuery.of(context).size.height * 1 / 3),
// //                                   width: Width(MediaQuery.of(context).size.width),
// //                                   padding: HtmlPaddings(right: HtmlPadding(40)),
// //                                 ),
// //                               },
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                     ttsProvider.isContentTranslating
// //                         ? Center(
// //                             child: CircularProgressIndicator(color: Colors.green))
// //                         : Container(),
// //                   ],
// //                 ),
// //               );
// //             });
// //           },
// //         ),
// //       ),
// //     );
// //   }

// //   Text percentageText(DarkThemeProvider themeProvider, String text) => Text(
// //         text,
// //         style: TextStyle(
// //             fontSize: 10,
// //             fontWeight: FontWeight.w500,
// //             color: themeProvider.darkTheme ? Colors.white : Colors.black),
// //       );

// //   IconButton menuOptions(
// //       String icon, DarkThemeProvider themeProvider, VoidCallback onPressed) {
// //     return IconButton(
// //       onPressed: onPressed,
// //       icon: SvgPicture.asset(
// //         icon,
// //         color: themeProvider.darkTheme ? Colors.white : Colors.black,
// //       ),
// //     );
// //   }
// // }




// import 'package:flutter/foundation.dart'; // For compute

// class HighlightParams {
//   final String html;
//   final List<int> path;
//   final int start;
//   final int end;

//   HighlightParams({
//     required this.html,
//     required this.path,
//     required this.start,
//     required this.end,
//   });
// }

// String highlightWord(HighlightParams params) {
//   final doc = html_parser.parse(params.html);

//   dom.Text? findNodeByPath(dom.Node root, List<int> path) {
//     var current = root;
//     for (int i in path) {
//       if (current is dom.Element && i < current.nodes.length) {
//         current = current.nodes[i];
//       } else {
//         return null;
//       }
//     }
//     return current is dom.Text ? current : null;
//   }

//   final target = findNodeByPath(doc.body!, params.path);
//   if (target != null) {
//     final text = target.text;
//     final before = text.substring(0, params.start);
//     final highlight = text.substring(params.start, params.end);
//     final after = text.substring(params.end);
//     final fragment = html_parser.parseFragment(
//         "$before<mark style='background:yellow;'>$highlight</mark>$after");
//     target.replaceWith(fragment);
//   }

//   return doc.body?.innerHtml ?? params.html;
// }

// class Word {
//   final dom.Text textNode;
//   final int start;
//   final int end;
//   final int globalIndex;  // Sequential index from traversal order

//   Word({
//     required this.textNode,
//     required this.start,
//     required this.end,
//     required this.globalIndex,
//   });
// }

// class TtsHtmlScreen extends StatefulWidget {
//   final Map<String, dynamic> article;
//   const TtsHtmlScreen({super.key, required this.article});

//   @override
//   State<TtsHtmlScreen> createState() => _TtsHtmlScreenState();
// }

// class _TtsHtmlScreenState extends State<TtsHtmlScreen> {
//  final FlutterTts _tts = FlutterTts();
//   List<Word> _words = [];
//   List<List<Word>> _sentences = [];
//   late final dom.Document _doc;
//   int _sentenceIndex = 0;
//   int _wordIndexInSentence = 0;
//   int _currentUtteranceStartWord = 0;
//   bool _isPlaying = false;

//   String _htmlContent = "";
//   String _title = '';
//   String _highlightedHtml = "";

//   double _speechRate = 0.5; // Lowered from 0.7 to make speech slower

//  late Connectivity _connectivity;
//   late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;


//  List<String> _languages = [];
//   String? selectedLocale = 'en-US'; // default selected

//   @override
//   void initState() {
//     super.initState();
//     _htmlContent = widget.article['content'] ?? widget.article['textContent'] ?? "";
//     _title = widget.article['title'] ?? '';
//     // Combine title with content
//     final combinedContent = _title.isNotEmpty 
//         ? '<h2 style="text-align: center; margin-bottom: 20px;">${_title}</h2>\n$_htmlContent'
//         : _htmlContent;
//     _htmlContent = combinedContent;
//     _highlightedHtml = _htmlContent;
//     _doc = html_parser.parse(_htmlContent); // Parse once, clean doc
//     _prepareWords();
//     _prepareSentences();
//     _configureTts();
//     //getAvailableLanguages();


// checkForNetwork(Provider.of<VpnStatusProvider>(context,listen: false));
//     // Removed initial highlight
//   }

// checkForNetwork(VpnStatusProvider vpnStatusProvider){
//   _connectivity = Connectivity();
//     _connectivitySubscription = _connectivitySubscription =
//         _connectivity.onConnectivityChanged.listen((event) {
//       if (!(event.contains(ConnectivityResult.wifi)) && !(event.contains(ConnectivityResult.mobile))) {
//         vpnStatusProvider.setTTSStatus(true);
//          _tts.stop();
//         _clearHighlight();
//          showMessage("You are not connected to the internet. Make sure WiFi/Mobile data is on");
//       }else{
//         vpnStatusProvider.setTTSStatus(false);
       
//       }
//     });
// }

// // getAvailableLanguages()async{
// // final langs = await _tts.getLanguages;
// //     setState(() {
// //       _languages = langs.cast<String>();
// //     });
// //     for(int i=0;i<=_languages.length;i++)
// //     print('All Langauges -> ${_languages.length} ${_languages[i]}');
// //     // Optionally set default language
// //     if (_languages.isNotEmpty) {
// //       _selectedLanguage = _languages.first;
// //       await _tts.setLanguage(_selectedLanguage!);
// //     }
// // }



// //   Future<void> _onSelectLanguage(String lang) async {
// //     await _tts.setLanguage(lang);
// //     setState(() {
// //       _selectedLanguage = lang;
// //     });
// //   }





//   Future<void> _configureTts() async {
//     await _tts.setLanguage("en-US");
//     await _tts.setPitch(1.0);
//     await _tts.setVolume(1.0);
//     await _tts.setSpeechRate(_speechRate);
//     await _tts.setEngine("com.google.android.tts");

//     _tts.setProgressHandler((String text, int start, int end, String word) {
//       print('TTS Text $text --$start $end $word');
//       // int cum = 0;
//       // final sentenceLength = _sentences[_sentenceIndex].length;
//       // final numWordsInUtterance = sentenceLength - _currentUtteranceStartWord;
//       // for (int li = 0; li < numWordsInUtterance; li++) {
//       //   final wordLen = _sentences[_sentenceIndex][_currentUtteranceStartWord + li].end -
//       //       _sentences[_sentenceIndex][_currentUtteranceStartWord + li].start;
//       //   if (start < cum + wordLen) {
//       //     setState(() {
//       //       _wordIndexInSentence = _currentUtteranceStartWord + li;
//       //       _highlightWord(_sentences[_sentenceIndex][_wordIndexInSentence]);
//       //     });
//       //     break;
//       //   }
//       //   cum += wordLen + (li < numWordsInUtterance - 1 ? 1 : 0); // Assuming space between words
//       // }
//     });

//     _tts.setCompletionHandler(() {
//       if (_isPlaying && _sentenceIndex < _sentences.length - 1) {
//         _nextWord();
//       } else {
//         setState(() {
//           _isPlaying = false;
//         });
//         _clearHighlight();
//       }
//     });
//   }

//   void _prepareWords() {
//     _words.clear();
//     int globalIndex = 0;

//     void walk(dom.Node node) {
//       if (node is dom.Text && node.text.trim().isNotEmpty) {
//         final text = node.text;
//         final wordReg = RegExp(r'\S+');
//         for (final match in wordReg.allMatches(text)) {
//           _words.add(Word(
//             textNode: node,
//             start: match.start,
//             end: match.end,
//             globalIndex: globalIndex++,
//           ));
//         }
//       } else if (node.hasChildNodes()) {
//         for (var child in node.nodes) {
//           walk(child);
//         }
//       }
//     }

//     walk(_doc.body!);
//   }

//   void _prepareSentences() {
//     _sentences.clear();
//     List<Word> currentSentence = [];

//     for (int i = 0; i < _words.length; i++) {
//       final word = _words[i];
//       final wordText = word.textNode.text.substring(word.start, word.end).trim();
//       currentSentence.add(word);

//       if (RegExp(r'[.!?]$').hasMatch(wordText) || i == _words.length - 1) {
//         _sentences.add(List.from(currentSentence));
//         currentSentence.clear();
//       }
//     }
//   }

//   bool _findAndHighlight(dom.Node node, int targetIndex) {
//     if (node is dom.Text && node.text.trim().isNotEmpty) {
//       final wordReg = RegExp(r'\S+');
//       for (final match in wordReg.allMatches(node.text)) {
//         if (targetIndex == 0) {  // This is the target word
//           final before = node.text.substring(0, match.start);
//           final highlight = node.text.substring(match.start, match.end);
//           final after = node.text.substring(match.end);

//           final fragment = html_parser.parseFragment(
//               "$before<mark style='background:yellow;'>$highlight</mark>$after");
//           node.replaceWith(fragment);
//           return true; // Found and highlighted
//         }
//         targetIndex--;
//       }
//     } else if (node.hasChildNodes()) {
//       for (var child in node.nodes) {
//         if (_findAndHighlight(child, targetIndex)) {
//           return true; // Stop after finding
//         }
//       }
//     }
//     return false;
//   }

//   void _highlightWord(Word word) {
//     final clonedDoc = _doc.clone(true); // Clone clean doc each time
//     _findAndHighlight(clonedDoc.body!, word.globalIndex);
//     setState(() {
//       _highlightedHtml = clonedDoc.body?.innerHtml ?? _htmlContent;
//     });
//   }

//   void _clearHighlight() {
//     setState(() {
//       _highlightedHtml = _doc.body?.innerHtml ?? _htmlContent;
//     });
//   }

//   String _getRemainingSentenceText(int sentenceIdx, int startWord) {
//     final words = _sentences[sentenceIdx].sublist(startWord);
//     return words.map((w) {
//       String wordStr = w.textNode.text.substring(w.start, w.end);
//       // Remove trailing punctuation for smoother speech (e.g., "end." -> "end")
//       wordStr = wordStr.replaceAll(RegExp(r'([.!?,;:]+)$'), '');
//       // Optionally remove other special chars if needed, but keep hyphens in words
//       wordStr = wordStr.replaceAll(RegExp(r'[^\w\s-]'), ' ');
//       return wordStr.trim();
//     }).join(' ');
//   }

//   void _playFromCurrentPosition() {
//     final sentLen = _sentences.isNotEmpty ? _sentences[_sentenceIndex].length : 0;
//     if (_sentenceIndex < _sentences.length && _wordIndexInSentence < sentLen) {
//       _playSentence(_sentenceIndex, startWord: _wordIndexInSentence);
//     } else if (_sentenceIndex + 1 < _sentences.length) {
//       _playSentence(_sentenceIndex + 1);
//     } else {
//       _playSentence(0);
//     }
//   }

//   void _playSentence(int sentenceIdx, {int startWord = 0}) {
//     if (sentenceIdx < 0 || sentenceIdx >= _sentences.length) return;

//     _sentenceIndex = sentenceIdx;
//     _wordIndexInSentence = startWord;
//     _currentUtteranceStartWord = startWord;

//     final text = _getRemainingSentenceText(sentenceIdx, startWord);
//     if (text.isEmpty) return;

//     _tts.speak(text);

//     if (_sentences[sentenceIdx].length > startWord) {
//       _highlightWord(_sentences[sentenceIdx][startWord]);
//     }
//   }

//   void _nextWord() {
//     // Stop current if playing
//     if (_isPlaying) {
//       _tts.stop();
//     }

//     final currentSentLen = _sentences[_sentenceIndex].length;
//     if (_wordIndexInSentence < currentSentLen - 1) {
//       // Next word in same sentence
//       _wordIndexInSentence++;
//     } else if (_sentenceIndex < _sentences.length - 1) {
//       // Next sentence
//       _sentenceIndex++;
//       _wordIndexInSentence = 0;
//     } else {
//       // End of content
//       setState(() {
//         _isPlaying = false;
//       });
//       _clearHighlight();
//       return;
//     }

//     setState(() {
//       _isPlaying = true;
//     });
//     _playFromCurrentPosition();
//   }

//   void _previousWord() {
//     // Stop current if playing
//     if (_isPlaying) {
//       _tts.stop();
//     }

//     if (_wordIndexInSentence > 0) {
//       // Previous word in same sentence
//       _wordIndexInSentence--;
//     } else if (_sentenceIndex > 0) {
//       // Previous sentence, start from last word
//       _sentenceIndex--;
//       _wordIndexInSentence = _sentences[_sentenceIndex].length - 1;
//     } else {
//       // Beginning of content
//       return;
//     }

//     setState(() {
//       _isPlaying = true;
//     });
//     _playFromCurrentPosition();
//   }

//   void _togglePlayPause() {
//     if (_isPlaying) {
//       _tts.stop();
//       setState(() {
//         _isPlaying = false;
//       });
//       _clearHighlight(); // Clear highlight on pause
//     } else {
//       setState(() {
//         _isPlaying = true;
//       });
//       _playFromCurrentPosition();
//     }
//   }

//   @override
//   void dispose() {
//     _clearHighlight();
//     _tts.stop();
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<DarkThemeProvider>(context);
//     final width = MediaQuery.of(context).size.width;
//     final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
//     final ttsProvider = Provider.of<TtsProvider>(context);
//     var webViewModel = Provider.of<WebViewModel>(context, listen: true);
//     var webViewController = webViewModel.webViewController;
//     var languageProvider = Provider.of<LanguageProvider>(context);
//     return SafeArea(
//       child: Container(
//         child: DraggableScrollableSheet(
//           initialChildSize: 0.95,
//           minChildSize: 0.3,
//           maxChildSize: 0.95,
//           builder: (context, scrollController) {
//             return LayoutBuilder(builder: (context, constraint) {
//               return Container(
//                 padding: EdgeInsets.only(
//                     bottom: MediaQuery.of(context).viewInsets.bottom),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                   border: Border(
//                       top: BorderSide(
//                           color: themeProvider.darkTheme
//                               ? Color(0xff42425F)
//                               : Color(0xffDADADA),
//                           width: 0.5)),
//                   color: themeProvider.darkTheme
//                       ? Color(0xff171720)
//                       : Color(0xffFFFFFF),
//                 ),
//                 child: Stack(
//                   children: [
//                     Column(
//                       children: [
//                         Column(
//                           children: [
//                             vpnStatusProvider.changeReaderMenu
//                                 ? Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       menuOptions('assets/images/back.svg',
//                                           themeProvider, () {

//                                         vpnStatusProvider
//                                             .updateReaderMenu(false);
//                                         _tts.stop();
//                                         _clearHighlight();
//                                       }),
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           menuOptions(
//                                               'assets/images/ai-icons/prev_enabled.svg',
//                                               themeProvider,
//                                              vpnStatusProvider.isTTSDisabled ? (){} : _previousWord),
//                                           menuOptions(
//                                               _isPlaying
//                                                   ? 'assets/images/ai-icons/Pause.svg'
//                                                   : 'assets/images/ai-icons/Play.svg',
//                                               themeProvider,
//                                              vpnStatusProvider.isTTSDisabled ? (){} : _togglePlayPause),
//                                           menuOptions(
//                                               'assets/images/ai-icons/end_enabled.svg',
//                                               themeProvider,
//                                              vpnStatusProvider.isTTSDisabled ? (){} : _nextWord)
//                                         ],
//                                       ),
//                                       Icon(
//                                         Icons.arrow_back,
//                                         color: Colors.transparent,
//                                       )
//                                     ],
//                                   )
//                                 : Row(
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     children: [


//                                       PopupMenuButton<String>(
//                                         icon: SvgPicture.asset(
//                                           'assets/images/ai-icons/translate.svg',
//                                           color: themeProvider.darkTheme
//                                               ? Colors.white
//                                               : Colors.black,
//                                         ),
//                                         color: themeProvider.darkTheme
//                                             ? const Color(0xff282836)
//                                             : const Color(0xffF3F3F3),
//                                         offset: Offset(width / 5.0, width / 7.2),
//                                         surfaceTintColor: themeProvider.darkTheme
//                                             ? const Color(0xff282836)
//                                             : const Color(0xffF3F3F3),
//                                         elevation: 2,
//                                         shape: const RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.only(
//                                             bottomLeft: Radius.circular(15.0),
//                                             bottomRight: Radius.circular(15.0),
//                                             topLeft: Radius.circular(15.0),
//                                             topRight: Radius.circular(15.0),
//                                           ),
//                                         ),
//                                        onSelected: (value) {
//                                                     languageProvider.selectLanguage(value);
//             // setState(() {
//             //   selectedLocale = value;
//             // });
//           },
//                                         itemBuilder: (context) => [
//             PopupMenuItem(
//               enabled: true,
//               child: SizedBox(
//                 width: 200, // control width
//                 height: 250, // control height
//                 child: Consumer<LanguageProvider>(
//                   builder: (context,languageProvider,_) {
//                     return Scrollbar(
//                       thumbVisibility: true,
//                       child: ListView.builder(
//                         itemCount: languageProvider.localeToName.length,
//                         shrinkWrap: true,
//                         padding: EdgeInsets.zero,
//                         itemBuilder: (context, index) {
//                           final entry = localeToName.entries.elementAt(index);
//                       final isSelected = languageProvider.selectedLocale == entry.key;
//                           return InkWell(
//                             onTap: () {
//                               languageProvider.selectLanguage(entry.key);
//                               Navigator.pop(context);
//                               // setState(() {
//                               //   selectedLocale = entry.key;
//                               // });
//                             },
//                             child: Container(
//                               decoration: BoxDecoration(
//                                   color: isSelected ? themeProvider.darkTheme ? Color(0xff39394B) : Color(0xffFFFFFF) : Colors.transparent,
//                                   borderRadius: BorderRadius.circular(3)
//                                 ),
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                     vertical: 8.0, horizontal: 8.0),
//                                 child: Row(
//                                   children: [
                                   
                                   
//                                     Expanded(
//                                       child: Text(
//                                         entry.value,
//                                         overflow: TextOverflow.ellipsis,
//                                         style: TextStyle(color: themeProvider.darkTheme ? Colors.white : Colors.black),
//                                       ),
//                                     ),
//                                      const SizedBox(width: 10),
//                                      isSelected ? SvgPicture.asset('assets/images/tick.svg') : SizedBox.shrink()
//                                     //  Container(
//                                     //   width: 15,
//                                     //   height: 15,
//                                     //   decoration: BoxDecoration(
//                                     //     color: isSelected
//                                     //         ? Colors.green
//                                     //         : Colors.transparent,
//                                     //     border: Border.all(
//                                     //       color: Colors.grey,
//                                     //     ),
//                                     //     borderRadius: BorderRadius.circular(4),
//                                     //   ),
//                                     //   child: isSelected
//                                     //       ? const Icon(
//                                     //           Icons.check,
//                                     //           size: 16,
//                                     //           color: Colors.white,
//                                     //         )
//                                     //       : null,
//                                     // ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                         // children: languageProvider.localeToName.entries.map((entry) {
//                         //   final isSelected = selectedLocale == entry.key;
                          
//                         // }).toList(),
//                       ),
//                     );
//                   }
//                 ),
//               ),
//             ),
          
//                                         ]
//             //                             {

                                        
//             //                               return _languages.map((lang) {
//             //   return CheckedPopupMenuItem<String>(
//             //     value: lang,
//             //     checked: _selectedLanguage == lang,
//             //     child: Text(lang),
//             //   );
//             // }).toList();}
                                        
//                                       ),
//                                       // menuOptions(
//                                       //     'assets/images/ai-icons/translate.svg',
//                                       //     themeProvider,
//                                       //     () {
//                                       //       // _translateWithAI(ttsProvider);
//                                       //     }),
//                                       menuOptions(
//                                           'assets/images/ai-icons/read.svg',
//                                           themeProvider,
//                                           () => vpnStatusProvider
//                                               .updateReaderMenu(true)),
//                                       PopupMenuButton<String>(
//                                         icon: SvgPicture.asset(
//                                           'assets/images/ai-icons/font.svg',
//                                           color: themeProvider.darkTheme
//                                               ? Colors.white
//                                               : Colors.black,
//                                         ),
//                                         color: themeProvider.darkTheme
//                                             ? const Color(0xff282836)
//                                             : const Color(0xffF3F3F3),
//                                         offset: Offset(width / 5.0, width / 7.2),
//                                         surfaceTintColor: themeProvider.darkTheme
//                                             ? const Color(0xff282836)
//                                             : const Color(0xffF3F3F3),
//                                         elevation: 2,
//                                         shape: const RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.only(
//                                             bottomLeft: Radius.circular(15.0),
//                                             bottomRight: Radius.circular(15.0),
//                                             topLeft: Radius.circular(15.0),
//                                             topRight: Radius.circular(15.0),
//                                           ),
//                                         ),
//                                         itemBuilder: (context) => [
//                                           PopupMenuItem(
//                                             enabled: true,
//                                             padding: EdgeInsets.zero,
//                                             child: SizedBox(
//                                               width: 220,
//                                               child: Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   Padding(
//                                                     padding:
//                                                         EdgeInsets.symmetric(
//                                                             horizontal: 8,
//                                                             vertical: 8),
//                                                     child: Text(
//                                                       "Text Zoom",
//                                                       style: TextStyle(
//                                                           color: themeProvider
//                                                                   .darkTheme
//                                                               ? Colors.white
//                                                               : Colors.black),
//                                                     ),
//                                                   ),
//                                                   Consumer<VpnStatusProvider>(
//                                                     builder: (context,
//                                                         vpnStatusProvider, _) {
//                                                       return SliderTheme(
//                                                         data: SliderThemeData(
//                                                           trackHeight: 3,
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .symmetric(
//                                                                   horizontal: 8),
//                                                           inactiveTrackColor:
//                                                               themeProvider
//                                                                       .darkTheme
//                                                                   ? const Color(
//                                                                       0xff363645)
//                                                                   : const Color(
//                                                                       0xffDADADA),
//                                                           thumbShape:
//                                                               const RoundSliderThumbShape(
//                                                             enabledThumbRadius:
//                                                                 6.0,
//                                                             pressedElevation: 2.0,
//                                                           ),
//                                                           trackShape:
//                                                               const RoundedRectSliderTrackShape(),
//                                                           overlayShape:
//                                                               const RoundSliderOverlayShape(
//                                                             overlayRadius: 12.0,
//                                                           ),
//                                                         ),
//                                                         child: Slider(
//                                                           value: vpnStatusProvider
//                                                               .fontSize,
//                                                           min: 8.0,
//                                                           max: 20.0,
//                                                           activeColor:
//                                                               const Color(
//                                                                   0xff00BD40),
//                                                           divisions: 120,
//                                                           onChanged: (value) {
//                                                             vpnStatusProvider
//                                                                 .updateReaderContentFontSize(
//                                                                     value);
//                                                           },
//                                                         ),
//                                                       );
//                                                     },
//                                                   ),
//                                                   Padding(
//                                                     padding: const EdgeInsets
//                                                         .symmetric(
//                                                         horizontal: 8.0),
//                                                     child: Row(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .spaceBetween,
//                                                       children: [
//                                                         percentageText(
//                                                             themeProvider,
//                                                             '50%'),
//                                                         percentageText(
//                                                             themeProvider,
//                                                             '100%'),
//                                                         percentageText(
//                                                             themeProvider,
//                                                             '200%'),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 5),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       menuOptions('assets/images/ai-icons/theme.svg',
//                                           themeProvider, () {
//                                         themeProvider.darkTheme =
//                                             !themeProvider.darkTheme;
//                                       }),
//                                       menuOptions(
//                                           'assets/images/ai-icons/clear.svg',
//                                           themeProvider,
//                                           () {
//                                             Navigator.pop(context);
//                                           }),
//                                     ],
//                                   ),
//                             Divider(
//                               color: themeProvider.darkTheme
//                                   ? Color(0xff42425F)
//                                   : Color(0xffDADADA),
//                             ),
//                           ],
//                         ),
//                         Expanded(
//                           child: SingleChildScrollView(
//                             padding: const EdgeInsets.all(16),
//                             child:Html(
//                 data: _highlightedHtml,
//                 style: {
//                   "body": Style(
//                     fontSize: FontSize(vpnStatusProvider.fontSize),
//                     textAlign: TextAlign.justify,
//                     lineHeight: LineHeight(1.5),
//                   ),
//                   "h2": Style(
//                     fontSize: FontSize(20.0),
//                     fontWeight: FontWeight.bold,
//                     textAlign: TextAlign.center,
//                     margin: Margins.only(bottom: 20),
//                   ),
//                   "mark": Style(backgroundColor: Color(0xff00BD40), color: Colors.white),
//                   "a mark": Style(backgroundColor: Color(0xff00BD40), color: Colors.white), // Ensure highlighting works inside links
//                   "img": Style(
//                     display: Display.block,
//                     margin: Margins.symmetric(horizontal: 12, vertical: 12),
//                     height: Height(MediaQuery.of(context).size.height * 1 / 3),
//                     width: Width(MediaQuery.of(context).size.width),
//                     padding: HtmlPaddings(right: HtmlPadding(40)),
//                   ),
//                 },
//                 onLinkTap:(url, attributes, element) {
//                   if(url != null){
//                      webViewController!
//                             .loadUrl(urlRequest: URLRequest(url: WebUri(url)));
//                   Navigator.pop(context);

//                   }
//                 },
//               ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     ttsProvider.isContentTranslating
//                         ? Center(
//                             child: CircularProgressIndicator(color: Colors.green))
//                         : Container(),
//                   ],
//                 ),
//               );
//             });
//           },
//         ),
//       ),
//     );
//   }

//   Text percentageText(DarkThemeProvider themeProvider, String text) => Text(
//         text,
//         style: TextStyle(
//             fontSize: 10,
//             fontWeight: FontWeight.w500,
//             color: themeProvider.darkTheme ? Colors.white : Colors.black),
//       );

//   IconButton menuOptions(
//       String icon, DarkThemeProvider themeProvider, VoidCallback onPressed) {
//     return IconButton(
//       onPressed: onPressed,
//       icon: SvgPicture.asset(
//         icon,
//         color: themeProvider.darkTheme ? Colors.white : Colors.black,
//       ),
//     );
//   }
// }





// // class Word {
// //   final dom.Text textNode;
// //   final int start;
// //   final int end;

// //   Word({required this.textNode, required this.start, required this.end});
// // }

// // class TtsHtmlScreen extends StatefulWidget {
// //   final Map<String, dynamic> article;
// //   const TtsHtmlScreen({super.key, required this.article});

// //   @override
// //   State<TtsHtmlScreen> createState() => _TtsHtmlScreenState();
// // }

// // class _TtsHtmlScreenState extends State<TtsHtmlScreen> {
// //   final FlutterTts _tts = FlutterTts();
// //   List<Word> _words = [];
// //   int _currentIndex = 0;
// //   bool _isPlaying = false;

// //   String _htmlContent = "";
// //   String _highlightedHtml = "";

// //   String title = "";

// //   @override
// //   void initState() {
// //     super.initState();
// //     title = widget.article['title'] ?? '';
// //     _htmlContent = widget.article['content'] ?? widget.article['textContent'] ?? "";
// //     _highlightedHtml = _htmlContent;
// //     _prepareWords();
// //     _configureTts();
// //   }

// //   void _configureTts() async {
// //     await _tts.setLanguage("en-US");
// //     await _tts.setPitch(1.0);
// //     await _tts.setVolume(1.0);
// //     await _tts.setSpeechRate(0.8);
// //     await _tts.setEngine("com.google.android.tts");

// //     // Set completion handler to speak the next word automatically
// //     _tts.setCompletionHandler(() {
// //       if (_isPlaying && _currentIndex < _words.length - 1) {
// //         _nextWord();
// //       } else {
// //         setState(() {
// //           _isPlaying = false;
// //         });
// //       }
// //     });
// //   }

// //   void _prepareWords() {
// //     final doc = html_parser.parse(_htmlContent);
// //     _words.clear();

// //     void walk(dom.Node node) {
// //       if (node is dom.Text && node.text.trim().isNotEmpty) {
// //         final text = node.text;
// //         final wordReg = RegExp(r'\S+');
// //         for (final match in wordReg.allMatches(text)) {
// //           _words.add(Word(textNode: node, start: match.start, end: match.end));
// //         }
// //       } else if (node.hasChildNodes()) {
// //         for (var child in node.nodes) {
// //           walk(child);
// //         }
// //       }
// //     }

// //     walk(doc.body!);
// //   }

// //   void _highlightWord(Word word) {
// //     final doc = html_parser.parse(_htmlContent);

// //     dom.Text? findNode(dom.Node node, dom.Text search) {
// //       if (node is dom.Text && node.text == search.text) return node;
// //       if (node.hasChildNodes()) {
// //         for (final child in node.nodes) {
// //           final result = findNode(child, search);
// //           if (result != null) return result;
// //         }
// //       }
// //       return null;
// //     }

// //     final target = findNode(doc.body!, word.textNode);
// //     if (target != null) {
// //       final text = target.text;
// //       final before = text.substring(0, word.start);
// //       final highlight = text.substring(word.start, word.end);
// //       final after = text.substring(word.end);
// //       final fragment = html_parser.parseFragment(
// //           "$before<mark style='background:yellow;'>$highlight</mark>$after");
// //       target.replaceWith(fragment);
// //     }

// //     setState(() {
// //       _highlightedHtml = doc.body?.innerHtml ?? _htmlContent;
// //     });
// //   }

// //   Future<void> _speakWord(Word word) async {
// //     await _tts.stop();
// //     await _tts.speak(word.textNode.text.substring(word.start, word.end));
// //     _highlightWord(word);
// //   }

// //   void _nextWord() {
// //     if (_currentIndex < _words.length - 1) {
// //       setState(() {
// //         _currentIndex++;
// //         _isPlaying = true;
// //       });
// //       _speakWord(_words[_currentIndex]);
// //     } else {
// //       setState(() {
// //         _isPlaying = false;
// //       });
// //     }
// //   }

// //   void _previousWord() {
// //     if (_currentIndex > 0) {
// //       setState(() {
// //         _currentIndex--;
// //         _isPlaying = true;
// //       });
// //       _speakWord(_words[_currentIndex]);
// //     } else {
// //       setState(() {
// //         _isPlaying = false;
// //       });
// //     }
// //   }

// //   void _togglePlayPause() {
// //     if (_isPlaying) {
// //       _tts.stop();
// //       setState(() {
// //         _isPlaying = false;
// //       });
// //     } else {
// //       setState(() {
// //         _isPlaying = true;
// //       });
// //       _speakWord(_words[_currentIndex]);
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _tts.stop();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //      final themeProvider = Provider.of<DarkThemeProvider>(context);
// //     final width = MediaQuery.of(context).size.width;
// //     final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
// //     final ttsProvider = Provider.of<TtsProvider>(context);
// //      var webViewModel = Provider.of<WebViewModel>(context, listen: true);
// //     var webViewController = webViewModel.webViewController;
// //     // final String title = widget.article['title'] ?? "";
// //     // final String content = widget.article['content'] ?? ""; // HTML
// //     // final String textContent = widget.article['textContent'] ?? ""; // Plain text

// //     return SafeArea(
// //       child: Container(
// //         //color: Colors.white,
// //         child: DraggableScrollableSheet(
// //           initialChildSize: 0.95,
// //                     minChildSize: 0.3,
// //                     maxChildSize: 0.95,
// //           builder: (context,scrollController){
            
            
// //            return LayoutBuilder(builder: (context, constraint) {
// //                       return Container(
// //                         padding: EdgeInsets.only(
// //                             bottom: MediaQuery.of(context).viewInsets.bottom),
// //                         decoration: BoxDecoration(
// //                             borderRadius:
// //                                 BorderRadius.vertical(top: Radius.circular(20)),
// //                                 border: Border(top: BorderSide(color:themeProvider.darkTheme ? Color(0xff42425F): Color(0xffDADADA),width: 0.5)),
// //                             color: themeProvider.darkTheme ? Color(0xff171720) : Color(0xffFFFFFF)
// //                             ),
// //                             child: Stack(
// //                               children: [
// //                                 Column(
// //                                   children: [
// //                                     Column(
// //                                       children:[
// //                                        vpnStatusProvider.changeReaderMenu ?
// //                                         Row(
// //                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                                           children: [
// //                                             menuOptions('assets/images/back.svg', themeProvider, (){
                                              
// //                                               vpnStatusProvider.updateReaderMenu(false);
// //                                               _tts.stop();
// //                                              // _prepareWords();
// //                                             }),
// //                                             Row(
// //                                               mainAxisAlignment: MainAxisAlignment.center,
// //                                               children: [
// //                                                 menuOptions('assets/images/ai-icons/prev_enabled.svg', themeProvider, _previousWord),
// //                                                 menuOptions(_isPlaying ? 'assets/images/ai-icons/Pause.svg' :'assets/images/ai-icons/Play.svg',themeProvider,_togglePlayPause),
// //                                                 menuOptions('assets/images/ai-icons/end_enabled.svg',themeProvider,_nextWord)
                                            
// //                                               ],
// //                                             ),
// //                                             Icon(Icons.arrow_back,color: Colors.transparent,)
// //                                           ],
// //                                         )
                                       
// //                                         :Row(
// //                                           mainAxisAlignment: MainAxisAlignment.end,
// //                                           children: [
// //                                             menuOptions( 'assets/images/ai-icons/translate.svg',themeProvider,()=>{}//_translateWithAI(ttsProvider),
// //                                             ),
// //                                             menuOptions('assets/images/ai-icons/read.svg',themeProvider,()=> vpnStatusProvider.updateReaderMenu(true)),
// //                                 PopupMenuButton<String>(
// //                                   icon: SvgPicture.asset(
// //                                     'assets/images/ai-icons/font.svg',
// //                                     color: themeProvider.darkTheme ? Colors.white : Colors.black,
// //                                   ),
// //                                     color:
// //                                               themeProvider.darkTheme ?const Color(0xff282836) :const Color(0xffF3F3F3),
// //                                   offset: Offset(width / 5.0, width / 7.2),
// //                                     surfaceTintColor:
// //                                               themeProvider.darkTheme ?const Color(0xff282836) : const Color(0xffF3F3F3),
// //                                           elevation: 2,
// //                                           shape:const RoundedRectangleBorder(
// //                                             borderRadius: BorderRadius.only(
// //                                               bottomLeft: Radius.circular(15.0),
// //                                               bottomRight: Radius.circular(15.0),
// //                                               topLeft: Radius.circular(15.0),
// //                                               topRight: Radius.circular(15.0),
// //                                             ),
// //                                           ),
// //                                   itemBuilder: (context) => [
// //                                     PopupMenuItem(
// //                                       enabled: true,
// //                                       padding: EdgeInsets.zero,
// //                                       child: SizedBox(
// //                                         width: 220,
// //                                         child: Column(
// //                                           crossAxisAlignment: CrossAxisAlignment.start,
// //                                           children: [
// //                                              Padding(
// //                                               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
// //                                               child: Text("Text Zoom",style: TextStyle(color: themeProvider.darkTheme ? Colors.white : Colors.black),),
// //                                             ),
// //                                             Consumer<VpnStatusProvider>(
// //                                               builder: (context, vpnStatusProvider, _) {
// //                                                 return SliderTheme(
// //                                                   data: SliderThemeData(
// //                                                     trackHeight: 3,
// //                                                     padding: const EdgeInsets.symmetric(horizontal: 8),
// //                                                     inactiveTrackColor: themeProvider.darkTheme
// //                                                         ? const Color(0xff363645)
// //                                                         : const Color(0xffDADADA),
                                
                                
// //                                                         // Round thumb (draggable handle)
// //                                         thumbShape: const RoundSliderThumbShape(
// //                                           enabledThumbRadius: 6.0, // size of the handle
// //                                           pressedElevation: 2.0,
// //                                         ),
                                
// //                                         // Round track edges
// //                                         trackShape: const RoundedRectSliderTrackShape(),
// //                                         overlayShape: const RoundSliderOverlayShape(
// //                                           overlayRadius: 12.0, // glow when pressed
// //                                         ),
                                                      
// //                                                   ),
// //                                                   child: Slider(
// //                                                     value: vpnStatusProvider.fontSize,
// //                                                     min: 8.0,
// //                                                     max: 20.0,
// //                                                     activeColor: const Color(0xff00BD40),
// //                                                     divisions: 120,
// //                                                     onChanged: (value) {
// //                                                       vpnStatusProvider.updateReaderContentFontSize(value);
// //                                                     },
// //                                                   ),
// //                                                 );
// //                                               },
// //                                             ),
// //                                             Padding(
// //                                               padding: const EdgeInsets.symmetric(horizontal: 8.0),
// //                                               child: Row(
// //                                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                                                 children: [
// //                                                   percentageText(themeProvider,'50%'),
// //                                                   percentageText(themeProvider,'100%'),
// //                                                   percentageText(themeProvider,'200%'),
// //                                                 ],
// //                                               ),
// //                                             ),
// //                                             SizedBox(height: 5,)
// //                                           ],
// //                                         ),
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                                             menuOptions('assets/images/ai-icons/theme.svg',themeProvider,(){
// //                                                   themeProvider.darkTheme = !themeProvider.darkTheme;
// //                                             }),
// //                                             menuOptions('assets/images/ai-icons/clear.svg',themeProvider,(){
// //                                               Navigator.pop(context);
// //                                             })
// //                                           ],
// //                                         ),
// //                                        Divider(
// //                                         color: themeProvider.darkTheme ? Color(0xff42425F) : Color(0xffDADADA),
// //                                        )
// //                                       ]
// //                                     ),
// //                                     if(title.isNotEmpty)...[Text(title,maxLines: 2,overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: vpnStatusProvider.fontSize + 12),)],
// //                                     Expanded(
// //                                       child: SingleChildScrollView(
// //                                         padding: const EdgeInsets.all(16),
// //                                         child: Html(
// //                 data: _highlightedHtml,
// //                 style: {
// //                   "body": Style(
// //                     fontSize: FontSize(vpnStatusProvider.fontSize), //16.0),
// //                     textAlign: TextAlign.justify, // Justified text for readability
// //                     lineHeight: LineHeight(1.5), // Improved line spacing
// //                   ),
// //                   "mark": Style(backgroundColor: Color(0xff00BD40), color: Colors.white),
// //                   // Style for images
// //                  "img": Style(
// //                     display: Display.block, // Treat image as block element
// //                     margin: Margins.symmetric(horizontal: 12, vertical: 12), // Vertical spacing
// //                     height: Height(MediaQuery.of(context).size.height*1/3), //200),
// //                     width: Width(MediaQuery.of(context).size.width),
// //                     padding: HtmlPaddings(right: HtmlPadding(40))
// //                    // alignment: Alignment.center, // Center the image
// //                    // width: Width(100, Unit.percent), // Constrain to 100% of container width
// //                   ),
// //                 },
// //               ),
// //                                         // Html(
// //                                         //       data: translatedHtml ??
// //                                         //           (content.isNotEmpty
// //                                         //               ? content
// //                                         //               : textContent),
// //                                         //       style: {
// //                                         //         "*": Style(
// //                                         //           fontSize: FontSize(vpnStatusProvider.fontSize),
// //                                         //         ),
// //                                         //       },
// //                                         //       onLinkTap: (url, _, __) {
// //                                         //         if (url != null) {
// //                                         //           // Handle link clicks (open in browser or inside app)
// //                                         //           debugPrint("Link clicked: $url");
// //                                         //           webViewController!.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
// //                                         //           Navigator.pop(context);
// //                                         //         }
// //                                         //       },
// //                                         //     ),
// //                                         // content.isNotEmpty
// //                                         //     ? Html(
// //                                         //         data: content,
// //                                         //         style: {
// //                                         //           "*": Style(
// //                                         //             fontSize: FontSize(vpnStatusProvider.fontSize),
// //                                         //           ),
// //                                         //         },
// //                                         //       )
// //                                         //     : Text(
// //                                         //         textContent,
// //                                         //         style: TextStyle(fontSize:vpnStatusProvider.fontSize),
// //                                         //       ),
// //                                       ),
// //                                     )
// //                                   ],
                                
// //                                 ),
                              
// //                               ttsProvider.isContentTranslating ? Center(child: CircularProgressIndicator(color: Colors.green,)):Container()
// //                               ],
// //                             ),
// //                             );
// //                             }
// //                             );
            
// //             // return Container(
              
// //             //    child: Text('CENTER THIS SCREEN'),
// //             // );
// //           }
          
// //           ),
// //       ),
// //     );

// //     // return Scaffold(
// //     //   appBar: AppBar(title: const Text("Reading Mode")),
// //     //   body: Column(
// //     //     children: [
// //     //       Expanded(
// //     //         child: SingleChildScrollView(
// //     //           padding: const EdgeInsets.all(12),
// //     //           child: Html(
// //     //             data: _highlightedHtml,
// //     //             style: {
// //     //               "body": Style(
// //     //                 fontSize: FontSize(16.0),
// //     //                 textAlign: TextAlign.justify, // Justified text for readability
// //     //                 lineHeight: LineHeight(1.5), // Improved line spacing
// //     //               ),
// //     //               "mark": Style(backgroundColor: Colors.yellow, color: Colors.black),
// //     //               // Style for images
// //     //              "img": Style(
// //     //                 display: Display.block, // Treat image as block element
// //     //                 margin: Margins.symmetric(horizontal: 12, vertical: 12), // Vertical spacing
// //     //                 height: Height(MediaQuery.of(context).size.height*1/3), //200),
// //     //                 width: Width(MediaQuery.of(context).size.width),
// //     //                 padding: HtmlPaddings(right: HtmlPadding(40))
// //     //                // alignment: Alignment.center, // Center the image
// //     //                // width: Width(100, Unit.percent), // Constrain to 100% of container width
// //     //               ),
// //     //             },
// //     //           ),
// //     //         ),
// //     //       ),
// //     //       Row(
// //     //         mainAxisAlignment: MainAxisAlignment.center,
// //     //         children: [
// //     //           IconButton(
// //     //             icon: const Icon(Icons.skip_previous),
// //     //             onPressed: _previousWord,
// //     //           ),
// //     //           IconButton(
// //     //             icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
// //     //             onPressed: _togglePlayPause,
// //     //           ),
// //     //           IconButton(
// //     //             icon: const Icon(Icons.skip_next),
// //     //             onPressed: _nextWord,
// //     //           ),
// //     //         ],
// //     //       ),
// //     //     ],
// //     //   ),
// //     // );
// //   }
// //   Text percentageText(DarkThemeProvider themeProvider,String text) => Text(text,style: TextStyle(fontSize: 10,fontWeight: FontWeight.w500,color: themeProvider.darkTheme ? Colors.white : Colors.black),);

// //   IconButton menuOptions(String icon,DarkThemeProvider themeProvider,VoidCallback onPressed) {
// //     return IconButton(onPressed: onPressed,
// //              icon: SvgPicture.asset(icon,color: themeProvider.darkTheme ? Colors.white: Colors.black,));
// //   }
// // }
