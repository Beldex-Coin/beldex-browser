// import 'package:html/dom.dart' as dom;
// //import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:html/parser.dart' as html_parser;

// class Word {
//   final dom.Text textNode;
//   final int start;
//   final int end;

//   Word({required this.textNode, required this.start, required this.end});
// }

// class TextToSpeechProvider extends ChangeNotifier {
//   final FlutterTts _tts = FlutterTts();

//   late dom.Document _doc;
//   String _originalHtml = '';
//   String _highlightedHtml = '';
//   List<List<Word>> _sentences = [];
//   List<Word> _words = [];

//   int _currentSentenceIndex = 0;
//   int _currentWordIndex = 0;
//   bool _isPlaying = false;

//   ScrollController scrollController = ScrollController();

//   TextToSpeechProvider(String htmlContent) {
//     _originalHtml = htmlContent;
//     _highlightedHtml = htmlContent;
//     _doc = html_parser.parse(htmlContent);
//     _prepareWords();
//     _prepareSentences();
//     //_configureTts();
//   }

//   String get highlightedHtml => _highlightedHtml;
//   bool get isPlaying => _isPlaying;

//   void _prepareWords() {
//     _words.clear();

//     void walk(dom.Node node) {
//       if (node is dom.Text && node.text.trim().isNotEmpty) {
//         final text = node.text;
//         final wordReg = RegExp(r'\S+');
//         for (final match in wordReg.allMatches(text)) {
//           _words.add(Word(textNode: node, start: match.start, end: match.end));
//         }
//       } else if (node.hasChildNodes()) {
//         for (var child in node.nodes) walk(child);
//       }
//     }

//     if (_doc.body != null) walk(_doc.body!);
//   }

//   void _prepareSentences() {
//   _sentences.clear();
//   List<Word> currentSentence = [];

//   for (int i = 0; i < _words.length; i++) {
//     final word = _words[i];
//     final wordText = word.textNode.text.substring(word.start, word.end).trim();

//     // Skip punctuation-only words
//     if (wordText.replaceAll(RegExp(r'[^\w]'), '').isEmpty) continue;

//     currentSentence.add(word);

//     if (RegExp(r'[.!?]$').hasMatch(wordText) || i == _words.length - 1) {
//       _sentences.add(List.from(currentSentence));
//       currentSentence.clear();
//     }
//   }
// }


//   void _configureTts() async {
//     await _tts.setLanguage("en-US");
//     await _tts.setPitch(1.0);
//     await _tts.setVolume(1.0);
//     await _tts.setSpeechRate(0.95);
//     await _tts.setEngine("com.google.android.tts");

//     _tts.setProgressHandler((String text, int start, int end, String word) {
//       // Highlight the currently speaking word
//       if (_currentSentenceIndex >= _sentences.length) return;
//       final sentence = _sentences[_currentSentenceIndex];

//       for (int i = 0; i < sentence.length; i++) {
//         final w = sentence[i];
//         final wText = w.textNode.text.substring(w.start, w.end);
//         if (wText.trim().toLowerCase() == word.toLowerCase()) {
//           _currentWordIndex = i;
//           _highlightWord(sentence[i]);
//           break;
//         }
//       }
//     });

//     _tts.setCompletionHandler(() {
//       if (_currentSentenceIndex < _sentences.length - 1) {
//         _currentSentenceIndex++;
//         _currentWordIndex = 0;
//         _speakSentence();
//       } else {
//         _isPlaying = false;
//         notifyListeners();
//       }
//     });
//   }

//   void _highlightWord(Word word) {
//     // Reset previous highlights
//     _doc = html_parser.parse(_originalHtml);

//     final node = word.textNode;
//     final parent = node.parent;
//     if (parent == null) return;

//     final before = node.text.substring(0, word.start);
//     final highlight = node.text.substring(word.start, word.end);
//     final after = node.text.substring(word.end);

//     final nodeIndex = parent.nodes.indexOf(node);
//     if (nodeIndex == -1) return;

//     parent.nodes.removeAt(nodeIndex);
//     int insertIndex = nodeIndex;

//     if (before.isNotEmpty) {
//       parent.nodes.insert(insertIndex, dom.Text(before));
//       insertIndex++;
//     }

//     final mark = dom.Element.tag('mark');
//     mark.attributes['class'] = 'highlight';
//     mark.attributes['style'] =
//         'background: yellow !important; color: black !important; display: inline !important;';
//     mark.append(dom.Text(highlight));
//     parent.nodes.insert(insertIndex, mark);
//     insertIndex++;

//     if (after.isNotEmpty) {
//       parent.nodes.insert(insertIndex, dom.Text(after));
//     }

//     _highlightedHtml = _doc.body?.innerHtml ?? _originalHtml;

//     // Auto-scroll to word if needed
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       scrollController.animateTo(
//         scrollController.offset + 30,
//         duration: Duration(milliseconds: 100),
//         curve: Curves.easeInOut,
//       );
//     });

//     notifyListeners();
//   }

//   void _speakSentence() async {
//     if (_currentSentenceIndex >= _sentences.length) return;

//     final sentence = _sentences[_currentSentenceIndex];
//     if (sentence.isEmpty) return;

//     final textToSpeak = sentence.map((w) => w.textNode.text.substring(w.start, w.end)).join(' ');

//     _isPlaying = true;
//     notifyListeners();

//     await _tts.stop();
//     await _tts.speak(textToSpeak);
//   }

//   // Controls
//   void play() {
//     if (_isPlaying) return;
//     _speakSentence();
//   }

//   void pause() async {
//     await _tts.stop();
//     _isPlaying = false;
//     notifyListeners();
//   }

//   void nextWord() {
//     final sentence = _sentences[_currentSentenceIndex];
//     if (_currentWordIndex < sentence.length - 1) {
//       _currentWordIndex++;
//       _speakFromWord(_currentWordIndex);
//     } else if (_currentSentenceIndex < _sentences.length - 1) {
//       _currentSentenceIndex++;
//       _currentWordIndex = 0;
//       _speakSentence();
//     }
//   }

//   void previousWord() {
//     if (_currentWordIndex > 0) {
//       _currentWordIndex--;
//       _speakFromWord(_currentWordIndex);
//     } else if (_currentSentenceIndex > 0) {
//       _currentSentenceIndex--;
//       final prevSentence = _sentences[_currentSentenceIndex];
//       _currentWordIndex = prevSentence.length - 1;
//       _speakSentence();
//     }
//   }

//   void _speakFromWord(int wordIndex) async {
//     final sentence = _sentences[_currentSentenceIndex];
//     final textToSpeak = sentence
//         .sublist(wordIndex)
//         .map((w) => w.textNode.text.substring(w.start, w.end))
//         .join(' ');

//     await _tts.stop();
//     await _tts.speak(textToSpeak);
//   }
// }