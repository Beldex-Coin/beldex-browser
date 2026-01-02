import 'dart:async';

import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/src/browser/pages/reading_mode/reader_provider.dart';
// import 'package:beldex_browser/src/browser/pages/reading_mode/speech_text_provider.dart';
// import 'package:beldex_browser/src/browser/pages/reading_mode/translating_provider.dart';
import 'package:beldex_browser/src/providers.dart';
// import 'package:beldex_browser/src/translation_provider.dart';
// import 'package:beldex_browser/src/tts_provider.dart';
import 'package:beldex_browser/src/utils/show_message.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:html/dom.dart' as dom;
//import 'package:html/parser.dart' as html_parser;
//import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Word {
  final dom.Text textNode;
  final int start;
  final int end;
  final int globalIndex;  // Sequential index from traversal order

  Word({
    required this.textNode,
    required this.start,
    required this.end,
    required this.globalIndex,
  });
}

class SpeechHtmlScreen extends StatefulWidget {
  final Map<String, dynamic> article;
  const SpeechHtmlScreen({super.key, required this.article});

  @override
  State<SpeechHtmlScreen> createState() => _SpeechHtmlScreenState();
}

class _SpeechHtmlScreenState extends State<SpeechHtmlScreen>{
 final FlutterTts flutterTts = FlutterTts();

//TtsInterruptionController ttsInterruptionController = TtsInterruptionController();
 final ScrollController _scrollController = ScrollController();

 late Connectivity _connectivity;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  String? selectedLocale = 'en-US'; // default selected

  @override
  void initState() {
    super.initState();
    // _htmlContent = widget.article['content'] ?? widget.article['textContent'] ?? "";
    // _title = widget.article['title'] ?? '';
    // // Combine title with content
    // final combinedContent = _title.isNotEmpty 
    //     ? '<h2 style="text-align: center; margin-bottom: 20px;">${_title}</h2>\n$_htmlContent'
    //     : _htmlContent;
    // _htmlContent = combinedContent;
    // _highlightedHtml = _htmlContent;
    // _doc = html_parser.parse(_htmlContent); // Parse once, clean doc
    // _prepareWords();
    // _prepareSentences();
    // _configureTts();
    // _loadLanguages();
    //getAvailableLanguages();
  //Provider.of<TranslatingProvider>(context,listen: false).resetTranslateContent();
  final vpnStatusProvider = Provider.of<VpnStatusProvider>(context,listen: false);
  final readerProvider = Provider.of<ReaderProvider>(context,listen: false);


 WidgetsBinding.instance.addPostFrameCallback((_) {
    checkForNetwork(
      vpnStatusProvider,
      readerProvider,
      AppLocalizations.of(context)!,
    );
  });
//  Future.microtask(() {   /// This is the working one 
//    checkForNetwork(vpnStatusProvider,readerProvider,AppLocalizations.of(context)!);

//  },);

  }

checkForNetwork(VpnStatusProvider vpnStatusProvider,ReaderProvider readerProvider, AppLocalizations loc)async{
   
  _connectivity = Connectivity();
    _connectivitySubscription = _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((event) {
      if (!(event.contains(ConnectivityResult.wifi)) && !(event.contains(ConnectivityResult.mobile))) {
        vpnStatusProvider.setInternetStatus(true);
        vpnStatusProvider.setTTSStatus(true);
         readerProvider.stop();
       // _clearHighlight();
         showMessage(loc.youAreNotConnectedToInternet);
      }else{
        vpnStatusProvider.setInternetStatus(false);
        vpnStatusProvider.setTTSStatus(false);
       
      }
    });
}



  @override
  void dispose() {
    flutterTts.stop();
    _connectivitySubscription.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final width = MediaQuery.of(context).size.width;
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
    //final ttsProvider = Provider.of<TtsProvider>(context);
    //var webViewModel = Provider.of<WebViewModel>(context, listen: true);
    //var webViewController = webViewModel.webViewController;
    //var languageProvider = Provider.of<LanguageProvider>(context);
   // final translatingProvider = Provider.of<TranslatingProvider>(context);
    final readerProvider = Provider.of<ReaderProvider>(context);
    return SafeArea(
      child: Container(
        child: DraggableScrollableSheet(
          initialChildSize: 0.95,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return LayoutBuilder(builder: (context, constraint) {
              return Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border(
                      top: BorderSide(
                          color: themeProvider.darkTheme
                              ? Color(0xff42425F)
                              : Color(0xffDADADA),
                          width: 0.5)),
                  color: themeProvider.readerDarkTheme
                      ? Color(0xff171720)
                      : Color(0xffFFFFFF),
                ),
                child: 
                // Stack(
                //   children: [
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          margin: EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color:themeProvider.darkTheme ? Color(0xff171720)
                      : Color(0xffFFFFFF),
                      border: Border(bottom: BorderSide(color: themeProvider.darkTheme
                                    ? Color(0xff42425F)
                                    : Color(0xffDADADA),)),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
                          ),
                          child: Column(
                            children: [
                              vpnStatusProvider.changeReaderMenu
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        //SizedBox(width: 5,),
                                         GestureDetector(
                                          onTap: () {
                                            vpnStatusProvider
                                                .updateReaderMenu(false);
                                                readerProvider.stop();
                                                readerProvider.resetCurrentParagraphIndex();
                                            flutterTts.stop();
                                            //_clearHighlight();
                                                                                 },
                                           child: Padding(
                                             padding: const EdgeInsets.only(left: 20.0),
                                             child: SvgPicture.asset(
                                                     'assets/images/back.svg',
                                                     color: themeProvider.darkTheme ? Colors.white : Colors.black,
                                                   ),
                                           ),
                                          //  IconButton(
                                          //        onPressed: () {
                                          //   vpnStatusProvider
                                          //       .updateReaderMenu(false);
                                          //       readerProvider.stop();
                                          //       readerProvider.resetCurrentParagraphIndex();
                                          //   flutterTts.stop();
                                          //   //_clearHighlight();
                                          //                                        },
                                          //        icon: SvgPicture.asset(
                                          //          'assets/images/back.svg',
                                          //          color: themeProvider.readerDarkTheme ? Colors.white : Colors.black,
                                          //        ),
                                          //      ),
                                         ),
                                        // menuOptions('assets/images/back.svg',
                                        //     themeProvider, () {
                                        
                                        //   vpnStatusProvider
                                        //       .updateReaderMenu(false);
                                        //       readerProvider.stop();
                                        //   flutterTts.stop();
                                        //   //_clearHighlight();
                                        // }),
                                        Consumer<ReaderProvider>(
                                          builder: (context, readerProvider,_) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                        //                                  ElevatedButton(
                                        //   onPressed: readerProvider.isSpeaking || readerProvider.isTranslating ? null : readerProvider.startAutoPlay,
                                        //   child: Text('Play'),
                                        // ),
                                                menuOptions(
                                                    'assets/images/ai-icons/prev_enabled.svg',
                                                    themeProvider, readerProvider.currentParagraphIndex > 0 && readerProvider.isSpeaking
                            ? readerProvider.previousParagraph
                            : (){},
                            isDisabled: !readerProvider.isSpeaking || readerProvider.currentParagraphIndex == 0 
                                                  // vpnStatusProvider.isTTSDisabled ? (){} : ttsProvider.previousWord
                                                   ),
                                                menuOptions(
                                                       readerProvider.isSpeaking ? 'assets/images/ai-icons/Pause.svg' : 'assets/images/ai-icons/Play.svg',
                                                    themeProvider, vpnStatusProvider.isNoInternet ? (){} : readerProvider.isSpeaking && !vpnStatusProvider.isNoInternet ? readerProvider.pauseReader : readerProvider.resumeReader,
                                                    isDisabled: vpnStatusProvider.isNoInternet 
                                                    ),
                                                    
                                                   //vpnStatusProvider.isTTSDisabled ? (){} :ttsProvider.isPlaying ? ttsProvider.pause : ttsProvider.play),
                                                menuOptions(
                                                    'assets/images/ai-icons/end_enabled.svg',
                                                    themeProvider, readerProvider.currentParagraphIndex < readerProvider.paragraphs.length - 1 && readerProvider.isSpeaking
                            ? readerProvider.nextParagraph : (){},
                            isDisabled: !readerProvider.isSpeaking  || readerProvider.currentParagraphIndex == readerProvider.paragraphs.length - 1 // i added this and condition
                            ),
                                                   //vpnStatusProvider.isTTSDisabled ? (){} : ttsProvider.nextWord)
                                              ],
                                            );
                                          }
                                        ),
                                        Padding(
                                             padding: const EdgeInsets.only(right: 20.0),
                                             child: SvgPicture.asset(
                                                     'assets/images/back.svg',
                                                     color: Colors.transparent,
                                                   ),
                                           ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        
                                        
                            //             Consumer<ReaderProvider>(
                            //               builder: (context,readerProvider,_) {
                            //                 return 
                            //               //   readerProvider.isTranslating ?
                                        
                            //               //   SvgPicture.asset('assets/images/ai-icons/translate.svg',color: Colors.gr,)
                                            
                            //               // :  
                            //               PopupMenuButton<String>(
                            //                   icon: SvgPicture.asset(
                            //                     'assets/images/ai-icons/translate.svg',
                            //                     color: readerProvider.isTranslating ? Colors.grey :
                                                
                            //                      themeProvider.darkTheme
                            //                         ? Colors.white
                            //                         : Colors.black,
                            //                   ),
                            //                   enabled: !readerProvider.isTranslating,
                            //                   color: themeProvider.darkTheme
                            //                       ? const Color(0xff282836)
                            //                       : const Color(0xffF3F3F3),
                            //                   offset: Offset(width / 5.0, width / 7.2),
                            //                   surfaceTintColor: themeProvider.darkTheme
                            //                       ? const Color(0xff282836)
                            //                       : const Color(0xffF3F3F3),
                            //                   elevation: 2,
                            //                   shape: const RoundedRectangleBorder(
                            //                     borderRadius: BorderRadius.only(
                            //                       bottomLeft: Radius.circular(15.0),
                            //                       bottomRight: Radius.circular(15.0),
                            //                       topLeft: Radius.circular(15.0),
                            //                       topRight: Radius.circular(15.0),
                            //                     ),
                            //                   ),
                            // //                  onSelected:readerProvider.isTranslating
                            // // ? null : (value) async{
                            // //                                                 Navigator.pop(context);
                                        
                            // //                   await readerProvider.translateParagraphs(value);
                            // //                              // languageProvider.selectLanguage(value);
                            // //                                             // setState(() {
                            // //                                             //   selectedLocale = value;
                            // //                                             // });
                            // //                                           },
                            //                   itemBuilder: (context) => [
                            //                                             PopupMenuItem(
                            //                                 enabled: true,
                            //                                 child: SizedBox(
                            //                                   width: 200, // control width
                            //                                   height: 250, // control height
                            //                                   child: Scrollbar(
                            //                                     thumbVisibility: true,
                            //                                     child: ListView.builder(
                            //                                       itemCount: readerProvider.languages.length,
                            //                                       shrinkWrap: true,
                            //                                       padding: EdgeInsets.zero,
                            //                                       itemBuilder: (context, index) {
                            //                                         final entry = readerProvider.languages.entries.elementAt(index);
                            //                                     final isSelected = readerProvider.selectedLanguage == entry.key;
                            //                                         return InkWell(
                            //                                           onTap: ()async {
                            //                                             Navigator.of(context, rootNavigator: true).pop();
                            //                                     Future.microtask(() async {
                            //                                         await readerProvider.translateParagraphs(entry.key);
                            //                                             });
                            //                                           //  // if (value != null) {
                            //                                           //     await readerProvider.translateParagraphs(entry.key);
                            //                                           //   //}
                                                                        
                            //                                           //   //languageProvider.selectLanguage(entry.key);
                            //                                           //   Navigator.pop(context);
                            //                                             // translatingProvider.translateToSelectedLanguage(_highlightedHtml, languageProvider.selectedLocale);
                            //                                             // final langAvail = await flutterTts.isLanguageAvailable(languageProvider.selectedLocale);
                            //                                             // if(langAvail){
                            //                                             //   await flutterTts.setLanguage(languageProvider.selectedLocale);
                            //                                             // }else{
                            //                                             //   showMessage('TTS does not support this language');
                            //                                             // }
                            //                                              print('IS Selected Language ${readerProvider.selectedLanguage} is');
                            //                                             // setState(() {
                            //                                             //   selectedLocale = entry.key;
                            //                                             // });
                            //                                           },
                            //                                           child: Container(
                            //                                             decoration: BoxDecoration(
                            //                                                 color: isSelected ? themeProvider.darkTheme ? Color(0xff39394B) : Color(0xffFFFFFF) : Colors.transparent,
                            //                                                 borderRadius: BorderRadius.circular(3)
                            //                                               ),
                            //                                             child: Padding(
                            //                                               padding: const EdgeInsets.symmetric(
                            //                                                   vertical: 8.0, horizontal: 8.0),
                            //                                               child: Row(
                            //                                                 children: [
                                                                             
                                                                             
                            //                                                   Expanded(
                            //                                                                               child: Text(
                            //                                                                                 entry.value,
                            //                                                                                 overflow: TextOverflow.ellipsis,
                            //                                                                                 style: TextStyle(color: themeProvider.darkTheme ? Colors.white : Colors.black),
                            //                                                                               ),
                            //                                                   ),
                            //                                                    const SizedBox(width: 10),
                            //                                                    isSelected ? SvgPicture.asset('assets/images/tick.svg') : SizedBox.shrink()
                            //                                                 ],
                            //                                               ),
                            //                                             ),
                            //                                           ),
                            //                                         );
                            //                                       },
                            //                                       // children: languageProvider.localeToName.entries.map((entry) {
                            //                                       //   final isSelected = selectedLocale == entry.key;
                                                                    
                            //                                       // }).toList(),
                            //                                     ),
                            //                                   ),
                            //                                 ),
                            //                                             ),
                                                                      
                            //                   ]
                                              
                            //                 );
                            //               }
                            //             ),
                                        
                                        
                                        IconButton(
                                onPressed: () => readerProvider.isTranslating ? (){} : vpnStatusProvider
                                                .updateReaderMenu(true),
                                icon: SvgPicture.asset(
                                  'assets/images/ai-icons/read.svg',
                                  color: readerProvider.isTranslating ? Colors.grey : themeProvider.darkTheme ? Colors.white : Colors.black,
                                ),
                              ),
                                        
                                        
                                        // menuOptions(
                                        //     'assets/images/ai-icons/read.svg',
                                        //     themeProvider,
                                        //     () => readerProvider.isTranslating ? (){} : vpnStatusProvider
                                        //         .updateReaderMenu(true),
                                        //         isDisabled: readerProvider.isTranslating
                                                
                                        //         ),
                                        PopupMenuButton<String>(
                                          icon: SvgPicture.asset(
                                            'assets/images/ai-icons/font.svg',
                                            color: themeProvider.darkTheme
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                          color: themeProvider.darkTheme
                                              ? const Color(0xff282836)
                                              : const Color(0xffF3F3F3),
                                          offset: Offset(width / 3.8, width / 7.2), //Offset(width / 5.0, width / 7.2)
                                          surfaceTintColor: themeProvider.darkTheme
                                              ? const Color(0xff282836)
                                              : const Color(0xffF3F3F3),
                                          elevation: 2,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(15.0),
                                              bottomRight: Radius.circular(15.0),
                                              topLeft: Radius.circular(15.0),
                                              topRight: Radius.circular(15.0),
                                            ),
                                          ),
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              enabled: true,
                                              padding: EdgeInsets.zero,
                                              child: SizedBox(
                                                width: 223,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 8),
                                                      child: Text(
                                                        "Text Zoom",
                                                        style: TextStyle(
                                                            color: themeProvider
                                                                    .darkTheme
                                                                ? Colors.white
                                                                : Colors.black),
                                                      ),
                                                    ),
                                                    Consumer<VpnStatusProvider>(
                                                      builder: (context,
                                                          vpnStatusProvider, _) {
                                                        return SliderTheme(
                                                          data: SliderThemeData(
                                                            trackHeight: 3,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal: 8),
                                                            inactiveTrackColor:
                                                                themeProvider
                                                                        .darkTheme
                                                                    ? const Color(
                                                                        0xff363645)
                                                                    : const Color(
                                                                        0xffDADADA),
                                                            thumbShape:
                                                                const RoundSliderThumbShape(
                                                              enabledThumbRadius:
                                                                  6.0,
                                                              pressedElevation: 2.0,
                                                            ),
                                                            trackShape:
                                                                const RoundedRectSliderTrackShape(),
                                                            overlayShape:
                                                                const RoundSliderOverlayShape(
                                                              overlayRadius: 12.0,
                                                            ),
                                                          ),
                                                          child: Slider(
                                                            value: vpnStatusProvider
                                                                .fontSize,
                                                            min: 8.0,
                                                            max: 25.0,
                                                            activeColor:
                                                                const Color(
                                                                    0xff00BD40),
                                                            divisions: 120,
                                                            onChanged: (value) {
                                                              vpnStatusProvider
                                                                  .updateReaderContentFontSize(
                                                                      value);
                                                            },
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          percentageText(
                                                              themeProvider,
                                                              '50%'),
                                                          percentageText(
                                                              themeProvider,
                                                              '100%'),
                                                          percentageText(
                                                              themeProvider,
                                                              '200%'),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(height: 10),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        menuOptions(themeProvider.readerDarkTheme ? 'assets/images/ai-icons/reader_Dark_theme.svg' : 'assets/images/ai-icons/theme.svg',
                                            themeProvider, () {
                                          themeProvider.readerDarkTheme =
                                              !themeProvider.readerDarkTheme;
                                        }),
                                       Container(
                                        width: 20,
                                        height: 45,
                                         child: VerticalDivider(
                                                                   width: 1,
                                                                   indent: 10,
                                                                   endIndent: 10,
                                                                   thickness: 1.5,
                                                                   color: themeProvider.darkTheme ? Color(0xff42425F) : Color(0xffDADADA),
                                                                 ),
                                       ),
                                        menuOptions(
                                            'assets/images/ai-icons/clear.svg',
                                            themeProvider,
                                            () {
                                              Navigator.pop(context);
                                            }),
                                      ],
                                    ),
                              // Divider(
                              //   color: themeProvider.readerDarkTheme
                              //       ? Color(0xff42425F)
                              //       : Color(0xffDADADA),
                              // ),
                            ],
                          ),
                        ),
                        
                        Expanded(
                            child: Consumer<ReaderProvider>(
              
              builder: (context,readerProvider,_) {
                return ListView.builder(
                  controller:  _scrollController,
                  //shrinkWrap: true,
                  itemCount: readerProvider.paragraphs.length,
                  itemBuilder: (_, index) {
                    final paragraph = readerProvider.paragraphs[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16,left:10,right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            paragraph.translatedText,
                             textAlign: index == 0 ? TextAlign.center : TextAlign.left,
                            style: TextStyle(
                              
                              fontSize:index == 0 ? vpnStatusProvider.fontSize + 12 : vpnStatusProvider.fontSize,
                              fontWeight: index == readerProvider.currentParagraphIndex || index == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color:
                              // index == 0 && index != readerProvider.currentParagraphIndex 
                              //     ? Color(0xff244980) 
                              //     : 
                                  index == readerProvider.currentParagraphIndex && readerProvider.isSpeaking ?  Color(0xff00BD40) : themeProvider.readerDarkTheme ? Colors.white : Colors.black,
                            ),
                          ),
                          if (paragraph.images.isNotEmpty)
                            ...paragraph.images.map((img) => ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                    img['src']!,
                                    width:double.infinity, //150,
                                    height:MediaQuery.of(context).size.height*1/3, //150,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Text(img['alt'] ?? 'Image failed'),
                                  ),
                            )),
                        ],
                      ),
                    );
                  },
                );
               
               // only with paragraph (working)
              
                // return ListView.builder(
                //   itemCount: readerProvider.paragraphs.length,
                //   itemBuilder: (context, index) {
                //     return Padding(
                //       padding: EdgeInsets.only(bottom: 8.0),
                //       child: Text(
                //         readerProvider.paragraphs[index],
                //         textAlign: index == 0  ? TextAlign.center : TextAlign.left,
                //         style: TextStyle(
                //           fontSize: index == 0 ? 20: 16,
                //           fontWeight: index == readerProvider.currentParagraphIndex || index == 0 ? FontWeight.bold : FontWeight.w400,
                //           fontFamily: 'Arial',
                //           color: index == 0 && index != readerProvider.currentParagraphIndex ? Color(0xff244980) : index == readerProvider.currentParagraphIndex  ?  Colors.blue : Colors.white,
                //         ),
                //       ),
                //     );
                //   },
                // );
              }
                            ),
              //               Html(
              //   data:translatingProvider.translatedContent ?? _highlightedHtml,
              //   style: {
              //     "body": Style(
              //       fontSize: FontSize(vpnStatusProvider.fontSize),
              //       textAlign: TextAlign.justify,
              //       lineHeight: LineHeight(1.5),
              //     ),
              //     "h2": Style(
              //       fontSize: FontSize(20.0),
              //       fontWeight: FontWeight.bold,
              //       textAlign: TextAlign.center,
              //       margin: Margins.only(bottom: 20),
              //     ),
              //     "mark": Style(backgroundColor: Color(0xff00BD40), color: Colors.white),
              //     "a mark": Style(backgroundColor: Color(0xff00BD40), color: Colors.white), // Ensure highlighting works inside links
              //     "img": Style(
              //       display: Display.block,
              //       margin: Margins.symmetric(horizontal: 12, vertical: 12),
              //       height: Height(MediaQuery.of(context).size.height * 1 / 3),
              //       width: Width(MediaQuery.of(context).size.width),
              //       padding: HtmlPaddings(right: HtmlPadding(40)),
              //     ),
              //   },
              //   onLinkTap:(url, attributes, element) {
              //     if(url != null){
              //        webViewController!
              //               .loadUrl(urlRequest: URLRequest(url: WebUri(url)));
              //     Navigator.pop(context);
              
              //     }
              //   },
              // ),
                         // ),
                        ),
                      ],
                    ),
                //     readerProvider.isTranslating
                //         ? Center(
                //             child: CircularProgressIndicator(color: Colors.green))
                //         : Container(),
                //   ],
                // ),
              );
            });
          },
        ),
      ),
    );
  }

  Text percentageText(DarkThemeProvider themeProvider, String text) => Text(
        text,
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: themeProvider.darkTheme ? Colors.white : Colors.black),
      );

  IconButton menuOptions(
      String icon, DarkThemeProvider themeProvider, VoidCallback onPressed,{bool isDisabled = false}) {
    return IconButton(
      onPressed: onPressed,
      icon: SvgPicture.asset(
        icon,
        color: isDisabled ? Colors.grey : themeProvider.darkTheme ? Colors.white : Colors.black,
      ),
    );
  }
}
