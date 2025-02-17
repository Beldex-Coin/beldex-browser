import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:beldex_browser/constants_key.dart';
import 'package:beldex_browser/src/browser/ai/constants/string_constants.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:dio/dio.dart';

import 'package:http/http.dart' as http;

class OpenAIRepository {
  static final OpenAIRepository _instance = OpenAIRepository._internal();

  factory OpenAIRepository() {
    return _instance;
  }

  OpenAIRepository._internal() {
    _response = response;
  }

  String? _response;

  String? get response => _response;

  void setResponse(String? value) {
    _response = value;
  }




Dio dio = Dio();
  CancelToken cancelToken = CancelToken(); // Create a new cancel token

  static StreamSubscription? _subscription;
  // Function to cancel the request
  cancelRequest() {
    cancelToken.cancel("User canceled the request");
  }


Stream<String> sendTextForStream(String userMessage) async* {
  cancelToken = CancelToken();

  try {
    final response = await dio.post<ResponseBody>(
      "https://api.openai.com/v1/chat/completions",
      options: Options(
        headers: {
          "Authorization": "Bearer ${APIClass.API_KEY}",
          "Content-Type": "application/json",
        },
        responseType: ResponseType.stream,
      ),
      cancelToken: cancelToken,
      data: jsonEncode({
        "model": "gpt-4",
        "messages": [
          {"role": "system", "content": "You are a helpful assistant."},
          {"role": "user", "content": userMessage}
        ],
        "stream": true,
      }),
    );


if (cancelToken.isCancelled) {
    print("🚨 Request was canceled: ");
    yield "Request was canceled by the user."; // Send as single string
  } 
  // else {
  //   print("❌ Network error: ");
  //   yield "Network errors:";
  // }
    await for (var chunk in response.data!.stream) {
      final decoded = utf8.decode(chunk);
      
      for (var line in decoded.split("\n")) {
        if (line.isNotEmpty && line.startsWith("data: ")) {
          String jsonString = line.substring(6).trim();
          if (jsonString == "[DONE]") {
            yield ''; // End of stream signal
            return;
          }

          try {
            Map<String, dynamic> jsonData = jsonDecode(jsonString);
            String newText = jsonData["choices"][0]["delta"]["content"] ?? "";

            // Emit words one by one with spaces
            List<String> words = newText.split(" ");
            for (int i = 0; i < words.length; i++) {
              if (i > 0) yield " ";
              yield words[i];
            }
          } catch (e) {
            //yield _emitErrorMessage("Error decoding server response.");
          }
        }
      }
    }
  } on DioException catch (e) {
  if (CancelToken.isCancel(e)) {
    print("🚨 Request was canceled: ${e.message}");
    yield "Request was canceled by the user."; // Send as single string
  } else {
    print("❌ Network error: ${e.message}");
    yield "Network error: ${e.message}";
  }
}
catch (e) {
  print("❌ Unexpected error: $e");
  yield "An unexpected error occurred.";
}
}



  // Future<String> sendText(String text) async {
  // String responseText = "";
  // try {
  //   final response = await http.post(
  //     Uri.parse(APIClass.API_URL),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer ${APIClass.API_KEY}',
  //     },
  //     body: jsonEncode({
  //       "model": "gpt-4o-mini", // Replace with the desired model
  //       "messages": [
  //         {"role": "user", "content": text}
  //       ],
  //       'max_tokens': 4096,
  //       //"temperature": 0.7, // Adjust temperature for creativity
  //     }),
  //   );
  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> responseData = jsonDecode(response.body);
  //     // Extracting the response content
  //     responseText = responseData["choices"]?[0]?["message"]?["content"] ?? "";
  //     log("OpenAI Chat - Content: $responseText");
  //     // Handle finish reason if needed
  //     final String finishReason = responseData["choices"]?[0]?["finish_reason"] ?? "";
  //     if (finishReason != "stop") {
  //       responseText = "Invalid Query"; // Replace with a constant if needed
  //     }
  //   } else {
  //     log("OpenAI Chat - Error: ${response.body}");
  //     responseText = "Error: ${response.reasonPhrase}";
  //   }
  // } catch (e) {
  //   log("OpenAI Chat - Exception: $e");
  //   responseText = "Error: $e";
  // }
  // log("OpenAI Chat - Final Response: $responseText");
  // return responseText;   
  // }


Future<String> sendText(String text) async {
  String responseText = "";
  try {
    final response = await http.post(
      Uri.parse(APIClass.API_URL),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${APIClass.API_KEY}',
      },
      body: utf8.encode(
         
      jsonEncode({
        "model": "gpt-4o-mini", // Replace with the desired model
        "messages": [
          {"role": "user", "content": text}
        ],
        'max_tokens': 4096,
        //"temperature": 0.7, // Adjust temperature for creativity
      }),
      )
      
      
    );
    if (response.statusCode == 200) {
       final decodeResponse = utf8.decode(response.bodyBytes);

      final Map<String, dynamic> responseData =  jsonDecode(decodeResponse);
      // Extracting the response content
      responseText = responseData["choices"]?[0]?["message"]?["content"] ?? "";
      log("OpenAI Chat - Content: $responseText ------- ${utf8.decode(response.bodyBytes)}");
      // Handle finish reason if needed
      final String finishReason = responseData["choices"]?[0]?["finish_reason"] ?? "";
      if (finishReason != "stop") {
        responseText = "Invalid Query"; // Replace with a constant if needed
      }
    } else {
      log("OpenAI Chat - Error: ${response.body}");
      responseText = "Error: ${response.reasonPhrase}";
    }
  } catch (e) {
    log("OpenAI Chat - Exception: $e");
    responseText = "Error: $e";
  }
  log("OpenAI Chat - Final Response: $responseText ");
  return responseText;   
  }













Future<String> sendTextForSummarise(String text) async {
  String responseText = "";
  try {
    final response = await http.post(
      Uri.parse(APIClass.API_URL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${APIClass.API_KEY}',
      },
      body: jsonEncode({
        "model": "gpt-4o-mini", // Replace with the desired model
        "messages": [
          {"role": "user", "content": "$text summarise this webpage in bullet points"}
        ],
        'max_tokens': 4096,
        //"temperature": 0.7, // Adjust temperature for creativity
      }),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      // Extracting the response content
      responseText = responseData["choices"]?[0]?["message"]?["content"] ?? "";
      log("OpenAI Chat - Content: $responseText");
      // Handle finish reason if needed
      final String finishReason = responseData["choices"]?[0]?["finish_reason"] ?? "";
      if (finishReason != "stop") {
        responseText = "Invalid Query"; // Replace with a constant if needed
      }
    } else {
      log("OpenAI Chat - Error: ${response.body}");
      responseText = "Error: ${response.reasonPhrase}";
    }
  } catch (e) {
    log("OpenAI Chat - Exception: $e");
    responseText = "Error: $e";
  }
  log("OpenAI Chat - Final Response: $responseText");
  return responseText;

   
  }



// Summarise for floating action button

Future<String> fetchAndSummarize(String url, WebViewModel webViewModel) async {
  try {
      // Step 3: Send content to OpenAI for summarization
      final openAiResponse = await http.post(
        Uri.parse(APIClass.API_URL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${APIClass.API_KEY}',
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









}
