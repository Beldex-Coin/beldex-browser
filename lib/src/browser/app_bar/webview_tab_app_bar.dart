// import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'dart:io';

import 'package:beldex_browser/main.dart';
import 'package:beldex_browser/src/browser/ai/beldex_ai_screen.dart';
import 'package:beldex_browser/src/browser/ai/chat_screen.dart';
import 'package:beldex_browser/src/browser/app_bar/sample_popup.dart';
import 'package:beldex_browser/src/browser/app_bar/search_screen.dart';
import 'package:beldex_browser/src/browser/app_bar/tab_viewer_app_bar.dart';
import 'package:beldex_browser/src/browser/app_bar/tabs_list.dart';
import 'package:beldex_browser/src/browser/app_bar/url_info_popup.dart';
import 'package:beldex_browser/src/browser/custom_image.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/favorite_model.dart';
import 'package:beldex_browser/src/browser/models/search_engine_model.dart';
import 'package:beldex_browser/src/browser/models/web_archive_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/pages/developers/main.dart';
import 'package:beldex_browser/src/browser/pages/download_page.dart';
import 'package:beldex_browser/src/browser/pages/settings/main.dart';
import 'package:beldex_browser/src/browser/pages/settings/search_settings_page.dart';
import 'package:beldex_browser/src/browser/tab_popup_menu_actions.dart';
import 'package:beldex_browser/src/browser/util.dart';
import 'package:beldex_browser/src/node_dropdown_list_page.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/utils/dynamic_text_size_widget.dart';
import 'package:beldex_browser/src/utils/screen_secure_provider.dart';
import 'package:beldex_browser/src/utils/show_message.dart';
import 'package:beldex_browser/src/utils/theme_setter.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:beldex_browser/src/utils/themes/sample_download_page.dart';
import 'package:beldex_browser/src/widget/aboutpage.dart';
import 'package:beldex_browser/src/widget/animated_toggle_switch.dart';
import 'package:beldex_browser/src/widget/downloads/download_ui.dart';
import 'package:beldex_browser/src/widget/text_widget.dart';
//import 'package:beldex_browser/src/widget/downloads/downloads_sample.dart';
import 'package:belnet_lib/belnet_lib.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_extend/share_extend.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../custom_popup_dialog.dart';
import '../custom_popup_menu_item.dart';
import '../popup_menu_actions.dart';
import '../project_info_popup.dart';
import '../webview_tab.dart';

TextEditingController? findOnPageController = TextEditingController();

class WebViewTabAppBar extends StatefulWidget {
  final void Function()? showFindOnPage;
  final void Function()? hideFindOnPage;
  const WebViewTabAppBar({Key? key, this.showFindOnPage, this.hideFindOnPage})
      : super(key: key);

  @override
  State<WebViewTabAppBar> createState() => WebViewTabAppBarState();
}

class WebViewTabAppBarState extends State<WebViewTabAppBar>
    with SingleTickerProviderStateMixin {
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
      }
    });
    Provider.of<SelectedItemsProvider>(context, listen: false)
        .initSharedPreferences();
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
    final browserModel = Provider.of<BrowserModel>(context);
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final theme = Theme.of(context);
    return Selector<WebViewModel, WebUri?>(
        selector: (context, webViewModel) => webViewModel.url,
        builder: (context, url, child) {
          if (url == null) {
            print('this search controller is calling');
            _searchController?.text = "";
          }
          if (url != null && _focusNode != null && !_focusNode!.hasFocus) {
            _searchController?.text = url.toString();
          }

          return browserModel.isFindingOnPage
                  ? findOnPageAppBar(themeProvider,theme)
                  : webViewAppBar(
                      themeProvider,theme);
        });
  }

  isFullScreen(InAppWebViewController? webviewController) async {
    if (await webviewController!.isInFullscreen()) {
      _focusNode!.unfocus();
    }
  }

  Widget findOnPageAppBar(DarkThemeProvider themeProvider,ThemeData theme) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var webViewModel = browserModel.getCurrentTab()?.webViewModel;
    var webViewModelPro = Provider.of<WebViewModel>(context, listen: true);
    var webViewController = webViewModelPro.webViewController;
    var findInteractionController = webViewModel?.findInteractionController;
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
    isFullScreen(webViewController);
    return PreferredSize(
        preferredSize: Size.fromHeight(90),
        child: Container(
          height: 45,
          width: double.infinity,
          margin: EdgeInsets.only(top: 40, left: 15, right: 15, bottom: 4),
          decoration: BoxDecoration(
              color: //webViewModel.isIncognitoMode ? Color(0xff040404) :
                  themeProvider.darkTheme
                      ? Color(0xff282836)
                      : Color(0xffF3F3F3),
              borderRadius: BorderRadius.circular(8)),
          child: LayoutBuilder(builder: (context, constraint) {
            return Row(
              children: [
                Container(
                  width: constraint.maxWidth / 1.5,
                  // color: Colors.yellow,
                  child: TextField(
                    onSubmitted: (value) {
                      findInteractionController?.findAll(find: value);
                    },
                    keyboardType: TextInputType.url,
                    focusNode: _focusNode,
                    autofocus: true,
                    controller: findOnPageController,
                    textInputAction: TextInputAction.go,
                    contextMenuBuilder: (context, editableTextState) {
                      //final List<ContextMenuButtonItem>
                      editableState = editableTextState;
                      buttonItems = editableTextState.contextMenuButtonItems;
                      buttonItems.clear(); // Clear all default options
                      if (findOnPageController!.text
                              .isEmpty //|| _searchController.selection != TextSelection.collapsed(offset: _searchController.selection.baseOffset)
                          ) {
                        // Clipboard.getData('text/plain').then((clipboardContent) {
                        //    if(clipboardContent != null && clipboardContent.text!.isNotEmpty){
                        buttonItems.add(ContextMenuButtonItem(
                            label: 'Paste',
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
                          label: 'Cut',
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
                          label: 'Copy',
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
                            label: 'Select All',
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
                          label: 'Paste',
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
                        hintText: "Find on page ...",
                        hintStyle: TextStyle(
                            color:const Color(0xff6D6D81),
                           // fontSize: 14.0,
                            fontWeight: FontWeight
                                .normal), //const TextStyle(fontSize: 14.0,fontWeight: FontWeight.normal),
                        ),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Container(
                  width: constraint.maxWidth / 3,
                  // color: Colors.green,
                  child: Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        // color: Colors.blue,
                        width: constraint.maxWidth / 9,
                        child: IconButton(
                          icon: Icon(Icons.keyboard_arrow_up,size :constraint.maxHeight/2),
                          onPressed: () {
                            findInteractionController?.findNext(forward: false);
                          },
                        ),
                      ),
                      SizedBox(
                        //color: Colors.yellow,
                        width: constraint.maxWidth / 12,
                        child: IconButton(
                          icon: Icon(Icons.keyboard_arrow_down,size :constraint.maxHeight/2),
                          onPressed: () {
                            findInteractionController?.findNext(forward: true);
                          },
                        ),
                      ),
                      Spacer(),
                      Container(
                        // color: Colors.pink,
                        width: constraint.maxWidth / 9,
                        child: IconButton(
                          icon: Icon(Icons.close,size :constraint.maxHeight/2),
                          onPressed: () {
                            findInteractionController?.clearMatches();
                            findOnPageController?.text = "";

                            if (widget.hideFindOnPage != null) {
                              widget.hideFindOnPage!();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          }),
        ));
  }

  
  final GlobalKey _appBarKey = GlobalKey();


 
  PreferredSize webViewAppBar(DarkThemeProvider themeProvider,ThemeData theme) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context,listen: false);
    var webViewModel = Provider.of<WebViewModel>(context, listen: true);
    var webViewController = webViewModel.webViewController;
    return PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: LayoutBuilder(builder: (context, constraints) {
          return Container(
            height:45, //constraints.maxHeight/1.6, //45,
            width: double.infinity,
            margin: EdgeInsets.only( top: 40,
                left: 10, right: 10, bottom: 4
            ),
            decoration: BoxDecoration(
                color: //webViewModel.isIncognitoMode ? Color(0xff040404) :
                    themeProvider.darkTheme
                        ?const Color(0xff282836)
                        :const Color(0xffF3F3F3),
                borderRadius: BorderRadius.circular(8)),
            child: LayoutBuilder(builder: (context, constraint) {
              return Row(
                children: [
                  SizedBox(
                    width:  webViewModel.url != null && vpnStatusProvider.canShowHomeScreen == false 
                        ? constraint.maxWidth / 4.2
                        : constraint.maxWidth / 5.6,
                    // color: Colors.yellow,
                    child: Row(
                      children: [
                        browserModel.webViewTabs.isEmpty == false && vpnStatusProvider.canShowHomeScreen == false
                       ?  GestureDetector(
                        onTap: ()async{
                          vpnStatusProvider.updateCanShowHomeScreen(true);
                  //            await webViewController?.evaluateJavascript(
                  // source: "document.activeElement.blur();");
                        if (await webViewController?.getSelectedText() != null) {
                // await webViewController?.evaluateJavascript(
                //     source: "window.getSelection().removeAllRanges();"
                //      );

                      await webViewController?.evaluateJavascript(source: """
                    
                    //Close keyboard if open
                    document.activeElement.blur();

                   // Close context menu
                   window.getSelection().removeAllRanges();

                  document.querySelectorAll('video').forEach(video => video.pause());

                  // Pause all HTML5 audio elements
                  document.querySelectorAll('audio').forEach(audio => audio.pause());

                  // Pause YouTube videos
                  var iframes = document.querySelectorAll('iframe');
                  iframes.forEach(iframe => {
                    var src = iframe.src;
                    if (src.includes('youtube.com/embed')) {
                      iframe.contentWindow.postMessage('{"event":"command","func":"pauseVideo","args":""}', '*');
                    }
                  });
                """);
              }
                         final ByteData data = await rootBundle.load('assets/images/screen-shot.png');
                          setState(() {
                            imageScreenshot = data.buffer.asUint8List();
                          });
                      
                          // webViewController!.loadData(data: homeHtmlContent,
                          // mimeType: 'text/html',
                          // encoding: 'utf-8'
                          // );
                          //browserModel.closeAllTabs();
                        },
                         child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                                 height: 33,
                                 width: 33,
                                 decoration: BoxDecoration(
                                     color:
                                         themeProvider.darkTheme ? Color(0xff39394B) : Color(0xffffffff),
                                     borderRadius: BorderRadius.circular(5)),
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                // browserModel.webViewTabs.isEmpty == false && widget.canHomeShown == true
                                  SvgPicture.asset(themeProvider.darkTheme ? 'assets/images/home.svg' : 'assets/images/home_wht_theme.svg',) 
                                    
                                   ],
                                 ),
                               ),
                       ):
                        SearchSettingsPopupList(
                          browserModel: browserModel,
                          browserSettings: settings,
                        ),
                        VerticalDivider(
                          width: 1,
                          indent: 6,
                          endIndent: 6,
                        ),
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
                                  } else {
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

                      ],
                    ),
                  ),
                  Container(
                    width: webViewModel.url != null && vpnStatusProvider.canShowHomeScreen == false 
                        ? constraint.maxWidth / 2
                        : constraint.maxWidth / 1.8,
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
                            hintText: "Search or enter Address",
                            hintStyle: TextStyle(
                                color: themeProvider.darkTheme
                                    ?const Color(0xff6D6D81)
                                    : const Color(0xff6D6D81),
                                fontWeight: FontWeight
                                    .normal) //const TextStyle(fontSize: 14.0,fontWeight: FontWeight.normal),
                            ),
                        style: theme.textTheme.bodyMedium,
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
                            hintText: "Search or enter Address",
                            hintStyle: TextStyle(
                                color: themeProvider.darkTheme
                                    ? const Color(0xff6D6D81)
                                    : const Color(0xff6D6D81),
                               // fontSize: 14,
                                // DynamicTextSizeWidget()
                                //     .dynamicFontSize(14.0, context),
                                fontWeight: FontWeight
                                    .normal) //const TextStyle(fontSize: 14.0,fontWeight: FontWeight.normal),
                            ),
                        style:theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  Container(
                    width: constraint.maxWidth / 4.1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        tabList(themeProvider,theme),
                        // SearchSettingsPopupList(browserModel: browserModel, browserSettings: settings,),
                        VerticalDivider(
                          width: 1,
                          indent: 6,
                          endIndent: 6,
                        ),
                        //   IconButton(icon:Icon(Icons.ads_click),
                        //  onPressed: ()async {
                        //   if(webViewController != null){
                        //     await webViewController.loadUrl(urlRequest: URLRequest(url: WebUri( _searchController!.text)));
                        //   }

                        //   },),
                        threeDotMenu(themeProvider,theme)
                      ],
                    ),
                  )
                ],
              );
            }),
          );
        }));
  }

  Widget tabList(DarkThemeProvider themeProvider,ThemeData theme) {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
     final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
    return InkWell(
      key: tabInkWellKey,
      onLongPress: () {
        final RenderBox? box =
            tabInkWellKey.currentContext!.findRenderObject() as RenderBox?;
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
              addNewTab();
              break;
            // case TabPopupMenuActions.NEW_INCOGNITO_TAB:
            //   addNewIncognitoTab();
            //   break;
          }
        })

        :showMenu(
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
              addNewTab();
              break;
            // case TabPopupMenuActions.NEW_INCOGNITO_TAB:
            //   addNewIncognitoTab();
            //   break;
          }
        });
      },
      onTap: () async {
        //Navigator.push(context,MaterialPageRoute(builder: ((context) => TabsList() )));
        if (browserModel.webViewTabs.isNotEmpty) {
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

          browserModel.showTabScroller = true;
        }
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

 bool checkCanGoforward = false;



  void hideFooter(InAppWebViewController? webViewController) {
    print('THE WEB MODEL FROM ----');
    if (webViewController != null) {
      webViewController.evaluateJavascript(source: "hideFooter();");
    }
  }

 
Future onMenuOpen(InAppWebViewController? webViewController)async {
 hideFooter(webViewController);
            try {
              checkCanGoforward = await webViewController?.canGoForward() ?? false;
              await webViewController?.evaluateJavascript(
                  source: "document.activeElement.blur();");
              // ContextMenuController.removeAny();
              // ContextMenuController().remove();
              if (await webViewController?.getSelectedText() != null) {
                await webViewController?.evaluateJavascript(
                    source: "window.getSelection().removeAllRanges();");
              }
            } catch (e) {
              print('Exception $e');
            }
          }








  Widget threeDotMenu(DarkThemeProvider themeProvider,ThemeData theme) {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    var webViewModel = Provider.of<WebViewModel>(context, listen: true);
    var webViewController = webViewModel.webViewController;
    final width = MediaQuery.of(context).size.width;
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context,listen:true);
    return Container(
      //color: Colors.yellow,
      width: 33,
      child: StatefulBuilder(builder: (context, setState) {
        return PopupMenuButton<String>(
          //offset: Offset(9, 47),
         // offset: Offset(position.dx, position.dy + box.size.height-35),
          offset:  Offset(width/13.0,width/7.6),
          color:
              themeProvider.darkTheme ?const Color(0xff282836) :const Color(0xffF3F3F3),
          onOpened: () => onMenuOpen(webViewController),
          // async {
          //   try {
          //     checkCanGoforward = await webViewController?.canGoForward() ?? false;
          //     await webViewController?.evaluateJavascript(
          //         source: "document.activeElement.blur();");
          //     if(await webViewController?.getSelectedText() != null){
          //       await webViewController?.evaluateJavascript(source:"window.getSelection().removeAllRanges();" );
          //     }
          //   } catch (e) {
          //     print('Exception $e');
          //   }
          // },
          icon: Icon(Icons.more_horiz,
              color: themeProvider.darkTheme ? Colors.white : Colors.black),
          onSelected: _popupMenuChoiceAction,
          surfaceTintColor:
              themeProvider.darkTheme ?const Color(0xff282836) : const Color(0xffF3F3F3),
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
            var items = [
              CustomPopupMenuItem<String>(
                enabled: false, //true,
                //isIconButtonRow: true,
                child: SizedBox(
                  width:190,
                  child: StatefulBuilder(
                    builder: (statefulContext, setState) {
                      var browserModel = Provider.of<BrowserModel>(
                          statefulContext,
                          listen: true);
                      var webViewModel = Provider.of<WebViewModel>(
                          statefulContext,
                          listen: true);
                      var webViewController = webViewModel.webViewController;

                      var isFavorite = false;
                      FavoriteModel? favorite;

                      if (webViewModel.url != null &&
                          webViewModel.url!.toString().isNotEmpty) {
                        favorite = FavoriteModel(
                            url: webViewModel.url,
                            title: webViewModel.title ?? "",
                            favicon: webViewModel.favicon);
                        isFavorite = browserModel.containsFavorite(favorite);
                      }

                      var children = <Widget>[];

                      if (Util.isIOS()) {
                        children.add(
                          SizedBox(
                              width: 25.0,
                              child: IconButton(
                                  padding: const EdgeInsets.all(0.0),
                                  icon: SvgPicture.asset(
                                      'assets/images/forward.svg'),
                                  onPressed: (){
                                    webViewController?.goBack();
                                    Navigator.pop(popupMenuContext);
                                  })),
                        );
                      }

                      children.addAll([
                        SizedBox(
                            width: 25.0,
                            child: IconButton(
                                padding: const EdgeInsets.all(0.0),
                                icon: SvgPicture.asset(
                                  'assets/images/forward.svg',
                                  color: checkCanGoforward
                                      ? themeProvider.darkTheme
                                          ? const Color(0xffFFFFFF)
                                          : const Color(0xff282836)
                                      : Colors.grey.shade500,
                                ),
                                // const Icon(Icons.arrow_forward,
                                //     color: Colors.white //Colors.black,
                                //     ),
                                onPressed:!vpnStatusProvider.canShowHomeScreen ? (){
                                  //webViewController?.goBack();
                                  webViewController?.goForward();
                                  Navigator.pop(popupMenuContext);
                                }:null)),
                     
                     vpnStatusProvider.canShowHomeScreen ?

                       SizedBox(
                            width: 25.0,
                            child: IconButton(
                                padding: const EdgeInsets.all(0.0),
                                icon: SvgPicture.asset(
                                        'assets/images/Favorites_white_theme.svg',
                                        color: themeProvider.darkTheme
                                            ? const Color(0xffFFFFFF)
                                            : const Color(0xff282836)),

                                // SvgPicture.asset(isFavorite ? 'assets/images/Star.svg' : 'assets/images/Favorites.svg',),
                                //  Icon(
                                //     isFavorite ? Icons.star : Icons.star_border,
                                //     color: isFavorite ? Color(0xff00B134): Colors.white //Colors.black,
                                //     ),
                                onPressed:null))  
                     :   SizedBox(
                            width: 25.0,
                            child: IconButton(
                                padding: const EdgeInsets.all(0.0),
                                icon: isFavorite
                                    ? SvgPicture.asset('assets/images/Star.svg')
                                    : SvgPicture.asset(
                                        'assets/images/Favorites_white_theme.svg',
                                        color: themeProvider.darkTheme
                                            ? const Color(0xffFFFFFF)
                                            : const Color(0xff282836)),

                                // SvgPicture.asset(isFavorite ? 'assets/images/Star.svg' : 'assets/images/Favorites.svg',),
                                //  Icon(
                                //     isFavorite ? Icons.star : Icons.star_border,
                                //     color: isFavorite ? Color(0xff00B134): Colors.white //Colors.black,
                                //     ),
                                onPressed:!vpnStatusProvider.canShowHomeScreen ? () {
                                  setState(() {
                                    if (favorite != null) {
                                      if (!browserModel
                                          .containsFavorite(favorite)) {
                                        browserModel.addFavorite(favorite);
                                      } else if (browserModel
                                          .containsFavorite(favorite)) {
                                        browserModel.removeFavorite(favorite);
                                      }
                                    }
                                  });
                                }:null)),
                        SizedBox(
                            width: 25.0,
                            child: IconButton(
                                padding: const EdgeInsets.all(0.0),
                                icon: SvgPicture.asset(
                                    'assets/images/Download.svg',
                                    color: themeProvider.darkTheme
                                        ? Color(0xffFFFFFF)
                                        : Color(0xff282836)),
                                onPressed:!vpnStatusProvider.canShowHomeScreen ? () async {
                                  Navigator.pop(popupMenuContext);
                                  if (webViewModel.url != null &&
                                      webViewModel.url!.scheme
                                          .startsWith("http")) {
                                    var url = webViewModel.url;
                                    if (url == null) {
                                      return;
                                    }

                                    String webArchivePath =
                                        "$WEB_ARCHIVE_DIR${Platform.pathSeparator}${url.scheme}-${url.host}${url.path.replaceAll("/", "-")}${DateTime.now().microsecondsSinceEpoch}.${Util.isAndroid() ? WebArchiveFormat.MHT.toValue() : WebArchiveFormat.WEBARCHIVE.toValue()}";

                                    String? savedPath = (await webViewController
                                        ?.saveWebArchive(
                                            filePath: webArchivePath,
                                            autoname: false));
                                    //print('this file is exits? ${fileExists(webArchivePath)}');
                                    bool isAlreadyExist = false;
                                    browserModel.webArchives
                                        .forEach((key, value) {
                                      if (value.url == url) {
                                        setState(() {
                                          isAlreadyExist = true;
                                        });

                                        // showMessage('This page is alrady saved offline');
                                        // return;
                                      }
                                    });
                                    var webArchiveModel = WebArchiveModel(
                                        url: url,
                                        path: savedPath,
                                        title: webViewModel.title,
                                        favicon: webViewModel.favicon,
                                        timestamp: DateTime.now());
                                    if (isAlreadyExist) {
                                      showMessage(
                                          'This page is alrady saved offline');
                                      // return;
                                    } else {
                                      if (savedPath != null) {
                                        browserModel.addWebArchive(
                                            url.toString(), webArchiveModel);
                                        if (mounted) {
                                          showMessage('Page is saved offline!');
                                        }
                                        browserModel.save();
                                      } else {
                                        if (mounted) {
                                          showMessage('Unable to save');
                                        }
                                      }
                                    }
                                  }
                                }:null)),
                        SizedBox(
                            width: 25.0,
                            child: IconButton(
                                padding: const EdgeInsets.all(0.0),
                                icon: SvgPicture.asset(
                                    'assets/images/Belnet.svg',
                                    color: themeProvider.darkTheme
                                        ?const Color(0xffFFFFFF)
                                        :const Color(0xff282836)),
                                onPressed: (){
                                  Navigator.pop(popupMenuContext);  
                                 navigateToBeldexNetwork(webViewController);
                                 
                                } )),
                        SizedBox(
                            width: 25.0,
                            child: IconButton(
                                padding: const EdgeInsets.all(0.0),
                                icon: SvgPicture.asset(
                                    'assets/images/screenshot.svg',
                                    color: themeProvider.darkTheme
                                        ? Color(0xffFFFFFF)
                                        : Color(0xff282836)),
                                onPressed:!vpnStatusProvider.canShowHomeScreen ? () async {
                                  var browserModel = Provider.of<BrowserModel>(
                                      context,
                                      listen: false);
                                  var basicProvider =
                                      Provider.of<BasicProvider>(context,
                                          listen: false);
                                  final SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  bool screenSecurityOn =
                                      prefs.getBool('switchState') ?? true;
                                  Navigator.pop(popupMenuContext);
                                  await route?.completed;
                                  if (!basicProvider.scrnSecurity) {
                                    takeScreenshotAndShow();
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            'Screen security is currently enabled.Make sure to disable it in the settings screen');
                                  }
                                }:null)),
                      
                      
                      
                     vpnStatusProvider.canShowHomeScreen ?  SizedBox(
                            width: 25.0,
                            child: IconButton(
                                padding: const EdgeInsets.all(0.0),
                                icon: SvgPicture.asset(
                                    'assets/images/refresh.svg',
                                    color: themeProvider.darkTheme
                                        ? Color(0xffFFFFFF)
                                        : Color(0xff282836)),
                                onPressed:null)):

                        PageLoadingContainer(
                          webViewController: webViewController,
                          popupMenuContext: popupMenuContext,
                          searchController: _searchController!,
                        )
                        // SizedBox(
                        //     width: 25.0,
                        //     child: IconButton(
                        //         padding: const EdgeInsets.all(0.0),
                        //         icon: SvgPicture.asset(
                        //             'assets/images/refresh.svg',
                        //             color:Colors.yellow
                        //             //  themeProvider.darkTheme
                        //             //     ? Color(0xffFFFFFF)
                        //             //     : Color(0xff282836)
                        //                 ),
                        //         onPressed: ()async {
                        //            if(webViewController != null && _searchController != null){
                        //       await webViewController.loadUrl(urlRequest: URLRequest(url: WebUri( _searchController!.text)));
                        //     }
                        //         // await webViewController?.reload();
                        //           Navigator.pop(popupMenuContext);
                        //         })),
                      ]);
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: children,
                      );
                    },
                  ),
                ),
              )
            ];

            items.addAll(PopupMenuActions.choices.map((choice) {
              switch (choice) {
                case PopupMenuActions.NEW_TAB:
                  return CustomPopupMenuItem<String>(
                    enabled: true,
                    value: choice,
                    height: 35,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          //SizedBox(height: 10),
                          Row(
                              // mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SvgPicture.asset('assets/images/new_tab.svg',
                                    color: themeProvider.darkTheme
                                        ?const Color(0xffFFFFFF)
                                        :const Color(0xff282836)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: TextWidget(text:choice,
                                      style: theme
                                          .textTheme
                                          .bodySmall //TextStyle(color:Colors.white,fontSize: 13,fontWeight: FontWeight.normal),
                                      ),
                                ),
                              ]),
                        ],
                      ),
                    ),
                  );
                // case PopupMenuActions.NEW_INCOGNITO_TAB:
                //   return CustomPopupMenuItem<String>(
                //     enabled: true,
                //     value: choice,
                //     height: 35,
                //     child: Padding(
                //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
                //       child: Row(
                //           //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             SvgPicture.asset('assets/images/private_tab.svg',
                //                 color: themeProvider.darkTheme
                //                     ?const Color(0xffFFFFFF)
                //                     :const Color(0xff282836)),
                //             Padding(
                //               padding:
                //                   const EdgeInsets.symmetric(horizontal: 8.0),
                //               child: TextWidget(
                //                 text:choice,
                //                 style: theme.textTheme.bodySmall,
                //               ),
                //             ),
                //           ]),
                //     ),
                //   );
                case PopupMenuActions.FAVORITES:
                  return CustomPopupMenuItem<String>(
                    enabled: true,
                    value: choice,
                    height: 35,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SvgPicture.asset(
                                'assets/images/Favorites_white_theme.svg',
                                color: themeProvider.darkTheme
                                    ? const Color(0xffFFFFFF)
                                    : const Color(0xff282836)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: TextWidget(
                               text: choice,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                            // const Icon(
                            //   Icons.star,
                            //   color: Colors.yellow,
                            // )
                          ]),
                    ),
                  );

                case PopupMenuActions.BELNET:
                  return CustomPopupMenuItem<String>(
                    enabled: true,
                    value: choice,
                    height: 35,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SvgPicture.asset('assets/images/Belnet.svg',
                                color: themeProvider.darkTheme
                                    ? const Color(0xffFFFFFF)
                                    : const Color(0xff282836)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextWidget(text:choice,
                                  style: theme.textTheme.bodySmall),
                            ),
                          ]),
                    ),
                  );
                case PopupMenuActions.DIVIDER:
                  return CustomPopupMenuItem<String>(
                      enabled: false,
                      height: 15,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(
                          color: themeProvider.darkTheme
                              ? const Color(0xff42425F)
                              :const Color(0xffDADADA),
                        ),
                      ));
                case PopupMenuActions.WEB_ARCHIVES:
                  return CustomPopupMenuItem<String>(
                    enabled: true,
                    value: choice,
                    height: 35,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(children: [
                        SvgPicture.asset('assets/images/Web Archieves.svg',
                            color: themeProvider.darkTheme
                                ?const Color(0xffFFFFFF)
                                :const Color(0xff282836)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextWidget(text:choice,
                              style: theme.textTheme.bodySmall),
                        ),
                      ]),
                    ),
                  );
                case PopupMenuActions.BELDEX_AI:
                  return CustomPopupMenuItem<String>(
                    enabled: true,
                    value: choice,
                    height: 35,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Row(children: [
                        SvgPicture.asset('assets/images/private_http.svg',
                            color: themeProvider.darkTheme
                                ?const Color(0xffFFFFFF)
                                :const Color(0xff282836)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: TextWidget(text:choice,
                              style: theme.textTheme.bodySmall),
                        ),
                      ]),
                    ),
                  );
                case PopupMenuActions.DOWNLOADS:
                  return CustomPopupMenuItem<String>(
                    enabled: true,
                    value: choice,
                    height: 35,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(children: [
                        SvgPicture.asset('assets/images/downloads-2.svg',
                            color: themeProvider.darkTheme
                                ?const Color(0xffFFFFFF)
                                :const Color(0xff282836)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextWidget(text:choice,
                              style: theme.textTheme.bodySmall),
                        ),
                      ]),
                    ),
                  );
                case PopupMenuActions.DESKTOP_MODE:
                  return CustomPopupMenuItem<String>(
                    enabled: browserModel.getCurrentTab() != null,
                    value: choice,
                    height: 35,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(children: [
                        Selector<WebViewModel, bool>(
                          selector: (context, webViewModel) =>
                              webViewModel.isDesktopMode,
                          builder: (context, value, child) {
                            return vpnStatusProvider.canShowHomeScreen ? 
                            SvgPicture.asset(
                              'assets/images/desktop_mode.svg',
                              color:themeProvider.darkTheme
                                      ?const Color(0xffFFFFFF)
                                      : const Color(0xff282836),
                            )
                            : SvgPicture.asset(
                              'assets/images/desktop_mode.svg',
                              color: value
                                  ?const Color(0xff00B134)
                                  : themeProvider.darkTheme
                                      ?const Color(0xffFFFFFF)
                                      : const Color(0xff282836),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: TextWidget(
                            text:choice,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ]),
                    ),
                  );
                // case PopupMenuActions.HISTORY:
                //   return CustomPopupMenuItem<String>(
                //     enabled: browserModel.getCurrentTab() != null,
                //     value: choice,
                //     child: Row(
                //        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Text(choice),
                //           const Icon(
                //             Icons.history,
                //             color: Colors.black,
                //           )
                //         ]),
                //   );
                case PopupMenuActions.SHARE:
                  return CustomPopupMenuItem<String>(
                    enabled: browserModel.getCurrentTab() != null,
                    value: choice,
                    height: 35,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(children: [
                        SvgPicture.asset('assets/images/Share.svg',
                            color: themeProvider.darkTheme
                                ?const Color(0xffFFFFFF)
                                :const Color(0xff282836)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextWidget(
                           text: choice,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ]),
                    ),
                  );
                case PopupMenuActions.SETTINGS:
                  return CustomPopupMenuItem<String>(
                    enabled: true,
                    value: choice,
                    height: 35,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(children: [
                        SvgPicture.asset('assets/images/settings.svg',
                            color: themeProvider.darkTheme
                                ?const Color(0xffFFFFFF)
                                :const Color(0xff282836)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextWidget(
                           text: choice,
                            style:theme.textTheme.bodySmall,
                          ),
                        ),
                      ]),
                    ),
                  );
                // case PopupMenuActions.DEVELOPERS:
                //   return CustomPopupMenuItem<String>(
                //     enabled: browserModel.getCurrentTab() != null,
                //     value: choice,
                //     child: Row(
                //        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Text(choice),
                //           const Icon(
                //             Icons.developer_mode,
                //             color: Colors.black,
                //           )
                //         ]),
                //   );
                case PopupMenuActions.FIND_ON_PAGE:
                  return CustomPopupMenuItem<String>(
                    enabled: browserModel.getCurrentTab() != null,
                    value: choice,
                    height: 35,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(children: [
                        SvgPicture.asset('assets/images/find_on_page.svg',
                            color: themeProvider.darkTheme
                                ?const Color(0xffFFFFFF)
                                :const Color(0xff282836)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextWidget(
                           text: choice,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ]),
                    ),
                  );
                case PopupMenuActions.DARKMODE:
                  return CustomPopupMenuItem<String>(
                    enabled: false,
                    value: choice,
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          Row(children: [
                            SvgPicture.asset('assets/images/theme.svg',
                                color: themeProvider.darkTheme
                                    ? const Color(0xffFFFFFF)
                                    :const Color(0xff282836)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 5),
                              child: TextWidget(
                               text: choice,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ]),
                          Positioned(
                              right: 0,
                              // bottom: 5,
                              child:
                                  AnimatedToggleSwitch(appbarKey: _appBarKey))
                        ],
                      ),
                    ),
                  );
                case PopupMenuActions.ABOUT:
                  return CustomPopupMenuItem<String>(
                    enabled: true,
                    value: choice,
                    height: 35,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(children: [
                        SvgPicture.asset('assets/images/about.svg',
                            color: themeProvider.darkTheme
                                ?const Color(0xffFFFFFF)
                                : const Color(0xff282836)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextWidget(
                           text: choice,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ]),
                    ),
                  );
                case PopupMenuActions.QUIT_VPN:
                  return CustomPopupMenuItem<String>(
                      enabled: true,
                      value: choice,
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset('assets/images/quit.svg',
                                    color: themeProvider.darkTheme
                                        ?const Color(0xffFFFFFF)
                                        :const Color(0xff282836)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7.0),
                                  child: TextWidget(
                                   text: choice,
                                    style:
                                        theme.textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                      ));
                // case PopupMenuActions.INAPPWEBVIEW_PROJECT:
                //   return CustomPopupMenuItem<String>(
                //     enabled: true,
                //     value: choice,
                //     child: Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Text(choice),
                //           Container(
                //             padding: const EdgeInsets.only(right: 6),
                //             child: const AnimatedBeldexBrowserLogo(
                //               size: 12.5,
                //             ),
                //           )
                //         ]),
                //   );
                default:
                  return CustomPopupMenuItem<String>(
                    value: choice,
                    child: TextWidget(text:choice),
                  );
              }
            }).toList());

            return items;
          },
        );
      }),
    );
  }

  
  void _updateSearchText(
      //TextEditingController _searchTextController
      String values) {
    print('update searchTextController');
    // if(_searchTextController.text.isNotEmpty)
    setState(() {
      searchText = values;
      // _searchController!.text = _searchTextController.text;
    });
  }

  goToSearchSettings() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => SearchSettingsPage()));
  }



  void _popupMenuChoiceAction(String choice) async {
    var currentWebViewModel = Provider.of<WebViewModel>(context, listen: false);
    final themeProvider =
        Provider.of<DarkThemeProvider>(context, listen: false);
     final vpnStatusProvider = Provider.of<VpnStatusProvider>(context,listen: false);
     var webViewModel = Provider.of<WebViewModel>(context, listen: false);
    var webViewController = webViewModel.webViewController;
    switch (choice) {
      case PopupMenuActions.NEW_TAB:
      vpnStatusProvider.updateCanShowHomeScreen(false);
        addNewTab();
        break;
      // case PopupMenuActions.NEW_INCOGNITO_TAB:
      //   addNewIncognitoTab();
      //   break;
      case PopupMenuActions.FAVORITES:
        showFavorites();
        break;
      case PopupMenuActions.HISTORY:
        showHistory();
        break;
      case PopupMenuActions.WEB_ARCHIVES:
        showWebArchives(themeProvider,vpnStatusProvider);
        break;
      case PopupMenuActions.BELDEX_AI:
        goToBeldexAIPage();
        break;
      case PopupMenuActions.FIND_ON_PAGE:
      if(!vpnStatusProvider.canShowHomeScreen){
        var isFindInteractionEnabled =
            currentWebViewModel.settings?.isFindInteractionEnabled ?? false;
        var findInteractionController =
            currentWebViewModel.findInteractionController;
        if (Util.isIOS() &&
            isFindInteractionEnabled &&
            findInteractionController != null) {
          await findInteractionController.presentFindNavigator();
        } else if (widget.showFindOnPage != null) {
          widget.showFindOnPage!();
        }}
        break;
      case PopupMenuActions.SHARE:
      if(!vpnStatusProvider.canShowHomeScreen){
        share();}
        break;
      case PopupMenuActions.DOWNLOADS:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => DownloadUI()));
        break;
      case PopupMenuActions.DESKTOP_MODE:
        toggleDesktopMode();
        break;
      case PopupMenuActions.DEVELOPERS:
        Future.delayed(const Duration(milliseconds: 300), () {
          goToDevelopersPage();
        });
        break;
      case PopupMenuActions.SETTINGS:
        Future.delayed(const Duration(milliseconds: 300), () {
          goToSettingsPage();
        });
        break;
      // case PopupMenuActions.INAPPWEBVIEW_PROJECT:
      //   Future.delayed(const Duration(milliseconds: 300), () {
      //     openProjectPopup();
      //   });
      //   break;
      case PopupMenuActions.BELNET:
        navigateToBeldexNetwork(webViewController);
        break;

      case PopupMenuActions.ABOUT:
        goToAbout();
        break;

      case PopupMenuActions.DARKMODE:
        Future.delayed(const Duration(milliseconds: 1000), () {});
        //changetheme();
        break;

      case PopupMenuActions.QUIT_VPN:
        quitVpnAndApp();
        break;
    }
  }

  void goToBeldexAIPage(){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatScreen()));
  }


  void navigateToBeldexNetwork(InAppWebViewController? webViewController)async{
      Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NodeDropdownListPage(
                exitData: [], canChangeNode: true,
                webViewController: webViewController,
              )));
     // print('THE RELOAD URL IN HERE IS AFTER ${value.toString()}');
     // await webViewController!.reload();
  } 
  void goToAbout() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AboutPage()));
  }

  void changetheme() {}

  void quitVpnAndApp() async {
    final themeProvider =
        Provider.of<DarkThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor:
              themeProvider.darkTheme ? Color(0xff282836) : Color(0xffFFFFFF),
          insetPadding: EdgeInsets.all(20),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 170,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: themeProvider.darkTheme
                    ? Color(0xff282836)
                    : Color(0xffFFFFFF),
                borderRadius: BorderRadius.circular(15)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child:const TextWidget(
                   text: 'Quit Browser',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
               const TextWidget(
                 text: 'Are you sure you want to quit?',
                  style: TextStyle(fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                        ),
                        child: MaterialButton(
                          elevation: 0,
                          color: themeProvider.darkTheme
                              ? Color(0xff39394B)
                              : Color(0xffF3F3F3),
                          disabledColor: Color(0xff2C2C3B),
                          minWidth: double.maxFinite,
                          height: 50,
                          child: TextWidget(text:'Cancel', style: TextStyle(fontSize: 18)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10.0), // Adjust the radius as needed
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                      ),
                    ),
                   const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: MaterialButton(
                          elevation: 0,
                          color: themeProvider.darkTheme
                              ? Color(0xff39394B)
                              : Color(0xffF3F3F3), // Color(0xff00B134),
                          disabledColor: Color(0xff2C2C3B),
                          minWidth: double.maxFinite,
                          height: 50,
                          child: TextWidget(text:'Quit',
                              style:
                                  TextStyle(color: Colors.red, fontSize: 18)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10.0), // Adjust the radius as needed
                          ),
                          onPressed: () async {
                            var disConnectValue =
                                await BelnetLib.disconnectFromBelnet();
                            print('belnet vpn disconnected $disConnectValue');
                            Future.delayed(Duration(milliseconds: 200),
                                (() => SystemNavigator.pop()));
                            // Navigator.of(context).pop(true);
                          },
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void addNewTab({WebUri? url}) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();
    final webViewModel = Provider.of<WebViewModel>(context, listen: false);
    final selectedItemsProvider = Provider.of<SelectedItemsProvider>(context,listen: false);


    url ??=
        WebUri(settings.searchEngine.url);
        webViewModel.settings?.minimumFontSize = selectedItemsProvider.fontSize.round();
        print('The WEBVIEWMODEL fontSize ${webViewModel.settings?.minimumFontSize}----- ${selectedItemsProvider.fontSize.round()}');
    browserModel.save();
    browserModel.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(url: url, settings: webViewModel.settings),
    ));
  }

  void addNewIncognitoTab({WebUri? url}) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();
     final webViewModel = Provider.of<WebViewModel>(context, listen: false);
    final selectedItemsProvider = Provider.of<SelectedItemsProvider>(context,listen: false);


    url ??=
        WebUri(settings.searchEngine.url);
     webViewModel.settings?.minimumFontSize = selectedItemsProvider.fontSize.round();
    browserModel.save();
    browserModel.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(url: url, isIncognitoMode: true, settings: webViewModel.settings),
    ));
  }

  void showFavorites() async {
    await showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          var browserModel = Provider.of<BrowserModel>(context, listen: true);
          final themeProvider =
              Provider.of<DarkThemeProvider>(context, listen: true);
          final vpnStatusProvider = Provider.of<VpnStatusProvider>(context,listen: true);
          return Dialog(
            backgroundColor:
                themeProvider.darkTheme ? Color(0xff2C2C3B) : Color(0xffF3F3F3),
            insetPadding: EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)
            ),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(10),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(12)),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 15, left: 8, right: 8),
                        child:const TextWidget(
                         text: 'Favorites',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                          child: browserModel.favorites.isEmpty
                              ? Center(child:const TextWidget(text:'No Favorites'))
                              :
                              // listViewChildren.isEmpty ?  Center(child: Text('No Web archives')):
                              ListView(
                                  children:
                                      browserModel.favorites.map((favorite) {
                                    var url = favorite.url;
                                    var faviconUrl = favorite.favicon != null
                                        ? favorite.favicon!.url
                                        : WebUri(
                                            "${url?.origin ?? ""}/favicon.ico");
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                              vpnStatusProvider.updateCanShowHomeScreen(false);
                                          addNewTab(url: favorite.url);
                                          Navigator.pop(context);
                                        });
                                      },
                                      child: Container(
                                          margin: EdgeInsets.only(bottom: 10),
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: themeProvider.darkTheme
                                                      ?const Color(0xff42425F)
                                                      :const Color(0xffDADADA)),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          height: 60,
                                          child: Row(children: [
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0),
                                                child: CustomImage(
                                                  url: faviconUrl,
                                                  maxWidth: 30.0,
                                                  height: 30.0,
                                                )),
                                            Expanded(
                                              child: Container(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    TextWidget(
                                                       text: favorite.title ??
                                                            favorite.url
                                                                ?.toString() ??
                                                            "",
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                    TextWidget(
                                                     text: favorite.url
                                                              ?.toString() ??
                                                          "",
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: themeProvider
                                                                  .darkTheme
                                                              ? const Color(
                                                                  0xff6D6D81)
                                                              :const Color(
                                                                  0xff6D6D81)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 35,
                                              //color: Colors.yellow,
                                              child: IconButton(
                                                icon: Icon(Icons.close,
                                                    color:
                                                        themeProvider.darkTheme
                                                            ?const Color(0xff6D6D81)
                                                            :const Color(0xffC5C5C5),
                                                    size:
                                                        20), //SvgPicture.asset('assets/images/close.svg', color:  themeProvider.darkTheme ? Color(0xff6D6D81) : Color(0xffC5C5C5), height: 20,width: 20,),
                                                onPressed: () async {
                                                  setState(() {
                                                    browserModel.removeFavorite(
                                                        favorite);
                                                    if (browserModel
                                                        .favorites.isEmpty) {
                                                      Navigator.pop(context);
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                          ])),
                                    );
                                  }).toList(),
                                ))
                    ],
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 7, right: 10),
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: Icon(Icons.close)),
                      ))
                ],
              ),
            ),
          );
        });
  }

  void showHistory() {
    showDialog(
        context: context,
        builder: (context) {
          var webViewModel = Provider.of<WebViewModel>(context, listen: true);

          return AlertDialog(
              contentPadding: const EdgeInsets.all(0.0),
              content: FutureBuilder(
                future:
                    webViewModel.webViewController?.getCopyBackForwardList(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }

                  WebHistory history = snapshot.data as WebHistory;
                  return SizedBox(
                      width: double.maxFinite,
                      child: ListView(
                        children: history.list?.reversed.map((historyItem) {
                              var url = historyItem.url;

                              return ListTile(
                                leading: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    // CachedNetworkImage(
                                    //   placeholder: (context, url) =>
                                    //       CircularProgressIndicator(),
                                    //   imageUrl: (url?.origin ?? "") + "/favicon.ico",
                                    //   height: 30,
                                    // )
                                    CustomImage(
                                        url: WebUri(
                                            "${url?.origin ?? ""}/favicon.ico"),
                                        maxWidth: 30.0,
                                        height: 30.0)
                                  ],
                                ),
                                title: TextWidget(text:historyItem.title ?? url.toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                subtitle: TextWidget(text:url?.toString() ?? "",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                isThreeLine: true,
                                onTap: () {
                                  webViewModel.webViewController
                                      ?.goTo(historyItem: historyItem);
                                  Navigator.pop(context);
                                },
                              );
                            }).toList() ??
                            <Widget>[],
                      ));
                },
              ));
        });
  }

  void showWebArchives(DarkThemeProvider themeProvider,VpnStatusProvider vpnStatusProvider) async {
    await showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          var browserModel = Provider.of<BrowserModel>(context, listen: true);
          var webArchives = browserModel.webArchives;

          var listViewChildren = <Widget>[];
          webArchives.forEach((key, webArchive) {
            var path = webArchive.path;
            // String fileName = path.substring(path.lastIndexOf('/') + 1);

            var url = webArchive.url;

            listViewChildren.add(InkWell(
              onTap: () {
                if (path != null) {
                  var browserModel =
                      Provider.of<BrowserModel>(context, listen: false);
                  vpnStatusProvider.updateCanShowHomeScreen(false);
                  browserModel.addTab(WebViewTab(
                    key: GlobalKey(),
                    webViewModel: WebViewModel(url: WebUri("file://$path")),
                  ));
                }
                Navigator.pop(context);
              },
              child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: themeProvider.darkTheme
                              ? Color(0xff42425F)
                              : Color(0xffDADADA)),
                      borderRadius: BorderRadius.circular(8)
                      ),
                  height: 60,
                  child: Row(children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: SvgPicture.asset(
                        'assets/images/webarchives.svg',
                        color: themeProvider.darkTheme
                            ? Color(0xff6D6D81)
                            : Color(0xffC5C5C5),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                             text: webArchive.title ?? url?.toString() ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextWidget(
                             text: url?.toString() ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: themeProvider.darkTheme
                                      ? Color(0xff6D6D81)
                                      : Color(0xff6D6D81)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 35,
                      //color: Colors.yellow,
                      child: IconButton(
                        icon: SvgPicture.asset(
                          'assets/images/delete.svg',
                          color: themeProvider.darkTheme
                              ? Color(0xff6D6D81)
                              : Color(0xffC5C5C5),
                          height: 20,
                          width: 20,
                        ),
                        onPressed: () async {
                          setState(() {
                            browserModel.removeWebArchive(webArchive);
                            browserModel.save();
                          });
                        },
                      ),
                    ),
                  ])),
            ));
          });
          return Dialog(
            backgroundColor:
                themeProvider.darkTheme ? Color(0xff2C2C3B) : Color(0xffF3F3F3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)
            ),
            insetPadding: EdgeInsets.all(15),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(10),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(12)),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 15, left: 8, right: 8),
                        child: TextWidget(
                         text: 'Web Archives',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                          child: listViewChildren.isEmpty
                              ? Center(child: TextWidget(text:'No Web archives'))
                              : ListView(
                                  children: listViewChildren,
                                ))
                    ],
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 7, right: 10),
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child:const Icon(Icons.close)),
                      ))
                ],
              ),
            ),
          );
        });
  }

  void share() {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var webViewModel = browserModel.getCurrentTab()?.webViewModel;
    var url = webViewModel?.url;
    if (url != null) {
      Share.share(url.toString(), subject: webViewModel?.title);
    }
  }

  void toggleDesktopMode() async {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var webViewModel = browserModel.getCurrentTab()?.webViewModel;
    var webViewController = webViewModel?.webViewController;

    var currentWebViewModel = Provider.of<WebViewModel>(context, listen: false);

    if (webViewController != null) {
      webViewModel?.isDesktopMode = !webViewModel.isDesktopMode;
      currentWebViewModel.isDesktopMode = webViewModel?.isDesktopMode ?? false;

      var currentSettings = await webViewController.getSettings();
      if (currentSettings != null) {
        currentSettings.preferredContentMode =
            webViewModel?.isDesktopMode ?? false
                ? UserPreferredContentMode.DESKTOP
                : UserPreferredContentMode.RECOMMENDED;
        await webViewController.setSettings(settings: currentSettings);
      }
      //additionally added this code for dekstop mode
      if (currentSettings!.preferredContentMode ==
          UserPreferredContentMode.DESKTOP) {
        String js =
            "document.querySelector('meta[name=\"viewport\"]').setAttribute('content', 'width=1024px, initial-scale=' + (document.documentElement.clientWidth / 1024));";
        await webViewController.evaluateJavascript(source: js);
        await webViewController.zoomOut();
      }
// this is removed by me
      // await webViewController.reload();
    }
  }

  void showUrlInfo() {
    var webViewModel = Provider.of<WebViewModel>(context, listen: false);
    var url = webViewModel.url;
    if (url == null || url.toString().isEmpty) {
      return;
    }

    route = CustomPopupDialog.show(
      context: context,
      transitionDuration: customPopupDialogTransitionDuration,
      builder: (context) {
        return UrlInfoPopup(
          route: route!,
          transitionDuration: customPopupDialogTransitionDuration,
          onWebViewTabSettingsClicked: () {
            goToSettingsPage();
          },
        );
      },
    );
  }

  void goToDevelopersPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const DevelopersPage()));
  }

  void goToSettingsPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SettingsPage()));
  }

  void openProjectPopup() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return const ProjectInfoPopup();
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  void takeScreenshotAndShow() async {
    var webViewModel = Provider.of<WebViewModel>(context, listen: false);
    var screenshot = await webViewModel.webViewController?.takeScreenshot();
    // var themeProvider = Provider.of<DarkThemeProvider>(context,listen: false);
    if (screenshot != null) {
      var dir = await getApplicationDocumentsDirectory();
      File file = File(
          "${dir.path}/screenshot_${DateTime.now().microsecondsSinceEpoch}.png");
      await file.writeAsBytes(screenshot);

      Future.delayed(
          Duration(
            seconds: 3,
          ), () {
        if (Navigator.canPop(context)) Navigator.pop(context);
      });
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            insetPadding: EdgeInsets.all(40),
            child: Container(
              height: MediaQuery.of(context).size.height / 2.3,
              width: MediaQuery.of(context).size.width / 3,
              // height: 300,
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                  color: Colors
                      .transparent, //themeProvider.darkTheme ? Color(0xff282836) : Color(0xffFFFFFF),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          width: 5,
                          color: Color(0xff3F3F3F), // s.black
                        )),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          screenshot,
                          height: MediaQuery.of(context).size.height / 3,
                          fit: BoxFit.cover,
                        )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: MaterialButton(
                          elevation: 0,
                          color:const Color(0xff3F3F3F), // Color(0xff00B134),
                          disabledColor: Color(0xff2C2C3B),
                          //minWidth: double.minPositive,
                          height: 40,
                          child:const TextWidget(text:'Share',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                18.0), // Adjust the radius as needed
                          ),
                          onPressed: () async {
                            await ShareExtend.share(file.path, "image");
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
          // return AlertDialog(
          //   content: Image.memory(screenshot),
          //   actions: <Widget>[
          //     ElevatedButton(
          //       child: const Text("Share"),
          //       onPressed: () async {
          //         await ShareExtend.share(file.path, "image");
          //       },
          //     )
          //   ],
          // );
        },
      );
//  Future.delayed(Duration(
//         seconds: 3,),(){
//           Navigator.pop(context);
//         });
      //  file.delete();
    }
  }
}
