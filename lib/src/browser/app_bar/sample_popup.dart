import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/search_engine_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/pages/search_engine/add_searchEnging_screen.dart';
import 'package:beldex_browser/src/browser/pages/search_engine/add_searchengine_provider.dart';
import 'package:beldex_browser/src/browser/pages/search_engine/searchengine_icon_placeholder.dart';
import 'package:beldex_browser/src/browser/pages/settings/search_settings_page.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:beldex_browser/src/widget/text_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

//class SelectedItemsProvider extends ChangeNotifier {
//   List<int> _selectedItems = [];

//   List<int> get selectedItems => _selectedItems;

//   List<Item> items = [
//     Item('This time Search in', ''),
//     Item('Beldex Search Engine', 'assets/images/Beldex_logo_svg 1.svg'),
//     Item('Google', 'assets/images/Google 1.svg'),
//     Item('DuckDuckGo', 'assets/images/DuckDuckGo 2.svg'),
//     Item('Yahoo', 'assets/images/Yahoo 1.svg'),
//     Item('Bing', 'assets/images/Bing 1.svg'),
//     Item('Ecosia search engine', 'assets/images/Ecosia.svg'),
//     Item('Baidu', 'assets/images/Baidu.svg'),
//     Item('Yandex', 'assets/images/Yandex.svg'),
//     Item('Youtube', 'assets/images/youtube.svg'),
//     Item('Twitter', 'assets/images/twitter 1.svg'),
//     Item('Wikipedia', 'assets/images/Wikipedia 1.svg'),
//     Item('Reddit', 'assets/images/Reddit 1.svg'),
//     Item('Search setting', 'assets/images/settings.svg')
//     // Item('Search setting','assets/images/settings.svg')
//     // Add more items as needed
//   ];

//  // late SharedPreferences _prefs;
//   String _value = 'assets/images/Google 1.svg';
//    double _fontSize = 8.0;
//   SelectedItemsProvider() {
//     initSharedPreferences();
//   }

//   String get value => _value;
//   double get fontSize => _fontSize;
//   Future<void> initSharedPreferences() async {
//    final _prefs = await SharedPreferences.getInstance();
//     String? storedValue = _prefs.getString('icon_value');
//     if (storedValue != null) {
//       _value = storedValue;
//       notifyListeners();
//     }
//      double? storedFontSize = _prefs.getDouble('fontSize');
//     if(storedFontSize != null){
//       _fontSize = storedFontSize;
//       notifyListeners();
//     }
//   }


//  void updateFontSize(double fontSizes)async{
//   final _prefs = await SharedPreferences.getInstance();
//   _fontSize = fontSizes;
//   notifyListeners();
//   await _prefs.setDouble('fontSize', fontSizes);
//  }



//   Future<void> updateIconValue(String newvalue) async {
//     final _prefs = await SharedPreferences.getInstance();
//     _value = newvalue;
//     notifyListeners();
//     await _prefs.setString('icon_value', newvalue);
//   }

// void updateIconWhenNotSerchEngine() async {
//     final _prefs = await SharedPreferences.getInstance();
//     final value = _prefs.getString('icon_value');
//     if(value == 'assets/images/youtube.svg' ||value == 'assets/images/Reddit 1.svg' || value == 'assets/images/Wikipedia 1.svg' || value == 'assets/images/twitter 1.svg'){
//       _value = 'assets/images/Google 1.svg';
//       notifyListeners();
//      await _prefs.setString('icon_value', _value);
//     }
   
//   }
//   void initializeSelectedItems() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String>? selectedItemsStr = prefs.getStringList('selectedItems');
//     if (selectedItemsStr != null) {
//       _selectedItems = selectedItemsStr.map((e) => int.parse(e)).toList();
//       notifyListeners();
//     } else {
//       _selectedItems = [0, 2, 3, 4, 5, 6, 8, 9, 11,13]; // Default selected indices
//       prefs.setStringList(
//           'selectedItems', _selectedItems.map((e) => e.toString()).toList());
//       notifyListeners();
//     }
//   }

//   void toggleItem(int index) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     if (_selectedItems.contains(index)) {
//       _selectedItems.remove(index);
//     } else {
//       _selectedItems.add(index);
//       _selectedItems.sort();
//     }

//     prefs.setStringList(
//         'selectedItems', _selectedItems.map((e) => e.toString()).toList());
//     notifyListeners();
//   }



  
//}


class ItemsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
   // final provider = Provider.of<SelectedItemsProvider>(context);
    final loc = AppLocalizations.of(context)!;
    final addEngineProvider =
    Provider.of<AddSearchEngineProvider>(context);
final sessionEngines = addEngineProvider.sessionSearchEngines;
final browserModel = Provider.of<BrowserModel>(context);
final settings = browserModel.getSettings();

    return Scaffold(
        appBar: normalAppBar(context, loc.manageSearchShortcuts, themeProvider),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(loc.engineVisibleOnSearchMenu,
                  //'Engine visible on the search menu',
                  style: TextStyle(
                      color: const Color(0xff00BD40),
                      fontSize: 17,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: themeProvider.darkTheme
                          ?const Color(0xff292937)
                          : const Color(0xffF3F3F3)),
                  padding:const EdgeInsets.only(
                      left: 15.0,
                      right: 15,
                      bottom: 20),
                  child: SingleChildScrollView(
                    child: Container(
                      child: 
                      ListView.builder(
  padding: EdgeInsets.zero,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount:
      browserModel.items.length + sessionEngines.length + 1,
  itemBuilder: (context, index) {

    /// ---------------- ADD SEARCH ENGINE BUTTON (LAST) ----------------
    if (index ==
        browserModel.items.length + sessionEngines.length) {
      return ListTile(
        onTap: () {
          
              Navigator.push(context,MaterialPageRoute(builder: (context)=> AddSearchEngineScreen()));
              // your action to open "Add search engine" screen
              print("Add Search Engine Clicked");
            
          // open add search engine screen
        },
        leading: const Icon(Icons.add,
            size: 18, color: Color(0xff00B134)),
        title: Text(
          loc.addSearchEngine,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Color(0xff00B134)
          ),
        ),
      );
    }

    /// ---------------- FIRST LIST ----------------
    if (index < browserModel.items.length) {
      final item = browserModel.items[index];

      if (item.name == 'This time Search in' ||
          item.name == 'Search setting' ||
          item.name == 'Beldex Search Engine') {
        return const SizedBox();
      }

      final actualIndex = index + (index >= 13 ? 2 : 0);

      return ListTile(
        leading: Container(
          height: 15,
          width: 15,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: browserModel.selectedItems.contains(index)
                  ? const Color(0xff00B134)
                  : themeProvider.darkTheme
                      ? Colors.white
                      : Colors.black,
            ),
          ),
          child: browserModel.selectedItems.contains(index)
              ? SvgPicture.asset(
                  'assets/images/tick.svg',
                  fit: BoxFit.cover,
                )
              : const SizedBox(),
        ),
        minLeadingWidth: 15,
        onTap: () => browserModel.toggleItem(index),
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: SvgPicture.asset(
                item.imageUrl,
                height: item.imageUrl ==
                        'assets/images/youtube.svg'
                    ? 18
                    : 22,
                width: item.imageUrl ==
                        'assets/images/youtube.svg'
                    ? 18
                    : 22,
                color: (actualIndex >= 10 &&
                        actualIndex <= 13)
                    ? themeProvider.darkTheme
                        ? Colors.white
                        : Colors.black
                    : null,
              ),
            ),
            Text(
              item.name,
              style: TextStyle(
                fontSize: 17,
                color: themeProvider.darkTheme
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    /// ---------------- SECOND LIST (SESSION ENGINES) ----------------
    final engineIndex = index - browserModel.items.length;
    final engine = sessionEngines[engineIndex];

return ListTile(
        leading: Container(
          height: 15,
          width: 15,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: addEngineProvider.selectedSessionEngines.contains(engine)
                  ? const Color(0xff00B134)
                  : themeProvider.darkTheme
                      ? Colors.white
                      : Colors.black,
            ),
          ),
          child: addEngineProvider.selectedSessionEngines.contains(engine)
              ? SvgPicture.asset(
                  'assets/images/tick.svg',
                  fit: BoxFit.cover,
                )
              : const SizedBox(),
        ),
        minLeadingWidth: 15,
        onTap: ()=> addEngineProvider.toggleSessionEngine(engine),// => provider.toggleItem(index),
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: CachedNetworkImage(
                            imageUrl: engine.assetIcon,
                            width: 20,
                            height: 20,
                            errorWidget: (_, __, ___) => SearchEnginePlaceholder(name:engine.name,size: 20,),
                          )// Icon(Icons.public, size: 18)
              // SvgPicture.asset(
              //   item.imageUrl,
              //   height: item.imageUrl ==
              //           'assets/images/youtube.svg'
              //       ? 18
              //       : 22,
              //   width: item.imageUrl ==
              //           'assets/images/youtube.svg'
              //       ? 18
              //       : 22,
              //   color: (actualIndex >= 10 &&
              //           actualIndex <= 13)
              //       ? themeProvider.darkTheme
              //           ? Colors.white
              //           : Colors.black
              //       : null,
              // ),
            ),
            Text(
              engine.name,
              style: TextStyle(
                fontSize: 17,
                color: themeProvider.darkTheme
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
               color: themeProvider.darkTheme ? const Color(0xff282836) : const Color(0xffF3F3F3),
                  surfaceTintColor:
            themeProvider.darkTheme ? const Color(0xff282836) :const Color(0xffF3F3F3),
                  elevation: 14,
            onSelected: (value) {
              // final engine =
              //     addSearchEngineProvider.allEngines[index];
            
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddSearchEngineScreen(editEngine: engine),
                  ),
                );
              }
            
              if (value == 'delete') {
               addEngineProvider.removeSessionEngineIfSelected(engine);
                addEngineProvider.removeSearchEngine(engine,settings,browserModel);
            
                /// If deleted engine was selected → reset to Google
                if (engine.name == settings.searchEngine.name) {
                  settings.searchEngine = GoogleSearchEngine;
                  browserModel.updateSettings(settings);
                  browserModel.updateIconValue(GoogleSearchEngine.assetIcon);
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text(loc.edit),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18,),
                    SizedBox(width: 8),
                    Text(loc.delete),
                  ],
                ),
              ),
            ],
                    ),
      );



    
  },
),
                      // ListView.builder(
                      //   padding: EdgeInsets.zero,
                      //   shrinkWrap: true,
                      //   physics: NeverScrollableScrollPhysics(),
                      //   itemCount: provider.items.length - 1, // Exclude two items
                      //   //itemExtent: 43,
                      //   itemBuilder: (context, index) {
                      //     final item = provider.items[index];
                      //     if (item.name != 'This time Search in' &&
                      //         item.name != 'Search setting' &&
                      //         item.name != 'Beldex Search Engine') {
                      //       final actualIndex = index +
                      //           (index >= 13
                      //               ? 2
                      //               : 0); // Adjust index if skipping items
                      //       return ListTile(
                      //         leading: Container(
                                    
                      //           height: 15,
                      //           width: 15,
                      //           decoration: BoxDecoration(
                      //             //color: provider.selectedItems.contains(index) ? const Color(0xff00B134): Colors.transparent,
                      //             borderRadius: BorderRadius.circular(2),
                      //             border: Border.all(color:provider.selectedItems.contains(index) ? const Color(0xff00B134): themeProvider.darkTheme ? Colors.white: Colors.black),
                      //           ),
                      //           child: provider.selectedItems.contains(index)
                      //               ? SvgPicture.asset(
                      //                   'assets/images/tick.svg',
                      //                   fit: BoxFit.cover,
                      //                 )
                      //               : SizedBox(),
                      //         ),
                      //         minLeadingWidth: 15,
                      //         onTap: () {
                      //           provider.toggleItem(index);
                      //         },
                      //         title: Container(
                      //           child: Row(
                      //             children: [
                      //               Padding(
                      //                 padding: const EdgeInsets.only(right: 10.0),
                      //                 child: SvgPicture.asset(
                      //                   item.imageUrl,
                      //                   height: item.imageUrl ==
                      //                           'assets/images/youtube.svg'
                      //                       ? 18
                      //                       : 22,
                      //                   width: item.imageUrl ==
                      //                           'assets/images/youtube.svg'
                      //                       ? 18
                      //                       : 22,
                      //                   color:
                      //                       (actualIndex >= 10 && actualIndex <= 13)
                      //                           ? themeProvider.darkTheme
                      //                               ? Colors.white
                      //                               : Colors.black
                      //                           : null,
                      //                 ),
                      //               ),
                      //               Text(
                      //                 item.name,
                      //                 style: TextStyle(
                      //                   color: themeProvider.darkTheme
                      //                       ? Colors.white
                      //                       : Colors.black,
                      //                   fontSize: 17,
                      //                   fontWeight: FontWeight.normal,
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       );
                      //     } else {
                      //       return SizedBox(); // Return an empty SizedBox for excluded items
                      //     }
                      //   },
                      // ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
        );
  }

  AppBar normalAppBar(
      BuildContext context, String title, DarkThemeProvider themeProvider) {
    return AppBar(
      centerTitle: true,
      leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset(
            'assets/images/back.svg',
            color: themeProvider.darkTheme ? Colors.white :const Color(0xff282836),
            height: 30,
          )),
      title: TextWidget(text:title, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}

class SearchSettingsPopupList extends StatefulWidget {
  final BrowserModel browserModel;
  final BrowserSettings browserSettings;
  const SearchSettingsPopupList(
      {super.key, required this.browserModel, required this.browserSettings});

  @override
  State<SearchSettingsPopupList> createState() =>
      _SearchSettingsPopupListState();
}

class _SearchSettingsPopupListState extends State<SearchSettingsPopupList> {

  void hideFooter(InAppWebViewController? webViewController) {
    print('THE WEB MODEL FROM ----');
    if (webViewController != null) {
      webViewController.evaluateJavascript(source: "hideFooter();");
    }
  }


  @override
  Widget build(BuildContext context) {
    //final provider = Provider.of<SelectedItemsProvider>(context, listen: false);
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    var webViewModel = Provider.of<WebViewModel>(context, listen: true);
    var webViewController = webViewModel.webViewController;
    final loc = AppLocalizations.of(context)!;
        final browserModel = Provider.of<BrowserModel>(context,listen: false);
    final settings = browserModel.getSettings();
    
    final addEngineProvider =
        Provider.of<AddSearchEngineProvider>(context, listen: true);

    final selectedSessionEngines =
        addEngineProvider.selectedSessionEngines;

    return PopupMenuButton<List<int>>(
      offset: Offset(0, 47),
      color: themeProvider.darkTheme ? const Color(0xff282836) : const Color(0xffF3F3F3),
      surfaceTintColor:
          themeProvider.darkTheme ? const Color(0xff282836) :const Color(0xffF3F3F3),
      elevation: 14,
      onOpened: () async {
        await webViewController?.evaluateJavascript(
            source:"document.activeElement.blur();"); //close the search engine keyboard while opening menu list to prevent overlap
              hideFooter(webViewController);
        if (await webViewController?.getSelectedText() != null) {
          await webViewController?.evaluateJavascript(
              source:"window.getSelection().removeAllRanges();"); //close text Selection while opening menu list to prevent overlap
        }
      },
      icon: Container(
        height: 33,
        width: 33,
        decoration: BoxDecoration(
            color:
                themeProvider.darkTheme ?const Color(0xff39394B) :const Color(0xffffffff),
            borderRadius: BorderRadius.circular(5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                 (browserModel.value.startsWith('http://') ||
     browserModel.value.startsWith('https://')) ?
     Image.network(
        browserModel.value,
        width: 20,
        height: 20,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return SearchEnginePlaceholder(
            name: settings.searchEngine.name,
            size: 20,
          );
        },
      )
      //  CachedNetworkImage(
      //       imageUrl: browserModel.value,
      //       width: 20,
      //       height: 20,
      //       errorWidget: (context, url, error) => SearchEnginePlaceholder(name:settings.searchEngine.name,size: 20,),
      //     )
      :
            SvgPicture.asset(
              browserModel.value,
              color: browserModel.value == 'assets/images/Reddit 1.svg' ||
                      browserModel.value == 'assets/images/Wikipedia 1.svg' ||
                      browserModel.value == 'assets/images/twitter 1.svg'
                  ? themeProvider.darkTheme
                      ? Colors.white
                      : Colors.black
                  : null,
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: 10,
              color: themeProvider.darkTheme ? Colors.white : Colors.black,
            )
          ],
        ),
      ),
      shape:const RoundedRectangleBorder(
        borderRadius: BorderRadius.all( Radius.circular(15.0),
        ),
      ),
      onSelected: _searchListActions,
            itemBuilder: (BuildContext context) {
        final List<PopupMenuEntry<List<int>>> menuItems = [];

        final int searchSettingIndex =
            browserModel.items.indexWhere((e) => e.name == 'Search setting');

        /// -------- FIRST LIST --------
        for (final index in browserModel.selectedItems) {
          if (index == searchSettingIndex) continue;

          menuItems.add(
            PopupMenuItem<List<int>>(
              value: [index],
              height: 35,
              child: index == 0
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text('${loc.thistimeSearchIn}:',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  : Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: SvgPicture.asset(
                            browserModel.items[index].imageUrl,
                            color: (index >= 10 && index <= 13)
                                ? themeProvider.darkTheme
                                    ? Colors.white
                                    : Colors.black
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          browserModel.items[index].name,
                          style:
                              Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
            ),
          );
        }

        /// -------- SECOND LIST (SESSION ENGINES) --------
        for (int i = 0; i < selectedSessionEngines.length; i++) {
          final engine = selectedSessionEngines[i];

          menuItems.add(
            PopupMenuItem<List<int>>(
              value: [-1000 - i], // ✅ UNIQUE NEGATIVE VALUE
              height: 35,
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: CachedNetworkImage(
                      imageUrl: engine.assetIcon,
                      width: 20,
                      height: 20,
                      errorWidget: (c, u, e) =>
                          SearchEnginePlaceholder(
                              name: engine.name, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    engine.name,
                    style:
                        Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }

        /// -------- SEARCH SETTING (LAST) --------
        if (browserModel.selectedItems.contains(searchSettingIndex)) {
          menuItems.add(
            PopupMenuItem<List<int>>(
              value: [searchSettingIndex],
              height: 35,
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: SvgPicture.asset(
                        browserModel.items[searchSettingIndex].imageUrl,color: themeProvider.darkTheme ? Colors.white : Colors.black,),
                  ),
                  const SizedBox(width: 8),
                  Text(loc.searchSettings,
                   // provider.items[searchSettingIndex].name,
                    style:
                        Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }

        return menuItems;
      },
    //   itemBuilder: (BuildContext context) {
    //     return provider.selectedItems.map((index) {
    //       return PopupMenuItem<List<int>>(
    //         value: [index],
    //         height: 35,
    //         child: index == 0
    //             ? Row(
    //                 children: [
    //                   Padding(
    //                     padding: const EdgeInsets.only(top: 10.0),
    //                     child: Text(loc.thistimeSearchIn,
    //                      // '${provider.items[index].name}:',
    //                       style: Theme.of(context).textTheme.bodySmall,
    //                     ),
    //                   ),
    //                 ],
    //               )
    //             : Row(
    //                 children: [
    //                   Container(
    //                       width: 30,
    //                       //color: Colors.yellow,
    //                       child: 
    //                       (provider.items[index].imageUrl.startsWith('http://') ||
    //  provider.items[index].imageUrl.startsWith('https://')) ?
    //        CachedNetworkImage(
    //         imageUrl: provider.items[index].imageUrl,
    //         width: 28,
    //         height: 28,
    //         errorWidget: (context, url, error) => SearchEnginePlaceholder(name:settings.searchEngine.name,size: 28,),
    //       )
    //   :  SvgPicture.asset(
    //                         provider.items[index].imageUrl,
    //                         color: index <= 13 && index >= 11 
    //                         //  index == 10 ||
    //                         //         index == 11 ||
    //                         //         index == 12 ||
    //                         //         index == 15
    //                             ? themeProvider.darkTheme
    //                                 ? Colors.white
    //                                 : Colors.black
    //                             : null,
    //                       )),
    //                   Padding(
    //                     padding: const EdgeInsets.only(left: 8.0),
    //                     child: TextWidget(
    //                      text: index == 13 ? loc.searchSettings : provider.items[index].name,
    //                       style: Theme.of(context).textTheme.bodySmall,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //       );
    //     }).toList();
    //   },
    );
  }

   void _searchListActions(List<int> choice) {
    final browserModel = context.read<BrowserModel>();
   // final provider = context.read<SelectedItemsProvider>();
    final addEngineProvider =
        context.read<AddSearchEngineProvider>();
    final settings = browserModel.getSettings();

    final int value = choice.first;

    /// -------- SESSION ENGINE CLICK --------
    if (value <= -1000) {
      final int engineIndex = (-value) - 1000;
      final engine =
          addEngineProvider.selectedSessionEngines[engineIndex];

      settings.searchEngine = engine;
      browserModel.updateSettings(settings);
      browserModel.updateIconValue(engine.assetIcon);

      print('The Selected Engine ----> ${engine.name}');
      return;
    }

    /// -------- EXISTING STATIC LOGIC --------
    switch (value) {
      case 1:
        setState(() {
          settings.searchEngine = SearchEngines[0];
          widget.browserModel.updateSettings(settings);
          WebUri? url;
          url ??= WebUri(settings.searchEngine.url);
              browserModel.updateIconValue('assets/images/Beldex_logo_svg 1.svg');
        });
        break;
      case 2:
        setState(() {
          settings.searchEngine = SearchEngines[0];
          widget.browserModel.updateSettings(settings);
          WebUri? url;
          url ??= WebUri(settings.searchEngine.url);
          browserModel.updateIconValue('assets/images/Google 1.svg');
        });
        break;
      case 3:
        setState(() {
          settings.searchEngine = SearchEngines[3];
          widget.browserModel.updateSettings(settings);
          WebUri? url;
          url ??= WebUri(settings.searchEngine.url);
          widget.browserModel.showTabScroller = false;
          browserModel.updateIconValue('assets/images/DuckDuckGo 2.svg');
        });
        break;
      case 4:
        setState(() {
          settings.searchEngine = SearchEngines[1];
          widget.browserModel.updateSettings(settings);
          WebUri? url;
          url ??= WebUri(settings.searchEngine.url);
          browserModel.updateIconValue('assets/images/Yahoo 1.svg');
        });
        break;
      case 5:
        setState(() {
          settings.searchEngine = SearchEngines[2];
          widget.browserModel.updateSettings(settings);
          WebUri? url;
          url ??= WebUri(settings.searchEngine.url);
          browserModel.updateIconValue('assets/images/Bing 1.svg');
        });
        break;
      case 6:
        setState(() {
          settings.searchEngine = SearchEngines[4];
          widget.browserModel.updateSettings(settings);
          WebUri? url;
          url ??= WebUri(settings.searchEngine.url);
          browserModel.updateIconValue('assets/images/Ecosia.svg');
        });
        break;
        case 7:
        setState(() {
          settings.searchEngine = SearchEngines[5];  // Baidu
          widget.browserModel.updateSettings(settings);
          WebUri? url;
          url ??= WebUri(settings.searchEngine.url);
          widget.browserModel.showTabScroller = false;
          browserModel.updateIconValue('assets/images/Baidu.svg');
        });
        break;
        case 8:
        setState(() {
          settings.searchEngine = SearchEngines[6];   // Yandex
          widget.browserModel.updateSettings(settings);
          WebUri? url;
          url ??= WebUri(settings.searchEngine.url);
          widget.browserModel.showTabScroller = false;
          browserModel.updateIconValue('assets/images/Yandex.svg');
        });
        break;
      case 9:
        setState(() {
          settings.searchEngine = SearchEngineModel(
              name: 'Youtube',
              url: 'https://www.youtube.com/',
              searchUrl: 'https://www.youtube.com/results?search_query=',
              assetIcon: '');
          widget.browserModel.updateSettings(settings);
        });
        browserModel.updateIconValue('assets/images/youtube.svg');
        break;
      case 10:
        setState(() {
          settings.searchEngine = SearchEngineModel(
              name: 'Twitter',
              url: 'https://twitter.com/',
              searchUrl: 'https://www.twitter.com/results?search_query=',
              assetIcon: '');
          widget.browserModel.updateSettings(settings);
        });
        widget.browserModel.showTabScroller = false;
        browserModel.updateIconValue('assets/images/twitter 1.svg');
        break;
      case 11:
        setState(() {
          settings.searchEngine = SearchEngineModel(
              name: 'Wikipedia',
              url: 'https://www.wikipedia.org/',
              searchUrl: 'https://en.wikipedia.org/w/index.php?search=',
              assetIcon: '');
          widget.browserModel.updateSettings(settings);
        });
        browserModel.updateIconValue('assets/images/Wikipedia 1.svg');
        break;
      case 12:
        browserModel.updateIconValue('assets/images/Reddit 1.svg');
        setState(() {
          settings.searchEngine = SearchEngineModel(
              name: 'Reddit',
              url: 'https://www.reddit.com/',
              searchUrl: 'https://www.reddit.com/search/?q=',
              assetIcon: '');
          widget.browserModel.updateSettings(settings);
        });
        break;
      case 13:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => SearchSettingsPage()),
        );
        return;
    }

    browserModel.updateSettings(settings);
  }

  // void _searchListActions(List<int> choice) async {
  //   var browserModel = Provider.of<BrowserModel>(context, listen: false);
  //   var settings = browserModel.getSettings();
  //   var provider = Provider.of<SelectedItemsProvider>(context, listen: false);
  //   switch (choice.first) {
  //     case 1:
  //       setState(() {
  //         settings.searchEngine = SearchEngines[0];
  //         widget.browserModel.updateSettings(settings);
  //         WebUri? url;
  //         url ??= WebUri(settings.searchEngine.url);
  //             provider.updateIconValue('assets/images/Beldex_logo_svg 1.svg');
  //       });
  //       break;
  //     case 2:
  //       setState(() {
  //         settings.searchEngine = SearchEngines[0];
  //         widget.browserModel.updateSettings(settings);
  //         WebUri? url;
  //         url ??= WebUri(settings.searchEngine.url);
  //         provider.updateIconValue('assets/images/Google 1.svg');
  //       });
  //       break;
  //     case 3:
  //       setState(() {
  //         settings.searchEngine = SearchEngines[3];
  //         widget.browserModel.updateSettings(settings);
  //         WebUri? url;
  //         url ??= WebUri(settings.searchEngine.url);
  //         widget.browserModel.showTabScroller = false;
  //         provider.updateIconValue('assets/images/DuckDuckGo 2.svg');
  //       });
  //       break;
  //     case 4:
  //       setState(() {
  //         settings.searchEngine = SearchEngines[1];
  //         widget.browserModel.updateSettings(settings);
  //         WebUri? url;
  //         url ??= WebUri(settings.searchEngine.url);
  //         provider.updateIconValue('assets/images/Yahoo 1.svg');
  //       });
  //       break;
  //     case 5:
  //       setState(() {
  //         settings.searchEngine = SearchEngines[2];
  //         widget.browserModel.updateSettings(settings);
  //         WebUri? url;
  //         url ??= WebUri(settings.searchEngine.url);
  //         provider.updateIconValue('assets/images/Bing 1.svg');
  //       });
  //       break;
  //     case 6:
  //       setState(() {
  //         settings.searchEngine = SearchEngines[4];
  //         widget.browserModel.updateSettings(settings);
  //         WebUri? url;
  //         url ??= WebUri(settings.searchEngine.url);
  //         provider.updateIconValue('assets/images/Ecosia.svg');
  //       });
  //       break;
  //        case 7:
  //       setState(() {
  //         settings.searchEngine = SearchEngines[5];  // Baidu
  //         widget.browserModel.updateSettings(settings);
  //         WebUri? url;
  //         url ??= WebUri(settings.searchEngine.url);
  //         widget.browserModel.showTabScroller = false;
  //         provider.updateIconValue('assets/images/Baidu.svg');
  //       });
  //       break;
  //       case 8:
  //       setState(() {
  //         settings.searchEngine = SearchEngines[6];   // Yandex
  //         widget.browserModel.updateSettings(settings);
  //         WebUri? url;
  //         url ??= WebUri(settings.searchEngine.url);
  //         widget.browserModel.showTabScroller = false;
  //         provider.updateIconValue('assets/images/Yandex.svg');
  //       });
  //       break;
  //     case 9:
  //       setState(() {
  //         settings.searchEngine = SearchEngineModel(
  //             name: 'Youtube',
  //             url: 'https://www.youtube.com/',
  //             searchUrl: 'https://www.youtube.com/results?search_query=',
  //             assetIcon: '');
  //         widget.browserModel.updateSettings(settings);
  //       });
  //       provider.updateIconValue('assets/images/youtube.svg');
  //       break;
  //     case 10:
  //       setState(() {
  //         settings.searchEngine = SearchEngineModel(
  //             name: 'Twitter',
  //             url: 'https://twitter.com/',
  //             searchUrl: 'https://www.twitter.com/results?search_query=',
  //             assetIcon: '');
  //         widget.browserModel.updateSettings(settings);
  //       });
  //       widget.browserModel.showTabScroller = false;
  //       provider.updateIconValue('assets/images/twitter 1.svg');
  //       break;
  //     case 11:
  //       setState(() {
  //         settings.searchEngine = SearchEngineModel(
  //             name: 'Wikipedia',
  //             url: 'https://www.wikipedia.org/',
  //             searchUrl: 'https://en.wikipedia.org/w/index.php?search=',
  //             assetIcon: '');
  //         widget.browserModel.updateSettings(settings);
  //       });
  //       provider.updateIconValue('assets/images/Wikipedia 1.svg');
  //       break;
  //     case 12:
  //       provider.updateIconValue('assets/images/Reddit 1.svg');
  //       setState(() {
  //         settings.searchEngine = SearchEngineModel(
  //             name: 'Reddit',
  //             url: 'https://www.reddit.com/',
  //             searchUrl: 'https://www.reddit.com/search/?q=',
  //             assetIcon: '');
  //         widget.browserModel.updateSettings(settings);
  //       });
  //       break;
  //     case 13:
  //       Navigator.push(context,
  //           MaterialPageRoute(builder: (context) => SearchSettingsPage()));
  //       break;
  //   }
  // }
}

class Item {
  final String name;
  final String imageUrl;

  Item(this.name, this.imageUrl);
}
