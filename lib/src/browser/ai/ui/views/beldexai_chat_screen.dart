import 'dart:async';

import 'package:beldex_browser/src/browser/ai/ai_model_provider.dart';
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
import 'package:connectivity_plus/connectivity_plus.dart';
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
  OpenAIRepository openAIRepository = OpenAIRepository();
  checkSummariseString(WebViewModel webViewModel, ChatViewModel model) {
    if(webViewModel != null && (webViewModel.url.toString() == "about:blank" || webViewModel.url.toString().startsWith("chrome-error") || webViewModel.url.toString().startsWith("edge-error"))){
    model.isSummariseAvailable = false;
    return;
  }
    if (webViewModel != null && webViewModel.url != null) {
      if (webViewModel.url!.scheme == 'http' ||
          webViewModel.url!.scheme == 'https') {
        // Regex to match common search engine result page patterns
        final searchEnginePattern = RegExp(
          r'(\?|&)q=|search=|(\?|&)query=',
          caseSensitive: false,
        );
        model.isSummariseAvailable = shouldShowFAB(webViewModel.url.toString());
            //!searchEnginePattern.hasMatch(webViewModel.url.toString());
        //setState(() {
        // vpnStatusProvider.updateFAB(!searchEnginePattern.hasMatch(url));

        // showFAB = !searchEnginePattern.hasMatch(url);
        // });
      }
    } else {
      model.isSummariseAvailable = false;
    }
    print("THE WEBVIEW IS NOT EMPTY AND SUMMARY AVAILABLE --->${model.isSummariseAvailable}");
  }


bool shouldShowFAB(String url) {
  Uri uri = Uri.parse(url);
  String host = uri.host.toLowerCase();
  String path = uri.path.split('#')[0]; // Modified to strip fragments after '#'

  // List of search engines and social media platforms to exclude
  Map<String, List<String>> blockedSites = {
    'google': ['google.'], // Matches all Google domains (google.com, google.co.in, etc.)
    'bing': ['bing.com'],
    'yahoo': ['yahoo.','consent.yahoo.','guce.yahoo.'],
    'duckduckgo': ['duckduckgo.com'],
    'baidu': ['baidu.com'],
    'yandex': ['yandex.'], // juce
    'ask': ['ask.com'],
    'ecosia':['ecosia.org'],
    'youtube': ['youtube.com'],
    'reddit': ['reddit.com'],
    'wikipedia': ['wikipedia.org'],
    'twitter': ['twitter.com', 'x.com'],
  };

  // Check if the host matches any blocked site homepage
  bool isBlockedHomepage = blockedSites.entries.any((entry) =>
      entry.value.any((domain) => host.contains(domain)) &&
      (path == "/" || path.isEmpty));

  // Check for search, video, or feed pages in search engines and social media
  bool isBlockedSearchOrFeed = [
    'search',      // Google, Bing, Yahoo, DuckDuckGo, Ask
   // '/s',           // Baidu
    'yandsearch',  // Yandex
    'results',     // YouTube search results
    'watch',       // YouTube videos (https://www.youtube.com/watch?v=xyz)
    'explore',     // Twitter/X explore page
    'trending',    // YouTube trending page
  ].any((keyword) => path.contains(keyword) || uri.queryParameters.containsKey("q"));

  // Check for Twitter authentication pages
  bool isTwitterAuthPage = (host.contains("twitter.com") || host.contains("x.com")) &&
      (path.startsWith("/login") || path.startsWith("/i/flow/login") || path.startsWith("/signup"));

  // Wikipedia-specific logic: Only allow content pages (not search, login, or special pages)
  bool isWikipedia = host.contains("wikipedia.org");
  bool isWikipediaContentPage = isWikipedia &&
      path.startsWith("/wiki/") && // Must be an article path
      !path.startsWith("/wiki/Special:") && 
      !path.startsWith("/wiki/Talk:") &&
      !path.startsWith("/wiki/User:") &&
      !path.startsWith("/wiki/Wikipedia:") &&
      !path.startsWith("/wiki/Category:") &&
      !path.startsWith("/wiki/File:") &&
      !path.startsWith("/wiki/Help:") &&
      !path.contains("search") && // Exclude search pages
      !path.contains("index.php") && // Exclude index/search pages
      !path.contains("#References"); // Exclude reference sections (though now redundant due to split)
 // Only allow Wikipedia content pages
  if (isWikipedia) {
    print("The URL is coming inside wikipedia block");
   // print("The Wikipedia 1 - ${!path.startsWith("/wiki/Special:")} 2 - ${ !path.startsWith("/wiki/Talk:")} 3 - ${!path.startsWith("/wiki/User:") } 4 - ${!path.startsWith("/wiki/Wikipedia:")} 5 - ${!path.startsWith("/wiki/Category:")} 6 - ${!path.startsWith("/wiki/File:")} 7 - ${!path.startsWith("/wiki/Help:")} 8 - ${!path.contains("search")} 9 - ${!path.contains("index.php")} 10 - ${ !path.contains("#References")}");
    return isWikipediaContentPage;
  }

bool isYahooConsentPage = host.contains("consent.yahoo.") || host.contains("guce.yahoo.");
//print("The Wikipedia $isWikipedia or $isWikiOne 1 - ${!path.startsWith("/wiki/Special:")} 2 - ${ !path.startsWith("/wiki/Talk:")} 3 - ${!path.startsWith("/wiki/User:") } 4 - ${!path.startsWith("/wiki/Wikipedia:")} 5 - ${!path.startsWith("/wiki/Category:")} 6 - ${!path.startsWith("/wiki/File:")} 7 - ${!path.startsWith("/wiki/Help:")} 8 - ${!path.contains("search")} 9 - ${!path.contains("index.php")} 10 - ${ !path.contains("#References")} and the last one $isWikipediaContentPage");
  if (isBlockedHomepage || isBlockedSearchOrFeed || isTwitterAuthPage || isYahooConsentPage) {
    print("The URL is coming inside block $isBlockedHomepage ----  $isBlockedSearchOrFeed ---- $isTwitterAuthPage");
    return false; // Hide FAB for blocked homepages, search/feed pages, YouTube videos, and Twitter auth pages
  }

 

  return true; // Show FAB only for actual webpages and valid Twitter/X posts
}

















  Future<void> setWelcomeAIScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSubmitted', true);
  }


 setDelayForWordSearch(ChatViewModel model,WebViewModel webViewModel,AIModelProvider aiModelProvider){
  Future.delayed(Duration(milliseconds: 250),(){
    getWordSearch(model,webViewModel,aiModelProvider);
  });
 }


 getWordSearch(ChatViewModel model,WebViewModel webViewModel,AIModelProvider aiModelProvider){
  if(searchWord.isNotEmpty || searchWord != ''){

    // Strict URL detection regex (only detects URLs with "http://" or "https://")
    final urlRegex = RegExp(
      r'\b(https?|ftp):\/\/[^\s/$.?#].[^\s]*\b',
      caseSensitive: false,
    );

    final match = urlRegex.firstMatch(searchWord);
    bool containsUrl = match != null;

    String? extractedUrl = containsUrl ? match!.group(0) : null;
     print('The Real Data -----> $searchWord ---- $extractedUrl');
     //model.getTextFromAskAI(searchWord);
      if(containsUrl){
        print('The Real Data 22-----> $searchWord ---- $extractedUrl');
        model.getTextFromAskBeldexAI(extractedUrl!,webViewModel,aiModelProvider.selectedModel);
      } else{
        print('The Real Data 333-----> $searchWord ---- $extractedUrl');
        model.getTextForUser(userMessage: searchWord,modelType:aiModelProvider.selectedModel);
      } 
    model.isSummariseAvailable = false;
     model.messageController.clear();
  }
 }

late Connectivity _connectivity;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  
checkInternet(ChatViewModel model)async{
   _connectivity = Connectivity();
    _connectivitySubscription = _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((event) {
      if (!(event.contains(ConnectivityResult.wifi)) && !(event.contains(ConnectivityResult.mobile)) ) {
         final lastUserMessageIndex = model.messages.lastIndexWhere((message) => message.role == Roles.user,);
         if (lastUserMessageIndex != -1 &&
                                    lastUserMessageIndex + 1 < model.messages.length && // Ensure modelMessage exists
                                    model.messages[lastUserMessageIndex + 1].role == Roles.model &&
                                    model.messages[lastUserMessageIndex + 1].text.isEmpty) {
                                     // model.messages[lastUserMessageIndex + 1].isInterrupted = true;
                                  print("Last user message is available but model message is empty ${model.messages[lastUserMessageIndex + 1]}");
                                  OpenAIRepository().cancelRequest();
                                  model.stopResponse();
                                  model.messages[lastUserMessageIndex + 1].text = 'The response has been interrupted'; // If token cancelled before generating response
                                  model.messages[lastUserMessageIndex + 1].canShowRegenerate = true;
                                }
       // openAIRepository.cancelRequest();
        // model.stopResponse();
        model.isTyping = false;
      } 
    });
}


bool _isRestrictedUrl(String text) {
    // Check if text starts with "http://" or "https://" and ends with ".bdx"
    return RegExp(r'^(http:\/\/|https:\/\/).+\.bdx$').hasMatch(text);
  }




//  bool containsUrl(String input) {
//   final urlPattern = RegExp(
//     r'((http|https):\/\/)?[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}(\S*)',
//     caseSensitive: false,
//   );
//   return urlPattern.hasMatch(input);
// }

 final DraggableScrollableController _controller =
      DraggableScrollableController();
  double previousExtent = 0.95; // Track previous sheet position


  void _onSheetDrag() {
    print('Scrolling option is calling');
    double currentExtent = _controller.size;
    if (currentExtent < previousExtent) {
      FocusManager.instance.primaryFocus?.unfocus(); // Close keyboard
    }
    previousExtent = currentExtent;
  }

basicSetting(ChatViewModel model,WebViewModel webViewModel,AIModelProvider aiModelProvider)async{
  openAIRepository.cancelRequest();
   model.stopResponse();
   Future.delayed(Duration(milliseconds: 100),(){
      model.messages.clear();
      model.messageController.clear();
      openAIRepository.clearHistory();
       model.canshowWelcome = isWelcomeShown;
        checkSummariseString(webViewModel, model);
        model.isTyping = false;
        //getWordSearch(model);
       // _controller.addListener(_onSheetDrag);
        checkInternet(model);
        setDelayForWordSearch(model,webViewModel,aiModelProvider);
   });
   
}



String removeSpecialFormatting(String text) {
  String cleanText = text
      // Remove bold (**text**)
      .replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (match) => match.group(1) ?? '')
      // Remove italic (*text*)
      .replaceAllMapped(RegExp(r'\*(.*?)\*'), (match) => match.group(1) ?? '')
      // Remove only • bullet points (keeping - )
      .replaceAll(RegExp(r'^•\s+', multiLine: true), '')
      // Remove stray $1 that might have crept in
      .replaceAll(RegExp(r'\$1'), '')
      // Remove numbered list markers (e.g., "1. ", "2. ")
      .replaceAll(RegExp(r'^\d+\.\s+', multiLine: true), '')
      // Remove Markdown headers (#, ##, ###, etc.) at start of lines
      .replaceAll(RegExp(r'^#+ ', multiLine: true), '')
      // Remove extra newlines and trim whitespace
      .replaceAll(RegExp(r'\n{2,}'), '\n')
      .trim();
  
  return cleanText;
}









  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    var browserModel = Provider.of<BrowserModel>(context);
    final webViewModel = Provider.of<WebViewModel>(context);
    final urlSummaryProvider = Provider.of<UrlSummaryProvider>(context);
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
    final aiModelProvider = Provider.of<AIModelProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    return BaseView<ChatViewModel>(
      onModelReady: (model) {
        this.model = model;


        basicSetting(model,webViewModel,aiModelProvider);
        // model.messages = [];
        // model.messageController.clear();
        //_checkWelcomeMessageStatus();
      //   model.canshowWelcome = isWelcomeShown;
      //   checkSummariseString(webViewModel, model);
      //   model.isTyping = false;
      //   //getWordSearch(model);
      //  // _controller.addListener(_onSheetDrag);
      //   checkInternet(model);
      //   setDelayForWordSearch(model,webViewModel,aiModelProvider);
        //print('BASE MODEL READY>>>>');
      },
      builder: (context, model, child) {
       // print('BASE MODEL BUILDER CALLING');
        
        return SafeArea(
          child: GestureDetector(
           onTap: ()=>FocusManager.instance.primaryFocus?.unfocus(),
            child: DraggableScrollableSheet(
              //controller: _controller,
                initialChildSize: 0.95,
                minChildSize: 0.3,
                maxChildSize: 0.95,
                builder: (context, scrollController) {
                   if(model.scrollController == null){
                  model.scrollController = scrollController; // draggable sheet scrollcontroller assigned to model controller
                   }
                   return 
                  //GestureDetector(
                    // Detect vertical swipe to dismiss keyboard
                //onPanUpdate: (details) {
                  // If dragging down (positive dy), dismiss keyboard
                  // if (details.delta.dy > 0) {
                  //   FocusScope.of(context).unfocus();
                  // }},
                    //child: 
                    LayoutBuilder(builder: (context, constraint) {
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
                                        
                                        openAIRepository.cancelRequest();
                                        model.stopResponse();
                                       Future.delayed(Duration(milliseconds: 200),(){
                                      // model.isSummariseCancelled = true;
                                       model.messages.clear();  // Use clear() instead of reassigning
                                       model.isTyping = false;
                                       openAIRepository.clearHistory();
                                       model.messageController.clear();  
                                       checkSummariseString(webViewModel, model);
                                        });
                          
                                          
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
                                           
                                            // final userMessageIndex = model.messages.lastIndexWhere((message) => message.role == Roles.user);
                                            // final userMessage = (userMessageIndex != -1) ? model.messages[userMessageIndex] : ChatModel(text: '', role: Roles.user);
                                        
                                            // // Find the index of the last model message after the user message
                                            // final modelMessageIndex = model.messages.lastIndexWhere((message) {
                                            //   return message.role == Roles.model && message.text.isNotEmpty;
                                            // });
                                            // final modelMessage = (modelMessageIndex != -1) ? model.messages[modelMessageIndex] : ChatModel(text: '', role: Roles.model);
                                        
                                            // print('Last AI User Message: ${userMessage.text}');
                                            // print('Last AI Model Message: ${modelMessage.text}');
                                        
                                             //}
                                              final chatHistory = model.messages.map((message) {
                                                            final prefix = message.role == Roles.user ? "You: " : "Beldex AI: ";
                                                             return "$prefix\n${message.text}";
                                                             }).join("\n");
                                        
                                        
                                                       switch(value){
                                                        case AIChatPopupMenuActions.COPY_CHAT:
                                                           
            
                                                    Clipboard.setData(ClipboardData(text:removeSpecialFormatting(chatHistory)));
                                                         // Clipboard.setData(ClipboardData(text: modelMessage.text));
                                                          showMessage('Copied');
                                                        break;
                                                        case AIChatPopupMenuActions.SHARE_CHAT:
                                                         Share.share(removeSpecialFormatting(chatHistory), subject:'');
                                                        break;
                                                        case AIChatPopupMenuActions.DELETE_CHAT:
                                                          model.messages.clear();
                                            //               // Find the index of the last model message
                                            // final lastModelMessageIndex = model.messages.lastIndexWhere((message) {
                                            //   return message.role == Roles.model && message.text.isNotEmpty;
                                            // });
                                        
                                            // // Find the index of the last user message
                                            // final lastUserMessageIndex = model.messages.lastIndexWhere((message) => message.role == Roles.user);
                                        
                                            // // Remove the last model message first (to avoid index shifting)
                                            // if (lastModelMessageIndex != -1) {
                                            //   model.messages.removeAt(lastModelMessageIndex);
                                            // }
                                        
                                            // // Remove the last user message
                                            // if (lastUserMessageIndex != -1) {
                                            //   model.messages.removeAt(lastUserMessageIndex);
                                            // }
                                                   showMessage('Chat deleted successfully');
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
                                        
            
                                                      final lastModelMessageIndex = model.messages.lastIndexWhere((message) {
                                                       return message.role == Roles.model && message.text.isNotEmpty;
                                                           });
            
                                                    // Return true if isRetry is false, otherwise return false
                                                   bool isNotRetry = lastModelMessageIndex != -1 ? !model.messages[lastModelMessageIndex].isRetry : false;
            
            
            
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
                    
                            // print('User Message: ${userMessage.text}');
                            // print('Model Message: ${modelMessage.text}');
                    
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
                                    visible: (model.canshowWelcome) && !isKeyboardVisible, // && !vpnStatusProvider.showErrorPage,
                                    child: Container(
                                        // height:
                                        //     MediaQuery.of(context).size.height *
                                        //         0.23, // 180,
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
                                                StringConstants.needHelpWithSite,style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 8.0),
                                              child: Text('${StringConstants.iCanHelpYouSummarising}${model.isSummariseAvailable ? " Try\n this:" : ""}',style: TextStyle(fontFamily: 'Poppins',fontSize:12, fontWeight: FontWeight.w300)
                                                  ),
                                            ),
                                            Visibility(
                                              visible: (model.canshowWelcome &&
                                        browserModel.webViewTabs.isNotEmpty &&
                                        model.isSummariseAvailable) && !isKeyboardVisible && !vpnStatusProvider.showErrorPage && vpnStatusProvider.canShowHomeScreen == false,
                                              child: Align(
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
                                                    webViewModel,aiModelProvider.selectedModel
                                                    );
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
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    )
                                  );
                                  }
                                  
                                   ),
                                 //Spacer(),
                                 Visibility(
                                  visible: (model.canshowWelcome &&
                                        //browserModel.webViewTabs.isNotEmpty &&
                                        !model.isSummariseAvailable),
                                   child: SizedBox( height:MediaQuery.of(context).size.height * (60 / MediaQuery.of(context).size.height), //30,
                                   ),
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
                                        model.canshowWelcome == false && !vpnStatusProvider.showErrorPage
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
                                                  webViewModel,aiModelProvider.selectedModel);
                                              urlSummaryProvider.updateCanStop(false);
                                              model.messageController.clear();
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
                           LayoutBuilder(
                          builder: (context, constraints) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Stack(
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          minHeight: screenHeight * 0.04, // 15% of screen height initially
                          maxHeight: screenHeight * 0.15, // 40% of screen height maximum
                        ),
                                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide( color: themeProvider.darkTheme ? Color(0xff3D4354) : Color(0xffDADADA)),right: BorderSide(color: themeProvider.darkTheme ? Color(0xff3D4354) : Color(0xffDADADA)),left: BorderSide(color: themeProvider.darkTheme ? Color(0xff3D4354) : Color(0xffDADADA))),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0),topRight: Radius.circular(10.0)),
                                                ),
                          
                        child: TextField(
                         enabled: !model.isTyping,
                                              controller: model.messageController,
                                              maxLength: 1000,
                                               inputFormatters: [
                                                  LengthLimitingTextInputFormatter(1000), // Restrict input
                                                ],
                                              maxLines: null, // Auto-expand with limit
                                              keyboardType: TextInputType.multiline,
                                              textInputAction: TextInputAction.done,
                                             //selectionControls: ClippedSelectionControls(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14,
                                              ),
                                  magnifierConfiguration: TextMagnifierConfiguration.disabled,
                                               onSubmitted: (value) {
                                  
                              // Check if there’s any input in the message controller
                                    if (model.messageController.text.trim().isNotEmpty) {
                                                            final lastModelMessageIndex = model.messages.lastIndexWhere(
                                    (message) => message.role == Roles.model && message.text.isNotEmpty,
                                  );
                                 if(containsUrl(model.messageController.text)){
                                  return;
                                 }
                                      urlSummaryProvider.updateSummariser(false);
                                      model.isTyping = true;
                                     
                                      // Reset messages state and UI components
                                       if (lastModelMessageIndex != -1) {
                                         model.messages[lastModelMessageIndex].canShowRegenerate = false;
                                         model.messages[lastModelMessageIndex].isRetry = false;
                                       }
                                      FocusScope.of(context).unfocus();
                                      setWelcomeAIScreen();
                                      model.canshowWelcome = false;
                                      model.isSummariseAvailable = false;
                              
                                      // Handle new message if text is present
                                      model.getTextForUser(modelType: aiModelProvider.selectedModel); //getTextAndImageInfo();
                                      model.messageController.clear();
                                    }                          },
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
                      Positioned(
                        top:15.0,right:15.0,
                        child: Visibility(
                          visible: model.messageController.text.isNotEmpty,
                          child: GestureDetector(
                            onTap: ()=> model.messageController.clear(),
                            child: SvgPicture.asset(
                                                  themeProvider.darkTheme
                                                      ? IconConstants.closeIconDark
                                                      : IconConstants.closeIconWhite,
                                                  width: 15, // Ensure visibility
                                                  height: 15,
                                                ),
                          ),
                        ),)
                    ],
                                  ),
                                  Container(
                       padding: const EdgeInsets.only(left: 15,right:15,bottom: 8.0),
                       margin: EdgeInsets.only(bottom: 5.0),
                    decoration: BoxDecoration(
                     // color: Colors.green,
                      border: Border(bottom: BorderSide( color: themeProvider.darkTheme ? Color(0xff3D4354) : Color(0xffDADADA)),right: BorderSide(color: themeProvider.darkTheme ? Color(0xff3D4354) : Color(0xffDADADA)),left: BorderSide(color: themeProvider.darkTheme ? Color(0xff3D4354) : Color(0xffDADADA))),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0),bottomRight: Radius.circular(10.0))),
                                  
                                  child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical:3.0),
                              child: GestureDetector(
                                onTap: (){
                                          final lastModelMessageIndex = model.messages.lastIndexWhere(
                                    (message) => message.role == Roles.model && message.text.isNotEmpty,
                                  );
                              
                                  final lastUserMessageIndex = model.messages.lastIndexWhere(
                                (message) => message.role == Roles.user,
                              );
                                 if(containsUrl(model.messageController.text)){
                                  return;
                                 }
                              
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
                                  model.messages[lastUserMessageIndex + 1].text = 'The response has been interrupted'; // If token cancelled before generating response
                                  model.messages[lastUserMessageIndex + 1].canShowRegenerate = true;
                                }else if (lastModelMessageIndex != -1) {
                                  
                                      model.messages[lastModelMessageIndex].canShowRegenerate = true;
                                       print('OnData coming inside data ${model.messages[lastModelMessageIndex].canShowRegenerate}');
                                    }
                              
                                  } else {
                                    // Check if there’s any input in the message controller
                                    if (model.messageController.text.trim().isNotEmpty) {
                                      //MessageBodyState().updateTypingText();
                                      urlSummaryProvider.updateSummariser(false);
                                      //typingProvider.updateAITypingState(true);
                                      model.isTyping = true;
                                     
                                      // Reset messages state and UI components
                                       if (lastModelMessageIndex != -1) {
                                         model.messages[lastModelMessageIndex].canShowRegenerate = false;
                                         model.messages[lastModelMessageIndex].isRetry = false;
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
                                      model.getTextForUser(modelType: aiModelProvider.selectedModel); //getTextAndImageInfo();
                                      model.messageController.clear();
                                    }
                                  }
                              
                                  },
                                child: 
                                SizedBox(
                                  height: 25,width: 25,
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: SvgPicture.asset(
                                       (model.messageController.text.trim().isEmpty && !model.isTyping) || containsUrl(model.messageController.text) ? 
                                       themeProvider.darkTheme ? 'assets/images/ai-icons/send_disabled.svg' : 'assets/images/ai-icons/send_disabled_wht_theme.svg'
                                       :
                                        model.isTyping
                                            ? 
                                            //themeProvider.darkTheme
                                               // ? 
                                                'assets/images/ai-icons/stop.svg'
                                               // : 'assets/images/ai-icons/Stop Circled 1.svg'
                                            : 
                                            //themeProvider.darkTheme
                                                //? 
                                                IconConstants.send
                                                //: IconConstants.sendWhite,
                                      ),
                                  ),
                                ),
                              ),
                             
                            ),
                          ],
                        ),
                                  )
                                ],
                              ),
                            );
                          },
                        )   
                              ],
                            )
                          ],
                        ),
                      );
                    });
                  //);
                },
                
                ),
          ),
        );
      },
    );
  }


}


