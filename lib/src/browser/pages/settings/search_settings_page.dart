import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/src/browser/app_bar/sample_popup.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/pages/search_engine/add_searchEnging_screen.dart';
import 'package:beldex_browser/src/browser/pages/search_engine/add_searchengine_provider.dart';
import 'package:beldex_browser/src/browser/pages/search_engine/searchengine_icon_placeholder.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/search_engine_model.dart';

// Model for search shortcuts list items

class SearchShortcutListModel {
  final String name;
  final String url;
  final String searchUrl;
  final String assetIcon;
  bool isActive;

  SearchShortcutListModel({
    required this.name,
    required this.url,
    required this.searchUrl,
    required this.assetIcon,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'searchUrl': searchUrl,
      'assetIcon': assetIcon,
      'isActive': isActive,
    };
  }

  // Create an object from JSON
  factory SearchShortcutListModel.fromJson(Map<String, dynamic> json) {
    return SearchShortcutListModel(
      name: json['name'],
      url: json['url'],
      searchUrl: json['searchUrl'],
      assetIcon: json['assetIcon'],
      isActive: json['isActive'],
    );
  }
}

class SearchSettingsPage extends StatefulWidget {
  const SearchSettingsPage({super.key});

  @override
  State<SearchSettingsPage> createState() => _SearchSettingsPageState();
}

class _SearchSettingsPageState extends State<SearchSettingsPage> {

  @override
  Widget build(BuildContext context) {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    var settings = browserModel.getSettings();
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      //backgroundColor: Color(0xff171720),
      appBar: normalAppBar(context, loc.search, themeProvider),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(loc.searchEngine,
                style: TextStyle(
                    color: Color(0xff00BD40),
                    fontSize: 17,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                  height: 158,
                  padding:
                     const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 15),
                  decoration: BoxDecoration(
                      color: themeProvider.darkTheme
                          ?const Color(0xff292937)
                          :const Color(0xffF3F3F3),
                      borderRadius: BorderRadius.circular(15.0)),
                  child:
                      // LayoutBuilder(builder: ((context, constraints) {
                      //   return
                      Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: ListTile(
                          //contentPadding: EdgeInsets.symmetric(vertical: 5),
                          leading: SvgPicture.asset(
                            'assets/images/find_on_page.svg',
                            color: themeProvider.darkTheme
                                ? Colors.white
                                : Colors.black,
                          ),
                          title: Text(loc.defaultSearchEngine,
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.normal),
                          ),
                          subtitle: Text(settings.searchEngine.name,
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w400)),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => DefaultSearchEngine()))),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: ListTile(
                          leading: SvgPicture.asset(
                            'assets/images/shortcut.svg',
                            color: themeProvider.darkTheme
                                ? Colors.white
                                : Colors.black,
                          ),
                          title:  Text(loc.manageSearchShortcuts,
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.normal),
                          ),
                          subtitle: Text(loc.editEnginesVisible,
                              //'Edit engines visible in the search menu',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w400)),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ItemsScreen())),
                        ),
                      ),
                    ],
                  )
                  //}))
              
                  ),
            ),
            Expanded(
              flex: 4,
              child: Container())
          ],
        ),
      ),
    );
  }
}

AppBar normalAppBar(
    BuildContext context, String title, DarkThemeProvider themeProvider) {
      final theme = Theme.of(context);
  return AppBar(
    centerTitle: true,
    leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: SvgPicture.asset(
          'assets/images/back.svg',
          color: themeProvider.darkTheme ? Colors.white :const Color(0xff282836),
          height: 30,
        )),
    title: Text(title, style: theme.textTheme.bodyLarge),
  );
}

class DefaultSearchEngine extends StatefulWidget {
  const DefaultSearchEngine({super.key});

  @override
  State<DefaultSearchEngine> createState() => _DefaultSearchEngineState();
}

class _DefaultSearchEngineState extends State<DefaultSearchEngine> {
  @override
  Widget build(BuildContext context) {
    final browserModel = Provider.of<BrowserModel>(context, listen: true);
    var settings = browserModel.getSettings();
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      //backgroundColor: Color(0xff171720),
      appBar: normalAppBar(context, loc.defaultSearchEngine, themeProvider),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
              child: Text(loc.selectOne,
                style: TextStyle(
                    color: Color(0xff00BD40),
                    fontSize: 17,
                    fontWeight: FontWeight.w500),
              ),
            ),
            defaultSearchEngineList(themeProvider)
          ],
        ),
      ),
    );
  }

Container defaultSearchEngineList(DarkThemeProvider themeProvider) {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    var settings = browserModel.getSettings();
    //var provider = Provider.of<SelectedItemsProvider>(context,listen: false);
    final addSearchEngineProvider = Provider.of<AddSearchEngineProvider>(context,listen: true);
    final loc = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color:
              themeProvider.darkTheme ? Color(0xff292937) : Color(0xffF3F3F3)),
      padding: EdgeInsets.only(left: 15.0, right: 15, top: 15, bottom: 20),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount:addSearchEngineProvider.allEngines.length + 1,  //SearchEngines.length + 1,
        itemExtent: 43,
        itemBuilder: (context, index) {
             if (index == addSearchEngineProvider.allEngines.length //SearchEngines.length
             ) {
          return InkWell(
            onTap: () {
              Navigator.push(context,MaterialPageRoute(builder: (context)=> AddSearchEngineScreen()));
              // your action to open "Add search engine" screen
              print("Add Search Engine Clicked");
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Icon(Icons.image,size: 22,color: Colors.transparent,
                      
                    ),
                  ),
                  Icon(Icons.add,size: 15, color: Color(0xff00BD40)),
                  SizedBox(width: 3),
                  Text( loc.addSearchEngine,
                    //"Add Search Engine",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xff00BD40),
                    ),
                  )
                ],
              ),
            ),
          );
        }
          bool isSelected = false;
          // setState(() {
          isSelected = addSearchEngineProvider.allEngines[index].name == settings.searchEngine.name  //SearchEngines[index].name == settings.searchEngine.name
              ? true
              : false;
          //});
           // final bool isNetwork = SearchEnginesIcons[index].startsWith('http://') || SearchEnginesIcons[index].startsWith('https://');
          return ListTile(
            leading: Container(
              height: 15,
              width: 15,
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xff00B134))),
              child: isSelected
                  ? Container(
                      decoration: BoxDecoration(
                          color:const Color(0xff00B134), shape: BoxShape.circle),
                    )
                  : SizedBox(),
            ),
            minLeadingWidth: 15,
            onTap: () {
              setState(() {
                isSelected = true;
                // if (SearchEngines.isNotEmpty) {
                //   settings.searchEngine = SearchEngines[index];
                // }
               if(addSearchEngineProvider.allEngines.isNotEmpty){
                settings.searchEngine = addSearchEngineProvider.allEngines[index];
               }
                browserModel.updateSettings(settings);
              });

              browserModel.updateIconValue(addSearchEngineProvider.allEngines[index].assetIcon);
              // if(index == 0){
              //    provider.updateIconValue('assets/images/Google 1.svg');
              // }else if(index == 1){
              //    provider.updateIconValue('assets/images/Yahoo 1.svg');
              // }else if(index == 2){
              //   provider.updateIconValue('assets/images/Bing 1.svg');
              // }else if(index == 3){
              //   provider.updateIconValue('assets/images/DuckDuckGo 2.svg');
              // }else if(index == 4){
              //   provider.updateIconValue('assets/images/Ecosia.svg');
              // }else if(index == 5){
              //   provider.updateIconValue('assets/images/DuckDuckGo 2.svg');
              // }else if(index == 6){
              //   provider.updateIconValue('assets/images/DuckDuckGo 2.svg');
              // }
             
            },
            title: Container(
              //color: Colors.yellow,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: buildIcon(addSearchEngineProvider.allEngines[index].assetIcon,addSearchEngineProvider.allEngines[index].name)
                    //  SvgPicture.asset(
                    //   SearchEnginesIcons[index],
                    //   height: 22,
                    //   width: 22,
                    // ),
                  ),
                  Text(
                   addSearchEngineProvider.allEngines[index].name, //SearchEngines[index].name,
                    style: TextStyle(
                        color: themeProvider.darkTheme
                            ? Colors.white
                            : Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            trailing: addSearchEngineProvider
          .isUserEngine(addSearchEngineProvider.allEngines[index]) ? Semantics(
            label: 'options',
            child: PopupMenuButton<String>(
               color: themeProvider.darkTheme ? const Color(0xff282836) : const Color(0xffF3F3F3),
                  surfaceTintColor:
            themeProvider.darkTheme ? const Color(0xff282836) :const Color(0xffF3F3F3),
                  elevation: 14,
            onSelected: (value) {
              final engine =
                  addSearchEngineProvider.allEngines[index];
            
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
                addSearchEngineProvider.removeSearchEngine(engine,settings,browserModel);
            
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
          ): SizedBox.shrink(),
          );
        },
      ),
    );
  }

Widget buildIcon(String iconPath,String name, {double size = 24}) {
  final bool isNetwork = iconPath.startsWith('http://') || iconPath.startsWith('https://');
  print('PLACEHOLDER ITEM ----> $iconPath');
  if (isNetwork) {
    print('PLACEHOLDER ITEM IFF----> $iconPath');
    return 
    CachedNetworkImage(
                            imageUrl: iconPath,
                            width: 22,
                            height: 22,
                            errorWidget: (_, __, ___) => SearchEnginePlaceholder(name: name,size: 20,) //const Icon(Icons.public),
                          );
    
    
    // CachedNetworkImage(
    //   imageUrl: iconPath,
    //   width: size,
    //   height: size,
    //   placeholder: (context, url) => const SizedBox(
    //     width: 20,
    //     height: 20,
    //     child: CircularProgressIndicator(strokeWidth: 2),
    //   ),
    //   errorWidget: (context, url, error) => const Icon(Icons.error),
    // );
  } else {
    print('PLACEHOLDER ITEM ElSE----> $iconPath');
    return SvgPicture.asset(
                      iconPath,
                      height: 22,
                      width: 22,
                    );

  }
}
  // Container defaultSearchEngineList(DarkThemeProvider themeProvider) {
  //   var browserModel = Provider.of<BrowserModel>(context, listen: true);
  //   var settings = browserModel.getSettings();
  //   var provider = Provider.of<SelectedItemsProvider>(context,listen: false);
  //   return Container(
  //     decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(15.0),
  //         color:
  //             themeProvider.darkTheme ? Color(0xff292937) : Color(0xffF3F3F3)),
  //     padding: EdgeInsets.only(left: 15.0, right: 15, top: 15, bottom: 20),
  //     child: ListView.builder(
  //       shrinkWrap: true,
  //       physics: NeverScrollableScrollPhysics(),
  //       itemCount: SearchEngines.length,
  //       itemExtent: 43,
  //       itemBuilder: (context, index) {
  //         bool isSelected = false;
  //         // setState(() {
  //         isSelected = SearchEngines[index].name == settings.searchEngine.name
  //             ? true
  //             : false;
  //         //});
  //         return ListTile(
  //           leading: Container(
  //             height: 15,
  //             width: 15,
  //             padding: EdgeInsets.all(2),
  //             decoration: BoxDecoration(
  //                 shape: BoxShape.circle,
  //                 border: Border.all(color: Color(0xff00B134))),
  //             child: isSelected
  //                 ? Container(
  //                     decoration: BoxDecoration(
  //                         color:const Color(0xff00B134), shape: BoxShape.circle),
  //                   )
  //                 : SizedBox(),
  //           ),
  //           minLeadingWidth: 15,
  //           onTap: () {
  //             setState(() {
  //               isSelected = true;
  //               if (SearchEngines.isNotEmpty) {
  //                 settings.searchEngine = SearchEngines[index];
  //               }
  //               browserModel.updateSettings(settings);
  //             });
  //             if(index == 0){
  //                provider.updateIconValue('assets/images/Google 1.svg');
  //             }else if(index == 1){
  //                provider.updateIconValue('assets/images/Yahoo 1.svg');
  //             }else if(index == 2){
  //               provider.updateIconValue('assets/images/Bing 1.svg');
  //             }else if(index == 3){
  //               provider.updateIconValue('assets/images/DuckDuckGo 2.svg');
  //             }else if(index == 4){
  //               provider.updateIconValue('assets/images/Ecosia.svg');
  //             }
             
  //           },
  //           title: Container(
  //             //color: Colors.yellow,
  //             child: Row(
  //               children: [
  //                 Padding(
  //                   padding: const EdgeInsets.only(right: 10.0),
  //                   child: SvgPicture.asset(
  //                     SearchEnginesIcons[index],
  //                     height: 22,
  //                     width: 22,
  //                   ),
  //                 ),
  //                 Text(
  //                   SearchEngines[index].name,
  //                   style: TextStyle(
  //                       color: themeProvider.darkTheme
  //                           ? Colors.white
  //                           : Colors.black,
  //                       fontSize: 17,
  //                       fontWeight: FontWeight.normal),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  // Widget defaultSearchEngineListview(BoxConstraints constraints) {
  //    var browserModel = Provider.of<BrowserModel>(context, listen: true);
  //   var settings = browserModel.getSettings();
  //   return ListView.builder(
  //     itemCount: SearchEngines.length,
  //     padding: EdgeInsets.all(5),
  //    // shrinkWrap: true,
  //     itemBuilder: ((context, index) {
  //             return Container(
  //               color: Colors.yellow,
  //               height: constraints.,
  //               child: ListTile(
  //                // minVerticalPadding:5,
  //                   title: Text(SearchEngines[index].name,style: TextStyle(color: Colors.white),),
  //               ),
  //             );
  //           }));
  // }
}

class SearchShortcuts extends StatefulWidget {
  const SearchShortcuts({super.key});

  @override
  State<SearchShortcuts> createState() => _SearchShortcutsState();
}

class _SearchShortcutsState extends State<SearchShortcuts> {
  List<SearchShortcutListModel> searchShortcutItems = [
    // SearchShortcutListModel(
    //   name: 'Search settings',
    //   url: '',
    //   searchUrl: '',
    //   assetIcon: 'assets/images/settings.svg',
    //   isActive: true,
    // ),
  ];

  @override
  void initState() {
    loadSearchShortcutListItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      //backgroundColor: Color(0xff171720),
      appBar: normalAppBar(context,loc.manageSearchShortcuts, themeProvider),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
              child: Text(loc.engineVisibleOnSearchMenu,
               // 'Engine visible on the search menu',
                style: TextStyle(
                    color: Color(0xff00BD40),
                    fontSize: 17,
                    fontWeight: FontWeight.w500),
              ),
            ),
          // manageShortcuts(themeProvider),
            manageSearchShortcuts(themeProvider)
          ],
        ),
      ),
    );
  }

  Container manageShortcuts(DarkThemeProvider themeProvider){
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color:
              themeProvider.darkTheme ?const Color(0xff292937) :const Color(0xffF3F3F3)),
      padding: EdgeInsets.only(left: 15.0, right: 15, //top: 15,
       bottom: 20),);

  }

  Container manageSearchShortcuts(DarkThemeProvider themeProvider) {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    var settings = browserModel.getSettings();

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color:
              themeProvider.darkTheme ?const Color(0xff292937) :const Color(0xffF3F3F3)),
      padding: EdgeInsets.only(left: 15.0, right: 15, //top: 15,
       bottom: 20),
      child: Container(
        //color: Colors.yellow,
        child: ListView.builder(
          //padding: EdgeInsets.,
          
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: searchShortcutItems.length,
          itemExtent: 43,
          itemBuilder: (context, index) {
           var item = searchShortcutItems[index];
             bool isSelected = false;
            // //  setState(() {
             isSelected = item.isActive;
            // // });
        
            return item.name == 'Search settings' ? Container(
              height: 5,
              //color: Colors.green,
              ) : ListTile(
              leading: Container(
                height: 15, width: 15,
                //padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                    //shape: BoxShape.circle,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: Color(0xff00B134))),
                child: item.isActive
                    ? SvgPicture.asset(
                        'assets/images/tick.svg',
                        fit: BoxFit.cover,
                      )
                    : SizedBox(),
              ),
              minLeadingWidth: 15,
              onTap: () {
                setState(() {
                      isSelected = isSelected ? false : true;
                        item.isActive = isSelected ?? false;
                        saveSearchShortcutItems(); // Save the updated list
                  // isSelected = isSelected ? false : true;
                  // searchShortcutItems[index].isActive = isSelected;
                  
                });
              },
              title: Container(
                //color: Colors.yellow,
                child: Row(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: SvgPicture.asset(
                            searchShortcutItems[index].assetIcon,
                            height: 22,
                            width: 22,
                            color: (index >= 8 && index <= 10)
                                ? themeProvider.darkTheme
                                    ? Colors.white
                                    : Colors.black
                                : null) //themeProvider.darkTheme? Colors.white:Colors.black,),
                        ),
                    Text(searchShortcutItems[index].name,
                        style: TextStyle(
                            color: themeProvider.darkTheme
                                ? Colors.white
                                : Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.normal)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> loadSearchShortcutListItems() async {
    searchShortcutItems = [];
    setState(() {
      
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Read the list from SharedPreferences
    String? storedData = prefs.getString('searchShortcutItems');
    if (storedData != null) {
      List<dynamic> decodedData = json.decode(storedData);
      setState(() {
        searchShortcutItems = decodedData
            .map((item) => SearchShortcutListModel.fromJson(item))
            .toList();
      });
    } else {
      // If no data is stored, use the default list
      setState(() {
        searchShortcutItems = [
          SearchShortcutListModel(
            name: 'Beldex search engine',
            url: '',
            searchUrl: '',
            assetIcon: 'assets/images/Beldex_logo_svg 1.svg',
            isActive: true,
          ),
          SearchShortcutListModel(
            name: 'Google',
            url: '',
            searchUrl: '',
            assetIcon: 'assets/images/Google 1.svg',
            isActive: true,
          ),
          SearchShortcutListModel(
            name: 'DuckDuckGo',
            url: '',
            searchUrl: '',
            assetIcon: 'assets/images/DuckDuckGo 2.svg',
            isActive: true,
          ),
          SearchShortcutListModel(
              name: 'Yahoo',
              url: '',
              searchUrl: '',
              assetIcon: 'assets/images/Yahoo 1.svg',
              isActive: true),
          SearchShortcutListModel(
              name: 'Bing',
              url: '',
              searchUrl: '',
              assetIcon: 'assets/images/Bing 1.svg',
              isActive: false),
          SearchShortcutListModel(
              name: 'Ecosia',
              url: '',
              searchUrl: '',
              assetIcon: 'assets/images/Ecosia.svg',
              isActive: false),
          SearchShortcutListModel(
              name: 'Youtube',
              url: '',
              searchUrl: '',
              assetIcon: 'assets/images/youtube.svg',
              isActive: false),
          SearchShortcutListModel(
              name: 'Twitter',
              url: '',
              searchUrl: '',
              assetIcon: 'assets/images/twitter 1.svg',
              isActive: true),
          SearchShortcutListModel(
              name: 'Wikipedia',
              url: '',
              searchUrl: '',
              assetIcon: 'assets/images/Wikipedia 1.svg',
              isActive: true),
          SearchShortcutListModel(
              name: 'Reddit',
              url: '',
              searchUrl: '',
              assetIcon: 'assets/images/Reddit 1.svg',
              isActive: false),
          SearchShortcutListModel(
      name: 'Search settings',
      url: '',
      searchUrl: '',
      assetIcon: 'assets/images/settings.svg',
      isActive: true,
    ),
        ];

       // searchShortcutItems = searchShortcutItems + items;
        // searchShortcutItems = [
        //   SearchShortcutModel(
        //     name: 'Beldex search engine',
        //     url: '',
        //     searchUrl: '',
        //     assetIcon: 'assets/images/Beldex_logo_svg 1.svg',
        //     isActive: true,
        //   ),
        //   SearchShortcutModel(
        //     name: 'Youtube',
        //     url: '',
        //     searchUrl: '',
        //     assetIcon: 'assets/images/Beldex_logo_svg 1.svg',
        //     isActive: true,
        //   ),
        //   SearchShortcutModel(
        //     name: 'Beldex',
        //     url: '',
        //     searchUrl: '',
        //     assetIcon: 'assets/images/Beldex_logo_svg 1.svg',
        //     isActive: true,
        //   ),
        //   // ... add the rest of your models
        // ];
      });
    }
  }

  // Save the list to SharedPreferences
  Future<void> saveSearchShortcutItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert the list to a format that can be stored in SharedPreferences
    String encodedData =
        json.encode(searchShortcutItems.map((item) => item.toJson()).toList());

    // Save the list to SharedPreferences
    prefs.setString('searchShortcutItems', encodedData);
  }
}
