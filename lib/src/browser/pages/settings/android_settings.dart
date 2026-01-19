import 'package:beldex_browser/ad_blocker_filter.dart';
import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/locale_provider.dart';
import 'package:beldex_browser/src/browser/app_bar/sample_popup.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/util.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/utils/screen_secure_provider.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:beldex_browser/src/widget/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';

class AndroidSettings extends StatefulWidget {
    final double heightInDp;
  final double widthInDp;
  final double toggleSizeInDp;
  final double fontSizeInDp1;
  final double fontSizeInDp2;
  const AndroidSettings({Key? key, required this.heightInDp, required this.widthInDp, required this.toggleSizeInDp, required this.fontSizeInDp1, required this.fontSizeInDp2}) : super(key: key);

  @override
  State<AndroidSettings> createState() => _AndroidSettingsState();
}

class _AndroidSettingsState extends State<AndroidSettings> {

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
   // var currentWebViewModel = Provider.of<WebViewModel>(context, listen: true);
    final selectedItemProvider = Provider.of<SelectedItemsProvider>(context, listen: true);
    double fontvalue =  selectedItemProvider.fontSize; 
    // double fontSizePercentage =
    //     ((currentWebViewModel.settings?.textZoom) ?? 100.0).toDouble();
    var vpnStatusProvider = Provider.of<VpnStatusProvider>(context,listen: false);
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        margin: EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: themeProvider.darkTheme
                ? const Color(0xff292937)
                : const Color(0xffF3F3F3),
            borderRadius: BorderRadius.circular(15)),
        // padding: EdgeInsets.only(left: 20, right: 15, top: 15, bottom: 20),
        child: RawScrollbar(
          padding: const EdgeInsets.only(right: 5, top: 5),
          thickness: 1.8,
          child: Container(
            padding:
                const EdgeInsets.only(left: 20, right: 15, top: 15, bottom: 20),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: _buildAndroidWebViewTabSettings(
                        themeProvider, fontvalue, constraints,selectedItemProvider,vpnStatusProvider),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }






Widget _buildSliderOption(double currentValue,
      Function(double) onChanged,DarkThemeProvider themeProvider) {
    return SliderTheme(
      data: SliderThemeData(
                trackHeight: 3,
                inactiveTrackColor:themeProvider.darkTheme ? Color(0xff363645) : Color(0xffDADADA)
              ),
      child: Slider(
        padding: EdgeInsets.all(10),
            value: currentValue,
            min: 8.0,
            max: 20.0,
            activeColor: Color(0xff00BD40),
            divisions:120,  //420,
            //label: '${currentValue.toStringAsFixed(1)}',
            onChanged: onChanged,
          ),
    );
  }



String getPercentage(double value) {
   // double percentage = (value / 42.0) * 100;
    double percentage = ((value - 8.0) / 12.0) * 150 + 50;
    return '${percentage.round() //toStringAsFixed(1)
    }%';
  }







  List<Widget> _buildAndroidWebViewTabSettings(DarkThemeProvider themeProvider,
      double fontvalue, BoxConstraints constraints,SelectedItemsProvider selectedItemProvider,VpnStatusProvider vpnStatusProvider) {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    var settings = browserModel.getSettings();
    var currentWebViewModel = Provider.of<WebViewModel>(context, listen: true);
    var webViewController = currentWebViewModel.webViewController;
    final basicProvider = Provider.of<BasicProvider>(context);
    final loc = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final appLocaleProvider = Provider.of<LocaleProvider>(context);
    var widgets = <Widget>[
      Column(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                TextWidget(text:loc.textZoom, //"Text Zoom",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Expanded(
                        child: TextWidget(
                           text:loc.textZoomContent, //"Customize text size in percentage for comfortable reading on any website.",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(fontWeight: FontWeight.w300,fontSize: widget.fontSizeInDp2))),
                    SizedBox(width: 20,),
                    TextWidget(
                      text:'${getPercentage(fontvalue)}',
                      style: TextStyle(
                          fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600,
                          color: themeProvider.darkTheme
                              ? Colors.white
                              : Colors.black),
                    )
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: constraints.maxWidth, //MediaQuery.of(context).size.height,
            child: _buildSliderOption( fontvalue,
              (value) async {
            currentWebViewModel.settings?.minimumFontSize = value.round();
            try {
              webViewController?.setSettings(
                  settings:
                      currentWebViewModel.settings ?? InAppWebViewSettings());
              var webSet = await webViewController?.getSettings();
              currentWebViewModel.settings = webSet;
             
            } catch (e) {}

            setState(() {
              fontvalue = value;
               selectedItemProvider.updateFontSize(fontvalue);
               print('The WEBVIEW model fontSize 4--- ${currentWebViewModel.settings?.minimumFontSize} --- ${selectedItemProvider.fontSize}');
             // browserModel.updateSettings(currentWebViewModel);
              browserModel.save();
            });
          },
          themeProvider
          ),
            // SliderTheme(
            //   data: SliderThemeData(
            //     trackHeight: 3,
            //   ),
            //   child: Slider(
            //     activeColor: const Color(0xff00BD40),
            //     min: 10.0,
            //     max: 200.0,
            //     value: fontSizePercentage,
            //     // allowedInteraction: SliderInteraction.tapAndSlide,
            //     onChanged: browserModel.webViewTabs.isEmpty
            //         ? null
            //         : (value) async {
            //             fontSizePercentage = value.toDouble();
            //             currentWebViewModel.settings?.textZoom =
            //                 fontSizePercentage.toInt();
            //             webViewController?.setSettings(
            //                 settings: currentWebViewModel.settings ??
            //                     InAppWebViewSettings());
            //             currentWebViewModel.settings =
            //                 await webViewController?.getSettings();
            //             browserModel.save();
            //             setState(() {});
            //           },
            //   ),
            // ),
          )
        ],
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
                    TextWidget(text:loc.adBlocker, //"Ad Blocker",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600)
                        // TextStyle(fontSize:15,// dynamicTextSizeWidget.dynamicFontSize(15, context),
                        // fontWeight: FontWeight.w600),
                        ),
                    TextWidget(
                        text:loc.adBlockerContent, //'Toggle to block intrusive ads while browsing and enhance your browsing experience',
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
                  value: basicProvider.adblock, //isSwitched,
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
                    basicProvider.updateAdblock(value);
                    // var browserModel = Provider.of<BrowserModel>(context, listen: false);
                    // browserModel.updateScreenSecurity(value);
                    setState(() {
                     // isSwitched = value;
                    });
                    if (basicProvider.adblock) {
                      List<ContentBlocker>? contentBlockers = [];
                     for (final adUrlFilter in AdBlockerFilter.adUrlFilters) {
                     contentBlockers.add(ContentBlocker(
                        trigger: ContentBlockerTrigger(
                           urlFilter: adUrlFilter,
                      ),
          action: ContentBlockerAction(
            type: ContentBlockerActionType.BLOCK,
            //selector: //".banner, .banners, .ads, .ad, .advert, .ad-container, .advertisement, .sponsored, .promo, .overlay-ad"
            //".ad ,.ads ,.advert ,.banner ,.banners ,.advertisement ,.promo ,.promotion ,.sponsored ,.sponsored-content ,.ad-container ,.ad-wrapper ,.ad-box ,.ad-slot,.ad-banner,.ad-image ,.ad-text ,video-ad,.interstitial,.sticky-ad,.floating-ad,.sidebar-ad,.footer-ad,.header-ad,.content-ad,.inline-ad,.content-recommendation,#google_ads,#adsense,.google-ad,.fb-ad (for Facebook ads),.twitter-ad (for Twitter ads),.native-ad,.outbrain,.taboola"
          )));
    }

    // Apply the "display: none" style to some HTML elements
    contentBlockers.add(ContentBlocker(
        trigger: ContentBlockerTrigger(
          urlFilter: ".*",
        ),
        action: ContentBlockerAction(
            type: ContentBlockerActionType.CSS_DISPLAY_NONE,
            selector: //selectors.join(', ') 
            ".banner, .banners, .ads, .ad, .advert, .ad-container, .advertisement, .sponsored, .promo, .overlay-ad"
                      //  ".ad ,.ads ,.advert ,.banner ,.banners ,.advertisement ,.promo ,.promotion ,.sponsored ,.sponsored-content ,.ad-container ,.ad-wrapper ,.ad-box ,.ad-slot,.ad-banner,.ad-image ,.ad-text ,video-ad,.interstitial,.sticky-ad,.floating-ad,.sidebar-ad,.footer-ad,.header-ad,.content-ad,.inline-ad,.content-recommendation,#google_ads,#adsense,.google-ad,.fb-ad,.twitter-ad,.native-ad,.outbrain,.taboola"

            )));

           currentWebViewModel.settings?.contentBlockers = contentBlockers;

                    } else {
                     currentWebViewModel.settings?.contentBlockers = [];
                    }
                    try {
              webViewController!.setSettings(
                  settings:
                      currentWebViewModel.settings ?? InAppWebViewSettings());
              var webSet = await webViewController.getSettings();
              currentWebViewModel.settings = webSet;
              vpnStatusProvider.updateFAB(false);
             // await webViewController.reload();
             await webViewController.loadUrl(urlRequest: URLRequest(url: currentWebViewModel.url,headers: {
            "Accept-Language": appLocaleProvider.fullLocaleId,
          }));

            } catch (e) {}

            setState(() {
              
            });
                    // await saveSwitchState(value);
                  }),
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
                    TextWidget(text:loc.autoConnect, //"Auto Connect",
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
                          text:loc.autoConnectContent, //"Automatically connect when the app launches",
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
                 // disabled: browserModel.webViewTabs.isEmpty,
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
                  value: basicProvider.autoConnect, //currentWebViewModel.settings?.supportZoom ?? true,
                  onToggle: (value) async {
                    basicProvider.updateAutoConnect(value);
                      setState(() {
                       print('AUTO CONNECT VALUE --------> ${basicProvider.autoConnect}');
                      });
                  }),
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
                    TextWidget(text:loc.autoSuggestion, //"Auto Suggestion",
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
                          text:loc.autoSuggestionContent, //"Automatically display suggestions while searching",
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
                 // disabled: browserModel.webViewTabs.isEmpty,
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
                  value: basicProvider.autoSuggest, //currentWebViewModel.settings?.supportZoom ?? true,
                  onToggle: (value) async {
                    basicProvider.updateAutoSuggest(value);
                      setState(() {
                       print('AUTO CONNECT VALUE --------> ${basicProvider.autoConnect}');
                      });
                  }),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          //height: constraints.maxHeight / 8.5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    TextWidget(text:loc.clearSessionCache, //"Clear Session Cache",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600)
                        
                        ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextWidget(
                          text:loc.clearSessionCacheContent, //"Automatically clear the current session's cache for confidentiality.",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontWeight: FontWeight.w300,fontSize: widget.fontSizeInDp2)
                        
                          ),
                    ),
                  ],
                ),
              ),
             const SizedBox(width: 30,),
              FlutterSwitch(
                  value:vpnStatusProvider.clearSessionCache,
                      //currentWebViewModel.settings?.clearSessionCache ?? false,
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
                  padding: 2.0,
                  activeToggleColor: const Color(0xff00BD40),
                  onToggle: (value) async {
                     setState(() {
                      vpnStatusProvider.updateClearSessionCache(value);
                      currentWebViewModel.settings?.clearSessionCache = value;
                    });
                    
                    webViewController?.setSettings(
                        settings: currentWebViewModel.settings ??
                            InAppWebViewSettings());
                    currentWebViewModel.settings =
                        await webViewController?.getSettings();
                    browserModel.save();
                    //setState(() {});
                  }),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          //height: constraints.maxHeight / 8.5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    TextWidget(text:loc.builtinZoomControls, //"Built In Zoom Controls",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600)),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextWidget(
                         text:loc.builtinZoomControlsContent, //"Control your browsing experience with built-in zoom functionality.",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontWeight: FontWeight.w300,fontSize: widget.fontSizeInDp2)),
                    ),
                  ],
                ),
              ),
             const SizedBox(
                width: 30,
              ),
              FlutterSwitch(
                  disabled: browserModel.webViewTabs.isEmpty,
                  value: vpnStatusProvider.builtinZoomControl,
                  // currentWebViewModel.settings?.builtInZoomControls ??
                  //     false,
                  inactiveColor: themeProvider.darkTheme
                      ? const Color(0xff363645)
                      : const Color(0xffFFFFFF),
                  inactiveToggleColor: themeProvider.darkTheme
                      ? const Color(0xff9595B5)
                      : const Color(0xffC5C5C5),
                  activeColor: themeProvider.darkTheme
                      ? const Color(0xff363645)
                      : const Color(0xffFFFFFF),
                  width: width / 8.0, //50,
                  height: width / 14.8, //29,
                  toggleSize: width / 17.2, //20
                  padding: 2.0,
                  activeToggleColor: Color(0xff00BD40),
                  onToggle: (value) async {
                     setState(() {
                       vpnStatusProvider.updateBuiltinZoomControl(value);
                       currentWebViewModel.settings?.builtInZoomControls = value;
                    });
                    webViewController?.setSettings(
                        settings: currentWebViewModel.settings ??
                            InAppWebViewSettings());
                    currentWebViewModel.settings =
                        await webViewController?.getSettings();
                    browserModel.save();
                   // setState(() {});
                  }),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          //height: constraints.maxHeight / 8.5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    TextWidget(text:loc.displayZoomControls, //"Display Zoom Controls",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600)),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextWidget(
                         text: loc.displayZoomControlsContent, //"Show on-screen zoom controls for easy accessibility.",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontWeight: FontWeight.w300,fontSize: widget.fontSizeInDp2)),
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
                  width:widget.widthInDp,
                    height: widget.heightInDp,
                  toggleSize: widget.toggleSizeInDp,
                  padding: 2.0,
                  activeToggleColor: Color(0xff00BD40),
                  value: vpnStatusProvider.displayZoomControls,
                  // currentWebViewModel.settings?.displayZoomControls ??
                  //     false,
                  onToggle: ((value) async {
                   setState(() {
                       vpnStatusProvider.updateDisplayZoomControls(value);
                        currentWebViewModel.settings?.displayZoomControls = value;
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
          //height: constraints.maxHeight / 8.5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    TextWidget(text:loc.thirdpartCookiesEnabled, //"Third Party Cookies Enabled",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600)),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextWidget(
                         text:loc.thirdpartyCookiesEnabledContent, //"Enable or disable third-party cookies to manage your confidentiality while browsing.",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontWeight: FontWeight.w300,fontSize: widget.fontSizeInDp2)),
                    ),
                  ],
                ),
              ),
            const  SizedBox(
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
                  width:widget.widthInDp,
                    height: widget.heightInDp,
                  toggleSize: widget.toggleSizeInDp,
                  padding: 2.0,
                  activeToggleColor: Color(0xff00BD40),
                  value: vpnStatusProvider.thirdpartyCookies,
                      // currentWebViewModel.settings?.thirdPartyCookiesEnabled ??
                      //     true,
                  onToggle: ((value) async {
                    setState(() {
                      vpnStatusProvider.updateThirdpartyCookies(value);
                        currentWebViewModel.settings?.thirdPartyCookiesEnabled =
                        value;
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
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          // height: constraints.maxHeight / 8.5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    TextWidget(text:loc.debuggingEnabled, //"Debugging Enabled",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600)),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextWidget(
                         text:loc.debuggingEnabledContent, //"Activate debugging mode for advanced insights into performance.",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontWeight: FontWeight.w300,fontSize: widget.fontSizeInDp2)),
                    ),
                  ],
                ),
              ),
             const SizedBox(
                width: 30,
              ),
              FlutterSwitch(
                  value: settings.debuggingEnabled,
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
                  padding: 2.0,
                  activeToggleColor: Color(0xff00BD40),
                  onToggle: ((value) {
                    setState(() {
                      settings.debuggingEnabled = value;
                      browserModel.updateSettings(settings);
                      if (browserModel.webViewTabs.isNotEmpty) {
                        var webViewModel =
                            browserModel.getCurrentTab()?.webViewModel;
                        if (Util.isAndroid()) {
                          InAppWebViewController.setWebContentsDebuggingEnabled(
                              settings.debuggingEnabled);
                        }
                        webViewModel?.settings?.isInspectable =
                            settings.debuggingEnabled;
                        webViewModel?.webViewController?.setSettings(
                            settings: webViewModel.settings ??
                                InAppWebViewSettings());
                        browserModel.save();
                      }
                    });
                  })),
            ],
          ),
        ),
      ),
    ];

    return widgets;
  }
}
