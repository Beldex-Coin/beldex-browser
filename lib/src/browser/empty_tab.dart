import 'package:beldex_browser/fetch_price.dart';
import 'package:beldex_browser/src/browser/app_bar/sample_popup.dart';
import 'package:beldex_browser/src/browser/webview_tab.dart';
import 'package:beldex_browser/src/providers.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'models/browser_model.dart';
import 'models/webview_model.dart';

class EmptyTab extends StatefulWidget {
  const EmptyTab({Key? key}) : super(key: key);

  @override
  State<EmptyTab> createState() => _EmptyTabState();
}

class _EmptyTabState extends State<EmptyTab> {

@override
  void initState() {
    var browserModel = Provider.of<BrowserModel>(context,listen: false);
    if(browserModel.webViewTabs.isEmpty){
      clearCookie();
    }
    
    super.initState();
  }

final List<Map<String, String>> items = [
    {'image': 'assets/images/Beldex_logo.svg', 
     'label': 'beldex.bdx',
     'link':'http://official.bdx/'},
    {'image': 'assets/images/BChat.svg', 
     'label': 'bchat.bdx',
     'link':'http://bchat.bdx/'},
    {'image': 'assets/images/belnet.svg', 
     'label': 'belnet.bdx', 
     'link':'http://belnet.bdx/'},
    {'image': 'assets/images/browser.svg', 
     'label': 'Beldex Browser.bdx',
     'link': 'http://browser.bdx/'},
     {'image': 'assets/images/BNS.svg',
     'label': 'bns.bdx', 
     'link': 'http://bns.bdx/',
    //  'darkImage': 'assets/images/bridge_dark.svg',
    //  'lightImage': 'assets/images/bridge_wht_theme.svg',
     },
    {'image': 'assets/images/explorer_dark.svg', 
     'label': 'Beldex explorer.bdx',
     'link': 'http://explorer.bdx/',
     'darkImage': 'assets/images/explorer_dark.svg',
     'lightImage': 'assets/images/explorer_wht_theme.svg',
     },
    
  ];


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
     final priceValueProvider = Provider.of<PriceValueProvider>(context);
    return Scaffold(
     // backgroundColor: Color(0xff171720),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical:15.0,horizontal: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                 //themeProvider.darkTheme ?
                  Padding(
                    padding: const EdgeInsets.only(top:30.0),
                    child: SvgPicture.asset('assets/images/browser-name-banner.svg',width: constraints.maxWidth/1.5,),
                  ),
                  const SizedBox(height: 50,),
                  Container(
                    height: 55,
                    decoration: BoxDecoration( 
                      color: themeProvider.darkTheme ? Color(0xff282836) : Color(0xffF3F3F3),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right:5.0),
                              child: Text('1.0000',style: TextStyle(fontWeight: FontWeight.bold),),
                            ),
                             Container(
                          padding: EdgeInsets.symmetric(vertical: 5,horizontal: 15),
                          decoration: BoxDecoration(
                            color: themeProvider.darkTheme ? Color(0xff171720) : Color(0xffFFFFFF),
                            borderRadius: BorderRadius.circular(18)
                          ),
                          child: Text('BDX',style: TextStyle(color: Color(0xff00BD40),fontWeight: FontWeight.bold),),

                        ),
                          ],
                        ),
                       
                        Text('=', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                         Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right:5.0),
                              child: Text('${priceValueProvider.value.toStringAsFixed(4)}',style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              ),
                            ),
                             Container(
                          padding: EdgeInsets.symmetric(vertical: 5,horizontal: 15),
                          decoration: BoxDecoration(
                            color: themeProvider.darkTheme ? Color(0xff171720) : Color(0xffFFFFFF),
                            borderRadius: BorderRadius.circular(18)
                          ),
                          child: Text('USDT',style: TextStyle(fontWeight: FontWeight.bold),),

                        ),
                          ],
                        ),

                      ],
                    ),
                  ),
                const SizedBox(height: 40),
                 Expanded(
                   child: Container(
                    height: 310,
                   // color: Colors.green,
                    padding: EdgeInsets.only(top:8),
                     child: GridView.builder(
                       itemCount: items.length,
                       physics: ClampingScrollPhysics(),
                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                         crossAxisCount: 3,
                        // crossAxisSpacing: 15,
                         mainAxisSpacing: 10,
                         mainAxisExtent: 130
                       ),
                       itemBuilder: (context, index) {
                         return ItemListWidget(
                           imagePath: items[index]['image']!,
                           label: items[index]['label']!,
                           darkImagePath: items[index]['darkImage'],
                           lightImagePath: items[index]['lightImage'],
                           link: items[index]['link']!,
                         );
                       },
                     ),
                   ),
                 ),
              
                 // : SvgPicture.asset('assets/images/Beldex_small_splash_white.svg',width: constraints.maxWidth,height: constraints.maxHeight/1.2,)
                  
                ],
              ),
            );
          }
        ),
      ),
    );
  }

  void openNewTab(value) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();

    browserModel.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(
          url: WebUri(value.startsWith("http")
              ? value
              : settings.searchEngine.searchUrl + value)),
    ));
  }
}


class ItemListWidget extends StatelessWidget {
  final String imagePath;
  final String label;
  final String? darkImagePath;
  final String? lightImagePath;
  final String link;

  ItemListWidget({
    required this.imagePath,
    required this.label,
    this.darkImagePath,
    this.lightImagePath, required this.link,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Provider.of<DarkThemeProvider>(context).darkTheme;
    final vpnStatusProvider = Provider.of<VpnStatusProvider>(context);
    final displayImagePath = (isDarkTheme && darkImagePath != null)
        ? darkImagePath!
        : (isDarkTheme ? imagePath : (lightImagePath ?? imagePath));

    return GestureDetector(
      onTap: (){
       vpnStatusProvider.updateCanShowHomeScreen(false);
       addNewTab(context,url: WebUri(link));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal:8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkTheme ? Color(0xff282836) : Color(0xffF3F3F3)
              ),
              child: SvgPicture.asset(
                displayImagePath,
                // width: 50,
                // height: 50,
              ),
            ),
           SizedBox(height: 8),
            Expanded(
              child: Container(
                //color: Colors.green,
                child: Text(
                  label,
                  style: TextStyle(fontSize: 12, color: isDarkTheme ? Color(0xff9595B5) : Color(0xff9595B5)),
                  maxLines: 3,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
           // SizedBox(height: 10,)
          ],
        ),
      ),
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
      webViewModel: WebViewModel(url: url),
    ));
  }

}
