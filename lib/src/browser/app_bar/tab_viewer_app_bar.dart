import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/pages/settings/main.dart';
import 'package:beldex_browser/src/browser/webview_tab.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../custom_popup_menu_item.dart';
import '../tab_viewer_popup_menu_actions.dart';

class TabViewerAppBar extends StatefulWidget implements PreferredSizeWidget {
  const TabViewerAppBar({Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  State<TabViewerAppBar> createState() => _TabViewerAppBarState();

  @override
  final Size preferredSize;
}

class _TabViewerAppBarState extends State<TabViewerAppBar> {
  GlobalKey tabInkWellKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 10.0,
      actions: _buildActionsMenu(),
    );
  }


  List<Widget> _buildActionsMenu() {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    var settings = browserModel.getSettings();
    var themeProvider = Provider.of<DarkThemeProvider>(context,listen: false);
    return <Widget>[
      InkWell(
        key: tabInkWellKey,
        onTap: null,
        child: Padding(
          padding: settings.homePageEnabled
              ? const EdgeInsets.only(
                  left: 20.0, top: 15.0, right: 10.0, bottom: 15.0)
              : const EdgeInsets.only(
                  left: 10.0, top: 10.0, right: 5.0, bottom: 10.0),
          child: Container(
            width: 18,
          height: 18,
            decoration: BoxDecoration(
              color: themeProvider.darkTheme
                  ?const Color(0xff282836)
                  :const Color(0xffF3F3F3),
                border: Border.all(width: 1.0,color :themeProvider.darkTheme ? Colors.white : Colors.black,),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0)),
            constraints: const BoxConstraints(minWidth: 18.0),
            child: Center(
                child: browserModel.webViewTabs.length >=100 ? 
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: SvgPicture.asset('assets/images/Infinity_white_theme.svg',color: themeProvider.darkTheme ? Colors.white: Colors.black,),
              ):
                 Text(
              browserModel.webViewTabs.length.toString(),
              style: const TextStyle(
                  //color: Colors.white,
                  fontWeight: FontWeight.normal,
                  
                  fontSize: 12.0),
            )),
          ),
        ),
      ),
      PopupMenuButton<String>(
        color:  themeProvider.darkTheme ?const Color(0xff282836) :const Color(0xffF3F3F3),
              icon: Icon(Icons.more_horiz,
                  color: themeProvider.darkTheme ? Colors.white : Colors.black),
        onSelected: _popupMenuChoiceAction,
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

          items.addAll(TabViewerPopupMenuActions.choices.map((choice) {
            switch (choice) {
              case TabViewerPopupMenuActions.NEW_TAB:
                return CustomPopupMenuItem<String>(
                  enabled: true,
                  value: choice,
                  height: 35,
                  child: Row(
                      children: [
                       SvgPicture.asset('assets/images/new_tab.svg' ,color: themeProvider.darkTheme
                                                ?const Color(0xffFFFFFF)
                                                :const Color(0xff282836)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal:8.0),
                          child: Text(choice, style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                        ),
                      ]),
                );
              // case TabViewerPopupMenuActions.NEW_INCOGNITO_TAB:
              //   return CustomPopupMenuItem<String>(
              //     enabled: true,
              //     value: choice,
              //     child: Row(
              //         children: [
              //          SvgPicture.asset('assets/images/private_tab.svg', color: themeProvider.darkTheme
              //                                   ?const Color(0xffFFFFFF)
              //                                   :const Color(0xff282836)),
              //           Padding(
              //             padding: const EdgeInsets.symmetric(horizontal:8.0),
              //             child: Text(choice,style: Theme.of(context)
              //                                 .textTheme
              //                                 .bodySmall),
              //           ),
              //         ]),
              //   );
              case TabViewerPopupMenuActions.CLOSE_ALL_TABS:
                return CustomPopupMenuItem<String>(
                  enabled: browserModel.webViewTabs.isNotEmpty,
                  value: choice,
                  height: 35,
                  child: Row(
                      children: [
                         Container(
                           child:Icon(Icons.close,size: 20,),
                         ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal:5.0),
                          child: Text(choice, style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                        ),
                      ]),
                );
              case TabViewerPopupMenuActions.SETTINGS:
                return CustomPopupMenuItem<String>(
                  enabled: true,
                  value: choice,
                  height: 35,
                  child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left:3.0),
                          child: SvgPicture.asset('assets/images/settings.svg', color: themeProvider.darkTheme
                                                ?const Color(0xffFFFFFF)
                                                :const Color(0xff282836)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal:8.0),
                          child: Text(choice,style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
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
      )
    ];
  }

  void _popupMenuChoiceAction(String choice) async {
     final vpnStatusProvider = Provider.of<VpnStatusProvider>(context,listen: false);
    switch (choice) {
      case TabViewerPopupMenuActions.NEW_TAB:
        Future.delayed(const Duration(milliseconds: 300), () {
          vpnStatusProvider.updateCanShowHomeScreen(false);
          addNewTab();
        });
        break;
      // case TabViewerPopupMenuActions.NEW_INCOGNITO_TAB:
      //   Future.delayed(const Duration(milliseconds: 300), () {
      //     addNewIncognitoTab();
      //   });
      //   break;
      case TabViewerPopupMenuActions.CLOSE_ALL_TABS:
        Future.delayed(const Duration(milliseconds: 300), () {
          closeAllTabs();
          clearCookie();
        });
        break;
      case TabViewerPopupMenuActions.SETTINGS:
        Future.delayed(const Duration(milliseconds: 300), () {
          goToSettingsPage();
        });
        break;
    }
  }

  void addNewTab({WebUri? url}) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();

    url ??= 
    // settings.homePageEnabled && settings.customUrlHomePage.isNotEmpty
    //     ? WebUri(settings.customUrlHomePage)
    //     : 
        WebUri(settings.searchEngine.url);

    browserModel.showTabScroller = false;

    browserModel.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(url: url),
    ));
  }

  void addNewIncognitoTab({WebUri? url}) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();

    url ??= 
    // settings.homePageEnabled && settings.customUrlHomePage.isNotEmpty
    //     ? WebUri(settings.customUrlHomePage)
    //     : 
        WebUri(settings.searchEngine.url);

    browserModel.showTabScroller = false;

    browserModel.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(url: url, isIncognitoMode: true),
    ));
  }

  void closeAllTabs() {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);

    browserModel.showTabScroller = false;

    browserModel.closeAllTabs();
  }

  void goToSettingsPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SettingsPage()));
  }
}
