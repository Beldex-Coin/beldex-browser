import 'package:beldex_browser/src/browser/app_bar/sample_popup.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/pages/settings/android_settings.dart';
import 'package:beldex_browser/src/browser/pages/settings/cross_platform_settings.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/utils/screen_secure_provider.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:belnet_lib/belnet_lib.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';
//import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:provider/provider.dart';


class PopupSettingsMenuActions {
  // ignore: constant_identifier_names
  static const String RESET_BROWSER_SETTINGS = "Reset Browser Settings";
  // ignore: constant_identifier_names
  static const String RESET_WEBVIEW_SETTINGS = "Reset WebView Settings";

  static const List<String> choices = <String>[
    RESET_BROWSER_SETTINGS,
    RESET_WEBVIEW_SETTINGS,
  ];
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {




@override
  void initState() {

    super.initState();
    Future.delayed(Duration(milliseconds: 200),(){
     setValues();
    });
    
  }


setValues(){
  var vpnStatusProvider = Provider.of<VpnStatusProvider>(context,listen: false);
   var currentWebViewModel = Provider.of<WebViewModel>(context, listen: false);

   vpnStatusProvider.updateCacheValue( currentWebViewModel.settings?.cacheEnabled ?? true);
   vpnStatusProvider.updateJSEnabled(currentWebViewModel.settings?.javaScriptEnabled ?? true);
   vpnStatusProvider.updateSupportZoomEbld(currentWebViewModel.settings?.supportZoom ?? true);
   
   vpnStatusProvider.updateClearSessionCache(currentWebViewModel.settings?.clearSessionCache ?? false);
   vpnStatusProvider.updateBuiltinZoomControl(currentWebViewModel.settings?.builtInZoomControls ?? true);
   vpnStatusProvider.updateDisplayZoomControls(currentWebViewModel.settings?.displayZoomControls ?? false);
   vpnStatusProvider.updateThirdpartyCookies(currentWebViewModel.settings?.thirdPartyCookiesEnabled ?? true);
}




  //final dynamicTextSizeWidget = DynamicTextSizeWidget();
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);

final screenSize = MediaQuery.of(context).size;

    // Your pixel sizes
    const double pixelHeight = 22.57;
    const double pixelWidth = 39.97;
    
     const double pixelToggleSize = 20.0; // Example toggle size in pixels
   const double pixelFontSize1 = 12.74;
   const double pixelFontSize2 = 10.92;
    // Conversion to percentage of screen size
    final double heightInPercentage = (pixelHeight / screenSize.height) * 100;
    final double widthInPercentage = (pixelWidth / screenSize.width) * 100;

    // Conversion to height and width in logical pixels (dp)
    final double heightInDp = screenSize.height * (heightInPercentage / 100);
    final double widthInDp = screenSize.width * (widthInPercentage / 100);
     final double fontSizeInDp1 = (pixelFontSize1 / screenSize.width) * screenSize.width;
final double fontSizeInDp2 = (pixelFontSize2 / screenSize.width) * screenSize.width;

final double toggleSizeInDp = (pixelToggleSize / screenSize.width) * screenSize.width;
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          //backgroundColor: Color(0xff171720),
          appBar: AppBar(
           // backgroundColor: Color(0xff171720),
            bottom: TabBar(

                onTap: (value) {
                  FocusScope.of(context).unfocus();
                },
                indicatorColor: Color(0xff00B134),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Color(0xff00B134),
                labelStyle: TextStyle(
                  fontSize: 16
                ),
                tabs:[
                  Tab(
                    text: "Basic",
                  ),
                  Tab(
                    text: "Advanced",
                  ),
                ]),
                centerTitle: true,
            title: Text(
              "Settings",style:Theme.of(context).textTheme.bodyLarge 
            ),
            leading:IconButton( 
          onPressed: ()=>Navigator.pop(context),
          icon :SvgPicture.asset(  
            'assets/images/back.svg',
             color: themeProvider.darkTheme ? Colors.white : Color(0xff282836),
             height: 30,

             )) ,
             actions: [
             
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: IconButton(
              onPressed: (){
               
           resetBrowserSettingsDialog();
              },
              icon: SvgPicture.asset('assets/images/reset_browser.svg',color: themeProvider.darkTheme ? Colors.white: Colors.black,))
             )
             ],
            // actions: <Widget>[
            //   PopupMenuButton<String>(
            //     onSelected: _popupMenuChoiceAction,
            //     offset: Offset(0, 47),
            //     itemBuilder: (context) {
            //       var items = [
            //         CustomPopupMenuItem<String>(
            //           enabled: true,
            //           value: PopupSettingsMenuActions.RESET_BROWSER_SETTINGS,
            //           child: Row(
            //              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: const [
            //                 Text(PopupSettingsMenuActions
            //                     .RESET_BROWSER_SETTINGS),
            //                 Icon(
            //                   Foundation.web,
            //                   color: Colors.black,
            //                 )
            //               ]),
            //         ),
            //         CustomPopupMenuItem<String>(
            //           enabled: true,
            //           value: PopupSettingsMenuActions.RESET_WEBVIEW_SETTINGS,
            //           child: Row(
            //              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: const [
            //                 Text(PopupSettingsMenuActions
            //                     .RESET_WEBVIEW_SETTINGS),
            //                 Icon(
            //                   MaterialIcons.web,
            //                   color: Colors.black,
            //                 )
            //               ]),
            //         )
            //       ];

            //       return items;
            //     },
            //   )
            // ],
          ),
          body:TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
            
              CrossPlatformSettings(heightInDp: heightInDp, widthInDp: widthInDp, toggleSizeInDp: toggleSizeInDp,fontSizeInDp1:fontSizeInDp1,fontSizeInDp2:fontSizeInDp2),
                AndroidSettings(heightInDp: heightInDp, widthInDp: widthInDp, toggleSizeInDp: toggleSizeInDp,fontSizeInDp1:fontSizeInDp1,fontSizeInDp2:fontSizeInDp2),
             // IOSSettings(),
            ],
          ),
        ));
  }



void resetBrowserSettingsDialog()async{
  final themeProvider = Provider.of<DarkThemeProvider>(context,listen: false);
  final theme = Theme.of(context);
  final height = MediaQuery.of(context).size.height;
  final width = MediaQuery.of(context).size.width;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
                   backgroundColor:
                  themeProvider.darkTheme ? Color(0xff282836) : Color(0xffFFFFFF),
              insetPadding: EdgeInsets.all(20),
                  child: Container(
                      width:width,
                height:height/4.2, //200,
                padding: EdgeInsets.all(10),
                decoration:
                    BoxDecoration(
                      color:themeProvider.darkTheme ? Color(0xff282836) : Color(0xffFFFFFF),
                      borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Text('Reset settings',style: theme.textTheme.bodyLarge,
                          // TextStyle(fontSize:20,// dynamicTextSizeWidget.dynamicFontSize(20, context),
                          // fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical:5.0),
                          child:const Text('Do you want to reset the browser\nsettings?',
                          textAlign: TextAlign.center,
                          ),
                        ),
       
                        Row(
                          children: [
                            Expanded(
                              flex:1,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical:10.0,),
                                child: MaterialButton(
                                  elevation: 0,
                                color:themeProvider.darkTheme ? const Color(0xff42425F)  :const Color(0xffF3F3F3),
                                disabledColor: Color(0xff2C2C3B),
                                 minWidth: double.maxFinite,
                                height: 50,
                                child:const Text('Cancel',style: TextStyle(fontSize:18)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Adjust the radius as needed
                                ),
                                  onPressed: (){
                                   Navigator.pop(context);
                                },
                                
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              flex:1,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical:10.0),
                                child: MaterialButton(
                                  color: const Color(0xff00B134),
                                disabledColor:const Color(0xff2C2C3B),
                                 minWidth: double.maxFinite,
                                 elevation: 0,
                                height: 50,
                                child:const Text('Reset',style: TextStyle(color: Colors.white,fontSize:18)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Adjust the radius as needed
                                ),
                                  onPressed:(){
                                   resetSettings();
                                   Navigator.pop(context);
                                  } 
                                
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


void resetSettings()async{
  
  var browserModel = Provider.of<BrowserModel>(context, listen: false);
  var selectedItemsProvider = Provider.of<SelectedItemsProvider>(context,listen: false);
   browserModel.getSettings();
   var currentWebViewModel =
            Provider.of<WebViewModel>(context, listen: false);
  setState(() {
          browserModel.updateSettings(BrowserSettings());
          browserModel.save();
        });
    resetScreenSecurity();
   resetOptions();

    selectedItemsProvider.updateIconValue('assets/images/Google 1.svg');
    selectedItemsProvider.updateFontSize(8.0);
    
    if(browserModel.webViewTabs.isNotEmpty){
      //  var currentWebViewModel =
      //       Provider.of<WebViewModel>(context, listen: false);
        var webViewController = currentWebViewModel.webViewController;
        await webViewController?.setSettings(
            settings: InAppWebViewSettings(
                incognito: currentWebViewModel.isIncognitoMode,
                useOnDownloadStart: true,
                useOnLoadResource: true,
                safeBrowsingEnabled: true,
                allowsLinkPreview: false,
                minimumFontSize: 8,
                isFraudulentWebsiteWarningEnabled: true));
        currentWebViewModel.settings = await webViewController?.getSettings();
        browserModel.save();
        setState(() {});
    }

}

resetOptions(){
  final vpnStatusProvider = Provider.of<VpnStatusProvider>(context,listen: false);
  vpnStatusProvider.updateCacheValue(true);
  vpnStatusProvider.updateJSEnabled(true);
  vpnStatusProvider.updateSupportZoomEbld(true);

  vpnStatusProvider.updateClearSessionCache(false);
  vpnStatusProvider.updateBuiltinZoomControl(true);
  vpnStatusProvider.updateDisplayZoomControls(false);
  vpnStatusProvider.updateThirdpartyCookies(true);
}



resetScreenSecurity()async{
  // var browserModel = Provider.of<BrowserModel>(context, listen: false);
  // browserModel.updateScreenSecurity(true);
  // final prefs = await SharedPreferences.getInstance();
  // await prefs.setBool('switchState', true);
  var basicProvider = Provider.of<BasicProvider>(context,listen: false);
  basicProvider.updateScrnSecurity(true);
  await BelnetLib.enableScreenSecurity();
  //await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
}



  void _popupMenuChoiceAction(String choice) async {
    switch (choice) {
      case PopupSettingsMenuActions.RESET_BROWSER_SETTINGS:
        var browserModel = Provider.of<BrowserModel>(context, listen: false);
        setState(() {
          browserModel.updateSettings(BrowserSettings());
          browserModel.save();
        });
        break;
      case PopupSettingsMenuActions.RESET_WEBVIEW_SETTINGS:
        var browserModel = Provider.of<BrowserModel>(context, listen: false);
        browserModel.getSettings();
        var currentWebViewModel =
            Provider.of<WebViewModel>(context, listen: false);
        var webViewController = currentWebViewModel.webViewController;
        await webViewController?.setSettings(
            settings: InAppWebViewSettings(
                incognito: currentWebViewModel.isIncognitoMode,
                useOnDownloadStart: true,
                useOnLoadResource: true,
                safeBrowsingEnabled: true,
                allowsLinkPreview: false,
                isFraudulentWebsiteWarningEnabled: true));
        currentWebViewModel.settings = await webViewController?.getSettings();
        browserModel.save();
        setState(() {});
        break;
    }
  }
}
