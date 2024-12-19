import 'dart:async';

import 'package:beldex_browser/src/browser/ai/chat_message.dart';
import 'package:beldex_browser/src/browser/ai/constants/icon_constants.dart';
import 'package:beldex_browser/src/browser/ai/network_model.dart';
import 'package:beldex_browser/src/browser/ai/string_constants.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_preference.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
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
  final ChatGPTService _chatGPTService = ChatGPTService(apiKey: 'API_KEY');

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

    final response = await _chatGPTService.fetchAndSummarize(
        '', webViewModel); //sendMessage(message);

    setState(() {
      _response = response;

      _messages.insert(
          0, ChatMessage(text: _response.toString(), sender: 'bot'));

      print('Response ------ > $_response');
    });

    _controller.clear();
  }

  Widget _buildTextComposer() {
    final themeProvider =
        Provider.of<DarkThemeProvider>(context, listen: false);
    var webViewModel = Provider.of<WebViewModel>(context, listen: true);
    return Row(
      children: [
        Expanded(
            child: TextField(
          controller: _controller,
          decoration: InputDecoration.collapsed(
              hintText: "Send a Message",
              hintStyle: TextStyle(
                  color:
                      themeProvider.darkTheme ? Colors.white : Colors.black)),
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




class SummariseUrlResult extends StatefulWidget {
  const SummariseUrlResult({super.key});

  @override
  State<SummariseUrlResult> createState() => _SummariseUrlResultState();
}

class _SummariseUrlResultState extends State<SummariseUrlResult> {

String title = "";
  String paragraph = "";
  List<String> bullets = [];
 final ChatGPTService _chatGPTService = ChatGPTService(apiKey: 'API_KEY');
 bool _isLoading = true;


  String displayedTitle = "";
  String displayedParagraph = "";
  List<String> displayedBullets = [];

  Timer? typingTimer;



 @override
  void didChangeDependencies() {
    
    super.didChangeDependencies();
    callSummaryApI(context);
  }





void callSummaryApI(BuildContext context)async{
  try{
     final webViewModel = Provider.of<WebViewModel>(context,listen: false);
  final response = await _chatGPTService.fetchAndSummarize(
        '', webViewModel);
    if(response.isNotEmpty){

      _parseResponse(response);
    }

  }catch(e){
    print(e);
  }finally{
    setState(() {
        _isLoading = false;
      });
  }
}

void _parseResponse(String response) {
    // Split response into lines
    List<String> lines = response.split("\n");

    // Extract title (assume the first non-empty line is the title)
    title = lines.firstWhere((line) => line.trim().isNotEmpty, orElse: () => "");

    // Extract paragraph (assume the first full sentence block is the paragraph)
    paragraph = lines.skip(1).firstWhere((line) => line.trim().isNotEmpty, orElse: () => "");

    // Extract bullet points (assume lines starting with "-", "•", or similar are bullets)
    bullets = lines
        .where((line) => line.trim().startsWith(RegExp(r"[-•]")))
        .map((line) => line.trim().replaceFirst(RegExp(r"[-•]\s*"), ""))
        .toList();

    setState(() {});

    _startTypingAnimation();
  }



void _startTypingAnimation() {
    int titleIndex = 0;
    int paragraphIndex = 0;
    int bulletIndex = 0;
    int bulletCharIndex = 0;

    displayedTitle = "";
    displayedParagraph = "";
    displayedBullets = [];

    typingTimer?.cancel();

    typingTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      // Type the title character by character
      if (titleIndex < title.length) {
        setState(() {
          displayedTitle += title[titleIndex];
          titleIndex++;
        });
      }
      // Type the paragraph character by character
      else if (paragraphIndex < paragraph.length) {
        setState(() {
          displayedParagraph += paragraph[paragraphIndex];
          paragraphIndex++;
        });
      }
      // Type the bullets one by one
      else if (bulletIndex < bullets.length) {
        if (displayedBullets.length <= bulletIndex) {
          displayedBullets.add(""); // Initialize the current bullet point
        }

        if (bulletCharIndex < bullets[bulletIndex].length) {
          setState(() {
            displayedBullets[bulletIndex] += bullets[bulletIndex][bulletCharIndex];
            bulletCharIndex++;
          });
        } else {
          bulletIndex++;
          bulletCharIndex = 0;
        }
      } else {
        // Stop the timer once all text is typed
        timer.cancel();
      }
    });
  }


 @override
  void dispose() {
   typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     final themeProvider = Provider.of<DarkThemeProvider>(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.95, // Initial size of the sheet
      minChildSize: 0.3, // Minimum size of the sheet
      maxChildSize: 1.0, // Maximum size of the sheet
      builder: (context, scrollController) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                border:
                    Border(top: BorderSide(color: Color(0xff42425F), width: 0.7)),
                color: Color(0xff45454E), // Background color of the sheet
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(
                                IconConstants.beldexAILogoSvg,
                                width: 20,
                                height: 20,
                              ),
                            ),
                            Text(
                              StringConstants.beldexAI,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                //fontWeight: FontWeight.w600,
                              ),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9.0,horizontal: 15.0),
                                margin: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Color(0xff2C2C3B),
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child:Row(
                                  
                                  children: [
                                    Text(StringConstants.hideSummarise),
                                    Padding(
                                      padding: const EdgeInsets.only(left:8.0),
                                      child: SvgPicture.asset(IconConstants.summariseIcon),
                                    )
                                  ],
                                )
                                
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Color(0xff9B9B9B),
                        height: 0.7,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: 
                          _isLoading
                          ? Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Lottie.asset(IconConstants.bubbleLoaderDark,
                             //fit: BoxFit.fitWidth
                            ),
                          )
                           
                          : Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              children: [
                                 if (displayedTitle.isNotEmpty)
                                  Text(
                                  displayedTitle,
                                   style: TextStyle(
                                   fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                    ),
                                            ),
                                               
                                               if (displayedParagraph.isNotEmpty) ...[
                                            SizedBox(height: 16),
                                            Text(
                                              displayedParagraph,
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                            
                            
                                          if (displayedBullets.isNotEmpty) ...[
                                            SizedBox(height: 16),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: displayedBullets.map((bullet) {
                                                return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("• ", style: TextStyle(fontSize: 16)),
                                Expanded(
                                  child: Text(
                                    bullet,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                            
                                
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                    ],
                  ),
            ),
          !_isLoading ? Positioned(
            bottom: 30,
            right: 20,
             child: Container(
              height: 50,
              width: 50,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xff00B134),
                borderRadius: BorderRadius.circular(8.0)
              ),
                child:SvgPicture.asset(IconConstants.copyIconDark,color: Colors.white,)
             ),
           ):Container(),
          
          ],
        );
      },
    );
  }
}

















class BeldexAiScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.95, // Initial size of the sheet
      minChildSize: 0.3, // Minimum size of the sheet
      maxChildSize: 1.0, // Maximum size of the sheet
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            border:
                Border(top: BorderSide(color: Color(0xff42425F), width: 0.7)),
            color: Color(0xff171720), // Background color of the sheet
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.width * 0.5),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Transform.translate(
                    offset: Offset(108,
                        -90), // Adjust this offset to position the first image
                    child: Image.asset(
                      IconConstants.browserAITransparentPng,
                      //'assets/images/box_element.svg', // Replace with your first image asset path
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width *
                          0.40, // Adjust width if necessary
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 100
                    // MediaQuery.of(context).size.height /1
                    ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Transform.translate(
                    offset: Offset(-65,
                        -26), // Adjust this offset to position the first image
                    child: Image.asset(IconConstants.browserAITransparentPng,
                        //'assets/images/box_element.svg', // Replace with your first image asset path
                        fit: BoxFit.contain,
                        width: 140 //MediaQuery.of(context).size.width *
                        // 0.40, // Adjust width if necessary
                        ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            IconConstants.beldexAILogoSvg,
                            width: 20,
                            height: 20,
                          ),
                        ),
                        Text(
                          StringConstants.beldexAI,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: SvgPicture.asset(
                            themeProvider.darkTheme
                                ? IconConstants.closeIconWhite
                                : IconConstants.closeIconWhite,
                            width: 15,
                            height: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Color(0xff42425F),
                    height: 0.7,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 100, left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SvgPicture.asset(themeProvider.darkTheme
                                    ? IconConstants.welcomeBeldexAIDark
                                    : IconConstants.welcomeBeldexAIWhite),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: Text(
                                    StringConstants.welcomeAIContent,
                                    style: TextStyle(
                                        color: Color(0xffEBEBEB), fontSize: 14),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          Container(
                            height: 180,
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.all(8.0),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(0xff282836),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(StringConstants.needHelpWithSite),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                      StringConstants.iCanHelpYouSummarising),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 14),
                                    decoration: BoxDecoration(
                                        color: Color(0xff171720),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Text(
                                      StringConstants.summariseThispage,
                                      style:
                                          TextStyle(color: Color(0xff01D001)),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFF171720),
                      border: Border.all(
                          color: Color(0xff42425F),
                          width:
                              0.6), // Background color of the TextField container
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                    height: 100,
                    child: Column(
                      children: [
                        // Spacing between icon and text field
                        Expanded(
                          child: TextField(
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 14), // Text color
                            cursorColor: Colors.green, // Cursor color
                            decoration: InputDecoration(
                                border: InputBorder
                                    .none, // No border for the TextField
                                hintText: StringConstants
                                    .enterPromptHere, // Placeholder text
                                hintStyle: TextStyle(
                                  color: Colors.white, // Placeholder text color
                                ),
                                suffix: SvgPicture.asset(themeProvider.darkTheme
                                    ? IconConstants.closeIconDark
                                    : IconConstants.closeIconWhite)),
                          ),
                        ),
                        SizedBox(
                            width:
                                8), // Spacing between text field and send icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SvgPicture.asset(IconConstants.micDark),
                            SvgPicture.asset(IconConstants.micWhite),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
          //),
        );
      },
    );
    //);
  }
}
