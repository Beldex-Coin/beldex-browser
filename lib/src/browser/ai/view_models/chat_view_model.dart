import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:beldex_browser/src/browser/ai/enums/roles.dart';
import 'package:beldex_browser/src/browser/ai/models/chat_model.dart';
import 'package:beldex_browser/src/browser/ai/repositories/openai_repository.dart';
import 'package:beldex_browser/src/browser/ai/view_models/base_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:flutter/material.dart';

class ChatViewModel extends BaseModel {
  final OpenAIRepository apiRepository = OpenAIRepository();
  final TextEditingController messageController = TextEditingController();
   ScrollController scrollController = ScrollController();
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




// For summarise 
Future<void> getTextAndSummariseInfo(WebViewModel webViewModel) async {
    //File? sendFile;
    String? summariseUrlText;
    summariseUrlText = summariseText;
    //sendFile = imageFile;
    if(summariseUrlText != null){
  messages.add(ChatModel(
      text: "${webViewModel.title.toString()} - Summarise page",
      role: Roles.user,
      isTypingComplete: true,
      canShowRegenerate: false,
      isSummariseResult: false,
     // image: sendFile,
    ));
    }else{
      messages.add(ChatModel(
      text: messageController.text,
      role: Roles.user,
      isTypingComplete: true,
      canShowRegenerate: false,
      isSummariseResult: false,
     // image: sendFile,
    ));
    }
   
    imageFile = null;
    summariseText = null;
    messages.add(ChatModel(
      role: Roles.model,
      text: "",
      isTypingComplete: false,
      canShowRegenerate: false,
      isSummariseResult: false,
      istyping: true
    ));
    modelResponseIndex = messages.length;
    scrollMessages();
    updateUI();
    String response = await apiRepository.sendTextForSummarise("${webViewModel.title.toString()} - Summarise this webpage"); //await apiRepository.sendTextAndImage(messageController.text, sendFile)
     
    messages.removeAt(messages.length - 1);
    messages.add(ChatModel(
      role: Roles.model,
      text: response,
      isTypingComplete: true,
      canShowRegenerate: false,
      isSummariseResult: false,
      istyping: false
    ));
    scrollMessages();
    updateUI();
  }



/// get the stream type 

 StreamSubscription<String>? _streamSubscription;
 String? _lastUserMessage; // Store last user message

//String? _lastUserMessage; // Store the last user message

Future<void> getTextForUser({String? userMessage, bool isRegenerate = false}) async {
  File? sendFile = _imageFile;

  // Use the stored last message if regenerating, otherwise get from input field
  String messageToSend = userMessage ?? messageController.text;
  _lastUserMessage = messageToSend; // Save the last message

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
  
  isTyping = true;
  // ✅ Listen to the streaming response and update existing message
  _streamSubscription = apiRepository.sendTextForStream(messageToSend).listen((word) {
    print('onData coming ---$word');
    if (modelResponseIndex == null) return;
    messages[modelResponseIndex!].text += word; // Append words to existing text
    updateUI();
  }, onDone: () {
    print('OnMessage Done--');
    messages[modelResponseIndex!].isTypingComplete = true;
    messages[modelResponseIndex!].canShowRegenerate = false;
    messages[modelResponseIndex!].istyping = false;
    isTyping = false;
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





























// For Ask Beldex AI

Future<void> getTextFromAskBeldexAI(String question,WebViewModel webViewModel) async {
   // File? sendFile;
   
final uri = Uri.parse(question);
     if(uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')){
      // sendFile = imageFile;
      messages.add(ChatModel(
      text: '$uri',
      role: Roles.user,
      //image: null,// sendFile,
    ));
   
     }else{
      // sendFile = imageFile;
      messages.add(ChatModel(
      text: question,
      role: Roles.user,
      //image: null,// sendFile,
    ));
   
     }





   
    imageFile = null;
    summariseText = null;
    messages.add(ChatModel(
      role: Roles.model,
      text: "",
    ));
    modelResponseIndex = messages.length;
    scrollMessages();
    updateUI();
    String response = uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https') ?
     await apiRepository.sendTextForSummarise("${uri.toString()} - Summarise this webpage")
    : await apiRepository.sendText(question); //await apiRepository.sendTextAndImage(messageController.text, sendFile)
        //: await apiRepository.sendText(messageController.text);
    messages.removeAt(messages.length - 1);
    messages.add(ChatModel(
      role: Roles.model,
      text: response,
    ));
    scrollMessages();
    updateUI();
  }











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
