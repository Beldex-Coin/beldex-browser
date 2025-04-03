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
          "Authorization": "Bearer ${APIClass.OPENAI_API_KEY}",
          "Content-Type": "application/json",
        },
        responseType: ResponseType.stream,
      ),
      cancelToken: cancelToken,
      data: jsonEncode({
        "model": "gpt-4-turbo",
        "messages": [
          {"role": "system", "content": "You are a helpful assistant. provide in bullet points if response more than 2 sentences"},
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
      Uri.parse(APIClass.OPENAI_API_URL),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${APIClass.OPENAI_API_KEY}',
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
      Uri.parse(APIClass.OPENAI_API_URL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${APIClass.OPENAI_API_KEY}',
      },
      body:utf8.encode( jsonEncode({
        "model": "gpt-4o-mini", // Replace with the desired model
        "messages": [
          {"role": "user", "content": "$text summarise this webpage in bullet points"}
        ],
        'max_tokens': 4096,
        //"temperature": 0.7, // Adjust temperature for creativity
      })),
    );
    if (response.statusCode == 200) {
      final decodeResponse = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> responseData = jsonDecode(decodeResponse);
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



//////////////////////////////////////////////////////////////////////////////

//For stream with multi-AI 

 static final Dio _dio = Dio();
  //static const String _apiKey = "YOUR_OPENAI_API_KEY";
  //static StreamSubscription? _subscription;


/// Store history for each model separately
   Map<String, List<Map<String, dynamic>>> _history = {
    "openai": [],
    "deepseek": [],
    "claude": [],
    "mistral": [],
    "gemini": []
  };

  Stream<String> sendTextForStreamWithModel(String modelType, String userMessage) async* {
    cancelToken = CancelToken();
    String apiUrl = "";
    Map<String, dynamic> requestData = {};
    Map<String, String> headers = {};
    print("THE CURRENT DEFAULT AI MODEL IS -----> $modelType");
    // Add the new user message to history
    _history[modelType]?.add({"role": "user", "content": userMessage});

    switch (modelType.toLowerCase()) {
      case "openai":
               try {
                apiUrl = "https://api.openai.com/v1/chat/completions";
  headers = {
    "Authorization": "Bearer ${APIClass.OPENAI_API_KEY}",
    "Content-Type": "application/json",
  };
  requestData = {
    "model": _getModelName(modelType),
    "messages": _history["openai"],
    // [
    //       {"role": "user", "content": "$userMessage"}
    //     ],
    "stream": true,  // Ensure streaming is enabled
  };
      final response = await _dio.post<ResponseBody>(
        apiUrl,
        options: Options(
          headers: headers,
          responseType: ResponseType.stream,
        ),
        cancelToken: cancelToken,
        data: jsonEncode(requestData),
      );
/////////////////////////////

String buffer = "";  // Accumulator for stream data


String fullContent = '';

  final utf8Decoder = Utf8Decoder(allowMalformed: true);
    await for (var data in response.data!.stream) {
      buffer += utf8Decoder.convert(data);
      print('Raw chunk (buffer): $buffer');

      List<String> lines = buffer.split('\n');
      if (!buffer.endsWith('\n')) {
        buffer = lines.removeLast();
      } else {
        buffer = '';
      }

      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty) continue;

        print('Processing line: $line');
        if (line.startsWith('data: ')) {
          String jsonString = line.substring(6);
          print('SSE data: $jsonString');

          if (jsonString == '[DONE]') {
            if (fullContent.isNotEmpty) {
              _history["openai"]!.add({
                "role": "assistant",
                "content": fullContent,
              });
              print('Stored in history: $fullContent');
            }
            print('Stream ended with [DONE]');
            continue;
          }

          try {
            final json = jsonDecode(jsonString);
            print('Parsed JSON: $json');
            final content = json['choices']?[0]?['delta']?['content']?.toString() ?? '';
            if (content.isNotEmpty) {
              print('Yielding content: "$content"'); // Log with quotes to see boundaries
              fullContent += content;
              yield content; // Yield content as a single chunk
            } else {
              print('Empty or no content in this chunk');
            }
          } catch (e) {
            print('JSON parse error in SSE: $e');
          }
        }
      }}   

//////////////////////
      // await for (var chunk in response.data!.stream) {
      //   final decoded = utf8.decode(chunk);

      //   print('Openai data -------> $decoded');
      //   for (var line in decoded.split("\n")) {
      //     if (line.isNotEmpty && line.startsWith("data: ")) {
      //       String jsonString = line.substring(6).trim();
      //       if (jsonString == "[DONE]") {
      //         yield ''; // End of stream signal
      //         return;
      //       }

      //       try {
      //         Map<String, dynamic> jsonData = jsonDecode(jsonString);
      //         String newText = _extractText(modelType, jsonData);
      //          print('Raw extract data $newText');
      //         _history[modelType]?.add({"role": "assistant", "content": newText});

      //         List<String> words = newText.split(" ");
      //         for (int i = 0; i < words.length; i++) {
      //           if (i > 0) yield " ";
      //           yield words[i];
      //         }
      //       } catch (e) {
      //         print("Error decoding response: $e");
      //       }
      //     }
      //   }
      // }
    } catch (e) {
      print("Unexpected error: $e");
      yield "Erroring";
    } 
    return;
      case "mistral":
      apiUrl = "https://api.mistral.ai/v1/chat/completions";
  headers = {
    "Authorization": "Bearer ${APIClass.MISTRAL_API_KEY}",
    "Content-Type": "application/json",
  };
  requestData = {
    "model": _getModelName(modelType),
    "messages": _history["mistral"],
    // [
    //       {"role": "user", "content": "$userMessage"}
    //     ],
    "stream": true,  // Ensure streaming is enabled
  };

  try {
    final response = await _dio.post<ResponseBody>(
      apiUrl,
      options: Options(
        headers: headers,
        responseType: ResponseType.stream,
      ),
      cancelToken: cancelToken,
      data: jsonEncode(requestData),
    );

String buffer = "";  // Accumulator for stream data


String fullContent = '';

  final utf8Decoder = Utf8Decoder(allowMalformed: true);
    await for (var data in response.data!.stream) {
      buffer += utf8Decoder.convert(data);
      print('Raw chunk (buffer): $buffer');

      List<String> lines = buffer.split('\n');
      if (!buffer.endsWith('\n')) {
        buffer = lines.removeLast();
      } else {
        buffer = '';
      }

      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty) continue;

        print('Processing line: $line');
        if (line.startsWith('data: ')) {
          String jsonString = line.substring(6);
          print('SSE data: $jsonString');

          if (jsonString == '[DONE]') {
            if (fullContent.isNotEmpty) {
              _history["mistral"]!.add({
                "role": "assistant",
                "content": fullContent,
              });
              print('Stored in history: $fullContent');
            }
            print('Stream ended with [DONE]');
            continue;
          }

          try {
            final json = jsonDecode(jsonString);
            print('Parsed JSON: $json');
            final content = json['choices']?[0]?['delta']?['content']?.toString() ?? '';
            if (content.isNotEmpty) {
              print('Yielding content: "$content"'); // Log with quotes to see boundaries
              fullContent += content;
              yield content; // Yield content as a single chunk
            } else {
              print('Empty or no content in this chunk');
            }
          } catch (e) {
            print('JSON parse error in SSE: $e');
          }
        }
      }}   


////////////////////
//String buffer = "";  // Accumulator for stream data


// String previousText = ""; // Track previous streamed response

// await for (var chunk in response.data!.stream) {
//   try {
//     String decoded = utf8.decode(chunk, allowMalformed: true);
//     buffer += decoded;

//     while (buffer.contains("data: ")) {
//       int dataStart = buffer.indexOf("data: ");
//       int dataEnd = buffer.indexOf("\n", dataStart);

//       if (dataEnd != -1) {
//         String completeChunk = buffer.substring(dataStart, dataEnd);
//         String jsonString = completeChunk.substring(6).trim(); 

//         if (jsonString == "[DONE]") {
//           print("✅ Stream finished");
//           return;
//         }

//         try {
//           Map<String, dynamic> jsonData = jsonDecode(jsonString);
//           String newText = jsonData["choices"]?[0]["delta"]?["content"] ?? "";

//           if (newText.isNotEmpty) {
//             // Find only the newly added portion
//             String newPart = newText.replaceFirst(previousText, "");
//             previousText = newText; // Update previousText for tracking

//             if (newPart.isNotEmpty) {
//               _history[modelType]?.add({"role": "assistant", "content": newPart});
//               yield newPart; // Yield only new words without duplication
//             }
//           }
//         } catch (e) {
//           print("❌ Error decoding response: $e");
//         }

//         buffer = buffer.substring(dataEnd + 1);
//       } else {
//         break;
//       }
//     }
//   } catch (e) {
//     print("❌ Error processing chunk: $e");
//     buffer = '';
//   }
// }


///////////////////

  // await for (var chunk in response.data!.stream) {
  //   try {
  //     // Decode the incoming chunk and append it to the buffer
  //     String decoded = utf8.decode(chunk, allowMalformed: true); // Allow malformed characters
  //     buffer += decoded;

  //     // Log the accumulated buffer for debugging
  //     print('Mistral DATA ---->  $buffer');

  //     // While we have a complete chunk (indicated by "data: "), try to process it
  //     while (buffer.contains("data: ")) {
  //       // Find the position of the first complete chunk starting with "data: "
  //       int dataStart = buffer.indexOf("data: ");
  //       int dataEnd = buffer.indexOf("\n", dataStart);  // Find the end of the current chunk

  //       if (dataEnd != -1) {
  //         // Extract the complete chunk from the buffer
  //         String completeChunk = buffer.substring(dataStart, dataEnd);
  //         String jsonString = completeChunk.substring(6).trim();  // Remove "data: " prefix

  //         // Handle end of stream (done signal)
  //         if (jsonString == "[DONE]") {
  //           print("Stream finished");
  //           yield '';  // End of stream
  //           return;
  //         }

  //         // Try to decode the JSON chunk
  //         try {
  //           Map<String, dynamic> jsonData = jsonDecode(jsonString);
  //           String newText = jsonData["choices"]?[0]["delta"]?["content"] ?? "";

  //           if (newText.isNotEmpty) {
  //             print("✅ Yielding new content: $newText");
  //              _history[modelType]?.add({"role": "assistant", "content": newText});
  //             yield newText;  // Yield the new content
  //           }
  //         } catch (e) {
  //           print("Error decoding response: $e");
  //           // If decoding fails, continue with the next chunk
  //         }

  //         // Remove the processed chunk from the buffer
  //         buffer = buffer.substring(dataEnd + 1);  // Move buffer past the processed chunk
  //       } else {
  //         // If no complete chunk is available, break the loop and wait for more data
  //         break;
  //       }
  //     }
  //   } catch (e) {
  //     print("Error processing chunk: $e");
  //     // In case of an error in chunk processing, reset the buffer and try again
  //     buffer = '';
  //   }
  // }
  } 
  catch (e) {
    print("Unexpected error: $e");
    yield "Erroring";
  }
  return;
  case "deepseek":
                apiUrl = 'https://api.deepseek.com/v1/chat/completions';
              headers = {
    "Authorization": "Bearer ${APIClass.DEEPSEEK_API_KEY}",
    "Content-Type": "application/json",
  };



  requestData = {
    "model": _getModelName(modelType),
    "messages":_history["deepseek"],
    // [
    //       {"role": "user", "content": "$userMessage"}
    //     ],
    "stream": true,  // Ensure streaming is enabled
  };
     try {
    final response = await _dio.post<ResponseBody>(
      apiUrl,
      options: Options(
        headers: headers,
        responseType: ResponseType.stream,
      ),
      cancelToken: cancelToken,
      data: jsonEncode(requestData),
    );


String buffer = "";  // Accumulator for stream data
  // Reset the buffer at the start of each new request
  buffer = "";  


//String previousText = ""; // Track previous streamed response


// await for (var chunk in response.data!.stream) {
//         final decoded = utf8.decode(chunk);

//         print('Deepseek data -------> $decoded');
//         for (var line in decoded.split("\n")) {
//           if (line.isNotEmpty && line.startsWith("data: ")) {
//             String jsonString = line.substring(6).trim();
//             if (jsonString == "[DONE]") {
//               yield ''; // End of stream signal
//               return;
//             }

//             try {
//               Map<String, dynamic> jsonData = jsonDecode(jsonString);
//               String newText = _extractText(modelType, jsonData);
//                print('Raw extract data $newText');
//               _history[modelType]?.add({"role": "assistant", "content": newText});

//               List<String> words = newText.split(" ");
//               for (int i = 0; i < words.length; i++) {
//                 if (i > 0) yield " ";
//                 yield words[i];
//               }
//             } catch (e) {
//               print("Error decoding response: $e");
//             }
//           }
//         }
//       }

//////////////////
String fullContent = '';

  final utf8Decoder = Utf8Decoder(allowMalformed: true);
    await for (var data in response.data!.stream) {
      buffer += utf8Decoder.convert(data);
      print('Raw chunk (buffer): $buffer');

      List<String> lines = buffer.split('\n');
      if (!buffer.endsWith('\n')) {
        buffer = lines.removeLast();
      } else {
        buffer = '';
      }

      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty) continue;

        print('Processing line: $line');
        if (line.startsWith('data: ')) {
          String jsonString = line.substring(6);
          print('SSE data: $jsonString');

          if (jsonString == '[DONE]') {
            if (fullContent.isNotEmpty) {
              _history["deepseek"]!.add({
                "role": "assistant",
                "content": fullContent,
              });
              print('Stored in history: $fullContent');
            }
            print('Stream ended with [DONE]');
            continue;
          }

          try {
            final json = jsonDecode(jsonString);
            print('Parsed JSON: $json');
            final content = json['choices']?[0]?['delta']?['content']?.toString() ?? '';
            if (content.isNotEmpty) {
              print('Yielding content: "$content"'); // Log with quotes to see boundaries
              fullContent += content;
              yield content; // Yield content as a single chunk
            } else {
              print('Empty or no content in this chunk');
            }
          } catch (e) {
            print('JSON parse error in SSE: $e');
          }
        }
      }}   
///////////////////////////////////////////



//   await for (var chunk in response.data!.stream) {
//     try {
//       // Decode the incoming chunk and append it to the buffer
//       String decoded = utf8.decode(chunk, allowMalformed: true); // Allow malformed characters
//       buffer += decoded;

//       // Log the accumulated buffer for debugging
//       print('Mistral DATA ---->  $buffer');

//       // While we have a complete chunk (indicated by "data: "), try to process it
//       while (buffer.contains("data: ")) {
//         // Find the position of the first complete chunk starting with "data: "
//         int dataStart = buffer.indexOf("data: ");
//         int dataEnd = buffer.indexOf("\n", dataStart);  // Find the end of the current chunk

//         if (dataEnd != -1) {
//           // Extract the complete chunk from the buffer
//           String completeChunk = buffer.substring(dataStart, dataEnd);
//           String jsonString = completeChunk.substring(6).trim();  // Remove "data: " prefix

//           // Handle end of stream (done signal)
//           if (jsonString == "[DONE]") {
//             print("Stream finished");
//             yield '';  // End of stream
//             return;
//           }

//           // Try to decode the JSON chunk
//           try {
//             Map<String, dynamic> jsonData = jsonDecode(jsonString);
//             String newText = jsonData["choices"]?[0]["delta"]?["content"] ?? "";

//             if (newText.isNotEmpty) {
//               print("✅ Yielding new content: $newText");
//                _history[modelType]?.add({"role": "assistant", "content": newText});
//               yield newText;  // Yield the new content
//             }
//           } catch (e) {
//             print("Error decoding response: $e");
//             // If decoding fails, continue with the next chunk
//           }

//           // Remove the processed chunk from the buffer
//           buffer = buffer.substring(dataEnd + 1);  // Move buffer past the processed chunk
//         } else {
//           // If no complete chunk is available, break the loop and wait for more data
//           break;
//         }
//       }
//     } catch (e) {
//       print("Error processing chunk: $e");
//       // In case of an error in chunk processing, reset the buffer and try again
//       buffer = '';
//     }
//   }
  } 
  catch (e) {
    print("Unexpected error: $e");
    yield "Erroring";
  }

  return ;
  case "gemini":
      

      final String apiUrl =
      "https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash-001:streamGenerateContent?key=${APIClass.GEMINI_API_KEY}";

  final Map<String, dynamic> requestData = {
    "contents": [
      {
        "parts": [
          {"text": userMessage}
        ]
      }
    ]
  };

  try {
    final response = await Dio().post<ResponseBody>(
      apiUrl,
      options: Options(
        headers: {"Content-Type": "application/json"},
        responseType: ResponseType.stream,
      ),
      cancelToken: cancelToken,
      data: jsonEncode(requestData),
    );




String buffer = '';
  String fullContent = ''; // Accumulate full response here
  final utf8Decoder = Utf8Decoder(allowMalformed: true);

print("✅ Response received. Status: ${response.statusCode}");
print("✅ Response received. Status: ${response.statusCode}");

    await for (var chunk in response.data!.stream) {
      final decoded = utf8Decoder.convert(chunk);
      print("🔹 Received chunk: '$decoded'");

      if (decoded.isEmpty) continue;

      buffer += decoded;

      // Process buffer for complete JSON arrays
      int startIndex = 0;
      while (true) {
        int nextOpen = buffer.indexOf('[', startIndex);
        if (nextOpen == -1) break; // No more arrays to process

        int bracketDepth = 0;
        int endIndex = -1;
        for (int i = nextOpen; i < buffer.length; i++) {
          if (buffer[i] == '[') bracketDepth++;
          if (buffer[i] == ']') bracketDepth--;
          if (bracketDepth == 0) {
            endIndex = i;
            break;
          }
        }

        if (endIndex == -1) break; // Incomplete array, wait for more data

        String jsonSnippet = buffer.substring(nextOpen, endIndex + 1);
        try {
          final List<dynamic> jsonResponse = jsonDecode(jsonSnippet);
          print("✅ Parsed JSON: $jsonResponse");

          for (var item in jsonResponse) {
            if (item.containsKey("candidates")) {
              final List<dynamic> parts = item["candidates"][0]["content"]["parts"];
              for (var part in parts) {
                if (part.containsKey("text")) {
                  String text = part["text"];
                  if (text.isNotEmpty) {
                    fullContent += text;
                    print("✅ Yielding content: '$text'");
                    yield text; // Yield immediately
                  }
                }
              }
            }
          }
          buffer = buffer.substring(endIndex + 1).trim(); // Remove processed part
          startIndex = 0; // Reset to start of remaining buffer
        } catch (e) {
          print("❌ Error decoding JSON: $e");
          break; // Wait for more data if parsing fails
        }

        // Check for [DONE] after processing
        if (buffer.contains('[DONE]')) {
          print("🏁 Stream ended with [DONE]");
          if (fullContent.isNotEmpty) {
            if (_history["gemini"] == null || _history["gemini"] is! List) {
              _history["gemini"] = [];
            }
            _history["gemini"]!.add({
              "role": "assistant",
              "content": fullContent,
            });
            print("📜 Stored in history: '$fullContent'");
          }
          buffer = '';
          break;
        }
      }
    }
    print("🔚 Stream processing completed");











//////////////////
// String buffer = '';
//      await for (var chunk in response.data!.stream) {
//       final decoded = utf8.decode(chunk).trim();
//       print("🔹 Received chunk: $decoded"); // Debugging response

//       if (decoded.isEmpty) continue;

//       buffer += decoded; // Append chunk to buffer

//       try {
//         // Ensure a complete JSON object before decoding
//         if (!buffer.endsWith("]")) continue; 

//         final List<dynamic> jsonResponse = jsonDecode(buffer);
//         buffer = ""; // Reset buffer after successful decoding

//         for (var item in jsonResponse) {
//           if (item.containsKey("candidates")) {
//             final List<dynamic> parts = item["candidates"][0]["content"]["parts"];

//             for (var part in parts) {
//               if (part.containsKey("text")) {
//                 String text = part["text"];

//                 for (int i = 0; i < text.length; i++) {
//                   yield text[i]; // Yield each character, including spaces
//                 }
//               }
//             }
//           }
//         }
//       } catch (e) {
//         print("❌ Error decoding JSON: $e");
//         // Don't clear the buffer since it might be incomplete JSON
//       }
//     }
  } catch (e) {
    print("🚨 Unexpected error: $e");
    yield "Erroring";
  }



////////////////////////////////////////////
















//       try {
//  // Ensure history exists and format it correctly
//     List<Content> chatHistory = (_history["gemini"] ?? []).map((msg) {
//       return Content(parts: [Parts(text: msg["content"] ?? "")]);
//     }).toList();
//     // Add current user message
//     chatHistory.add(Content(parts: [Parts(text: userMessage)]));

    
//     print("Formatted Chat History for Request: ${chatHistory.map((c) => c.parts!.first.text).toList()}");
//         // Assuming `sendStream` is a method of the `flutter_gemini` plugin
//         await for (final response in gemini.streamGenerateContent(userMessage)) {
//           // Extract text from response
//           final String newText = response.content?.parts?.map((part) => part.text).join(" ") ?? "";
          
//           if (newText.isNotEmpty) {
//             print('📝 Extracted Text: $newText');
            
//             // Append to history
//             _history[modelType]?.add({"role": "assistant", "content": newText});
            
//             // Stream word by word
//             List<String> words = newText.split(" ");
//             for (int i = 0; i < words.length; i++) {
//               if (i > 0) yield " ";
//               yield words[i];
//             }
//           }
//         }
//       } catch (e) {
//         print("Error in Gemini stream: $e");
//         yield "Erroring"; // in Gemini response: $e";
//       }
        return;

      default:
      print("Invalid model type: $modelType");
        yield "Erroring";
        return;
    }
  }


/// Extract text from API response
  String _extractText(String modelType, Map<String, dynamic> jsonData) {
    if (modelType == "openai" || modelType == "deepseek" || modelType == "mistral") {
      return jsonData["choices"][0]["delta"]["content"] ?? "";
    } else if (modelType == "claude") {
      return jsonData["content"][0]["text"] ?? "";
    } else if (modelType == "gemini") {
      // Debug: Print response to find the correct path
      print("Full Gemini Response: ${jsonEncode(jsonData)}");

      try {
      if (jsonData is Map && jsonData.containsKey("candidates")) {
        var candidates = jsonData["candidates"];
        if (candidates.isNotEmpty && candidates[0].containsKey("content")) {
          var content = candidates[0]["content"];
          if (content.containsKey("parts") && content["parts"] is List) {
            var parts = content["parts"];
            if (parts.isNotEmpty && parts[0].containsKey("text")) {
              return parts[0]["text"] ?? "";
            }
          }
        }
      }
    } catch (e) {
      print("Error extracting text: $e");
    }
      return "⚠️ No valid response found in Gemini API output.";
        }
    return "";
  }











 /// Get model name dynamically
  String _getModelName(String modelType) {
    switch (modelType) {
      case "openai":
        return "gpt-4o-mini";
      case "deepseek":
        return "deepseek-chat";
      case "mistral":
        return "mistral-small-latest";
      default:
        return "";
    }
  }



  /// Clears chat history for a specific model
  void clearHistory() {
    _history.clear();
    _history = {
    "openai": [],
    "deepseek": [],
    "claude": [],
    "mistral": [],
    "gemini": []
  };
  }



///////////////////////////////////////////////////////////////////////
// For summarise FAB 

Future<String> fetchAndSummarizeContent(String url, WebViewModel webViewModel,String modelType) async {
  try {

String pageContent = await  webViewModel.webViewController!.evaluateJavascript(
source: """
          (function() {
            let textContent = document.body.innerText;
            return textContent.trim();
          })();
        """,);
   
print('The response of the data coming from url $pageContent');
   String resp = //urlList.contains(url) ?
    await summaryWithUrls("${StringConstants.askSummaryForContent}.[$pageContent]", //"Please summarize the following content in a natural, well-structured paragraph format,start with title opt for the summarise content,only necessary content can be display in bullet points as well strucred sentences, similar to how a human would summarize an article. Ensure that the summary maintains coherence, captures key points, and flows naturally without just listing topics.[$pageContent]",
    modelType,"");
   return resp;
  } catch (e) {
    print("Error --> ${e.toString()}");
    return 'Erroring';
  }
}

Future<String> fetchAndSummarizeUrls(String url, WebViewModel webViewModel,String modelType) async {
  try {
   String resp = //urlList.contains(url) ?
    await summaryWithUrls("Please summarize the following url content in a natural, well-structured paragraph format,start with title opt for the summarise content,only necessary content can be display in bullet points as well strucred sentences, similar to how a human would summarize an article. Ensure that the summary maintains coherence, captures key points, and flows naturally without just listing topics.[$url]",modelType,"");
   return resp;
  } catch (e) {
    print("Error --> ${e.toString()}");
    return 'Erroring';
  }
}



Future<String> summaryWithUrls(String text, String model,String pageContent)async{
   String url = '';
    Map<String, dynamic> headers = {};
    Map<String, dynamic> body = {};
    cancelToken = CancelToken();

    switch (model) {
      case 'openai':
        url = 'https://api.openai.com/v1/chat/completions';
        headers = {
          'Authorization': 'Bearer ${APIClass.OPENAI_API_KEY}',
          'Content-Type': 'application/json',
        };
        body = {
          'model': 'gpt-4-turbo',
          'messages': [
             {'role': 'system', 'content': 'You are nice assistant.Provide response in bullet points:'},
            {'role': 'user', 'content': text}
          ],
          //'max-token': 4096
        };
        print('The Request data passed $text');
        break;

      case 'mistral':
        url = 'https://api.mistral.ai/v1/chat/completions';
        headers = {
          'Authorization': 'Bearer ${APIClass.MISTRAL_API_KEY}',
          'Content-Type': 'application/json',
        };
        body = {
          'model': 'mistral-small-latest',
          'messages': [
               // {'role': 'system', 'content': 'You are nice assistant.Provide response in bullet points:'},
            {'role': 'user', 'content': text}
          ],
        };
        break;
       case 'deepseek':
        
       url = 'https://api.deepseek.com/v1/chat/completions';
        headers = {
          'Authorization': 'Bearer ${APIClass.DEEPSEEK_API_KEY}',
          'Content-Type': 'application/json',
        };
        body = {
          'model': 'deepseek-chat',
          'messages': [
            // {'role': 'system', 'content': 'You are nice assistant.Provide response in bullet points:'},
            {'role': 'user', 'content': text}
          ],
          //'max-token': 4096
        };
        break;

      case 'gemini':
          url =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${APIClass.GEMINI_API_KEY}'; //'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${APIClass.GEMINI_API_KEY}';

   headers = {
    'Content-Type': 'application/json',
  };

  body = {
      "contents": [{
    "parts":[{"text": text}]
    }]
  };
         break;

      default:
        throw Exception('Invalid AI model selected');
    }

    try {
      Response response = await dio.post(
        url,
        options: Options(headers: headers),
        data: jsonEncode(body),
        cancelToken:cancelToken
      );
       print("The response from the models direct---$model");

       print("The response from the models directly ---- ${response.data}");
      if (response.statusCode == 200) {
        return _parseResponse(response.data, model);
      } else {
        print('The Response Errorcode ${response.statusCode}');
        return 'Erroring';
       // throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      print('The Response Error $model ----${e.toString()}');
      return 'Erroring';
     // throw Exception('Error fetching AI response: $e');
    }
}

String _parseResponse(dynamic data, String model) {
    switch (model) {
      case 'openai':
        return data['choices'][0]['message']['content'] ?? 'No response';
      case 'mistral':
        return data['choices'][0]['message']['content'] ?? 'No response';
      case 'gemini':
        return data['candidates'][0]['content']['parts'][0]['text'] ?? 'No response';
      case 'deepseek':
        return data['choices'][0]['message']['content'] ?? 'No response';
      default:
        return 'Invalid model response';
    }
  }

}
