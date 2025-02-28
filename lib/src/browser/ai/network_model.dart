import 'dart:convert';
import 'package:beldex_browser/constants_key.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:http/http.dart' as http;

class ChatGPTService {
  final String apiKey; // Your OpenAI API Key

  ChatGPTService({required this.apiKey});



Future<String> fetchAndSummarize(String url, WebViewModel webViewModel) async {
  try {
    // Step 1: Fetch the HTML content of the URL
    // final response = await http.get(Uri.parse(url));
    // if (response.statusCode == 200) {
    //   String htmlContent = response.body;
    //   print('AI URL content1 -- $htmlContent');
    //   // Step 2: Extract text content using a regex
    //   // Remove HTML tags
    //   String textContent = htmlContent.replaceAll(RegExp(r'<[^>]*>'), ' ');
    //    print('AI URL content 2-- $textContent');
    //   // Trim the content to a reasonable size for summarization
    //   if (textContent.length > 4000) {
    //     textContent = textContent.substring(0, 4000);
    //     print('AI URL content3 -- $textContent');
    //   }


        
    // String? extractedContent = await webViewModel.webViewController?.evaluateJavascript(
    //               source: "document.body.innerText");
//  print('AI URL here --- $extractedContent');
// if(extractedContent != null && extractedContent.isNotEmpty){
//    if(extractedContent.length > 4000){
//    // extractedContent = extractedContent.substring(0, 4000);
//    }
// }




      // Step 3: Send content to OpenAI for summarization
      final openAiResponse = await http.post(
        Uri.parse(APIClass.OPENAI_API_URL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${APIClass.OPENAI_API_KEY}',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',//'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': 'Summarize the following webpage in bullet dot points:'},
            {'role': 'user', 'content': '${webViewModel.url} summarise this webpage' //extractedContent  
            },
          ],
          'max_tokens': 4096, // Adjust as needed
        }),
      );

      if (openAiResponse.statusCode == 200) {
        final responseBody = json.decode(openAiResponse.body);
        final choices = responseBody['choices'] as List;
        if (choices.isNotEmpty) {
          return choices[0]['message']['content'];
        } else {
          return 'No response from ChatGPT.';
        }
      } else {
        // Parse and return error from OpenAI
        final responseBody = json.decode(openAiResponse.body);
        if (responseBody.containsKey('error')) {
          return 'Error: ${responseBody['error']['message']}';
        } else {
          return 'Error: ${openAiResponse.statusCode} - ${openAiResponse.reasonPhrase}';
        }
      }

    // } else {
    //   throw Exception('Failed to fetch URL content.');
    // }
  } catch (e) {
    return 'Error: ${e.toString()}';
  }
}











  Future<String> sendMessage(String message) async {
   

    try {
      final response = await http.post(
        Uri.parse(APIClass.OPENAI_API_URL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${APIClass.OPENAI_API_KEY}',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini', // Or 'gpt-4' if you have access
          'messages': [
            {'role': 'system', 'content': 'You are a helpful assistant.'},
            {'role': 'user', 'content': message},
          ],
          'max_tokens': 4096,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final choices = responseBody['choices'] as List;
        if (choices.isNotEmpty) {
          return choices[0]['message']['content'];
        } else {
          return 'No response from ChatGPT.';
        }
      } else {
        // Parse and return error from OpenAI
        final responseBody = json.decode(response.body);
        if (responseBody.containsKey('error')) {
          return 'Error: ${responseBody['error']['message']}';
        } else {
          return 'Error: ${response.statusCode} - ${response.reasonPhrase}';
        }
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
