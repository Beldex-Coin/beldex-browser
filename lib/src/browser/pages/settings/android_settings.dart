import 'package:beldex_browser/src/browser/app_bar/sample_popup.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/util.dart';
import 'package:beldex_browser/src/providers.dart';
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
      Function(double) onChanged) {
    return SliderTheme(
      data: SliderThemeData(
                trackHeight: 3,
              ),
      child: Slider(
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

    final width = MediaQuery.of(context).size.width;
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
                TextWidget(text:"Text Zoom",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Expanded(
                        child: TextWidget(
                           text: "Customize text size in percentage for comfortable reading on any website.",
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
          }),
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
          //height: constraints.maxHeight / 8.5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    TextWidget(text:"Clear Session Cache",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600)
                        
                        ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextWidget(
                          text:"Automatically clear the current session's cache for confidentiality.",
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
                    TextWidget(text:"Built In Zoom Controls",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600)),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextWidget(
                         text: "Control your browsing experience with built-in zoom functionality.",
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
                    TextWidget(text:"Display Zoom Controls",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600)),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextWidget(
                         text: "Show on-screen zoom controls for easy accessibility.",
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
                    TextWidget(text:"Third Party Cookies Enabled",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600)),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextWidget(
                         text: "Enable or disable third-party cookies to manage your confidentiality while browsing.",
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
                    TextWidget(text:"Debugging Enabled",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: widget.fontSizeInDp1, fontWeight: FontWeight.w600)),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextWidget(
                         text: "Activate debugging mode for advanced insights into performance.",
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
