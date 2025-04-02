import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
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
                  await widget.webViewController!.loadUrl(
                      urlRequest: URLRequest(
                          url: WebUri(widget.searchController!.text)));
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
