import 'dart:ui';

import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/locale_provider.dart';
import 'package:beldex_browser/src/browser/app_bar/sample_popup.dart';
import 'package:beldex_browser/src/browser/app_bar/search_screen.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/search_engine_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/pages/search_engine/add_searchengine_provider.dart';
import 'package:beldex_browser/src/browser/pages/settings/app_language_screen.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/utils/screen_secure_provider.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:beldex_browser/src/widget/aboutpage.dart';
import 'package:beldex_browser/src/widget/text_widget.dart';
import 'package:belnet_lib/belnet_lib.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
//import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CrossPlatformSettings extends StatefulWidget {
  final double heightInDp;
  final double widthInDp;
  final double toggleSizeInDp;
   final double fontSizeInDp1;
  final double fontSizeInDp2;
  const CrossPlatformSettings({Key? key, required this.heightInDp, required this.widthInDp, required this.toggleSizeInDp, required this.fontSizeInDp1, required this.fontSizeInDp2}) : super(key: key);

  @override
  State<CrossPlatformSettings> createState() => _CrossPlatformSettingsState();
}

class _CrossPlatformSettingsState extends State<CrossPlatformSettings> {
  final TextEditingController _customHomePageController =
      TextEditingController();
  final TextEditingController _customUserAgentController =
      TextEditingController();

      late List<ContextMenuButtonItem> buttonItems = [];
  late EditableTextState editableState = EditableTextState();
  bool isSwitched = true;
  //final dynamicTextSizeWidget = DynamicTextSizeWidget();
  @override
  void initState() {
    super.initState();
    loadSwitchState();
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
  }


 _openLanguageScreen(){
   Navigator.push(context, MaterialPageRoute(builder: (context)=> AppLanguageScreen()));
 }


  @override
  void dispose() {
    _customHomePageController.dispose();
    _customUserAgentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    var vpnStatusProvider = Provider.of<VpnStatusProvider>(context,listen: false);
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        margin:const EdgeInsets.all(15),
        height: constraints.maxHeight,
        decoration: BoxDecoration(
            color: themeProvider.darkTheme
                ? const Color(0xff292937)
                : const Color(0xffF3F3F3),
            borderRadius: BorderRadius.circular(15)),
        child: RawScrollbar(
          padding: EdgeInsets.only(right: 5, top: 5),
          thickness: 1.8,
          child: Container(
            padding:
                const EdgeInsets.only(left: 20, right: 15, top: 15, bottom: 20),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: _buildBaseSettings(
                        themeProvider, constraints,vpnStatusProvider), // children,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

// for checking the screen security initial value
  Future<void> loadSwitchState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isSwitched = prefs.getBool('switchState') ?? true;
    });
  }

  // Function to save the switch state to SharedPreferences
  Future<void> saveSwitchState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('switchState', value);
  }

  bool isValidURL(String url) {
    final urlPattern =
        r'^(http|https):\/\/([A-Z0-9][A-Z0-9_-]*(?:\.[A-Z0-9][A-Z0-9_-]*)+):?(\d+)?\/?';
    final regex = RegExp(urlPattern, caseSensitive: false);
    return regex.hasMatch(url);
  }

  List<Widget> _buildBaseSettings(
      DarkThemeProvider themeProvider, BoxConstraints constraints,VpnStatusProvider vpnStatusProvider) {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    var settings = browserModel.getSettings();
    var currentWebViewModel = Provider.of<WebViewModel>(context, listen: true);
    var webViewController = currentWebViewModel.webViewController;
    // var selectedItemsProvider =
    //     Provider.of<SelectedItemsProvider>(context, listen: false);
    var basicProvider = Provider.of<BasicProvider>(context, listen: false);
    bool _showError = false;
    final localeProvider = Provider.of<LocaleProvider>(context,listen: true);
        final loc = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final addSearchEngineProvider = Provider.of<AddSearchEngineProvider>(context,listen: false);

//

// final screenSize = MediaQuery.of(context).size;

//     // Your pixel sizes
//     const double pixelHeight = 22.57;
//     const double pixelWidth = 39.97;
    
//      const double pixelToggleSize = 20.0; // Example toggle size in pixels
   
//     // Conversion to percentage of screen size
//     final double heightInPercentage = (pixelHeight / screenSize.height) * 100;
//     final double widthInPercentage = (pixelWidth / screenSize.width) * 100;

//     // Conversion to height and width in logical pixels (dp)
//     final double heightInDp = screenSize.height * (heightInPercentage / 100);
//     final double widthInDp = screenSize.width * (widthInPercentage / 100);


// final double toggleSizeInDp = (pixelToggleSize / screenSize.width) * screenSize.width;












    var widgets = <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: SizedBox(
          //height: constraints.maxHeight/7.5,
          //color: Colors.yellow,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Column(
                textBaseline: TextBaseline.alphabetic,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  TextWidget(text:loc.searchEngine, //"Search Engine",
                      style: theme.textTheme.bodyLarge!
                          .copyWith(fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600)),
                  TextWidget(
                      text:loc.searchEngineContent, //'Choose your preferred search engine for personalized browsing.',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: theme.textTheme.bodySmall!
                          .copyWith(fontWeight: FontWeight.w300,fontSize: widget.fontSizeInDp2)),
                ],
              ),
            ),
            PopupMenuTheme(
              data: PopupMenuThemeData(
                shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
      side: BorderSide(
        color: themeProvider.darkTheme
            ? const Color(0xff42425F)
            : const Color(0xffF3F3F3),
      ),
    ),
              ),
              child: PopupMenuButton<SearchEngineModel>(
                offset: Offset(-8, 49),
                color: themeProvider.darkTheme
                    ? const Color(0xff292937)
                    : const Color(0xffF3F3F3),
                surfaceTintColor: themeProvider.darkTheme
                    ? const Color(0xff292937)
                    : const Color(0xffF3F3F3),
                icon: Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                      color: themeProvider.darkTheme
                          ? const Color(0xff363645)
                          : const Color(0xffFFFFFF),
                      border: Border.all(
                          color: themeProvider.darkTheme
                              ? const Color(0xff42425F)
                              : const Color(0xff3EC745)),
                      borderRadius: BorderRadius.circular(3)),
                  padding:const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          child: TextWidget(
                       text: settings.searchEngine.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 13,
                            color: themeProvider.darkTheme
                                ? Colors.white
                                : Color(0xff3EC745)),
                      )),
                      SizedBox(
                        width: 25,
                        child: Icon(Icons.arrow_drop_down,
                            color: themeProvider.darkTheme
                                ? const Color(0xff6D6D81)
                                : const Color(0xff3EC745)),
                      ),
                    ],
                  ),
                ),
                onSelected: (value) {
                  setState(() {
                    settings.searchEngine = value;
                    browserModel.updateSettings(settings);
                  });
                    browserModel.updateIconValue(value.assetIcon);
                  // if (value.name == 'Google') {
                  //   selectedItemsProvider
                  //       .updateIconValue('assets/images/Google 1.svg');
                  // } else if (value.name == 'Yahoo') {
                  //   selectedItemsProvider
                  //       .updateIconValue('assets/images/Yahoo 1.svg');
                  // } else if (value.name == 'Bing') {
                  //   selectedItemsProvider
                  //       .updateIconValue('assets/images/Bing 1.svg');
                  // } else if (value.name == 'DuckDuckGo') {
                  //   selectedItemsProvider
                  //       .updateIconValue('assets/images/DuckDuckGo 2.svg');
                  // } else if (value.name == 'Ecosia') {
                  //   selectedItemsProvider
                  //       .updateIconValue('assets/images/Ecosia.svg');
                  // }
                },
                itemBuilder: ((context) {
                  return addSearchEngineProvider.allEngines.map((searchEngine) {
                    return PopupMenuItem<SearchEngineModel>(
                        enabled: true,
                        value: searchEngine,
                        height: 30,
                        child: Text(searchEngine.name,style: TextStyle(fontWeight: FontWeight.w300),));
                  }).toList();
                }),
              ),
            )
          ]),
        ),
      ),
    //   Padding(
    //     padding: const EdgeInsets.symmetric(vertical: 10.0),
    //     child: SizedBox(
    //       //height: constraints.maxHeight/7.5,
    //       //color: Colors.yellow,
    //       child:
    //           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    //         Expanded(
    //           child: Column(
    //             textBaseline: TextBaseline.alphabetic,
    //             crossAxisAlignment: CrossAxisAlignment.baseline,
    //             children: [
    //               TextWidget(text:"Change Langauge",
    //                   style: theme.textTheme.bodyLarge!
    //                       .copyWith(fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600)),
    //               TextWidget(
    //                   text: loc.hello, //'Change the app language',
    //                   overflow: TextOverflow.ellipsis,
    //                   maxLines: 3,
    //                   style: theme.textTheme.bodySmall!
    //                       .copyWith(fontWeight: FontWeight.w300,fontSize: widget.fontSizeInDp2)),
    //             ],
    //           ),
    //         ),
    //         PopupMenuTheme(
    //           data: PopupMenuThemeData(
    //             shape: RoundedRectangleBorder(
    //   borderRadius: BorderRadius.circular(4),
    //   side: BorderSide(
    //     color: themeProvider.darkTheme
    //         ? const Color(0xff42425F)
    //         : const Color(0xffF3F3F3),
    //   ),
    // ),
    //           ),
    //           child: PopupMenuButton<String>(
    //             offset: Offset(-8, 49),
    //             color: themeProvider.darkTheme
    //                 ? const Color(0xff292937)
    //                 : const Color(0xffF3F3F3),
    //             surfaceTintColor: themeProvider.darkTheme
    //                 ? const Color(0xff292937)
    //                 : const Color(0xffF3F3F3),
    //             icon: Container(
    //               width: 100,
    //               height: 40,
    //               decoration: BoxDecoration(
    //                   color: themeProvider.darkTheme
    //                       ? const Color(0xff363645)
    //                       : const Color(0xffFFFFFF),
    //                   border: Border.all(
    //                       color: themeProvider.darkTheme
    //                           ? const Color(0xff42425F)
    //                           : const Color(0xff3EC745)),
    //                   borderRadius: BorderRadius.circular(3)),
    //               padding:const EdgeInsets.symmetric(horizontal: 5),
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: [
    //                   Expanded(
    //                       child: TextWidget(
    //                    text:localeProvider.selectedLanguage,
    //                     overflow: TextOverflow.ellipsis,
    //                     maxLines: 1,
    //                     style: TextStyle(
    //                         fontSize: 13,
    //                         color: themeProvider.darkTheme
    //                             ? Colors.white
    //                             : Color(0xff3EC745)),
    //                   )),
    //                   SizedBox(
    //                     width: 25,
    //                     child: Icon(Icons.arrow_drop_down,
    //                         color: themeProvider.darkTheme
    //                             ? const Color(0xff6D6D81)
    //                             : const Color(0xff3EC745)),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             onSelected: (String selected) {
    //               /// This automatically:
    //   /// - Saves locale
    //   /// - Disables follow-system-locale mode
    //   /// - Updates selectedLanguage
    //   /// - Triggers UI update
    //   localeProvider.setLocale(localeProvider.languages[selected]!);
    //               // localeProvider.setLocale(localeProvider.languages[selected]!);
    //               // localeProvider.setSelectedLanguage();
    //               // // setState(() {
    //               // //   // settings.searchEngine = value;
    //               // //   // browserModel.updateSettings(settings);
    //               // // });
                 
    //             },
    //             itemBuilder: ((context) {
    //               return localeProvider.languages.keys.map((String language) {
    //                 return PopupMenuItem<String>(
    //                     enabled: true,
    //                     value: language,
    //                     height: 30,
    //                     child: Text(language,style: TextStyle(fontWeight: FontWeight.w300),));
    //               }).toList();
    //             }),
    //           ),
    //         )
    //       ]),
    //     ),
    //   ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          //color: Colors.green,
          // height: constraints.maxHeight/8.5,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  child: Column(
                    textBaseline: TextBaseline.alphabetic,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      TextWidget(text:loc.homePage, //"Home page",
                          style: theme.textTheme.bodyLarge!.copyWith(
                              fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600)),
                      TextWidget(
                         text:loc.homepageContent, //'Set your homepage for quick access to favorite sites.',
                          style: theme.textTheme.bodySmall!
                              .copyWith(fontWeight: FontWeight.w300,fontSize: widget.fontSizeInDp2)),
                    ],
                  ),
                ),
              ),
             const SizedBox(
                width: 30,
              ),
              FlutterSwitch(
                  value: settings.homePageEnabled,
                  inactiveColor: themeProvider.darkTheme
                      ? const Color(0xff363645)
                      : const Color(0xffFFFFFF),
                  inactiveToggleColor: themeProvider.darkTheme
                      ? const Color(0xff9595B5)
                      : const Color(0xffC5C5C5),
                  activeColor: themeProvider.darkTheme
                      ? const Color(0xff363645)
                      : const Color(0xffFFFFFF),
                  width: widget.widthInDp, //width / 8.0, //50,
                  height:widget.heightInDp, //width / 14.8, //29,
                  toggleSize:widget.toggleSizeInDp, //width / 17.2, //20
                  padding: 2.0,
                  activeToggleColor: const Color(0xff00BD40),
                  onToggle: ((value) async {
                    setState(() {
                      // settings.homePageEnabled = value;
                      // browserModel.updateSettings(settings);

                      if (value == false) {
                        settings.homePageEnabled = value;
                        browserModel.updateSettings(settings);
                      }

                      if (value) {
                        //_customHomePageController.text = settings.customUrlHomePage;

                        showDialog(
                          context: context,
                          // barrierDismissible: false,
                          builder: (context) {
                            return Dialog(
                              backgroundColor: themeProvider.darkTheme
                                  ? const Color(0xff282836)
                                  : const Color(0xffFFFFFF),
                              insetPadding: EdgeInsets.all(20),
                               shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
                              child: Container(
                                
                                width: MediaQuery.of(context).size.width,
                                // height: 200,
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                 // color: Colors.white,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child:  TextWidget(
                                       text:loc.homePage, //'Home Page',
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    // StatefulBuilder(
                                    //   builder: (context, setState) {
                                    //     return SwitchListTile(
                                    //       title: Text(settings.homePageEnabled ? "ON" : "OFF"),
                                    //       value: settings.homePageEnabled,
                                    //       onChanged: (value) {
                                    //         setState(() {
                                    //           settings.homePageEnabled = value;
                                    //           browserModel.updateSettings(settings);
                                    //         });
                                    //       },
                                    //     );
                                    //   },
                                    // ),
                                    StatefulBuilder(
                                        builder: (context, setState) {
                                      return Row(
                                          // mainAxisAlignment: MainAxisAlignment.end,
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: themeProvider
                                                                .darkTheme
                                                            ? Color(0xff42425F)
                                                            : Color(
                                                                0xffDADADA)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                child: TextField(
                                                  onSubmitted: (value) {
                                                    if (value.isEmpty ||
                                                        value == '') {
                                                      settings.homePageEnabled =
                                                          false;
                                                      browserModel
                                                          .updateSettings(
                                                              settings);
                                                      setState(() {
                                                        _showError = true;
                                                        return;
                                                      });
                                                    } else if(!isValidURL(value)){
                                                   _showError = true;
                                                       return ;
                                                     }else {
                                                      setState(() {
                                                        settings.customUrlHomePage =
                                                            formatUrl(
                                                                value.trim());

                                                        settings.homePageEnabled =
                                                            true;
                                                        browserModel
                                                            .updateSettings(
                                                                settings);
                                                        Navigator.pop(context);
                                                      });
                                                    }
                                                  },
                                                  keyboardType:
                                                      TextInputType.url,
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    contentPadding: EdgeInsets.only(left:5),
                                                    hintText:loc.customUrlHomePage,
                                                        //'Custom URL Home Page',
                                                    hintStyle: TextStyle(
                                                      fontSize: 14,
                                                        color:  const Color(0xff77778B),
                                                                fontWeight: FontWeight.w400
                                                                ),
                                                  ),
                                                  controller:
                                                      _customHomePageController,
                                                      magnifierConfiguration:TextMagnifierConfiguration.disabled,
                                                contextMenuBuilder: (context, editableTextState) {
                      //final List<ContextMenuButtonItem>
                      buttonItems = editableTextState.contextMenuButtonItems;

                      editableState = editableTextState;

                      buttonItems.clear(); // Clear all default options
                      if (_customHomePageController.text.isEmpty) {
                        buttonItems.add(ContextMenuButtonItem(
                            label:loc.paste,// 'Paste',
                            onPressed: () {
                              Clipboard.getData('text/plain').then((value) {
                                if (value != null && value.text != null) {
                                  final text = _customHomePageController.text;
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
                                  _customHomePageController.text = newText;
                                  // if(_searchController.text.trim().isEmpty || containsUrl(_searchController.text)){
                                  //   print("The User Message Contains Url 1");
                                  // canShowSearchAI= '';
                                  //   }else
                                  //     canShowSearchAI= _searchController.text;
                         // print('BELDEX AI ---------> $canShowSearchAI');
        
                                  //canShowSearchAI = _searchController.text;
                                  final newSelection = TextSelection.collapsed(
                                    offset:
                                        selection.start + value.text!.length,
                                  );
                                  _customHomePageController.selection = newSelection;
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
                                  _customHomePageController.text;
                              final String newFindOnPageText =
                                  findOnPageText.replaceRange(
                                      selection.start, selection.end, '');

                              print(
                                  'Cut value Editable Text ---> $findOnPageText -- $newFindOnPageText -- $newText');
                              _customHomePageController.text =
                                  findOnPageText; //newFindOnPageText;
                            }
                            //  // Clipboard.setData(ClipboardData(text: editableTextState.textEditingValue.text));
                            //   editableTextState.cutSelection(SelectionChangedCause.tap);
                            //   _searchController.clear();
                            //   //editableTextState.hideToolbar(false);
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
                                final text = _customHomePageController.text;
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
                                _customHomePageController.text = newText;
                                final newSelection = TextSelection.collapsed(
                                  offset: selection.start + value.text!.length,
                                );
                                _customHomePageController.selection = newSelection;
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
                                                  
                                                ),
                                              ),
                                            )
                                          ]);
                                    }),
                                    Visibility(
                                      visible: _showError,
                                      child: TextWidget(
                                       text:loc.pleaseEnterValidCustomURL, // 'Please enter valid custom Url',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                    SizedBox(height: 8,),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: MaterialButton(
                                        color: Color(0xff0BA70F), //const Color(0xff00B134),
                                        disabledColor: Color(0xff2C2C3B),
                                        minWidth: double.maxFinite,
                                        height: 50,
                                        child:  Text(loc.ok, // 'OK',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10.0), // Adjust the radius as needed
                                        ),
                                        onPressed: () {
                                         setState(() {
                                            if (_customHomePageController
                                              .text.isEmpty) {
                                            settings.homePageEnabled = false;
                                            //setState(() {
                                              _showError = true;
                                              return;
                                            //});
                                          }else if(!isValidURL(_customHomePageController.text)){
                                             _showError = true;
                                             return ;
                                          } else {
                                            //setState(() {
                                              // _customHomePageController.text = settings.customUrlHomePage;
                                              _showError = false;
                                              settings.customUrlHomePage =
                                                  formatUrl(
                                                      (_customHomePageController
                                                              .text)
                                                          .trim());
                                              settings.homePageEnabled = true;
                                              browserModel
                                                  .updateSettings(settings);
                                              Navigator.pop(context);
                                           // });
                                          }
                                          });
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    });
                  })),
            ],
          ),
        ),
      ),

      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  textBaseline: TextBaseline.alphabetic,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  children: [
                    TextWidget(text:loc.screenSecurity, //"Screen security",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600)
                        // TextStyle(fontSize:15,// dynamicTextSizeWidget.dynamicFontSize(15, context),
                        // fontWeight: FontWeight.w600),
                        ),
                    TextWidget(
                        text:loc.screenSecurityContent, //'Add an extra layer of protection for secure browsing.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontWeight: FontWeight.w300,fontSize: widget.fontSizeInDp2)
                        // TextStyle(
                        //   fontSize:12,// dynamicTextSizeWidget.dynamicFontSize(12, context),
                        //   fontWeight: FontWeight.w400,
                        // )
                        ),
                  ],
                ),
              ),
             const SizedBox(
                width: 30,
              ),
              FlutterSwitch(
                  value: basicProvider.scrnSecurity, //isSwitched,
                  inactiveColor: themeProvider.darkTheme
                      ? const Color(0xff363645)
                      : const Color(0xffFFFFFF),
                  inactiveToggleColor: themeProvider.darkTheme
                      ? const Color(0xff9595B5)
                      : const Color(0xffC5C5C5),
                  activeColor: themeProvider.darkTheme
                      ? const Color(0xff363645)
                      : const Color(0xffFFFFFF),
                    width:widget.widthInDp,
                    height: widget.heightInDp,
                  toggleSize: widget.toggleSizeInDp,
                  padding: 2.0, // width: width / 7.9, //50,
                  // height: height / 28.8, //29,
                  // toggleSize: height / 36.2, //20
                  activeToggleColor: Color(0xff00BD40),
                  onToggle: (value) async {
                    //var basicProvider = Provider.of<BasicProvider>(context,listen: false);
                    basicProvider.updateScrnSecurity(value);
                    // var browserModel = Provider.of<BrowserModel>(context, listen: false);
                    // browserModel.updateScreenSecurity(value);
                    setState(() {
                      isSwitched = value;
                    });
                    if (basicProvider.scrnSecurity) {
                     await BelnetLib.enableScreenSecurity();
                      // await FlutterWindowManager.addFlags(
                      //     FlutterWindowManager.FLAG_SECURE);
                    } else {
                      await BelnetLib.disableScreenSecurity();
                      // await FlutterWindowManager.clearFlags(
                      //     FlutterWindowManager.FLAG_SECURE);
                    }

                    // await saveSwitchState(value);
                  }),
            ],
          ),
        ),
      ),

      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          //color: Colors.pink,
          //height: constraints.maxHeight/8.5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    TextWidget(text:loc.javascriptEnabled, //"JavaScript Enabled",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600)
                        // TextStyle(
                        //     fontSize:15,// dynamicTextSizeWidget.dynamicFontSize(15, context),
                        //     fontWeight: FontWeight.w600,
                        //     color: themeProvider.darkTheme
                        //         ? Colors.white
                        //         : Colors.black),
                        ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextWidget(
                          text:loc.javascriptEnabledContent, //"Enable or disable JavaScript for a tailored experience.",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontWeight: FontWeight.w300,fontSize: widget.fontSizeInDp2)
                          // TextStyle(
                          //   fontSize:12,// dynamicTextSizeWidget.dynamicFontSize(12, context),
                          //   fontWeight: FontWeight
                          //       .w400, //color:browserModel.webViewTabs.isEmpty ? themeProvider.darkTheme ? Color(0xff6D6D81) : Color(0xffC5C5C5):
                          // )
                          ),
                    ),
                  ],
                ),
              ),
             const SizedBox(
                width: 30,
              ),
              FlutterSwitch(
                  disabled: browserModel.webViewTabs.isEmpty,
                  inactiveColor: themeProvider.darkTheme
                      ? const Color(0xff363645)
                      : const Color(0xffFFFFFF),
                  inactiveToggleColor: themeProvider.darkTheme
                      ? const Color(0xff9595B5)
                      : const Color(0xffC5C5C5),
                  activeColor: themeProvider.darkTheme
                      ? const Color(0xff363645)
                      : const Color(0xffFFFFFF),
                  width: widget.widthInDp, //width / 8.0, //50,
                  height:widget.heightInDp, //width / 14.8, //29,
                  toggleSize:widget.toggleSizeInDp, //width / 17.2, //20
                  padding: 2.0,
                  activeToggleColor: const Color(0xff00BD40),
                  value:vpnStatusProvider.jsEbld,
                     // currentWebViewModel.settings?.javaScriptEnabled ?? true,
                  onToggle: ((value) async {
                    setState(() {
                        //jsEnabled = value;
                        vpnStatusProvider.updateJSEnabled(value);
                        currentWebViewModel.settings?.javaScriptEnabled = value;
                      });
                      
                    webViewController?.setSettings(
                        settings: currentWebViewModel.settings ??
                            InAppWebViewSettings());
                    currentWebViewModel.settings =
                        await webViewController?.getSettings();
                    browserModel.save();
                   // setState(() {});
                  })),
            ],
          ),
        ),
      ),

      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          //height: constraints.maxHeight/8.5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    TextWidget(text:loc.cacheEnabled, //"Cache Enabled",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600)
                        // TextStyle(
                        //     fontSize:15,// dynamicTextSizeWidget.dynamicFontSize(15, context),
                        //     fontWeight: FontWeight.w600,
                        //     color: themeProvider.darkTheme
                        //         ? Colors.white
                        //         : Colors.black),
                        ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextWidget(
                         text:loc.cacheEnabledContent,// "Toggle caching for faster loading or increased confidentiality.",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontWeight: FontWeight.w300,fontSize: widget.fontSizeInDp2)
                          // TextStyle(
                          //   fontSize:12,// dynamicTextSizeWidget.dynamicFontSize(12, context),
                          //   fontWeight: FontWeight
                          //       .w400, //color: themeProvider.darkTheme ? Colors.white : Color(0xff3D3D44AC)
                          // )
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 30,
              ),
              FlutterSwitch(
                  disabled: browserModel.webViewTabs.isEmpty,
                  inactiveColor: themeProvider.darkTheme
                      ? const Color(0xff363645)
                      : const Color(0xffFFFFFF),
                  inactiveToggleColor: themeProvider.darkTheme
                      ? const Color(0xff9595B5)
                      : const Color(0xffC5C5C5),
                  activeColor: themeProvider.darkTheme
                      ? const Color(0xff363645)
                      : const Color(0xffFFFFFF),
                 width: widget.widthInDp, //width / 8.0, //50,
                  height:widget.heightInDp, //width / 14.8, //29,
                  toggleSize:widget.toggleSizeInDp, //width / 17.2, //20
                  padding: 2.0,
                  activeToggleColor: Color(0xff00BD40),
                  value:vpnStatusProvider.cacheEbld, //currentWebViewModel.settings?.cacheEnabled ?? true,
                  onToggle: ((value) async {
                    setState(() {
                        vpnStatusProvider.updateCacheValue(value);
                        //cacheEbd = value;
                        currentWebViewModel.settings?.cacheEnabled = value;
                      
                      });
                    webViewController?.setSettings(
                        settings: currentWebViewModel.settings ??
                            InAppWebViewSettings());
                    currentWebViewModel.settings =
                        await webViewController?.getSettings();
                    browserModel.save();
                    //setState(() {});
                  })),
            ],
          ),
        ),
      ),

      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: SizedBox(
          //height: constraints.maxHeight/8.5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    TextWidget(text:loc.supportZoom, //"Support Zoom",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600)
                        // TextStyle(
                        //     fontSize:15,// dynamicTextSizeWidget.dynamicFontSize(15, context),
                        //     fontWeight: FontWeight.w600,
                        //     color: themeProvider.darkTheme
                        //         ? Colors.white
                        //         : Colors.black),
                        ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextWidget(
                          text:loc.supportZoomContent, //"Enable zoom for a closer look at web content.",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontWeight: FontWeight.w300,fontSize: widget.fontSizeInDp2)
                          // TextStyle(
                          //   fontSize:12,// dynamicTextSizeWidget.dynamicFontSize(12, context),
                          //   fontWeight: FontWeight
                          //       .w400, //color: themeProvider.darkTheme ? Colors.white : Color(0xff3D3D44AC)
                          // )
                          ),
                    ),
                  ],
                ),
              ),
             const SizedBox(
                width: 30,
              ),
              FlutterSwitch(
                  disabled: browserModel.webViewTabs.isEmpty,
                  inactiveColor: themeProvider.darkTheme
                      ? const Color(0xff363645)
                      : const Color(0xffFFFFFF),
                  inactiveToggleColor: themeProvider.darkTheme
                      ? const Color(0xff9595B5)
                      : const Color(0xffC5C5C5),
                  activeColor: themeProvider.darkTheme
                      ? const Color(0xff363645)
                      : const Color(0xffFFFFFF),
                  width: widget.widthInDp, //width / 8.0, //50,
                  height: widget.heightInDp, //width / 14.8, //29,
                  toggleSize:widget.toggleSizeInDp, //width / 17.2, //20
                  padding: 2.0,
                  activeToggleColor: Color(0xff00BD40),
                  value: vpnStatusProvider.supportZoomEbld, //currentWebViewModel.settings?.supportZoom ?? true,
                  onToggle: ((value) async {
                      setState(() {
                        vpnStatusProvider.updateSupportZoomEbld(value);
                        //supportZoom = value;
                         currentWebViewModel.settings?.supportZoom = value;
                      });
                     
                    webViewController?.setSettings(
                        settings: currentWebViewModel.settings ??
                            InAppWebViewSettings());
                    currentWebViewModel.settings =
                        await webViewController?.getSettings();
                    browserModel.save();
                   // setState(() {});
                  })),
            ],
          ),
        ),
      ),
      
Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: InkWell(
          onTap: _openLanguageScreen,
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  textBaseline: TextBaseline.alphabetic,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  children: [
                    TextWidget(text:"App Language", //"Screen security",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600)
                        // TextStyle(fontSize:15,// dynamicTextSizeWidget.dynamicFontSize(15, context),
                        // fontWeight: FontWeight.w600),
                        ),
                    TextWidget(
                        text:localeProvider.selectedLanguage, //'Add an extra layer of protection for secure browsing.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontWeight: FontWeight.w300,fontSize: widget.fontSizeInDp2)
                        // TextStyle(
                        //   fontSize:12,// dynamicTextSizeWidget.dynamicFontSize(12, context),
                        //   fontWeight: FontWeight.w400,
                        // )
                        ),
                  ],
                ),
              ),
             const SizedBox(
                width: 30,
              ),
              SvgPicture.asset(
                'assets/images/arrow_backs.svg', height:widget.toggleSizeInDp*0.5, //width / 18.5, //16 ,
                color: themeProvider.darkTheme
                    ? const Color(0xff56566F)
                    : const Color(0xffB8B8C0),
              )
              
            ],
          ),
        ),
      ),





      Padding(
        padding: const EdgeInsets.symmetric(vertical: 13.0),
        child: InkWell(
          onTap: _openAppSettings,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextWidget(text:loc.appPermissions, //"App Permissions",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600)
                    // TextStyle(fontSize:15,// dynamicTextSizeWidget.dynamicFontSize(15, context),
                    // fontWeight: FontWeight.w600),
                    ),
              ),
              SvgPicture.asset(
                'assets/images/arrow_backs.svg', height:widget.toggleSizeInDp*0.5, //width / 18.5, //16 ,
                color: themeProvider.darkTheme
                    ? const Color(0xff56566F)
                    : const Color(0xffB8B8C0),
              )
              //Icon(Icons.arrow_back_,size: 20,)
            ],
          ),
        ),
      ),
      
    //  Padding(
    //     padding: const EdgeInsets.symmetric(vertical: 13.0),
    //     child: InkWell(
    //       onTap:()=> BelnetLib.setDefaultApp(),
    //       child: Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         children: [
    //           Expanded(
    //             child: Text("Set as Default Browser",
    //                 style: theme
    //                     .textTheme
    //                     .bodyLarge!
    //                     .copyWith(fontSize: 15, fontWeight: FontWeight.w400)),
    //           ),
    //           SvgPicture.asset(
    //             'assets/images/arrow_backs.svg',
    //             height: width / 18.5,
    //             color: themeProvider.darkTheme
    //                 ? Color(0xff56566F)
    //                 : Color(0xffB8B8C0),
    //           )
    //         ],
    //       ),
    //     ),
    //   ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 13.0),
        child: InkWell(
          onTap:()=> BelnetLib.setDefaultApp(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextWidget(text:loc.setAsDefaultBrowser, //"Set as Default Browser",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600)),
              ),
              SvgPicture.asset(
                'assets/images/arrow_backs.svg',
                height:widget.toggleSizeInDp*0.5, //width / 18.5,
                color: themeProvider.darkTheme
                    ? const Color(0xff56566F)
                    : const Color(0xffB8B8C0),
              )
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 13.0),
        child: InkWell(
          onTap: (() => Navigator.push(
              context, MaterialPageRoute(builder: ((context) => AboutPage())))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextWidget(text:loc.aboutBeldexBrowser,  //"About Beldex Browser",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600)),
              ),
              SvgPicture.asset(
                'assets/images/arrow_backs.svg',
                height:widget.toggleSizeInDp*0.5, //width / 18.5,
                color: themeProvider.darkTheme
                    ? const Color(0xff56566F)
                    : const Color(0xffB8B8C0),
              )
            ],
          ),
        ),
      ),

  // GestureDetector(
  //   onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> SampleExitnodeDropdown())),
  //   child: Container(
  //     child: Text('Dropdown here '),
  //   ),
  // )


    ];
    return widgets;
  }
}

// class SamplePage extends StatelessWidget {
//   const SamplePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: GestureDetector(
//             onTap: () {
//               showModalBottomSheet<int>(
//                 backgroundColor: Colors.transparent,
//                 context: context,
//                 builder: (context) {
//                   return Popover(
//                     child: Container(
//                       margin: EdgeInsets.all(15),
//                       height: 300,
//                       color: Colors.lightBlue,
//                     ),
//                   );
//                 },
//               );
//             },
//             child: Text('Click')),
//       ),
//     );
//   }
// }

class Popover extends StatelessWidget {
  const Popover({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: Colors.green //theme.cardColor,
          //borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_buildHandle(context), if (child != null) child],
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    final theme = Theme.of(context);

    return FractionallySizedBox(
      widthFactor: 0.25,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 12.0,
        ),
        child: Container(
          height: 5.0,
          decoration: BoxDecoration(
            color: Colors.yellow, //theme.dividerColor,
            borderRadius: const BorderRadius.all(Radius.circular(2.5)),
          ),
        ),
      ),
    );
  }
}
