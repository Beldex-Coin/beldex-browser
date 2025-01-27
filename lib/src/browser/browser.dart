import 'dart:async';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:beldex_browser/src/browser/ai/chat_screen.dart';
import 'package:beldex_browser/src/browser/app_bar/browser_app_bar.dart';
import 'package:beldex_browser/src/browser/app_bar/sample_popup.dart';
import 'package:beldex_browser/src/browser/app_bar/search_screen.dart';
import 'package:beldex_browser/src/browser/app_bar/tab_viewer_app_bar.dart';
import 'package:beldex_browser/src/browser/app_bar/webview_tab_app_bar.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/tab_viewer.dart';
import 'package:beldex_browser/src/browser/util.dart';
import 'package:beldex_browser/src/browser/webview_tab.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:beldex_browser/src/widget/text_widget.dart';
import 'package:belnet_lib/belnet_lib.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:upgrader/upgrader.dart';
// import 'app_bar/sample_webview_tab_app_bar.dart';
import 'empty_tab.dart';
import 'models/browser_model.dart';

class Browser extends StatefulWidget {
  const Browser({Key? key}) : super(key: key);

  @override
  State<Browser> createState() => _BrowserState();
}

class _BrowserState extends State<Browser> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const platform =
      MethodChannel('com.beldex.beldex_browser.intent_data');

  var _isRestored = false;


  String? _sharedUrl;
  StreamSubscription? _intentDataStreamSubscription;
  final _sharedFiles = <SharedMediaFile>[];
  bool isExternalLink = false;
  int resetValue = 1;
  
  @override
  void initState() {
    super.initState();
    //getIntentData();
    

     WidgetsBinding.instance.addObserver(this);
   // final browserModel = Provider.of<BrowserModel>(context,listen: false);
    // Listen for incoming text or URL when the app is running or resumed
    _intentDataStreamSubscription =
        ReceiveSharingIntent.instance.getMediaStream().listen((value)async {
       String? url = await platform.invokeMethod("getIntentData");

  if(url!.contains('browser_fallback_url')){
    print('FALLBACK URL -----');
  }

      setState(() {
        _sharedFiles.clear();
        _sharedFiles.addAll(value);
           print('Sample External link ----${_sharedFiles.map((f) => f.toMap())} ------ $url');
        if (_sharedFiles.isNotEmpty) {
          _sharedUrl = _sharedFiles[0].path;
          print('IsExternal Link 1-------> $isExternalLink');
          //if(_sharedUrl!.startsWith('/redirect') && url != null){
           if(url != null){
            openLink(url,false);
           }
           // openLink(url,false);
         // }else{
          //  openLink(_sharedUrl,false);
          //}
          
        }else{
           print('IsExternal Link 2-------> $isExternalLink');
        }
        print('IsExternal Link 3-------> $isExternalLink');
      });
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.instance.getInitialMedia().then((value)async {
      String? url = await platform.invokeMethod("getIntentData");
      await Future.delayed(Duration(milliseconds: 300)); // Add delay
      setState(() {
        _sharedFiles.clear();
        print('Sample Shared File data ${_sharedFiles.length}');
        _sharedFiles.addAll(value);
     
       if(resetValue == 1){
        resetValue = 0;
        print('Reset Values From the variable ---------- $resetValue');
          print(
            'Sample External link1 ----${_sharedFiles.map((f) => f.toMap())}');
        if (_sharedFiles.isNotEmpty) {
          _sharedUrl = _sharedFiles[0].path;
           print('IsExternal Link 4-------> $_sharedUrl');
           // if(_sharedUrl!.startsWith('/redirect') && url != null){
              print('IsExternal Link inside thee condition');
              if( url != null){
                  openLink(url,true);
              }
            //openLink(url,true);
          // }else{
          // openLink(_sharedUrl,true);
          // }
        }else if(_sharedFiles.isEmpty){
          if (url != null) {
        if (mounted) {
          print('IsExternal Link 5-------> $_sharedUrl --$url');
          print('Sample external from the link $url');
          openLink(url,true);
        }
      }
           print('IsExternal Link 5-------> $isExternalLink');
        }
       } 
        
        // Tell the library that we are done processing the intent.
       // ReceiveSharingIntent.instance.reset();
      });
    },onError: (err){
       print("getIntentDataStream error: $err");
    }  
    );


  }


void openLink(String? _sharedUrl,isInitialLaunch)async {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();
    final vpnStatusProvider =
        Provider.of<VpnStatusProvider>(context, listen: false);
    var webViewModel = Provider.of<WebViewModel>(context, listen: false);
    var webViewController = webViewModel.webViewController;
    var url = WebUri(formatUrl(_sharedUrl!.trim()));
    url ??= WebUri(settings.searchEngine.url);
    print('THE WEB URL ADD NEW TANS--> $url ${ModalRoute.of(context)?.settings.name}');

  vpnStatusProvider.updateCanShowHomeScreen(false);
    
            //Navigator.pushNamedAndRemoveUntil(context, '/browser', (route) => false);
// setState(() {
//   isExternalLink = true;
//   print('IsExternal link from openLink $isExternalLink');
// });
   
   
  //  if(webViewController != null){
  //   vpnStatusProvider.updateCanShowHomeScreen(false);
  //   if(vpnStatusProvider.canShowHomeScreen == true){
  //    webViewController.loadUrl(urlRequest: URLRequest(url: url));
  //   }else if(settings.homePageEnabled && settings.customUrlHomePage.isNotEmpty){
  //     browserModel.closeAllTabs();
  //   }
  //  }
   if (webViewController != null) {
       await webViewController.evaluateJavascript(
          source: """
       if (document.fullscreenElement) {
        document.exitFullscreen(); 
        }"""
        );
      }
   if ((webViewController != null && vpnStatusProvider.canShowHomeScreen == true) //|| (webViewController != null && settings.homePageEnabled && settings.customUrlHomePage.isNotEmpty)
   ) {
      vpnStatusProvider.updateCanShowHomeScreen(false);
        webViewController.loadUrl(urlRequest: URLRequest(url: url));
        print('THE URL loading 2 --> ${webViewModel.url}');
    } 
    else {
      if(isInitialLaunch){
        print('ENTER INSIDE THE INITIAL LAUNCH  -- ${browserModel.webViewTabs.length}');
        //browserModel.webViewTabs.length;
         if( settings.homePageEnabled && settings.customUrlHomePage.isNotEmpty){
         // await Future.delayed(Duration(milliseconds: 300),(){
             browserModel.closeAllTabs();
         // }); // Add delay
       
      }
      }
     
      browserModel.addTab(WebViewTab(
        key: GlobalKey(),
        webViewModel: WebViewModel(url: url),
      ));
    }
    setState(() {
      resetValue = 0;
     // isInitialLaunch = false;
      //_sharedFiles.clear();
    });
    
  }


@override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    
    super.didChangeAppLifecycleState(state);
    if(state == AppLifecycleState.resumed){
      print('INSIDE THE APPLIFECYCLE SHARED ${_sharedFiles.map((f) => f.toMap())}');
      if(_sharedFiles.isNotEmpty){
        print('INSIDE THE RESUMED STATE  -----');
        
        Navigator.popUntil(context, (route) => route.isFirst);
        setState(() {
          _sharedFiles.clear();
        });
        closeTabListPage();
        // while (Navigator.canPop(context)) {
        //        Navigator.pop(context);
        //       }
       // Navigator.push(context, MaterialPageRoute(builder: (context)=> Browser()));
      }
    }
  }


void closeTabListPage(){
   var browserModel = Provider.of<BrowserModel>(context, listen: false);
   //if(
    browserModel.showTabScroller = false;
    browserModel.showTab(browserModel.getCurrentTabIndex());
}




  getIntentData() async {
    if (Util.isAndroid()) {
      String? url = await platform.invokeMethod("getIntentData");
      if (url != null) {
        if (mounted) {
          var browserModel = Provider.of<BrowserModel>(context, listen: false);
          browserModel.addTab(WebViewTab(
            key: GlobalKey(),
            webViewModel: WebViewModel(url: WebUri(url)),
          ));
        }
      }
    }
  }

  @override
  void dispose() {
    //closeAllTabs(context);
    //_connectivitySubscription.cancel();
    //_isConnectedEventSubscription!.cancel();
    _intentDataStreamSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void closeAllTabs(context) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);

    browserModel.showTabScroller = false;

    browserModel.closeAllTabs();
    clearCookie();
  }

  restore() async {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    browserModel.restore();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isRestored) {
      _isRestored = true;
      restore();
    }
    precacheImage(const AssetImage("assets/icon/icon.png"), context);
  }

  @override
  Widget build(BuildContext context) {
    return _buildBrowser(context);
  }

  Widget _buildBrowser(BuildContext cxt) {
    var currentWebViewModel = Provider.of<WebViewModel>(context, listen: true);
    var browserModel = Provider.of<BrowserModel>(context, listen: true);

    browserModel.addListener(() {
      browserModel.save();
    });
    currentWebViewModel.addListener(() {
      browserModel.save();
    });

    var canShowTabScroller =
        browserModel.showTabScroller && browserModel.webViewTabs.isNotEmpty;

    return IndexedStack(
      index: canShowTabScroller ? 1 : 0,
      children: [
        _buildWebViewTabs(),
        canShowTabScroller ? _buildWebViewTabsViewer() : Container()
      ],
    );
  }

  Widget _buildWebViewTabs() {
     final vpnStatusProvider = Provider.of<VpnStatusProvider>(context,listen: false);
          var browserModel = Provider.of<BrowserModel>(context, listen: false);
          var webViewModel = browserModel.getCurrentTab()?.webViewModel;
          var webViewController = webViewModel?.webViewController;
    return WillPopScope(
        onWillPop: () async {
     
             // vpnStatusProvider.updateCanShowHomeScreen(false);
      

     if(browserModel.showTabScroller == true){
         browserModel.showTabScroller = false;
         return false;
        }

      if(vpnStatusProvider.showFAB){
        vpnStatusProvider.updateFAB(false);
      }

if (vpnStatusProvider.canShowHomeScreen == true) {
            bool? result = await _showDownloadConfirmationDialog(context);
            if (result != null && result) {
              return true;
            } else {
              return false;
            }
          }

          if (webViewController != null) {
            if (await webViewController.canGoBack()) {
              webViewController.goBack();

              if (findOnPageController != null) {
                setState(() {
                  findOnPageController!.text = '';
                });
                await webViewModel?.findInteractionController!.clearMatches();
              }
              browserModel.updateFindOnPage(false);

              return false;
            }
          }

          if (browserModel.isFindingOnPage) {
            if (findOnPageController != null) {
              setState(() {
                findOnPageController!.text = '';
              });
              await webViewModel?.findInteractionController!.clearMatches();
            }
            browserModel.updateFindOnPage(false);

            return false;
          }
          if (webViewModel != null && webViewModel.tabIndex != null) {
            setState(() {
              browserModel.closeTab(webViewModel.tabIndex!);
             // vpnStatusProvider.updateCanShowHomeScreen(false);
              //clearCookie();
            });
            if (mounted) {
              FocusScope.of(context).unfocus();
            }
            //  if(browserModel.isNewTab){
            //   browserModel.updateIsNewTab(false);
            //  }

            return false;
          }

          if (browserModel.webViewTabs.isEmpty) {
            bool? result = await _showDownloadConfirmationDialog(context);
            if (result != null && result) {
              return true;
            } else {
              return false;
            }
          }

          return false;

          // return browserModel.webViewTabs.isEmpty == true ? await _showDownloadConfirmationDialog(context) ?? false : false;  //browserModel.webViewTabs.isEmpty;
        },
        child: UpgradeAlert(
          showIgnore: false,
        showLater: false,
          upgrader: Upgrader(
            debugLogging: true
          ),
          child: Scaffold(
            resizeToAvoidBottomInset: true,
              // backgroundColor: Color(0xff171720),
              appBar: const BrowserAppBar(),
              body: _buildWebViewTabsContent(),
              floatingActionButton: vpnStatusProvider.showFAB && browserModel.webViewTabs.isNotEmpty  ? FloatingActionButton(
                onPressed: ()async{
                   if(await webViewController?.getSelectedText() != null){
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
                   showModalBottomSheet(
      context: context,
      isScrollControlled: true,
     builder: (context){
          return SummariseUrlResult();
     });
              
              vpnStatusProvider.updateFAB(false);
              
              },
              backgroundColor: Colors.transparent,
              child: ClipOval(
                child: Image.asset('assets/images/ai-icons/Ai-Button.png'),
              )
              // Container(
              //   height: 50,
              //   width: 50,
              //   decoration: BoxDecoration(
              //     color: Colors.green,
              //     shape: BoxShape.circle
              //   ),
              // )

              ): Container(),
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              ),
        ));
  }

  Future<bool?> _showDownloadConfirmationDialog(BuildContext context) {
    final themeProvider =
        Provider.of<DarkThemeProvider>(context, listen: false);
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
                return Dialog(
          backgroundColor:
              themeProvider.darkTheme ? Color(0xff282836) : Color(0xffFFFFFF),
          insetPadding:const EdgeInsets.all(20),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 170,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: themeProvider.darkTheme
                    ? const Color(0xff282836)
                    :const Color(0xffFFFFFF),
                borderRadius: BorderRadius.circular(15)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextWidget(
                    text:'Quit Browser',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                TextWidget(
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
                              ? const Color(0xff39394B)
                              :const Color(0xffF3F3F3), // Color(0xff00B134),
                          disabledColor: Color(0xff2C2C3B),
                          minWidth: double.maxFinite,
                          height: 50,
                          child: TextWidget( text:'Quit',
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
                                (() => Navigator.of(context).pop(true)));
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

  Widget _buildWebViewTabsContent() {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
    if (browserModel.webViewTabs.isEmpty //|| browserModel.isNewTab
        ) {
      return const EmptyTab();
    }

    for (final webViewTab in browserModel.webViewTabs) {
      var isCurrentTab =
          webViewTab.webViewModel.tabIndex == browserModel.getCurrentTabIndex();

      if (isCurrentTab) {
        Future.delayed(const Duration(milliseconds: 100), () {
          webViewTabStateKey.currentState?.onShowTab();
        });
      } else {
        webViewTabStateKey.currentState?.onHideTab();
      }
    }

    var stackChildren = <Widget>[
      browserModel.getCurrentTab() ?? Container(),
      vpnStatusProvider.canShowHomeScreen == false ? _createProgressIndicator() : Container()
    ];

    return Stack(
      children: stackChildren,
    );
  }

  Widget _createProgressIndicator() {
    return Selector<WebViewModel, double>(
        selector: (context, webViewModel) => webViewModel.progress,
        builder: (context, progress, child) {
          if (progress >= 1.0) {
            return Container();
          }
          return PreferredSize(
              preferredSize: const Size(double.infinity, 4.0),
              child: SizedBox(
                  height: 3.0,
                  child: LinearProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(const Color(0xff00B134)),
                    value: progress,
                  )));
        });
  }

  Widget _buildWebViewTabsViewer() {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    var themeProvider = Provider.of<DarkThemeProvider>(context);
    final selectedItemsProvider = Provider.of<SelectedItemsProvider>(context);
    return WillPopScope(
        onWillPop: () async {
          browserModel.showTabScroller = false;
          return false;
        },
        child: Scaffold(
            //backgroundColor: Color(0xff171720),
            appBar: const TabViewerAppBar(),
            body: TabViewer(
              currentIndex: browserModel.getCurrentTabIndex(),
              children: browserModel.webViewTabs.map((webViewTab) {
                webViewTabStateKey.currentState?.pause();
                var screenshotData = webViewTab.webViewModel.screenshot;
                Widget screenshotImage = Container(
                  decoration: BoxDecoration(
                      color:const Color(0xff171720),
                      borderRadius: BorderRadius.circular(10)),
                  width: double.infinity,
                  child: screenshotData != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child:
                              Image.memory(screenshotData, fit: BoxFit.cover))
                      : null,
                );
                webViewTab.webViewModel.settings?.minimumFontSize = selectedItemsProvider.fontSize.toInt();
                var url = webViewTab.webViewModel.url;
                final faviconUrl = webViewTab.webViewModel.favicon != null
                    ? webViewTab.webViewModel.favicon!.url
                    : (url != null && ["http", "https"].contains(url.scheme)
                        ? Uri.parse("${url.origin}/favicon.ico")
                        : null);

                var isCurrentTab = browserModel.getCurrentTabIndex() ==
                    webViewTab.webViewModel.tabIndex;
                
                return Container(
                  height: 100,
                  padding:const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                  //margin: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                      color: themeProvider.darkTheme
                          ?const Color(0xff282836)
                          :const Color(0xffF3F3F3),
                      border: Border.all(
                          color: isCurrentTab
                              ? Color(0xff00B134)
                              : Colors.transparent),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      Container(
                        // color: Colors.yellow,
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 25,
                              child: IconButton(
                                icon:const Icon(
                                  Icons.close,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (webViewTab.webViewModel.tabIndex !=
                                        null) {
                                         // clearCookie();
                                      browserModel.closeTab(
                                          webViewTab.webViewModel.tabIndex!);
                                      if (browserModel.webViewTabs.isEmpty) {
                                        browserModel.showTabScroller = false;
                                      }
                                    }
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                          child: Container(
                        margin:const EdgeInsets.only(top: 5),
                        decoration: BoxDecoration(
                            //color: Color(0xff171720),
                            borderRadius: BorderRadius.circular(10)),
                        child: screenshotImage,
                      )),
                    ],
                  ),
                );
              }).toList(),
              onTap: (index) async {
                browserModel.showTabScroller = false;
                browserModel.showTab(index);
              },
            )));
  }
}
