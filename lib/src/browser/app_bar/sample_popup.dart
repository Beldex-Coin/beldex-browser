import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/search_engine_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/pages/settings/search_settings_page.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:beldex_browser/src/widget/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectedItemsProvider extends ChangeNotifier {
  List<int> _selectedItems = [];

  List<int> get selectedItems => _selectedItems;

  List<Item> items = [
    Item('This time Search in', ''),
    Item('Beldex Search Engine', 'assets/images/Beldex_logo_svg 1.svg'),
    Item('Google', 'assets/images/Google 1.svg'),
    Item('DuckDuckGo', 'assets/images/DuckDuckGo 2.svg'),
    Item('Yahoo', 'assets/images/Yahoo 1.svg'),
    Item('Bing', 'assets/images/Bing 1.svg'),
    Item('Ecosia search engine', 'assets/images/Ecosia.svg'),
    Item('Youtube', 'assets/images/youtube.svg'),
    Item('Twitter', 'assets/images/twitter 1.svg'),
    Item('Wikipedia', 'assets/images/Wikipedia 1.svg'),
    Item('Reddit', 'assets/images/Reddit 1.svg'),
    Item('Search setting', 'assets/images/settings.svg')
    // Item('Search setting','assets/images/settings.svg')
    // Add more items as needed
  ];

 // late SharedPreferences _prefs;
  String _value = 'assets/images/Google 1.svg';
   double _fontSize = 8.0;
  SelectedItemsProvider() {
    initSharedPreferences();
  }

  String get value => _value;
  double get fontSize => _fontSize;
  Future<void> initSharedPreferences() async {
   final _prefs = await SharedPreferences.getInstance();
    String? storedValue = _prefs.getString('icon_value');
    if (storedValue != null) {
      _value = storedValue;
      notifyListeners();
    }
     double? storedFontSize = _prefs.getDouble('fontSize');
    if(storedFontSize != null){
      _fontSize = storedFontSize;
      notifyListeners();
    }
  }


 void updateFontSize(double fontSizes)async{
  final _prefs = await SharedPreferences.getInstance();
  _fontSize = fontSizes;
  notifyListeners();
  await _prefs.setDouble('fontSize', fontSizes);
 }



  void updateIconValue(String newvalue) async {
    final _prefs = await SharedPreferences.getInstance();
    _value = newvalue;
    notifyListeners();
    await _prefs.setString('icon_value', newvalue);
  }

void updateIconWhenNotSerchEngine() async {
    final _prefs = await SharedPreferences.getInstance();
    final value = _prefs.getString('icon_value');
    if(value == 'assets/images/youtube.svg' ||value == 'assets/images/Reddit 1.svg' || value == 'assets/images/Wikipedia 1.svg' || value == 'assets/images/twitter 1.svg'){
      _value = 'assets/images/Google 1.svg';
      notifyListeners();
     await _prefs.setString('icon_value', _value);
    }
   
  }
  void initializeSelectedItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? selectedItemsStr = prefs.getStringList('selectedItems');
    if (selectedItemsStr != null) {
      _selectedItems = selectedItemsStr.map((e) => int.parse(e)).toList();
      notifyListeners();
    } else {
      _selectedItems = [0, 2, 3, 4, 5, 6, 8, 9, 11]; // Default selected indices
      prefs.setStringList(
          'selectedItems', _selectedItems.map((e) => e.toString()).toList());
      notifyListeners();
    }
  }

  void toggleItem(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_selectedItems.contains(index)) {
      _selectedItems.remove(index);
    } else {
      _selectedItems.add(index);
      _selectedItems.sort();
    }

    prefs.setStringList(
        'selectedItems', _selectedItems.map((e) => e.toString()).toList());
    notifyListeners();
  }
}

class ItemsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final provider = Provider.of<SelectedItemsProvider>(context);
    return Scaffold(
        appBar: normalAppBar(context, 'Manage search Shortcuts', themeProvider),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child:const Text(
                  'Engine visible on the search menu',
                  style: TextStyle(
                      color: const Color(0xff00BD40),
                      fontSize: 17,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: themeProvider.darkTheme
                        ?const Color(0xff292937)
                        : const Color(0xffF3F3F3)),
                padding:const EdgeInsets.only(
                    left: 15.0,
                    right: 15,
                    bottom: 20),
                child: Container(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: provider.items.length - 1, // Exclude two items
                    //itemExtent: 43,
                    itemBuilder: (context, index) {
                      final item = provider.items[index];
                      if (item.name != 'This time Search in' &&
                          item.name != 'Search setting' &&
                          item.name != 'Beldex Search Engine') {
                        final actualIndex = index +
                            (index >= 11
                                ? 2
                                : 0); // Adjust index if skipping items
                        return ListTile(
                          leading: Container(

                            height: 15,
                            width: 15,
                            decoration: BoxDecoration(
                              //color: provider.selectedItems.contains(index) ? const Color(0xff00B134): Colors.transparent,
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(color:provider.selectedItems.contains(index) ? const Color(0xff00B134): themeProvider.darkTheme ? Colors.white: Colors.black),
                            ),
                            child: provider.selectedItems.contains(index)
                                ? SvgPicture.asset(
                                    'assets/images/tick.svg',
                                    fit: BoxFit.cover,
                                  )
                                : SizedBox(),
                          ),
                          minLeadingWidth: 15,
                          onTap: () {
                            provider.toggleItem(index);
                          },
                          title: Container(
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
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
                                    color:
                                        (actualIndex >= 8 && actualIndex <= 11)
                                            ? themeProvider.darkTheme
                                                ? Colors.white
                                                : Colors.black
                                            : null,
                                  ),
                                ),
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    color: themeProvider.darkTheme
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return SizedBox(); // Return an empty SizedBox for excluded items
                      }
                    },
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
    final provider = Provider.of<SelectedItemsProvider>(context, listen: false);
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    var webViewModel = Provider.of<WebViewModel>(context, listen: true);
    var webViewController = webViewModel.webViewController;
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
            SvgPicture.asset(
              provider.value,
              color: provider.value == 'assets/images/Reddit 1.svg' ||
                      provider.value == 'assets/images/Wikipedia 1.svg' ||
                      provider.value == 'assets/images/twitter 1.svg'
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
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15.0),
          bottomRight: Radius.circular(15.0),
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      onSelected: _searchListActions,
      itemBuilder: (BuildContext context) {
        return provider.selectedItems.map((index) {
          return PopupMenuItem<List<int>>(
            value: [index],
            height: 35,
            child: index == 0
                ? Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          '${provider.items[index].name}:',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Container(
                          width: 30,
                          //color: Colors.yellow,
                          child: SvgPicture.asset(
                            provider.items[index].imageUrl,
                            color: index == 8 ||
                                    index == 9 ||
                                    index == 10 ||
                                    index == 11
                                ? themeProvider.darkTheme
                                    ? Colors.white
                                    : Colors.black
                                : null,
                          )),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextWidget(
                         text: provider.items[index].name,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
          );
        }).toList();
      },
    );
  }

  void _searchListActions(List<int> choice) async {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();
    var provider = Provider.of<SelectedItemsProvider>(context, listen: false);
    switch (choice.first) {
      case 1:
        setState(() {
          settings.searchEngine = SearchEngines[0];
          widget.browserModel.updateSettings(settings);
          WebUri? url;
          url ??= WebUri(settings.searchEngine.url);
              provider.updateIconValue('assets/images/Beldex_logo_svg 1.svg');
        });
        break;
      case 2:
        setState(() {
          settings.searchEngine = SearchEngines[0];
          widget.browserModel.updateSettings(settings);
          WebUri? url;
          url ??= WebUri(settings.searchEngine.url);
          provider.updateIconValue('assets/images/Google 1.svg');
        });
        break;
      case 3:
        setState(() {
          settings.searchEngine = SearchEngines[3];
          widget.browserModel.updateSettings(settings);
          WebUri? url;
          url ??= WebUri(settings.searchEngine.url);
          widget.browserModel.showTabScroller = false;
          provider.updateIconValue('assets/images/DuckDuckGo 2.svg');
        });
        break;
      case 4:
        setState(() {
          settings.searchEngine = SearchEngines[1];
          widget.browserModel.updateSettings(settings);
          WebUri? url;
          url ??= WebUri(settings.searchEngine.url);
          provider.updateIconValue('assets/images/Yahoo 1.svg');
        });
        break;
      case 5:
        setState(() {
          settings.searchEngine = SearchEngines[2];
          widget.browserModel.updateSettings(settings);
          WebUri? url;
          url ??= WebUri(settings.searchEngine.url);
          provider.updateIconValue('assets/images/Bing 1.svg');
        });
        break;
      case 6:
        setState(() {
          settings.searchEngine = SearchEngines[4];
          widget.browserModel.updateSettings(settings);
          WebUri? url;
          url ??= WebUri(settings.searchEngine.url);
          provider.updateIconValue('assets/images/Ecosia.svg');
        });
        break;
      case 7:
        setState(() {
          settings.searchEngine = SearchEngineModel(
              name: 'Youtube',
              url: 'https://www.youtube.com/',
              searchUrl: 'https://www.youtube.com/results?search_query=',
              assetIcon: '');
          widget.browserModel.updateSettings(settings);
        });
        provider.updateIconValue('assets/images/youtube.svg');
        break;
      case 8:
        setState(() {
          settings.searchEngine = SearchEngineModel(
              name: 'Twitter',
              url: 'https://twitter.com/',
              searchUrl: 'https://www.twitter.com/results?search_query=',
              assetIcon: '');
          widget.browserModel.updateSettings(settings);
        });
        widget.browserModel.showTabScroller = false;
        provider.updateIconValue('assets/images/twitter 1.svg');
        break;
      case 9:
        setState(() {
          settings.searchEngine = SearchEngineModel(
              name: 'Wikipedia',
              url: 'https://www.wikipedia.org/',
              searchUrl: 'https://en.wikipedia.org/w/index.php?search=',
              assetIcon: '');
          widget.browserModel.updateSettings(settings);
        });
        provider.updateIconValue('assets/images/Wikipedia 1.svg');
        break;
      case 10:
        provider.updateIconValue('assets/images/Reddit 1.svg');
        setState(() {
          settings.searchEngine = SearchEngineModel(
              name: 'Reddit',
              url: 'https://www.reddit.com/',
              searchUrl: 'https://www.reddit.com/search/?q=',
              assetIcon: '');
          widget.browserModel.updateSettings(settings);
        });
        break;
      case 11:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SearchSettingsPage()));
        break;
    }
  }
}

class Item {
  final String name;
  final String imageUrl;

  Item(this.name, this.imageUrl);
}
