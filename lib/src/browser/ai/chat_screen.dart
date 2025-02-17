import 'dart:async';

import 'package:beldex_browser/src/browser/ai/chat_message.dart';
import 'package:beldex_browser/src/browser/ai/constants/icon_constants.dart';
import 'package:beldex_browser/src/browser/ai/constants/string_constants.dart';
import 'package:beldex_browser/src/browser/ai/network_model.dart';
import 'package:beldex_browser/src/browser/ai/ui/views/base_views.dart';
import 'package:beldex_browser/src/browser/ai/view_models/chat_view_model.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/utils/show_message.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_preference.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:flutter_markdown/flutter_markdown.dart' as md;

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

  // void _sendUserMessage(WebViewModel webViewModel) async {
  //   final message = _controller.text.trim();
  //   if (message.isEmpty) return;

  //   ChatMessage uMessage = ChatMessage(text: _controller.text, sender: "user");
  //   setState(() {
  //     _messages.insert(0, uMessage);
  //   });
  //   _controller.clear();

  //   setState(() {
  //     _response = 'Loading...';
  //   });

  //   final response = await _chatGPTService.fetchAndSummarize(
  //       '', webViewModel); //sendMessage(message);

  //   setState(() {
  //     _response = response;

  //     _messages.insert(
  //         0, ChatMessage(text: _response.toString(), sender: 'bot'));

  //     print('Response ------ > $_response');
  //   });

  //   _controller.clear();
  // }

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
          onPressed: null, //() => _sendUserMessage(webViewModel),
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
  ChatViewModel? model;
  String displayedTitle = "";
  String displayedParagraph = "";
  List<String> displayedBullets = [];

  Timer? typingTimer;



@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    callSummaryApI(context);
  });
}







  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();

  //   callSummaryApI(context);
  // }
void callSummaryApI(BuildContext context) async {
  final urlSummaryProvider = Provider.of<UrlSummaryProvider>(context, listen: false);
  final webViewModel = Provider.of<WebViewModel>(context, listen: false);

  try {
    await urlSummaryProvider.fetchSummary(webViewModel);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final response = urlSummaryProvider.summaryText;
      print('BELDEX AI API CALL RESPONSE --- $response');

      if (response.isNotEmpty) {
        _parseResponse(response);
      }
    });
  } catch (e) {
    print(e);
  }
}

  // void callSummaryApI(BuildContext context) async {
     
  //      final urlSummaryProvider = Provider.of<UrlSummaryProvider>(context);
  //     final webViewModel = Provider.of<WebViewModel>(context);
  //     urlSummaryProvider.fetchSummary(webViewModel);
  //   try {
  //     final response = urlSummaryProvider.summaryText;
  //     print('BELDEX AI API CALL RESPONSE --- $response');
  //        // await _chatGPTService.fetchAndSummarize('', webViewModel);
  //     if (response.isNotEmpty) {
        
  //       _parseResponse(response);
  //     }
  //   } catch (e) {
  //     print(e);
  //   } finally {
  //     // setState(() {
  //     //   _isLoading = false;
  //     // });
  //   }
  // }



void _parseResponse(String response) {
  if (response.isEmpty) return;

  // Split response into lines
  List<String> lines = response.split("\n").map((line) => line.trim()).toList();

  // Extract title (first non-empty line)
  title = lines.firstWhere((line) => line.isNotEmpty, orElse: () => "");

  // Extract bullet points (skip the first line, which is the title)
  bullets = lines
      .skip(1) // Skip the title line
      .where((line) => line.isNotEmpty) // Ensure the line is not empty
      .toList();

  print('BELDEX AI API Title --- $title');
  print('BELDEX AI API Bullets --- $bullets');

  setState(() {});
}



  // void _parseResponse(String response) {
  //   // Split response into lines
  //   List<String> lines = response.split("\n");

  //   // Extract title (assume the first non-empty line is the title)
  //   title =
  //       lines.firstWhere((line) => line.trim().isNotEmpty, orElse: () => "");

  //   // Extract paragraph (assume the first full sentence block is the paragraph)
  //   paragraph = lines
  //       .skip(1)
  //       .firstWhere((line) => line.trim().isNotEmpty, orElse: () => "");

  //   // Extract bullet points (assume lines starting with "-", "•", or similar are bullets)
  //   bullets = lines
  //       .where((line) => line.trim().startsWith(RegExp(r"[-•]")))
  //       .map((line) => line.trim().replaceFirst(RegExp(r"[-•]\s*"), ""))
  //       .toList();

  //   setState(() {});

  //   //_startTypingAnimation();
  // }

  
  @override
  void dispose() {
   // typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final webViewModel = Provider.of<WebViewModel>(context);
    final urlSummaryProvider = Provider.of<UrlSummaryProvider>(context);
    // return BaseView<ChatViewModel>(
    //   onModelReady: (model){
    //     this.model = model;
    //    // model.getSummariseForFloatingActionButton(webViewModel);
    //     //print('MODEL DATA FROM SUMMARISE ${model.sumResponse}');
    //   },
    //    builder: (context, model, child) {
           return SafeArea(
        child: DraggableScrollableSheet(
          initialChildSize: 0.95, // Initial size of the sheet
          minChildSize: 0.3, // Minimum size of the sheet
          maxChildSize: 0.95, // Maximum size of the sheet
          builder: (context, scrollController) {
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(color: Color(0xff42425F), width: 0.7)),
                    color: themeProvider.darkTheme ? Color(0xff45454E) : Color(0xffF3F3F3), // Background color of the sheet
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
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
                               // color: Colors.white,
                               fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 9.0, horizontal: 15.0),
                                  margin: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: themeProvider.darkTheme ? Color(0xff2C2C3B): Color(0xffFDFDFD),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    children: [
                                      Text(StringConstants.hideSummarise,style: TextStyle(fontFamily: 'Poppins',fontSize: 13),),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: SvgPicture.asset(
                                            IconConstants.summariseIcon, color: themeProvider.darkTheme ? Colors.white:Colors.black,),
                                      )
                                    ],
                                  )),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: themeProvider.darkTheme ? Color(0xff9B9B9B): Color(0xff9B9B9B),
                        height: 0.7,
                      ),
                      Expanded(
                        child: RawScrollbar(
                          controller: scrollController,
                          thumbVisibility:
                              true, //!_isLoading, //?? false, //: true,
      
                          thumbColor:themeProvider.darkTheme ? Color(0xff45454E) : Color(0xffC5C5C5),
                          trackColor:themeProvider.darkTheme ? Color(0xff2C2C3B) : Color(0xffFBFBFB),
                          trackVisibility: true,
                          crossAxisMargin: 0.9,
                          //thickness: 3.0,
                          mainAxisMargin: 0.8,
                          // minThumbLength: 20,
                          padding: EdgeInsets.all(8.0),
                          radius: Radius.circular(5),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: urlSummaryProvider.isLoading  //_isLoading
                                ? Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: 
                                    LoadingAnimationWidget.waveDots(
                color:themeProvider.darkTheme ? Color(0xff9595B5) : Color(0xffACACAC),
                size: 30,
              ),
                                  )
                                : title.isNotEmpty && paragraph.isEmpty && bullets.isEmpty ?
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: md.Markdown(
                                              data:
                                              title,
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              physics: NeverScrollableScrollPhysics(),
                                              styleSheet:
                                                  md.MarkdownStyleSheet.fromTheme(
                                                Theme.of(context).copyWith(
                                                  textTheme: TextTheme(
                                                      bodyMedium: TextStyle(
                                                    fontSize: 15,
                                                    fontFamily: 'Poppins',
                                                fontWeight: FontWeight.normal
                                                  )),
                                                ),
                                              ),
                                            ),
                                    )
                               : Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      children: [
                                        if (title.isNotEmpty)
                                        md.Markdown(
                                            data:title.startsWith('-')
                                                ? title.substring(1).trim()
                                                : '',
                                            // title,
                                            shrinkWrap: true,
                                            padding: EdgeInsets.zero,
                                            physics: NeverScrollableScrollPhysics(),
                                            styleSheet:
                                                md.MarkdownStyleSheet.fromTheme(
                                              Theme.of(context).copyWith(
                                                textTheme: TextTheme(
                                                    bodyMedium: TextStyle(
                                                  fontSize: 24,
                                                  fontFamily: 'Poppins',
                                              fontWeight: FontWeight.bold
                                                )),
                                              ),
                                            ),
                                          ),
                                          // Text(
                                          //   title.startsWith('-')
                                          //       ? title.substring(1).trim()
                                          //       : '',
                                          //   style: TextStyle(
                                          //     fontSize: 24,
                                          //     fontWeight: FontWeight.bold,
                                          //   ),
                                          // ),
                                        // if (paragraph.isNotEmpty) ...[
                                        //   SizedBox(height: 16),
                                        //   md.Markdown(
                                        //     data: paragraph,
                                        //     shrinkWrap: true,
                                        //     padding: EdgeInsets.zero,
                                        //     styleSheet:
                                        //         md.MarkdownStyleSheet.fromTheme(
                                        //       Theme.of(context).copyWith(
                                        //         textTheme: TextTheme(
                                        //             bodyMedium: TextStyle(
                                        //           //color: ColorConstants.white,
                                        //           fontSize: 16,
                                        //           //fontWeight: FontWeight.w400,
                                        //         )),
                                        //       ),
                                        //     ),
                                        //   ),
                                        //   // Text(
                                        //   //   paragraph.startsWith('-')
                                        //   //       ? paragraph
                                        //   //           .substring(1)
                                        //   //           .trim()
                                        //   //       : '',
                                        //   //   style: TextStyle(fontSize: 16),
                                        //   // ),
                                        // ],
                                        if (bullets.isNotEmpty) ...[
                                          SizedBox(height: 16),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: bullets.map((bullet) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Text("• ",
                                                    //     style: TextStyle(
                                                    //         fontSize: 16)),
                                                    Expanded(
                                                      child: md.Markdown(
                                                        data: bullet,
                                                        shrinkWrap: true,
                                                        padding: EdgeInsets.zero,
                                                        physics: NeverScrollableScrollPhysics(),
                                                        styleSheet:
                                                            md.MarkdownStyleSheet
                                                                .fromTheme(
                                                          Theme.of(context)
                                                              .copyWith(
                                                            textTheme: TextTheme(
                                                                bodyMedium:
                                                                    TextStyle(
                                                              //color: ColorConstants.white,
                                                              fontSize: 16,
                                                              //fontWeight: FontWeight.w400,
                                                            )),
                                                          ),
                                                        ),
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
                      ),
                    ],
                  ),
                ),
                !urlSummaryProvider.isLoading //_isLoading
                    ? Positioned(
                        bottom: 30,
                        right: 20,
                        child: GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text:urlSummaryProvider.summaryText));
                            showMessage('Copied');

                          },
                          child: Container(
                              height: 50,
                              width: 50,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: const Color(0xff00B134),
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: SvgPicture.asset(
                                IconConstants.copyIconDark,
                                color: Colors.white,
                              )),
                        ),
                      )
                    : Container(),
              ],
            );
          },
        ),
      );

    //    }
      
       
    // );
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
                                ? IconConstants.closeIconDark
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
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        SvgPicture.asset(IconConstants.beldexAILogoWhiteColor),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            IconConstants.chat,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color(0xff42425F),
                                    ),
                                    borderRadius: BorderRadius.circular(15)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(13.0),
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(themeProvider
                                                  .darkTheme
                                              ? 'assets/images/ai-icons/MaleUser1.svg'
                                              : 'assets/images/ai-icons/Male User 1.svg'),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Text('You',
                                                style: TextStyle(
                                                    color: Color(0xff9595B5))),
                                          ),
                                          Spacer(),
                                          SvgPicture.asset(
                                              IconConstants.copyIconDark),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(13.0),
                                      child: Text(
                                          'How much is BDX coin in 2030? How much is BDX coin in 2030?How much is BDX coin in 2030? How much is BDX coin in 2030?'),
                                    ),
                                    Divider(
                                      color: Color(0xff42425F),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(13.0),
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            IconConstants.beldexAILogoSvg,
                                            height: 20,
                                            width: 20,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Text(
                                              StringConstants.beldexAI,
                                              style: TextStyle(
                                                  color: Color(0xff9595B5)),
                                            ),
                                          ),
                                          Spacer(),
                                          SvgPicture.asset(
                                              IconConstants.copyIconDark),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                        //InitialSummariseWelcomeWidget(themeProvider: themeProvider),
                        ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            onSubmitted: (value) {},
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
                            SvgPicture.asset(IconConstants.sendDark),
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

class DraggableAISheet extends StatefulWidget {
  const DraggableAISheet({super.key});

  @override
  State<DraggableAISheet> createState() => _DraggableAISheetState();
}

class _DraggableAISheetState extends State<DraggableAISheet> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ChatGPTService _chatGPTService = ChatGPTService(apiKey: "");

  void sendUserMessage(VpnStatusProvider vpnStasProvider) async {
    // final vpnStatusProvider = Provider.of<VpnStatusProvider>(context,listen: false);
    // String _response = 'loading';
    // vpnStatusProvider.updateAIResponse(_response);
    // final message = _textController.text.trim();
    //   if(message.isEmpty) return;

    //   ChatMessage uMessage = ChatMessage(text: _textController.text, sender: "user", ai: 'Beldex AI', aiResponse: vpnStatusProvider.aiResponse,);

    //   setState(() {
    //     _messages.insert(0, uMessage);
    //   });
    //   _textController.clear();
    //    final response = await _chatGPTService.sendMessage(message);

    //   setState(() {
    //     _response = response;
    //     vpnStatusProvider.updateAIResponse(_response);
    //     print('The AI Response ----- ${vpnStatusProvider.aiResponse}');
    //   //  _messages.insert(0, ChatMessage(text: _response.toString(), sender: "Beldex AI"));
    //   });
    //   _textController.clear();

    final vpnStatusProvider =
        Provider.of<VpnStatusProvider>(context, listen: false);

    final message = _textController.text.trim();
    if (message.isEmpty) return;

    ChatMessage uMessage = ChatMessage(
      text: message,
      sender: "user",
      ai: 'Beldex AI',
      aiResponse: vpnStatusProvider.aiResponse,
    );

    setState(() {
      _messages.insert(0, uMessage);
    });

    _textController.clear();

    vpnStatusProvider.updateAIResponse('loading'); // Show the loading state

    final response = await _chatGPTService.sendMessage(message);

    vpnStatusProvider.updateAIResponse(response); // Update the response
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.95, // Initial size of the sheet
      minChildSize: 0.3, // Minimum size of the sheet
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom, // Make space for the keyboard
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                color: Color(0xff171720),
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
                        child: Image.asset(
                            IconConstants.browserAITransparentPng,
                            //'assets/images/box_element.svg', // Replace with your first image asset path
                            fit: BoxFit.contain,
                            width: 140 //MediaQuery.of(context).size.width *
                            // 0.40, // Adjust width if necessary
                            ),
                      ),
                    ),
                  ),
                  Column(
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
                                    ? IconConstants.closeIconDark
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
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                                IconConstants.beldexAILogoWhiteColor),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                IconConstants.chat,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w700),
                              ),
                            )
                          ],
                        ),
                      ),
                      // Expanded(
                      //   child: SingleChildScrollView(
                      //     controller: scrollController, // Allow scrolling of content
                      //     child: Column(
                      //       children: [
                      //        Padding(
                      //      padding: const EdgeInsets.all(8.0),
                      //      child: Container(
                      //       decoration: BoxDecoration(
                      //         border: Border.all(color: Color(0xff42425F),),
                      //         borderRadius: BorderRadius.circular(15)
                      //       ),
                      //       child: ListView.builder(
                      //         reverse: true,
                      //         shrinkWrap: true,
                      //         itemCount: _messages.length,
                      //        // controller: scrollController,
                      //         itemBuilder: (context, index) {
                      //           return _messages[index];
                      //         }),
                      //      ),
                      //                                )
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xff42425F)),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListView.builder(
                            controller:
                                ScrollController(), // Dedicated ScrollController
                            reverse: true,
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              return _messages[index];
                            },
                          ),
                        ),
                      ),

                      // Bottom TextField Section
                      Container(
                        //  padding: const EdgeInsets.all(16.0),
                        // margin: EdgeInsets.all(13),
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),

                        decoration: BoxDecoration(
                          color: Color(0xFF171720),
                          border: Border.all(
                              color: Color(0xff42425F),
                              width:
                                  0.6), // Background color of the TextField container
                          borderRadius: BorderRadius.circular(10), //
                          // (
                          //  // top: BorderSide(color: Color(0xff42425F), width: 0.7),
                          // ),
                        ),
                        height: 100,
                        child: Column(
                          children: [
                            // Spacing between icon and text field
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                onSubmitted: (value) {},
                                maxLines: null,
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
                                      color: Colors
                                          .white, // Placeholder text color
                                    ),
                                    suffix: SvgPicture.asset(
                                        themeProvider.darkTheme
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
                                IconButton(
                                    onPressed: () =>
                                        sendUserMessage(vpnStatusProvider),
                                    icon: SvgPicture.asset(
                                        IconConstants.sendDark)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class InitialSummariseWelcomeWidget extends StatelessWidget {
  final DarkThemeProvider themeProvider;
  final ChatViewModel model;
  final BrowserModel browserModel;
  final UrlSummaryProvider urlSummaryProvider;
  final WebViewModel webViewModel;
  const InitialSummariseWelcomeWidget({super.key, required this.themeProvider, required this.model, required this.browserModel, required this.urlSummaryProvider, required this.webViewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.green,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset(themeProvider.darkTheme
                    ? IconConstants.welcomeBeldexAIDark
                    : IconConstants.welcomeBeldexAIWhite),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    StringConstants.welcomeAIContent,
                    //textAlign: TextAlign.center,
                    style: TextStyle(color:themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff222222),fontFamily: 'Poppins' , fontSize: 14),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: model.canshowWelcome &&
                                    browserModel.webViewTabs.isNotEmpty &&
                                    model.isSummariseAvailable ? 20 : 80,
          ),
          // Container(
          //   height: 180,
          //   width: MediaQuery.of(context).size.width,
          //   margin: EdgeInsets.all(8.0),
          //   padding: EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     color: Color(0xff282836),
          //     borderRadius: BorderRadius.circular(10),
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text(StringConstants.needHelpWithSite),
          //       Padding(
          //         padding:
          //             const EdgeInsets.symmetric(vertical: 8.0),
          //         child: Text(
          //             StringConstants.iCanHelpYouSummarising),
          //       ),
          //       Align(
          //         alignment: Alignment.bottomRight,
          //         child: Container(
          //           padding: EdgeInsets.symmetric(
          //               vertical: 12, horizontal: 14),
          //           decoration: BoxDecoration(
          //               color: Color(0xff171720),
          //               borderRadius:
          //                   BorderRadius.circular(12)),
          //           child: Text(
          //             StringConstants.summariseThispage,
          //             style:
          //                 TextStyle(color: Color(0xff01D001)),
          //           ),
          //         ),
          //       )
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }
}
