import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:beldex_browser/src/browser/ai/ai_model_provider.dart';
import 'package:beldex_browser/src/browser/ai/constants/string_constants.dart';
import 'package:beldex_browser/src/browser/ai/enums/roles.dart';
import 'package:beldex_browser/src/browser/ai/models/chat_model.dart';
import 'package:beldex_browser/src/browser/ai/repositories/openai_repository.dart';
import 'package:beldex_browser/src/browser/ai/view_models/base_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/utils/show_message.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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
  }


// Summarise in floating action button
Future<void> getSummariseForFloatingActionButton(WebViewModel webViewModel)async{
   String response = await apiRepository.fetchAndSummarize('', webViewModel);
   sumResponse = response;
   updateUI();
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


Future<void> getTextAndSummariseInfo(WebViewModel webViewModel, String modelType, {String? sumText, bool isRegenerate = false}) async {
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
    scrollMessages();
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
            addSummarizeRetryMessage(webViewModel, modelType, sumText);
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
        addSummarizeRetryMessage(webViewModel, modelType, sumText);
    }

    updateUI();
    scrollMessages();
}


void addSummarizeRetryMessage(WebViewModel webViewModel, String modelType, String? sumText) {
    messages.add(ChatModel(
        role: Roles.model,
        text: StringConstants.retryMessage,
        isTypingComplete: true,
        canShowRegenerate: false,
        isRetry: true,
        isSummariseResult: true,
    ));

    updateUI();
}


void regenerateSummarization(WebViewModel webViewModel, String modelType) {
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
    getTextAndSummariseInfo(webViewModel, modelType, isRegenerate: true); // Restart response
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






/// get the stream type 

 StreamSubscription<String>? _streamSubscription;
 String? _lastUserMessage; // Store last user message

//String? _lastUserMessage; // Store the last user message

Future<void> getTextForUser({String? userMessage, bool isRegenerate = false,String modelType= 'openai'}) async {
  File? sendFile = _imageFile;
 print('The Default Model type -----> $modelType');
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







  if (!isRegenerate) {
    // Add a new user message only if it's a fresh request
    messages.add(ChatModel(
      text: messageToSend,
      role: Roles.user,
      image: sendFile,
      isTypingComplete: true,
      canShowRegenerate: false,
      isSummariseResult: false,
    ));
  }

  _imageFile = null;

  if (!isRegenerate) {
    // Add an empty AI response only if it's a fresh request
    messages.add(ChatModel(
      role: Roles.model,
      text: "",
      isTypingComplete: false,
      canShowRegenerate: false,
      isSummariseResult: false,
      istyping: true
    ));
  }

  modelResponseIndex = messages.length - 1;
  scrollMessages();
  updateUI();
    ///"Note: If this content contains only url then provide general information about the domain from the given URL as summarise, such as its purpose, industry, or key features." 
  isTyping = true;
  String wrd = '';
  // ✅ Listen to the streaming response and update existing message
  _streamSubscription = apiRepository.sendTextForStreamWithModel(modelType,messageToSend).listen((word) {
    print('onData coming ---$word');
    if (modelResponseIndex == null) return;
    wrd = word;
    messages[modelResponseIndex!].text += word; // Append words to existing text
    updateUI();
  }, onDone: () {
    print('OnMessage Done--');

    if(wrd == "Erroring"){
      messages[modelResponseIndex!].text = StringConstants.retryMessage;
      messages[modelResponseIndex!].isRetry = true;
       messages[modelResponseIndex!].isTypingComplete = true;
    messages[modelResponseIndex!].canShowRegenerate = false;
    messages[modelResponseIndex!].istyping = false;
    isTyping = false;
    }else{
       messages[modelResponseIndex!].isTypingComplete = true;
    messages[modelResponseIndex!].canShowRegenerate = false;
    messages[modelResponseIndex!].istyping = false;
    messages[modelResponseIndex!].isRetry = false;
    isTyping = false;
    }


    // messages[modelResponseIndex!].isTypingComplete = true;
    // messages[modelResponseIndex!].canShowRegenerate = false;
    // messages[modelResponseIndex!].istyping = false;
    // isTyping = false;
    updateUI();
    _streamSubscription?.cancel();
  }, onError: (error) {
     if (modelResponseIndex != null) {
    messages[modelResponseIndex!].istyping = false;
    messages[modelResponseIndex!].text = error.toString(); // Ensure error message is captured
  }
  
     isTyping = false;
    print("Error streaming response: $error");
    _streamSubscription?.cancel();
  });
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
void checkNetworkConnectivity()async{
  final connectivityResult = await Connectivity().checkConnectivity();

  if(connectivityResult == ConnectivityResult.none){
    showMessage("Network error.Please check mobile data/Wifi is on and retry");
    return;
  }else{
    // Step 2: Test Actual Internet Access
  bool hasInternet = await _hasInternetAccess();

  if (!hasInternet) {
    showMessage('Unprecedented traffic with Exit node. Please change exit node and retry');
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
    scrollMessages();
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

