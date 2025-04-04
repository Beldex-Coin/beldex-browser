import 'dart:convert';
import 'dart:io';

import 'package:beldex_browser/ad_blocker_filter.dart';
import 'package:beldex_browser/main.dart';
import 'package:beldex_browser/src/browser/empty_tab.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/util.dart';
import 'package:beldex_browser/src/node_dropdown_list_page.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/utils/screen_secure_provider.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:beldex_browser/src/widget/downloads/download_prov.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'javascript_console_result.dart';
import 'long_press_alert_dialog.dart';
import 'models/browser_model.dart';

final webViewTabStateKey = GlobalKey<_WebViewTabState>();

class WebViewTab extends StatefulWidget {
  const WebViewTab({Key? key, required this.webViewModel}) : super(key: key);

  final WebViewModel webViewModel;

  @override
  State<WebViewTab> createState() => _WebViewTabState();
}

class _WebViewTabState extends State<WebViewTab> with WidgetsBindingObserver {
  InAppWebViewController? _webViewController;
  PullToRefreshController? _pullToRefreshController;
  FindInteractionController? _findInteractionController;
  bool _isWindowClosed = false;

  final TextEditingController _httpAuthUsernameController =
      TextEditingController();
  final TextEditingController _httpAuthPasswordController =
      TextEditingController();
  bool checkUrl = false;

  List<ContentBlocker>? contentBlockers = []; // Domain filter variable for ad blocks

setAdBlocker() async {
    for (final adUrlFilter in AdBlockerFilter.adUrlFilters) {
      contentBlockers?.add(ContentBlocker(
          trigger: ContentBlockerTrigger(
            urlFilter: adUrlFilter,
          ),
          action: ContentBlockerAction(
            type: ContentBlockerActionType.BLOCK,
          )));
    }
    // Apply the "display: none" style to some HTML elements
    contentBlockers?.add(ContentBlocker(
        trigger: ContentBlockerTrigger(
          urlFilter: ".*",
        ),
        action: ContentBlockerAction(
            type: ContentBlockerActionType.CSS_DISPLAY_NONE,
            selector: ".banner, .banners, .ads, .ad, .advert, .ad-container, .advertisement, .sponsored, .promo, .overlay-ad"
    )));
   
  }


  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    setAdBlocker();
    _pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(color: Colors.green),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                _webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                _webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await _webViewController?.getUrl()));
              }
            },
          );

    _findInteractionController = FindInteractionController();
  }

  @override
  void dispose() {
    _webViewController = null;
    widget.webViewModel.webViewController = null;
    widget.webViewModel.pullToRefreshController = null;
    widget.webViewModel.findInteractionController = null;

    _httpAuthUsernameController.dispose();
    _httpAuthPasswordController.dispose();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_webViewController != null && Util.isAndroid()) {
      if (state == AppLifecycleState.paused) {
        pauseAll();
      } else {
        resumeAll();
      }
    }
  }

  void pauseAll() {
    if (Util.isAndroid()) {
      _webViewController?.pause();
    }
    pauseTimers();
  }

  void resumeAll() {
    if (Util.isAndroid()) {
      _webViewController?.resume();
    }
    resumeTimers();
  }

  void pause() {
    if (Util.isAndroid()) {
      _webViewController?.pause();
    }
  }

  void resume() {
    if (Util.isAndroid()) {
      _webViewController?.resume();
    }
  }

  void pauseTimers() {
    _webViewController?.pauseTimers();
  }

  void resumeTimers() {
    _webViewController?.resumeTimers();
  }

  @override
  Widget build(BuildContext context) {
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          _buildWebView(context),
          vpnStatusProvider.canShowHomeScreen ? EmptyTab() : Container()
        ],
      )
    );
  }

Future<String> getConnectedExitnode()async{
  final prefs = await SharedPreferences.getInstance();
  final node = prefs.getString('selectedExitNode') ?? '';
  if(node.length == 56){
    String firstPart = node.substring(0, 4);
      String lastPart = node.substring(node.length - 4);
     return '$firstPart...$lastPart';
  }
  return node;
}

String getBackgroundColor(DarkThemeProvider themeProvider){
  return themeProvider.darkTheme ? '#282836'  : '#F3F3F3';
}

String getTextColor(DarkThemeProvider themeProvider){
  return themeProvider.darkTheme ? '#EBEBEB' : '#222222';
}



bool _isValidUrl(String url) {
    if(url.startsWith('http:')){
      print('ERROR FROM THE HTTP  ');
      return true;
    }else if(url.startsWith('https:')){
      print('ERROR FROM THE HTTPS  ');
      return true;
    }else 
    if(url == 'about:blank'){
      print('ERROR FROM THE ABOUT:BLANk');
      return true;
    }else
    return false; //url.startsWith('http:') || url.startsWith('https') || url == 'about:blank';
  }

  InAppWebView _buildWebView(BuildContext conxt) {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    var settings = browserModel.getSettings();
    var currentWebViewModel = Provider.of<WebViewModel>(context, listen: true);
     final themeProvider = Provider.of<DarkThemeProvider>(context);
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
        final urlSummaryProvider = Provider.of<UrlSummaryProvider>(context);
        final basicProvider = Provider.of<BasicProvider>(context);
    //final DownloadController _downloadCon = Get.put(DownloadController());
    final downloadProvider =
        Provider.of<DownloadProvider>(context, listen: false);
    if (Util.isAndroid()) {
      InAppWebViewController.setWebContentsDebuggingEnabled(
          settings.debuggingEnabled);
    }

    var initialSettings = widget.webViewModel.settings!;
    initialSettings.isInspectable = settings.debuggingEnabled;
    initialSettings.useOnDownloadStart = true;
    initialSettings.useOnLoadResource = true;
    initialSettings.useShouldOverrideUrlLoading = true;
    initialSettings.javaScriptCanOpenWindowsAutomatically = true;
    initialSettings.userAgent =
        "Mozilla/5.0 (Linux; Android 10; Pixel Build/QP1A.190711.019; wv) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Mobile Safari/537.36";
    //"Mozilla/5.0 (Linux; Android 9; LG-H870 Build/PKQ1.190522.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36";
    initialSettings.transparentBackground = true;
    initialSettings.contentBlockers = basicProvider.adblock ? contentBlockers : []; // for adblocker
    initialSettings.safeBrowsingEnabled = true;
    initialSettings.disableDefaultErrorPage = true;
    initialSettings.supportMultipleWindows = true;
    // initialSettings.verticalScrollbarThumbColor = themeProvider.darkTheme ?Color(0xff4D4D64) : Color(0xffC7C7C7);
    //    // const Color.fromRGBO(0, 0, 0, 0.5);
    // initialSettings.horizontalScrollbarThumbColor =themeProvider.darkTheme ?Color(0xff4D4D64) : Color(0xffC7C7C7);
    // const Color.fromRGBO(0, 0, 0, 0.5);
    initialSettings.allowsLinkPreview = false;
    initialSettings.isFraudulentWebsiteWarningEnabled = true;
    initialSettings.disableLongPressContextMenuOnLinks = true;
    initialSettings.allowingReadAccessTo = WebUri('file://$WEB_ARCHIVE_DIR/');
    //print('selected text is ---> ${_webViewController?.getSelectedText().toString()}');
    return InAppWebView(
      // keepAlive: widget.webViewModel.keepAlive,
      initialUrlRequest: URLRequest(url: widget.webViewModel.url),
      initialSettings: initialSettings,
      windowId: widget.webViewModel.windowId,
      pullToRefreshController: _pullToRefreshController,
      findInteractionController: _findInteractionController,

      onWebViewCreated: (controller) async {
        initialSettings.transparentBackground = false;
        await controller.setSettings(settings: initialSettings);

        _webViewController = controller;
        widget.webViewModel.webViewController = controller;
        widget.webViewModel.pullToRefreshController = _pullToRefreshController;
        widget.webViewModel.findInteractionController =
            _findInteractionController;

        if (Util.isAndroid()) {
          controller.startSafeBrowsing();
        }

        widget.webViewModel.settings = await controller.getSettings();

        if (isCurrentTab(currentWebViewModel)) {
          currentWebViewModel.updateWithValue(widget.webViewModel);
        }

      _webViewController!.addJavaScriptHandler(
              handlerName: 'changeNode',
              callback: (args) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NodeDropdownListPage(exitData: [], canChangeNode: true,webViewController: _webViewController,)),
                );
              });

      },
     
      onLoadStart: (controller, url) async {
        widget.webViewModel.isSecure = Util.urlIsSecure(url!);
        widget.webViewModel.url = url;
        widget.webViewModel.loaded = false;
        widget.webViewModel.setLoadedResources([]);
        widget.webViewModel.setJavaScriptConsoleResults([]);
        vpnStatusProvider.setErrorPage(false);
        if (isCurrentTab(currentWebViewModel)) {
          currentWebViewModel.updateWithValue(widget.webViewModel);
        } else if (widget.webViewModel.needsToCompleteInitialLoad) {
          controller.stopLoading();
        }
      },
      onLoadStop: (controller, url) async {
        try{
           _pullToRefreshController?.endRefreshing();
            urlSummaryProvider.updateUrl(url.toString()); // for summarise with floating button
           _checkIsUrlSearchResult(url.toString(),vpnStatusProvider); // for showing floating button
        if (widget.webViewModel.isDesktopMode) {
          String js =
              "document.querySelector('meta[name=\"viewport\"]').setAttribute('content', 'width=1024px, initial-scale=' + (document.documentElement.clientWidth / 1024));";
          controller.evaluateJavascript(source: js);
          controller.zoomOut();
        }
         
        widget.webViewModel.url = url;
        widget.webViewModel.favicon = null;
        widget.webViewModel.loaded = true;
       
        var sslCertificateFuture = _webViewController?.getCertificate();
        var titleFuture = _webViewController?.getTitle();
        var faviconsFuture = _webViewController?.getFavicons();

        var sslCertificate = await sslCertificateFuture;
        if (sslCertificate == null && !Util.isLocalizedContent(url!)) {
         // widget.webViewModel.isSecure = false;
        }

        widget.webViewModel.title = await titleFuture;

        List<Favicon>? favicons = await faviconsFuture;
        if (favicons != null && favicons.isNotEmpty) {
          for (var fav in favicons) {
            if (widget.webViewModel.favicon == null) {
              widget.webViewModel.favicon = fav;
            } else {
              if ((widget.webViewModel.favicon!.width == null &&
                      !widget.webViewModel.favicon!.url
                          .toString()
                          .endsWith("favicon.ico")) ||
                  (fav.width != null &&
                      widget.webViewModel.favicon!.width != null &&
                      fav.width! > widget.webViewModel.favicon!.width!)) {
                widget.webViewModel.favicon = fav;
              }
            }
          }
        }
        
        if (isCurrentTab(currentWebViewModel)) {
          widget.webViewModel.needsToCompleteInitialLoad = false;
          currentWebViewModel.updateWithValue(widget.webViewModel);

          var screenshotData = _webViewController
              ?.takeScreenshot(
                  screenshotConfiguration: ScreenshotConfiguration(
                      compressFormat: CompressFormat.JPEG, quality: 20))
              .timeout(
                const Duration(milliseconds: 1500),
                onTimeout: () => null,
              );
          widget.webViewModel.screenshot = await screenshotData;
        }
        }catch(e){
          print(e);
        }


if(basicProvider.adblock){
await _webViewController!.evaluateJavascript(source: """
      function removeAdsAndFallbacks() {
        try {
          console.log('Running ad and fallback removal');

          let adSelectors = [
            /*'[id*="ad-"], [id*="ads-"], [id*="advert-"]',
            '[class*="ad-"], [class*="ads-"], [class*="advert-"]',
            'iframe[src*="ads"], iframe[src*="ad-"], iframe[src*="doubleclick"]',
            '[aria-label="Advertisement"], [aria-label="Sponsored"]',
            '.banner-ad, .ad-container, .advertisement, .sponsored, .promo' */
            '.banner, .banners, .ads, .ad, .advert, .ad-container, .advertisement, .sponsored, .promo, .overlay-ad, iframe[src*="doubleclick"] ,.doubleclick'
          ];

          let fallbackSelectors = [
            'div:contains("webpage not available")',
            'div:contains("Webpage not available")',
            'div:contains("ad blocker")',
            'div:contains("advertisement not loaded")',
            'div:contains("please disable ad blocker")',
            '[class*="ad-fallback"], [id*="ad-fallback"]',
            '.ad-error, .ad-blocked-message'
          ];

          let allSelectors = adSelectors.concat(fallbackSelectors);

          allSelectors.forEach(selector => {
            document.querySelectorAll(selector).forEach(el => {
              if (!el.closest('header') && !el.closest('nav') && !el.closest('main') && !el.closest('footer')) {
                let text = el.textContent.toLowerCase();
                if (text.includes('webpage not available') || text.includes('Webpage not available') ||
                    text.includes('ad blocker') || 
                    text.includes('advertisement') || 
                    text.includes('sponsored')) {
                  console.log('Hiding fallback: ' + el.outerHTML.substring(0, 50));
                  el.style.display = 'none';
                } else if (el.matches(adSelectors.join(','))) {
                  console.log('Hiding ad: ' + el.outerHTML.substring(0, 50));
                  el.style.display = 'none';
                }
              }
            });
          });

          document.querySelectorAll('div, section').forEach(el => {
            if (!el.innerHTML.trim() && 
                (el.className.includes('ad') || el.id.includes('ad') || el.className.includes('fallback'))) {
              el.style.display = 'none';
            }
          });

        } catch (e) {
          console.log('Error in removal script: ' + e.toString());
        }
      }

      removeAdsAndFallbacks();
      setInterval(removeAdsAndFallbacks, 2000);
    """);
}
      },
      onProgressChanged: (controller, progress) {
        if (progress == 100) {
          _pullToRefreshController?.endRefreshing();
        }

        widget.webViewModel.progress = progress / 100;

        if (isCurrentTab(currentWebViewModel)) {
          currentWebViewModel.updateWithValue(widget.webViewModel);
          print('coming ttooo');
          setState(() {
            checkUrl = _isValidUrl(widget.webViewModel.url.toString());
          });
        }
      },
      onUpdateVisitedHistory: (controller, url, androidIsReload) async {
        // widget.webViewModel.url = url;
        // widget.webViewModel.title = await _webViewController?.getTitle();
        setState(() {
            vpnStatusProvider.updateIsUrlValid(_isValidUrl(widget.webViewModel.url.toString()));
        });
        // if (isCurrentTab(currentWebViewModel)) {
        //   currentWebViewModel.updateWithValue(widget.webViewModel);
        // }
      },
      onLongPressHitTestResult: (controller, hitTestResult) async {
        print('Long press value ${hitTestResult.type}');

        if (LongPressAlertDialog.hitTestResultSupported
            .contains(hitTestResult.type)) {
          var requestFocusNodeHrefResult =
              await _webViewController?.requestFocusNodeHref();

          print("requestFocusNodeHref ${requestFocusNodeHrefResult!.src}");

          if (requestFocusNodeHrefResult != null) {
            showDialog(
              context: context,
              builder: (context) {
                return LongPressAlertDialog(
                  webViewModel: widget.webViewModel,
                  hitTestResult: hitTestResult,
                  requestFocusNodeHrefResult: requestFocusNodeHrefResult,
                );
              },
            );
          }
        }

        if (hitTestResult.type ==
            InAppWebViewHitTestResultType.EDIT_TEXT_TYPE) {}
      },
      onConsoleMessage: (controller, consoleMessage) {
        try {
          Color consoleTextColor = Colors.black;
          Color consoleBackgroundColor = Colors.transparent;
          IconData? consoleIconData;
          Color? consoleIconColor;
          if (consoleMessage.message.isNotEmpty) {
            if (consoleMessage.messageLevel == ConsoleMessageLevel.ERROR) {
              consoleTextColor = Colors.red;
              consoleIconData = Icons.report_problem;
              consoleIconColor = Colors.red;
            } else if (consoleMessage.messageLevel == ConsoleMessageLevel.TIP) {
              consoleTextColor = Colors.blue;
              consoleIconData = Icons.info;
              consoleIconColor = Colors.blueAccent;
            } else if (consoleMessage.messageLevel ==
                ConsoleMessageLevel.WARNING) {
              consoleBackgroundColor = const Color.fromRGBO(255, 251, 227, 1);
              consoleIconData = Icons.report_problem;
              consoleIconColor = Colors.orangeAccent;
            }

            widget.webViewModel
                .addJavaScriptConsoleResults(JavaScriptConsoleResult(
              data: consoleMessage.message,
              textColor: consoleTextColor,
              backgroundColor: consoleBackgroundColor,
              iconData: consoleIconData,
              iconColor: consoleIconColor,
            ));
          }
          if (isCurrentTab(currentWebViewModel)) {
            currentWebViewModel.updateWithValue(widget.webViewModel);
          }
        } catch (e) {
          print(e.toString());
        }
      },
      onLoadResource: (controller, resource) {
        widget.webViewModel.addLoadedResources(resource);

        if (isCurrentTab(currentWebViewModel)) {
          currentWebViewModel.updateWithValue(widget.webViewModel);
        }
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        vpnStatusProvider.setErrorPage(false);
        if (navigationAction.isForMainFrame) {
          print('navigation innnn----->');
          if (browserModel.isFindingOnPage) {
            browserModel.updateFindOnPage(false);
          }
        }

        var url = navigationAction.request.url;
        print('coming ----->');
        if (url != null &&
            !["http", "https", "file", "chrome", "data", "javascript", "about"]
                .contains(url.scheme)) {
          if (url.scheme == "intent") {
             try{
               
                  await _webViewController!.evaluateJavascript(
          source: "if (document.fullscreenElement) { document.exitFullscreen(); }"
        ); 

            var replacedUrl =
                 url.toString().replaceFirst("intent://", "https://");

              String? package =  extractPackageIdFromUrl(url.toString());
              print('IS PACKAGE ID AVAILABLE --- $package');
              bool? installed = await isAppInstalled(package!);
              print('IS PACKAGE ID AVAILABLE --- $package -- is Installed -- $installed');
              
              if(installed!){
                //  await launchUrl(Uri.parse(replacedUrl),
                //  mode: LaunchMode.externalApplication);
                await InstalledApps.startApp(package);
               // return NavigationActionPolicy.CANCEL;
              }else if(installed == false && package != null){
                // if(package == null){
                //   await launchUrl(Uri.parse("https://play.google.com/store"),
                //  mode: LaunchMode.externalApplication
                //  );
                // }else{
                   await launchUrl(Uri.parse("https://play.google.com/store/apps/details?id=$package"),
                 mode: LaunchMode.externalApplication
                 );
               // }
                
              }
              await controller.goBack();
             await controller.clearHistory();



             } on PlatformException catch(e){
                print('Failed to handle intent: $e');
             }



            // var replacedUrl =
            //     url.toString().replaceFirst("intent://", "https://");
            // await launchUrl(Uri.parse(replacedUrl),
            //     mode: LaunchMode.externalApplication);
            return NavigationActionPolicy.CANCEL;
          }
          try {
            if (kDebugMode) {
              print("## launching ... ${url.scheme}");
            }
            await launchUrl(url);
          } catch (e) {
            if (kDebugMode) {
              print("@@@@@@@@@@ I GOT url @@@@@@@@@$url$e");
            }
          }
          return NavigationActionPolicy.CANCEL;
          // if (await canLaunchUrl(url)) {
          //   // Launch the App
          //   await launchUrl(
          //     url,
          //   );
          //   // and cancel the request
          //   return NavigationActionPolicy.CANCEL;
          // }
        }

        return NavigationActionPolicy.ALLOW;
      },
      onDownloadStartRequest: (controllers, url) async {
        int itemCount = 0;
        String path = url.url.path;
        String fileName = path.substring(path.lastIndexOf('/') + 1);

        Directory? directory = await getExternalStorageDirectory();
        String _dir = "";
        if (directory!.path.contains("/storage/emulated/0/") &&
            Util.isAndroid()) {
          _dir = '/storage/emulated/0/Download';
        } else {
          _dir = directory.path;
        }

        if (kDebugMode) {
          // ignore: prefer_interpolation_to_compose_strings
          print("***** URL: " + url.url.toString());
          print("******* Path: ${directory.path}  and _dir: ${_dir}");
        }
        try {
          //  showDialog(
          //   context: conxt,
          //   builder: (BuildContext context) {
          //     return AlertDialog(
          //       title: Text("Download Started"),
          //       content: Text("File is downloading from $url"),
          //       actions: <Widget>[
          //         TextButton(
          //           child: Text("OK"),
          //           onPressed: () {
          //             Navigator.of(context).pop();
          //           },
          //         ),
          //       ],
          //     );
          //   },
          // );

          bool? downloadConfirmed =
              await _showDownloadConfirmationDialog(context, url);
          if (downloadConfirmed == true) {
            downloadProvider.addTask(
                url.url.toString(), _dir, url.suggestedFilename);
          }
          //

          //await _downloadController.fileDownloadPermission(url, _dir);

          //await _downloadCon.fileDownloadPermission(url,_dir);

          //  await _downloadCon.createDownloadLog(url);

          // await FlutterDownloader.enqueue(
          //   url: url.url.toString(),
          //   fileName:itemCount == 0 ? '${url.suggestedFilename}' : '${url.suggestedFilename}_$itemCount}', //fileName,
          //   savedDir: _dir,
          //   showNotification: true,
          //   openFileFromNotification: true,

          // ).whenComplete((){
          //   _downloadCon.downloadCompleteShow(url);
          //   itemCount++;
          // });
        } catch (error) {
          // _downloadCon.downloadError(error, url);
        }

        // String path = url.url.path;
        // String fileName = path.substring(path.lastIndexOf('/') + 1);

        // await FlutterDownloader.enqueue(
        //   url: url.toString(),
        //   fileName: fileName,
        //   savedDir: (await getTemporaryDirectory()).path,
        //   showNotification: true,
        //   openFileFromNotification: true,
        // );
      },

      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        var sslError = challenge.protectionSpace.sslError;
        if (sslError != null && (sslError.code != null)) {
          if (Util.isIOS() && sslError.code == SslErrorType.UNSPECIFIED) {
            return ServerTrustAuthResponse(
                action: ServerTrustAuthResponseAction.PROCEED);
          }
          widget.webViewModel.isSecure = false;
          if (isCurrentTab(currentWebViewModel)) {
            currentWebViewModel.updateWithValue(widget.webViewModel);
          }
          return ServerTrustAuthResponse(
              action: ServerTrustAuthResponseAction.CANCEL);
        }
        return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED);
      },
      onReceivedError: (controller, request, error) async {
        var isForMainFrame = request.isForMainFrame ?? false;
        if (!isForMainFrame) return;

          getConnectedExitnode();
          _pullToRefreshController?.setEnabled(true);
        _pullToRefreshController?.endRefreshing();
        await controller.stopLoading();
        if (Util.isIOS() && error.type == WebResourceErrorType.CANCELLED) {
          // NSURLErrorDomain
          return;
        }
        var errorUrl = request.url;
        _webViewController?.loadData(data: """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <style>
    ${await InAppWebViewController.tRexRunnerCss}
    </style>
    <style>
    body {
    margin: 0;
    font-family: Arial, sans-serif;
    background-color: #fff;
}
    .interstitial-wrapper {
        box-sizing: border-box;
        font-size: 1em;
        line-height: 1.6em;
        margin: 0 auto 0;
        max-width: 600px;
        width: 100%;
    }

.container {
    display: flex;
    flex-direction: column;
    height: 100vh;
    justify-content: space-between;
    text-align: start;
}

.header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0 10px;
    background-color: #f1f1f1;
}

.time {font-size: 16px;}

.icons {display: flex;}

.icon {margin-left: 10px;}

.content {
    flex-grow: 1;
    display: flex;
    flex-direction: column;
   /* justify-content: center;
    align-items: center; */
    padding: 20px;
}

.dino-icon {
    width: 50px;
    height: 50px;
    margin-bottom: 20px;
}

h1 {
    font-size: 24px;
    margin-bottom: 10px;
}

p {
    margin: 5px 0;
}

.error {
    color: red;
}

.footer {
    background-color: ${getBackgroundColor(themeProvider)} ; /* #282836 : #F3F3F3; */
    padding: 20px;
    /*height:31vh; */
    border-top-right-radius: 10px;
    border-top-left-radius: 10px;
    color: ${getTextColor(themeProvider)};
    text-align: center;
}

.change-button {
    background-color: #00BD40;
    color: white;
    padding: 15px 20px;
    border: none;
    border-radius: 10px;
    cursor: pointer;
    font-size: 16px;
    font-weight: 600;
   /* line-height:24px;*/
    width:156px;
    height:49px;
}

.change-button:hover {
    background-color: #45a049;
}

.title-text{
 font-size: 18px;
 font-weight:700;
line-height:27px;
}
.content-text{
 color: #00BD40;
}

.content-style{
 font-size:14px;
 text-align:center;
 font-weight:400;
 line-height:19.07px;
 font-family:sans-serif;
 padding:10px;
}




    </style>
</head>
<body>
 <div class="container" onclick="hideFooter()">
<div class="interstitial-wrapper">
        <div class="content">
           ${await InAppWebViewController.tRexRunnerHtml}
           <h1>Website not available</h1>
      <p>Could not load web pages at <strong>$errorUrl</strong> because:</p>
      <p>${error.description}</p>
        </div></div>
        <div class="footer" id="footer">
            <p class="title-text">Change Node</p>
            <p class="content-style">Exit node <span class="content-text">${await getConnectedExitnode()}</span> has experienced unprecedented traffic. Please click on <span class="content-text">Change Node</span> to switch exit node.</p>
            <button class="change-button" id="changeNodeButton">Change node</button>
        </div>
    </div>



<script type="text/javascript">
document.getElementById("footer").style.display = "none";
   document.getElementById("changeNodeButton").onclick = function() {
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('changeNode');
            }
        }
        function hideFooter() {
        document.getElementById("footer").style.display = "none";
    }
    function showFooter() {
        document.getElementById("footer").style.display = "block";
    }
    function setError(error) {
        if (error === "net::ERR_NAME_NOT_RESOLVED" || error === "net::ERR_CONNECTION_TIMED_OUT") {
            document.getElementById("footer").style.display = "block";
        } else {
            document.getElementById("footer").style.display = "none";
        }
    }
    </script>

</body>
</html>
    """, 
    baseUrl: errorUrl, 
    historyUrl: errorUrl,
    );



  vpnStatusProvider.updateFAB(false);
 vpnStatusProvider.setErrorPage(true);
        widget.webViewModel.url = errorUrl;
       // widget.webViewModel.isSecure = false;
       // await _webViewController?.stopLoading();
        if (isCurrentTab(currentWebViewModel)) {
           //await controller.stopLoading();
          currentWebViewModel.updateWithValue(widget.webViewModel);
        }


Future.delayed(const Duration(seconds: 3),(){
       if(error.description == "net::ERR_CONNECTION_TIMED_OUT"){
      print('ERROR TYPE HERE 11---- $checkUrl');
        _webViewController?.evaluateJavascript(source: "showFooter();");
    
     }else if(error.description == "net::ERR_NAME_NOT_RESOLVED"){
        if(vpnStatusProvider.isUrlValid == false){
         _webViewController?.evaluateJavascript(source: "showFooter();");
        }
     }else{
      print('ERROR TYPE HERE 222---- $checkUrl');
       _webViewController?.evaluateJavascript(source: "hideFooter();");
     }
     vpnStatusProvider.updateFAB(false);
     vpnStatusProvider.setErrorPage(true);
    });  



      },
      onTitleChanged: (controller, title) async {
        widget.webViewModel.title = title;

        if (isCurrentTab(currentWebViewModel)) {
          currentWebViewModel.updateWithValue(widget.webViewModel);
        }
      },
      onCreateWindow: (controller, createWindowRequest) async {
        print('coming 2');
        var webViewTab = WebViewTab(
          key: GlobalKey(),
          webViewModel: WebViewModel(
              url: WebUri("about:blank"),
              windowId: createWindowRequest.windowId),
        );

        browserModel.addTab(webViewTab);
        print('coming 3');
        return true;
      },
      onCloseWindow: (controller) {
        if (_isWindowClosed) {
          return;
        }
        _isWindowClosed = true;
        if (widget.webViewModel.tabIndex != null) {
          browserModel.closeTab(widget.webViewModel.tabIndex!);
        }
      },
      onPermissionRequest: (controller, permissionRequest) async {
        return PermissionResponse(
            resources: permissionRequest.resources,
            action: PermissionResponseAction.GRANT);
      },
      onReceivedHttpAuthRequest: (controller, challenge) async {
        var action = await createHttpAuthDialog(challenge);
        return HttpAuthResponse(
            username: _httpAuthUsernameController.text.trim(),
            password: _httpAuthPasswordController.text,
            action: action,
            permanentPersistence: true);
      },
    );
  }






// Show FAB when individual sites open
void _checkIsUrlSearchResult(String url,VpnStatusProvider vpnStatusProvider) {
  if(vpnStatusProvider.canShowHomeScreen){
    vpnStatusProvider.updateFAB(false);
    print('The URL is -----> $url and it is able to see FAB ${vpnStatusProvider.showFAB} inside showHome');
    return;
  }

  if(url.isEmpty || url == "about:blank" || url.startsWith("chrome-error") || url.startsWith("edge-error") || url.startsWith("file:")){
    vpnStatusProvider.updateFAB(false);
    return;
  }
 


vpnStatusProvider.updateFAB(shouldShowFAB(url));
    print('The URL is -----> $url and it is able to see FAB ${vpnStatusProvider.showFAB}');
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

// bool shouldShowFAB(String url) {
//   Uri uri = Uri.parse(url);
//   String host = uri.host.toLowerCase();
//   String path = uri.path;

//   // List of search engines and social media platforms to exclude
//   Map<String, List<String>> blockedSites = {
//     'google': ['google.'], // Matches all Google domains (google.com, google.co.in, etc.)
//     'bing': ['bing.com'],
//     'yahoo': ['yahoo.'],
//     'duckduckgo': ['duckduckgo.com'],
//     'baidu': ['baidu.com'],
//     'yandex': ['yandex.'],
//     'ask': ['ask.com'],
//     'youtube': ['youtube.com'],
//     'wikipedia':['wikipedia.org'],
//     'twitter': ['twitter.com', 'x.com'],
//   };

//   // Check if the host matches any blocked site homepage
//   bool isBlockedHomepage = blockedSites.entries.any((entry) =>
//       entry.value.any((domain) => host.contains(domain)) &&
//       (path == "/" || path.isEmpty));

//   // Check for search, video, or feed pages in search engines and social media
//   bool isBlockedSearchOrFeed = [
//     'search',      // Google, Bing, Yahoo, DuckDuckGo, Ask
//     's',           // Baidu
//     'yandsearch',  // Yandex
//     'results',     // YouTube search results
//     'watch',       // YouTube videos (https://www.youtube.com/watch?v=xyz)
//     'explore',     // Twitter/X explore page
//     'trending',    // YouTube trending page
//   ].any((keyword) => path.contains(keyword) || uri.queryParameters.containsKey("q"));

//   // Check for Twitter authentication pages
//   bool isTwitterAuthPage = (host.contains("twitter.com") || host.contains("x.com")) &&
//       (path.startsWith("/login") || path.startsWith("/i/flow/login") || path.startsWith("/signup"));


//    // Wikipedia-specific logic: Only allow content pages (not search, login, or special pages)
// bool isWikipedia = host.contains("wikipedia.org");
//   bool isWikipediaContentPage = isWikipedia &&
//       path.startsWith("/wiki/") && // Must be an article path
//       !path.startsWith("/wiki/Special:") && 
//       !path.startsWith("/wiki/Talk:") &&
//       !path.startsWith("/wiki/User:") &&
//       !path.startsWith("/wiki/Wikipedia:") &&
//       !path.startsWith("/wiki/Category:") &&
//       !path.startsWith("/wiki/File:") &&
//       !path.startsWith("/wiki/Help:") &&
//       !path.contains("search") && // Exclude search pages
//       !path.contains("index.php") && // Exclude index/search pages
//       !path.contains("#References"); // Exclude reference sections


//   if (isBlockedHomepage || isBlockedSearchOrFeed || isTwitterAuthPage) {
//     return false; // Hide FAB for blocked homepages, search/feed pages, YouTube videos, and Twitter auth pages
//   }


//   // Only allow Wikipedia content pages
//   if (isWikipedia) {
//     return isWikipediaContentPage;
//   }

//   return true; // Show FAB only for actual webpages and valid Twitter/X posts
// }


String getDownloadFile(String name){
 
  if(name.length > 15){
    String firstPart = name.substring(0, 4);
      String lastPart = name.substring(name.length - 4);
     return '$firstPart...$lastPart';
  }
  return name;
}

  Future<bool?> _showDownloadConfirmationDialog(BuildContext context, url) {
    final themeProvider =
        Provider.of<DarkThemeProvider>(context, listen: false);
        final width = MediaQuery.of(context).size.width;
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor:
              themeProvider.darkTheme ?const Color(0xff282836) :const Color(0xffFFFFFF),
          insetPadding: EdgeInsets.all(15),
          child: Container(
            width: width,
            // height: 200,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: themeProvider.darkTheme
                    ?const Color(0xff282836)
                    :const Color(0xffFFFFFF),
                borderRadius: BorderRadius.circular(8)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child:const Text(
                    'Download',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  'You are about to download ${getDownloadFile(url.suggestedFilename)}. \n Are you sure?',
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
                              ? Color(0xff42425F)
                              : Color(0xffF3F3F3),
                          disabledColor: Color(0xff2C2C3B),
                          minWidth: double.maxFinite,
                          height: 50,
                          child:const Text('Cancel', style: TextStyle(fontSize: 18)),
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
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: MaterialButton(
                          color: Color(0xff00B134),
                          disabledColor: Color(0xff2C2C3B),
                          minWidth: double.maxFinite,
                          height: 50,
                          child: Text('Download',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10.0), // Adjust the radius as needed
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop(true);
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











  bool isCurrentTab(WebViewModel currentWebViewModel) {
    return currentWebViewModel.tabIndex == widget.webViewModel.tabIndex;
  }

  Future<HttpAuthResponseAction> createHttpAuthDialog(
      URLAuthenticationChallenge challenge) async {
    HttpAuthResponseAction action = HttpAuthResponseAction.CANCEL;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Login"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(challenge.protectionSpace.host),
              TextField(
                decoration: const InputDecoration(labelText: "Username"),
                controller: _httpAuthUsernameController,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Password"),
                controller: _httpAuthPasswordController,
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("Cancel"),
              onPressed: () {
                action = HttpAuthResponseAction.CANCEL;
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text("Ok"),
              onPressed: () {
                action = HttpAuthResponseAction.PROCEED;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return action;
  }

  void onShowTab() async {
    resume();
    if (widget.webViewModel.needsToCompleteInitialLoad) {
      widget.webViewModel.needsToCompleteInitialLoad = false;
      await widget.webViewModel.webViewController
          ?.loadUrl(urlRequest: URLRequest(url: widget.webViewModel.url));
    }
  }

  void onHideTab() async {
    pause();
  }


  Future<bool?> isAppInstalled(String packageId) async {
  if (packageId.isEmpty) return false;
  
  //bool isInstalled = await InstalledApps.isAppInstalled(packageId);
  bool? appIsInstalled = await InstalledApps.isAppInstalled(packageId);
  return appIsInstalled;
}

String? extractPackageIdFromUrl(String url) {
  // Regex pattern to match 'id=' or 'package=' in the URL
  RegExp packageIdRegex = RegExp(r'(id|package)=([a-zA-Z0-9\._]+)');
  RegExp fallbackUrlRegex = RegExp(r'browser_fallback_url=([^&]+)');

  // Check for fallback URL first
  Match? fallbackMatch = fallbackUrlRegex.firstMatch(url);
  if (fallbackMatch != null && fallbackMatch.group(1) != null) {
    String fallbackUrl = Uri.decodeFull(fallbackMatch.group(1)!);
    // Recursively check the fallback URL
    return extractPackageIdFromUrl(fallbackUrl);
  }

  // Check for package ID using the regex
  Match? packageIdMatch = packageIdRegex.firstMatch(url);
  if (packageIdMatch != null && packageIdMatch.group(2) != null) {
    return packageIdMatch.group(2);
  }

  // Return null if no package ID is found
  return null;
}

}

