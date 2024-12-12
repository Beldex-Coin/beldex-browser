import 'dart:async';

import 'package:beldex_browser/src/browser/ai/chat_message.dart';
import 'package:beldex_browser/src/browser/ai/network_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_preference.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  TextEditingController _tokenController = TextEditingController();
  final ChatGPTService _chatGPTService = ChatGPTService(
      apiKey:'API_KEY');

  final List<ChatMessage> _messages = [];
  String? token;
  //OpenAI? openAI;
  StreamSubscription? subscription;
  @override
  void initState() {
    // final prefs = SharedPreferences.getInstance();

    // Add a listener to detect text changes
    _tokenController.addListener(() {
      // Move the cursor to the end whenever the text changes
      _tokenController.selection = TextSelection.fromPosition(
        TextPosition(offset: _tokenController.text.length),
      );
    });
    super.initState();
  }

 
  
  // void _sendMessage() async {
  //   ChatMessage message = ChatMessage(text: _controller.text, sender: "user");
  //   setState(() {
  //     _messages.insert(0, message);
  //   });
  //   _controller.clear();

  //   // final request = ChatCompleteText(
  //   //     model: Gpt4ChatModel(),
  //   //     messages: [
  //   //       Map.of({"role": "user", "content": message.text})
  //   //     ],
  //   //     maxToken: 200);

  //   final request = ChatCompleteText(messages: [
  //     Map.of({"role": "user", "content": message.text})
  //   ], maxToken: 200, model: GptTurboChatModel());
  //   try {
  //     ChatCTResponse? response =
  //         await openAI!.onChatCompletion(request: request);
  //     print("DATA IN the response ${response!.choices[0].message}");
  //     for (var element in response.choices) {
  //       print("data -> ${element.message?.content}");
  //     }

  //     if (response != null && response.choices.isNotEmpty) {
  //       ChatMessage botMessage = ChatMessage(
  //           text: response!.choices[0].message!.content.toString(),
  //           sender: "bot");

  //       setState(() {
  //         _messages.insert(0, botMessage);
  //       });

  //       print(
  //           "Request was successful. Data: ${response.choices[0].message?.content}");
  //     } else {
  //       print("Request completed but no data found.");
  //     }
  //   } catch (e) {
  //     print('ERROR CODE $e');

  //     setState(() {
  //       _messages.insertT(0, ChatMessage(text: e.toString(), sender: "bot"));
  //     });
  //   }
  // }

  String _response = '';

  void _sendUserMessage(WebViewModel webViewModel) async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    ChatMessage uMessage = ChatMessage(text: _controller.text, sender: "user");
    setState(() {
      _messages.insert(0, uMessage);
    });
    _controller.clear();

    setState(() {
      _response = 'Loading...';
    });

    final response = await _chatGPTService.fetchAndSummarize('',webViewModel); //sendMessage(message);
    
    setState(() {
      _response = response;

      _messages.insert(
          0, ChatMessage(text: _response.toString(), sender: 'bot'));

      print('Response ------ > $_response');
    });

    _controller.clear();
  }

  Widget _buildTextComposer() {
    final themeProvider = Provider.of<DarkThemeProvider>(context,listen: false);
    var webViewModel = Provider.of<WebViewModel>(context, listen: true);
    return Row(
      children: [
        Expanded(
            child: TextField(
          controller: _controller,
          decoration:
               InputDecoration.collapsed(hintText: "Send a Message",hintStyle: TextStyle(color: themeProvider.darkTheme ? Colors.white : Colors.black )),
        )),
        IconButton(
          onPressed: () => _sendUserMessage(webViewModel),
          icon: const Icon(Icons.send),
        ),
      ],
    ).px16();
  }

  @override
  void dispose() {
    subscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'BELDEX AI',
          textAlign: TextAlign.center,
        ),
        // actions: [
        //   IconButton(
        //       onPressed: () => _showAllHistory(context),
        //       icon: const Icon(Icons.settings))
        // ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
                child: ListView.builder(
                    reverse: true,
                    padding: Vx.m8,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _messages[index];
                    })),




            Container(
              decoration: BoxDecoration(color: context.cardColor),
              child: _buildTextComposer(),
            ),


            // Container(
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: Container(
            //           padding: EdgeInsets.all(0),
            //           decoration: BoxDecoration(
            //             color: Color(0xff3D4354),
            //             borderRadius: BorderRadius.circular(25.0)
            //           ),
            //           child: Column(
            //             children: [
            //               Row(

            //                 children: [
            //                   IconButton(onPressed: (){}, 
            //                   icon: Icon(Icons.emoji_emotions)),
            //                   Flexible(
            //                     child: TextField(
            //                       minLines: 1,
            //                       maxLines: null,
            //                       keyboardType: TextInputType.text,
            //                       keyboardAppearance: Brightness.dark,
            //                       cursorColor: Colors.white54,
            //                       style: TextStyle(color: Colors.white,),
            //                       decoration: InputDecoration(
            //                         counterStyle: const TextStyle(color: Colors.white54),
            //                         hintText: 'Type Message',
            //                         hintStyle: TextStyle(color: Colors.white54,fontSize: 15),
            //                         border: OutlineInputBorder(
            //                           borderRadius: BorderRadius.circular(25.0),
            //                           borderSide: BorderSide.none
            //                         ),
            //                         contentPadding: EdgeInsets.symmetric(vertical: 12.0)
            //                       ),
            //                     )
            //                   ),
            //                 ],
            //               )
            //             ],
            //           ),
            //         ),
                    
            //       )
            //     ],
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}




