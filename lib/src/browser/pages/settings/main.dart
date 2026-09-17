import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/locale_provider.dart';
import 'package:beldex_browser/src/browser/app_bar/sample_popup.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/pages/settings/android_settings.dart';
import 'package:beldex_browser/src/browser/pages/settings/cross_platform_settings.dart';
import 'package:beldex_browser/src/browser/pages/tab_settings/glassmorph_widget.dart';
import 'package:beldex_browser/src/browser/providers/appbar_position_provider.dart';
import 'package:beldex_browser/src/browser/providers/tab_provider.dart';
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


int selectedSettingTab = 0;


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


List settingType = ['Basic', 'Advanced'];

  //final dynamicTextSizeWidget = DynamicTextSizeWidget();
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);

final screenSize = MediaQuery.of(context).size;
final loc = AppLocalizations.of(context)!;
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
    return Stack(
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
        SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
             // bottom: 
              // TabBar(
          
              //     onTap: (value) {
              //       FocusScope.of(context).unfocus();
              //     },
              //     indicatorColor: Color(0xff00B134),
              //     indicatorSize: TabBarIndicatorSize.tab,
              //     labelColor: Color(0xff00B134),
              //     labelStyle: TextStyle(
              //       fontSize: 16
              //     ),
              //     tabs:[
              //       Tab(
              //         text:loc.basic //"Basic",
              //       ),
              //       Tab(
              //         text:loc.advanced,// "Advanced",
              //       ),
              //     ]),
                  //centerTitle: true,
                  automaticallyImplyLeading: false,
              title:Row(
                children: [
          GestureDetector(
            onTap: ()=> Navigator.pop(context),
            child: SvgPicture.asset(
              'assets/images/back.svg',
              color: themeProvider.darkTheme ? Colors.white :const Color(0xff282836),
              height: 25,
            ),
          ),
          SizedBox(width: 8,),
          Text(loc.settings, style: TextStyle(fontFamily: 'Inter',fontSize: 16,fontWeight: FontWeight.w900)),
                ],
              ),
              
            //   leading:
            //   IconButton( 
            // onPressed: ()=>Navigator.pop(context),
            // icon :SvgPicture.asset(  
            //   'assets/images/back.svg',
            //    color: themeProvider.darkTheme ? Colors.white : Color(0xff282836),
            //    height: 30,
          
            //    )) ,
               actions: [
               
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: IconButton(
                onPressed: (){
                 
             resetBrowserSettingsDialog();
                },
                icon: SvgPicture.asset('assets/images/ai-icons/new/reset-setting.svg',color: themeProvider.darkTheme ? Colors.white: Colors.black,))
               )
               ],
            ),
            body: settingsBody(heightInDp,widthInDp, toggleSizeInDp,fontSizeInDp1,fontSizeInDp2,loc,themeProvider),
          ),
        ),
      ],
    );
  }


Widget settingsBody(double heightInDp,double widthInDp,double toggleSizeInDp, double fontSizeInDp1,double fontSizeInDp2,AppLocalizations loc,DarkThemeProvider themeProvider){
  return Column(  
    children:[
        Container(
                            height: 50,width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.symmetric(horizontal:  10,vertical: 3),
              decoration: BoxDecoration(
                border: Border.all(color:themeProvider.darkTheme ? Color(0xff333333) : Color(0xffD4D4D4))
              ),
              child: 
              Row(
  children: List.generate(
    settingType.length * 2 - 1,
    (index) {
      if (index.isOdd) {
        return const SizedBox(width: 10);
      }

     final actualIndex = index ~/ 2;

      return Expanded(
        child: _tabButton(
          title: actualIndex == 0 ? loc.basic : loc.advanced,
          //count: settingType[index].length,
          selected: selectedSettingTab == actualIndex,
          onTap: () {
            setState(() {
              selectedSettingTab = actualIndex;
            });
            //provider.changeTab(actualIndex);
          },
        ),
      );
    },
  ),
)),


Expanded(child: selectedSettingTab == 0 ? 
 CrossPlatformSettings(heightInDp: heightInDp, widthInDp: widthInDp, toggleSizeInDp: toggleSizeInDp,fontSizeInDp1:fontSizeInDp1,fontSizeInDp2:fontSizeInDp2)
              :  AndroidSettings(heightInDp: heightInDp, widthInDp: widthInDp, toggleSizeInDp: toggleSizeInDp,fontSizeInDp1:fontSizeInDp1,fontSizeInDp2:fontSizeInDp2),
             // IOSSettings(),

)





    ]
  );
}

Widget _tabButton({
  required String title,
 // required int count,
  required bool selected,
  required VoidCallback onTap,
}) {
  final themeProvider = Provider.of<DarkThemeProvider>(context);
  return InkWell(
    onTap: onTap,
    child: Container(
      //height: 45,
      padding:
          const EdgeInsets.all(
        9,
      ),
      decoration: BoxDecoration(
        color: selected ?
            themeProvider.darkTheme ? Colors.black : Color(0xffffffff) : themeProvider.darkTheme ? Color(0xff444444).withOpacity(0.4) : Color(0xffD4D4D4).withOpacity(0.4),
        border: Border.all(color: selected ? themeProvider.darkTheme ? Colors.white : Colors.black : Colors.transparent,width: 0.3)
      ),
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text( title,style: TextStyle(fontSize: 12,color:selected ?themeProvider.darkTheme ? Colors.white : Colors.black : themeProvider.darkTheme ?  Color(0xff8D8D8D): Colors.black,fontFamily: 'Inter',fontWeight: selected? FontWeight.w900 : FontWeight.w400)),
        ],
      ),

    ),
  );
}


void resetBrowserSettingsDialog()async{
  final themeProvider = Provider.of<DarkThemeProvider>(context,listen: false);
  // final theme = Theme.of(context);
  // final height = MediaQuery.of(context).size.height;
  // final width = MediaQuery.of(context).size.width;
  final loc = AppLocalizations.of(context)!;
    return showDialog(
      context: context,
       barrierColor:themeProvider.darkTheme ? Colors.black54 : Color(0xffFFFFFFE).withOpacity(0.8) ,
      builder: (BuildContext context) {
        return Dialog(
                   insetPadding: EdgeInsets.all(18),
            backgroundColor: Colors.transparent,
            // title: const Text(
            //   "Create Tab Group",
            // ),
           
            // shape:
            //     RoundedRectangleBorder(
            //   borderRadius:
            //       BorderRadius.circular(
            //     18,
            //   ),
            // ),
                  child: GlassCommonPanel(
                    child: Container(
                       margin: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  // decoration: BoxDecoration(
                  //   border: Border.all(color: themeProvider.darkTheme ? Color(0xff444444) : Color(0xffD4D4D4))
                  // ),
                      //   width:width,
                      //              // height:height/4.2, //200,
                      //               padding: EdgeInsets.all(10),
                      //               decoration:
                      // BoxDecoration(
                      //   color:themeProvider.darkTheme ? Color(0xff282836) : Color(0xffFFFFFF),
                      //   borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Text(loc.resetSettings, //'Reset settings',
                            style: TextStyle(fontFamily: 'inter',fontSize: 18,color:themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B) ),
                            // TextStyle(fontSize:20,// dynamicTextSizeWidget.dynamicFontSize(20, context),
                            // fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical:5.0),
                            child: Text(loc.doYouWanttoReset,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: 'inter',fontSize: 14, color:themeProvider.darkTheme ? Color(0xffACACAC): Color(0xff444444)),
                            ),
                          ),
                           
                          Row(
                            children: [
                              Expanded(
                                flex:1,
                                child: Padding(
                                  padding: EdgeInsets.zero, //symmetric(vertical:10.0,),
                                  child: MaterialButton(
                                    elevation: 0,
                                  color:themeProvider.darkTheme ? const Color(0xff333333)  :const Color(0xffDEDEDE),
                                  disabledColor: Color(0xff2C2C3B),
                                   minWidth: double.maxFinite,
                                  height: 50,
                                  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.zero,
  ),
                                  child: Text(loc.cancel,
                                  style: TextStyle(fontSize:16,fontFamily: 'Inter',color: themeProvider.darkTheme ? Color(0xffEBEBEB) : Color(0xff0B0B0B),fontWeight: FontWeight.w600)),
                                  // shape: RoundedRectangleBorder(
                                  //   borderRadius: BorderRadius.circular(
                                  //       10.0), // Adjust the radius as needed
                                  // ),
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
                                  padding: EdgeInsets.zero,//symmetric(vertical:10.0),
                                  child: MaterialButton(
                                    color:themeProvider.darkTheme ? const Color(0xffEBEBEB) : Color(0xff0B0B0B),
                                  disabledColor:const Color(0xff2C2C3B),
                                   minWidth: double.maxFinite,
                                   elevation: 0,
                                  height: 50,
                                  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.zero,
  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(loc.reset //'Reset'
                                    ,style: TextStyle(color:themeProvider.darkTheme ? Color(0xff0B0B0B) : Color(0xffEBEBEB),fontSize:18,fontFamily: 'Inter', fontWeight: FontWeight.w600),),
                                  ),
                                  // shape: RoundedRectangleBorder(
                                  //   borderRadius: BorderRadius.circular(
                                  //       10.0), // Adjust the radius as needed
                                  // ),
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
                  ),
                );
      },
    );
}


void resetSettings()async{
  
  var browserModel = Provider.of<BrowserModel>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context,listen: false);

 // var selectedItemsProvider = Provider.of<SelectedItemsProvider>(context,listen: false);
   browserModel.getSettings();
   var currentWebViewModel =
            Provider.of<WebViewModel>(context, listen: false);
  setState(() {
          browserModel.updateSettings(BrowserSettings());
          browserModel.save();
        });
    resetScreenSecurity();
   resetOptions();

    browserModel.updateIconValue('assets/images/Google 1.svg');
    browserModel.updateFontSize(8.0);
    
    if(groupProvider.totalOpenTabsCount != 0){
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
  final basicProvider = Provider.of<BasicProvider>(context,listen: false);
    final localeProvider = Provider.of<LocaleProvider>(context,listen:false);
    final appBarPositionProvider = Provider.of<AppBarPositionProvider>(context,listen: false);
  vpnStatusProvider.updateCacheValue(true);
  vpnStatusProvider.updateJSEnabled(true);
  vpnStatusProvider.updateSupportZoomEbld(true);

  vpnStatusProvider.updateClearSessionCache(false);
  vpnStatusProvider.updateBuiltinZoomControl(true);
  vpnStatusProvider.updateDisplayZoomControls(false);
  vpnStatusProvider.updateThirdpartyCookies(true);
  basicProvider.updateAutoConnect(false);
  basicProvider.updateAutoSuggest(false);
  basicProvider.updateAdblock(true);
    localeProvider.resetAppLocaleToEnglish();
  vpnStatusProvider.updateIsEnableFreeName(false);
 appBarPositionProvider.changePosition(AppBarPosition.top);
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
