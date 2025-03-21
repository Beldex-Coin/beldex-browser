import 'dart:convert';

import 'package:beldex_browser/src/browser/ai/constants/icon_constants.dart';
import 'package:beldex_browser/src/browser/ai/constants/string_constants.dart';
import 'package:beldex_browser/src/browser/ai/ui/views/beldexai_chat_screen.dart';
import 'package:beldex_browser/src/browser/ai/view_models/chat_view_model.dart';
import 'package:beldex_browser/src/browser/app_bar/sample_popup.dart';
// import 'package:beldex_browser/src/browser/app_bar/sample_webview_tab_app_bar.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/pages/settings/search_settings_page.dart';
import 'package:beldex_browser/src/browser/util.dart';
import 'package:beldex_browser/src/browser/webview_tab.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

String formatUrl(String url) {
  if (kDebugMode) {
    print('*****************$url');
  }
  // Regular expression pattern to check for a domain-like structure
  var domainPattern = RegExp(r'^(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}$');

  // Check if the URL starts with http:// or https://
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  } else if (domainPattern.hasMatch(url)) {
    // If the URL is a domain but doesn't start with http:// or https://, prepend 'https://'
    if (kDebugMode) {
      print('https://$url');
    }
    return 'https://$url';
  } else {
    // If the URL is not a domain-like string, return it as is
    return url;
  }
}

bool isAllTextSelected(TextSelection selection, String text) {
  return selection.baseOffset == 0 && selection.extentOffset == text.length;
}

class SearchScreen extends StatefulWidget {
  final TextEditingController controller;
//  final String pageTitle;
//  final String favIcons;
  final BrowserModel browserModel;
  final BrowserSettings settings;
  final dynamic webViewController;
  final WebViewModel webViewModel;
  final Function(WebUri url)? addNewTab;
  SearchScreen({
    super.key,
    required this.controller,
    required this.browserModel,
    required this.settings,
    required this.webViewController,
    required this.webViewModel,
    this.addNewTab, //required this.pageTitle, required this.favIcons,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  FocusNode? _focusNode;
  List<SearchShortcutListModel> selectedListItems = [];
  late List<SearchShortcutListModel> searchShortcutItems = [];
  String pageTitle = '';
  List<Favicon> favIcon = [];
  late List<ContextMenuButtonItem> buttonItems = [];
  late EditableTextState editableState = EditableTextState();
  late int duration;
  String canShowSearchAI = '';
  @override
  void initState() {
    super.initState();
    getDataForIconsAndTitle();
    setDuration(context);
    //loadSearchShortcutListItems();
  }

  getDataForIconsAndTitle() async {
    if (widget.webViewController != null) {
      setState(() {});
      pageTitle = await widget.webViewController.getTitle() ==
              "data:text/html;charset=utf-8;base64,"
          ? widget.controller.text
          : await widget.webViewController.getTitle();
      favIcon = await widget.webViewController.getFavicons();

      print('data from pageTitle -----> $pageTitle ${favIcon[0].url}');
    }
  }

  Future<void> loadSearchShortcutListItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Read the list from SharedPreferences
    String? storedData = prefs.getString('searchShortcutItems');
    if (storedData != null) {
      List<dynamic> decodedData = json.decode(storedData);
      setState(() {
        searchShortcutItems = decodedData
            .map((item) => SearchShortcutListModel.fromJson(item))
            .toList();
      });
    } else {
      // If no data is stored, use the default list
      setState(() {
        searchShortcutItems = [
          SearchShortcutListModel(
            name: 'Beldex search engine',
            url: '',
            searchUrl: '',
            assetIcon: 'assets/images/Beldex_logo_svg 1.svg',
            isActive: true,
          ),
          SearchShortcutListModel(
            name: 'Google',
            url: '',
            searchUrl: '',
            assetIcon: 'assets/images/Google 1.svg',
            isActive: true,
          ),
          SearchShortcutListModel(
            name: 'DuckDuckGo',
            url: '',
            searchUrl: '',
            assetIcon: 'assets/images/DuckDuckGo 2.svg',
            isActive: true,
          ),
          SearchShortcutListModel(
              name: 'Yahoo',
              url: '',
              searchUrl: '',
              assetIcon: 'assets/images/Yahoo 1.svg',
              isActive: true),
          SearchShortcutListModel(
              name: 'Bing',
              url: '',
              searchUrl: '',
              assetIcon: 'assets/images/Bing 1.svg',
              isActive: false),
          SearchShortcutListModel(
              name: 'Ecosia',
              url: '',
              searchUrl: '',
              assetIcon: 'assets/images/Ecosia.svg',
              isActive: false),
          SearchShortcutListModel(
              name: 'Youtube',
              url: '',
              searchUrl: '',
              assetIcon: 'assets/images/youtube.svg',
              isActive: false),
          SearchShortcutListModel(
              name: 'Twitter',
              url: '',
              searchUrl: '',
              assetIcon: 'assets/images/twitter 1.svg',
              isActive: true),
          SearchShortcutListModel(
              name: 'Wikipedia',
              url: '',
              searchUrl: '',
              assetIcon: 'assets/images/Wikipedia 1.svg',
              isActive: true),
          SearchShortcutListModel(
              name: 'Reddit',
              url: '',
              searchUrl: '',
              assetIcon: 'assets/images/Reddit 1.svg',
              isActive: false),
          SearchShortcutListModel(
            name: 'Search settings',
            url: '',
            searchUrl: '',
            assetIcon: 'assets/images/settings.svg',
            isActive: true,
          ),
        ];

        // searchShortcutItems = searchShortcutItems + items;
      });
    }
  }

  List<SearchShortcutListModel> getSelectedItems() {
    print('all the items --> ${searchShortcutItems[0].name}');
    return searchShortcutItems.where((item) => item.isActive).toList();
  }

  setDuration(BuildContext context) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    setState(() {
      if (browserModel.webViewTabs.isEmpty) {
        duration = 400;
        print('duration ---------> $duration');
      } else {
        duration = 0;
        print('duration ---------> $duration');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    // var webViewModel = Provider.of<WebViewModel>(context, listen: true);
    // print('this is the favIcons list is ${widget.favIcons}');
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();
    final theme = Theme.of(context);
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
     final selecteditemsProvider = Provider.of<SelectedItemsProvider>(context, listen: false);
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(90),
          child: Container(
            height: 45,
            width: double.infinity,
            margin:
                const EdgeInsets.only(top: 40, left: 10, right: 10, bottom: 8),
            decoration: BoxDecoration(
                color: themeProvider.darkTheme
                    ? const Color(0xff282836)
                    : const Color(0xffF3F3F3),
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [

                // SearchSettingsPopupList(
                //   browserModel: browserModel,
                //   browserSettings: settings,
                // ),
                  Container(
        height: 33,
        width: 33,
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
            color:
                themeProvider.darkTheme ? Color(0xff39394B) : Color(0xffffffff),
            borderRadius: BorderRadius.circular(5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              selecteditemsProvider.value,
              color: selecteditemsProvider.value == 'assets/images/Reddit 1.svg' ||
                      selecteditemsProvider.value == 'assets/images/Wikipedia 1.svg' ||
                      selecteditemsProvider.value == 'assets/images/twitter 1.svg'
                  ? themeProvider.darkTheme
                      ? Colors.white
                      : Colors.black
                  : null,
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: 2,
              color: Colors.transparent,
            )
          ],
        ),
      ),
                Expanded(
                  flex: 4,
                  child: TextField(
                    onSubmitted: (value) {
                      String trimmedValue = value.trim();
                     if(trimmedValue.isNotEmpty){
                       var url = WebUri(formatUrl(value.trim()));
                      if (!url.scheme.startsWith("http") &&
                          !Util.isLocalizedContent(url)) {
                        url = WebUri(
                            widget.settings.searchEngine.searchUrl + value);
                      }
                      //Navigator.pop(context, url);
                      // browserModel.updateIsNewTab(false);
                      if (widget.webViewController != null) {
                        widget.webViewController!
                            .loadUrl(urlRequest: URLRequest(url: url));
                      } else {
                        if (mounted) setState(() {});
                        print('comes inside new tab');
                        //  browserModel.updateIsNewTab(false);
                        addNewTab(url: url);
                        widget.webViewModel.url = url;

                        // widget.webViewController!.getTitle();
                      }
                      vpnStatusProvider.updateCanShowHomeScreen(false);
                      Future.delayed(Duration(milliseconds: duration), () {
                        Navigator.pop(context, url);
                      });
                     }

                      
                    },
                    keyboardType: TextInputType.url,
                    focusNode: _focusNode,
                    autofocus: true,
                    controller: _searchController,
                    textInputAction: TextInputAction.go,
                    contextMenuBuilder: (context, editableTextState) {
                      //final List<ContextMenuButtonItem>
                      buttonItems = editableTextState.contextMenuButtonItems;

                      editableState = editableTextState;

                      buttonItems.clear(); // Clear all default options
                      if (_searchController.text.isEmpty) {
                        buttonItems.add(ContextMenuButtonItem(
                            label: 'Paste',
                            onPressed: () {
                              Clipboard.getData('text/plain').then((value) {
                                if (value != null && value.text != null) {
                                  final text = _searchController.text;
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
                                  _searchController.text = newText;
                                  if(_searchController.text.trim().isEmpty || containsUrl(_searchController.text)){
                                    print("The User Message Contains Url 1");
                                  canShowSearchAI= '';
                                    }else
                                      canShowSearchAI= _searchController.text;
                         // print('BELDEX AI ---------> $canShowSearchAI');
        
                                  //canShowSearchAI = _searchController.text;
                                  final newSelection = TextSelection.collapsed(
                                    offset:
                                        selection.start + value.text!.length,
                                  );
                                  _searchController.selection = newSelection;
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
                                  _searchController.text;
                              final String newFindOnPageText =
                                  findOnPageText.replaceRange(
                                      selection.start, selection.end, '');

                              print(
                                  'Cut value Editable Text ---> $findOnPageText -- $newFindOnPageText -- $newText');
                              _searchController.text =
                                  findOnPageText; //newFindOnPageText;
                            }
                            //  // Clipboard.setData(ClipboardData(text: editableTextState.textEditingValue.text));
                            //   editableTextState.cutSelection(SelectionChangedCause.tap);
                            //   _searchController.clear();
                            //   //editableTextState.hideToolbar(false);
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
                                final text = _searchController.text;
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
                                _searchController.text = newText;
                                final newSelection = TextSelection.collapsed(
                                  offset: selection.start + value.text!.length,
                                );
                                _searchController.selection = newSelection;
                                editableTextState.hideToolbar(false);
                              }
                            });
                          },
                        ));
                      }
                      return AdaptiveTextSelectionToolbar.buttonItems(
                        anchors: editableTextState.contextMenuAnchors,
                        buttonItems: buttonItems,
                      );
                    },
                    onChanged: (value) {
                       setState(() {
                        if(containsUrl(_searchController.text) || _searchController.text.trim().isEmpty){
                          print("The User Message Contains url 22");
                          canShowSearchAI= '';
                        }else
                          canShowSearchAI= _searchController.text;
                         // print('BELDEX AI ---------> $canShowSearchAI');
                        });
                      if (value.isEmpty) {
                        editableState.hideToolbar(true);
                       
                      }
                    },
                    // onEditingComplete: (){
                    //   setState(() {
                    //                               print('BELDEX AI 2---------> $canShowSearchAI');

                    //   });
                    // },
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(
                            top: 5.0, right: 10.0, bottom: 10.0),
                        border: InputBorder.none,
                        hintText: "Search or enter Address",
                        hintStyle: TextStyle(
                            color: const Color(0xff6D6D81),
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal)),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                _searchController.text.isNotEmpty
                    ? Container(
                        width: 40,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close_outlined,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_searchController.text.isNotEmpty) {
                                editableState.hideToolbar(true);
                              }
                              _searchController.text = '';
                              buttonItems.clear();
                              canShowSearchAI = '';
                            });
                          },
                        ))
                    : SizedBox()
              ],
            ),
          ),),
      body: Column(
        children: [
          widget.controller.text == '' || widget.controller.text.isEmpty || vpnStatusProvider.canShowHomeScreen
              ? Container()
              : Container(
                  height: 55,
                  width: double.infinity,
                  margin: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: themeProvider.darkTheme ? Color(0xff282836): Color(0xffDADADA)),
                      // color: themeProvider.darkTheme
                      //     ? const Color(0xff282836)
                      //     : const Color(0xffF3F3F3),
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        height: 40,
                        width: 40,
                        child: favIcon == [] || favIcon.length == 0
                            ? Container()
                            : Image.network(
                                '${favIcon[0].url.toString()}',
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.web);
                                },
                              ),
                      ),
                      Expanded(
                          flex: 5,
                          child: GestureDetector(
                            onTap: () {
                              
                              if (widget.controller.text.isNotEmpty) {
                                
                                var url = WebUri(
                                    formatUrl(widget.controller.text.trim()));
                                if (!url.scheme.startsWith("http") &&
                                    !Util.isLocalizedContent(url)) {
                                  url = WebUri(
                                      widget.settings.searchEngine.searchUrl +
                                          widget.controller.text);
                                }
                                // browserModel.updateIsNewTab(false);
                                if (widget.webViewController != null) {
                                  widget.webViewController!.loadUrl(
                                      urlRequest: URLRequest(url: url));
                                  print(
                                      'THE WEBVIEWMODEL 4 --> ${widget.webViewModel.url}');
                                } else {
                                  if (mounted) setState(() {});
                                  print('comes inside new tab');
                                  //  browserModel.updateIsNewTab(false);
                                  addNewTab(url: url);
                                  widget.webViewModel.url = url;
                                  print('THE WEBVIEWMODEL 3 --> ${widget.webViewModel.url}');
                                  // widget.webViewController!.getTitle();
                                }
                                 vpnStatusProvider.updateCanShowHomeScreen(false);
                                Future.delayed(Duration(milliseconds: duration),
                                    () {
                                  Navigator.pop(context, url);
                                });
                              }
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                pageTitle.isNotEmpty
                                    ? Container(
                                        child: Text('${pageTitle.toString()}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16)),
                                      )
                                    : Container(),
                                widget.controller.text.isNotEmpty
                                    ? Container(
                                        child: Text(
                                          '${widget.controller.text}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: const Color(0xff00B134)),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          )),
                      Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  child: IconButton(
                                      onPressed: () {
                                        _shareUrl('${widget.controller.text}');
                                        // Navigator.pop(context);
                                      },
                                      icon: SvgPicture.asset(
                                        'assets/images/Shares.svg',
                                        color: themeProvider.darkTheme
                                            ? Colors.white
                                            : Colors.black,
                                      )),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _searchController.text =
                                              widget.controller.text;
                                        });
                                      },
                                      icon: SvgPicture.asset(
                                        'assets/images/edit.svg',
                                        color: themeProvider.darkTheme
                                            ? Colors.white
                                            : Colors.black,
                                      )),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  child: IconButton(
                                      onPressed: () {
                                        _copyToClipboard(
                                            '${widget.controller.text}');
                                      },
                                      icon: SvgPicture.asset(
                                          'assets/images/copy.svg')),
                                ),
                              ),
                            ],
                          ))
                    ],
                  ),
                ),

              canShowSearchAI != '' || canShowSearchAI.isNotEmpty ?  GestureDetector(
                onTap: ()async{
                  Navigator.pop(context);
                  bool showWelcomeMessage = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSubmitted', true);
    bool? hasSubmitted = prefs.getBool('hasSubmitted');
    setState(() {});
      showWelcomeMessage = (hasSubmitted ?? false);
      print("Show welcome page ---------->$hasSubmitted -------  $showWelcomeMessage");
   
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
     builder: (context){

     return BeldexAIScreen(isWelcomeShown:false ,searchWord:canShowSearchAI); //DraggableAISheet();
          //return BeldexAiScreen();
     });
                },
                child:
                Container(
  height: 60,
  margin: EdgeInsets.only(left: 10, right: 10, bottom: 8),
  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
  decoration: BoxDecoration(
    border: Border.all(
      color: themeProvider.darkTheme ? Color(0xff42425F) : Color(0xffDADADA),
    ),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(
    children: [
      SvgPicture.asset(
        IconConstants.beldexAILogoSvg,
        height: 20,
        width: 25,
      ),
      SizedBox(width: 8), // Add spacing between the icon and text
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              canShowSearchAI,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Ask Beldex AI',
              style: TextStyle(
                color: Color(0xff00B134),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 9.0),
        child: SvgPicture.asset(
          'assets/images/ai-icons/arrow.svg',
          height: 10,
          width: 20, // Adjust width to ensure flexibility
        ),
      ),
    ],
  ),
),

              ):SizedBox(),
        ],
      ),
    );
  }

  // Function to copy URL to clipboard
  void _copyToClipboard(String url) {
    Clipboard.setData(ClipboardData(text: url));
    Fluttertoast.showToast(msg: 'Copied to clipboard');
  }

  // Function to share URL
  void _shareUrl(String url) async {
    if (await canLaunch(url)) {
      await Share.share(url);
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(msg: 'Unable to share URL');
    }
  }

  void addNewTab({WebUri? url}) {
    final browserModel = Provider.of<BrowserModel>(context, listen: false);
    final settings = browserModel.getSettings();
    final webViewModel = Provider.of<WebViewModel>(context, listen: false);
    final selectedItemsProvider = Provider.of<SelectedItemsProvider>(context,listen: false);
    //browserModel.updateIsNewTab(false);
    url ??= settings.homePageEnabled && settings.customUrlHomePage.isNotEmpty
        ? WebUri(settings.customUrlHomePage)
        : WebUri(settings.searchEngine.url);
 webViewModel.settings?.minimumFontSize = selectedItemsProvider.fontSize.round();
        print('The WEBVIEWMODEL fontSize ${webViewModel.settings?.minimumFontSize}----- ${selectedItemsProvider.fontSize.round()}');
    browserModel.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(url: url,settings: webViewModel.settings),
    ));
  }

  PreferredSize appBars(DarkThemeProvider themeProvider) {
    final theme = Theme.of(context);
    return PreferredSize(
        preferredSize: Size.fromHeight(90),
        child: Container(
          height: 45,
          width: double.infinity,
          margin: EdgeInsets.only(top: 40, left: 10, right: 10, bottom: 8),
          decoration: BoxDecoration(
              color: themeProvider.darkTheme
                  ? const Color(0xff282836)
                  : const Color(0xffF3F3F3),
              borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: TextField(
                  keyboardType: TextInputType.url,
                  focusNode: _focusNode,
                  autofocus: true,
                  controller: _searchController,
                  onEditingComplete: () {
                    Navigator.pop(context, _searchController);
                  },
                  textInputAction: TextInputAction.go,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(
                        left: 10.0, top: 10.0, right: 10.0, bottom: 10.0),
                    border: InputBorder.none,
                    hintText: "Search or enter Address",
                    hintStyle: theme.textTheme
                        .bodyMedium, //const TextStyle(fontSize: 14.0,fontWeight: FontWeight.normal),
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                    child: IconButton(
                  icon: const Icon(
                    Icons.close_outlined,
                    size: 20,
                  ),
                  onPressed: () {},
                )),
              )
            ],
          ),
        ));
  }
}
