import 'package:beldex_browser/locale_provider.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:beldex_browser/src/web2_domain_list.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class AnimatedToggleSwitch extends StatefulWidget {
  final GlobalKey appbarKey;
  const AnimatedToggleSwitch({super.key, required this.appbarKey});

  @override
  State<AnimatedToggleSwitch> createState() => _AnimatedToggleSwitchState();
}

class _AnimatedToggleSwitchState extends State<AnimatedToggleSwitch> {
  bool _toggleValue = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    return GestureDetector(
      onTap: () => toggleButton(themeProvider),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 1000),
        height: 27,
        width: 55,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: themeProvider.darkTheme
                ? const Color(0xff363645)
                : const Color(0xffFFFFFF)),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration:const Duration(milliseconds: 1000),
              curve: Curves.easeIn,
              top: 3.0,
              left: themeProvider.darkTheme ? 30.0 : 0.0,
              right: themeProvider.darkTheme ? 0.0 : 30.0,
              child: InkWell(
                //onTap:()=> toggleButton(themeProvider),
                child: AnimatedSwitcher(
                    duration:const Duration(milliseconds: 1000),
                    transitionBuilder: (child, animation) {
                      return RotationTransition(child: child, turns: animation);
                    },
                    child: themeProvider.darkTheme
                        ? Container(
                            key: UniqueKey(),
                            height: 20,
                            width: 20,
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xff00BD40)),
                            child:
                                SvgPicture.asset('assets/images/dark_mode.svg'),
                          )
                        // )  Icon(Icons.check_circle,color: Colors.green,key: UniqueKey(),)
                        : Container(
                            key: UniqueKey(),
                            height: 20,
                            width: 20,
                            padding:const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xffC5C5C5)),
                            child: SvgPicture.asset(
                                'assets/images/white_theme.svg'),
                          )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void toggleButton(DarkThemeProvider themeProvider) {
   // print('clicked --> ');
    Navigator.pop(context);
    themeProvider.darkTheme = !themeProvider.darkTheme;
    updateStatusbarColor(themeProvider);
    //  (widget.appbarKey.currentWidget as StatefulElement).markNeedsBuild();
  }

   updateStatusbarColor(DarkThemeProvider themeProvider){
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: themeProvider.darkTheme ? Brightness.light : Brightness.dark
      )
    );
  }
}

class PageLoadingContainer extends StatefulWidget {
  final InAppWebViewController? webViewController;
  final BuildContext popupMenuContext;
  final TextEditingController? searchController;
  const PageLoadingContainer(
      {super.key,
      required this.webViewController,
      required this.popupMenuContext,
      required this.searchController});

  @override
  State<PageLoadingContainer> createState() => _PageLoadingContainerState();
}

class _PageLoadingContainerState extends State<PageLoadingContainer> {
  bool isLoading = false;
  late InAppWebViewController webViewController;
 checkLoading(VpnStatusProvider vpnStatusProvider)async{
 if(widget.webViewController != null){
  if(vpnStatusProvider.canShowHomeScreen){
    setState(() {
      isLoading = false;
    });
  }else{
     bool loading = await widget.webViewController!.isLoading();
  setState(() {
    isLoading = loading;
  });
  }
 
 }



  //  setState(() {   });
  //    isLoading = await widget.webViewController!.isLoading();

  
    // if( await webViewController.isLoading() == true){
    //   setState(() {
    //   print('coming inside');
    //   isLoading = true;
    //   });
    // }
  
 }

  @override
  Widget build(BuildContext context) {
    
   // print('coming');
   final vpnStatusProvider = Provider.of<VpnStatusProvider>(context,listen: false);
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final browserModel = Provider.of<BrowserModel>(context,listen: false);
    final appLocaleProvider = Provider.of<LocaleProvider>(context,listen: false);
        final webViewModel = Provider.of<WebViewModel>(context,listen: false);

    checkLoading(vpnStatusProvider);
    return SizedBox(
        width: 25.0,
        child: IconButton(
            padding: const EdgeInsets.all(0.0),
            icon: SvgPicture.asset(isLoading && browserModel.webViewTabs.isNotEmpty ? 'assets/images/stop_white_theme.svg' : 'assets/images/refresh.svg',
                color:
                themeProvider.darkTheme
                    ?const Color(0xffFFFFFF)
                    :const Color(0xff282836)),
            onPressed: () async {
              if (!isLoading) {
                setState(() {
                  isLoading = true;
                });
                Navigator.pop(widget.popupMenuContext);
                if (widget.webViewController != null &&
                    widget.searchController != null) {

String trimmedValue = widget.searchController!.text.trim();
if (trimmedValue.isEmpty) return;

//widget.webViewModel.setResolveData(trimmedValue);


//REMOVE http/https for detection + resolver
// String normalizedInput = trimmedValue
//     .replaceFirst(RegExp(r'^https?:\/\/'), '')
//     .trim();


String normalizedInput;

try {
  final uri = Uri.parse(
    trimmedValue.startsWith("http")
        ? trimmedValue
        : "http://$trimmedValue",
  );
  normalizedInput = uri.host;
} catch (_) {
  normalizedInput = trimmedValue
      .replaceFirst(RegExp(r'^https?:\/\/'), '')
      .split("/")
      .first;
}



String input = normalizedInput.toLowerCase(); //trimmedValue.toLowerCase();

bool isFullResolverUrl = input.contains("/resolver/fns/");


// NEW: plain text check
bool isPlainText = !input.contains(".");


bool isWeb2Domain = Web2DomainList().isWeb2Domain(input);
    // input.contains(".com") ||
    // input.contains(".in") ||
    // input.contains(".org") ||
    // input.contains(".net") ||
    // input.contains(".io");


// bool isPotentialWeb3Domain =
//     !input.startsWith("http") &&
//     !input.contains(" ") &&
//     input.split(".").length >= 2;

bool isPotentialWeb3Domain =
    input.contains(".") &&
    !input.startsWith("http") &&
    !input.contains(" ") &&
    !isWeb2Domain;

                  



if (!isPlainText && !isWeb2Domain && (isFullResolverUrl || isPotentialWeb3Domain)) {
  try {
    final apiUrl = isFullResolverUrl
        ? trimmedValue
        : "https://apis.freename.io/api/v1/resolver/FNS/$input";

    final res = await Dio().get(apiUrl);

    final records = res.data?["data"]?["records"];

    if (records != null && records.isNotEmpty) {

      String resolvedValue;
      String resolvedType;

      final aRecord = records.firstWhere(
        (r) => r["type"]?.toString().trim().toUpperCase() == "A",
        orElse: () => null,
      );

      if (aRecord != null) {
        resolvedValue = aRecord["value"];
        resolvedType = "A";
      } else {
        final first = records.first;
        resolvedValue = first["value"];
        resolvedType = first["type"]?.toString() ?? "UNKNOWN";
      }

      final domainName =
          res.data?["data"]?["asciiName"] ?? trimmedValue;

      // ✅ CLEAR + STORE immediately
      //widget.webViewModel.clearResolvedData();

     // widget.webViewModel.setActiveDomain(domainName);

      

      String finalUrl = resolvedValue.startsWith("http")
          ? resolvedValue
          : "http://$resolvedValue";

      if (widget.webViewController != null) {
           await widget.webViewController!.loadUrl(
                      urlRequest: URLRequest(
                          url: WebUri(finalUrl),
                          headers: {
            "Accept-Language": appLocaleProvider.fullLocaleId,
          },
                          ));
        // widget.webViewController!.loadUrl(
        //   urlRequest: URLRequest(
        //     url: WebUri(finalUrl),
        //   ),
        // );
      } 
      // else {
      //   addNewTab(url: WebUri(finalUrl));
      //   widget.webViewModel.url = WebUri(finalUrl);
      // }
    browserModel.setIsWeb3Domain(true);
   print('RESOLVE setiSWeb3 domain ${browserModel.isWeb3Domain}');

//Future.delayed(Duration(milliseconds: 450),()async{
  print('RESOLVE DOMAIN REDIRECT DATA IS ${webViewModel.url.toString()}');
 // final value = await webViewModel.webViewController?.getUrl();
  browserModel.addDomain(domain: domainName, resolvedValue:finalUrl, //resolvedValue, 
  type: resolvedType, redirectValue: //value?.toString() ?? 
  webViewModel.url.toString() //.url.toString()
  );
//});






      // Navigator.pop(context, WebUri(finalUrl));
      // return;
    }
  } catch (e) {
    print("Resolver failed: $e");
   // return;
  }
}else{
   await widget.webViewController!.loadUrl(
                      urlRequest: URLRequest(
                          url: WebUri(widget.searchController!.text),
                          headers: {
            "Accept-Language": appLocaleProvider.fullLocaleId,
          },
                          ));
}






          //         await widget.webViewController!.loadUrl(
          //             urlRequest: URLRequest(
          //                 url: WebUri(widget.searchController!.text),
          //                 headers: {
          //   "Accept-Language": appLocaleProvider.fullLocaleId,
          // }
          //                 ));
                  vpnStatusProvider.updateFAB(true);
                }
              } else {
                setState(() {
                  isLoading = false;
                });
                if (widget.webViewController != null) {
                  if (await widget.webViewController!.isLoading()) {
                    await widget.webViewController!.stopLoading();
                    
                  }
                }
              }
            }));
  }
}
