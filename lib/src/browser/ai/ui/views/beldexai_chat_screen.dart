import 'dart:async';
import 'dart:io';

import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/locale_provider.dart';
import 'package:beldex_browser/src/browser/ai/ai_model_provider.dart';
import 'package:beldex_browser/src/browser/ai/chat_screen.dart';
import 'package:beldex_browser/src/browser/ai/constants/icon_constants.dart';
import 'package:beldex_browser/src/browser/ai/constants/string_constants.dart';
import 'package:beldex_browser/src/browser/ai/enums/roles.dart';
import 'package:beldex_browser/src/browser/ai/models/chat_model.dart';
import 'package:beldex_browser/src/browser/ai/repositories/openai_repository.dart';
import 'package:beldex_browser/src/browser/ai/ui/views/base_views.dart';
import 'package:beldex_browser/src/browser/ai/ui/widgets/attachment_preview.dart';
import 'package:beldex_browser/src/browser/ai/ui/widgets/audio/floating_read_aloud_player.dart';
import 'package:beldex_browser/src/browser/ai/ui/widgets/audio/read_aloud_controller.dart';
import 'package:beldex_browser/src/browser/ai/ui/widgets/full_screen_image_viewer.dart';
import 'package:beldex_browser/src/browser/ai/ui/widgets/message_pair.dart';
import 'package:beldex_browser/src/browser/ai/ui/widgets/pop_up_menu.dart';
import 'package:beldex_browser/src/browser/ai/ui/widgets/waveform_widget.dart';
import 'package:beldex_browser/src/browser/ai/view_models/chat_view_model.dart';
import 'package:beldex_browser/src/browser/custom_popup_menu_item.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/pages/tab_settings/glassmorph_widget.dart';
import 'package:beldex_browser/src/browser/providers/tab_provider.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/utils/show_message.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdfx/pdfx.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

GlobalKey chatMenukey = GlobalKey();



// ignore: must_be_immutable
class BeldexAIScreen extends StatefulWidget {
  final bool isWelcomeShown;
  final String searchWord ;
  BeldexAIScreen({super.key, required this.isWelcomeShown, this.searchWord=''});

  @override
  State<BeldexAIScreen> createState() => _BeldexAIScreenState();
}

class _BeldexAIScreenState extends State<BeldexAIScreen> with WidgetsBindingObserver{
  ChatViewModel? model;

  bool? canShowWelcome;

  OpenAIRepository openAIRepository = OpenAIRepository();

    late List<ContextMenuButtonItem> buttonItems = [];

     late EditableTextState editableState = EditableTextState();



   





@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addObserver(this);
}











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
  if(widget.searchWord.isNotEmpty || widget.searchWord != ''){

    // Strict URL detection regex (only detects URLs with "http://" or "https://")
    final urlRegex = RegExp(
      r'\b(https?|ftp):\/\/[^\s/$.?#].[^\s]*\b',
      caseSensitive: false,
    );

    final match = urlRegex.firstMatch(widget.searchWord);
    bool containsUrl = match != null;

    String? extractedUrl = containsUrl ? match!.group(0) : null;
     print('The Real Data -----> ${widget.searchWord} ---- $extractedUrl');
     //model.getTextFromAskAI(searchWord);
      if(containsUrl){
        print('The Real Data 22-----> ${widget.searchWord} ---- $extractedUrl');
        model.getTextFromAskBeldexAI(extractedUrl!,webViewModel,aiModelProvider.selectedModel);
      } else{
        print('The Real Data 333-----> ${widget.searchWord} ---- $extractedUrl');
        model.getTextForUser(userMessage: widget.searchWord,modelType:aiModelProvider.selectedModel);
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
 final DraggableScrollableController _controller =
      DraggableScrollableController();

  double previousExtent = 0.95; 
 // Track previous sheet position
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
       model.canshowWelcome = widget.isWelcomeShown;
        checkSummariseString(webViewModel, model);
        model.isTyping = false;
        model.clearAttachments();

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

bool isAllTextSelected(TextSelection selection, String text) {
  return selection.baseOffset == 0 && selection.extentOffset == text.length;
}


Future<void> showAttachmentOptions(BuildContext context,DarkThemeProvider themeProvider,ChatViewModel model)async {

   await model.initializeDailyAttachmentLimit();

  if (!context.mounted) return;

  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      final isDark = themeProvider.darkTheme;
      
      return Container(
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.only(
          top: 12,
          left: 8,
          right: 8,
          bottom: 8,
        ),
        padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: isDark
              ? const Color(0xff111111)
              : Color(0xffEBEBEB),
              
              border: Border.all(color: Color(0xff444444))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Color(0xff333333)
                        : Color(0xffACACAC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
            
                const SizedBox(height: 20),
            
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Add Files',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
                                const SizedBox(height: 12),

               !model.canAddMoreImages ? Align(
                alignment: Alignment.center,
                 child: Text(
                      'Reached today limit.Please wait for 24 hours for more attachments',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
               ):SizedBox.shrink(),
                const SizedBox(height: 12),
            
                // Camera
                _attachmentOption(
                  icon: 'camera.svg',
                  title: 'Camera',
                  isDark: isDark,
                  model: model,
                  onTap: () async {
                    Navigator.pop(context);
                    await model.pickFromCamera();
                  },
                ),
            Divider(
                  color: themeProvider.darkTheme ? Color(0xff333333) : Color(0xffCCCCCC),
                ),
                // Photos
                _attachmentOption(
                  icon: 'photos.svg',
                  title: 'Photos',
                  isDark: isDark,
                  model: model,
                  onTap: () async {
                    Navigator.pop(context);
                    await model.pickFromGallery();
                  },
                ),
                Divider(
                  color: themeProvider.darkTheme ? Color(0xff333333) : Color(0xffCCCCCC),
                ),
                // Files
                _attachmentOption(
                  icon: 'files.svg',
                  title: 'Files',
                  isDark: isDark,
                  model: model,
                  onTap: () async {
                    Navigator.pop(context);
                    await model.pickFromFiles(); //pickFile();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _attachmentOption({
  required String icon,
  required String title,
  required bool isDark, required ChatViewModel model,
  required VoidCallback onTap,
}) {

  final bool canAttach = model.canAddMoreImages;
 //final bool enabled = model.canAddMoreAttachments;

  return InkWell(
    onTap: !canAttach //model.imageFiles.length >= 10
     ? null : onTap,
    //borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: isDark ? Color(0xff222222) : Color(0xffEBEBEB)),
              color:  isDark
                  ? const Color(0xff1A1A1A)
                  : const Color(0xffF2F2F2),
             // borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset('assets/images/ai-icons/new/$icon',color: !canAttach // model.imageFiles.length >= 10
               ? Colors.grey : isDark ? Colors.white : Colors.black,)
            ),

          const SizedBox(width: 14),

          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: !canAttach // model.imageFiles.length >= 10
               ? Colors.grey : isDark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
        ],
      ),
    ),
  );
}

//////////////////////////////





@override
void dispose() {
  WidgetsBinding.instance.removeObserver(this);

  // Stop Read Aloud when BeldexAI screen is closed.
  final readAloudController =
      context.read<ReadAloudController>();

  readAloudController.close();

  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    var browserModel = Provider.of<BrowserModel>(context,listen: false);
    final webViewModel = Provider.of<WebViewModel>(context);
    final urlSummaryProvider = Provider.of<UrlSummaryProvider>(context);
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
    final aiModelProvider = Provider.of<AIModelProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final loc = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context,listen: false);
    final groupProvider = Provider.of<GroupProvider>(context);
    final readAloudController = Provider.of<ReadAloudController>(context);
    return BaseView<ChatViewModel>(
      onModelReady: (model) {
        this.model = model;
        basicSetting(model,webViewModel,aiModelProvider);
      },
      builder: (context, model, child) {
        //print('BASE MODEL BUILDER CALLING ${model.messages}');
        
        return PopScope(
           canPop: true,
  onPopInvokedWithResult: (bool didPop, dynamic result) async {
    if (didPop) {
      await readAloudController.close();
    }
  },
          child: SafeArea(
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
                      LayoutBuilder(builder: (context, constraint) {
                        return Container(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          decoration: BoxDecoration(
                              color:Colors.transparent //themeProvider.darkTheme ? Color(0xff171720) : Color(0xffFFFFFF)
                              ),
                          child: Stack(
                            children: [
             Positioned.fill(
          child:themeProvider.darkTheme ? Image.asset(
            'assets/images/ai-icons/new/background_map.gif',
            fit: BoxFit.cover,
          ): Image.asset(
            'assets/images/ai-icons/new/BG_wht_theme.gif',
            fit: BoxFit.cover,
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
                                        Text(loc.beldexAI,
                                          //StringConstants.beldexAI,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                             // color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Spacer(),
                                        SizedBox(
                                          height: 48,
                                         // color: Colors.yellow,
                                          child:Icon(Icons.close,color: Colors.transparent,)
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: GestureDetector(
                                            onTap: ()async {
                                                await readAloudController.close();
          
                                                if (!context.mounted) return;
          
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
                                 model.canshowWelcome 
                                      ? SizedBox()
                                      :Padding(
                                    padding: EdgeInsets.only(left: 15,right: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                      // SvgPicture.asset(
                                      //     IconConstants.beldexAILogoWhiteColor,color: themeProvider.darkTheme ? Colors.white : Color(0xff333333),),
                                      Text(loc.chat,
                                        //IconConstants.chat,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'Inter',
                                            color: themeProvider.darkTheme ? Colors.white : Color(0xff333333),
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Row(
                                        children: [
                                          Visibility(
                                          visible:true, //model.messages.isNotEmpty,
                                          child: GestureDetector(
                                            onTap:model.messages.isNotEmpty ? ()async{
                                          
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
                                             await readAloudController.close();
                                            
                                            }: null,
                                            child: SizedBox(
                                              child: SvgPicture.asset('assets/images/ai-icons/Erase _dark.svg',color:model.messages.isEmpty ? Colors.grey : themeProvider.darkTheme ? Colors.white : Color(0xff333333))),
                                          ),
                                         // ),
                                        ),
                                        Visibility(
                                          visible:true, //model.messages.isNotEmpty,
                                          child: PopupMenuButton<String>(
                                            menuPadding: EdgeInsets.zero,
                           color:themeProvider.darkTheme ? Color(0xff222222).withOpacity(0.9): Color(0xffEBEBEB).withOpacity(0.1),
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor:themeProvider.darkTheme ? Color(0xff222222).withOpacity(0.9) :Color(0xffEBEBEB).withOpacity(0.1),
                 // color:  themeProvider.darkTheme ?const Color(0xff282836) :const Color(0xffF3F3F3),
          constraints: BoxConstraints(
                    maxWidth: 220,
                   ),
               shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(
                color:themeProvider.darkTheme ? Color(0xff333333) :  Color(0xffD4D4D4), //.withOpacity(0.2),
                width: 1,
              ),
            ),
                                                  //color:  themeProvider.darkTheme ?const Color(0xff282836) :const Color(0xffF3F3F3),
                                                        icon: Icon(Icons.more_horiz,
                                                            color: themeProvider.darkTheme ? Colors.white : Colors.black),
                                                  onSelected:(value)async {
                                                final chatHistory = model.messages.map((message) {
                                                              final prefix = message.role == Roles.user ? "You: " : "Beldex AI: ";
                                                               return "$prefix\n${message.text}";
                                                               }).join("\n");
                                                     print("THE CHAT HISTORY IS $chatHistory");
                                          
                                                         switch(value){
                                                          case AIChatPopupMenuActions.COPY_CHAT:
                                                             
                                                    if(model.messages.isNotEmpty){
                                                      Clipboard.setData(ClipboardData(text:removeSpecialFormatting(chatHistory)));
                                                           // Clipboard.setData(ClipboardData(text: modelMessage.text));
                                                            showMessage(loc.copied  
                                                            );
                                                    }
                                                          break;
                                                          case AIChatPopupMenuActions.SHARE_CHAT:
                                                          if(model.messages.isNotEmpty){
                                                           Share.share(removeSpecialFormatting(chatHistory), subject:'');}
                                                          break;
                                                          case AIChatPopupMenuActions.DELETE_CHAT:
                                                          if(model.messages.isNotEmpty){
                                                             await readAloudController.close(); 
                                                            model.messages = []; //.clear();
                                                             showMessage(loc.chatDeleted);}
                                                          break;
                                                         }
                                                  },
                                                  offset: Offset(0, 47),
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
                                                            padding: EdgeInsets.zero,
                                                            child: GlassSettingPanel(
                                                               color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffFFFFFF).withOpacity(0.1),
                                                              child: Container(
                                                                height: 35,
                                                                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                                                child: Row(
                                                                    children: [
                                                                     SvgPicture.asset(IconConstants.copyIconWhite ,color:model.messages.isEmpty ||  model.isTyping ? themeProvider.darkTheme ? Color(0xffEBEBEB).withOpacity(0.3): Color(0xff0B0B0B).withOpacity(0.3) : themeProvider.darkTheme
                                                                                                                      ?const Color(0xffFFFFFF)
                                                                                                                      :const Color(0xff282836)),
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(horizontal:8.0),
                                                                        child: Text(loc.copy,
                                                                         style: Theme.of(context)
                                                                                                                    .textTheme
                                                                                                                    .bodySmall?.copyWith( 
                                                                                                                      color: model.messages.isEmpty || model.isTyping ? themeProvider.darkTheme ? Color(0xffEBEBEB).withOpacity(0.3): Color(0xff0B0B0B).withOpacity(0.3) : themeProvider.darkTheme ? Colors.white:Colors.black,
                                                                                                                      fontFamily: 'Inter'
                                                                                                                    )),
                                                                      ),
                                                                    ]),
                                                              ),
                                                            ),
                                                          );
                                                        case AIChatPopupMenuActions.SHARE_CHAT:
                                                          return CustomPopupMenuItem<String>(
                                                            enabled:model.messages.isNotEmpty && !model.isTyping,
                                                            value:choice, // choice,
                                                            height: 35,
                                                            padding: EdgeInsets.zero,
                                                            child: GlassSettingPanel(
                                                               color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffFFFFFF).withOpacity(0.1),
                                                              child: Container(
                                                                height: 35,padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                                                child: Row(
                                                                    children: [
                                                                       SvgPicture.asset('assets/images/ai-icons/Share.svg' ,color:model.messages.isEmpty || model.isTyping ? themeProvider.darkTheme ? Color(0xffEBEBEB).withOpacity(0.3): Color(0xff0B0B0B).withOpacity(0.3) : themeProvider.darkTheme
                                                                                                                    ?const Color(0xffFFFFFF)
                                                                                                                    :const Color(0xff282836)),
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(horizontal:5.0),
                                                                        child: Text(loc.share, style: Theme.of(context)
                                                                                                                    .textTheme
                                                                                                                    .bodySmall?.copyWith( 
                                                                                                                      color: model.messages.isEmpty || model.isTyping ? themeProvider.darkTheme ? Color(0xffEBEBEB).withOpacity(0.3) :  Color(0xff0B0B0B).withOpacity(0.3) : themeProvider.darkTheme ? Colors.white:Colors.black,
                                                                                                                      fontFamily: 'Inter'
                                                                                                                    )),
                                                                      ),
                                                                    ]),
                                                              ),
                                                            ),
                                                          );
                                                        case AIChatPopupMenuActions.DELETE_CHAT:
                                                          return CustomPopupMenuItem<String>(
                                                            enabled: model.messages.isNotEmpty && !model.isTyping,
                                                            value: choice,
                                                            height: 35,padding: EdgeInsets.zero,
                                                            child: GlassSettingPanel(
                                                               color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffFFFFFF).withOpacity(0.1),
                                                              child: Container(
                                                                height: 35,
                                                                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                                                child: Row(
                                                                    children: [
                                                                      SvgPicture.asset('assets/images/ai-icons/Trash 1.svg', 
                                                                               color: model.messages.isEmpty || model.isTyping ? themeProvider.darkTheme ? Color(0xffEBEBEB).withOpacity(0.3) : Color(0xff0B0B0B).withOpacity(0.3)
                                                                                                             : themeProvider.darkTheme
                                                                                                                    ?const Color(0xffFFFFFF)
                                                                                                                    :const Color(0xff282836)),
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(horizontal:5.0),
                                                                        child: Text(loc.delete,style: Theme.of(context)
                                                                                                                    .textTheme
                                                                                                                    .bodySmall?.copyWith( 
                                                                                                                      color: model.messages.isEmpty || model.isTyping ? themeProvider.darkTheme ? Color(0xffEBEBEB).withOpacity(0.3) :Color(0xff0B0B0B).withOpacity(0.3) : themeProvider.darkTheme ? Colors.white:Colors.black,
                                                                                                                      fontFamily: 'Inter'
                                                                                                                    )),
                                                                      ),
                                                                    ]),
                                                              ),
                                                            ),
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
                                        ],
                                      )
                                    ]),
                                  ),
                                model.messages.isEmpty && (groupProvider.totalOpenTabsCount != 0 //browserModel.webViewTabs.isNotEmpty
                                 &&
                                          model.isSummariseAvailable && vpnStatusProvider.canShowHomeScreen == false &&
                                          model.canshowWelcome == false && !vpnStatusProvider.showErrorPage)?
                                Expanded(child: 
                                 Padding(
                                   padding: EdgeInsets.symmetric(horizontal: 8),
                                   child: GlassSettingPanel(
                                    color: themeProvider.darkTheme ? Color(0xff444444).withOpacity(0.2): Color(0xffD4D4D4).withOpacity(0.2),
                                     child: Container(
                                      padding: EdgeInsets.only(bottom: 10),
                                       child: 
                                      //  browserModel.webViewTabs.isNotEmpty &&
                                      //     model.isSummariseAvailable && vpnStatusProvider.canShowHomeScreen == false &&
                                      //     model.canshowWelcome == false && !vpnStatusProvider.showErrorPage
                                      // ? 
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                                    webViewModel,aiModelProvider.selectedModel,loc);
                                                urlSummaryProvider.updateCanStop(false);
                                                model.messageController.clear();
                                               // urlSummaryProvider.updateSummariser(true);
                                              },
                                              child: GlassSettingPanel(
                                                color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Colors.transparent,
                                                child: Container(
                                                  //height: 40,
                                                  margin: EdgeInsets.only(left: 10),
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 15.0, horizontal: 15),
                                                  decoration: BoxDecoration(
                                                      color:themeProvider.darkTheme ? Colors.transparent : Color(0xff222222) //themeProvider.darkTheme ? Color(0xff222222) : Color(0xff),
                                                      // borderRadius:
                                                      //     BorderRadius.circular(12)
                                                          ),
                                                  child: Row(
                                                    children: [
                                                      Text(loc.summariseThisPage,style: TextStyle(color: Colors.white,fontFamily: 'Inter',),),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                                left: 8.0),
                                                        child: SvgPicture.asset(
                                                            IconConstants
                                                                .summariseIcon,  color: Color(0xff01D001),),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      //: SizedBox(),
                                     ),
                                   ),
                                 )
                                
                                ): model.messages.isEmpty && !model.canshowWelcome ?
                                
                                Expanded(child: 
                                 Padding(
                                   padding: EdgeInsets.symmetric(horizontal: 8),
                                   child: GlassSettingPanel(
                                    color: themeProvider.darkTheme ? Color(0xff444444).withOpacity(0.2): Color(0xffD4D4D4).withOpacity(0.2),
                                     child: Container(
                                      // padding: EdgeInsets.only(bottom: 10),
                                      //  child: 
                                      // //  browserModel.webViewTabs.isNotEmpty &&
                                      // //     model.isSummariseAvailable && vpnStatusProvider.canShowHomeScreen == false &&
                                      // //     model.canshowWelcome == false && !vpnStatusProvider.showErrorPage
                                      // // ? 
                                      // Row(
                                      //   crossAxisAlignment: CrossAxisAlignment.end,
                                      //     mainAxisAlignment:
                                      //         MainAxisAlignment.center,
                                      //     children: [
                                      //       GestureDetector(
                                      //         onTap: () {
                                      //           urlSummaryProvider.updateSummariser(true);
                                      //           urlSummaryProvider.updateCanStop(true);
                                      //           model.isSummariseAvailable = false;
                                      //           model.summariseText =
                                      //               webViewModel.url.toString() ??
                                      //                   '';
                                      //           model.getTextAndSummariseInfo(
                                      //               webViewModel,aiModelProvider.selectedModel,loc);
                                      //           urlSummaryProvider.updateCanStop(false);
                                      //           model.messageController.clear();
                                      //          // urlSummaryProvider.updateSummariser(true);
                                      //         },
                                      //         child: GlassSettingPanel(
                                      //           color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Colors.transparent,
                                      //           child: Container(
                                      //             //height: 40,
                                      //             margin: EdgeInsets.only(left: 10),
                                      //             padding: EdgeInsets.symmetric(
                                      //                 vertical: 15.0, horizontal: 15),
                                      //             decoration: BoxDecoration(
                                      //                 color:themeProvider.darkTheme ? Colors.transparent : Color(0xff222222) //themeProvider.darkTheme ? Color(0xff222222) : Color(0xff),
                                      //                 // borderRadius:
                                      //                 //     BorderRadius.circular(12)
                                      //                     ),
                                      //             child: Row(
                                      //               children: [
                                      //                 Text(loc.summariseThisPage,style: TextStyle(color: Colors.white,fontFamily: 'Inter',),),
                                      //                 Padding(
                                      //                   padding:
                                      //                       const EdgeInsets.only(
                                      //                           left: 8.0),
                                      //                   child: SvgPicture.asset(
                                      //                       IconConstants
                                      //                           .summariseIcon,  color: Color(0xff01D001),),
                                      //                 )
                                      //               ],
                                      //             ),
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   )
                                      // //: SizedBox(),
                                     ),
                                   ),
                                 )
                                
                                )
                                :
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
                                      child: Padding(
                                         padding: EdgeInsets.all(8.0),
                                        child: GlassPanel(
                                           //color: themeProvider.darkTheme ? Color(0xff1A1A1A) : Color(0xffEBEBEB),
                                          child: Container(
                                              // height:
                                              //     MediaQuery.of(context).size.height *
                                              //         0.23, // 180,
                                              width: MediaQuery.of(context).size.width,
                                             
                                              padding: EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                color:Colors.transparent, //themeProvider.darkTheme ? Color(0xff282836) : Color(0xffF3F3F3),
                                               //border: Border.all(color: themeProvider.darkTheme ? Color(0xff444444) : Color(0xffD4D4D4))                                           // borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(loc.needHelpWithThisSite
                                                     // StringConstants.needHelpWithSite
                                                      ,style: TextStyle(fontFamily: 'Inter',fontSize: 14, fontWeight: FontWeight.w600),),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                        vertical: 8.0), //StringConstants.iCanHelpYouSummarising
                                                    child: Text('${loc.beldexAICanHelpYou}${model.isSummariseAvailable ? loc.tryThis : ""}',style: TextStyle(fontFamily: 'Roboto',fontSize:12, fontWeight: FontWeight.w300)
                                                        ),
                                                  ),
                                                  Visibility(
                                                    visible: (model.canshowWelcome &&
                                                    groupProvider.totalOpenTabsCount != 0
                                              //browserModel.webViewTabs.isNotEmpty 
                                              &&
                                              model.isSummariseAvailable) && !isKeyboardVisible && !vpnStatusProvider.showErrorPage && vpnStatusProvider.canShowHomeScreen == false,
                                                    child: Align(
                                                      alignment: Alignment.bottomLeft,
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
                                                          webViewModel,aiModelProvider.selectedModel,loc
                                                          );
                                                      urlSummaryProvider.updateCanStop(false);
                                                        },
                                                        child: GlassSettingPanel(
                                                          color: themeProvider.darkTheme ? Color(0xff1A1A1A) : Color(0xffEBEBEB),
                                                          child: Container(
                                                            padding: EdgeInsets.symmetric(
                                                                vertical: 12,
                                                                horizontal: 14),
                                                            decoration: BoxDecoration(
                                                                color: Colors.transparent//themeProvider.darkTheme ? Color(0xff171720): Color(0xffFFFFFF),
                                                                // borderRadius:
                                                                //     BorderRadius.circular(
                                                                //         12)
                                                                ),
                                                            child: Text(loc.summariseThisPage,
                                                              // StringConstants
                                                              //     .summariseThispage,
                                                              style: TextStyle(fontFamily: 'inter',fontSize: 12,
                                                                  color: Color(0xff01D001)),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
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
                                          !model.isSummariseAvailable && localeProvider.languages == 'English'),
                                     child: SizedBox( height:MediaQuery.of(context).size.height * (60 / MediaQuery.of(context).size.height), //30,
                                     ),
                                   ),
          
                                 model.messages.isNotEmpty && (groupProvider.totalOpenTabsCount != 0 //browserModel.webViewTabs.isNotEmpty 
                                 &&
                                          model.isSummariseAvailable && vpnStatusProvider.canShowHomeScreen == false &&
                                          model.canshowWelcome == false && !vpnStatusProvider.showErrorPage)
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                                    webViewModel,aiModelProvider.selectedModel,loc);
                                                urlSummaryProvider.updateCanStop(false);
                                                model.messageController.clear();
                                               // urlSummaryProvider.updateSummariser(true);
                                              },
                                              child: GlassSettingPanel(
                                                color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Colors.transparent,
                                                child: Container(
                                                  //height: 40,
                                                  margin: EdgeInsets.only(left: 10),
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 15.0, horizontal: 15),
                                                  decoration: BoxDecoration(
                                                     color:themeProvider.darkTheme ? Colors.transparent : Color(0xff222222) //themeProvider.darkTheme ? Color(0xff222222) : Color(0xff),
                                                      // borderRadius:
                                                      //     BorderRadius.circular(12)
                                                          ),
                                                  child: Row(
                                                    children: [
                                                      Text(loc.summariseThisPage,style: TextStyle(color: Colors.white,fontFamily: 'Inter',),),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                                left: 8.0),
                                                        child: SvgPicture.asset(
                                                            IconConstants
                                                                .summariseIcon,  color: Color(0xff01D001),),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : SizedBox(),
                            !readAloudController.isVisible ?
             const SizedBox.shrink()
             : FloatingReadAloudPlayer(
              model:model,
          controller: readAloudController,
                ),
          
                             LayoutBuilder(
                            builder: (context, constraints) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight:50, //constraints.minHeight*0.50, //1.0,
                                    maxHeight:180 //constraints.maxHeight*2.0,
                                  ),
                                  child: Container(
                                     decoration: BoxDecoration(
              border: Border.all(
                color: themeProvider.darkTheme
                    ? const Color(0xff444444)
                    : const Color(0xffD4D4D4),
                width: 1,
              ),
              //borderRadius: BorderRadius.circular(16),
            ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                    
                                    
                                    if (model.imageFiles.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 76,
                                          child: ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            clipBehavior: Clip.hardEdge,
                                            padding: const EdgeInsets.only(
                                              top: 6,
                                              right: 6,
                                            ),
                                            itemCount: model.imageFiles.length,
                                            separatorBuilder: (_, __) =>
                                                const SizedBox(width: 8),
                                            itemBuilder: (context, index) {
                                              final file = model.imageFiles[index];
                                      
                                              return SizedBox(
                                                width: 70,
                                                child: Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    Positioned(
                                                      left: 0,
                                                      right: 0,
                                                      bottom: 0,
                                                      top: 6,
                                                      child: 
                                                      AttachmentPreview(
                    file: file,
                    onTap: () {
                      // Open the appropriate preview for this file.
                      showFullScreenImagePreview(
                        context,
                        model.imageFiles,
                        index,
                      );
                    },
                  ),
                                                     
                                                    ),
                                      
                                                    // Remove attachment button
                                                    Positioned(
                                                      right: -2,
                                                      top: 0,
                                                      child: GestureDetector(
                                                        behavior: HitTestBehavior.opaque,
                                                        onTap: () {
                                                          model.removeFileAttachment(index);
                                                        },
                                                        child: Container(
                                                          width: 22,
                                                          height: 22,
                                                          decoration: const BoxDecoration(
                                                            shape: BoxShape.rectangle,
                                                            color: Colors.black87,
                                                          ),
                                                          alignment: Alignment.center,
                                                          child: const Icon(
                                                            Icons.close,
                                                            size: 14,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    
                                    
                                    // TEXT + ACTION BUTTONS
                                    // -------------------------
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 6,
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          // --------------------------------------------------
                                          // ATTACHMENT / CLOSE MIC BUTTON
                                          // --------------------------------------------------
                                          SizedBox(
                                            width: 40,
                                            height: 40,
                                            child: Center(
                                              child: GestureDetector(
                                                behavior: HitTestBehavior.opaque,
                                                onTap: () async {
                                                  if (model.isListening) {
                                                    await model.cancelVoiceSearch(); //toggleVoiceSearch();
                                                   // model.messageController.clear();
                                                  } else {
                                                    showAttachmentOptions(
                                                      context,
                                                      themeProvider,
                                                      model,
                                                    );
                                                  }
                                                },
                                                child: SizedBox(
                                                  width: 32,
                                                  height: 32,
                                                  child: Center(
                                                    child: SvgPicture.asset(
                                                      model.isListening
                                                          ? 'assets/images/ai-icons/new/close_mic.svg'
                                                          : 'assets/images/ai-icons/new/add_attach.svg',
                                                      width: 20,
                                                      height: 20,color: themeProvider.darkTheme ? Colors.white : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                    
                                          // --------------------------------------------------
                                          // EXPANDING TEXT / LISTENING / TRANSCRIBING
                                          // --------------------------------------------------
                                          Expanded(
                                            child: AnimatedSwitcher(
                                              duration: const Duration(milliseconds: 200),
                                              child: model.isListening
                                                  ? _buildListeningView(
                                                      context,
                                                      model,
                                                      themeProvider,
                                                    )
                                                  : model.isTranscribing
                                                      ? _buildTranscribingView(
                                                          context,
                                                          model,
                                                          themeProvider,
                                                        )
                                                      : 
                                                      _buildMessageTextField(
                                                          context,
                                                          model,
                                                          themeProvider,
                                                          loc,
                                                        ),
                                            ),
                                          ),
                                    
                                          // --------------------------------------------------
                                          // MIC BUTTON
                                          // --------------------------------------------------
                                          SizedBox(
                                            width: 40,
                                            height: 40,
                                            child: Center(
                                              child: GestureDetector(
                                                behavior: HitTestBehavior.opaque,
                                                onTap:
                                                    model.isTyping ||
                                                            model.isTranscribing || readAloudController.isVisible
                                                        ? null
                                                        : () async {
                                                            await model.toggleVoiceSearch();
                                                          },
                                                child: SizedBox(
                                                  width: 32,
                                                  height: 32,
                                                  child: Center(
                                                    child: model.isListening ? SvgPicture.asset('assets/images/ai-icons/new/stop.svg') :
                                                     SvgPicture.asset('assets/images/ai-icons/new/mic.svg',color:readAloudController.isVisible ? Colors.grey :  themeProvider.darkTheme ? Colors.white : Colors.black,)
                                                    // Icon(
                                                    //   model.isListening
                                                    //       ? Icons.stop_circle_outlined
                                                    //       : Icons.mic_none_rounded,
                                                    //   size: 23,
                                                    //   color: model.isListening
                                                    //       ? Colors.red
                                                    //       : themeProvider.darkTheme
                                                    //           ? Colors.white
                                                    //           : Colors.black87,
                                                    // ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                    
                                          // --------------------------------------------------
                                          // SEND / STOP BUTTON
                                          // --------------------------------------------------
                                          ValueListenableBuilder<TextEditingValue>(
                                            valueListenable: model.messageController,
                                            builder: (context, value, child) {
                                              final hasText =
                                                  value.text.trim().isNotEmpty;
                                    
                                              final hasAttachments =
                                                  model.imageFiles.isNotEmpty;
                                    
                                              final canSend =
                                                  !model.isListening &&
                                                  !model.isTranscribing &&
                                                  (hasText || hasAttachments) &&
                                                  vpnStatusProvider.isNetConnected;
                                    
                                              return SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: Center(
                                                  child: GestureDetector(
                                                    behavior: HitTestBehavior.opaque,
                                                    onTap: () async {
            // --------------------------------------------------
            // STOP RESPONSE
            // --------------------------------------------------
            if (model.isTyping) {
              final lastModelMessageIndex =
                  model.messages.lastIndexWhere(
                (message) =>
                    message.role == Roles.model &&
                    message.text.isNotEmpty,
              );

              final lastUserMessageIndex =
                  model.messages.lastIndexWhere(
                (message) => message.role == Roles.user,
              );

              model.isTyping = false;
              model.stopResponse();

              if (lastUserMessageIndex != -1 &&
                  lastUserMessageIndex + 1 <
                      model.messages.length &&
                  model.messages[lastUserMessageIndex + 1].role ==
                      Roles.model &&
                  model.messages[lastUserMessageIndex + 1]
                      .text.isEmpty) {
                OpenAIRepository().cancelRequest();

                model.messages[lastUserMessageIndex + 1].text =
                    'The response has been interrupted';

                model.messages[lastUserMessageIndex + 1]
                    .canShowRegenerate = true;
              } else if (lastModelMessageIndex != -1) {
                model.messages[lastModelMessageIndex]
                    .canShowRegenerate = true;
              }

              return;
            }

            // --------------------------------------------------
            // STOP LISTENING AND WAIT FOR TRANSCRIPTION
            // --------------------------------------------------
            if (model.isListening) {
              await model.toggleVoiceSearch();
            }

            // Wait until speech recognition and transcription finish.
            while (model.isListening || model.isTranscribing) {
              await Future.delayed(
                const Duration(milliseconds: 100),
              );
            }

            // --------------------------------------------------
            // CAPTURE TRANSCRIBED MESSAGE
            // --------------------------------------------------
            final String userMessage =
                model.messageController.text.trim();

            final bool hasAttachments =
                model.imageFiles.isNotEmpty;

            final bool canSendNow =
                (userMessage.isNotEmpty || hasAttachments) &&
                !model.isListening &&
                !model.isTranscribing &&
                !model.isTyping &&
                vpnStatusProvider.isNetConnected;

            if (!canSendNow) {
              return;
            }

            // --------------------------------------------------
            // URL VALIDATION
            // --------------------------------------------------
            if (containsUrl(userMessage)) {
              return;
            }

            // --------------------------------------------------
            // PREPARE MESSAGE
            // --------------------------------------------------
            final lastModelMessageIndex =
                model.messages.lastIndexWhere(
              (message) =>
                  message.role == Roles.model &&
                  message.text.isNotEmpty,
            );

            urlSummaryProvider.updateSummariser(false);

            if (lastModelMessageIndex != -1) {
              model.messages[lastModelMessageIndex]
                  .canShowRegenerate = false;

              model.messages[lastModelMessageIndex].isRetry = false;
            }

            FocusScope.of(context).unfocus();

            setWelcomeAIScreen();

            model.canshowWelcome = false;
            model.isSummariseAvailable = false;

            // --------------------------------------------------
            // SEND MESSAGE
            // --------------------------------------------------
            debugPrint('MESSAGE BEFORE SEND: "$userMessage"');

            model.getTextForUser(
              userMessage: userMessage,
              modelType: aiModelProvider.selectedModel,
            );

            // Clear only after capturing the message.
            model.messageController.clear();
          },
                                                    child: Container(
                                                      width: 32,
                                                      height: 32,
                                                      decoration: BoxDecoration(
                                                        color: canSend ? Color(0xff1A1A1A) : themeProvider.darkTheme ? Color(0xff1A1A1A) : Color(0xffEBEBEB),
                                                        border: Border.all(color:canSend ? Color(0xff333333) : Colors.transparent)
                                                      ),
                                                      child: Center(
                                                        child: model.isTyping
                                                            ? SvgPicture.asset(
                                                                'assets/images/ai-icons/new/stop.svg',
                                                                // width: 24,
                                                                // height: 24,
                                                                color:
                                                                                        const Color(0xff8D8D8D),
                                                              )
                                                            : SvgPicture.asset(
                                                                'assets/images/ai-icons/new/send_ai.svg',
                                                                // width: 20,
                                                                // height: 20,
                                                                color: canSend
                                                                                        ? (
                                                                                          // themeProvider.darkTheme
                                                                                          //   ? 
                                                                                            Colors.white
                                                                                           // : Colors.black
                                                                                            )
                                                                                        : const Color(0xff8D8D8D),
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                   
                                      ],
                                    ),
                                  ),
                                )
                                
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
          ),
        );
      },
    );
  }



  Widget _buildListeningView(
  BuildContext context,
  ChatViewModel model,
  DarkThemeProvider themeProvider,
) {
  return Container(
    height: 56,
    alignment: Alignment.center,
    padding:
        const EdgeInsets.symmetric(
      horizontal: 12,
    ),
    child: VoiceWaveform(
      soundLevel:
          model.soundLevel,
      isDark:
          themeProvider.darkTheme,
    ),
  );
}
Widget _buildTranscribingView(
  BuildContext context,
  ChatViewModel model,
  DarkThemeProvider themeProvider,
) {
  final textColor =
      themeProvider.darkTheme
          ? Colors.white
          : Colors.black87;

  return Container(
    height: 56,
    alignment:
        Alignment.centerLeft,
    padding:
        const EdgeInsets.symmetric(
      horizontal: 14,
    ),
    child: Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: themeProvider.darkTheme ? Lottie.asset('assets/images/ai-icons/new/Transcribe_dark.json') : Lottie.asset('assets/images/ai-icons/new/Transcribe.json')
          //     CircularProgressIndicator(
          //   strokeWidth: 2,
          //   color: textColor,
          // ),
        ),
        const SizedBox(width: 12),
        Text(
          'Transcribing...',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: textColor,
          ),
        ),
      ],
    ),
  );
}

Widget _buildMessageTextField(
  BuildContext context,
  ChatViewModel model,
  DarkThemeProvider themeProvider,
  AppLocalizations loc,
) {
  return TextField(
    controller: model.messageController,
    maxLength: 1000,
    inputFormatters: [
      LengthLimitingTextInputFormatter(1000),
    ],
    minLines: 1,
    maxLines: 5,
    keyboardType: TextInputType.multiline,
    textInputAction: TextInputAction.newline,
    scrollPhysics:
        const ClampingScrollPhysics(),
    style: const TextStyle(
      fontWeight: FontWeight.normal,
      fontFamily: 'Inter',
      fontSize: 14,
    ),
    cursorColor: Colors.green,
    decoration: InputDecoration(
      border: InputBorder.none,
      counterText: '',
      hintText: loc.enterPromptHere,
      hintStyle: const TextStyle(
        color: Color(0xff8D8D8D),
        fontFamily: 'Inter',
        fontSize: 14,
      ),
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
    ),
    magnifierConfiguration:
        TextMagnifierConfiguration.disabled,
      contextMenuBuilder: (context, editableTextState) {
                                                          //final List<ContextMenuButtonItem>
                                                          buttonItems = editableTextState.contextMenuButtonItems;
                                    
                                                          editableState = editableTextState;
                                    
                                                          buttonItems.clear(); // Clear all default options
                                                          if (model.messageController.text.isEmpty) {
                                                            buttonItems.add(ContextMenuButtonItem(
                                                                label:loc.paste,// 'Paste',
                                                                onPressed: () {
                                                                  Clipboard.getData('text/plain').then((value) {
                                    if (value != null && value.text != null) {
                                      final text = model.messageController.text;
                                      //final selection = _searchController.selection;
                                      final selection = editableTextState
                                          .textEditingValue.selection;
                                      final newText = text.replaceRange(
                                        selection.start,
                                        selection.end,
                                        value.text!,
                                      );
                                      print(
                                          'text --> $text\n selection --> $selection\n newtext --> $newText');
                                      model.messageController.text = newText;
                                    //   if(model.messageController.text.trim().isEmpty || containsUrl(model.messageController.text)){
                                    //     print("The User Message Contains Url 1");
                                    //  // canShowSearchAI= '';
                                    //     }else
                                    //       canShowSearchAI= _searchController.text;
                                                             // print('BELDEX AI ---------> $canShowSearchAI');
                                            
                                      //canShowSearchAI = _searchController.text;
                                      final newSelection = TextSelection.collapsed(
                                        offset:
                                            selection.start + value.text!.length,
                                      );
                                       model.messageController.selection = newSelection;
                                      editableTextState.hideToolbar(false);
                                    }
                                                                  });
                                                                }));
                                                          } else {
                                                            buttonItems.clear();
                                                            buttonItems.add(ContextMenuButtonItem(
                                                              label:loc.cut, //'Cut',
                                                              onPressed: () {
                                                                editableTextState
                                    .cutSelection(SelectionChangedCause.tap);
                                                                final TextEditingController controller =
                                    editableTextState.widget.controller;
                                                                final TextEditingValue value = controller.value;
                                                                final TextSelection selection = value.selection;
                                                                if (!selection.isCollapsed) {
                                                                  final String cutText =
                                      selection.textInside(value.text);
                                                                  Clipboard.setData(ClipboardData(text: cutText));
                                    
                                                                  final String newText = value.text.replaceRange(
                                      selection.start, selection.end, '');
                                                                  controller.value = TextEditingValue(
                                      text: newText,
                                      selection: TextSelection.collapsed(
                                          offset: selection.start));
                                    
                                                                  final String findOnPageText =
                                       model.messageController.text;
                                                                  final String newFindOnPageText =
                                      findOnPageText.replaceRange(
                                          selection.start, selection.end, '');
                                    
                                                                  print(
                                      'Cut value Editable Text ---> $findOnPageText -- $newFindOnPageText -- $newText');
                                                                   model.messageController.text =
                                      findOnPageText; //newFindOnPageText;
                                                                }
                                                                //  // Clipboard.setData(ClipboardData(text: editableTextState.textEditingValue.text));
                                                                //   editableTextState.cutSelection(SelectionChangedCause.tap);
                                                                //   _searchController.clear();
                                                                //   //editableTextState.hideToolbar(false);
                                                              },
                                                            ));
                                    
                                                            buttonItems.add(ContextMenuButtonItem(
                                                              label: loc.copy,// 'Copy',
                                                              onPressed: () {
                                                                final TextEditingValue value =
                                    editableTextState.textEditingValue;
                                                                final TextSelection selection = value.selection;
                                    
                                                                if (!selection.isCollapsed) {
                                                                  final String selectedText =
                                      selection.textInside(value.text);
                                                                  Clipboard.setData(
                                      ClipboardData(text: selectedText));
                                                                  print("Copied value --> $selectedText");
                                                                }
                                                                editableTextState.hideToolbar(false);
                                                              },
                                                            ));
                                                            if (!isAllTextSelected(
                                                                editableTextState.textEditingValue.selection,
                                                                editableTextState.textEditingValue.text)) {
                                                              buttonItems.add(ContextMenuButtonItem(
                                                                label:loc.selectAll, // 'Select All',
                                                                onPressed: () {
                                                                  // Clipboard.setData(ClipboardData(text: editableTextState.textEditingValue.text));
                                                                  editableTextState
                                      .selectAll(SelectionChangedCause.tap);
                                                                  //editableTextState.hideToolbar(false);
                                                                },
                                                              ));
                                                            }
                                                            // Add a custom "Paste" button
                                                            buttonItems.add(ContextMenuButtonItem(
                                                              label:loc.paste, // 'Paste',
                                                              onPressed: () {
                                                                Clipboard.getData('text/plain').then((value) {
                                                                  if (value != null && value.text != null) {
                                    final text =  model.messageController.text;
                                    // final selection = _searchController.selection;
                                    final selection = editableTextState
                                        .textEditingValue.selection;
                                    final newText = text.replaceRange(
                                      selection.start,
                                      selection.end,
                                      value.text!,
                                    );
                                    print(
                                        'text --> $text\n selection --> $selection\n newtext --> $newText');
                                     model.messageController.text = newText;
                                    final newSelection = TextSelection.collapsed(
                                      offset: selection.start + value.text!.length,
                                    );
                                     model.messageController.selection = newSelection;
                                    editableTextState.hideToolbar(false);
                                                                  }
                                                                });
                                                              },
                                                            ));
                                                          }
                                                          return  AdaptiveTextSelectionToolbar.buttonItems(
                                                            anchors: editableTextState.contextMenuAnchors,
                                                            buttonItems: buttonItems,
                                                          );
                                                        },
  );
}

}


