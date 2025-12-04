import 'dart:convert';
import 'package:belnet_lib/belnet_lib.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;

class ParagraphData {
  final String originalText;
  String translatedText;
   List<Map<String, String>> images;

  ParagraphData({
    required this.originalText,
    required this.translatedText,
    required this.images,
  });
}

class ReaderProvider extends ChangeNotifier {
  final FlutterTts flutterTts = FlutterTts();
final MethodChannel _methodChannel = MethodChannel('belnet_lib_method_channel');
  List<ParagraphData> paragraphs = [];
  int currentParagraphIndex = 0;
  bool isSpeaking = false;
  bool autoPlay = false;
  bool isTranslating = false;
  String selectedLanguage = 'en-US';

  final Set<String> blockTags = {
    'p', 'div', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'blockquote', 'pre', 'hr'
  };

  final Map<String, String> languages = {
  'ar': 'Arabic',
  'as-IN': 'Assamese (India)',
  'bg-BG': 'Bulgarian (Bulgaria)',
  'bn-BD': 'Bengali (Bangladesh)',
  'bn-IN': 'Bengali (India)',
  'brx-IN': 'Bodo (India)',
  'bs-BA': 'Bosnian (Bosnia and Herzegovina)',
  'ca-ES': 'Catalan (Spain)',
  'cs-CZ': 'Czech (Czech Republic)',
  'cy-GB': 'Welsh (United Kingdom)',
  'da-DK': 'Danish (Denmark)',
  'de-DE': 'German (Germany)',
  'doi-IN': 'Dogri (India)',
  'el-GR': 'Greek (Greece)',
  'en-AU': 'English (Australia)',
  'en-GB': 'English (United Kingdom)',
  'en-IN': 'English (India)',
  'en-NG': 'English (Nigeria)',
  'en-US': 'English (United States)',
  'es-ES': 'Spanish (Spain)',
  'es-US': 'Spanish (United States)',
  'et-EE': 'Estonian (Estonia)',
  'fi-FI': 'Finnish (Finland)',
  'fil-PH': 'Filipino (Philippines)',
  'fr-CA': 'French (Canada)',
  'fr-FR': 'French (France)',
  'gu-IN': 'Gujarati (India)',
  'he-IL': 'Hebrew (Israel)',
  'hi-IN': 'Hindi (India)',
  'hr-HR': 'Croatian (Croatia)',
  'hu-HU': 'Hungarian (Hungary)',
  'id-ID': 'Indonesian (Indonesia)',
  'is-IS': 'Icelandic (Iceland)',
  'it-IT': 'Italian (Italy)',
  'ja-JP': 'Japanese (Japan)',
  'jv-ID': 'Javanese (Indonesia)',
  'km-KH': 'Khmer (Cambodia)',
  'kn-IN': 'Kannada (India)',
  'ko-KR': 'Korean (South Korea)',
  'kok-IN': 'Konkani (India)',
  'lt-LT': 'Lithuanian (Lithuania)',
  'lv-LV': 'Latvian (Latvia)',
  'mai-IN': 'Maithili (India)',
  'ml-IN': 'Malayalam (India)',
  'mni-IN': 'Manipuri (India)',
  'mr-IN': 'Marathi (India)',
  'ms-MY': 'Malay (Malaysia)',
  'nb-NO': 'Norwegian Bokmål (Norway)',
  'ne-NP': 'Nepali (Nepal)',
  'nl-BE': 'Dutch (Belgium)',
  'nl-NL': 'Dutch (Netherlands)',
  'or-IN': 'Odia (India)',
  'pa-IN': 'Punjabi (India)',
  'pl-PL': 'Polish (Poland)',
  'pt-BR': 'Portuguese (Brazil)',
  'pt-PT': 'Portuguese (Portugal)',
  'ro-RO': 'Romanian (Romania)',
  'ru-RU': 'Russian (Russia)',
  'sa-IN': 'Sanskrit (India)',
  'sat-IN': 'Santali (India)',
  'sd-IN': 'Sindhi (India)',
  'si-LK': 'Sinhala (Sri Lanka)',
  'sk-SK': 'Slovak (Slovakia)',
  'sq-AL': 'Albanian (Albania)',
  'sr-RS': 'Serbian (Serbia)',
  'su-ID': 'Sundanese (Indonesia)',
  'sv-SE': 'Swedish (Sweden)',
  'sw-KE': 'Swahili (Kenya)',
  'ta-IN': 'Tamil (India)',
  'te-IN': 'Telugu (India)',
  'th-TH': 'Thai (Thailand)',
  'tr-TR': 'Turkish (Turkey)',
  'uk-UA': 'Ukrainian (Ukraine)',
  'ur-IN': 'Urdu (India)',
  'ur-PK': 'Urdu (Pakistan)',
  'vi-VN': 'Vietnamese (Vietnam)',
  'yue-HK': 'Cantonese (Hong Kong)',
  'zh-CN': 'Chinese (Simplified, China)',
  'zh-TW': 'Chinese (Traditional, Taiwan)',
  };



  static const String geminiApiKey = '';
  static const String geminiApiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  ReaderProvider(String htmlContent, {String initialLanguage = 'en-US'}) {
    selectedLanguage = initialLanguage;
    paragraphs = _extractParagraphsFromHtml(htmlContent);
    _configureTts();
    _methodChannel.setMethodCallHandler(_methodHandler);
  }


Future<void> _methodHandler(MethodCall call) async {
  if (call.method == "focusLost") {
    await stop(); // Stop TTS immediately
  }
}



 List<ParagraphData> _extractParagraphsFromHtml(String htmlString) {
  final document = html_parser.parse(htmlString,);
  List<ParagraphData> result = [];

  // Define common image file extensions
  final imageExtensions = ['.jpg', '.jpeg', '.webp', '.gif', '.bmp'];

  // Define block-level tags
  final blockTags = {
    'p', 'div', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'ul', 'ol', 'li',
    'section', 'article', 'main', 'blockquote', 'pre'
  };

  // Extract title
  final title = document.querySelector('title');
  if (title != null && title.text.trim().isNotEmpty) {
    print('Found title: ${title.text.trim()}');
    result.add(ParagraphData(
      originalText: title.text.trim(),
      translatedText: title.text.trim(),
      images: [],
    ));
  }

  final body = document.body;
  if (body == null) {
    print('No body found in HTML');
    return result;
  }

  // Current buffer and images for the active block
  StringBuffer currentBuffer = StringBuffer();
  List<Map<String, String>> currentImages = [];
  Set<String> seenUrls = {}; // Track unique image URLs within the current block

  // Helper function to normalize URLs for deduplication (remove path variations for same image)
  String normalizeUrl(String url) {
    try {
      final uri = Uri.parse(url);
      // Extract base path up to the .ece and alternates, but ignore size-specific suffixes
      final pathParts = uri.path.split('/');
      if (pathParts.length >= 4) {
        // For The Hindu style: /public/incoming/{id}.ece/alternates/{size}/filename.jpg
        final baseParts = pathParts.sublist(0, 4); // Up to .ece
        final basePath = baseParts.join('/');
        return '${uri.scheme}://${uri.host}$basePath';
      } else {
        // Fallback: remove query/fragment as before
        return uri.replace(query: '', fragment: '').toString();
      }
    } catch (e) {
      // If parsing fails, return original
      return url;
    }
  }

  // Helper function to check if a URL is likely an image
  bool isImageUrl(String url) {
    if (url.isEmpty) return false;
    final lowerUrl = url.toLowerCase();
    return imageExtensions.any((ext) => lowerUrl.contains(ext)) ||
           lowerUrl.contains('image') ||
           lowerUrl.contains('img') ||
           lowerUrl.contains('photo') ||
           lowerUrl.contains('picture');
  }

  // Helper function to extract image data from a node
  void extractImage(dom.Element node, String srcAttr, String altAttr) {
    final src = node.attributes[srcAttr] ?? '';
    final normalizedSrc = normalizeUrl(src);
    final alt = node.attributes[altAttr] ?? node.attributes['alt'] ?? '';
    if (src.isNotEmpty && isImageUrl(src) && !seenUrls.contains(normalizedSrc)) {
      print('Found unique image: tag=${node.localName}, src=$src, normalized=$normalizedSrc, alt=$alt, attr=$srcAttr');
      currentImages.add({'src': src, 'alt': alt});
      seenUrls.add(normalizedSrc);
    }
  }

  // Helper function to add a paragraph
  void addParagraph(String text) {
    text = text.trim();
    if (text.isEmpty && currentImages.isEmpty) return;
    if (text.isEmpty) {
      text = '[Images]';
    }
    print('Adding paragraph: text="$text", images=$currentImages');
    result.add(ParagraphData(
      originalText: text,
      translatedText: text,
      images: List<Map<String, String>>.from(currentImages),
    ));
    currentImages.clear();
    seenUrls.clear(); // Clear seen URLs after adding paragraph
  }

  void recurse(dom.Node node) {
    if (node is dom.Text) {
      currentBuffer.write(node.text);
    } else if (node is dom.Element) {
      final tag = node.localName?.toLowerCase() ?? '';
      final isBlock = blockTags.contains(tag);

      if (isBlock && tag != 'hr') {
        // Process any accumulated text/images before starting new block
        if (currentBuffer.isNotEmpty || currentImages.isNotEmpty) {
          addParagraph(currentBuffer.toString());
          currentBuffer.clear();
        }
        seenUrls.clear(); // Reset seen URLs for new block
        print('Starting new block: tag=$tag');
      }

      // Handle image-related tags and attributes
      if (tag == 'img') {
        extractImage(node, 'src', 'alt');
        extractImage(node, 'data-src', 'alt');
        extractImage(node, 'data-lazy-src', 'alt');
        final srcset = node.attributes['srcset'] ?? '';
        if (srcset.isNotEmpty) {
          final urls = srcset
              .split(',')
              .map((s) => s.trim().split(' ')[0])
              .where((url) => url.isNotEmpty && isImageUrl(url))
              .map(normalizeUrl)
              .toSet() // Deduplicate URLs in srcset
              .where((url) => !seenUrls.contains(url));
          for (var normalizedUrl in urls) {
            // Find the original URL that matches this normalized one (prefer the first occurrence)
            final originalUrl = srcset
                .split(',')
                .map((s) => s.trim().split(' ')[0])
                .firstWhere((url) => normalizeUrl(url) == normalizedUrl, orElse: () => normalizedUrl);
            print('Found unique image from srcset: tag=$tag, src=$originalUrl, normalized=$normalizedUrl, alt=${node.attributes['alt'] ?? ''}');
            currentImages.add({'src': originalUrl, 'alt': node.attributes['alt'] ?? ''});
            seenUrls.add(normalizedUrl);
          }
        }
      } else if (tag == 'source') {
        extractImage(node, 'src', 'alt');
        extractImage(node, 'data-src', 'alt');
        extractImage(node, 'data-lazy-src', 'alt');
        final srcset = node.attributes['srcset'] ?? '';
        if (srcset.isNotEmpty) {
          final urls = srcset
              .split(',')
              .map((s) => s.trim().split(' ')[0])
              .where((url) => url.isNotEmpty && isImageUrl(url))
              .map(normalizeUrl)
              .toSet() // Deduplicate URLs in srcset
              .where((url) => !seenUrls.contains(url));
          for (var normalizedUrl in urls) {
            // Find the original URL that matches this normalized one
            final originalUrl = srcset
                .split(',')
                .map((s) => s.trim().split(' ')[0])
                .firstWhere((url) => normalizeUrl(url) == normalizedUrl, orElse: () => normalizedUrl);
            print('Found unique image from source srcset: src=$originalUrl, normalized=$normalizedUrl, alt=${node.attributes['alt'] ?? ''}');
            currentImages.add({'src': originalUrl, 'alt': node.attributes['alt'] ?? ''});
            seenUrls.add(normalizedUrl);
          }
        }
      } else if (tag == 'picture') {
        // Special handling for picture: process children but don't add extra
        for (var child in node.nodes) {
          recurse(child);
        }
        return; // Skip default recursion for picture
      } else if (tag == 'div' || tag == 'span' || tag == 'a') {
        final style = node.attributes['style'] ?? '';
        final regex = RegExp(r'background(?:-image)?\s*:\s*url\((.*?)\)', caseSensitive: false);
        final match = regex.firstMatch(style);
        if (match != null) {
          final url = match.group(1)?.replaceAll('"', '').replaceAll("'", '') ?? '';
          final normalizedUrl = normalizeUrl(url);
          if (isImageUrl(url) && !seenUrls.contains(normalizedUrl)) {
            print('Found unique background image: tag=$tag, src=$url, normalized=$normalizedUrl');
            currentImages.add({'src': url, 'alt': ''});
            seenUrls.add(normalizedUrl);
          }
        }
        if (tag == 'a') {
          final href = node.attributes['href'] ?? '';
          final normalizedHref = normalizeUrl(href);
          if (isImageUrl(href) && !seenUrls.contains(normalizedHref)) {
            print('Found unique image in <a> href: src=$href, normalized=$normalizedHref');
            currentImages.add({'src': href, 'alt': node.attributes['title'] ?? ''});
            seenUrls.add(normalizedHref);
          }
        }
      } else if (tag == 'br') {
        currentBuffer.write('\n');
      }

      // Recurse through child nodes (unless picture)
      if (tag != 'picture') {
        for (var child in node.nodes) {
          recurse(child);
        }
      }

      // Handle block tag end
      if (isBlock && tag != 'hr') {
        addParagraph(currentBuffer.toString());
        currentBuffer.clear();
        print('Ending block: tag=$tag');
      }
    }
  }

  recurse(body);

  // Handle any remaining content
  if (currentBuffer.isNotEmpty || currentImages.isNotEmpty) {
    addParagraph(currentBuffer.toString());
    currentBuffer.clear();
  }


/// For Duplicate image urls 
for (var p in result) {
  final seen = <String>{};

  p.images.removeWhere((img) {
    final src = img['src'];
    if (src == null || src.isEmpty) return true;

    final normalized = normalizedImageUrl(src);
    if (seen.contains(normalized)) {
      return true; // duplicate → remove
    }

    seen.add(normalized);
    return false;
  });
notifyListeners();
  debugPrint('Final unique images: ${p.images}');
}



  debugPrint('Final result: ${result.map((p) => {'text': p.originalText, 'images': p.images}).toList()}');
  return result;
}



String normalizedImageUrl(String url) {
  if (url.isEmpty) return '';

  // Trim and lower
  url = url.trim().toLowerCase();

  // Remove query parameters
  url = url.split('?').first;

  // Extract the filename (last part of the path)
  final uri = Uri.tryParse(url);
  if (uri == null) return url;

  final pathSegments = uri.pathSegments;
  if (pathSegments.isEmpty) return url;

  String filename = pathSegments.last;

  // Remove extension variations like .jpg.webp → keep only base name
  filename = filename.replaceAll(RegExp(r'\.(jpg|jpeg|png|gif|webp|avif|bmp)$'), '');

  return filename; // this is our "unique key"
}








  Future<void> _configureTts() async {
    await flutterTts.setLanguage(selectedLanguage);
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    //await flutterTts.setVoice({"name": "ta-in-x-tac-local","locale":"ta-IN"});
    flutterTts.setCompletionHandler(() {
                    debugPrint('TTS Completed: index=$currentParagraphIndex');

      isSpeaking = false;
      if (autoPlay && currentParagraphIndex < paragraphs.length - 1) {
        currentParagraphIndex++;
        _speakCurrentParagraph();
      } else {
        autoPlay = false;
      }
      notifyListeners();
    });
  }

  Future<String> _translateText(String text, String targetLanguage) async {
    if (text.isEmpty) return text;

    final prompt = 'Translate the following content to $targetLanguage: "$text". '
        'Only provide the equivalent text content.';
    final body = jsonEncode({
      'contents': [
        {'parts': [{'text': prompt}]}
      ]
    });

    try {
      final response = await http.post(
        Uri.parse('$geminiApiUrl?key=$geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['candidates'][0]['content']['parts'][0]['text'] ?? text;
      } else {
        return text;
      }
    } catch (e) {
      print('Translation error: $e');
      return text;
    }
  }





  Future<void> translateParagraphs(String targetLanguage) async {
    isTranslating = true;
    notifyListeners();

    List<ParagraphData> translated = [];
    for (var p in paragraphs) {
      String translatedText = p.originalText;
      if (p.originalText.isNotEmpty && targetLanguage != 'en-US') {
        translatedText = await _translateText(p.originalText, targetLanguage);
      }
      translated.add(ParagraphData(
          originalText: p.originalText, translatedText: translatedText, images: p.images));
    }

    paragraphs = translated;
    selectedLanguage = targetLanguage;
    isTranslating = false;
    await flutterTts.setLanguage(targetLanguage);
    notifyListeners();
  }

  Future<void> _speakCurrentParagraph() async {
    if (paragraphs.isEmpty) return;
    isSpeaking = true;
    notifyListeners();
    await BelnetLib.requestFocus();
    await flutterTts.speak(paragraphs[currentParagraphIndex].translatedText);
  }

  Future<void> startAutoPlay() async {
    await stop();
    autoPlay = true;
    currentParagraphIndex = 0;
    notifyListeners();
    _speakCurrentParagraph();
  }

  Future<void> stop() async {
    await flutterTts.stop();
    isSpeaking = false;
    autoPlay = false;
    notifyListeners();
    await BelnetLib.abandonFocus();
  }

  Future<void> nextParagraph() async {
    await flutterTts.pause();
    if (currentParagraphIndex < paragraphs.length - 1) {
      currentParagraphIndex++;
      autoPlay = true;
      notifyListeners();
      _speakCurrentParagraph();
    }
  }

  Future<void> previousParagraph() async {
    await flutterTts.pause();
    if (currentParagraphIndex > 0) {
      currentParagraphIndex--;
      autoPlay = true;
      notifyListeners();
      _speakCurrentParagraph();
    }
  }

  Future<void> resumeReader() async {
    final val = await isCallActive();
    if(val){
      return;
    }
    if(currentParagraphIndex >= paragraphs.length - 1 ){
      currentParagraphIndex = 0;
    }
    isSpeaking = true;
    autoPlay = true;
    notifyListeners();
    _speakCurrentParagraph();
  }

  Future<void> pauseReader() async {
    await flutterTts.pause();
    isSpeaking = false;
    autoPlay = false;
    notifyListeners();
  }

  Future<void> resetCurrentParagraphIndex()async{
  currentParagraphIndex = 0;
  notifyListeners();

}



 Future<bool> isCallActive()async{
  return BelnetLib.isCallActive();
 }





}



// class ParagraphData {
//   final String originalText;
//   String translatedText;
//   final List<Map<String, String>> images;

//   ParagraphData({
//     required this.originalText,
//     required this.translatedText,
//     required this.images,
//   });
// }

// class ReaderProvider extends ChangeNotifier {
//   final FlutterTts flutterTts = FlutterTts();
//   TtsInterruptionController ttsInterruptionController = TtsInterruptionController();
//   List<ParagraphData> paragraphs = [];
//   int currentParagraphIndex = 0;
//   bool isSpeaking = false;
//   bool autoPlay = false;
//   bool isTranslating = false;
//   String selectedLanguage = 'en-US';

//   final Set<String> blockTags = {
//     'p', 'div', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'blockquote', 'pre', 'hr'
//   };

//   final Map<String, String> languages = {
//   'ar': 'Arabic',
//   'as-IN': 'Assamese (India)',
//   'bg-BG': 'Bulgarian (Bulgaria)',
//   'bn-BD': 'Bengali (Bangladesh)',
//   'bn-IN': 'Bengali (India)',
//   'brx-IN': 'Bodo (India)',
//   'bs-BA': 'Bosnian (Bosnia and Herzegovina)',
//   'ca-ES': 'Catalan (Spain)',
//   'cs-CZ': 'Czech (Czech Republic)',
//   'cy-GB': 'Welsh (United Kingdom)',
//   'da-DK': 'Danish (Denmark)',
//   'de-DE': 'German (Germany)',
//   'doi-IN': 'Dogri (India)',
//   'el-GR': 'Greek (Greece)',
//   'en-AU': 'English (Australia)',
//   'en-GB': 'English (United Kingdom)',
//   'en-IN': 'English (India)',
//   'en-NG': 'English (Nigeria)',
//   'en-US': 'English (United States)',
//   'es-ES': 'Spanish (Spain)',
//   'es-US': 'Spanish (United States)',
//   'et-EE': 'Estonian (Estonia)',
//   'fi-FI': 'Finnish (Finland)',
//   'fil-PH': 'Filipino (Philippines)',
//   'fr-CA': 'French (Canada)',
//   'fr-FR': 'French (France)',
//   'gu-IN': 'Gujarati (India)',
//   'he-IL': 'Hebrew (Israel)',
//   'hi-IN': 'Hindi (India)',
//   'hr-HR': 'Croatian (Croatia)',
//   'hu-HU': 'Hungarian (Hungary)',
//   'id-ID': 'Indonesian (Indonesia)',
//   'is-IS': 'Icelandic (Iceland)',
//   'it-IT': 'Italian (Italy)',
//   'ja-JP': 'Japanese (Japan)',
//   'jv-ID': 'Javanese (Indonesia)',
//   'km-KH': 'Khmer (Cambodia)',
//   'kn-IN': 'Kannada (India)',
//   'ko-KR': 'Korean (South Korea)',
//   'kok-IN': 'Konkani (India)',
//   'lt-LT': 'Lithuanian (Lithuania)',
//   'lv-LV': 'Latvian (Latvia)',
//   'mai-IN': 'Maithili (India)',
//   'ml-IN': 'Malayalam (India)',
//   'mni-IN': 'Manipuri (India)',
//   'mr-IN': 'Marathi (India)',
//   'ms-MY': 'Malay (Malaysia)',
//   'nb-NO': 'Norwegian Bokmål (Norway)',
//   'ne-NP': 'Nepali (Nepal)',
//   'nl-BE': 'Dutch (Belgium)',
//   'nl-NL': 'Dutch (Netherlands)',
//   'or-IN': 'Odia (India)',
//   'pa-IN': 'Punjabi (India)',
//   'pl-PL': 'Polish (Poland)',
//   'pt-BR': 'Portuguese (Brazil)',
//   'pt-PT': 'Portuguese (Portugal)',
//   'ro-RO': 'Romanian (Romania)',
//   'ru-RU': 'Russian (Russia)',
//   'sa-IN': 'Sanskrit (India)',
//   'sat-IN': 'Santali (India)',
//   'sd-IN': 'Sindhi (India)',
//   'si-LK': 'Sinhala (Sri Lanka)',
//   'sk-SK': 'Slovak (Slovakia)',
//   'sq-AL': 'Albanian (Albania)',
//   'sr-RS': 'Serbian (Serbia)',
//   'su-ID': 'Sundanese (Indonesia)',
//   'sv-SE': 'Swedish (Sweden)',
//   'sw-KE': 'Swahili (Kenya)',
//   'ta-IN': 'Tamil (India)',
//   'te-IN': 'Telugu (India)',
//   'th-TH': 'Thai (Thailand)',
//   'tr-TR': 'Turkish (Turkey)',
//   'uk-UA': 'Ukrainian (Ukraine)',
//   'ur-IN': 'Urdu (India)',
//   'ur-PK': 'Urdu (Pakistan)',
//   'vi-VN': 'Vietnamese (Vietnam)',
//   'yue-HK': 'Cantonese (Hong Kong)',
//   'zh-CN': 'Chinese (Simplified, China)',
//   'zh-TW': 'Chinese (Traditional, Taiwan)',
//   };



//   static const String geminiApiUrl =
//       'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

//   ReaderProvider(String htmlContent, {String initialLanguage = 'en-US'}) {
//     selectedLanguage = initialLanguage;
//     paragraphs = _extractParagraphsFromHtml(htmlContent);
//     _configureTts();
//   }


// List<ParagraphData> _extractParagraphsFromHtml(String htmlString) {
//   final document = html_parser.parse(htmlString,);
//   List<ParagraphData> result = [];

//   // Define common image file extensions
//   final imageExtensions = ['.jpg', '.jpeg', '.webp', '.gif', '.bmp'];

//   // Define block-level tags
//   final blockTags = {
//     'p', 'div', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'ul', 'ol', 'li',
//     'section', 'article', 'main', 'blockquote', 'pre'
//   };

//   // Extract title
//   final title = document.querySelector('title');
//   if (title != null && title.text.trim().isNotEmpty) {
//     print('Found title: ${title.text.trim()}');
//     result.add(ParagraphData(
//       originalText: title.text.trim(),
//       translatedText: title.text.trim(),
//       images: [],
//     ));
//   }

//   final body = document.body;
//   if (body == null) {
//     print('No body found in HTML');
//     return result;
//   }

//   // Current buffer and images for the active block
//   StringBuffer currentBuffer = StringBuffer();
//   List<Map<String, String>> currentImages = [];
//   Set<String> seenUrls = {}; // Track unique image URLs within the current block

//   // Helper function to normalize URLs for deduplication (remove path variations for same image)
//   String normalizeUrl(String url) {
//     try {
//       final uri = Uri.parse(url);
//       // Extract base path up to the .ece and alternates, but ignore size-specific suffixes
//       final pathParts = uri.path.split('/');
//       if (pathParts.length >= 4) {
//         // For The Hindu style: /public/incoming/{id}.ece/alternates/{size}/filename.jpg
//         final baseParts = pathParts.sublist(0, 4); // Up to .ece
//         final basePath = baseParts.join('/');
//         return '${uri.scheme}://${uri.host}$basePath';
//       } else {
//         // Fallback: remove query/fragment as before
//         return uri.replace(query: '', fragment: '').toString();
//       }
//     } catch (e) {
//       // If parsing fails, return original
//       return url;
//     }
//   }

//   // Helper function to check if a URL is likely an image
//   bool isImageUrl(String url) {
//     if (url.isEmpty) return false;
//     final lowerUrl = url.toLowerCase();
//     return imageExtensions.any((ext) => lowerUrl.contains(ext)) ||
//            lowerUrl.contains('image') ||
//            lowerUrl.contains('img') ||
//            lowerUrl.contains('photo') ||
//            lowerUrl.contains('picture');
//   }

//   // Helper function to extract image data from a node
//   void extractImage(dom.Element node, String srcAttr, String altAttr) {
//     final src = node.attributes[srcAttr] ?? '';
//     final normalizedSrc = normalizeUrl(src);
//     final alt = node.attributes[altAttr] ?? node.attributes['alt'] ?? '';
//     if (src.isNotEmpty && isImageUrl(src) && !seenUrls.contains(normalizedSrc)) {
//       print('Found unique image: tag=${node.localName}, src=$src, normalized=$normalizedSrc, alt=$alt, attr=$srcAttr');
//       currentImages.add({'src': src, 'alt': alt});
//       seenUrls.add(normalizedSrc);
//     }
//   }

//   // Helper function to add a paragraph
//   void addParagraph(String text) {
//     text = text.trim();
//     if (text.isEmpty && currentImages.isEmpty) return;
//     if (text.isEmpty) {
//       text ='[Images]';
//     }
//     print('Adding paragraph: text="$text", images=$currentImages');
//     result.add(ParagraphData(
//       originalText: text,
//       translatedText: text,
//       images: List<Map<String, String>>.from(currentImages),
//     ));
//     currentImages.clear();
//     seenUrls.clear(); // Clear seen URLs after adding paragraph
//   }

//   void recurse(dom.Node node) {
//     if (node is dom.Text) {
//       currentBuffer.write(node.text);
//     } else if (node is dom.Element) {
//       final tag = node.localName?.toLowerCase() ?? '';
//       final isBlock = blockTags.contains(tag);

//       if (isBlock && tag != 'hr') {
//         // Process any accumulated text/images before starting new block
//         if (currentBuffer.isNotEmpty || currentImages.isNotEmpty) {
//           addParagraph(currentBuffer.toString());
//           currentBuffer.clear();
//         }
//         seenUrls.clear(); // Reset seen URLs for new block
//         print('Starting new block: tag=$tag');
//       }

//       // Handle image-related tags and attributes
//       if (tag == 'img') {
//         extractImage(node, 'src', 'alt');
//         extractImage(node, 'data-src', 'alt');
//         extractImage(node, 'data-lazy-src', 'alt');
//         final srcset = node.attributes['srcset'] ?? '';
//         if (srcset.isNotEmpty) {
//           final urls = srcset
//               .split(',')
//               .map((s) => s.trim().split(' ')[0])
//               .where((url) => url.isNotEmpty && isImageUrl(url))
//               .map(normalizeUrl)
//               .toSet() // Deduplicate URLs in srcset
//               .where((url) => !seenUrls.contains(url));
//           for (var normalizedUrl in urls) {
//             // Find the original URL that matches this normalized one (prefer the first occurrence)
//             final originalUrl = srcset
//                 .split(',')
//                 .map((s) => s.trim().split(' ')[0])
//                 .firstWhere((url) => normalizeUrl(url) == normalizedUrl, orElse: () => normalizedUrl);
//             print('Found unique image from srcset: tag=$tag, src=$originalUrl, normalized=$normalizedUrl, alt=${node.attributes['alt'] ?? ''}');
//             currentImages.add({'src': originalUrl, 'alt': node.attributes['alt'] ?? ''});
//             seenUrls.add(normalizedUrl);
//           }
//         }
//       } else if (tag == 'source') {
//         extractImage(node, 'src', 'alt');
//         extractImage(node, 'data-src', 'alt');
//         extractImage(node, 'data-lazy-src', 'alt');
//         final srcset = node.attributes['srcset'] ?? '';
//         if (srcset.isNotEmpty) {
//           final urls = srcset
//               .split(',')
//               .map((s) => s.trim().split(' ')[0])
//               .where((url) => url.isNotEmpty && isImageUrl(url))
//               .map(normalizeUrl)
//               .toSet() // Deduplicate URLs in srcset
//               .where((url) => !seenUrls.contains(url));
//           for (var normalizedUrl in urls) {
//             // Find the original URL that matches this normalized one
//             final originalUrl = srcset
//                 .split(',')
//                 .map((s) => s.trim().split(' ')[0])
//                 .firstWhere((url) => normalizeUrl(url) == normalizedUrl, orElse: () => normalizedUrl);
//             print('Found unique image from source srcset: src=$originalUrl, normalized=$normalizedUrl, alt=${node.attributes['alt'] ?? ''}');
//             currentImages.add({'src': originalUrl, 'alt': node.attributes['alt'] ?? ''});
//             seenUrls.add(normalizedUrl);
//           }
//         }
//       } else if (tag == 'picture') {
//         // Special handling for picture: process children but don't add extra
//         for (var child in node.nodes) {
//           recurse(child);
//         }
//         return; // Skip default recursion for picture
//       } else if (tag == 'div' || tag == 'span' || tag == 'a') {
//         final style = node.attributes['style'] ?? '';
//         final regex = RegExp(r'background(?:-image)?\s*:\s*url\((.*?)\)', caseSensitive: false);
//         final match = regex.firstMatch(style);
//         if (match != null) {
//           final url = match.group(1)?.replaceAll('"', '').replaceAll("'", '') ?? '';
//           final normalizedUrl = normalizeUrl(url);
//           if (isImageUrl(url) && !seenUrls.contains(normalizedUrl)) {
//             print('Found unique background image: tag=$tag, src=$url, normalized=$normalizedUrl');
//             currentImages.add({'src': url, 'alt': ''});
//             seenUrls.add(normalizedUrl);
//           }
//         }
//         if (tag == 'a') {
//           final href = node.attributes['href'] ?? '';
//           final normalizedHref = normalizeUrl(href);
//           if (isImageUrl(href) && !seenUrls.contains(normalizedHref)) {
//             print('Found unique image in <a> href: src=$href, normalized=$normalizedHref');
//             currentImages.add({'src': href, 'alt': node.attributes['title'] ?? ''});
//             seenUrls.add(normalizedHref);
//           }
//         }
//       } else if (tag == 'br') {
//         currentBuffer.write('\n');
//       }

//       // Recurse through child nodes (unless picture)
//       if (tag != 'picture') {
//         for (var child in node.nodes) {
//           recurse(child);
//         }
//       }

//       // Handle block tag end
//       if (isBlock && tag != 'hr') {
//         addParagraph(currentBuffer.toString());
//         currentBuffer.clear();
//         print('Ending block: tag=$tag');
//       }
//     }
//   }

//   recurse(body);

//   // Handle any remaining content
//   if (currentBuffer.isNotEmpty || currentImages.isNotEmpty) {
//     addParagraph(currentBuffer.toString());
//     currentBuffer.clear();
//   }

//   print('Final result: ${result.map((p) => {'text': p.originalText, 'images': p.images}).toList()}');
//   return result;
// }



//   // List<ParagraphData> _extractParagraphsFromHtml(String htmlString) {
//   //   final document = html_parser.parse(htmlString);
//   //   List<ParagraphData> result = [];

//   //   final title = document.querySelector('title');
//   //   if (title != null && title.text.trim().isNotEmpty) {
//   //     result.add(ParagraphData(
//   //         originalText: title.text.trim(), translatedText: title.text.trim(), images: []));
//   //   }

//   //   final body = document.body;
//   //   if (body == null) return result;

//   //   StringBuffer buffer = StringBuffer();
//   //   List<Map<String, String>> currentImages = [];

//   //   void recurse(dom.Node node) {
//   //     if (node is dom.Text) {
//   //       buffer.write(node.text);
//   //     } else if (node is dom.Element) {
//   //       final tag = node.localName?.toLowerCase() ?? '';
//   //       final isBlock = blockTags.contains(tag);

//   //       if (isBlock && tag != 'hr' && buffer.isNotEmpty) {
//   //         final text = buffer.toString().trim();
//   //         if (text.isNotEmpty) {
//   //           result.add(ParagraphData(
//   //               originalText: text, translatedText: text, images: List.from(currentImages)));
//   //         }
//   //         buffer.clear();
//   //         currentImages.clear();
//   //       }

//   //       if (tag == 'img') {
//   //         final src = node.attributes['src'] ?? '';
//   //         final alt = node.attributes['alt'] ?? '';
//   //         if (src.isNotEmpty) currentImages.add({'src': src, 'alt': alt});
//   //       }

//   //       for (var child in node.nodes) recurse(child);

//   //       if (isBlock) {
//   //         final text = buffer.toString().trim();
//   //         if (text.isNotEmpty) {
//   //           result.add(ParagraphData(
//   //               originalText: text, translatedText: text, images: List.from(currentImages)));
//   //         }
//   //         buffer.clear();
//   //         currentImages.clear();
//   //       } else if (tag == 'br') {
//   //         buffer.write('\n');
//   //       }
//   //     }
//   //   }

//   //   recurse(body);

//   //   final finalText = buffer.toString().trim();
//   //   if (finalText.isNotEmpty) {
//   //     result.addAll(finalText
//   //         .split('\n')
//   //         .map((s) => s.trim())
//   //         .where((s) => s.isNotEmpty)
//   //         .map((s) => ParagraphData(
//   //               originalText: s,
//   //               translatedText: s,
//   //               images: List.from(currentImages),
//   //             )));
//   //   }

//   //   return result;
//   // }

//   Future<void> _configureTts() async {
//     await flutterTts.setLanguage(selectedLanguage);
//     await flutterTts.setPitch(1.0);
//     await flutterTts.setSpeechRate(0.5);
    
//     flutterTts.setCompletionHandler(() {
//               print('TTS Completed: index=$currentParagraphIndex');

//       // isSpeaking = false;
//       // if (autoPlay && currentParagraphIndex < paragraphs.length - 1) {
//       //   currentParagraphIndex++;
//       //   _speakCurrentParagraph();
//       // } else {
//       //   autoPlay = false;
//       // }
//       notifyListeners();
//     });
//   }

//   Future<String> _translateText(String text, String targetLanguage) async {
//     if (text.isEmpty) return text;

//     final prompt = 'Translate the following content to $targetLanguage: "$text". '
//         'Only provide the equivalent text content.';
//     final body = jsonEncode({
//       'contents': [
//         {'parts': [{'text': prompt}]}
//       ]
//     });

//     try {
//       final response = await http.post(
//         Uri.parse('$geminiApiUrl?key=${APIClass.GEMINI_API_KEY}'),
//         headers: {'Content-Type': 'application/json'},
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         return jsonResponse['candidates'][0]['content']['parts'][0]['text'] ?? text;
//       } else {
//         return text;
//       }
//     } catch (e) {
//       print('Translation error: $e');
//       return text;
//     }
//   }

//   Future<void> translateParagraphs(String targetLanguage) async {
//     isTranslating = true;
//     notifyListeners();

//     List<ParagraphData> translated = [];
//     for (var p in paragraphs) {
//       String translatedText = p.originalText;
//       if (p.originalText.isNotEmpty && targetLanguage != 'en-US') {
//         translatedText = await _translateText(p.originalText, targetLanguage);
//       }
//       translated.add(ParagraphData(
//           originalText: p.originalText, translatedText: translatedText, images: p.images));
//     }

//     paragraphs = translated;
//     selectedLanguage = targetLanguage;
//     isTranslating = false;
//     await flutterTts.setLanguage(targetLanguage);
//     notifyListeners();
//   }

//   Future<void> _speakCurrentParagraph() async {
//     if (paragraphs.isEmpty) return;
//     isSpeaking = true;
//     notifyListeners();
//     await flutterTts.speak(paragraphs[currentParagraphIndex].translatedText);

    
//   }

//   Future<void> startAutoPlay() async {
//     await stop();
//     autoPlay = true;
//     currentParagraphIndex = 0;
//     notifyListeners();
//     _speakCurrentParagraph();
//   }

//   Future<void> stop() async {
//     await flutterTts.stop();
//     isSpeaking = false;
//     autoPlay = false;
//      currentParagraphIndex = 0;
//     notifyListeners();
//   }

//   Future<void> nextParagraph() async {
//     await flutterTts.pause();
//     if (currentParagraphIndex < paragraphs.length - 1) {
//       currentParagraphIndex++;
//       autoPlay = true;
//       notifyListeners();
//       _speakCurrentParagraph();
//     }
//   }

//   Future<void> previousParagraph() async {
//     await flutterTts.pause();
//     if (currentParagraphIndex > 0) {
//       currentParagraphIndex--;
//       autoPlay = true;
//       notifyListeners();
//       _speakCurrentParagraph();
//     }
//   }

//   Future<void> resumeReader() async {
//    // ttsInterruptionController.stopPlayingInBackground();
//     isSpeaking = true;
//     autoPlay = true;
//     notifyListeners();
//     _speakCurrentParagraph();
//   }

//   Future<void> pauseReader() async {
//     await flutterTts.pause();
//     isSpeaking = false;
//     autoPlay = false;
//     notifyListeners();
//   }
// }








// Working with paragraph without images  (working)


// class ReaderProvider extends ChangeNotifier {
//   final FlutterTts flutterTts = FlutterTts();

//   List<String> paragraphs = [];
//   int currentParagraphIndex = 0;
//   bool isSpeaking = false;
//   bool autoPlay = false;

//   final Set<String> blockTags = {
//     'p', 'div', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'blockquote', 'pre', 'hr'
//   };

//   ReaderProvider(String htmlContent, {String title = ''}) {
//     // Combine title with content
//     final combinedContent = title.isNotEmpty 
//         ? '<h2 style="text-align: center; margin-bottom: 20px;">$title</h2>\n$htmlContent'
//         : htmlContent;
//     paragraphs = _extractParagraphsFromHtml(combinedContent);
//     _configureTts();
//   }

//   List<String> _extractParagraphsFromHtml(String htmlString) {
//     final dom.Document document = html_parser.parse(htmlString);
//     List<String> paragraphs = [];

//     final dom.Element? title = document.querySelector('title');
//     if (title != null && title.text.trim().isNotEmpty) {
//       paragraphs.add(title.text.trim());
//     }

//     final dom.Element? body = document.body;
//     if (body == null) return paragraphs;

//     StringBuffer buffer = StringBuffer();
//     void recurse(dom.Node node) {
//       if (node is dom.Text) {
//         buffer.write(node.text);
//       } else if (node is dom.Element) {
//         String tag = node.localName?.toLowerCase() ?? '';
//         bool isBlock = blockTags.contains(tag);

//         if (isBlock && tag != 'hr' && buffer.isNotEmpty) {
//           final text = buffer.toString().trim();
//           if (text.isNotEmpty) paragraphs.add(text);
//           buffer.clear();
//         }

//         for (var child in node.nodes) recurse(child);

//         if (isBlock) {
//           if (tag == 'hr') {
//             final text = buffer.toString().trim();
//             if (text.isNotEmpty) paragraphs.add(text);
//             buffer.clear();
//           } else {
//             final text = buffer.toString().trim();
//             if (text.isNotEmpty) paragraphs.add(text);
//             buffer.clear();
//           }
//         } else if (tag == 'br') {
//           buffer.write('\n');
//         }
//       }
//     }

//     recurse(body);
//     final finalText = buffer.toString().trim();
//     if (finalText.isNotEmpty) {
//       paragraphs.addAll(
//         finalText.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty),
//       );
//     }
//     return paragraphs;
//   }

//   Future<void> _configureTts() async {
//     await flutterTts.setLanguage('en-US');
//     await flutterTts.setPitch(1.0);
//     await flutterTts.setSpeechRate(0.5);

//     flutterTts.setCompletionHandler(() {
//       isSpeaking = false;
//       if (autoPlay && currentParagraphIndex < paragraphs.length - 1) {
//         currentParagraphIndex++;
//         _speakCurrentParagraph();
//       } else {
//         autoPlay = false;
//       }
//       notifyListeners();
//     });
//   }

//   Future<void> _speakCurrentParagraph() async {
//     if (paragraphs.isNotEmpty &&
//         currentParagraphIndex >= 0 &&
//         currentParagraphIndex < paragraphs.length) {
//       isSpeaking = true;
//       notifyListeners();
//       await flutterTts.speak(paragraphs[currentParagraphIndex]);
//     }
//   }

//   Future<void> startAutoPlay() async {
//     await stop();
//     autoPlay = true;
//     currentParagraphIndex = 0;
//     notifyListeners();
//     _speakCurrentParagraph();
//   }

//   Future<void> stop() async {
//     await flutterTts.stop();
//     isSpeaking = false;
//     autoPlay = false;
//     currentParagraphIndex = 0;
//     notifyListeners();
//   }

//   void nextParagraph() {
//     flutterTts.pause();
//     if (currentParagraphIndex < paragraphs.length - 1) {
//       currentParagraphIndex++;
//       autoPlay = true;
//       notifyListeners();
//       _speakCurrentParagraph();
//     }
//   }

//   void previousParagraph() {
//     flutterTts.pause();
//     if (currentParagraphIndex > 0) {
//       currentParagraphIndex--;
//       autoPlay = true;
//       notifyListeners();
//       _speakCurrentParagraph();
//     }
//   }

//   void resumeReader() {
//     isSpeaking = true;
//     autoPlay = true;
//     notifyListeners();
//     _speakCurrentParagraph();
//   }

//   void pauseReader() async {
//     await flutterTts.pause();
//     isSpeaking = false;
//     autoPlay = false;
//     notifyListeners();
//   }
// }
