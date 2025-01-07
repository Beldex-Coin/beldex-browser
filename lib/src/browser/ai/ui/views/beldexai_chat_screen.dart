import 'package:beldex_browser/src/browser/ai/chat_screen.dart';
import 'package:beldex_browser/src/browser/ai/constants/icon_constants.dart';
import 'package:beldex_browser/src/browser/ai/constants/string_constants.dart';
import 'package:beldex_browser/src/browser/ai/enums/roles.dart';
import 'package:beldex_browser/src/browser/ai/models/chat_model.dart';
import 'package:beldex_browser/src/browser/ai/ui/views/base_views.dart';
import 'package:beldex_browser/src/browser/ai/ui/widgets/message_pair.dart';
import 'package:beldex_browser/src/browser/ai/view_models/chat_view_model.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class BeldexAIScreen extends StatelessWidget {
  final bool isWelcomeShown;

  BeldexAIScreen({super.key, required this.isWelcomeShown});

  ChatViewModel? model;

  bool? canShowWelcome;

  checkSummariseString(WebViewModel webViewModel, ChatViewModel model) {
    if (webViewModel != null && webViewModel.url != null) {
      if (webViewModel.url!.scheme == 'http' ||
          webViewModel.url!.scheme == 'https') {
        // Regex to match common search engine result page patterns
        final searchEnginePattern = RegExp(
          r'(\?|&)q=|search=|(\?|&)query=',
          caseSensitive: false,
        );
        model.isSummariseAvailable =
            !searchEnginePattern.hasMatch(webViewModel.url.toString());
        //setState(() {
        // vpnStatusProvider.updateFAB(!searchEnginePattern.hasMatch(url));

        // showFAB = !searchEnginePattern.hasMatch(url);
        // });
      }
    } else {
      model.isSummariseAvailable = false;
    }
  }

  Future<void> setWelcomeAIScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSubmitted', true);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    var browserModel = Provider.of<BrowserModel>(context);
    final webViewModel = Provider.of<WebViewModel>(context);
    return BaseView<ChatViewModel>(
      onModelReady: (model) {
        this.model = model;
        model.messages = [];
        //_checkWelcomeMessageStatus();
        model.canshowWelcome = isWelcomeShown;
        checkSummariseString(webViewModel, model);
      },
      builder: (context, model, child) {
        return SafeArea(
          child: DraggableScrollableSheet(
              initialChildSize: 0.95,
              minChildSize: 0.3,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                model.scrollController = scrollController; // draggable sheet scrollcontroller assigned to model controller
                return LayoutBuilder(builder: (context, constraint) {
                  return Container(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    decoration: const BoxDecoration(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                        color: Color(0xff171720)),
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.width * 0.5),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Transform.translate(
                              offset: Offset(108, -90),
                              child: Image.asset(
                                IconConstants.browserAITransparentPng,
                                fit: BoxFit.contain,
                                width:
                                    MediaQuery.of(context).size.width * 0.40,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 100),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Transform.translate(
                              offset: Offset(-65, -26),
                              child: Image.asset(
                                IconConstants.browserAITransparentPng,
                                fit: BoxFit.contain,
                                width: 140,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
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
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(right: 8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        model.messages = [];
                                        Navigator.pop(context);
                                      },
                                      child: SvgPicture.asset(
                                        themeProvider.darkTheme
                                            ? IconConstants.closeIconDark
                                            : IconConstants.closeIconWhite,
                                        width: 15,
                                        height: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              color: Color(0xff42425F),
                              height: 0.7,
                            ),
                           model.canshowWelcome 
                                ? SizedBox()
                                :Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Row(children: [
                                SvgPicture.asset(
                                    IconConstants.beldexAILogoWhiteColor),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      IconConstants.chat,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700),
                                    ))
                              ]),
                            ),
          
                            Expanded(
                                child: Container(
                                    //decoration: BoxDecoration(
          
                                    // border: Border.all(
                                    //   color: Color(0xff42425F),
                                    // ),
                                    // borderRadius:
                                    //     BorderRadius.circular(15)
                                    //  ),
                                    child: ListView.builder(
                              controller:
                                 model.scrollController, // scrollController,
                             // reverse: true,
                              itemCount: (model.messages.length / 2)
                                  .ceil(), // Each pair is one item
                              itemBuilder: (context, index) {
                                final userMessage = model.messages[index * 2];
                                final modelMessage = (index * 2 + 1 <
                                        model.messages.length)
                                    ? model.messages[index * 2 + 1]
                                    : ChatModel(text: '', role: Roles.model);
          
          
          
                                // Calculate the last response index
                       int lastResponseIndex = model.messages.lastIndexWhere((message) {
                      return message.role == Roles.model && message.text.isNotEmpty;
                           });
          
          
                          final currentResponseIndex = index * 2 + 1;
          
                          print('The Current index value ---- $currentResponseIndex and the last index value --- $lastResponseIndex');
          
          
          
                                return MessagePair(
                                  userMessage: userMessage,
                                  modelMessage: modelMessage,
                                  model: model, 
                                  currentResponseIndex: currentResponseIndex,
                                  lastResponseIndex: lastResponseIndex,
                                  // isLoading: modelMessage.text.isEmpty && modelMessage.image == null, // Initially loading
                                );
                              },
                            ))),
          
                            model.canshowWelcome
                                ? InitialSummariseWelcomeWidget(
                                    themeProvider: themeProvider,
                                  )
                                : SizedBox(),
                            // Spacer(),
                            model.canshowWelcome &&
                                    browserModel.webViewTabs.isNotEmpty &&
                                    model.isSummariseAvailable
                                ? Container(
                                    height:
                                        MediaQuery.of(context).size.height *
                                            0.23, // 180,
                                    width: MediaQuery.of(context).size.width,
                                    margin: EdgeInsets.all(8.0),
                                    padding: EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Color(0xff282836),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            StringConstants.needHelpWithSite),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(StringConstants
                                              .iCanHelpYouSummarising),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: GestureDetector(
                                            onTap: () async {
                                              setWelcomeAIScreen();
                                              //setState(() {
                                              model.canshowWelcome = false;
                                              // });
                                              model.isSummariseAvailable =
                                                  false;
                                              model.summariseText =
                                                  webViewModel.url
                                                          .toString() ??
                                                      '';
                                              model.getTextAndSummariseInfo(
                                                  webViewModel);
                                              model.messageController.clear();
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 12,
                                                  horizontal: 14),
                                              decoration: BoxDecoration(
                                                  color: Color(0xff171720),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              child: Text(
                                                StringConstants
                                                    .summariseThispage,
                                                style: TextStyle(
                                                    color: Color(0xff01D001)),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                            browserModel.webViewTabs.isNotEmpty &&
                                    model.isSummariseAvailable &&
                                    model.canshowWelcome == false
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          model.isSummariseAvailable = false;
                                          model.summariseText =
                                              webViewModel.url.toString() ??
                                                  '';
                                          model.getTextAndSummariseInfo(
                                              webViewModel);
                                        },
                                        child: Container(
                                          //height: 40,
                                          margin: EdgeInsets.only(left: 10),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15.0, horizontal: 15),
                                          decoration: BoxDecoration(
                                              color: Color(0xff00B134),
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: Row(
                                            children: [
                                              Text('Summarise this page'),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                        left: 8.0),
                                                child: SvgPicture.asset(
                                                    IconConstants
                                                        .summariseIcon),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox(),
          
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
                              height:
                                  MediaQuery.of(context).size.height * 0.18,
                              child: Column(
                                children: [
                                  // Spacing between icon and text field
                                  Expanded(
                                    child: TextField(
                                      //controller: _textController,
                                      onSubmitted: (value) {
                                        setWelcomeAIScreen();
                                            model.canshowWelcome = false;
                                            model.isSummariseAvailable =
                                                false;
                                            if (model.messageController.text
                                                .toString()
                                                .isNotEmpty) {
                                              model.getTextAndImageInfo();
                                              model.messageController.clear();
                                            }
                                      },
                                      controller: model.messageController,
                                      maxLines: null,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14), // Text color
                                      cursorColor:
                                          Colors.green, // Cursor color
                                      decoration: InputDecoration(
                                          border: InputBorder
                                              .none, // No border for the TextField
                                          hintText: StringConstants
                                              .enterPromptHere, // Placeholder text
                                          hintStyle: TextStyle(
                                            color: Colors
                                                .white, // Placeholder text color
                                          ),
                                          suffix: GestureDetector(
                                            onTap: () => model
                                                .messageController
                                                .clear(),
                                            child: SvgPicture.asset(
                                                themeProvider.darkTheme
                                                    ? IconConstants
                                                        .closeIconDark
                                                    : IconConstants
                                                        .closeIconWhite),
                                          )),
                                    ),
                                  ),
                                  SizedBox(
                                      width:
                                          8), // Spacing between text field and send icon
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SvgPicture.asset(IconConstants.micDark),
                                      IconButton(
                                          onPressed: () {
                                            FocusScope.of(context).unfocus();
                                            setWelcomeAIScreen();
                                            model.canshowWelcome = false;
                                            model.isSummariseAvailable =
                                                false;
                                            if (model.messageController.text
                                                .toString()
                                                .isNotEmpty) {
                                              model.getTextAndImageInfo();
                                              model.messageController.clear();
                                            }
                                          }, //()=>sendUserMessage(vpnStatusProvider),
                                          icon: SvgPicture.asset(
                                              IconConstants.sendDark)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                });
              }),
        );
      },
    );
  }
}
