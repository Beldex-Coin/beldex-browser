import 'package:beldex_browser/src/browser/ai/chat_screen.dart';
import 'package:beldex_browser/src/browser/ai/constants/icon_constants.dart';
import 'package:beldex_browser/src/browser/ai/constants/string_constants.dart';
import 'package:beldex_browser/src/browser/ai/enums/roles.dart';
import 'package:beldex_browser/src/browser/ai/models/chat_model.dart';
import 'package:beldex_browser/src/browser/ai/repositories/openai_repository.dart';
import 'package:beldex_browser/src/browser/ai/ui/views/base_views.dart';
import 'package:beldex_browser/src/browser/ai/ui/widgets/message_pair.dart';
import 'package:beldex_browser/src/browser/ai/ui/widgets/pop_up_menu.dart';
import 'package:beldex_browser/src/browser/ai/view_models/chat_view_model.dart';
import 'package:beldex_browser/src/browser/custom_popup_menu_item.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/tab_popup_menu_actions.dart';
import 'package:beldex_browser/src/browser/tab_viewer_popup_menu_actions.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/utils/show_message.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:beldex_browser/src/widget/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

GlobalKey chatMenukey = GlobalKey();
// ignore: must_be_immutable
class BeldexAIScreen extends StatelessWidget {
  final bool isWelcomeShown;
  final String searchWord ;
  BeldexAIScreen({super.key, required this.isWelcomeShown, this.searchWord=''});

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
   //getWordSearch(model);
  }

  Future<void> setWelcomeAIScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSubmitted', true);
  }


 setDelayForWordSearch(ChatViewModel model,WebViewModel webViewModel){
  Future.delayed(Duration(milliseconds: 250),(){
    getWordSearch(model,webViewModel);
  });
 }


 getWordSearch(ChatViewModel model,WebViewModel webViewModel){
  if(searchWord.isNotEmpty || searchWord != ''){
     //model.getTextFromAskAI(searchWord);
         model.getTextFromAskBeldexAI(searchWord,webViewModel);
    model.isSummariseAvailable = false;
     model.messageController.clear();
  }
 }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    var browserModel = Provider.of<BrowserModel>(context);
    final webViewModel = Provider.of<WebViewModel>(context);
    final urlSummaryProvider = Provider.of<UrlSummaryProvider>(context);
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
    return BaseView<ChatViewModel>(
      onModelReady: (model) {
        this.model = model;
        model.messages = [];
        //_checkWelcomeMessageStatus();
        model.canshowWelcome = isWelcomeShown;
        checkSummariseString(webViewModel, model);
        model.isTyping = false;
        //getWordSearch(model);
        setDelayForWordSearch(model,webViewModel);
        //print('BASE MODEL READY>>>>');
      },
      builder: (context, model, child) {
       // print('BASE MODEL BUILDER CALLING');
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
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                            border: Border(top: BorderSide(color:themeProvider.darkTheme ? Color(0xff42425F): Color(0xffDADADA),width: 0.5)),
                        color: themeProvider.darkTheme ? Color(0xff171720) : Color(0xffFFFFFF)
                        ),
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
                                      fontFamily: 'Poppins',
                                       // color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Spacer(),
                                  SizedBox(
                                    height: 48,
                                   // color: Colors.yellow,
                                    child:Icon(Icons.close,color: Colors.transparent,)
                                  ),
                                  Visibility(
                                    visible: model.messages.isNotEmpty,
                                    child: GestureDetector(
                                      onTap: (){
                                         model.messages = [];
                                          model.isTyping = false;
                                          checkSummariseString(webViewModel,model);
                                          model.messageController.clear();
                                      },
                                      child: SizedBox(
                                        //color: Colors.green,
                                       // height: 36,width: 30,
                                        // child: IconButton(
                                        //   onPressed: (){
                                        //   model.messages = [];
                                        //   model.isTyping = false;
                                        //   checkSummariseString(webViewModel,model);
                                        //   model.messageController.clear();
                                        // },
                                         child: SvgPicture.asset('assets/images/ai-icons/Erase _dark.svg',color: themeProvider.darkTheme ? Colors.white : Color(0xff333333))),
                                    ),
                                   // ),
                                  ),
                                  Visibility(
                                    visible: model.messages.isNotEmpty,
                                    child: PopupMenuButton<String>(
                                            color:  themeProvider.darkTheme ?const Color(0xff282836) :const Color(0xffF3F3F3),
                                                  icon: Icon(Icons.more_horiz,
                                                      color: themeProvider.darkTheme ? Colors.white : Colors.black),
                                            onSelected:(value) {
                                        // if(model.messages.isNotEmpty){
                                            // Find the index of the last user message
                                        final userMessageIndex = model.messages.lastIndexWhere((message) => message.role == Roles.user);
                                        final userMessage = (userMessageIndex != -1) ? model.messages[userMessageIndex] : ChatModel(text: '', role: Roles.user);
                                    
                                        // Find the index of the last model message after the user message
                                        final modelMessageIndex = model.messages.lastIndexWhere((message) {
                                          return message.role == Roles.model && message.text.isNotEmpty;
                                        });
                                        final modelMessage = (modelMessageIndex != -1) ? model.messages[modelMessageIndex] : ChatModel(text: '', role: Roles.model);
                                    
                                        print('Last AI User Message: ${userMessage.text}');
                                        print('Last AI Model Message: ${modelMessage.text}');
                                    
                                         //}
                                    
                                    
                                                   switch(value){
                                                    case AIChatPopupMenuActions.COPY_CHAT:
                                                      Clipboard.setData(ClipboardData(text: modelMessage.text));
                                                      showMessage('Copied');
                                                    break;
                                                    case AIChatPopupMenuActions.SHARE_CHAT:
                                                     Share.share('${modelMessage.text}', subject:modelMessage.text);
                                                    break;
                                                    case AIChatPopupMenuActions.DELETE_CHAT:
                                                    
                                                      // Find the index of the last model message
                                        final lastModelMessageIndex = model.messages.lastIndexWhere((message) {
                                          return message.role == Roles.model && message.text.isNotEmpty;
                                        });
                                    
                                        // Find the index of the last user message
                                        final lastUserMessageIndex = model.messages.lastIndexWhere((message) => message.role == Roles.user);
                                    
                                        // Remove the last model message first (to avoid index shifting)
                                        if (lastModelMessageIndex != -1) {
                                          model.messages.removeAt(lastModelMessageIndex);
                                        }
                                    
                                        // Remove the last user message
                                        if (lastUserMessageIndex != -1) {
                                          model.messages.removeAt(lastUserMessageIndex);
                                        }
                                               showMessage('Message Deleted');
                                                    break;
                                                   }
                                            },
                                            offset: Offset(0, 47),
                                             surfaceTintColor:
                                                      themeProvider.darkTheme ? Color(0xff282836) : Color(0xffF3F3F3),
                                                  elevation: 2,
                                            shape:const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.only(
                                                      bottomLeft: Radius.circular(15.0),
                                                      bottomRight: Radius.circular(15.0),
                                                      topLeft: Radius.circular(15.0),
                                                      topRight: Radius.circular(15.0),
                                                    ),
                                                  ),
                                            itemBuilder: (popupMenuContext) {
                                              var items = <PopupMenuEntry<String>>[];
                                    
                                              items.addAll(AIChatPopupMenuActions.choices.map((choice) {
                                                switch (choice) {
                                                  case AIChatPopupMenuActions.COPY_CHAT:
                                                    return CustomPopupMenuItem<String>(
                                                      enabled: model.messages.isNotEmpty && !model.isTyping,
                                                      value: choice,
                                                      height: 35,
                                                      child: Row(
                                                          children: [
                                                           SvgPicture.asset(IconConstants.copyIconWhite ,color:model.messages.isEmpty ||  model.isTyping ? themeProvider.darkTheme ? Color(0xff6D6D81): Color(0xffC5C5C5) : themeProvider.darkTheme
                                                  ?const Color(0xffFFFFFF)
                                                  :const Color(0xff282836)),
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal:8.0),
                                                              child: Text(choice, style: Theme.of(context)
                                                .textTheme
                                                .bodySmall?.copyWith( 
                                                  color: model.messages.isEmpty || model.isTyping ? themeProvider.darkTheme ? Color(0xff6D6D81): Color(0xffC5C5C5) : themeProvider.darkTheme ? Colors.white:Colors.black
                                                )),
                                                            ),
                                                          ]),
                                                    );
                                                  case AIChatPopupMenuActions.SHARE_CHAT:
                                                    return CustomPopupMenuItem<String>(
                                                      enabled:model.messages.isNotEmpty && !model.isTyping,
                                                      value: choice,
                                                      height: 35,
                                                      child: Row(
                                                          children: [
                                                             SvgPicture.asset('assets/images/ai-icons/Share.svg' ,color:model.messages.isEmpty || model.isTyping ? themeProvider.darkTheme ? Color(0xff6D6D81): Color(0xffC5C5C5) : themeProvider.darkTheme
                                                ?const Color(0xffFFFFFF)
                                                :const Color(0xff282836)),
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal:5.0),
                                                              child: Text(choice, style: Theme.of(context)
                                                .textTheme
                                                .bodySmall?.copyWith( 
                                                  color: model.messages.isEmpty || model.isTyping ? themeProvider.darkTheme ? Color(0xff6D6D81):  Color(0xffC5C5C5) : themeProvider.darkTheme ? Colors.white:Colors.black
                                                )),
                                                            ),
                                                          ]),
                                                    );
                                                  case AIChatPopupMenuActions.DELETE_CHAT:
                                                    return CustomPopupMenuItem<String>(
                                                      enabled: model.messages.isNotEmpty && !model.isTyping,
                                                      value: choice,
                                                      height: 35,
                                                      child: Row(
                                                          children: [
                                                            SvgPicture.asset('assets/images/ai-icons/Trash 1.svg', 
                                                                     color: model.messages.isEmpty || model.isTyping ? themeProvider.darkTheme ? Color(0xff6D6D81): Color(0xffC5C5C5)
                                         : themeProvider.darkTheme
                                                ?const Color(0xffFFFFFF)
                                                :const Color(0xff282836)),
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal:5.0),
                                                              child: Text(choice,style: Theme.of(context)
                                                .textTheme
                                                .bodySmall?.copyWith( 
                                                  color: model.messages.isEmpty || model.isTyping ? themeProvider.darkTheme ? Color(0xff6D6D81):Color(0xffC5C5C5) : themeProvider.darkTheme ? Colors.white:Colors.black
                                                )),
                                                            ),
                                                          ]),
                                                    );
                                                  default:
                                                    return CustomPopupMenuItem<String>(
                                                      value: choice,
                                                      child: Text(choice),
                                                    );
                                                }
                                              }).toList());
                                    
                                              return items;
                                            },
                                          ),
                                  ),
                                     
                                  Visibility(
                                    visible: model.messages.isNotEmpty,
                                    child: Container(
                                      color:themeProvider.darkTheme ? Color(0xff42425F) : Color(0xffDADADA),
                                      margin: EdgeInsets.only(right: 10),
                                      child: VerticalDivider(
                                        color: Colors.black,
                                      width: 2,
                                                                      indent: 12,
                                      endIndent: 12,
                                                                       ),
                                    ),
                                  ),
                                  // VerticalDivider(
                                  //   thickness: 1,
                                  //   width: ,
                                  //   color: Colors.black,
                                  // ),
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
                            Divider(
                              color:themeProvider.darkTheme ? Color(0xff42425F): Color(0xffDADADA),
                              height: 0.7,
                            ),
                           model.canshowWelcome 
                                ? SizedBox()
                                :Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Row(children: [
                                SvgPicture.asset(
                                    IconConstants.beldexAILogoWhiteColor,color: themeProvider.darkTheme ? Colors.white : Color(0xff333333),),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      IconConstants.chat,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'Poppins',
                                          color: themeProvider.darkTheme ? Colors.white : Color(0xff333333),
                                          fontWeight: FontWeight.w700),
                                    ))
                              ]),
                            ),
          
                            Expanded(
  child: Container(
    child: ListView.builder(
      controller: model.scrollController,
      physics: ClampingScrollPhysics(), // Adjust physics
      padding: const EdgeInsets.only(top: 10), // Add padding
      itemCount: (model.messages.length / 2).ceil(),
      itemBuilder: (context, index) {
        final userMessage = model.messages[index * 2];
        final modelMessage = (index * 2 + 1 < model.messages.length)
            ? model.messages[index * 2 + 1]
            : ChatModel(text: '', role: Roles.model);

        int lastResponseIndex = model.messages.lastIndexWhere((message) {
          return message.role == Roles.model && message.text.isNotEmpty;
        });
        final currentResponseIndex = index * 2 + 1;

        print('User Message: ${userMessage.text}');
        print('Model Message: ${modelMessage.text}');

        return MessagePair(
          key: ValueKey(index),
          userMessage: userMessage,
          modelMessage: modelMessage,
          model: model,
          currentResponseIndex: currentResponseIndex,
          lastResponseIndex: lastResponseIndex,
        );
      },
    ),
  ),
),

          
                            // model.canshowWelcome
                            //     ? 
                                Builder(
                                  builder: (context) {
                                    final isKeyboardVisible =
                            MediaQuery.of(context).viewInsets.bottom > 0;
                                    return AnimatedOpacity(
                                      opacity: isKeyboardVisible ? 0.0 : 1.0,
                              duration: Duration(milliseconds: 300),
                                      child: Visibility(
                                        visible:  model.canshowWelcome && !isKeyboardVisible,
                                        child: InitialSummariseWelcomeWidget(
                                            themeProvider: themeProvider, model: model, browserModel: browserModel, urlSummaryProvider: urlSummaryProvider, webViewModel: webViewModel,
                                          ),
                                      ),
                                    );
                                  }
                                ),
                                //: SizedBox(),



                            Builder(
                              builder:(context){
                                // Check if the keyboard is visible
                        final isKeyboardVisible =
                            MediaQuery.of(context).viewInsets.bottom > 0;
                             return AnimatedOpacity(
                              opacity: isKeyboardVisible ? 0.0 : 1.0,
                              duration: Duration(milliseconds: 300),
                              child: Visibility(
                                visible: (model.canshowWelcome &&
                                    browserModel.webViewTabs.isNotEmpty &&
                                    model.isSummariseAvailable) && !isKeyboardVisible,
                                child: Container(
                                    height:
                                        MediaQuery.of(context).size.height *
                                            0.23, // 180,
                                    width: MediaQuery.of(context).size.width,
                                    margin: EdgeInsets.all(8.0),
                                    padding: EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color:themeProvider.darkTheme ? Color(0xff282836) : Color(0xffF3F3F3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            StringConstants.needHelpWithSite,style: TextStyle(fontWeight: FontWeight.w600),),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(StringConstants
                                              .iCanHelpYouSummarising,style: TextStyle(fontWeight: FontWeight.w300)
                                              ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: GestureDetector(
                                            onTap: () async {
                                              setWelcomeAIScreen();
                                              //setState(() {
                                              model.canshowWelcome = false;
                                              // });
                                              // model.isSummariseAvailable =
                                              //     false;
                                              // model.summariseText =
                                              //     webViewModel.url
                                              //             .toString() ??
                                              //         '';
                                              // model.getTextAndSummariseInfo(
                                              //     webViewModel);
                                              model.messageController.clear();


                                         urlSummaryProvider.updateSummariser(true);
                                          urlSummaryProvider.updateCanStop(true);
                                          model.isSummariseAvailable = false;
                                          model.summariseText =
                                              webViewModel.url.toString() ??
                                                  '';
                                          Future.delayed(Duration(milliseconds: 100),(){});
                                          model.getTextAndSummariseInfo(
                                              webViewModel);
                                          urlSummaryProvider.updateCanStop(false);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 12,
                                                  horizontal: 14),
                                              decoration: BoxDecoration(
                                                  color:themeProvider.darkTheme ? Color(0xff171720): Color(0xffFFFFFF),
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
                                )
                              );
                              }
                              
                               ),




                            // Spacer(),
                            // model.canshowWelcome &&
                            //         browserModel.webViewTabs.isNotEmpty &&
                            //         model.isSummariseAvailable
                            //     ? Container(
                            //         height:
                            //             MediaQuery.of(context).size.height *
                            //                 0.23, // 180,
                            //         width: MediaQuery.of(context).size.width,
                            //         margin: EdgeInsets.all(8.0),
                            //         padding: EdgeInsets.all(14),
                            //         decoration: BoxDecoration(
                            //           color: Color(0xff282836),
                            //           borderRadius: BorderRadius.circular(10),
                            //         ),
                            //         child: Column(
                            //           crossAxisAlignment:
                            //               CrossAxisAlignment.start,
                            //           children: [
                            //             Text(
                            //                 StringConstants.needHelpWithSite),
                            //             Padding(
                            //               padding: const EdgeInsets.symmetric(
                            //                   vertical: 8.0),
                            //               child: Text(StringConstants
                            //                   .iCanHelpYouSummarising),
                            //             ),
                            //             Align(
                            //               alignment: Alignment.bottomRight,
                            //               child: GestureDetector(
                            //                 onTap: () async {
                            //                   setWelcomeAIScreen();
                            //                   //setState(() {
                            //                   model.canshowWelcome = false;
                            //                   // });
                            //                   model.isSummariseAvailable =
                            //                       false;
                            //                   model.summariseText =
                            //                       webViewModel.url
                            //                               .toString() ??
                            //                           '';
                            //                   model.getTextAndSummariseInfo(
                            //                       webViewModel);
                            //                   model.messageController.clear();


                            //               // Additionaly added
                            //               urlSummaryProvider.updateSummariser(true);
                            //               urlSummaryProvider.updateCanStop(true);
                            //               //model.isSummariseAvailable = false;
                            //               model.summariseText =
                            //                   webViewModel.url.toString() ??
                            //                       '';
                            //               // model.getTextAndSummariseInfo(
                            //               //     webViewModel);
                            //               urlSummaryProvider.updateCanStop(false);
                            //                 },
                            //                 child: Container(
                            //                   padding: EdgeInsets.symmetric(
                            //                       vertical: 12,
                            //                       horizontal: 14),
                            //                   decoration: BoxDecoration(
                            //                       color: Color(0xff171720),
                            //                       borderRadius:
                            //                           BorderRadius.circular(
                            //                               12)),
                            //                   child: Text(
                            //                     StringConstants
                            //                         .summariseThispage,
                            //                     style: TextStyle(
                            //                         color: Color(0xff01D001)),
                            //                   ),
                            //                 ),
                            //               ),
                            //             )
                            //           ],
                            //         ),
                            //       )
                            //     : SizedBox(),
                            browserModel.webViewTabs.isNotEmpty &&
                                    model.isSummariseAvailable && vpnStatusProvider.canShowHomeScreen == false &&
                                    model.canshowWelcome == false
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          urlSummaryProvider.updateSummariser(true);
                                          urlSummaryProvider.updateCanStop(true);
                                          model.isSummariseAvailable = false;
                                          model.summariseText =
                                              webViewModel.url.toString() ??
                                                  '';
                                          model.getTextAndSummariseInfo(
                                              webViewModel);
                                          urlSummaryProvider.updateCanStop(false);
                                         // urlSummaryProvider.updateSummariser(true);
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
                                              Text('Summarise this page',style: TextStyle(color: Colors.white,fontFamily: 'Poppins',),),
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
          

Container(
  margin: const EdgeInsets.only(bottom: 10, left: 8, right: 8, top: 10),
  child: Row(
    children: [
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: themeProvider.darkTheme ? Color(0xff3D4354) : Color(0xffDADADA),
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.2, // 40% of screen height
                          ),
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              reverse: true,
                              physics: const BouncingScrollPhysics(),
                              child: TextField(
                                enabled: !model.isTyping,
                                controller: model.messageController,
                                maxLength: 1000,
                                 inputFormatters: [
                                    LengthLimitingTextInputFormatter(1000), // Restrict input
                                  ],
                                maxLines: null, // Auto-expand with limit
                                keyboardType: TextInputType.multiline,
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                ),
                                 onSubmitted: (value) {
                urlSummaryProvider.updateSummariser(false);
                setWelcomeAIScreen();
                model.canshowWelcome = false;
                model.isSummariseAvailable = false;
                if (model.messageController.text.toString().isNotEmpty) {
                  model.getTextAndImageInfo();
                  model.messageController.clear();
                }
              },
                                cursorColor: Colors.green,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  counterText: '',
                                  contentPadding: const EdgeInsets.only(
                                 right: 29.0),
                                  hintText: StringConstants.enterPromptHere,
                                  hintStyle: const TextStyle(
                                    color: Color(0xff6D6D81),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical:3.0),
                        child: SizedBox(
                          //color: Colors.green,
                          height: 35,width: 35,
                          child: IconButton(
                            //visualDensity: VisualDensity.comfortable,
                           // padding: EdgeInsets.symmetric(vertical: 5),
                            onPressed: () {
                               final lastModelMessageIndex = model.messages.lastIndexWhere(
                              (message) => message.role == Roles.model && message.text.isNotEmpty,
                            );
                        
                            final lastUserMessageIndex = model.messages.lastIndexWhere(
                          (message) => message.role == Roles.user,
                        );
                            //messageBodyTimer?.cancel();
                        
                            if (model.isTyping) {
                              // Stop typing state
                              model.isTyping = false;
                              //typingProvider.updateAITypingState(false);
                             model.stopResponse();
                               // Check if the last user message exists but its respective model message is empty
                          if (lastUserMessageIndex != -1 &&
                              lastUserMessageIndex + 1 < model.messages.length && // Ensure modelMessage exists
                              model.messages[lastUserMessageIndex + 1].role == Roles.model &&
                              model.messages[lastUserMessageIndex + 1].text.isEmpty) {
                               // model.messages[lastUserMessageIndex + 1].isInterrupted = true;
                            print("Last user message is available but model message is empty ${model.messages[lastUserMessageIndex + 1]}");
                            OpenAIRepository().cancelRequest();
                            model.messages[lastUserMessageIndex + 1].text = 'The response has been interrupted';
                            model.messages[lastUserMessageIndex + 1].canShowRegenerate = true;
                          }else if (lastModelMessageIndex != -1) {
                            
                                model.messages[lastModelMessageIndex].canShowRegenerate = true;
                                 print('OnData coming inside data ${model.messages[lastModelMessageIndex].canShowRegenerate}');
                              }
                        
                            } else {
                              // Check if there’s any input in the message controller
                              if (model.messageController.text.isNotEmpty) {
                                //MessageBodyState().updateTypingText();
                                urlSummaryProvider.updateSummariser(false);
                                //typingProvider.updateAITypingState(true);
                                model.isTyping = true;
                               
                                // Reset messages state and UI components
                                 if (lastModelMessageIndex != -1) {
                                   model.messages[lastModelMessageIndex].canShowRegenerate = false;
                                //   print('last model message iiis is ${model.messages[lastModelMessageIndex].typingText} ');
                                //   if(model.messages[lastModelMessageIndex].typingText.isNotEmpty || model.messages[lastModelMessageIndex].typingText != ''){
                                   
                                //     model.messages[lastModelMessageIndex].text = model.messages[lastModelMessageIndex].typingText;
                                //   model.messages[lastModelMessageIndex].typingText = '';
                                 }
                                  
                                //   model.messages[lastModelMessageIndex].isTypingComplete = true;
                                //   print('last model message is ${model.messages[lastModelMessageIndex].text} ');
                                // }
                                FocusScope.of(context).unfocus();
                                setWelcomeAIScreen();
                                model.canshowWelcome = false;
                                model.isSummariseAvailable = false;
                        
                                // Handle new message if text is present
                                model.getTextForUser(); //getTextAndImageInfo();
                                model.messageController.clear();
                              }
                            }
                        
                            },
                            icon: SvgPicture.asset(
                              model.isTyping
                                  ? 
                                  themeProvider.darkTheme
                                      ? 'assets/images/ai-icons/Stop.svg'
                                      : 'assets/images/ai-icons/Stop Circled 1.svg'
                                  : 
                                  themeProvider.darkTheme
                                      ? IconConstants.sendDark
                                      : IconConstants.sendWhite,
                              // width: 20, // Ensure visibility
                              // height: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                right: -7,
                child: Visibility(
                  visible: model.messageController.text.isNotEmpty,
                  child: GestureDetector(
                                      onTap: () => model.messageController.clear(),
                                      child: Padding(
                                        padding: const EdgeInsets.all(17.0),
                                        child: SvgPicture.asset(
                                          themeProvider.darkTheme
                                              ? IconConstants.closeIconDark
                                              : IconConstants.closeIconWhite,
                                          width: 15, // Ensure visibility
                                          height: 15,
                                        ),
                                      ),
                                    ),
                ),)
            ],
          ),
        ),
      ),
    ],
  ),
),



// Container(
//         margin: const EdgeInsets.only(bottom: 10, left: 8, right: 8, top: 10),
//         child: Row(
//           children: [
//             Expanded(
//               child: Container(
//                 padding:  EdgeInsets.symmetric( horizontal:10),
//                 decoration: BoxDecoration(
//                  // color: ColorConstants.grey3D4354,
//                  border: Border.all(color:themeProvider.darkTheme ? Color(0xff3D4354): Color(0xffDADADA)),
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                       Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       mainAxisSize: MainAxisSize.max,
//                       children: [
//                         // InputFieldButton(
//                         //   icon: Icons.emoji_emotions,
//                         //   onpressed: () {
//                         //     FocusScope.of(context).unfocus();
//                         //     widget.model?.setShowEmoji = true;
//                         //   },
//                         // ),
//                        // model.imageFile == null
//                            // ? 
//                             Flexible(
//                                 child: TextField(
//               enabled: !model.isTyping, //(typingProvider.isTyping),
//               //controller: _textController,
//               onSubmitted: (value) {
//                 urlSummaryProvider.updateSummariser(false);
//                 setWelcomeAIScreen();
//                 model.canshowWelcome = false;
//                 model.isSummariseAvailable = false;
//                 if (model.messageController.text.toString().isNotEmpty) {
//                   model.getTextAndImageInfo();
//                   model.messageController.clear();
//                 }
//               },
//               controller: model.messageController,
//               maxLines: null,
//               style: TextStyle(
//                   //color: Colors.white,
//                   fontWeight: FontWeight.normal,
//                   fontSize: 14), // Text color
//               cursorColor: Colors.green, // Cursor color
//               decoration: InputDecoration(
//                   border: InputBorder.none, // No border for the TextField
//                   hintText: StringConstants.enterPromptHere, // Placeholder text
//                   hintStyle: TextStyle(
//                     color: Color(0xff6D6D81), //Colors.white, // Placeholder text color,
//                     fontFamily: 'Poppins'
//                   ),
//                   suffix: GestureDetector(
//                     onTap: () => model.messageController.clear(),
//                     child: SvgPicture.asset(themeProvider.darkTheme
//                         ? IconConstants.closeIconDark
//                         : IconConstants.closeIconWhite),
//                   )),
//             ),  
//                               //   TextFormFieldWidget(
//                               //   model: widget.model,
//                               // )
//                               ),
//                       ],
//                     ),
//                                             IconButton(
//   onPressed: () {
//     final lastModelMessageIndex = model.messages.lastIndexWhere(
//       (message) => message.role == Roles.model && message.text.isNotEmpty,
//     );

//     final lastUserMessageIndex = model.messages.lastIndexWhere(
//   (message) => message.role == Roles.user,
// );
//     //messageBodyTimer?.cancel();

//     if (model.isTyping) {
//       // Stop typing state
//       model.isTyping = false;
//       //typingProvider.updateAITypingState(false);
//      model.stopResponse();
//        // Check if the last user message exists but its respective model message is empty
//   if (lastUserMessageIndex != -1 &&
//       lastUserMessageIndex + 1 < model.messages.length && // Ensure modelMessage exists
//       model.messages[lastUserMessageIndex + 1].role == Roles.model &&
//       model.messages[lastUserMessageIndex + 1].text.isEmpty) {
//        // model.messages[lastUserMessageIndex + 1].isInterrupted = true;
//     print("Last user message is available but model message is empty ${model.messages[lastUserMessageIndex + 1]}");
//     OpenAIRepository().cancelRequest();
//     model.messages[lastUserMessageIndex + 1].text = 'The response has been interrupted';
//     model.messages[lastUserMessageIndex + 1].canShowRegenerate = true;
//   }else if (lastModelMessageIndex != -1) {
    
//         model.messages[lastModelMessageIndex].canShowRegenerate = true;
//          print('OnData coming inside data ${model.messages[lastModelMessageIndex].canShowRegenerate}');
//       }

//     } else {
//       // Check if there’s any input in the message controller
//       if (model.messageController.text.isNotEmpty) {
//         //MessageBodyState().updateTypingText();
//         urlSummaryProvider.updateSummariser(false);
//         //typingProvider.updateAITypingState(true);
//         model.isTyping = true;
       
//         // Reset messages state and UI components
//          if (lastModelMessageIndex != -1) {
//            model.messages[lastModelMessageIndex].canShowRegenerate = false;
//         //   print('last model message iiis is ${model.messages[lastModelMessageIndex].typingText} ');
//         //   if(model.messages[lastModelMessageIndex].typingText.isNotEmpty || model.messages[lastModelMessageIndex].typingText != ''){
           
//         //     model.messages[lastModelMessageIndex].text = model.messages[lastModelMessageIndex].typingText;
//         //   model.messages[lastModelMessageIndex].typingText = '';
//          }
          
//         //   model.messages[lastModelMessageIndex].isTypingComplete = true;
//         //   print('last model message is ${model.messages[lastModelMessageIndex].text} ');
//         // }
//         FocusScope.of(context).unfocus();
//         setWelcomeAIScreen();
//         model.canshowWelcome = false;
//         model.isSummariseAvailable = false;

//         // Handle new message if text is present
//         model.getTextForUser(); //getTextAndImageInfo();
//         model.messageController.clear();
//       }
//     }
//   },
//   icon: SvgPicture.asset(
//     model.isTyping
//         ? themeProvider.darkTheme ? 'assets/images/ai-icons/Stop.svg' : 'assets/images/ai-icons/Stop Circled 1.svg'
//         : themeProvider.darkTheme ? IconConstants.sendDark : IconConstants.sendWhite,
      
//   ),
// )
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
























                            // Bottom TextField Section
                            // Container(
                            //   //  padding: const EdgeInsets.all(16.0),
                            //   // margin: EdgeInsets.all(13),
                            //   margin: const EdgeInsets.all(5),
                            //   padding: const EdgeInsets.symmetric(
                            //       horizontal: 16, vertical: 8),
          
                            //   decoration: BoxDecoration(
                            //     color: themeProvider.darkTheme ? Color(0xFF171720) : Color(0xffffffff),
                            //     border: Border.all(
                            //         color:themeProvider.darkTheme ? Color(0xff42425F): Color(0xffDADADA),
                            //         width:
                            //             0.6), // Background color of the TextField container
                            //     borderRadius: BorderRadius.circular(10), //
                            //     // (
                            //     //  // top: BorderSide(color: Color(0xff42425F), width: 0.7),
                            //     // ),
                            //   ),
                            //   height:
                            //       MediaQuery.of(context).size.height * 0.18,
                            //   child: Column(
                            //     children: [
                            //       // Spacing between icon and text field
                            //       Expanded(
                            //         child: TextField(
                            //           //controller: _textController,
                            //           onSubmitted: (value) {
                            //              urlSummaryProvider.updateSummariser(false);
                            //             setWelcomeAIScreen();
                            //                 model.canshowWelcome = false;
                            //                 model.isSummariseAvailable =
                            //                     false;
                            //                 if (model.messageController.text
                            //                     .toString()
                            //                     .isNotEmpty) {
                            //                   model.getTextAndImageInfo();
                            //                   model.messageController.clear();
                            //                 }
                            //           },
                            //           controller: model.messageController,
                            //           maxLines: null,
                            //           style: TextStyle(
                            //               //color: Colors.white,
                            //               fontWeight: FontWeight.normal,
                            //               fontSize: 14), // Text color
                            //           cursorColor:
                            //               Colors.green, // Cursor color
                            //           decoration: InputDecoration(
                            //               border: InputBorder
                            //                   .none, // No border for the TextField
                            //               hintText: StringConstants
                            //                   .enterPromptHere, // Placeholder text
                            //               hintStyle: TextStyle(
                            //                 color: Color(0xff6D6D81), // Placeholder text color
                            //                 fontFamily: 'Poppins',
                            //               ),
                            //               suffix: GestureDetector(
                            //                 onTap: () => model
                            //                     .messageController
                            //                     .clear(),
                            //                 child: SvgPicture.asset(
                            //                     themeProvider.darkTheme
                            //                         ? IconConstants
                            //                             .closeIconDark
                            //                         : IconConstants
                            //                             .closeIconWhite),
                            //               )),
                            //         ),
                            //       ),
                            //       SizedBox(
                            //           width:
                            //               8), // Spacing between text field and send icon
                            //       Row(
                            //         mainAxisAlignment:
                            //             MainAxisAlignment.spaceBetween,
                            //         children: [
                            //           SvgPicture.asset(IconConstants.micDark,color: themeProvider.darkTheme ? Colors.white:Colors.black,),
                            //           IconButton(
                            //               onPressed: 
                            //               // urlSummaryProvider.canStopAndRegenerate
                            //               // ? (){
                                            
                            //               // }  
                            //               // : 
                            //               () {
                            //                 urlSummaryProvider.updateSummariser(false);
                            //                 FocusScope.of(context).unfocus();
                            //                 setWelcomeAIScreen();
                            //                 model.canshowWelcome = false;
                            //                 model.isSummariseAvailable =
                            //                     false;
                            //                 if (model.messageController.text
                            //                     .toString()
                            //                     .isNotEmpty) {
                            //                   model.getTextAndImageInfo();
                            //                   model.messageController.clear();
                            //                 }
                            //               }, //()=>sendUserMessage(vpnStatusProvider),
                            //               icon: SvgPicture.asset(
                            //                 //   urlSummaryProvider.canStopAndRegenerate || urlSummaryProvider.isLoading ?
                            //                 //   'assets/images/ai-icons/Stop.svg'
                            //                 //  : 
                            //                  IconConstants.sendDark,
                            //                  color: themeProvider.darkTheme ? Colors.white:Colors.black,
                            //                  )),
                            //         ],
                            //       ),
                            //     ],
                            //   ),
                            // ),
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








  Widget tabList(DarkThemeProvider themeProvider,ThemeData theme,BuildContext context) {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
     final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
    return InkWell(
      key: chatMenukey,
      onLongPress: () {
        final RenderBox? box =
            chatMenukey.currentContext!.findRenderObject() as RenderBox?;
        if (box == null) {
          return;
        }

        Offset position = box.localToGlobal(Offset.zero);
       
         browserModel.webViewTabs.isEmpty ?
          showMenu(
                context: context,
                 color: themeProvider.darkTheme ?const Color(0xff282836) : const Color(0xffF3F3F3),
                // surfaceTintColor: Colors.green,
               shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15.0),
              bottomRight: Radius.circular(15.0),
              topLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0),)
              ),
              surfaceTintColor: themeProvider.darkTheme ?const Color(0xff282836) :const Color(0xffF3F3F3),
                position: RelativeRect.fromLTRB(position.dx,
                    position.dy + box.size.height+5, box.size.width, 0),
                items: EmptyTabPopupMenuActions.choices.map((tabPopupMenuAction) {
                  IconData? iconData;
                  switch (tabPopupMenuAction) {
                    // case TabPopupMenuActions.CLOSE_TABS:
                    //   iconData = Icons.close;
                    //   break;
                    case EmptyTabPopupMenuActions.NEW_TAB:
                      iconData = Icons.add;
                      break;
                    // case TabPopupMenuActions.NEW_INCOGNITO_TAB:
                    //   iconData = MaterialCommunityIcons.incognito;
                    //   break;
                  }

                  return PopupMenuItem<String>(
                    value: tabPopupMenuAction,
                    height: 35,
                    //padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      
                      children: [
                    //  tabPopupMenuAction == 'New private tab' ?
                    //  Padding(
                    //    padding: const EdgeInsets.only(left:8.0),
                    //    child: SvgPicture.asset('assets/images/private_tab.svg',
                    //               color: themeProvider.darkTheme
                    //                   ? const Color(0xffFFFFFF)
                    //                   : const Color(0xff282836)),
                    //  )
                    //   : 
                      Icon(iconData,
                          color: themeProvider.darkTheme
                              ? Colors.white
                              : Colors.black //black,
                          ),
                      Container(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: TextWidget(text: tabPopupMenuAction,style:theme
                                          .textTheme
                                          .bodySmall ,),
                      )
                    ]),
                  );
                }).toList())
            .then((value) {
          switch (value) {
            // case TabPopupMenuActions.CLOSE_TABS:
            //   browserModel.closeAllTabs();
            //   clearCookie();
            //   break;
            case EmptyTabPopupMenuActions.NEW_TAB:
            vpnStatusProvider.updateCanShowHomeScreen(false);
              //addNewTab();
              break;
            // case TabPopupMenuActions.NEW_INCOGNITO_TAB:
            //   addNewIncognitoTab();
            //   break;
          }
        })

        :
        showMenu(
                context: context,
                 color: themeProvider.darkTheme ?const Color(0xff282836) : const Color(0xffF3F3F3),
                // surfaceTintColor: Colors.green,
               shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15.0),
              bottomRight: Radius.circular(15.0),
              topLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0),)
              ),
              surfaceTintColor: themeProvider.darkTheme ?const Color(0xff282836) :const Color(0xffF3F3F3),
                position: RelativeRect.fromLTRB(position.dx,
                    position.dy + box.size.height+5, box.size.width, 0),
                items: TabPopupMenuActions.choices.map((tabPopupMenuAction) {
                  IconData? iconData;
                  switch (tabPopupMenuAction) {
                    case TabPopupMenuActions.CLOSE_TABS:
                      iconData = Icons.close;
                      break;
                    case TabPopupMenuActions.NEW_TAB:
                      iconData = Icons.add;
                      break;
                    // case TabPopupMenuActions.NEW_INCOGNITO_TAB:
                    //   iconData = MaterialCommunityIcons.incognito;
                    //   break;
                  }

                  return PopupMenuItem<String>(
                    value: tabPopupMenuAction,
                    height: 35,
                    //padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      
                      children: [
                    //  tabPopupMenuAction == 'New private tab' ?
                    //  Padding(
                    //    padding: const EdgeInsets.only(left:8.0),
                    //    child: SvgPicture.asset('assets/images/private_tab.svg',
                    //               color: themeProvider.darkTheme
                    //                   ? const Color(0xffFFFFFF)
                    //                   : const Color(0xff282836)),
                    //  )
                    //   : 
                      Icon(iconData,
                          color: themeProvider.darkTheme
                              ? Colors.white
                              : Colors.black //black,
                          ),
                      Container(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: TextWidget(text: tabPopupMenuAction,style:theme
                                          .textTheme
                                          .bodySmall ,),
                      )
                    ]),
                  );
                }).toList())
            .then((value) {
          switch (value) {
            case TabPopupMenuActions.CLOSE_TABS:
              browserModel.closeAllTabs();
              clearCookie();
              break;
            case TabPopupMenuActions.NEW_TAB:
            vpnStatusProvider.updateCanShowHomeScreen(false);
              //addNewTab();
              break;
            // case TabPopupMenuActions.NEW_INCOGNITO_TAB:
            //   addNewIncognitoTab();
            //   break;
          }
        });
      },
      onTap: () async {
        //Navigator.push(context,MaterialPageRoute(builder: ((context) => TabsList() )));
  //       if (browserModel.webViewTabs.isNotEmpty) {
  //         var webViewModel = browserModel.getCurrentTab()?.webViewModel;
  //         var webViewController = webViewModel?.webViewController;
  //          hideFooter(webViewController);
  //         if (View.of(context).viewInsets.bottom > 0.0) {
  //           SystemChannels.textInput.invokeMethod('TextInput.hide');
  //           if (FocusManager.instance.primaryFocus != null) {
  //             FocusManager.instance.primaryFocus!.unfocus();
  //           }
  //           if (webViewController != null) {
  //             await webViewController.evaluateJavascript(
  //                 source: "document.activeElement.blur();");
  //           }
  //           await Future.delayed(const Duration(milliseconds: 300));
  //         }


  //        if(vpnStatusProvider.canShowHomeScreen){
  //    if (webViewModel != null && imageScreenshot != null){
  //     webViewModel.screenshot = imageScreenshot;
  //    }
  //       vpnStatusProvider.updateCanShowHomeScreen(false);
  //  }else if (webViewModel != null && webViewController != null) {
  //           webViewModel.screenshot = await webViewController
  //               .takeScreenshot(
  //                   screenshotConfiguration: ScreenshotConfiguration(
  //                       compressFormat: CompressFormat.JPEG, quality: 20))
  //               .timeout(
  //                 const Duration(milliseconds: 1500),
  //                 onTimeout: () => null,
  //               );
  //         }

  //         browserModel.showTabScroller = true;
  //       }
      },
      child: Container(
        width: 18,
        height: 18,
        margin: const EdgeInsets.only(
            left: 10.0, top: 10.0, right: 5.0, bottom: 10.0),
        decoration: BoxDecoration(
            color:
                themeProvider.darkTheme ? const Color(0xff282836) : const Color(0xffF3F3F3),
            border: Border.all(
                width: 1.0,
                color: themeProvider.darkTheme ? Colors.white : Colors.black),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(3.0)),
        constraints: const BoxConstraints(minWidth: 18.0),
        child: Center(
          child: browserModel.webViewTabs.length >= 100
              ? Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: SvgPicture.asset(
                    'assets/images/Infinity_white_theme.svg',
                    color:
                        themeProvider.darkTheme ? Colors.white : Colors.black,
                  ),
                )
              : TextWidget(
                 text: browserModel.webViewTabs.length.toString(),
                  style: TextStyle(
                      color:
                          themeProvider.darkTheme ? Colors.white : Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 12.0),
                ),
        ),
      ),
    );
  }

}
