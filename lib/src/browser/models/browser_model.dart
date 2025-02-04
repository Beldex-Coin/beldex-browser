import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:beldex_browser/ad_blocker_filter.dart';
import 'package:beldex_browser/src/browser/models/favorite_model.dart';
import 'package:beldex_browser/src/browser/models/web_archive_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/webview_tab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'search_engine_model.dart';
import 'package:collection/collection.dart';

class BrowserSettings {
  SearchEngineModel searchEngine;
  bool homePageEnabled;
  String customUrlHomePage;
  bool debuggingEnabled;

  BrowserSettings(
      {this.searchEngine = GoogleSearchEngine,
      this.homePageEnabled = false,
      this.customUrlHomePage = "",
      this.debuggingEnabled = false});

  BrowserSettings copy() {
    return BrowserSettings(
        searchEngine: searchEngine,
        homePageEnabled: homePageEnabled,
        customUrlHomePage: customUrlHomePage,
        debuggingEnabled: debuggingEnabled);
  }

  static BrowserSettings? fromMap(Map<String, dynamic>? map) {
    return map != null
        ? BrowserSettings(
            searchEngine: SearchEngines[map["searchEngineIndex"]],
            homePageEnabled: map["homePageEnabled"],
            customUrlHomePage: map["customUrlHomePage"],
            debuggingEnabled: map["debuggingEnabled"])
        : null;
  }

  Map<String, dynamic> toMap() {
    return {
      "searchEngineIndex": SearchEngines.indexOf(searchEngine),
      "homePageEnabled": homePageEnabled,
      "customUrlHomePage": customUrlHomePage,
      "debuggingEnabled": debuggingEnabled
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

class BrowserModel extends ChangeNotifier {
  final List<FavoriteModel> _favorites = [];
  final List<WebViewTab> _webViewTabs = [];
  final Map<String, WebArchiveModel> _webArchives = {};
  int _currentTabIndex = -1;
  BrowserSettings _settings = BrowserSettings();
  late WebViewModel _currentWebViewModel;

  bool _showTabScroller = false;

  bool get showTabScroller => _showTabScroller;

  set showTabScroller(bool value) {
    if (value != _showTabScroller) {
      _showTabScroller = value;
      notifyListeners();
    }
  }

//new tab

 bool _isNewTab = false;

  bool get isNewTab => _isNewTab;

  set isNewTab(bool value) {
    if (value != _isNewTab) {
      _isNewTab = value;
      notifyListeners();
    }
  }

  void updateIsNewTab(bool value) {
    isNewTab = value;
  }


// find on page

bool _isFindingOnPage =false;

bool get isFindingOnPage => _isFindingOnPage;

set isFindingOnPage(bool value){
  if(value != _isFindingOnPage){
    _isFindingOnPage = value;
    notifyListeners();
  }
}

void updateFindOnPage(bool value){
  isFindingOnPage = value;
}




// screensecurity

bool _isScreenSecure = true;


bool get isScreenSecure => _isScreenSecure;



  Future<void> loadSavedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isScreenSecure = prefs.getBool('isScreenSecure') ?? true;
    notifyListeners();
  }





set isScreenSecure(bool value){
  if(value != _isScreenSecure){
    _isScreenSecure = value;
    notifyListeners();
  }
}

void updateScreenSecurity(bool value)async{
  isScreenSecure = value;
   SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isScreenSecure', value);
}



setAdblocker() async {
     List<ContentBlocker>? contentBlockers = [];
    for (final adUrlFilter in AdBlockerFilter.adUrlFilters) {
      contentBlockers.add(ContentBlocker(
          trigger: ContentBlockerTrigger(
            urlFilter: adUrlFilter,
          ),
          action: ContentBlockerAction(
            type: ContentBlockerActionType.BLOCK,
          )));
    }
    
     // Apply the "display: none" style to some HTML elements
    contentBlockers.add(ContentBlocker(
        trigger: ContentBlockerTrigger(
          urlFilter: ".*",
        ),
        action: ContentBlockerAction(
            type: ContentBlockerActionType.CSS_DISPLAY_NONE,
            )));
  
  _currentWebViewModel.settings?.contentBlockers = contentBlockers;


    for (var webViewTab in _webViewTabs) {
      webViewTab.webViewModel.settings?.contentBlockers = contentBlockers;
    }


}








  BrowserModel() {
    _currentWebViewModel = WebViewModel();
    setAdblocker();
  }

  UnmodifiableListView<WebViewTab> get webViewTabs =>
      UnmodifiableListView(_webViewTabs);

  UnmodifiableListView<FavoriteModel> get favorites =>
      UnmodifiableListView(_favorites);

  UnmodifiableMapView<String, WebArchiveModel> get webArchives =>
      UnmodifiableMapView(_webArchives);

  void addTab(WebViewTab webViewTab) {
    //updateIsNewTab(true);
    _webViewTabs.add(webViewTab);
    _currentTabIndex = _webViewTabs.length - 1;
    webViewTab.webViewModel.tabIndex = _currentTabIndex;

    _currentWebViewModel.updateWithValue(webViewTab.webViewModel);

    notifyListeners();
  }

  void addTabs(List<WebViewTab> webViewTabs) {
    for (var webViewTab in webViewTabs) {
      _webViewTabs.add(webViewTab);
      webViewTab.webViewModel.tabIndex = _webViewTabs.length - 1;
    }
    _currentTabIndex = _webViewTabs.length - 1;
    if (_currentTabIndex >= 0) {
      _currentWebViewModel.updateWithValue(webViewTabs.last.webViewModel);
    }

    notifyListeners();
  }

  void closeTab(int index) {
    final webViewTab = _webViewTabs[index];
    _webViewTabs.removeAt(index);
    //InAppWebViewController.disposeKeepAlive(webViewTab.webViewModel.keepAlive);

    _currentTabIndex = _webViewTabs.length - 1;

    for (int i = index; i < _webViewTabs.length; i++) {
      _webViewTabs[i].webViewModel.tabIndex = i;
    }

    if (_currentTabIndex >= 0) {
      _currentWebViewModel
          .updateWithValue(_webViewTabs[_currentTabIndex].webViewModel);
    } else {
      _currentWebViewModel.updateWithValue(WebViewModel());
    }

    notifyListeners();
  }

  void showTab(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      _currentWebViewModel
          .updateWithValue(_webViewTabs[_currentTabIndex].webViewModel);

      notifyListeners();
    }
  }

  void closeAllTabs() {
    // for (final webViewTab in _webViewTabs) {
    //   InAppWebViewController.disposeKeepAlive(webViewTab.webViewModel.keepAlive);
    // }
    _webViewTabs.clear();
    _currentTabIndex = -1;
    _currentWebViewModel.updateWithValue(WebViewModel());

    notifyListeners();
  }

  int getCurrentTabIndex() {
    return _currentTabIndex;
  }

  WebViewTab? getCurrentTab() {
    return _currentTabIndex >= 0 ? _webViewTabs[_currentTabIndex] : null;
  }

  bool containsFavorite(FavoriteModel favorite) {
    return _favorites.contains(favorite) ||
        _favorites
                .map((e) => e)
                .firstWhereOrNull((element) => element.url == favorite.url) !=
            null;
  }

  void addFavorite(FavoriteModel favorite) {
    _favorites.add(favorite);
    notifyListeners();
  }

  void addFavorites(List<FavoriteModel> favorites) {
    _favorites.addAll(favorites);
    notifyListeners();
  }

  void clearFavorites() {
    _favorites.clear();
    notifyListeners();
  }

  void removeFavorite(FavoriteModel favorite) {
    if (!_favorites.remove(favorite)) {
      var favToRemove = _favorites
          .map((e) => e)
          .firstWhereOrNull((element) => element.url == favorite.url);
      _favorites.remove(favToRemove);
    }

    notifyListeners();
  }

  void addWebArchive(String url, WebArchiveModel webArchiveModel) {
    _webArchives.putIfAbsent(url, () => webArchiveModel);
    notifyListeners();
  }

  void addWebArchives(Map<String, WebArchiveModel> webArchives) {
    _webArchives.addAll(webArchives);
    notifyListeners();
  }

  void removeWebArchive(WebArchiveModel webArchive) {
    var path = webArchive.path;
    if (path != null) {
      final webArchiveFile = File(path);
      try {
        webArchiveFile.deleteSync();
      } finally {
        _webArchives.remove(webArchive.url.toString());
      }
      notifyListeners();
    }
  }

  void clearWebArchives() {
    _webArchives.forEach((key, webArchive) {
      var path = webArchive.path;
      if (path != null) {
        final webArchiveFile = File(path);
        try {
          webArchiveFile.deleteSync();
        } finally {
          _webArchives.remove(key);
        }
      }
    });

    notifyListeners();
  }

  BrowserSettings getSettings() {
    return _settings.copy();
  }

  void updateSettings(BrowserSettings settings) {
    _settings = settings;
    notifyListeners();
  }

  void setCurrentWebViewModel(WebViewModel webViewModel) {
    _currentWebViewModel = webViewModel;
  }

  DateTime _lastTrySave = DateTime.now();
  Timer? _timerSave;
  Future<void> save() async {
    _timerSave?.cancel();

    if (DateTime.now().difference(_lastTrySave) >=
        const Duration(milliseconds: 400)) {
      _lastTrySave = DateTime.now();
      await flush();
    } else {
      _lastTrySave = DateTime.now();
      _timerSave = Timer(const Duration(milliseconds: 500), () {
        save();
      });
    }
  }

  Future<void> flush() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("browser", json.encode(toJson()));
  }

  Future<void> restore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> browserData;
    try {
      String? source = prefs.getString("browser");
      if (source != null) {
        browserData = await json.decode(source);

        clearFavorites();
        closeAllTabs();
        clearWebArchives();

        List<Map<String, dynamic>> favoritesList = 
            browserData["favorites"]?.cast<Map<String, dynamic>>() ?? [];
        List<FavoriteModel> favorites =
            favoritesList.map((e) => FavoriteModel.fromMap(e)!).toList();

        Map<String, dynamic> webArchivesMap = {};
           // browserData["webArchives"]?.cast<String, dynamic>() ?? {};
        Map<String, WebArchiveModel> webArchives = webArchivesMap.map(
            (key, value) => MapEntry(
                key, WebArchiveModel.fromMap(value?.cast<String, dynamic>())!));

        BrowserSettings settings = BrowserSettings.fromMap(
                browserData["settings"]?.cast<String, dynamic>()) ??
            BrowserSettings();
        List<Map<String, dynamic>> webViewTabList = [];

      
          //  browserData["webViewTabs"]?.cast<Map<String, dynamic>>() ?? [];
        // List<WebViewTab> webViewTabs = webViewTabList
        //     .map((e) => WebViewTab(
        //           key: GlobalKey(),
        //           webViewModel: WebViewModel.fromMap(e)!,
        //         ))
        //     .toList();
        
        // webViewTabs.sort((a, b) =>
        //     a.webViewModel.tabIndex!.compareTo(b.webViewModel.tabIndex!));

        addFavorites(favorites);
        addWebArchives(webArchives);
        updateSettings(settings);
       if( settings.homePageEnabled && settings.customUrlHomePage.isNotEmpty){
        //   List<WebViewTab> webViewTabs =[
        //    WebViewTab(webViewModel: WebViewModel(url:WebUri( settings.customUrlHomePage))
        //    )
        // ];
        addTab(WebViewTab(webViewModel: WebViewModel(url:WebUri( settings.customUrlHomePage))
           ));
        // addTabs(webViewTabs);
       }
        //addTabs(webViewTabs);

        int currentTabIndex =
            browserData["currentTabIndex"] ?? _currentTabIndex;
        currentTabIndex = min(currentTabIndex, _webViewTabs.length - 1);

        if (currentTabIndex >= 0) {
          showTab(currentTabIndex);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "favorites": _favorites.map((e) => e.toMap()).toList(),
      "webViewTabs": _webViewTabs.map((e) => e.webViewModel.toMap()).toList(),
      "webArchives":
          _webArchives.map((key, value) => MapEntry(key, value.toMap())),
      "currentTabIndex": _currentTabIndex,
      "settings": _settings.toMap(),
      "currentWebViewModel": _currentWebViewModel.toMap(),
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
