import 'dart:convert';

import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/locale_provider.dart';
import 'package:beldex_browser/src/browser/ai/constants/icon_constants.dart';
import 'package:beldex_browser/src/browser/ai/constants/string_constants.dart';
import 'package:beldex_browser/src/browser/ai/ui/views/beldexai_chat_screen.dart';
import 'package:beldex_browser/src/browser/ai/view_models/chat_view_model.dart';
import 'package:beldex_browser/src/browser/app_bar/sample_popup.dart';
// import 'package:beldex_browser/src/browser/app_bar/sample_webview_tab_app_bar.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/pages/search_engine/searchengine_icon_placeholder.dart';
import 'package:beldex_browser/src/browser/pages/settings/app_language_screen.dart';
import 'package:beldex_browser/src/browser/pages/settings/search_settings_page.dart';
import 'package:beldex_browser/src/browser/pages/voice_search/voice_search.dart';
import 'package:beldex_browser/src/browser/util.dart';
import 'package:beldex_browser/src/browser/webview_tab.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/tts_provider.dart';
import 'package:beldex_browser/src/utils/screen_secure_provider.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
//import 'package:searchfield/searchfield.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

bool isSearchScreenActive(BuildContext context) {
  return ModalRoute.of(context)?.settings.arguments is SearchScreen;
}






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
  static bool isActive = false;
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




   final Dio _dio = Dio();
  //List<SearchFieldListItem<String>> _suggestions = [];



  @override
  void initState() {
    super.initState();
    SearchScreen.isActive = true;
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






//   Future<void> fetchSuggestions(String query) async {
//      print('ERROR TEXT RESPONSE AUTOCOMPLETE CALLING---');
//   if (query.isEmpty) {
//     setState(() => _suggestions = []);
//     return;
//   }

//   try {
//     final response = await _dio.get(
//       'http://suggestqueries.google.com/complete/search',
//       queryParameters: {
//         'client': 'firefox',
//         'q': query,
//       },
//       options: Options(responseType: ResponseType.json), //  ensure JSON
//     );
//      print('ERROR TEXT RESPONSE AUTOCOMPLETE ${response.statusCode} --- ${response.data}');
//     if (response.statusCode == 200) {
//   final data = jsonDecode(response.data); //  convert to List
//   if (data is List && data.length > 1 && data[1] is List) {
//     final List<dynamic> suggestionsList = data[1];
//     setState(() {
//       _suggestions = suggestionsList
//           .map((item) => SearchFieldListItem<String>(
//                 item.toString(),
//                 item: item.toString(),
//               ))
//           .toList();
//     });
//   }}
//   } catch (e) {
//     debugPrint("Error fetching suggestions: $e");
//   }
// }






// final List<String> allSuggestions = [
//     "google.com",
//     "github.com",
//     "flutter.dev",
//     "stackoverflow.com",
//     "openai.com"
//   ];
String _currentQuery = "";

  List<String> filteredSuggestions = [];


  // Future<void> _filterSuggestions(String query) async {
  //    _currentQuery = query;

  //  if (query.isEmpty) {
  //   print('The User Message Contains url 33 $query');
  //     setState(() => filteredSuggestions = []);
  //     return;
  //   }

  //   //setState(() => _isLoading = true);

  //   try {
  //     final response = await _dio.get(
  //       'http://suggestqueries.google.com/complete/search',
  //       queryParameters: {
  //         'client': 'firefox',
  //         'q': query,
  //       },
  //       options: Options(responseType: ResponseType.plain), // force plain text
  //     );

  //     // Parse manually
  //     final List<dynamic> data = jsonDecode(response.data);
  //     final List<String> suggestions = List<String>.from(data[1]);

  //     setState(() {
  //       filteredSuggestions = suggestions;
  //     });
  //     print('The User Message Contains url 44 ${suggestions.length} ${filteredSuggestions.length}');
  //   } catch (e) {
  //     print("Error fetching suggestions: $e");
  //     setState(() => filteredSuggestions = []);
  //   } finally {
  //     //setState(() => _isLoading = false);
  //   }
  // }
Future<void> _filterSuggestions(String query) async {
  _currentQuery = query;

  if (query.isEmpty) {
    print('The User Message Contains url 33 $query');
    setState(() => filteredSuggestions = []);
    return;
  }

  try {
    final response = await _dio.get(
      'http://suggestqueries.google.com/complete/search',
      queryParameters: {
        'client': 'firefox',
        'q': query,
      },
      options: Options(responseType: ResponseType.bytes), // get raw bytes
    );

    // Decode response as UTF-8 manually
    final decoded = utf8.decode(response.data);
    final List<dynamic> data = jsonDecode(decoded);
    final List<String> suggestions = List<String>.from(data[1]);

    setState(() {
      filteredSuggestions = suggestions;
    });

    print('The User Message Contains url 44 ${suggestions.length} ${filteredSuggestions.length}');
  } catch (e) {
    print("Error fetching suggestions: $e");
    setState(() => filteredSuggestions = []);
  }
}

  // void _filterSuggestions(String input) {
  //   setState(() {
  //     if (input.isEmpty) {
  //       filteredSuggestions = [];
  //     } else {
  //       filteredSuggestions = allSuggestions
  //           .where((s) => s.toLowerCase().contains(input.toLowerCase()))
  //           .toList();
  //     }
  //   });
  // }


//  void _openVoiceDialog() {
//     showVoiceDialog(
//       context,Provider.of<DarkThemeProvider>(context,listen: false),
//       onResult: (recognizedText) {
//         _searchController.text = recognizedText; // update controller
//         setState(() {
//           canShowSearchAI = _searchController.text;
//         });
//       },
//     );
//   }

void _openVoiceDialog() async {
  var status = await Permission.microphone.status;
  final loc = AppLocalizations.of(context)!;
  if (status.isDenied) {
    status = await Permission.microphone.request();
    print('STATUS MICROPHONE ___> $status');
  }

  if (status.isPermanentlyDenied) {
    // User selected "Don't ask again"
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title:  Text(loc.micPermissionRequired),
        content:  Text(
                   "${loc.uPermanentlyDeniedMicAccess}"
                   "${loc.plsEnableMicInAppSettings}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel,style: TextStyle(color: Colors.blue),),
          ),
          TextButton(
            onPressed: () {
              openAppSettings(); // from permission_handler
              Navigator.pop(ctx);
            },
            child: Text(loc.openSettings,style: TextStyle(color: Colors.green),),
          ),
        ],
      ),
    );
    return;
  }

  if (status.isGranted) {
    print('STATUS MICROPHONE granted -> $status');
  showVoiceDialog(
  context,
  Provider.of<DarkThemeProvider>(context, listen: false),
  Provider.of<TtsProvider>(context,listen: false),true,
  onResult: (recognizedText) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Update the controller safely
      _searchController.text = recognizedText;

      // Update the state safely
      setState(() {
        canShowSearchAI = _searchController.text;
      });
    });
  },
);

  }
}


Future<void> _openQRScanner() async {
  final themeProvider = Provider.of<DarkThemeProvider>(context,listen: false);
  final loc = AppLocalizations.of(context)!;
  var status = await Permission.camera.status;
  if(status.isDenied){
    setState(() {
      
    });
    status = await Permission.camera.request();
  }
  if (status.isGranted) {
    // final scannedValue = await Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    // );

final scannedValue = await showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: themeProvider.darkTheme ? Color(0xff282836) : Color(0xffF3F3F3),
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          height: 450,
          padding: EdgeInsets.all(14),
          //color: Color(0xff282836),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top:3,bottom: 8),//only(left:12,right:12),
                margin: EdgeInsets.only(bottom: 5),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                 // color: Colors.blue,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline:TextBaseline.ideographic,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: SvgPicture.asset('assets/images/ai-icons/close.svg',color: Colors.transparent,)),
                      Text(loc.scanQR, //"Scan QR",
                          style: TextStyle( fontSize: 20,fontFamily: 'Poppins',fontWeight: FontWeight.w600)),
                      
                      
                      GestureDetector(
                       onTap: () {
                          MobileScannerController().stop();
                          Navigator.pop(context);
                        } , // no v
                        child: Padding(
                          padding: EdgeInsets.only(bottom:8,top: 5 ),
                          child: SvgPicture.asset('assets/images/ai-icons/close.svg',color: themeProvider.darkTheme ? Colors.white : Colors.black, height: 18,)),
                      ),
                      // IconButton(
                      //   icon: const Icon(Icons.close,),
                      //   onPressed: () {
                      //     MobileScannerController().stop();
                      //     Navigator.pop(context);
                      //   } , // no value
                      // ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MobileScanner(
                    fit: BoxFit.cover,
                    onDetect: (capture) {
                      final barcode = capture.barcodes.first;
                      final code = barcode.rawValue;
                      if (code != null) {
                        Navigator.pop(context, code); // return value
                      }
                    },
                  ),
                ),
              ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Center(child: Text(loc.alignQRInCenterOFFrame,
              textAlign: TextAlign.center ,style: TextStyle(fontSize: 16,fontFamily: 'Poppins'),)))
            ],
          ),
        ),
      );
    },
  );

    if (scannedValue != null) {
      setState(() { _searchController.text = scannedValue;
       canShowSearchAI = '';// _searchController.text;
      });
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text(loc.cameraPermissionDenied)),
    );
  }
}






  @override
  void dispose() {
    SearchScreen.isActive = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    // var webViewModel = Provider.of<WebViewModel>(context, listen: true);
    // print('this is the favIcons list is ${widget.favIcons}');
    final basicProvider = Provider.of<BasicProvider>(context,listen: false);
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
    // final selecteditemsProvider = Provider.of<SelectedItemsProvider>(context, listen: false);
     final ttsProvider = Provider.of<TtsProvider>(context,listen: false);
     final appLocaleProvider = Provider.of<LocaleProvider>(context,listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
            child: 
            Row(
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
            (browserModel.value.startsWith('http://') || browserModel.value.startsWith('https://')) ?
            CachedNetworkImage(
                            imageUrl: browserModel.value,
                            width: 20,
                            height: 20,
                            errorWidget: (_, __, ___) => SearchEnginePlaceholder(name:settings.searchEngine.name,size: 20,),
                          )
             :
            SvgPicture.asset(
              browserModel.value,
              color: browserModel.value == 'assets/images/Reddit 1.svg' ||
                      browserModel.value == 'assets/images/Wikipedia 1.svg' ||
                      browserModel.value == 'assets/images/twitter 1.svg'
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
                            .loadUrl(urlRequest: URLRequest(url: url,
                            headers: {
            "Accept-Language": appLocaleProvider.fullLocaleId,
          }
                            ));
                      } else {
                        if (mounted) setState(() {});
                        print('comes inside new tab');
                        //  browserModel.updateIsNewTab(false);
                        addNewTab(url: url);
                        widget.webViewModel.url = url;

                        // widget.webViewController!.getTitle();
                      }
                      vpnStatusProvider.updateCanShowHomeScreen(false);
                      ttsProvider.updateTTSDisplayStatus(false);
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
                    magnifierConfiguration: TextMagnifierConfiguration.disabled,
                    contextMenuBuilder: (context, editableTextState) {
                      //final List<ContextMenuButtonItem>
                      buttonItems = editableTextState.contextMenuButtonItems;

                      editableState = editableTextState;

                      buttonItems.clear(); // Clear all default options
                      if (_searchController.text.isEmpty) {
                        buttonItems.add(ContextMenuButtonItem(
                            label:loc.paste,// 'Paste',
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
                                  if(_searchController.text.trim().isEmpty){
                                    print("The User Message Contains Url 1");
                                  canShowSearchAI= '';
                                    }else if(containsUrl(_searchController.text)){
                                      canShowSearchAI = '';
                                      _filterSuggestions(_searchController.text);
                                    }
                                    else{
                                      canShowSearchAI= _searchController.text;
                                      _filterSuggestions(_searchController.text);
                                    }
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
                         buttonItems.add(
  ContextMenuButtonItem(
    label:loc.copy,// 'Copy',
    onPressed: () {
      final TextEditingValue value = editableTextState.textEditingValue;
      final TextSelection selection = value.selection;

      if (!selection.isCollapsed) {
        final String selectedText = selection.textInside(value.text);

        // Copy to clipboard
        Clipboard.setData(ClipboardData(text: selectedText));
        print("Copied value --> $selectedText");

        // Clear the selection (move cursor to the end of selection)
        editableTextState.userUpdateTextEditingValue(
          value.copyWith(
            selection: TextSelection.collapsed(offset: selection.end),
          ),
          SelectionChangedCause.toolbar,
        );
      }

      editableTextState.hideToolbar(false);
    },
  ),
);

                        // buttonItems.add(ContextMenuButtonItem(
                        //   label: 'Copy',
                        //   onPressed: () {
                        //     final TextEditingValue value =
                        //         editableTextState.textEditingValue;
                        //     final TextSelection selection = value.selection;

                        //     if (!selection.isCollapsed) {
                        //       final String selectedText =
                        //           selection.textInside(value.text);
                        //       Clipboard.setData(
                        //           ClipboardData(text: selectedText));
                        //       print("Copied value --> $selectedText");
                        //     }
                        //     editableTextState.hideToolbar(false);
                        //   },
                        // ));
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
                          label: loc.paste,// 'Paste',
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

                                 if(_searchController.text.trim().isEmpty){
                                    print("The User Message Contains Url 1");
                                  canShowSearchAI= '';
                                    }else if(containsUrl(_searchController.text)){
                                      canShowSearchAI = '';
                                      _filterSuggestions(_searchController.text);
                                    }else{
                                      canShowSearchAI= _searchController.text;
                                      _filterSuggestions(_searchController.text);
                                    }


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
                      return  AdaptiveTextSelectionToolbar.buttonItems(
                        anchors: editableTextState.contextMenuAnchors,
                        buttonItems: buttonItems,
                      );
                    },
                    onChanged: (value) {
                      _filterSuggestions(value);
                       setState(() {
                        if(containsUrl(_searchController.text) || _searchController.text.trim().isEmpty){
                          canShowSearchAI= '';
                          filteredSuggestions = [];
                          print("The User Message Contains url 22 ${filteredSuggestions.length}");

                        }else
                          canShowSearchAI= _searchController.text;
                         // print('BELDEX AI ---------> $canShowSearchAI');
                        });
                      if (value.isEmpty) {
                        editableState.hideToolbar(true);
                       
                      }
                    },
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(
                            top: 5.0, right: 10.0, bottom: 10.0),
                        border: InputBorder.none,
                        hintText:loc.searchOrEnterAddress,
                        hintStyle: TextStyle(
                            color: const Color(0xff6D6D81),
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal),
                            ),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Visibility(
                              visible: _searchController.text.trim().isEmpty, 
                              child: Container(
                                margin: EdgeInsets.only(right: 8),
                                //color: Colors.green,
                                width: 55,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  // crossAxisAlignment: CrossAxisAlignment.baseline,
                                  // textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    GestureDetector(
                                      onTap: _openQRScanner,
                                      
                                      child: SvgPicture.asset('assets/images/ai-icons/qr_reader.svg',color: themeProvider.darkTheme ? Colors.white : Colors.black,)),
                                      SizedBox(width: 9,),
                                    GestureDetector(
                                      onTap:_openVoiceDialog,
                                      // (){
                                      //   print('SpeechToText clciked');
                                      //   print('SpeechTo Text calling value ${_speechToText.isNotListening} ${_speechToText.isListening}');
                                      //   _speechToText.isNotListening ? _startListening() : _stopListening();
                                      //   },
                                      child: SvgPicture.asset('assets/images/ai-icons/Microphone 1.svg',color: themeProvider.darkTheme ? Colors.white : Colors.black,)),
                                  ],
                                ),
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
                              filteredSuggestions = [];
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
         // if( (widget.controller.text == '' || widget.controller.text.isEmpty || vpnStatusProvider.canShowHomeScreen) && filteredSuggestions.isEmpty)...[

          (widget.controller.text == '' || widget.controller.text.isEmpty || vpnStatusProvider.canShowHomeScreen) || filteredSuggestions.isNotEmpty
              ? Container()
              : 
              Container(
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
                                      urlRequest: URLRequest(url: url,
                                      headers: {
            "Accept-Language": appLocaleProvider.fullLocaleId,
          },
                                      ));
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
                                        _shareUrl('${widget.controller.text}',loc);
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
                                            '${widget.controller.text}',loc);
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
         // ],

if (filteredSuggestions.isNotEmpty && _searchController.text.trim().isNotEmpty && basicProvider.autoSuggest ) ...[
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color:themeProvider.darkTheme ? Color(0xff292937) : Color(0xffF3F3F3),
                ),
                padding: EdgeInsets.only(bottom: 5),
                margin: EdgeInsets.only(left:10,right:10,bottom: 10),
                constraints: BoxConstraints(
                  maxHeight: 200, // limit max height
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredSuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = filteredSuggestions[index];
                
                    final queryLower = _currentQuery.toLowerCase();
                    final suggestionLower = suggestion.toLowerCase();
                
                    final matchIndex = suggestionLower.indexOf(queryLower);
                
                    InlineSpan textSpan;
                    if (matchIndex != -1 && _currentQuery.isNotEmpty) {
                      textSpan = TextSpan(
                        children: [
                          TextSpan(
                            text: suggestion.substring(0, matchIndex),
                            style: TextStyle(
                              color: themeProvider.darkTheme ? Colors.white : Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: suggestion.substring(matchIndex, matchIndex + _currentQuery.length),
                            style:  TextStyle(
                              color: themeProvider.darkTheme ? Colors.white : Colors.black, //Colors.blue, // highlight color
                             // fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: suggestion.substring(matchIndex + _currentQuery.length),
                            style: TextStyle(
                              color: themeProvider.darkTheme ? Colors.white.withOpacity(0.5) : Color(0xff333333).withOpacity(0.5),
                            ),
                          ),
                        ],
                      );
                    } else {
                      textSpan = TextSpan(
                        text: suggestion,
                        style: TextStyle(
                          color: themeProvider.darkTheme ? Colors.white : Colors.black,
                        ),
                      );
                    }
                
                    return GestureDetector(
                      onTap: () async {
                        // handle tap
                String trimmedValue = suggestion.trim();
                    if(trimmedValue.isNotEmpty){
                      var url = WebUri(formatUrl(suggestion.trim()));
                     if (!url.scheme.startsWith("http") &&
                         !Util.isLocalizedContent(url)) {
                       url = WebUri(
                           widget.settings.searchEngine.searchUrl + suggestion);
                     }
                     //Navigator.pop(context, url);
                     // browserModel.updateIsNewTab(false);
                     if (widget.webViewController != null) {
                       widget.webViewController!
                           .loadUrl(urlRequest: URLRequest(url: url,
                           headers: {
            "Accept-Language": appLocaleProvider.fullLocaleId,
          }
                           ));
                     } else {
                       if (mounted) setState(() {});
                       print('comes inside new tab');
                       //  browserModel.updateIsNewTab(false);
                       addNewTab(url: url);
                       widget.webViewModel.url = url;
                
                       // widget.webViewController!.getTitle();
                     }
                     //filteredSuggestions = [];
                     vpnStatusProvider.updateCanShowHomeScreen(false);
                     Future.delayed(Duration(milliseconds: duration), () {
                       Navigator.pop(context, url);
                     });
                    }
                
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: themeProvider.darkTheme
                 ? SvgPicture.asset('assets/images/ai-icons/Search_suggestion.svg')
                 : SvgPicture.asset('assets/images/ai-icons/Search_suggestions_wht.svg'),
                            ),
                            Expanded(
                              child: RichText(
                                text: textSpan,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  _searchController.text = suggestion;
                                  if(containsUrl(suggestion)){
                                    canShowSearchAI = '';
                                  }else{
                                    canShowSearchAI= suggestion;
                                  }
                                });
                              },
                              child: SizedBox(
                                child:  themeProvider.darkTheme
                                  ? SvgPicture.asset('assets/images/ai-icons/arrow_suggestion.svg')
                                  : SvgPicture.asset('assets/images/ai-icons/arrow_suggestions_wht.svg'),
                              ),
                            )
                           
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],




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
    color:  themeProvider.darkTheme ? Color(0xff292937) : Color(0xffF3F3F3),
    // border: Border.all(
    //   color: themeProvider.darkTheme ? Color(0xff42425F) : Color(0xffDADADA),
    // ),
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
            Text(loc.askBeldexAI,
              //'Ask Beldex AI',
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
  void _copyToClipboard(String url,AppLocalizations loc) {
    Clipboard.setData(ClipboardData(text: url));
    Fluttertoast.showToast(msg:loc.copiedToClipboard,// 'Copied to clipboard'
    );
  }

  // Function to share URL
  void _shareUrl(String url,AppLocalizations loc) async {
    if (await canLaunch(url)) {
      await Share.share(url);
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(msg:loc.unableToShareUrl);
    }
  }

  void addNewTab({WebUri? url}) {
    final browserModel = Provider.of<BrowserModel>(context, listen: false);
    final settings = browserModel.getSettings();
    final webViewModel = Provider.of<WebViewModel>(context, listen: false);
    //final selectedItemsProvider = Provider.of<SelectedItemsProvider>(context,listen: false);
    //browserModel.updateIsNewTab(false);
    url ??= settings.homePageEnabled && settings.customUrlHomePage.isNotEmpty
        ? WebUri(settings.customUrlHomePage)
        : WebUri(settings.searchEngine.url);
 webViewModel.settings?.minimumFontSize = browserModel.fontSize.round();
        print('The WEBVIEWMODEL fontSize ${webViewModel.settings?.minimumFontSize}----- ${browserModel.fontSize.round()}');
    browserModel.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(url: url,settings: webViewModel.settings),
    ));
  }

  PreferredSize appBars(DarkThemeProvider themeProvider) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
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
                    hintText:loc.searchOrEnterAddress, //"Search or enter Address",
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
