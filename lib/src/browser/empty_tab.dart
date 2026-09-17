import 'package:beldex_browser/fetch_price.dart';
import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/src/browser/app_bar/app_bars.dart';
import 'package:beldex_browser/src/browser/app_bar/sample_popup.dart';
import 'package:beldex_browser/src/browser/app_bar/search_screen.dart';
import 'package:beldex_browser/src/browser/pages/tab_settings/glassmorph_widget.dart';
import 'package:beldex_browser/src/browser/providers/appbar_position_provider.dart';
import 'package:beldex_browser/src/browser/providers/ip_provider.dart';
import 'package:beldex_browser/src/browser/webview_tab.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'models/browser_model.dart';
import 'models/webview_model.dart';

class EmptyTab extends StatefulWidget {
  const EmptyTab({Key? key}) : super(key: key);

  @override
  State<EmptyTab> createState() => _EmptyTabState();
}

class _EmptyTabState extends State<EmptyTab> {
 bool canShowIP = false;



@override
  void initState() {
    var browserModel = Provider.of<BrowserModel>(context,listen: false);
    if(browserModel.webViewTabs.isEmpty){
      clearCookie();
    }
    
    super.initState();
  }

final List<Map<String, String>> items = [
    {'image': 'assets/images/ai-icons/new/Beldex_logo 1.svg',
     'light' : 'assets/images/ai-icons/new/Beldexw.svg', 
     'label': 'Beldex.bdx',
     'link':'http://official.bdx/'},
    {'image': 'assets/images/ai-icons/new/bchat.svg', 
    'light' : 'assets/images/ai-icons/new/bchatw.svg', 
     'label': 'BChat.bdx',
     'link':'http://bchat.bdx/'},
    {'image': 'assets/images/ai-icons/new/belnet.svg',
    'light' : 'assets/images/ai-icons/new/BelNetw.svg',  
     'label': 'BelNet.bdx', 
     'link':'http://belnet.bdx/'},
    {'image': 'assets/images/ai-icons/new/beldex_browser.svg',
    'light' : 'assets/images/ai-icons/new/Beldex Browserw.svg',  
     'label': 'Beldex Browser.bdx',
     'link': 'http://browser.bdx/'},
     {'image': 'assets/images/ai-icons/new/bridge.svg',
     'light' : 'assets/images/ai-icons/new/Beldex Bridgew.svg', 
     'label': 'Beldex Bridge.bdx', 
     'link': 'http://bridge.bdx/',
    //  'darkImage': 'assets/images/bridge_dark.svg',
    //  'lightImage': 'assets/images/bridge_wht_theme.svg',
     },
    {'image': 'assets/images/ai-icons/new/explorer.svg',
    'light' : 'assets/images/ai-icons/new/Beldex Explorerw.svg', 
     'label': 'Beldex Explorer.bdx',
     'link': 'http://explorer.bdx/',
     'darkImage': 'assets/images/ai-icons/new/explorer.svg',
     'lightImage': 'assets/images/ai-icons/new/explorer.svg',
     },
    
  ];


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
     final priceValueProvider = Provider.of<PriceValueProvider>(context);
     final ipProvider = Provider.of<IpProvider>(context);
     final browserModel = Provider.of<BrowserModel>(context);
     final settings = browserModel.getSettings();
     final loc = AppLocalizations.of(context)!;
     final webViewModel = Provider.of<WebViewModel>(context);
    // var webViewModel = browserModel.getCurrentTab()?.webViewModel;
        var webViewController = webViewModel.webViewController;
     final appBarPositionProvider = Provider.of<AppBarPositionProvider>(context);
     final vpnStatusProvider = Provider.of<VpnStatusProvider>(context); 
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
          bottom: false,
          child: Scaffold(
            backgroundColor:Colors.transparent, //Color(0xff171720),
            body: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical:15.0,horizontal: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                       Spacer(),
                      appBarPositionProvider.selectedPosition == AppBarPosition.top || vpnStatusProvider.canShowHomeScreen && appBarPositionProvider.selectedPosition != AppBarPosition.bottom ? 
                     // FlexibleAppbar()
                       GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchScreen(
                                      controller: TextEditingController(),
                                      browserModel: browserModel,
                                      settings: settings,
                                      webViewController: webViewController,
                                      webViewModel: webViewModel,
                                      //  pageTitle:pageTitles ,//pageTitle,
                                      //  favIcons:favIcon, //favIcon,
                                    )));
                        },
                        child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: themeProvider.darkTheme ? Color(0xff111111) : Color(0xffFFFFFF).withOpacity(0.6),
                              border: Border.all(color: themeProvider.darkTheme ? Color(0xff444444) : Color(0xffD4D4D4))
                            ),
                            padding: EdgeInsets.only(right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: themeProvider.darkTheme ? Color(0xff1A1A1A) : Color(0xffEBEBEB),
                                    border: Border.all(color:themeProvider.darkTheme ? Color(0xff333333) : Color(0xffC0C0C0))),
                                  child: SearchSettingsPopupList(
                                                            browserModel: browserModel,
                                                            browserSettings: settings,
                                                          ),
                                ),
                                Expanded(child: Text(loc.searchOrEnterAddress, style: TextStyle(fontFamily: 'Roboto',fontSize: 14,color:Color(0xff737373)),overflow: TextOverflow.ellipsis,maxLines: 1,)),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                                  child: SvgPicture.asset('assets/images/ai-icons/new/search_tab_white.svg',color: themeProvider.darkTheme ? Color(0xffffffff) : Color(0xff0B0B0B),),
                                )
                              ],
                            ),
                          ),
                      )
                      : SizedBox(),
                        SizedBox(height: 15,),
                       //themeProvider.darkTheme ?
                        // Padding(
                        //   padding: const EdgeInsets.only(top:30.0),
                        //   child: SvgPicture.asset('assets/images/browser-name-banner.svg',width: constraints.maxWidth/1.5,),
                        // ),
                        //const SizedBox(height: 50,),
                        Container(
                          decoration: BoxDecoration(
                            color: themeProvider.darkTheme ? Colors.transparent : Color(0xffACACAC).withOpacity(0.1),
                             border: Border.all(color: Colors.grey.withOpacity(0.3))
                          ),
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(loc.marketUpdate,style: TextStyle(fontFamily: 'Inter',fontWeight: FontWeight.w900, color: themeProvider.darkTheme ? Color(0xffACACAC) : Color(0xff444444),fontSize: 10),),
                              SizedBox(height: 10,),
                              GlassPanel(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration( 
                                    //color: themeProvider.darkTheme ? Color(0xff282836) : Color(0xffF3F3F3),
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right:5.0),
                                            child: Text('1.0000',style: TextStyle(fontWeight: FontWeight.w800,fontFamily: 'Inter'),),
                                          ),
                                           Container(
                                        padding: EdgeInsets.symmetric(vertical: 5,horizontal: 15),
                                        decoration: BoxDecoration(
                                          color: themeProvider.darkTheme ? Color(0xff0B0B0B) : Color(0xffFFFFFF),
                                        ),
                                        child: Text('BDX',style: TextStyle(color: Color(0xff00BD40),fontWeight: FontWeight.bold,fontFamily: 'Inter'),),
                                        
                                      ),
                                        ],
                                      ),
                                     
                                      Text('=', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                                       Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right:5.0),
                                            child: Text('${priceValueProvider.value.toStringAsFixed(4)}',style: TextStyle(fontWeight: FontWeight.w800,fontFamily: 'Inter'),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            ),
                                          ),
                                           Container(
                                        padding: EdgeInsets.symmetric(vertical: 5,horizontal: 15),
                                        decoration: BoxDecoration(
                                          color: themeProvider.darkTheme ? Color(0xff0B0B0B) : Color(0xffFFFFFF),
                                        ),
                                        child: Text('USDT',style: TextStyle(fontWeight: FontWeight.w600,fontFamily: 'Inter',color:themeProvider.darkTheme ? Color(0xffACACAC): Color(0xff444444)),),
                                        
                                      ),
                                        ],
                                      ),
                                        
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
          
                      const SizedBox(height: 10),
                       ClipRect(
                         child: 
                        // ConstrainedBox(
                          
                          //height: 310,
                          //color: Colors.green,
                          //padding: EdgeInsets.only(top:8),
                          //  constraints: BoxConstraints(
                          //   maxHeight: 250,
                          //  ),
                          // child: 
                           GridView.builder(
                             itemCount: items.length,
                             shrinkWrap: true,
                               physics: const NeverScrollableScrollPhysics(),
                             //physics: ClampingScrollPhysics(),
                             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                               crossAxisCount: 3,
                               mainAxisSpacing: 10,
                               crossAxisSpacing: 10,
                               childAspectRatio: 0.9,
                             
                              //  crossAxisCount: 3,
                              // // crossAxisSpacing: 15,
                              //  mainAxisSpacing: 10,
                              //  mainAxisExtent: 130
                             ),
                             itemBuilder: (context, index) {
                               return ItemListWidget(
                                 imagePath: items[index]['image']!,
                                 lightTheme: items[index]['light']!,
                                 label: items[index]['label']!,
                                 darkImagePath: items[index]['darkImage'],
                                 lightImagePath: items[index]['lightImage'],
                                 link: items[index]['link']!,
                               );
                             },
                           ),
                        // ),
                       ),
                       Spacer(),
                       Container(
                         padding: EdgeInsets.all(10),
                         decoration: BoxDecoration(
                          color: themeProvider.darkTheme ? Color(0xff1A1A1A).withOpacity(0.1) : Color(0xffACACAC).withOpacity(0.1),
                          border: Border.all(color:themeProvider.darkTheme ? Color(0xff222222) : Color(0xffD4D4D4))
                         ),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(loc.iPAddress,style: TextStyle(fontFamily: 'Inter',fontWeight: FontWeight.w900,fontSize:10, color: Color(0xffACACAC)),),
                             Padding(
                               padding: const EdgeInsets.only(top: 8.0),
                               child: Row(
                                 children:[
                                 Expanded(
                                   child: GlassPanel(
                                     
                                                 child: Padding(
                                                   padding: const EdgeInsets.symmetric(vertical:  14.0, horizontal: 8.0),
                                                   child: Column(
                                                     mainAxisAlignment: MainAxisAlignment.center,
                                                     crossAxisAlignment: CrossAxisAlignment.start,
                                                     children: [
                                                       Row(
                                                         children: [
                                                           // SizedBox(height: 8),
                                                           Text('${loc.myIP}  ',style: TextStyle(color:themeProvider.darkTheme ? Color(0xffACACAC): Color(0xff4D4D4D),fontSize: 11,fontWeight: FontWeight.w900, fontFamily: 'Inter'),),
                                                           GestureDetector(
                                                             onTap: ()=>setState(() {
                                                               canShowIP = !canShowIP;
                                                             }),
                                                             child:canShowIP ? SvgPicture.asset('assets/images/ai-icons/new/view_IP.svg') : SvgPicture.asset('assets/images/ai-icons/new/hide.svg')),
                                                             //Icon(Icons)
                                                         ],
                                                                           
                                                       ),
                                                       SizedBox(height: 10,),
                                                   !canShowIP ? Text( '***.**.***.**',style: TextStyle(fontFamily: 'Poppins',fontSize: 11),)
                                                   : Text( '${ipProvider.realIp}',style: TextStyle(fontFamily: 'Poppins',fontSize: 11),),
                                                                           
                                                     ],
                                                   ),
                                                 ),
                                   ),
                                 ),
                                 SizedBox(width: 5,),
                                 Expanded(
                                   child: GlassPanel(
                                     
                                                 child: Padding(
                                                   padding: const EdgeInsets.all(8.0),
                                                   child: Column(
                                                     mainAxisAlignment: MainAxisAlignment.center,
                                                     crossAxisAlignment: CrossAxisAlignment.baseline,
                                                     textBaseline: TextBaseline.alphabetic,
                                                     children:[
                                                    Text('${loc.vpnIP}  ',style: TextStyle(color:themeProvider.darkTheme ? Color(0xffACACAC): Color(0xff4D4D4D),fontSize: 11,fontWeight: FontWeight.w800,fontFamily: 'Inter'),),
                                                       RichText(
                                                                                 textAlign: TextAlign.justify,
                                                                                 maxLines: 1,
                                                                                   text: TextSpan(
                                                                                       text: "IPV4: ",
                                                                                       style: TextStyle(
                                                                                           fontSize:11, //mHeight * 0.060 / 3,
                                                                                           fontWeight: FontWeight.w800,
                                                                                           fontFamily: 'Roboto',
                                                                                           color: themeProvider.darkTheme ? Colors.white : Colors.black ),
                                                                                       children: [
                                                                                     TextSpan(
                                                                                         text:ipProvider.currentIPv4,
                                                   style: TextStyle(
                                                   fontSize:11, //mHeight * 0.056 / 3,
                                                   fontWeight: FontWeight.w100,
                                                   fontFamily: 'Roboto',
                                                   color:themeProvider.darkTheme ? Color(0xffffffff): Color(0xff333333),
                                                   overflow: TextOverflow.ellipsis
                                                       ))
                                                                                   ])),
                                                                                   SizedBox(height: 5,),
                                                                                     RichText(
                                                                                 textAlign: TextAlign.justify,
                                                                                 maxLines: 1,
                                                                                   text: TextSpan(
                                                                                       text: "IPV6: ",
                                                                                       style: TextStyle(
                                                                                           fontSize:11, //mHeight * 0.060 / 3,
                                                                                           fontWeight: FontWeight.w800,
                                                                                           fontFamily: 'Roboto',
                                                                                           color: themeProvider.darkTheme ? Colors.white : Colors.black),
                                                                                       children: [
                                                                                     TextSpan(
                                                                                         text:ipProvider.currentIPv6,
                                                   style: TextStyle(
                                                   fontSize:11, //mHeight * 0.056 / 3,
                                                   fontWeight: FontWeight.w100,
                                                   fontFamily: 'Roboto',
                                                   color:themeProvider.darkTheme ? Color(0xffffffff): Color(0xff333333),
                                                   overflow: TextOverflow.ellipsis
                                                   
                                                       ))
                                                                                   ])),
                                                     ]
                                                   ),
                                                 ),
                                   ),
                                 )
                                 ]
                               ),
                             )
                           ],
                         ),
                       ),
                       // : SvgPicture.asset('assets/images/Beldex_small_splash_white.svg',width: constraints.maxWidth,height: constraints.maxHeight/1.2,)
                        
                      ],
                    ),
                  );
                }
              ),
            ),
          ),
        ),
      ],
    );
  }

  void openNewTab(value) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();
browserModel.showTabScroller = false;
    browserModel.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(
        uuid: Uuid().v4(),
          url: WebUri(value.startsWith("http")
              ? value
              : settings.searchEngine.searchUrl + value)),
    ));
  }
}


class ItemListWidget extends StatelessWidget {
  final String imagePath;
  final String label;
  final String lightTheme;
  final String? darkImagePath;
  final String? lightImagePath;
  final String link;

  ItemListWidget({
    required this.imagePath,
    required this.label,
    this.darkImagePath,
    this.lightImagePath, required this.link, required this.lightTheme,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
    // final displayImagePath = (isDarkTheme && darkImagePath != null)
    //     ? darkImagePath!
    //     : (isDarkTheme ? imagePath : (lightImagePath ?? imagePath));

    return GestureDetector(
      onTap: (){
       vpnStatusProvider.updateCanShowHomeScreen(false);
       addNewTab(context,url: WebUri(link));
      },
      child: GlassAppTile(icon:themeProvider.darkTheme ? imagePath :
       lightTheme ,title: label,)
      // Padding(
      //   padding: const EdgeInsets.symmetric(horizontal:8.0),
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       GlassAppTile(icon:displayImagePath ,title: label,)
      //     //   Container(
      //     //     padding: EdgeInsets.all(20),
      //     //     decoration: BoxDecoration(
      //     //       shape: BoxShape.circle,
      //     //       color:Colors.transparent, // isDarkTheme ? Color(0xff222222) : Color(0xffF3F3F3),
      //     //       border: Border.all(color: Color(0xff222222),)
      //     //     ),
      //     //     child: SvgPicture.asset(
      //     //       displayImagePath,
      //     //       // width: 50,
      //     //       // height: 50,
      //     //     ),
      //     //   ),
      //     //  SizedBox(height: 8),
      //     //   Expanded(
      //     //     child: Container(
      //     //       //color: Colors.green,
      //     //       child: Text(
      //     //         label,
      //     //         style: TextStyle(fontSize: 12, color: isDarkTheme ? Color(0xff9595B5) : Color(0xff9595B5)),
      //     //         maxLines: 3,
      //     //         textAlign: TextAlign.center,
      //     //       ),
      //     //     ),
      //     //   ),
      //      // SizedBox(height: 10,)
      //     ],
      //   ),
      // ),
    );
  }
  void addNewTab( BuildContext context,{WebUri? url}) {
    final browserModel = Provider.of<BrowserModel>(context, listen: false);
    final webViewModel = Provider.of<WebViewModel>(context, listen: false);
    final settings = browserModel.getSettings();
   // final selectedItemsProvider = Provider.of<SelectedItemsProvider>(context,listen: false);
    url ??=
        // settings.homePageEnabled && settings.customUrlHomePage.isNotEmpty
        //     ? WebUri(settings.customUrlHomePage)
        //     :
        WebUri(settings.searchEngine.url);
    // browserModel.updateIsNewTab(true);
    print('THE WEB TEST --> $url');
    print('The WEBVIEW model fontSize ${webViewModel.settings?.minimumFontSize}');
    webViewModel.settings?.minimumFontSize = browserModel.fontSize.round();
    browserModel.save();
    print('The WEBVIEW model fontSize 2--- ${webViewModel.settings?.minimumFontSize}');
    browserModel.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(uuid: Uuid().v4(),url: url),
    ));
  }

}
