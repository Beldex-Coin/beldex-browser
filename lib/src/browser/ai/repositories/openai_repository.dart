import 'dart:convert';
import 'dart:developer';
import 'package:beldex_browser/constants_key.dart';
import 'package:beldex_browser/src/browser/ai/constants/string_constants.dart';

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

  Future<String> sendText(String text) async {
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
          {"role": "user", "content": text}
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

}
