
import 'dart:convert';
import 'dart:typed_data';

import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/locale_provider.dart';
import 'package:beldex_browser/src/browser/app_bar/sample_popup.dart';
import 'package:beldex_browser/src/browser/app_bar/search_screen.dart';
import 'package:beldex_browser/src/browser/custom_popup_dialog.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/search_engine_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/pages/reading_mode/reader_provider.dart';
import 'package:beldex_browser/src/browser/pages/reading_mode/reader_screen.dart';
import 'package:beldex_browser/src/browser/pages/search_engine/add_searchengine_provider.dart';
import 'package:beldex_browser/src/browser/pages/settings/app_language_screen.dart';
import 'package:beldex_browser/src/browser/pages/settings/search_settings_page.dart';
import 'package:beldex_browser/src/browser/providers/appbar_position_provider.dart';
import 'package:beldex_browser/src/browser/providers/bottom_nav_bar_provider.dart';
import 'package:beldex_browser/src/browser/providers/tab_provider.dart';
import 'package:beldex_browser/src/browser/tab_popup_menu_actions.dart';
import 'package:beldex_browser/src/browser/util.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/tts_provider.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

TextEditingController? findOnPageController = TextEditingController();

bool checkSearchEngineInUrl(
  List<SearchEngineModel> firstList,
  List<SearchEngineModel> secondList,
  WebUri givenUrl,
) {
  final urlString = givenUrl.toString().toLowerCase();

  // // Check only HTTPS urls
  // if (!urlString.startsWith('https://')) {
  //   return false;
  // }

  // Check first list
  for (final engine in firstList) {
    final host = Uri.parse(engine.url).host.toLowerCase();

    if (urlString.contains(host)) {
      return true;
    }
  }

  // Check second list
  for (final engine in secondList) {
    final host = Uri.parse(engine.url).host.toLowerCase();

    if (urlString.contains(host)) {
      return true;
    }
  }

  return false;
}









class FlexibleAppbar extends StatefulWidget implements PreferredSizeWidget {
  const FlexibleAppbar({super.key, this.preferredSize  = const Size.fromHeight(kToolbarHeight)});

  @override
  State<FlexibleAppbar> createState() => _FlexibleAppbarState();


   @override
  final Size preferredSize;
}

class _FlexibleAppbarState extends State<FlexibleAppbar> with SingleTickerProviderStateMixin {


TextEditingController? _searchController = TextEditingController();
  TextEditingController? _homeSerachController = TextEditingController();
  Uint8List? imageScreenshot;
  FocusNode? _focusNode, _focusNode2;
  String searchText = '';
  GlobalKey tabInkWellKey = GlobalKey();

  Duration customPopupDialogTransitionDuration =
      const Duration(milliseconds: 300);
  CustomPopupDialogPageRoute? route;
  List<SearchShortcutListModel> selectedListItems = [];
  late List<SearchShortcutListModel> searchShortcutItems = [];
  dynamic pageTitles = '';
  String favIcon = '';
  OutlineInputBorder outlineBorder = const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent, width: 0.0),
    borderRadius: BorderRadius.all(
      Radius.circular(50.0),
    ),
  );

  late List<ContextMenuButtonItem> buttonItems = [];
  late EditableTextState editableState;


   final FlutterTts flutterTts = FlutterTts();

    bool _isReporting = false;

     bool _isSharing = false;
//  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode?.addListener(() async {
      if (_focusNode != null &&
          !_focusNode!.hasFocus &&
          _searchController != null &&
          _searchController!.text.isEmpty) {
        var browserModel = Provider.of<BrowserModel>(context, listen: true);
        var webViewModel = browserModel.getCurrentTab()?.webViewModel;
        var webViewController = webViewModel?.webViewController;
        _searchController!.text =
            (await webViewController?.getUrl())?.toString() ?? "";
            browserModel.updateUserInput(_searchController!.text);
      }
    });
    Provider.of<BrowserModel>(context, listen: false)
        .initSharedPreferences();
           // _configureTts(context);
    //  loadSearchShortcutListItems();
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _focusNode = null;
    _focusNode2?.dispose();
    _focusNode2 = null;
    _searchController?.dispose();
    _searchController = null;
    findOnPageController?.dispose();
    findOnPageController = null;
    searchShortcutItems.clear();
    buttonItems.clear();
    super.dispose();
  }

  List<SearchShortcutListModel> getSelectedItems() {
    print('all the items --> ${searchShortcutItems[0].name}');
    return searchShortcutItems.where((item) => item.isActive).toList();
  }











  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final browserModel = Provider.of<BrowserModel>(context);
    final settings = browserModel.getSettings();
    final loc = AppLocalizations.of(context)!;
             final addEngineProvider =
        Provider.of<AddSearchEngineProvider>(context, listen: true);
    final appBarPositionProvider = Provider.of<AppBarPositionProvider>(context);
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
    final selectedSessionEngines =
        addEngineProvider.selectedSessionEngines;
 final theme = Theme.of(context);
    var webViewModel = Provider.of<WebViewModel>(context, listen: true);
    var webViewController = webViewModel.webViewController;
 final groupProvider = Provider.of<GroupProvider>(context);
        return  Selector<WebViewModel, WebViewModel>(
        selector: (context, webViewModel) => webViewModel,
        builder: (context, webViewModel, child) {
          // if (url == null) {
          //   print('this search controller is calling');
          //   _searchController?.text = "";
          // }
final domains = browserModel.domainList;

for (var item in domains) {
  print("RESOLVER DOMAINS ${item['domain']}");
  print("RESOLVER DOMAINS value ${item['resolvedValue']}");
  print("RESOLVER DOMAINS REDIRECTS ${item['redirectValue']}");
  print("RESOLVER DOMAINS TYPE ${item['type']}");
}



// final displayText =
//       webViewModel.url?.toString() ??
//       "";
//       final host = webViewModel.url?.host ?? '';

//   if (_focusNode != null && !_focusNode!.hasFocus) {
//     // if(isIpAddress(webViewModel.url.toString())){
//     //         _searchController?.text = webViewModel.getDomainFromIp(host) ?? ''; //webViewModel.resolveData; //'metaverse';
//     //       }else
//     final currentUrl = webViewModel.url?.toString() ?? "";

// if(currentUrl.isNotEmpty && !(currentUrl.toString().startsWith('https://') && checkSearchEngineInUrl(SearchEngines, selectedSessionEngines, webViewModel.url!))){
//   _searchController?.text =
//     currentUrl.isEmpty
//         ? ""
//         : browserModel.getDisplayUrl(currentUrl);

// }else{
//     _searchController?.text = currentUrl;
// }



final displayText =
      webViewModel.url?.toString() ??
      "";
      final host = webViewModel.url?.host ?? '';

  if (_focusNode != null && !_focusNode!.hasFocus) {
    // if(isIpAddress(webViewModel.url.toString())){
    //         _searchController?.text = webViewModel.getDomainFromIp(host) ?? ''; //webViewModel.resolveData; //'metaverse';
    //       }else
    final currentUrl = webViewModel.url?.toString() ?? "";

if(currentUrl.isNotEmpty && !(currentUrl.toString().startsWith('https://') && checkSearchEngineInUrl(SearchEngines, selectedSessionEngines, webViewModel.url!))){
  _searchController?.text =
    currentUrl.isEmpty
        ? ""
        : browserModel.getDisplayUrl(currentUrl);
        WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      browserModel.updateUserInput(_searchController!.text);
    }
  });

}else{
    _searchController?.text = currentUrl;
   WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      browserModel.updateUserInput(_searchController!.text);
    }
  });
}










  // _searchController?.text = webViewModel.getDisplayUrl(webViewModel.url.toString());
    //_searchController?.text = displayText;
   print('Return the IP URL 1 $currentUrl -- ${_searchController?.text}');
 }

          return browserModel.isFindingOnPage ? 
              findOnPage(themeProvider,theme,appBarPositionProvider)
          
         : (appBarPositionProvider.selectedPosition == AppBarPosition.top && groupProvider.totalOpenTabsCount != 0 //browserModel.webViewTabs.isNotEmpty 
         && vpnStatusProvider.canShowHomeScreen == false) ? webViewAppBar(themeProvider,theme,appBarPositionProvider) : Container();
          //:
          
        // appBarPositionProvider.selectedPosition == AppBarPosition.top || vpnStatusProvider.canShowHomeScreen ?  Container(
        //                     height: 50,
        //                     decoration: BoxDecoration(
        //                       color: themeProvider.darkTheme ? Color(0xff111111) : Color(0xffFFFFFF).withOpacity(0.6),
        //                       border: Border.all(color: themeProvider.darkTheme ? Color(0xff444444) : Color(0xffD4D4D4))
        //                     ),
        //                     padding: EdgeInsets.only(right: 10),
        //                     child: Row(
        //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                       children: [
        //                         Container(
        //                           margin: EdgeInsets.all(7),
        //                           decoration: BoxDecoration(
        //                             color: themeProvider.darkTheme ? Color(0xff1A1A1A) : Color(0xffEBEBEB),
        //                             border: Border.all(color:themeProvider.darkTheme ? Color(0xff333333) : Color(0xffC0C0C0))),
        //                           child: SearchSettingsPopupList(
        //                                                     browserModel: browserModel,
        //                                                     browserSettings: settings,
        //                                                   ),
        //                         ),
        //                         InkWell(
        //                           onTap: (){
        //                             Navigator.push(
        //                     context,
        //                     MaterialPageRoute(
        //                         builder: (context) => SearchScreen(
        //                               controller: _searchController!,
        //                               browserModel: browserModel,
        //                               settings: settings,
        //                               webViewController: webViewController,
        //                               webViewModel: webViewModel,
        //                               //  pageTitle:pageTitles ,//pageTitle,
        //                               //  favIcons:favIcon, //favIcon,
        //                             )));

        //                           },
        //                           child: Text(loc.searchOrEnterAddress, style: TextStyle(fontFamily: 'Roboto',fontSize: 14,color:Color(0xff737373)),)),
        //                         SvgPicture.asset('assets/images/ai-icons/new/search_tab_white.svg',color: themeProvider.darkTheme ? Color(0xffffffff) : Color(0xff0B0B0B),)
        //                       ],
        //                     ),
        //                   ) : appBarPositionProvider.selectedPosition == AppBarPosition.bottom ? Container(
        //                         child: PreferredSize(preferredSize: Size.fromHeight(150),
        //                          child: LayoutBuilder(builder: (context, constraints){
        //                           return Container(
        //                             color: Colors.green,
        //                           );
        //                          })),

        //                   ) : Container();
          // browserModel.isFindingOnPage
          //         ? findOnPageAppBar(themeProvider,theme,appBarPositionProvider)
          //         : webViewAppBar(
          //             themeProvider,theme,appBarPositionProvider);
        });
           
        
  }


    PreferredSize findOnPage(DarkThemeProvider themeProvider,ThemeData theme,AppBarPositionProvider appBarPositionProvider){ 
      var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var webViewModel = browserModel.getCurrentTab()?.webViewModel;
    var webViewModelPro = Provider.of<WebViewModel>(context, listen: false);
    var webViewController = webViewModelPro.webViewController;
    final loc = AppLocalizations.of(context)!;
    var findInteractionController = webViewModel?.findInteractionController;
   // final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
    isFullScreen(webViewController);

    return PreferredSize(
                preferredSize: Size.fromHeight(150),
                child: LayoutBuilder(
                  builder: (context,constraints) {
                    return Container(
                      height:45, //constraints.maxHeight/1.6, //45,
            width: double.infinity,
            margin: EdgeInsets.only( top:appBarPositionProvider.selectedPosition ==
      AppBarPosition.bottom ? 0 : 40,
                left: 10, right: 10, bottom: 4
            ),padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: //webViewModel.isIncognitoMode ? Color(0xff040404) :
                    themeProvider.darkTheme
                        ?const Color(0xff111111)
                        :const Color(0xffFFFFFF),
                        border: Border.all(color: themeProvider.darkTheme ? Color(0xff444444) : Color(0xffD4D4D4))
                //borderRadius: BorderRadius.circular(8)
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                                        //width: constraint.maxWidth / 1.5,
                                        // color: Colors.yellow,
                                        child: TextField(
                      key: const ValueKey('findOnPageField'),
                      onSubmitted: (value) {
                        findInteractionController?.findAll(find: value);
                      },
                      keyboardType: TextInputType.url,
                      focusNode: _focusNode,
                      autofocus: true,
                      controller: findOnPageController,
                      textInputAction: TextInputAction.go,
                                          magnifierConfiguration: TextMagnifierConfiguration.disabled,
                      // contextMenuBuilder: (context, editableTextState) {
                      //   return Text('TEXTEEEEES');
                      // },
                      contextMenuBuilder: (context, editableTextState) {
                        buttonItems = editableTextState.contextMenuButtonItems;
                      
                        editableState = editableTextState;
                      
                        buttonItems.clear(); // Clear all default options
                        if (findOnPageController!.text
                                .isEmpty //|| _searchController.selection != TextSelection.collapsed(offset: _searchController.selection.baseOffset)
                            ) {
                          // Clipboard.getData('text/plain').then((clipboardContent) {
                          //    if(clipboardContent != null && clipboardContent.text!.isNotEmpty){
                          buttonItems.add(ContextMenuButtonItem(
                              label:loc.paste, //'Paste',
                              onPressed: () {
                                Clipboard.getData('text/plain').then((value) {
                                  if (value != null && value.text != null) {
                                    final text = findOnPageController!.text;
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
                                    findOnPageController!.text = newText;
                                    final newSelection = TextSelection.collapsed(
                                      offset:
                                          selection.start + value.text!.length,
                                    );
                                    findOnPageController!.selection =
                                        newSelection;
                                    editableTextState.hideToolbar(false);
                                  }
                                });
                              }));
                        } else {
                          buttonItems.clear();
                          buttonItems.add(ContextMenuButtonItem(
                            label:loc.cut,// 'Cut',
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
                                    findOnPageController!.text;
                                final String newFindOnPageText =
                                    findOnPageText.replaceRange(
                                        selection.start, selection.end, '');
                      
                                print(
                                    'Cut value Editable Text ---> $findOnPageText -- $newFindOnPageText -- $newText');
                                findOnPageController!.text =
                                    findOnPageText; //newFindOnPageText;
                              }
                      
                              // // Clipboard.setData(ClipboardData(text: editableTextState.textEditingValue.text));
                              // editableTextState
                              //     .cutSelection(SelectionChangedCause.tap);
                              // findOnPageController!.clear();
                              // //editableTextState.hideToolbar(false);
                            },
                          ));
                      
                          buttonItems.add(ContextMenuButtonItem(
                            label:loc.copy,// 'Copy',
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
                              label:loc.selectAll,// 'Select All',
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
                            label:loc.paste,// 'Paste',
                            onPressed: () {
                              Clipboard.getData('text/plain').then((value) {
                                if (value != null && value.text != null) {
                                  final text = findOnPageController!.text;
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
                                  findOnPageController!.text = newText;
                                  final newSelection = TextSelection.collapsed(
                                    offset: selection.start + value.text!.length,
                                  );
                                  findOnPageController!.selection = newSelection;
                                  editableTextState.hideToolbar(false);
                                }
                              });
                              // Clipboard.getData('text/plain').then((value) {
                              //   if (value != null) {
                              //     _searchController.text += value.text!;
                              //     editableTextState.hideToolbar(false);
                              //     //_focusNode!.unfocus();
                              //   }
                              // });
                            },
                          ));
                        }
                        return AdaptiveTextSelectionToolbar.buttonItems(
                          anchors: editableTextState.contextMenuAnchors,
                          buttonItems: buttonItems,
                        );
                      },
                       onChanged: (value) {
                        if(value.isEmpty){
                          editableState.hideToolbar(true);
                        }
                      },
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(
                              top: 5.0, left: 15, right: 10.0, bottom: 10.0),
                          border: InputBorder.none,
                          hintText:"${loc.findOnPage}...",  //"Find on page ...",
                          hintStyle: TextStyle(
                              color:const Color(0xff8D8D8D),
                             // fontSize: 14.0,
                              fontWeight: FontWeight
                                  .normal), //const TextStyle(fontSize: 14.0,fontWeight: FontWeight.normal),
                          ),
                      style: theme.textTheme.bodyMedium,
                                        ),
                                      ),
                    ),



Container(
                        // color: Colors.blue,
                        width: 30,
                        child: IconButton(
                          icon: Icon(Icons.keyboard_arrow_up,size :15),
                          onPressed: () {
                            findInteractionController?.findNext(forward: false);
                          },
                        ),
                      ),
                      SizedBox(
                        //color: Colors.yellow,
                        width: 30,
                        child: IconButton(
                          icon: Icon(Icons.keyboard_arrow_down,size :15),
                          onPressed: () {
                            findInteractionController?.findNext(forward: true);
                          },
                        ),
                      ),
                     // Spacer(),
                      Container(
                        // color: Colors.pink,
                        width: 30,
                        child: IconButton(
                          icon: Icon(Icons.close,size :15),
                          onPressed: () {
                            findInteractionController?.clearMatches();
                            findOnPageController?.text = "";

                            //if (widget.hideFindOnPage != null) {
                              browserModel.updateFindOnPage(false);
                             //}
                          },
                        ),
                      ),





                  ],
                ),
                    );
                  }
                ));

    }

  isFullScreen(InAppWebViewController? webviewController) async {
    if (await webviewController!.isInFullscreen()) {
      _focusNode!.unfocus();
    }
  }

PreferredSize webViewAppBar(DarkThemeProvider themeProvider,ThemeData theme,AppBarPositionProvider appBarPositionProvider){
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context,listen: false);
    var webViewModel = Provider.of<WebViewModel>(context, listen: true);
    final localeProvider = Provider.of<LocaleProvider>(context,listen: false);
    final loc = AppLocalizations.of(context)!;
    var webViewController = webViewModel.webViewController;
    final ttsProvider = Provider.of<TtsProvider>(context,listen: false);
    final groupProvider = Provider.of<GroupProvider>(context);
    return PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: LayoutBuilder(builder: (context, constraints) {
          return Container(
            height:45, //constraints.maxHeight/1.6, //45,
            width: double.infinity,
            margin: EdgeInsets.only( top:appBarPositionProvider.selectedPosition ==
      AppBarPosition.bottom ? 0 : 40,
                left: 10, right: 10, bottom: 4
            ),
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: //webViewModel.isIncognitoMode ? Color(0xff040404) :
                    themeProvider.darkTheme
                        ?const Color(0xff111111)
                        :const Color(0xffFFFFFF),
                        border: Border.all(color: themeProvider.darkTheme ? Color(0xff444444) : Color(0xffD4D4D4))
                //borderRadius: BorderRadius.circular(8)
                ),
            child: LayoutBuilder(builder: (context, constraint) {

              return Row(
                children: [
              //     Visibility(
              //       visible: browserModel.webViewTabs.isEmpty == false && vpnStatusProvider.canShowHomeScreen == false,
              //       child:GestureDetector(
              //           onTap: ()async{
              //             vpnStatusProvider.updateCanShowHomeScreen(true);
              //             await webViewController?.stopLoading();
              //             vpnStatusProvider.updateFAB(false);
              //            ttsProvider.updateTTSDisplayStatus(false);

              //     //            await webViewController?.evaluateJavascript(
              //     // source: "document.activeElement.blur();");
              //           if (await webViewController?.getSelectedText() != null) {
              //   // await webViewController?.evaluateJavascript(
              //   //     source: "window.getSelection().removeAllRanges();"
              //   //      );

              //         await webViewController?.evaluateJavascript(source: """
                    
              //       //Close keyboard if open
              //       document.activeElement.blur();

              //      // Close context menu
              //      window.getSelection().removeAllRanges();

              //     document.querySelectorAll('video').forEach(video => video.pause());

              //     // Pause all HTML5 audio elements
              //     document.querySelectorAll('audio').forEach(audio => audio.pause());

              //     // Pause YouTube videos
              //     var iframes = document.querySelectorAll('iframe');
              //     iframes.forEach(iframe => {
              //       var src = iframe.src;
              //       if (src.includes('youtube.com/embed')) {
              //         iframe.contentWindow.postMessage('{"event":"command","func":"pauseVideo","args":""}', '*');
              //       }
              //     });
              //   """);
              // }
              //            final ByteData data = await rootBundle.load('assets/images/screen-shot.png');
              //             setState(() {
              //               imageScreenshot = data.buffer.asUint8List();
              //             });
                      
              //             // webViewController!.loadData(data: homeHtmlContent,
              //             // mimeType: 'text/html',
              //             // encoding: 'utf-8'
              //             // );
              //             //browserModel.closeAllTabs();
              //           },
              //            child: Container(
              //               //margin: EdgeInsets.symmetric(horizontal: 8,vertical: 8),
              //                   //  height: 33,
              //                   //  width: 33,
              //                    decoration: BoxDecoration(
              //                        color:Colors.transparent,
              //                            //themeProvider.darkTheme ? Color(0xff39394B) : Color(0xffffffff),
              //                       // borderRadius: BorderRadius.circular(5)
              //                        ),
              //                    child: Row(
              //                      mainAxisAlignment: MainAxisAlignment.center,
              //                      children: [
              //                   // browserModel.webViewTabs.isEmpty == false && widget.canHomeShown == true
              //                     SvgPicture.asset( 'assets/images/ai-icons/new/Home.svg', color: Color(0xff8D8D8D),),
                         
              //                      ],
              //                    ),
              //                  ),
              //          ) 
              //     ),
                   
                      Visibility(
                          visible: vpnStatusProvider.canShowHomeScreen ? false: webViewModel.url != null ? true : false,
                          // webViewModel.url != null ||
                          //     webViewModel.isIncognitoMode,
                          child: Selector<WebViewModel, bool>(
                              selector: (context, webViewModel) =>
                                  webViewModel.isSecure,
                              builder: (context, isSecure, child) {
                                var image =  themeProvider.darkTheme
                                        ? 'assets/images/https.svg'
                                        : 'assets/images/https_white_theme.svg';
                                if (webViewModel.isIncognitoMode) {
                                  print('Incognito ----> ');
                                  image = Util.urlIsSecure(webViewModel.url as Uri) == false 
                                  //!(webViewModel.isSecure)
                                      ? 'assets/images/private_http.svg'
                                      : 'assets/images/privatetab.svg';
                                      print('Incognito ----? $image');
                                } else if (isSecure &&
                                    !(webViewModel.isIncognitoMode)) {
                                  if (webViewModel.url != null &&
                                      webViewModel.url!.scheme == "file") {
                                    image = themeProvider.darkTheme
                                           ? 'assets/images/Web Archieves.svg'
                                           : 'assets/images/web_arc-black.svg';
                                  } else if(isSecure && browserModel.isUrlInDomainList(webViewModel.url.toString())){
                                    image = themeProvider.darkTheme
                                      ? 'assets/images/http.svg'
                                      : 'assets/images/http_white_theme.svg';
                                  }else {
                                    image = themeProvider.darkTheme
                                        ? 'assets/images/https.svg'
                                        : 'assets/images/https_white_theme.svg';
                                  }
                                } else if ((webViewModel.url != null &&
                                        (isSecure == false)) &&
                                    !webViewModel.isIncognitoMode) {
                                       if(webViewModel.url.toString().endsWith('.bdx') || webViewModel.url.toString().endsWith('.bdx/')){
                                       image = themeProvider.darkTheme
                                        ? 'assets/images/mnLock-dark-theme.svg'
                                        : 'assets/images/mnLock-white-theme.svg';
                                    }else{
                                       image = themeProvider.darkTheme
                                      ? 'assets/images/http.svg'
                                      : 'assets/images/http_white_theme.svg';
                                    }
                                  
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: SvgPicture.asset(
                                    image,
                                    height: constraint.maxWidth / 16.5,
                                    width: constraint.maxWidth / 16.5,
                                  ),
                                );
                              }),
                        ),
 SizedBox(width: 5,),
                                                      Expanded(
                                                        child: Container(
                                                                            // width: webViewModel.url != null && vpnStatusProvider.canShowHomeScreen == false && ttsProvider.canTTSDisplay == false
                                                                            //     ? constraint.maxWidth / 2
                                                                            //    : ttsProvider.canTTSDisplay && browserModel.webViewTabs.isNotEmpty ? constraint.maxWidth / 2.1 
                                                                            //       : constraint.maxWidth / 1.8,
                                                                            child: GestureDetector(
                                                                              onTap: () async {
                                                                                if (webViewController != null) {
                                                                          webViewController.evaluateJavascript(source: "hideFooter();");
                                                                            }
                                                                                Navigator.push(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                        builder: (context) => SearchScreen(
                                                                                              controller: _searchController!,
                                                                                              browserModel: browserModel,
                                                                                              settings: settings,
                                                                                              webViewController: webViewController,
                                                                                              webViewModel: webViewModel,
                                                                                              //  pageTitle:pageTitles ,//pageTitle,
                                                                                              //  favIcons:favIcon, //favIcon,
                                                                                            )));
                                                        
                                                                                //  if (_searchTextController.text.isNotEmpty) {
                                                                                //   setState(() {
                                                                                //     _searchController = _searchTextController;
                                                                                //   });
                                                                                // }
                                                                              },
                                                                              child:
                                                                              vpnStatusProvider.canShowHomeScreen ?
                                                        
                                                                               TextField(
                                                                                readOnly: true,
                                                                                enabled: false,
                                                                                canRequestFocus: false,
                                                                                // onSubmitted: (value) {
                                                                                //   if(canShowExpandedTextField){
                                                                                //      var url = WebUri(value.trim());
                                                                                //   if (!url.scheme.startsWith("http") &&
                                                                                //       !Util.isLocalizedContent(url)) {
                                                                                //     url = WebUri(settings.searchEngine.searchUrl + value);
                                                                                //   }
                                                        
                                                                                //   if (webViewController != null) {
                                                                                //     webViewController.loadUrl(
                                                                                //         urlRequest: URLRequest(url: url));
                                                                                //   } else {
                                                                                //     addNewTab(url: url);
                                                                                //     webViewModel.url = url;
                                                                                //   }
                                                                                //   canShowExpandedTextField = false;
                                                                                //   }
                                                        
                                                                                // },
                                                                                keyboardType: TextInputType.url,
                                                                                focusNode: _focusNode,
                                                                                autofocus: false,
                                                                                controller: _homeSerachController,
                                                                                textInputAction: TextInputAction.go,
                                                                                decoration: InputDecoration(
                                                                                    contentPadding: const EdgeInsets.only(
                                                                                        top: 5.0, right: 10.0, bottom: 10.0),
                                                                                    border: InputBorder.none,
                                                                                    hintText: loc.searchOrEnterAddress, // "Search or enter Address",
                                                                                    hintStyle: TextStyle(
                                  color:const Color(0xff737373),fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600) //const TextStyle(fontSize: 14.0,fontWeight: FontWeight.normal),
                              ),
                          style: theme.textTheme.bodyMedium!.copyWith(fontSize: 12,fontWeight: FontWeight.w600, fontFamily: 'Roboto',color: themeProvider.darkTheme ? Colors.white : Colors.black),
                                                                                //isLengthyLanguageInList(localeProvider.selectedLanguage) ? theme.textTheme.bodyMedium!.copyWith(fontSize: 9) : theme.textTheme.bodyMedium,
                                                                              ):
                                                                              TextField(
                                                                                readOnly: true,
                                                                                enabled: false,
                                                                                canRequestFocus: false,
                                                                                // onSubmitted: (value) {
                                                                                //   var url = WebUri(value.trim());
                                                                                //   if (!url.scheme.startsWith("http") &&
                                                                                //       !Util.isLocalizedContent(url)) {
                                                                                //     url = WebUri(settings.searchEngine.searchUrl + value);
                                                                                //   }
                                                                              
                                                                                //   if (webViewController != null) {
                                                                                //     webViewController.loadUrl(
                                                                                //         urlRequest: URLRequest(url: url));
                                                                                //   } else {
                                                                                //     addNewTab(url: url);
                                                                                //     webViewModel.url = url;
                                                                                //   }
                                                                                // },
                                                                                keyboardType: TextInputType.url,
                                                                                focusNode: _focusNode,
                                                                                autofocus: false,
                                                                                controller: _searchController,
                                                                                textInputAction: TextInputAction.go,
                                                                                decoration: InputDecoration(
                                                                                    contentPadding: const EdgeInsets.only(
                                                                                        top: 5.0, right: 10.0, bottom: 10.0),
                                                                                    border: InputBorder.none,
                                                                                    hintText:loc.searchOrEnterAddress, // "Search or enter Address",
                                                                                    hintStyle: TextStyle(
                                                                                        color: themeProvider.darkTheme
                                                                                            ? const Color(0xff6D6D81)
                                                                                            : const Color(0xff6D6D81),
                                                                                     fontWeight: FontWeight.w600) //const TextStyle(fontSize: 14.0,fontWeight: FontWeight.normal),
                                                                                    ),
                                                                                style:TextStyle(fontFamily: 'Roboto',fontWeight: FontWeight.w600,fontSize: 12,color: themeProvider.darkTheme ? Colors.white : Colors.black),
                                                                                //isLengthyLanguageInList(localeProvider.selectedLanguage) ? theme.textTheme.bodyMedium!.copyWith(fontSize: 9) : theme.textTheme.bodyMedium,
                                                                              ),
                                                                            ),
                                                                          ),
                                                      ),
                                                      Container(
                    width: 20,
                    child: Visibility(
                          visible:ttsProvider.canTTSDisplay && groupProvider.totalOpenTabsCount != 0, //browserModel.webViewTabs.isNotEmpty,
                          child: GestureDetector(
                            onTap: ()async{
                              final article = await extractReadableContent(webViewController);
                           hideSelectionMenu(webViewController!);
if (article != null) {
   showModalBottomSheet(
      context: context,
      isScrollControlled: true,
     builder: (context){

     return ChangeNotifierProvider(
      create: (context) => ReaderProvider(
        (article['title'] != null && article['title'].toString().isNotEmpty)
                                      ? '<h2>${article['title']}</h2>${article['content'] ?? article['textContent'] ?? ""}'
                                      : article['content'] ?? article['textContent'] ?? ""
       
        ),
      
         child: SpeechHtmlScreen(article: article,)
      
     ); //TtsHtmlScreen(article: article,); //ReadingModeScreen(article: article,); //DraggableAISheet();
          //return BeldexAiScreen();
     });
} else {
  debugPrint("No article extracted");
}

                            },
                            child: Container(
                              width: 20,
                              child: themeProvider.darkTheme ?  SvgPicture.asset('assets/images/ai-icons/reading_mode.svg') : SvgPicture.asset('assets/images/ai-icons/Reading_mode_wht.svg'))) ),
                    
                   ),

//tabList(themeProvider, theme)

                 
                ],
              );
//               return Row(
//                 children: [
//                   SizedBox(
//                     width:  webViewModel.url != null && vpnStatusProvider.canShowHomeScreen == false 
//                         ? constraint.maxWidth / 4.2
//                         : constraint.maxWidth / 5.6,
//                     // color: Colors.yellow,
//                     child: Row(
//                       children: [
//                         browserModel.webViewTabs.isEmpty == false && vpnStatusProvider.canShowHomeScreen == false
//                        ?  GestureDetector(
//                         onTap: ()async{
//                           vpnStatusProvider.updateCanShowHomeScreen(true);
//                           await webViewController?.stopLoading();
//                           vpnStatusProvider.updateFAB(false);
//                          ttsProvider.updateTTSDisplayStatus(false);

//                   //            await webViewController?.evaluateJavascript(
//                   // source: "document.activeElement.blur();");
//                         if (await webViewController?.getSelectedText() != null) {
//                 // await webViewController?.evaluateJavascript(
//                 //     source: "window.getSelection().removeAllRanges();"
//                 //      );

//                       await webViewController?.evaluateJavascript(source: """
                    
//                     //Close keyboard if open
//                     document.activeElement.blur();

//                    // Close context menu
//                    window.getSelection().removeAllRanges();

//                   document.querySelectorAll('video').forEach(video => video.pause());

//                   // Pause all HTML5 audio elements
//                   document.querySelectorAll('audio').forEach(audio => audio.pause());

//                   // Pause YouTube videos
//                   var iframes = document.querySelectorAll('iframe');
//                   iframes.forEach(iframe => {
//                     var src = iframe.src;
//                     if (src.includes('youtube.com/embed')) {
//                       iframe.contentWindow.postMessage('{"event":"command","func":"pauseVideo","args":""}', '*');
//                     }
//                   });
//                 """);
//               }
//                          final ByteData data = await rootBundle.load('assets/images/screen-shot.png');
//                           setState(() {
//                             imageScreenshot = data.buffer.asUint8List();
//                           });
                      
//                           // webViewController!.loadData(data: homeHtmlContent,
//                           // mimeType: 'text/html',
//                           // encoding: 'utf-8'
//                           // );
//                           //browserModel.closeAllTabs();
//                         },
//                          child: Container(
//                             margin: EdgeInsets.symmetric(horizontal: 8,vertical: 8),
//                                  height: 33,
//                                  width: 33,
//                                  decoration: BoxDecoration(
//                                      color:
//                                          themeProvider.darkTheme ? Color(0xff39394B) : Color(0xffffffff),
//                                     // borderRadius: BorderRadius.circular(5)
//                                      ),
//                                  child: Row(
//                                    mainAxisAlignment: MainAxisAlignment.center,
//                                    children: [
//                                 // browserModel.webViewTabs.isEmpty == false && widget.canHomeShown == true
//                                   SvgPicture.asset(themeProvider.darkTheme ? 'assets/images/home.svg' : 'assets/images/home_wht_theme.svg',) 
                                    
//                                    ],
//                                  ),
//                                ),
//                        ):
//                         SearchSettingsPopupList(
//                           browserModel: browserModel,
//                           browserSettings: settings,
//                         ),
//                          VerticalDivider(
//                           width: 1,
//                           indent: 10,
//                           endIndent: 10,
//                           color: themeProvider.darkTheme ? Color(0xff42425F) : Color(0xffDADADA),
//                         ),
//                         Visibility(
//                           visible: vpnStatusProvider.canShowHomeScreen ? false: webViewModel.url != null ? true : false,
//                           // webViewModel.url != null ||
//                           //     webViewModel.isIncognitoMode,
//                           child: Selector<WebViewModel, bool>(
//                               selector: (context, webViewModel) =>
//                                   webViewModel.isSecure,
//                               builder: (context, isSecure, child) {
//                                 var image =  themeProvider.darkTheme
//                                         ? 'assets/images/https.svg'
//                                         : 'assets/images/https_white_theme.svg';
//                                 if (webViewModel.isIncognitoMode) {
//                                   print('Incognito ----> ');
//                                   image = Util.urlIsSecure(webViewModel.url as Uri) == false 
//                                   //!(webViewModel.isSecure)
//                                       ? 'assets/images/private_http.svg'
//                                       : 'assets/images/privatetab.svg';
//                                       print('Incognito ----? $image');
//                                 } else if (isSecure &&
//                                     !(webViewModel.isIncognitoMode)) {
//                                   if (webViewModel.url != null &&
//                                       webViewModel.url!.scheme == "file") {
//                                     image = themeProvider.darkTheme
//                                            ? 'assets/images/Web Archieves.svg'
//                                            : 'assets/images/web_arc-black.svg';
//                                   } else if(isSecure && browserModel.isUrlInDomainList(webViewModel.url.toString())){
//                                     image = themeProvider.darkTheme
//                                       ? 'assets/images/http.svg'
//                                       : 'assets/images/http_white_theme.svg';
//                                   }else {
//                                     image = themeProvider.darkTheme
//                                         ? 'assets/images/https.svg'
//                                         : 'assets/images/https_white_theme.svg';
//                                   }
//                                 } else if ((webViewModel.url != null &&
//                                         (isSecure == false)) &&
//                                     !webViewModel.isIncognitoMode) {
//                                        if(webViewModel.url.toString().endsWith('.bdx') || webViewModel.url.toString().endsWith('.bdx/')){
//                                        image = themeProvider.darkTheme
//                                         ? 'assets/images/mnLock-dark-theme.svg'
//                                         : 'assets/images/mnLock-white-theme.svg';
//                                     }else{
//                                        image = themeProvider.darkTheme
//                                       ? 'assets/images/http.svg'
//                                       : 'assets/images/http_white_theme.svg';
//                                     }
                                  
//                                 }
//                                 return Padding(
//                                   padding: const EdgeInsets.only(left: 5.0),
//                                   child: SvgPicture.asset(
//                                     image,
//                                     height: constraint.maxWidth / 16.5,
//                                     width: constraint.maxWidth / 16.5,
//                                   ),
//                                 );
//                               }),
//                         ),

//                       ],
//                     ),
//                   ),
//                   Container(
//                     width: webViewModel.url != null && vpnStatusProvider.canShowHomeScreen == false && ttsProvider.canTTSDisplay == false
//                         ? constraint.maxWidth / 2
//                        : ttsProvider.canTTSDisplay && browserModel.webViewTabs.isNotEmpty ? constraint.maxWidth / 2.1 
//                           : constraint.maxWidth / 1.8,
//                     child: GestureDetector(
//                       onTap: () async {
//                         if (webViewController != null) {
//                   webViewController.evaluateJavascript(source: "hideFooter();");
//                     }
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => SearchScreen(
//                                       controller: _searchController!,
//                                       browserModel: browserModel,
//                                       settings: settings,
//                                       webViewController: webViewController,
//                                       webViewModel: webViewModel,
//                                       //  pageTitle:pageTitles ,//pageTitle,
//                                       //  favIcons:favIcon, //favIcon,
//                                     )));

//                         //  if (_searchTextController.text.isNotEmpty) {
//                         //   setState(() {
//                         //     _searchController = _searchTextController;
//                         //   });
//                         // }
//                       },
//                       child:
//                       vpnStatusProvider.canShowHomeScreen ?

//                        TextField(
//                         readOnly: true,
//                         enabled: false,
//                         canRequestFocus: false,
//                         // onSubmitted: (value) {
//                         //   if(canShowExpandedTextField){
//                         //      var url = WebUri(value.trim());
//                         //   if (!url.scheme.startsWith("http") &&
//                         //       !Util.isLocalizedContent(url)) {
//                         //     url = WebUri(settings.searchEngine.searchUrl + value);
//                         //   }

//                         //   if (webViewController != null) {
//                         //     webViewController.loadUrl(
//                         //         urlRequest: URLRequest(url: url));
//                         //   } else {
//                         //     addNewTab(url: url);
//                         //     webViewModel.url = url;
//                         //   }
//                         //   canShowExpandedTextField = false;
//                         //   }

//                         // },
//                         keyboardType: TextInputType.url,
//                         focusNode: _focusNode,
//                         autofocus: false,
//                         controller: _homeSerachController,
//                         textInputAction: TextInputAction.go,
//                         decoration: InputDecoration(
//                             contentPadding: const EdgeInsets.only(
//                                 top: 5.0, right: 10.0, bottom: 10.0),
//                             border: InputBorder.none,
//                             hintText: loc.searchOrEnterAddress, // "Search or enter Address",
//                             hintStyle: TextStyle(
//                                 color: themeProvider.darkTheme
//                                     ?const Color(0xff6D6D81)
//                                     : const Color(0xff6D6D81),
//                                 fontWeight: FontWeight
//                                     .normal) //const TextStyle(fontSize: 14.0,fontWeight: FontWeight.normal),
//                             ),
//                         style:TextStyle(fontFamily: 'Roboto',fontWeight: FontWeight.w500,fontSize: 16)
//                         //isLengthyLanguageInList(localeProvider.selectedLanguage) ? theme.textTheme.bodyMedium!.copyWith(fontSize: 9) : theme.textTheme.bodyMedium,
//                       ):
//                       TextField(
//                         readOnly: true,
//                         enabled: false,
//                         canRequestFocus: false,
//                         // onSubmitted: (value) {
//                         //   var url = WebUri(value.trim());
//                         //   if (!url.scheme.startsWith("http") &&
//                         //       !Util.isLocalizedContent(url)) {
//                         //     url = WebUri(settings.searchEngine.searchUrl + value);
//                         //   }
                      
//                         //   if (webViewController != null) {
//                         //     webViewController.loadUrl(
//                         //         urlRequest: URLRequest(url: url));
//                         //   } else {
//                         //     addNewTab(url: url);
//                         //     webViewModel.url = url;
//                         //   }
//                         // },
//                         keyboardType: TextInputType.url,
//                         focusNode: _focusNode,
//                         autofocus: false,
//                         controller: _searchController,
//                         textInputAction: TextInputAction.go,
//                         decoration: InputDecoration(
//                             contentPadding: const EdgeInsets.only(
//                                 top: 5.0, right: 10.0, bottom: 10.0),
//                             border: InputBorder.none,
//                             hintText:loc.searchOrEnterAddress, // "Search or enter Address",
//                             hintStyle: TextStyle(
//                                 color: themeProvider.darkTheme
//                                     ? const Color(0xff6D6D81)
//                                     : const Color(0xff6D6D81),
//                                // fontSize: 14,
//                                 // DynamicTextSizeWidget()
//                                 //     .dynamicFontSize(14.0, context),
//                                 fontWeight: FontWeight
//                                     .normal) //const TextStyle(fontSize: 14.0,fontWeight: FontWeight.normal),
//                             ),
//                         style:TextStyle(fontFamily: 'Roboto',fontWeight: FontWeight.w500,fontSize: 14),
//                         //isLengthyLanguageInList(localeProvider.selectedLanguage) ? theme.textTheme.bodyMedium!.copyWith(fontSize: 9) : theme.textTheme.bodyMedium,
//                       ),
//                     ),
//                   ),
//                   Container(
//                     width: ttsProvider.canTTSDisplay && browserModel.webViewTabs.isNotEmpty ? constraint.maxWidth / 3.8 : constraint.maxWidth / 4.1,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Visibility(
//                           visible: ttsProvider.canTTSDisplay && browserModel.webViewTabs.isNotEmpty,
//                           child: GestureDetector(
//                             onTap: ()async{
//                               final article = await extractReadableContent(webViewController);
//                            hideSelectionMenu(webViewController!);
// if (article != null) {
//    showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//      builder: (context){

//      return ChangeNotifierProvider(
//       create: (context) => ReaderProvider(
//         (article['title'] != null && article['title'].toString().isNotEmpty)
//                                       ? '<h2>${article['title']}</h2>${article['content'] ?? article['textContent'] ?? ""}'
//                                       : article['content'] ?? article['textContent'] ?? ""
       
//         ),
      
//          child: SpeechHtmlScreen(article: article,)
      
//      ); //TtsHtmlScreen(article: article,); //ReadingModeScreen(article: article,); //DraggableAISheet();
//           //return BeldexAiScreen();
//      });
// } else {
//   debugPrint("No article extracted");
// }

//                             },
//                             child: themeProvider.darkTheme ?  SvgPicture.asset('assets/images/ai-icons/reading_mode.svg') : SvgPicture.asset('assets/images/ai-icons/Reading_mode_wht.svg')) ),
                      
//                         // tabList(themeProvider,theme),
//                         // // SearchSettingsPopupList(browserModel: browserModel, browserSettings: settings,),
//                         //  VerticalDivider(
//                         //   width: 1,
//                         //   indent: 10,
//                         //   endIndent: 10,
//                         //   color: themeProvider.darkTheme ? Color(0xff42425F) : Color(0xffDADADA),
//                         // ),
//                         //   IconButton(icon:Icon(Icons.ads_click),
//                         //  onPressed: ()async {
//                         //   if(webViewController != null){
//                         //     await webViewController.loadUrl(urlRequest: URLRequest(url: WebUri( _searchController!.text)));
//                         //   }

//                         //   },),
//                        // threeDotMenu(themeProvider,theme)
//                       ],
//                     ),
//                   )
//                 ],
//               );
            }),
          );
        }));
  }


  Widget tabList(DarkThemeProvider themeProvider,ThemeData theme) {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
     final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
     final tabGroupProvider = Provider.of<GroupProvider>(context,listen: false);
     final groupProvider = Provider.of<GroupProvider>(context);
     //final bottomNavigationProvider =Provider.of<BottomNavigationProvider>(context);
     //final loc = AppLocalizations.of(context)!;
    return InkWell(
      key: tabInkWellKey,
      onLongPress: () {
        final RenderBox? box =
            tabInkWellKey.currentContext!.findRenderObject() as RenderBox?;
        if (box == null) {
          return;
        }
        vpnStatusProvider.updateFAB(false);
        Offset position = box.localToGlobal(Offset.zero);
       
       groupProvider.totalOpenTabsCount == 0
         //browserModel.webViewTabs.isEmpty
          ?
          showMenu(
                context: context,
                 color: themeProvider.darkTheme ?const Color(0xff282836) : const Color(0xffF3F3F3),
                 constraints: BoxConstraints(
                  maxWidth: 220,
                 ),
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
                          SizedBox(width: 10,),
                      Text('getLocalizedTabListPopupMenuItemsName(tabPopupMenuAction, loc)', //tabPopupMenuAction,
                      style:theme
                                        .textTheme
                                        .bodySmall ,overflow: TextOverflow.ellipsis,maxLines: 1,)
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
             // addNewTab();
              break;
            // case TabPopupMenuActions.NEW_INCOGNITO_TAB:
            //   addNewIncognitoTab();
            //   break;
          }
        })

        :showMenu(
                context: context,
                 color: themeProvider.darkTheme ?const Color(0xff282836) : const Color(0xffF3F3F3),
                 constraints: BoxConstraints(
                  maxWidth: 220,
                 ),
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
                          SizedBox(width: 10,),
                      Expanded(
                        child: Text('getLocalizedTabListPopupMenuItemsName(tabPopupMenuAction, loc)', //tabPopupMenuAction,
                        style:theme
                                          .textTheme
                                          .bodySmall ,overflow: TextOverflow.ellipsis,maxLines: 1,),
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
        
        if (groupProvider.totalOpenTabsCount != 0) {
          var webViewModel = browserModel.getCurrentTab()?.webViewModel;
          var webViewController = webViewModel?.webViewController;
           hideFooter(webViewController);
          if (View.of(context).viewInsets.bottom > 0.0) {
            SystemChannels.textInput.invokeMethod('TextInput.hide');
            if (FocusManager.instance.primaryFocus != null) {
              FocusManager.instance.primaryFocus!.unfocus();
            }
            if (webViewController != null) {
              await webViewController.evaluateJavascript(
                  source: "document.activeElement.blur();");
            }
            await Future.delayed(const Duration(milliseconds: 300));
          }
          tabGroupProvider.changeViewMode(ViewMode.all);

        vpnStatusProvider.updateFAB(false);
         if(vpnStatusProvider.canShowHomeScreen){
     if (webViewModel != null && imageScreenshot != null){
      webViewModel.screenshot = imageScreenshot;
     }
        vpnStatusProvider.updateCanShowHomeScreen(false);
   }else if (webViewModel != null && webViewController != null) {
            webViewModel.screenshot = await webViewController
                .takeScreenshot(
                    screenshotConfiguration: ScreenshotConfiguration(
                        compressFormat: CompressFormat.JPEG, quality: 20))
                .timeout(
                  const Duration(milliseconds: 1500),
                  onTimeout: () => null,
                );
          }
          //bottomNavigationProvider.changeView(HomeView.tabs);
          browserModel.showTabScroller = true;
        }
      },
      child: Stack(
              children: [

                SvgPicture.asset('assets/images/ai-icons/new/Tabs.svg',color: Color(0xff8D8D8D),),
                Positioned.fill(
                  right: 2,
                  child: Center(
                  child:groupProvider.totalOpenTabsCount > 99 ? SvgPicture.asset(
                    'assets/images/Infinity_white_theme.svg',
                    color:
                        themeProvider.darkTheme ? Colors.white : Colors.black,
                  ):Text(groupProvider.totalOpenTabsCount.toString(),
                  style: TextStyle(fontSize: 10),
                  )
                  )
                  )
              ],
            ),
      // Container(
      //   width: 18,
      //   height: 18,
      //   margin: const EdgeInsets.only(
      //       left: 10.0, top: 10.0, right: 5.0, bottom: 10.0),
      //   decoration: BoxDecoration(
      //       color:
      //           themeProvider.darkTheme ? const Color(0xff282836) : const Color(0xffF3F3F3),
      //       border: Border.all(
      //           width: 1.0,
      //           color: themeProvider.darkTheme ? Colors.white : Colors.black),
      //       shape: BoxShape.rectangle,
      //       borderRadius: BorderRadius.circular(3.0)),
      //   constraints: const BoxConstraints(minWidth: 18.0),
      //   child: Center(
      //     child: browserModel.webViewTabs.length >= 100
      //         ? Padding(
      //             padding: const EdgeInsets.all(2.0),
      //             child: SvgPicture.asset(
      //               'assets/images/Infinity_white_theme.svg',
      //               color:
      //                   themeProvider.darkTheme ? Colors.white : Colors.black,
      //             ),
      //           )
      //         : TextWidget(
      //            text: browserModel.webViewTabs.length.toString(),
      //             style: TextStyle(
      //                 color:
      //                     themeProvider.darkTheme ? Colors.white : Colors.black,
      //                 fontWeight: FontWeight.normal,
      //                 fontSize: 12.0),
      //           ),
      //   ),
      // ),
    );
  }


   hideSelectionMenu(InAppWebViewController webViewController)async{
    await webViewController?.evaluateJavascript(
                  source: "document.activeElement.blur();");
              if (await webViewController?.getSelectedText() != null) {
                await webViewController?.evaluateJavascript(
                    source: "window.getSelection().removeAllRanges();");
              }
   }

  void hideFooter(InAppWebViewController? webViewController) {
    print('THE WEB MODEL FROM ----');
    if (webViewController != null) {
      webViewController.evaluateJavascript(source: "hideFooter();");
    }
  }


Future<Map<String, dynamic>?> extractReadableContent(
    InAppWebViewController? controller) async {
  try {
    final result = await controller?.evaluateJavascript(source: """
      (() => {
        try {
          // Clone and clean DOM
          var doc = document.cloneNode(true);

          // Remove scripts, templates, and AMP tags
          doc.querySelectorAll('script, style, template, amp-analytics, amp-list, amp-ad, iframe, noscript').forEach(el => el.remove());

          // Use Readability
          var reader = new Readability(doc);
          var article = reader.parse();

          if (!article) return "";

          // Sanitize HTML to remove any residual unwanted tags
          var content = document.createElement('div');
          content.innerHTML = article.content;
          content.querySelectorAll('script, style, template, amp-analytics, amp-list, amp-ad, iframe, noscript').forEach(el => el.remove());

          article.content = content.innerHTML.trim();

          return JSON.stringify(article);
        } catch (e) {
          return "";
        }
      })();
    """);

    if (result == null || result.isEmpty) return null;

    return Map<String, dynamic>.from(jsonDecode(result));
  } catch (e) {
    debugPrint("Error extracting readable content: $e");
    return null;
  }
}


}