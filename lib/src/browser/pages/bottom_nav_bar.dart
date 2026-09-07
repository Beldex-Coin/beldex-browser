import 'dart:io';
import 'dart:ui';

import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/locale_provider.dart';
import 'package:beldex_browser/main.dart';
import 'package:beldex_browser/src/browser/ai/ai_model_provider.dart';
import 'package:beldex_browser/src/browser/ai/chat_screen.dart';
import 'package:beldex_browser/src/browser/ai/ui/views/beldexai_chat_screen.dart';
import 'package:beldex_browser/src/browser/app_bar/tab_viewer_app_bar.dart';
import 'package:beldex_browser/src/browser/app_bar/url_info_popup.dart';
import 'package:beldex_browser/src/browser/app_bar/webview_tab_app_bar.dart';
import 'package:beldex_browser/src/browser/browser.dart';
import 'package:beldex_browser/src/browser/custom_image.dart';
import 'package:beldex_browser/src/browser/custom_popup_dialog.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/favorite_model.dart';
import 'package:beldex_browser/src/browser/models/search_engine_model.dart';
import 'package:beldex_browser/src/browser/models/web_archive_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/pages/change_node_screen.dart';
import 'package:beldex_browser/src/browser/pages/developers/main.dart';
import 'package:beldex_browser/src/browser/pages/search_engine/add_searchengine_provider.dart';
import 'package:beldex_browser/src/browser/pages/settings/app_language_screen.dart';
import 'package:beldex_browser/src/browser/pages/settings/main.dart';
import 'package:beldex_browser/src/browser/pages/tab_settings/glassmorph_widget.dart';
import 'package:beldex_browser/src/browser/popup_menu_actions.dart';
import 'package:beldex_browser/src/browser/project_info_popup.dart';
import 'package:beldex_browser/src/browser/providers/appbar_position_provider.dart';
import 'package:beldex_browser/src/browser/providers/bottom_nav_bar_provider.dart';
import 'package:beldex_browser/src/browser/providers/tab_provider.dart';
import 'package:beldex_browser/src/browser/tab_popup_menu_actions.dart';
import 'package:beldex_browser/src/browser/util.dart';
import 'package:beldex_browser/src/browser/webview_tab.dart';
import 'package:beldex_browser/src/node_dropdown_list_page.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/tts_provider.dart';
import 'package:beldex_browser/src/utils/screen_secure_provider.dart';
import 'package:beldex_browser/src/utils/show_message.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:beldex_browser/src/widget/aboutpage.dart';
import 'package:beldex_browser/src/widget/animated_toggle_switch.dart';
import 'package:beldex_browser/src/widget/downloads/download_ui.dart';
import 'package:beldex_browser/src/widget/text_widget.dart';
import 'package:belnet_lib/belnet_lib.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {


late List<Widget> pages; 

@override
  void initState() {
    super.initState();
        final browserModel = Provider.of<BrowserModel>(context,listen: false);
//  var webViewModel = browserModel.getCurrentTab()?.webViewModel;
//         var webViewController = webViewModel?.webViewController;
//  pages = [
//       const Browser(), //HomeScreen(),
//        ChangeNodePage(
//                 exitData: [],
//                 canChangeNode: true,
//                 webViewController: webViewController,
//               ),
//       const ChatScreen(),
//       const ChatScreen(),
//       const ChatScreen(),
//     ];



      BelnetLib.disconnectEventChannel.receiveBroadcastStream().listen((event){
        print('User is clicked disconnect');
   if (event == "notification_disconnect") {
      print("User clicked disconnect from notification");
      // Handle your logic
      try{
       exit(0);
      //AwesomeNotifications().cancelAll();
      }catch(e){

      }
          }
  },
   onError: (error) {
    debugPrint("Notification disconnect stream error: $error");
  }
  
  ); 
  }



  @override
  Widget build(BuildContext context) {
    final browserModel = Provider.of<BrowserModel>(context);
     var webViewModel = browserModel.getCurrentTab()?.webViewModel;
        var webViewController = webViewModel?.webViewController;
    final bottomNavProvider =
        Provider.of<BottomNavigationProvider>(context);
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final appBarPositionProvider =
        Provider.of<AppBarPositionProvider>(context);
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);
    final loc = AppLocalizations.of(context)!;
    // final pages = [
    //   const Browser(), //HomeScreen(),
    //   ChangeNodePage(
    //             exitData: [],
    //             canChangeNode: true,
    //             webViewController: webViewController,
    //           ),
    //   const ChatScreen(),
    //   const ChatScreen(),
    //   const ChatScreen(),
    // ];

    return PopScope(
      canPop: bottomNavProvider.isHome,

      onPopInvokedWithResult: (didPop, result) {

        if (!didPop &&
            !bottomNavProvider.isHome) {

          bottomNavProvider.goHome();
        }
      },

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
          Scaffold(
          backgroundColor: Colors.transparent,
            body: IndexedStack(
              index: bottomNavProvider.currentIndex,
              children: [
                  const Browser(), //HomeScreen(),
       ChangeNodePage(
                exitData: [],
                canChangeNode: true,
                webViewController: webViewController,
              ),
      const ChatScreen(),
      const ChatScreen(),
      const ChatScreen(),
              ]
                //pages,
            ),
            bottomNavigationBar: browserModel.showTabScroller &&  groupProvider.totalOpenTabsCount != 0//browserModel.webViewTabs.isNotEmpty 
            ? TabBottomBar()
            // Container(
            //   height: 65,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Container(
            //         color: Colors.green,
            //         child: Icon(Icons.add))
            //     ],
            //   ),
            // )
            :
                appBarPositionProvider.selectedPosition ==
                        AppBarPosition.top 
            //             &&
            // bottomNavProvider.showBottomNav
                 ?  
                    CustomBottomNavigationBar()
                    : null
            // bottomNavigationBar: browserModel.showTabScroller == true && browserModel.webViewTabs.isNotEmpty 
            // ? TabBottomBar() :
            //     appBarPositionProvider.selectedPosition ==
            //             AppBarPosition.top &&
            // bottomNavProvider.showBottomNav
            //         ?  CustomBottomNavigationBar()
            //         : null,
          ),
        vpnStatusProvider.isChangeNode ?  
        Positioned.fill(child: Material(
          color:themeProvider.darkTheme ? Color(0xff0B0B0B).withOpacity(0.6) : Color(0xffFFFFFF).withOpacity(0.6),
          child: Center(
            child: 
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GlassSettingPanel(
                color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffFFFFFF).withOpacity(0.1),
                
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(border: Border.all(color: themeProvider.darkTheme ? Color(0xff444444): Color(0xffD4D4D4))),
                  padding: EdgeInsets.symmetric(horizontal:  10, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     // Image.asset('assets/images/ai-icons/new/Loading.gif')
                     //Text('Connecting...',),
                     
                      Container(
                        height: 28,width: 28,
                        child: CircularProgressIndicator(
                          //padding: EdgeInsets.all(5),
                          color:themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B),strokeWidth: 2,),
                      ),
                      SizedBox(height: 10,),
                      Text('${loc.connecting}', style: TextStyle(fontSize: 18,fontFamily: 'Inter',color: themeProvider.darkTheme ? Color(0xffEBEBEB) :Color(0xff737373)),)
                    ],
                  ),
                ),
              ),
            ),
          ),
        )):SizedBox()
        ],
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatefulWidget {
   CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {


  CustomPopupDialogPageRoute? route;

//final GlobalKey menuKey = GlobalKey();
GlobalKey tabInkWellsKey = GlobalKey();


@override
  void initState() {
    // TODO: implement initState
    super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
    final groupProvider =
        Provider.of<GroupProvider>(
      context,
      listen: false,
    );

    groupProvider.autoGroupAllTabs();
  });
  }

  @override
  Widget build(BuildContext context) {

    final provider =
        Provider.of<BottomNavigationProvider>(context);
       final theme = Theme.of(context);
        final themeProvider = Provider.of<DarkThemeProvider>(context);
        final browserModel = Provider.of<BrowserModel>(context);
        final bottomNavigationProvider = Provider.of<BottomNavigationProvider>(context); 
            var webViewModel = Provider.of<WebViewModel>(context, listen: true);
    // final localeProvider = Provider.of<LocaleProvider>(context,listen: false);
    // final loc = AppLocalizations.of(context)!;
    final groupProvider = Provider.of<GroupProvider>(context);
    var webViewController = webViewModel.webViewController;
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
      final ttsProvider = Provider.of<TtsProvider>(context,listen: false);

    return SafeArea(
       top: false,left: false,right: false,bottom: true,
      child: Container(
         height: 65,
                    decoration: BoxDecoration(
                      color:themeProvider.darkTheme ? Color(0xff0B0B0B) : Color(0xffEBEBEB) ,
                      border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.3)))
                    ),
        child: BottomNavigationBar(
          // backgroundColor:themeProvider.darkTheme ? Color(0xff0B0B0B) : Color(0xffEBEBEB),
          // labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          // selectedIndex: provider.currentIndex,
          // indicatorColor: Colors.transparent,
          // labelPadding: EdgeInsets.zero,
          // onDestinationSelected: (index) {
            type: BottomNavigationBarType.fixed,
        backgroundColor: themeProvider.darkTheme
        ? const Color(0xff0B0B0B)
        : const Color(0xffEBEBEB),
        selectedItemColor: Colors.transparent,
        unselectedItemColor: Colors.transparent,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: provider.currentIndex,
        //  onDestinationSelected: (index) {
            onTap: (index){
         switch(index) {
        
          case 0:
           if(provider.currentIndex == 0 && groupProvider.totalOpenTabsCount != 0 //browserModel.webViewTabs.isEmpty == false 
           && vpnStatusProvider.canShowHomeScreen == false){
                  displayHomePage(vpnStatusProvider,webViewController!,ttsProvider);
           }else{
             context
                .read<BottomNavigationProvider>()
                .goHome();
                provider.changeIndex(index);
           }
            
            break;
        
          case 1:
          context
                .read<BottomNavigationProvider>()
                .gotoChangeNode();
                provider.changeIndex(index);
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (_) => const NodeDropdownListPage(
            //       exitData: [],
            //       canChangeNode: true,
                  
            //     ),
            //   ),
            // );
            break;
        
          case 2:
          gotoBeldexAI(themeProvider);
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (_) => const ChatScreen(),
            //   ),
            // );
            break;
      
            case 3:
            showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                   builder: (context){
              return SummariseUrlResult(aiModelProvider: AIModelProvider());
                   });
        }
          },
        
          items: [
          //  provider.currentIndex == 0 ? Container(
          //      margin: EdgeInsets.all(13),
          //     child: GlassPanel(
          //       child: SvgPicture.asset('assets/images/ai-icons/new/Home.svg'),
          //     ),
          //   ): SvgPicture.asset('assets/images/ai-icons/new/Home.svg'),
          //  provider.currentIndex == 1 ? Container(
          //     margin: EdgeInsets.all(13),
          //     child: GlassPanel(
          //       child: SvgPicture.asset('assets/images/ai-icons/new/Change_node.svg'),
          //     ),
          //   ): SvgPicture.asset('assets/images/ai-icons/new/Change_node.svg'),
          //  provider.currentIndex == 2 ? Container(
          //     margin: EdgeInsets.all(13),
          //     child: GlassPanel(
          //       //height: 30,width: 30,
          //       child: SvgPicture.asset('assets/images/ai-icons/new/Beldex_Ai.svg'),
          //     ),
          //   ) : SvgPicture.asset('assets/images/ai-icons/new/Beldex_Ai.svg'),
          //  provider.currentIndex == 3 ? Container(
          //     margin: EdgeInsets.all(13),
          //     child: GlassPanel(
          //       //height: 30,width: 30,
          //       child: SvgPicture.asset('assets/images/ai-icons/new/Tabs.svg'),
          //     ),
          //   ) : SvgPicture.asset('assets/images/ai-icons/new/Tabs.svg'),
      
          //   PopupMenuButton<String>(
          //       icon: const Icon(Icons.more_vert),
        
          //       onSelected: (value) {
        
          //         switch (value) {
        
          //           case "settings":
          //             // Navigator.push(
          //             //   context,
          //             //   MaterialPageRoute(
          //             //     builder: (_) =>
          //             //         const SettingsScreen(),
          //             //   ),
          //             // );
          //             break;
        
          //           case "downloads":
          //             // Navigator.push(
          //             //   context,
          //             //   MaterialPageRoute(
          //             //     builder: (_) =>
          //             //         const DownloadsScreen(),
          //             //   ),
          //             // );
          //             break;
          //         }
          //       },
        
          //       itemBuilder: (_) => [
        
          //         const PopupMenuItem(
          //           value: "settings",
          //           child: Text("Settings"),
          //         ),
        
          //         const PopupMenuItem(
          //           value: "downloads",
          //           child: Text("Downloads"),
          //         ),
          //       ],
          //     ),
        
            BottomNavigationBarItem(
              icon: provider.currentIndex == 0 ? Container(
                // height: 60,
                // margin: EdgeInsets.symmetric(vertical: 8),
                child: 
                GlassSettingPanel(
                  color:groupProvider.totalOpenTabsCount != 0 //browserModel.webViewTabs.isNotEmpty
                   && !vpnStatusProvider.canShowHomeScreen ? Colors.transparent : themeProvider.darkTheme ? const Color(0xFF222222).withOpacity(0.5) : const Color(0xffD4D4D4).withOpacity(0.7),
                  child: Container(
      
                  decoration: BoxDecoration(
                    color:groupProvider.totalOpenTabsCount != 0 //browserModel.webViewTabs.isNotEmpty  
                    && !vpnStatusProvider.canShowHomeScreen ? Colors.transparent : themeProvider.darkTheme ? Colors.transparent : Color(0xffFFFFFF),
                    border: Border.all(color:groupProvider.totalOpenTabsCount != 0 //browserModel.webViewTabs.isNotEmpty 
                    && !vpnStatusProvider.canShowHomeScreen ? Colors.transparent :  themeProvider.darkTheme ? Color(0xff444444): Color(0xffC0C0C0))
                  ),
                  child: SvgPicture.asset('assets/images/ai-icons/new/Home.svg',color: themeProvider.darkTheme ? Colors.white : Colors.black),
                  ),
                  ),
              ):SvgPicture.asset('assets/images/ai-icons/new/Home.svg',color: Color(0xff8D8D8D),),
              
              // Icon(Icons.home_outlined),
              //selectedIcon: Icon(Icons.home),
              label: "",
            ),
        
            BottomNavigationBarItem(
              icon: provider.currentIndex == 1 ? Container(
                // height: 60,
                //  margin: EdgeInsets.symmetric(vertical: 8),
                //margin: EdgeInsets.all(13),
                child: GlassPanel(child: Container(
                  decoration: BoxDecoration(
                    color: themeProvider.darkTheme ? Colors.transparent : Color(0xffFFFFFF),
                    border: Border.all(color:themeProvider.darkTheme ? Color(0xff444444): Color(0xffC0C0C0))
                  ),
                  child: SvgPicture.asset('assets/images/ai-icons/new/Change_node.svg',color: themeProvider.darkTheme ? Colors.white : Colors.black))),
              ):SvgPicture.asset('assets/images/ai-icons/new/Change_node.svg',color: Color(0xff8D8D8D),),
              label: "",
            ),
        
            BottomNavigationBarItem(
             icon: provider.currentIndex == 2 ? Container(
                // height: 60,
                //  margin: EdgeInsets.symmetric(vertical: 8),
                child: GlassPanel(child: Container(
                  decoration: BoxDecoration(
                    color: themeProvider.darkTheme ? Colors.transparent : Color(0xffFFFFFF),
                    border: Border.all(color:themeProvider.darkTheme ? Color(0xff444444): Color(0xffC0C0C0))
                  ),
                  child: SvgPicture.asset('assets/images/ai-icons/new/Beldex_Ai.svg',color: themeProvider.darkTheme ? Colors.white : Colors.black))),
              ):SvgPicture.asset('assets/images/ai-icons/new/Beldex_Ai.svg',color: Color(0xff8D8D8D),),
              label: "",
            
            ),
        BottomNavigationBarItem(
             icon: tabList(themeProvider,theme,bottomNavigationProvider),
            
             
             
              // Stack(
              //   children: [
      
              //     SvgPicture.asset('assets/images/ai-icons/new/Tabs.svg',color: Color(0xff8D8D8D),),
              //     Positioned.fill(
              //       right: 2,
              //       child: Center(
              //       child: Text(browserModel.webViewTabs.length.toString(),style: TextStyle(fontSize: 10),)))
              //   ],
              // ),
              label: "",  
          ),
            BottomNavigationBarItem(
              icon: 
      
      // IconButton(
      //   key: menuKey,
      //   icon: const Icon(Icons.more_horiz),
      //   onPressed: () {
      //      print('ONPRESSING POPUP ${menuKey.currentContext}');
      //     showBrowserMenu(
      //       context,
      //       menuKey,
      //       themeProvider.darkTheme,
      //     );
      //   },
      // ),
              
              MainPopupMenu(),
      
        
              label: "",
            ),
          ],
        ),
      ),
    );
  }

 bool checkCanGoforward = false;


 displayHomePage(VpnStatusProvider vpnStatusProvider,InAppWebViewController webViewController,TtsProvider ttsProvider) async{
                vpnStatusProvider.updateCanShowHomeScreen(true);
                          await webViewController?.stopLoading();
                          vpnStatusProvider.updateFAB(false);
                         ttsProvider.updateTTSDisplayStatus(false);

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
                        //  final ByteData data = await rootBundle.load('assets/images/screen-shot.png');
                        //   setState(() {
                        //     imageScreenshot = data.buffer.asUint8List();
                        //   });
                      
                          // webViewController!.loadData(data: homeHtmlContent,
                          // mimeType: 'text/html',
                          // encoding: 'utf-8'
                          // );
                          //browserModel.closeAllTabs();
                       // },
 }



Widget tabList(DarkThemeProvider themeProvider,ThemeData theme,BottomNavigationProvider bottomNavigationProvider) {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
     final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
     final tabGroupProvider = Provider.of<GroupProvider>(context,listen: false);
     final groupProvider = Provider.of<GroupProvider>(context);
     //final bottomNavigationProvider =Provider.of<BottomNavigationProvider>(context);
     final loc = AppLocalizations.of(context)!;
    return InkWell(
      key: tabInkWellsKey,
      onLongPress: () {
        final RenderBox? box =
            tabInkWellsKey.currentContext!.findRenderObject() as RenderBox?;
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
                menuPadding: EdgeInsets.zero,
                color:themeProvider.darkTheme ? Color(0xff222222).withOpacity(0.9): Color(0xffEBEBEB).withOpacity(0.9),
  elevation: 0,
  shadowColor: Colors.transparent,
  surfaceTintColor:themeProvider.darkTheme ? Color(0xff222222).withOpacity(0.9) :Color(0xffEBEBEB).withOpacity(0.9),
                 //color: themeProvider.darkTheme ?const Color(0xff282836) : const Color(0xffF3F3F3),
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
                // surfaceTintColor: Colors.green,
              //  shape: RoundedRectangleBorder(
              //   borderRadius: BorderRadius.only(
              // bottomLeft: Radius.circular(15.0),
              // bottomRight: Radius.circular(15.0),
              // topLeft: Radius.circular(15.0),
              // topRight: Radius.circular(15.0),)
              // ),
              //surfaceTintColor: themeProvider.darkTheme ?const Color(0xff282836) :const Color(0xffF3F3F3),
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
                    padding: EdgeInsets.zero,
                    //padding: EdgeInsets.symmetric(vertical: 8),
                    child: GlassSettingPanel(
                          color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffEBEBEB).withOpacity(0.7),
                      child: Container(
                        height: 35,padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
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
                          Text(getLocalizedTabListPopupMenuItemsName(tabPopupMenuAction, loc), //tabPopupMenuAction,
                          style:theme
                                            .textTheme
                                            .bodySmall!.copyWith(fontFamily: 'Inter') ,overflow: TextOverflow.ellipsis,maxLines: 1,)
                        ]),
                      ),
                    ),
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
                menuPadding: EdgeInsets.zero,
                color:themeProvider.darkTheme ? Color(0xff222222).withOpacity(0.9): Color(0xffEBEBEB).withOpacity(0.9),
  elevation: 0,
  shadowColor: Colors.transparent,
  surfaceTintColor:themeProvider.darkTheme ? Color(0xff222222).withOpacity(0.9) :Color(0xffEBEBEB).withOpacity(0.9),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.zero,
    side: BorderSide(
      color:themeProvider.darkTheme ? Color(0xff333333) :  Color(0xffD4D4D4), //.withOpacity(0.2),
      width: 1,
    ),
  ),
                 //color: themeProvider.darkTheme ?const Color(0xff282836) : const Color(0xffF3F3F3),
                 constraints: BoxConstraints(
                  maxWidth: 220,
                 ),
                // surfaceTintColor: Colors.green,
              //  shape: RoundedRectangleBorder(
              //   borderRadius: BorderRadius.only(
              // bottomLeft: Radius.circular(15.0),
              // bottomRight: Radius.circular(15.0),
              // topLeft: Radius.circular(15.0),
              // topRight: Radius.circular(15.0),)
              // ),
              //surfaceTintColor: themeProvider.darkTheme ?const Color(0xff282836) :const Color(0xffF3F3F3),
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
                    padding: EdgeInsets.zero,
                    //padding: EdgeInsets.symmetric(vertical: 8),
                    child: GlassSettingPanel(
                      color:themeProvider.darkTheme ? Color(0xFF222222).withOpacity(0.5) : Color(0xffEBEBEB).withOpacity(0.7),
                      child: Container(
                        height: 35,
                        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
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
                            child: Text(getLocalizedTabListPopupMenuItemsName(tabPopupMenuAction, loc), //tabPopupMenuAction,
                            style:theme
                                              .textTheme
                                              .bodySmall!.copyWith(fontFamily: 'Inter') ,overflow: TextOverflow.ellipsis,maxLines: 1,),
                          )
                        ]),
                      ),
                    ),
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
        groupProvider.autoGroupAllTabs();
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
    //  if (webViewModel != null && imageScreenshot != null){
    //   webViewModel.screenshot = imageScreenshot;
    //  }
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
          if(bottomNavigationProvider.currentIndex == 1){
          bottomNavigationProvider.changeIndex(0);
        }
        }
      },
      child:Stack(
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
      //  Container(
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

void addNewTab({WebUri? url}) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();
    final webViewModel = Provider.of<WebViewModel>(context, listen: false);
   // final selectedItemsProvider = Provider.of<SelectedItemsProvider>(context,listen: false);


    url ??=
        WebUri(settings.searchEngine.url);
        webViewModel.settings?.minimumFontSize = browserModel.fontSize.round();
        print('The WEBVIEWMODEL fontSize ${webViewModel.settings?.minimumFontSize}----- ${browserModel.fontSize.round()}');
    browserModel.save();
    browserModel.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(uuid: Uuid().v4(),url: url, settings: webViewModel.settings),
    ));
  }

String getLocalizedTabListPopupMenuItemsName(String actionName,AppLocalizations loc) {
 // final loc = AppLocalizations.of(context)!;

  switch (actionName) {
    case TabPopupMenuActions.NEW_TAB : return loc.newtab;
    case TabPopupMenuActions.CLOSE_TABS : return loc.closeTabs;
    default: return loc.newtab;
  }
}




void hideFooter(InAppWebViewController? webViewController) {
    print('THE WEB MODEL FROM ----');
    if (webViewController != null) {
      webViewController.evaluateJavascript(source: "hideFooter();");
    }
  }






void gotoBeldexAI(DarkThemeProvider themeProvider)async{
  bool showWelcomeMessage = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? hasSubmitted = prefs.getBool('hasSubmitted');
    setState(() {});
      showWelcomeMessage = !(hasSubmitted ?? false);
    

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: themeProvider.darkTheme ? Color(0xff111111) : Color(0xffFFFFFF),
      barrierColor: themeProvider.darkTheme ? Color(0xff111111) : Color(0xffFFFFFF),
     builder: (context){
 
     return BeldexAIScreen(isWelcomeShown: showWelcomeMessage); //DraggableAISheet();




          //return BeldexAiScreen();
     });
}


}

class MainPopupMenu extends StatefulWidget {
  const MainPopupMenu({super.key});

  @override
  State<MainPopupMenu> createState() => _MainPopupMenuState();
}

class _MainPopupMenuState extends State<MainPopupMenu> {




  final GlobalKey _appBarKey = GlobalKey();


    bool _isReporting = false;

     bool _isSharing = false;


 bool checkCanGoforward = false;

  CustomPopupDialogPageRoute? route;



bool canEnabled(AppBarPositionProvider appBarPositionProvider,BottomNavigationProvider bttomNavigationProvider){
     if(appBarPositionProvider.selectedPosition == AppBarPosition.top && bttomNavigationProvider.currentIndex == 1){
       return false;
     }
 return true;

}




  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final loc = AppLocalizations.of(context)!;

var browserModel = Provider.of<BrowserModel>(context, listen: true);
//var webViewModel = browserModel.getCurrentTab()?.webViewModel;
    var webViewModel = Provider.of<WebViewModel>(context, listen: true);
    var webViewController = webViewModel.webViewController;
    final width = MediaQuery.of(context).size.width;
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context,listen:true);
        final ttsProvider = Provider.of<TtsProvider>(context);
        final localeProvider =  Provider.of<LocaleProvider>(context);
    final bottomNavigationProvider = Provider.of<BottomNavigationProvider>(context);
    final appBarPositionProvider = Provider.of<AppBarPositionProvider>(context); 
    return StatefulBuilder(
      builder: (context,setState) {
        return PopupMenuButton<String>(
            constraints: BoxConstraints(
                minWidth: 230,maxWidth: 230
              ),
          offset: Offset(0, 47),
          menuPadding: EdgeInsets.zero,
          icon: SvgPicture.asset('assets/images/ai-icons/new/threedot.svg',color: Color(0xffC4C4C4),),
          color:themeProvider.darkTheme ? Color(0xff222222).withOpacity(0.9) : Color(0xffEBEBEB).withOpacity(0.9),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: themeProvider.darkTheme ? Color(0xff222222).withOpacity(0.9) :  Color(0xffEBEBEB).withOpacity(0.9),
          shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(
          color:themeProvider.darkTheme ? Color(0xff333333) :  Color(0xffD4D4D4), //.withOpacity(0.2),
          width: 1,
        ),
          ),
          onOpened: () => onMenuOpen(webViewController,vpnStatusProvider),
        
          onSelected: _popupMenuChoiceAction,
          itemBuilder:(popupMenuContext){


              List<PopupMenuEntry<String>> menuItems = [
                //PopupMenuItem(child: child)
              ];
        
                          // var webViewController = webViewModel!.webViewController;
        
                          // var isFavorite = false;
                          // FavoriteModel? favorite;
        
                          // if (webViewModel.url != null &&
                          //     webViewModel.url!.toString().isNotEmpty && (webViewModel.url!.scheme == "http" || webViewModel.url!.scheme == "https")) {
                          //   favorite = FavoriteModel(
                          //       url: webViewModel.url,
                          //       title: webViewModel.title ?? "",
                          //       favicon: webViewModel.favicon);
                          //   isFavorite = browserModel.containsFavorite(favorite);
                          // }
        
        
        
              menuItems.addAll(
                PopupMenuActions.choices.map((choice){
                  switch(choice){
                     case PopupMenuActions.NEW_TAB:
                      return PopupMenuItem<String>(
                  value: choice,
                  height: 35,
                  padding: EdgeInsets.zero,
                  child:GlassGroupPanel(
                        color:themeProvider.darkTheme ? Color(0xff222222) : Color(0xffEBEBEB),
                        child: Container(
                          height:35,
                          // alignment: Alignment.centerLeft,
                          // color: Colors.red,
                          // constraints: BoxConstraints(
                          //   minWidth: 210, maxWidth: 220
                          // ),
                          child: Padding(
                              padding: const EdgeInsets.only(top: 10,left: 15,right: 10),
                              child: Row(
                                children: [
                                  SvgPicture.asset('assets/images/ai-icons/new/Add_to_group_plus.svg',color:canEnabled(appBarPositionProvider,bottomNavigationProvider) ?  themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B): Colors.grey,),
                                  SizedBox(width: 5,),
                                  Expanded(
                                    child: Text('${loc.newtab}',
                                      style: TextStyle(fontFamily: 'Inter', fontSize: 14,color:canEnabled(appBarPositionProvider,bottomNavigationProvider) ? themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B): Colors.grey),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ),
                      )
                      
                ); 
                case PopupMenuActions.FAVORITES:
                      return PopupMenuItem<String>(
                  value: choice,
                  height: 35,
                  padding: EdgeInsets.zero,
                  child:GlassGroupPanel(
                        color:themeProvider.darkTheme ? Color(0xff222222) : Color(0xffEBEBEB),
                        child: Container(
                          height:35,
                          
                          // constraints: BoxConstraints(
                          //   minWidth: 210, maxWidth: 220
                          // ),
                          child: Padding(
                              padding: const EdgeInsets.only(top: 10,left: 15,right: 10),
                              child: Row(
                                children: [
                                  SvgPicture.asset('assets/images/ai-icons/new/Favorites.svg',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B),),
                                  SizedBox(width: 5,),                             
                                   Expanded(
                                    child: Text('${loc.favorites}',
                                      style: TextStyle(fontFamily: 'Inter', fontSize: 14,color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ),
                      )
                      
                );
                case PopupMenuActions.BELNET:
                      return PopupMenuItem<String>(
                  value: choice,
                  height: 35,
                  padding: EdgeInsets.zero,
                  child:GlassGroupPanel(
                        color:themeProvider.darkTheme ? Color(0xff222222) : Color(0xffEBEBEB),
                        child: Container(
                          height: 35,
                          //decoration: BoxDecoration(border: Border.all(color: themeProvider.darkTheme ? Color(0xff222222).withOpacity(0.1) : Color(0xffEBEBEB))),
                          // constraints: BoxConstraints(
                          //   minWidth: 210, maxWidth: 220
                          // ),
                          child: Padding(
                              padding: const EdgeInsets.only(top: 10,left: 15,right: 10),
                              child: Row(
                                children: [
                                   SvgPicture.asset('assets/images/ai-icons/new/Belnet.svg',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B),),
                                  SizedBox(width: 5,),
                                  Expanded(
                                    child: Text('${loc.changeNode}',
                                      style: TextStyle(fontFamily: 'Inter', fontSize: 14,color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ),
                      )
                      
                );
                case PopupMenuActions.BELDEX_AI:
                      return PopupMenuItem<String>(
                  value: choice,
                  height: 35,
                  padding: EdgeInsets.zero,
                  child:GlassGroupPanel(
                        color:themeProvider.darkTheme ? Color(0xff222222) : Color(0xffEBEBEB),
                        child: Container(
                          height: 35,
                          // constraints: BoxConstraints(
                          //   minWidth: 210, maxWidth: 220
                          // ),
                          child: Padding(
                              padding: const EdgeInsets.only(top: 10,left: 15,right: 10),
                              child: Row(
                                children: [
                                   SvgPicture.asset('assets/images/ai-icons/new/Beldex Ai_menu.svg',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B),),
                                  SizedBox(width: 5,),
                                  Expanded(
                                    child: Text('${loc.beldexAI}',
                                      style: TextStyle(fontFamily: 'Inter', fontSize: 14,color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ),
                      )
                      
                );
                case PopupMenuActions.SHARE:
                      return PopupMenuItem<String>(
                  value: choice,
                  height: 35,
                  padding: EdgeInsets.zero,
                  child:GlassGroupPanel(
                        color:themeProvider.darkTheme ? Color(0xff222222) : Color(0xffEBEBEB),
                        child: Container(
                          height: 35,
                          // constraints: BoxConstraints(
                          //   minWidth: 210, maxWidth: 220
                          // ),
                          child: Padding(
                              padding: const EdgeInsets.only(top: 10,left: 15, right: 10),
                              child: Row(
                                children: [
                                   SvgPicture.asset('assets/images/ai-icons/Share_dark.svg',color:canEnabled(appBarPositionProvider,bottomNavigationProvider) ? themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B): Colors.grey,),
                                  SizedBox(width: 5,),
                                  Expanded(
                                    child: Text('${loc.share}',
                                      style: TextStyle(fontFamily: 'Inter', fontSize: 14,color:canEnabled(appBarPositionProvider,bottomNavigationProvider) ? themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B): Colors.grey),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ),
                      )
                      
                );
                case PopupMenuActions.DIVIDER:
                      return PopupMenuItem<String>(
                  value: choice,
                  height: 35,
                  padding: EdgeInsets.zero,
                  child:GlassGroupPanel(
                        color:themeProvider.darkTheme ? Color(0xff222222) : Color(0xffEBEBEB),
                        child: Container(
                          height: 35,
                          // constraints: BoxConstraints(
                          //   minWidth: 210, maxWidth: 220
                          // ),
                          child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                                  child: Divider(
                          color: themeProvider.darkTheme
                              ? const Color(0xff333333)
                              :const Color(0xffD4D4D4),
                                                  ),
                                                ),
                        ),
                      )
                      
                );
                case PopupMenuActions.WEB_ARCHIVES:
                      return PopupMenuItem<String>(
                  value: choice,
                  height: 35,
                  padding: EdgeInsets.zero,
                  child:GlassGroupPanel(
                        color:themeProvider.darkTheme ? Color(0xff222222) : Color(0xffEBEBEB),
                        child: Container(
                          height: 35,
                          // constraints: BoxConstraints(
                          //   minWidth: 210, maxWidth: 220
                          // ),
                          child: Padding(
                              padding: const EdgeInsets.only(top: 10,left: 15,right: 10),
                              child: Row(
                                children: [
                                   SvgPicture.asset('assets/images/ai-icons/new/Web Archieves.svg',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B),),
                                  SizedBox(width: 5,),
                                  Expanded(
                                    child: Text('${loc.webArchives}',
                                      style: TextStyle(fontFamily: 'Inter', fontSize: 14,color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ),
                      )
                      
                );
                case PopupMenuActions.FIND_ON_PAGE:
                      return PopupMenuItem<String>(
                  value: choice,
                  height: 35,
                  padding: EdgeInsets.zero,
                  child:GlassGroupPanel(
                        color:themeProvider.darkTheme ? Color(0xff222222) : Color(0xffEBEBEB),
                        child: Container(
                          height: 35,
                          // constraints: BoxConstraints(
                          //   minWidth: 210, maxWidth: 220
                          // ),
                          child: Padding(
                              padding: const EdgeInsets.only(top: 10,left: 15,right: 10),
                              child: Row(
                                children: [
                                   SvgPicture.asset('assets/images/ai-icons/new/Find on page.svg',color:canEnabled(appBarPositionProvider,bottomNavigationProvider) ? themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B): Colors.grey,),
                                  SizedBox(width: 5,),
                                  Expanded(
                                    child: Text('${loc.findOnPage}',
                                      style: TextStyle(fontFamily: 'Inter', fontSize: 14,color:canEnabled(appBarPositionProvider,bottomNavigationProvider) ? themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B): Colors.grey),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ),
                      )
                      
                );
                case PopupMenuActions.DOWNLOADS:
                      return PopupMenuItem<String>(
                  value: choice,
                  height: 35,
                  padding: EdgeInsets.zero,
                  child:GlassGroupPanel(
                        color:themeProvider.darkTheme ? Color(0xff222222) : Color(0xffEBEBEB),
                        child: Container(
                          height: 35,
                          // constraints: BoxConstraints(
                          //   minWidth: 210, maxWidth: 220
                          // ),
                          child: Padding(
                              padding: const EdgeInsets.only(top: 10,left: 15,right: 10),
                              child: Row(
                                children: [
                                  SvgPicture.asset('assets/images/ai-icons/new/downloads.svg',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B),),
                                  SizedBox(width: 5,),
                                  Expanded(
                                    child: Text('${loc.downloads}',
                                      style: TextStyle(fontFamily: 'Inter', fontSize: 14,color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ),
                      )
                      
                );
                case PopupMenuActions.INVITE_PEOPLE:
                      return PopupMenuItem<String>(
                  value: choice,
                  height: 35,
                  padding: EdgeInsets.zero,
                  child:GlassGroupPanel(
                        color:themeProvider.darkTheme ? Color(0xff222222) : Color(0xffEBEBEB),
                        child: Container(
                          height: 35,
                          // constraints: BoxConstraints(
                          //   minWidth: 210, maxWidth: 220
                          // ),
                          child: Padding(
                              padding: const EdgeInsets.only(top: 10,left: 15, right: 10),
                              child: Row(
                                children: [
                                   SvgPicture.asset('assets/images/ai-icons/new/Share.svg',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B),),
                                  SizedBox(width: 5,),
                                  Expanded(
                                    child: Text(loc.invitePeople,
                                      style: TextStyle(fontFamily: 'Inter', fontSize: 14,color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ),
                      )
                      
                );
                case PopupMenuActions.DESKTOP_MODE:
                      return PopupMenuItem<String>(
                  value: choice,
                  height: 35,
                  padding: EdgeInsets.zero,
                  child:GlassGroupPanel(
                        color:themeProvider.darkTheme ? Color(0xff222222) : Color(0xffEBEBEB),
                        child: Container(
                          height: 35,
                          // constraints: BoxConstraints(
                          //   minWidth: 210, maxWidth: 220
                          // ),
                          child: Padding(
                              padding: const EdgeInsets.only(top: 10,left: 15, right: 10),
                              child: Row(
                                children: [
                                   SvgPicture.asset('assets/images/ai-icons/new/desktop_mode.svg',color:canEnabled(appBarPositionProvider,bottomNavigationProvider) ? webViewModel.isDesktopMode ? Colors.green : themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B): Colors.grey,),
                                  SizedBox(width: 5,),
                                  Expanded(
                                    child: Text('${loc.desktopMode}',
                                      style: TextStyle(fontFamily: 'Inter', fontSize: 14,color:canEnabled(appBarPositionProvider,bottomNavigationProvider) ? themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B): Colors.grey),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ),
                      )
                      
                );
                case PopupMenuActions.SETTINGS:
                      return PopupMenuItem<String>(
                  value: choice,
                  height: 35,
                  padding: EdgeInsets.zero,
                  child:GlassGroupPanel(
                        color:themeProvider.darkTheme ? Color(0xff222222) : Color(0xffEBEBEB),
                        child: Container(
                          height: 35,
                          // constraints: BoxConstraints(
                          //   minWidth: 210, maxWidth: 220
                          // ),
                          child: Padding(
                              padding: const EdgeInsets.only(top: 10,left: 15,right: 10),
                              child: Row(
                                children: [
                                   SvgPicture.asset('assets/images/ai-icons/new/Settings.svg',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B),),
                                  SizedBox(width: 5,),
                                  Expanded(
                                    child: Text('${loc.settings}',
                                      style: TextStyle(fontFamily: 'Inter', fontSize: 14,color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ),
                      )
                      
                );
                case PopupMenuActions.DARKMODE:
                      return PopupMenuItem<String>(
                  value: choice,
                  height: 35,
                  padding: EdgeInsets.zero,
                  child:GlassGroupPanel(
                        color:themeProvider.darkTheme ? Color(0xff222222) : Color(0xffEBEBEB),
                        child: Container(
                          height: 35,
                          // constraints: BoxConstraints(
                          //   minWidth: 210, maxWidth: 220
                          // ),
                          child: Padding(
                              padding: const EdgeInsets.only(top: 10,left: 15,right: 10),
                              child: Row(
                                children: [
                                   SvgPicture.asset('assets/images/ai-icons/new/Edit Group Color.svg',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B),),
                                  SizedBox(width: 5,),
                                  Expanded(
                                    child: Text('${loc.dark}',
                                      style: TextStyle(fontFamily: 'Inter', fontSize: 14,color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                   Container(
            margin: EdgeInsets.only(left: 5),
            //width: 50,
            height: 28,
            child: AnimatedToggleSwitch(appbarKey: _appBarKey)),
                                ],
                              ),
                            ),
                        ),
                      )
                      
                );
                case PopupMenuActions.REPORT_AN_ISSUE:
                      return PopupMenuItem<String>(
                  value: choice,
                  height: 35,
                  padding: EdgeInsets.zero,
                  child:GlassGroupPanel(
                        color:themeProvider.darkTheme ? Color(0xff222222) : Color(0xffEBEBEB),
                        child: Container(
                          height: 35,
                          // constraints: BoxConstraints(
                          //   minWidth: 210, maxWidth: 220
                          // ),
                          child: Padding(
                              padding: const EdgeInsets.only(top: 10,left: 15, right: 10),
                              child: Row(
                                children: [
                                  SvgPicture.asset('assets/images/ai-icons/new/Report an Issue.svg',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B),),
                                  SizedBox(width: 5,),
                                  Expanded(
                                    child: Text('${loc.reportAnIssue}',
                                      style: TextStyle(fontFamily: 'Inter', fontSize: 14,color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ),
                      )
                      
                );
                case PopupMenuActions.ABOUT:
                      return PopupMenuItem<String>(
                  value: choice,
                  height: 35,
                  padding: EdgeInsets.zero,
                  child:GlassGroupPanel(
                        color:themeProvider.darkTheme ? Color(0xff222222) : Color(0xffEBEBEB),
                        child: Container(
                          height: 35,
                          // constraints: BoxConstraints(
                          //   minWidth: 210, maxWidth: 220
                          // ),
                          child: Padding(
                              padding: const EdgeInsets.only(top: 10,left: 15, right: 10),
                              child: Row(
                                children: [
                                  SvgPicture.asset('assets/images/ai-icons/new/about.svg',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B),),
                                  SizedBox(width: 5,),
                                  Expanded(
                                    child: Text('${loc.about}',
                                      style: TextStyle(fontFamily: 'Inter', fontSize: 14,color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ),
                      )
                      
                );
                case PopupMenuActions.QUIT_VPN:
                      return PopupMenuItem<String>(
                  value: choice,
                  height: 40,
                  padding: EdgeInsets.zero,
                  child:GlassGroupPanel(
                        color:themeProvider.darkTheme ? Color(0xff222222) : Color(0xffEBEBEB),
                        child: Container(
                          height: 40,
                          // constraints: BoxConstraints(
                          //   minWidth: 210, maxWidth: 220
                          // ),
                          child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                              child: Row(
                                children: [
                                  SvgPicture.asset('assets/images/ai-icons/new/quit.svg',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B),),
                                  SizedBox(width: 5,),
                                  Expanded(
                                    child: Text('${loc.quit}',
                                      style: TextStyle(fontFamily: 'Inter', fontSize: 14,color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B)),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ),
                      )
                      
                );
                default: 
                   return PopupMenuItem<String>(
                    child: SizedBox()
                    );
                  }
                }).toList()
              );
        
        
              menuItems.add(
                 PopupMenuItem<String>(
          //value: 'delete',
          height: 40,
          enabled: canEnabled(appBarPositionProvider,bottomNavigationProvider),
          padding: EdgeInsets.zero,
          child: 
              GlassGroupPanel(
                 color:themeProvider.darkTheme ? Color(0xff222222) : Color(0xffEBEBEB),
                child: Container(
                   height: 40,
                   //width: 190,
                  padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                  // decoration: BoxDecoration(
                  //   color:Colors.transparent, //Color(0xff222222).withOpacity(0.7),
                  //   //borderRadius: BorderRadius.circular(16),
                  //   // 
                  // ),
                  child:  StatefulBuilder(
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
                              webViewModel.url!.toString().isNotEmpty && (webViewModel.url!.scheme == "http" || webViewModel.url!.scheme == "https")) {
                            favorite = FavoriteModel(
                                url: webViewModel.url,
                                title: webViewModel.title ?? "",
                                favicon: webViewModel.favicon);
                            isFavorite = browserModel.containsFavorite(favorite);
                          }
        

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                             GestureDetector(
                              onTap:canEnabled(appBarPositionProvider,bottomNavigationProvider) && !vpnStatusProvider.canShowHomeScreen ? (){
                                          //webViewController?.goBack();
                                          webViewController?.goForward();
                                          Navigator.pop(popupMenuContext);
                                        }:null,
                              child: SvgPicture.asset('assets/images/ai-icons/new/forward.svg',color:  checkCanGoforward ?
                               themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B) : Colors.grey)),
                             GestureDetector(
                              onTap:// vpnStatusProvider.canShowHomeScreen ? null : (){
                                canEnabled(appBarPositionProvider,bottomNavigationProvider) && !vpnStatusProvider.canShowHomeScreen ? () {
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
                                        }:null,
                              //} ,
                              child:canEnabled(appBarPositionProvider,bottomNavigationProvider) ?
                              vpnStatusProvider.canShowHomeScreen ?
                                 SvgPicture.asset('assets/images/ai-icons/new/Favorites.svg',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B))
                               : isFavorite 
                               ? SvgPicture.asset('assets/images/ai-icons/new/Star.svg',)
                               : SvgPicture.asset('assets/images/ai-icons/new/Favorites.svg',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B))
                               :SvgPicture.asset('assets/images/ai-icons/new/Favorites.svg',color: Colors.grey)
                               ),
                             GestureDetector(
                              onTap:canEnabled(appBarPositionProvider,bottomNavigationProvider) && !vpnStatusProvider.canShowHomeScreen ? () async {
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
                                              showMessage(loc.thispageAlreadySavedOffline);
                                              // return;
                                            } else {
                                              if (savedPath != null) {
                                                browserModel.addWebArchive(
                                                    url.toString(), webArchiveModel);
                                                if (mounted) {
                                                  showMessage(loc.pageSavedOffline );
                                                }
                                                browserModel.save();
                                              } else {
                                                if (mounted) {
                                                  showMessage(loc.unabledToSave);
                                                }
                                              }
                                            }
                                          }
                                        }:null,
                              child: SvgPicture.asset('assets/images/ai-icons/new/Download.svg',color:canEnabled(appBarPositionProvider,bottomNavigationProvider) ? themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B): Colors.grey)),
                             GestureDetector(
                              onTap: (){
                                 Navigator.pop(popupMenuContext);  
                                         navigateToBeldexNetwork(webViewController,appBarPositionProvider,bottomNavigationProvider);
                              },
                              child: SvgPicture.asset('assets/images/ai-icons/new/belnet.svg',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B))),
                             GestureDetector(
                              onTap:canEnabled(appBarPositionProvider,bottomNavigationProvider) && !vpnStatusProvider.canShowHomeScreen ? () async {
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
                                            takeScreenshotAndShow(loc);
                                          } else {
                                            Fluttertoast.showToast(
                                                msg:loc.screensecurityCurrentlyEnabled);
                                          }
                                        }:null,
                              child: SvgPicture.asset('assets/images/ai-icons/new/External Link 1.svg', color:canEnabled(appBarPositionProvider,bottomNavigationProvider) ? themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B): Colors.grey)),
                            canEnabled(appBarPositionProvider,bottomNavigationProvider) ?
                             PageLoadingContainer(
                              webViewController: webViewController,
                              popupMenuContext: popupMenuContext,
                              searchController: TextEditingController(text: browserModel.userInput),
                            )
                            : Container(child: SvgPicture.asset('assets/images/ai-icons/new/refresh.svg',color:Colors.grey))
                            
                        ],
                      );
                    }
                  ),
                ),
              ),
           // ),
          //),
        )
              );
        
              return menuItems;
          });
      }
    );
  }


 void hideFooter(InAppWebViewController? webViewController) {
    print('THE WEB MODEL FROM ----');
    if (webViewController != null) {
      webViewController.evaluateJavascript(source: "hideFooter();");
    }
  }

Future onMenuOpen(InAppWebViewController? webViewController,VpnStatusProvider vpnStatusProvider)async {
 hideFooter(webViewController);
            try {
              
              checkCanGoforward = await webViewController?.canGoForward() ?? false;
              vpnStatusProvider.updateFAB(false);
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


void _popupMenuChoiceAction(String choice) async {
    var currentWebViewModel = Provider.of<WebViewModel>(context, listen: false);
    final browserModel = Provider.of<BrowserModel>(context,listen: false);
    final themeProvider =
        Provider.of<DarkThemeProvider>(context, listen: false);
     final vpnStatusProvider = Provider.of<VpnStatusProvider>(context,listen: false);
     var webViewModel = Provider.of<WebViewModel>(context, listen: false);
    var webViewController = webViewModel.webViewController;
    final loc = AppLocalizations.of(context)!;
    final bottomNavigationProvider = Provider.of<BottomNavigationProvider>(context,listen: false);
    final appBarPositionProvider = Provider.of<AppBarPositionProvider>(context,listen: false); 
    switch (choice) {
       case PopupMenuActions.NEW_TAB:
       if(canEnabled(appBarPositionProvider,bottomNavigationProvider) ){
         vpnStatusProvider.updateCanShowHomeScreen(false);
        addNewTab();
       }
       
        break;
      // case PopupMenuActions.NEW_INCOGNITO_TAB:
      //   addNewIncognitoTab();
      //   break;
      case PopupMenuActions.FAVORITES:
        showFavorites(loc,themeProvider);
        break;
      
      case PopupMenuActions.WEB_ARCHIVES:
        showWebArchives(themeProvider,vpnStatusProvider,loc);
        break;
      case PopupMenuActions.BELDEX_AI:
        goToBeldexAIPage();
        break;
        case PopupMenuActions.FIND_ON_PAGE:
        if(canEnabled(appBarPositionProvider,bottomNavigationProvider))
      if(!vpnStatusProvider.canShowHomeScreen){
        var isFindInteractionEnabled =
            currentWebViewModel.settings?.isFindInteractionEnabled ?? false;
        var findInteractionController =
            currentWebViewModel.findInteractionController;
            print('THE I FOR FIND_ONPAGE IS WORKING');
            browserModel.updateFindOnPage(true);
        if (Util.isIOS() &&
            isFindInteractionEnabled &&
            findInteractionController != null) {
          await findInteractionController.presentFindNavigator();
        }
        
        else if(WebViewTabAppBar().showFindOnPage != null){
          WebViewTabAppBar().showFindOnPage!();
          browserModel.updateFindOnPage(true);
          print('THE ELSE FOR FIND_ONPAGE IS WORKING');
        }
        //  else if (widget.showFindOnPage != null) {
        //   widget.showFindOnPage!();

        // }
        }
        break;
      case PopupMenuActions.SHARE:
      if(canEnabled(appBarPositionProvider,bottomNavigationProvider) )
      if(!vpnStatusProvider.canShowHomeScreen){
        share();}
        break;
      case PopupMenuActions.DOWNLOADS:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => DownloadUI()));
        break;
case PopupMenuActions.INVITE_PEOPLE:
           invitePeople();
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => DownloadUI()));
        break;

      case PopupMenuActions.DESKTOP_MODE:
      if(canEnabled(appBarPositionProvider,bottomNavigationProvider) )
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
        navigateToBeldexNetwork(webViewController,appBarPositionProvider,bottomNavigationProvider);
        break;

      case PopupMenuActions.ABOUT:
        goToAbout();
        break;
      case PopupMenuActions.REPORT_AN_ISSUE:
        reportIssue();
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


void showWebArchives(DarkThemeProvider themeProvider,VpnStatusProvider vpnStatusProvider, AppLocalizations loc) async {
showModalBottomSheet(
      context: context,
      isScrollControlled: true,
     builder: (context){
     return WebArchives();
      //DraggableAISheet();
   //return BeldexAiScreen();
     });
}


void showFavorites(AppLocalizations loc,DarkThemeProvider themeProvider) async {


showModalBottomSheet(
      context: context,
      isScrollControlled: true,
     builder: (context){

     return FavoritesScreen();
      //DraggableAISheet();




          //return BeldexAiScreen();
     });
}


void goToBeldexAIPage()async{
    bool showWelcomeMessage = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? hasSubmitted = prefs.getBool('hasSubmitted');
    setState(() {});
      showWelcomeMessage = !(hasSubmitted ?? false);
    

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
     builder: (context){

     return BeldexAIScreen(isWelcomeShown: showWelcomeMessage); //DraggableAISheet();




          //return BeldexAiScreen();
     });
  }


void navigateToBeldexNetwork(InAppWebViewController? webViewController,AppBarPositionProvider appBarPositionProvider,BottomNavigationProvider bottomNavigationProvider)async{
   if(appBarPositionProvider.selectedPosition == AppBarPosition.bottom){
     Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChangeNodePage(
                exitData: [], canChangeNode: true,
                webViewController: webViewController,
              )));
   }else{
      bottomNavigationProvider.changeIndex(1);
   }
      
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
        final loc = AppLocalizations.of(context)!;
        final localeProvider = Provider.of<LocaleProvider>(context,listen:false);




 showDialog(
      context: context,
      barrierColor:  themeProvider.darkTheme ? Colors.black54 : Color(0xffFFFFFFE).withOpacity(0.8),
      builder: (BuildContext context) {
                return Dialog(
          insetPadding: EdgeInsets.all(18),
            backgroundColor: Colors.transparent,
          child: GlassSettingPanel(
           color: themeProvider.darkTheme ? Color(0xff1A1A1A).withOpacity(0.8) : Color(0xffEBEBEB) ,
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: themeProvider.darkTheme ? Color(0xff444444) : Color(0xffD4D4D4))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextWidget(
                      text: loc.quitBrowser, //'Quit Browser',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,fontFamily: 'Inter'),
                    ),
                  ),
                  TextWidget(
                   text:loc.rUSureWantToQuitApp,// 'Are you sure you want to quit?',
                    style: TextStyle(fontWeight: FontWeight.w500,fontFamily: 'Roboto',),
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
                                ? Color(0xff333333)
                                : Color(0xffF3F3F3),
                            disabledColor: Color(0xff2C2C3B),
                            minWidth: double.maxFinite,
                            height: 50,
                            shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.zero,
  ),

                            child: TextWidget(text:loc.cancel ,// 'Cancel',
                             style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600, fontFamily: 'Inter',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff444444))),
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(
                            //       10.0), // Adjust the radius as needed
                            // ),
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
                            color:  themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B),// Color(0xff00B134),
                            disabledColor: Color(0xff2C2C3B),
                            minWidth: double.maxFinite,
                            height: 50,
                            shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.zero,
  ),

                            child: TextWidget( text:loc.quit, // 'Quit',
                                style:
                                    TextStyle(fontSize: 16,fontFamily: 'Inter',color: themeProvider.darkTheme ? Color(0xff0B0B0B) : Color(0xffEBEBEB),fontWeight: FontWeight.w600)),
                            
                            onPressed: () async {
                              var disConnectValue =
                                  await BelnetLib.disconnectFromBelnet();
                              print('belnet vpn disconnected $disConnectValue');
                              // Future.delayed(Duration(milliseconds: 200),
                              //     (() => Navigator.of(context).pop(true)));
                              // Navigator.of(context).pop(true);
                              Navigator.of(context).pop();
  await Future.delayed(const Duration(milliseconds: 200));
  SystemNavigator.pop();
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );




    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return Dialog(
    //       backgroundColor:
    //           themeProvider.darkTheme ? Color(0xff282836) : Color(0xffFFFFFF),
    //       insetPadding: EdgeInsets.all(20),
    //       child: Container(
    //         width: MediaQuery.of(context).size.width,
    //         //height: 170,
    //         padding: EdgeInsets.all(15),
    //         decoration: BoxDecoration(
    //             color: themeProvider.darkTheme
    //                 ? Color(0xff282836)
    //                 : Color(0xffFFFFFF),
    //             borderRadius: BorderRadius.circular(15)),
    //         child: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           children: <Widget>[
    //             Padding(
    //               padding: const EdgeInsets.symmetric(vertical: 8.0),
    //               child: TextWidget(
    //                text:loc.quitBrowser,// 'Quit Browser',
    //                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    //               ),
    //             ),
    //             TextWidget(
    //              text:loc.rUSureWantToQuitApp, // 'Are you sure you want to quit?',
    //               style: TextStyle(fontWeight: FontWeight.w500),
    //               textAlign: TextAlign.center,
    //             ),
    //             Row(
    //               children: [
    //                 Expanded(
    //                   flex: 1,
    //                   child: Padding(
    //                     padding: const EdgeInsets.symmetric(
    //                       vertical: 10.0,
    //                     ),
    //                     child: MaterialButton(
    //                       elevation: 0,
    //                       color: themeProvider.darkTheme
    //                           ? Color(0xff39394B)
    //                           : Color(0xffF3F3F3),
    //                       disabledColor: Color(0xff2C2C3B),
    //                       minWidth: double.maxFinite,
    //                       height: 50,
    //                       child: TextWidget(text:loc.cancel, // 'Cancel',
    //                        style: TextStyle(fontSize:isLengthyLanguageInList(localeProvider.selectedLanguage) ? 13 : 18)),
    //                       shape: RoundedRectangleBorder(
    //                         borderRadius: BorderRadius.circular(
    //                             10.0), // Adjust the radius as needed
    //                       ),
    //                       onPressed: () {
    //                         Navigator.of(context).pop(false);
    //                       },
    //                     ),
    //                   ),
    //                 ),
    //                const SizedBox(
    //                   width: 10,
    //                 ),
    //                 Expanded(
    //                   flex: 1,
    //                   child: Padding(
    //                     padding: const EdgeInsets.symmetric(vertical: 10.0),
    //                     child: MaterialButton(
    //                       elevation: 0,
    //                       color: themeProvider.darkTheme
    //                           ? Color(0xff39394B)
    //                           : Color(0xffF3F3F3), // Color(0xff00B134),
    //                       disabledColor: Color(0xff2C2C3B),
    //                       minWidth: double.maxFinite,
    //                       height: 50,
    //                       child: TextWidget(text:loc.quit, //'Quit',
    //                           style:
    //                               TextStyle(color: Colors.red, fontSize:isLengthyLanguageInList(localeProvider.selectedLanguage) ? 13 : 18)),
    //                       shape: RoundedRectangleBorder(
    //                         borderRadius: BorderRadius.circular(
    //                             10.0), // Adjust the radius as needed
    //                       ),
    //                       onPressed: () async {
    //                         var disConnectValue =
    //                             await BelnetLib.disconnectFromBelnet();
    //                         print('belnet vpn disconnected $disConnectValue');
    //                         Future.delayed(Duration(milliseconds: 200),
    //                             (() => SystemNavigator.pop()));
    //                         // Navigator.of(context).pop(true);
    //                       },
    //                     ),
    //                   ),
    //                 ),
    //               ],
    //             )
    //           ],
    //         ),
    //       ),
    //     );
    //   },
    // );
  }

  void addNewTab({WebUri? url}) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();
    final webViewModel = Provider.of<WebViewModel>(context, listen: false);
   // final selectedItemsProvider = Provider.of<SelectedItemsProvider>(context,listen: false);
    browserModel.showTabScroller = false;

    url ??=
        WebUri(settings.searchEngine.url);
        webViewModel.settings?.minimumFontSize = browserModel.fontSize.round();
        print('The WEBVIEWMODEL fontSize ${webViewModel.settings?.minimumFontSize}----- ${browserModel.fontSize.round()}');
    browserModel.save();
    browserModel.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(uuid: Uuid().v4(),url: url, settings: webViewModel.settings),
    ));
  }

  void addNewIncognitoTab({WebUri? url}) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();
     final webViewModel = Provider.of<WebViewModel>(context, listen: false);
    //final selectedItemsProvider = Provider.of<SelectedItemsProvider>(context,listen: false);


    url ??=
        WebUri(settings.searchEngine.url);
     webViewModel.settings?.minimumFontSize = browserModel.fontSize.round();
    browserModel.save();
    browserModel.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(uuid: Uuid().v4(),url: url, isIncognitoMode: true, settings: webViewModel.settings),
    ));
  }


  void reportIssue() async {
    if(_isReporting) return;

    setState(() {
      
    });
    _isReporting = true;
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: 'support@beldex.io', // 
    query: Uri.encodeFull('subject=Feedback Report: Beldex Browser_Android&body='),
  );

  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  // setState(() {}); _isReporting = false;
  } else {
  // setState(() { }); _isReporting = false;
    // Optionally, handle the error if no email app is available
    print('Could not launch email app');
  }
  _isReporting = false;
}


  // void showFavorites(AppLocalizations loc) async {
  //   await showDialog<void>(
  //       barrierDismissible: false,
  //       context: context,
  //       builder: (BuildContext context) {
  //         var browserModel = Provider.of<BrowserModel>(context, listen: true);
  //         final themeProvider =
  //             Provider.of<DarkThemeProvider>(context, listen: true);
  //         final vpnStatusProvider = Provider.of<VpnStatusProvider>(context,listen: true);
  //         return Dialog(
  //           backgroundColor:
  //               themeProvider.darkTheme ? Color(0xff2C2C3B) : Color(0xffF3F3F3),
  //           insetPadding: EdgeInsets.all(15),
  //             shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(12)
  //           ),
  //           child: Container(
  //             width: MediaQuery.of(context).size.width,
  //             height: MediaQuery.of(context).size.height,
  //             padding: EdgeInsets.all(10),
  //             decoration:
  //                 BoxDecoration(borderRadius: BorderRadius.circular(12)),
  //             child: Stack(
  //               children: [
  //                 Column(
  //                   children: [
  //                     Padding(
  //                       padding: const EdgeInsets.only(
  //                           top: 8.0, bottom: 15, left: 8, right: 8),
  //                       child: TextWidget(
  //                        text:loc.favorites, //'Favorites',
  //                         style: TextStyle(
  //                             fontSize: 20, fontWeight: FontWeight.bold),
  //                       ),
  //                     ),
  //                     Expanded(
  //                         child: browserModel.favorites.isEmpty
  //                             ? Center(child: TextWidget(text:loc.noFavorites, //'No Favorites'
  //                             ))
  //                             :
  //                             // listViewChildren.isEmpty ?  Center(child: Text('No Web archives')):
  //                             ListView(
  //                                 children:
  //                                     browserModel.favorites.map((favorite) {
  //                                   var url = favorite.url;
  //                                   var faviconUrl = favorite.favicon != null
  //                                       ? favorite.favicon!.url
  //                                       : WebUri(
  //                                           "${url?.origin ?? ""}/favicon.ico");
  //                                   return InkWell(
  //                                     onTap: () {
  //                                       setState(() {
  //                                             vpnStatusProvider.updateCanShowHomeScreen(false);
  //                                         addNewTab(url: favorite.url);
  //                                         Navigator.pop(context);
  //                                       });
  //                                     },
  //                                     child: Container(
  //                                         margin: EdgeInsets.only(bottom: 10),
  //                                         padding: EdgeInsets.all(8),
  //                                         decoration: BoxDecoration(
  //                                             border: Border.all(
  //                                                 color: themeProvider.darkTheme
  //                                                     ?const Color(0xff42425F)
  //                                                     :const Color(0xffDADADA)),
  //                                             borderRadius:
  //                                                 BorderRadius.circular(10)),
  //                                         height: 60,
  //                                         child: Row(children: [
  //                                           Padding(
  //                                               padding: const EdgeInsets.only(
  //                                                   right: 8.0),
  //                                               child: CustomImage(
  //                                                 url: faviconUrl,
  //                                                 maxWidth: 30.0,
  //                                                 height: 30.0,
  //                                               )),
  //                                           Expanded(
  //                                             child: Container(
  //                                               child: Column(
  //                                                 crossAxisAlignment:
  //                                                     CrossAxisAlignment.start,
  //                                                 children: [
  //                                                   TextWidget(
  //                                                      text: favorite.title ??
  //                                                           favorite.url
  //                                                               ?.toString() ??
  //                                                           "",
  //                                                       maxLines: 1,
  //                                                       overflow: TextOverflow
  //                                                           .ellipsis),
  //                                                   TextWidget(
  //                                                    text:  browserModel.getDisplayUrl(favorite.url
  //                                                             ?.toString() ??
  //                                                         ""),
  //                                                     maxLines: 1,
  //                                                     overflow:
  //                                                         TextOverflow.ellipsis,
  //                                                     style: TextStyle(
  //                                                         color: themeProvider
  //                                                                 .darkTheme
  //                                                             ? const Color(
  //                                                                 0xff6D6D81)
  //                                                             :const Color(
  //                                                                 0xff6D6D81)),
  //                                                   ),
  //                                                 ],
  //                                               ),
  //                                             ),
  //                                           ),
  //                                           Container(
  //                                             width: 35,
  //                                             //color: Colors.yellow,
  //                                             child: IconButton(
  //                                               icon: Icon(Icons.close,
  //                                                   color:
  //                                                       themeProvider.darkTheme
  //                                                           ?const Color(0xff6D6D81)
  //                                                           :const Color(0xffC5C5C5),
  //                                                   size:
  //                                                       20), //SvgPicture.asset('assets/images/close.svg', color:  themeProvider.darkTheme ? Color(0xff6D6D81) : Color(0xffC5C5C5), height: 20,width: 20,),
  //                                               onPressed: () async {
  //                                                 setState(() {
  //                                                   browserModel.removeFavorite(
  //                                                       favorite);
  //                                                   if (browserModel
  //                                                       .favorites.isEmpty) {
  //                                                     Navigator.pop(context);
  //                                                   }
  //                                                 });
  //                                               },
  //                                             ),
  //                                           ),
  //                                         ])),
  //                                   );
  //                                 }).toList(),
  //                               ))
  //                   ],
  //                 ),
  //                 Container(
  //                     margin: EdgeInsets.only(top: 7, right: 10),
  //                     alignment: Alignment.topRight,
  //                     child: InkWell(
  //                       onTap: () {
  //                         Navigator.pop(context);
  //                       },
  //                       child: Container(
  //                           decoration: BoxDecoration(shape: BoxShape.circle),
  //                           child: Icon(Icons.close)),
  //                     ))
  //               ],
  //             ),
  //           ),
  //         );
  //       });
  // }

// void showWebArchives(DarkThemeProvider themeProvider,VpnStatusProvider vpnStatusProvider, AppLocalizations loc) async {
//     await showDialog<void>(
//         barrierDismissible: false,
//         context: context,
//         builder: (BuildContext context) {
//           var browserModel = Provider.of<BrowserModel>(context, listen: true);
//           var webArchives = browserModel.webArchives;

//           var listViewChildren = <Widget>[];
//           webArchives.forEach((key, webArchive) {
//             var path = webArchive.path;
//             // String fileName = path.substring(path.lastIndexOf('/') + 1);

//             var url = webArchive.url;

//             listViewChildren.add(InkWell(
//               onTap: () {
//                 if (path != null) {
//                   var browserModel =
//                       Provider.of<BrowserModel>(context, listen: false);
//                   vpnStatusProvider.updateCanShowHomeScreen(false);
//                   browserModel.addTab(WebViewTab(
//                     key: GlobalKey(),
//                     webViewModel: WebViewModel(uuid: Uuid().v4(),url: WebUri("file://$path")),
//                   ));
//                 }
//                 Navigator.pop(context);
//               },
//               child: Container(
//                   margin: EdgeInsets.only(bottom: 10),
//                   padding: EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                       border: Border.all(
//                           color: themeProvider.darkTheme
//                               ? Color(0xff42425F)
//                               : Color(0xffDADADA)),
//                       borderRadius: BorderRadius.circular(8)
//                       ),
//                   height: 60,
//                   child: Row(children: [
//                     Padding(
//                       padding: const EdgeInsets.only(right: 8.0),
//                       child: SvgPicture.asset(
//                         'assets/images/webarchives.svg',
//                         color: themeProvider.darkTheme
//                             ? Color(0xff6D6D81)
//                             : Color(0xffC5C5C5),
//                       ),
//                     ),
//                     Expanded(
//                       child: Container(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             TextWidget(
//                              text: webArchive.title ?? url?.toString() ?? "",
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(fontWeight: FontWeight.w600),
//                             ),
//                             TextWidget(
//                              text:browserModel.getDisplayUrl(url?.toString() ?? ""),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                   color: themeProvider.darkTheme
//                                       ? Color(0xff6D6D81)
//                                       : Color(0xff6D6D81)),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Container(
//                       width: 35,
//                       //color: Colors.yellow,
//                       child: IconButton(
//                         icon: SvgPicture.asset(
//                           'assets/images/delete.svg',
//                           color: themeProvider.darkTheme
//                               ? Color(0xff6D6D81)
//                               : Color(0xffC5C5C5),
//                           height: 20,
//                           width: 20,
//                         ),
//                         onPressed: () async {
//                           setState(() {
//                             browserModel.removeWebArchive(webArchive);
//                             browserModel.save();
//                           });
//                         },
//                       ),
//                     ),
//                   ])),
//             ));
//           });
//           return Dialog(
//             backgroundColor:
//                 themeProvider.darkTheme ? Color(0xff2C2C3B) : Color(0xffF3F3F3),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12)
//             ),
//             insetPadding: EdgeInsets.all(15),
//             child: Container(
//               width: MediaQuery.of(context).size.width,
//               height: MediaQuery.of(context).size.height,
//               padding: EdgeInsets.all(10),
//               decoration:
//                   BoxDecoration(borderRadius: BorderRadius.circular(12)),
//               child: Stack(
//                 children: [
//                   Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.only(
//                             top: 8.0, bottom: 15, left: 8, right: 8),
//                         child: TextWidget(
//                          text:loc.webArchives, // 'Web Archives',
//                           style: TextStyle(
//                               fontSize: 20, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       Expanded(
//                           child: listViewChildren.isEmpty
//                               ? Center(child: TextWidget(text:loc.noWebArchives, //'No Web Archives'
//                               ))
//                               : ListView(
//                                   children: listViewChildren,
//                                 ))
//                     ],
//                   ),
//                   Container(
//                       margin: EdgeInsets.only(top: 7, right: 10),
//                       alignment: Alignment.topRight,
//                       child: InkWell(
//                         onTap: () {
//                           Navigator.pop(context);
//                         },
//                         child: Container(
//                             decoration: BoxDecoration(shape: BoxShape.circle),
//                             child:const Icon(Icons.close)),
//                       ))
//                 ],
//               ),
//             ),
//           );
//         });
//   }

  void share() {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);

        final addEngineProvider =
        Provider.of<AddSearchEngineProvider>(context, listen: false);

    final selectedSessionEngines =
        addEngineProvider.selectedSessionEngines;
    var webViewModel = browserModel.getCurrentTab()?.webViewModel;

    var url = webViewModel?.url;
    if (url != null) {
      if(url.toString().isNotEmpty && !(url.toString().startsWith('https://') && checkSearchEngineInUrl(SearchEngines, selectedSessionEngines, url))){

      Share.share(browserModel.getDisplayUrl(url.toString()), subject: webViewModel?.title);
      }else{
               Share.share(url.toString(), subject: webViewModel?.title);
      }
      //Share.share(url.toString(), subject: webViewModel?.title);
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
         await webViewController.reload();
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

  // void showUrlInfo() {
  //   var webViewModel = Provider.of<WebViewModel>(context, listen: false);
  //   var url = webViewModel.url;
  //   if (url == null || url.toString().isEmpty) {
  //     return;
  //   }

  //   route = CustomPopupDialog.show(
  //     context: context,
  //     transitionDuration: customPopupDialogTransitionDuration,
  //     builder: (context) {
  //       return UrlInfoPopup(
  //         route: route!,
  //         transitionDuration: customPopupDialogTransitionDuration,
  //         onWebViewTabSettingsClicked: () {
  //           goToSettingsPage();
  //         },
  //       );
  //     },
  //   );
  // }

void invitePeople() async{
   if (_isSharing) return; // Ignore if already sharing
   setState(() {
     
   });
   _isSharing = true; // Set flag to block further clicks
  const String playStoreUrl = 'https://play.google.com/store/apps/details?id=io.beldex.beldex_browser&hl=en_IN&pli=1'; // Replace with your real Play Store URL
 final result = await SharePlus.instance.share(ShareParams(text:"Hey, I've been using Beldex browser to browse confidentially. Try it yourself! Download it at $playStoreUrl") ); //.share('Check out this app: $playStoreUrl');

   _isSharing = false; 

 if (result.status == ShareResultStatus.success) {
      print('Shared successfully');
    } else if (result.status == ShareResultStatus.dismissed) {
      print('Share dismissed');
    }

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

  void takeScreenshotAndShow(AppLocalizations loc) async {
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
                          child: TextWidget(text:loc.share,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                18.0), // Adjust the radius as needed
                          ),
                          onPressed: () async {
                            SharePlus.instance.share(ShareParams(files: [XFile(file.path)],text: 'image'));
                           // await ShareExtend.share(file.path, "image");
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
    }}





    }
















class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
      ),
      body: Container(),
    );
  }
}

class ChangeNodeScreen extends StatelessWidget {
  const ChangeNodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Node"),
      ),
      body: Container(),
    );
  }
}







