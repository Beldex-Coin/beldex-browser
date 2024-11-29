class SearchEngineModel {
  final String name;
  final String assetIcon;
  final String url;
  final String searchUrl;

  const SearchEngineModel(
      {required this.name,
      required this.url,
      required this.searchUrl,
      required this.assetIcon});

  static SearchEngineModel? fromMap(Map<String, dynamic>? map) {
    return map != null
        ? SearchEngineModel(
            name: map["name"],
            assetIcon: map["assetIcon"],
            url: map["url"],
            searchUrl: map["searchUrl"])
        : null;
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "assetIcon": assetIcon,
      "url": url,
      "searchUrl": searchUrl
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

// ignore: constant_identifier_names
const GoogleSearchEngine = SearchEngineModel(
    name: "Google",
    url: "https://www.google.com/",
    searchUrl: "https://www.google.com/search?q=",
    assetIcon: "assets/images/google_logo.png");

// ignore: constant_identifier_names
const YahooSearchEngine = SearchEngineModel(
    name: "Yahoo",
    url: "https://yahoo.com/",
    searchUrl: "https://search.yahoo.com/search?p=",
    assetIcon: "assets/images/yahoo_logo.png");

// ignore: constant_identifier_names
const BingSearchEngine = SearchEngineModel(
    name: "Bing",
    url: "https://www.bing.com/",
    searchUrl: "https://www.bing.com/search?q=",
    assetIcon: "assets/images/bing_logo.png");

// ignore: constant_identifier_names
const DuckDuckGoSearchEngine = SearchEngineModel(
    name: "DuckDuckGo",
    url: "https://duckduckgo.com/",
    searchUrl: "https://duckduckgo.com/?q=",
    assetIcon: "assets/images/duckduckgo_logo.png");

// ignore: constant_identifier_names
const EcosiaSearchEngine = SearchEngineModel(
    name: "Ecosia",
    url: "https://www.ecosia.org/",
    searchUrl: "https://www.ecosia.org/search?q=",
    assetIcon: "assets/images/ecosia_logo.png");

// ignore: constant_identifier_names
const SearchEngines = <SearchEngineModel>[
  GoogleSearchEngine,
  YahooSearchEngine,
  BingSearchEngine,
  DuckDuckGoSearchEngine,
  EcosiaSearchEngine
];


const SearchEnginesIcons = [
 'assets/images/Google 1.svg',
 'assets/images/Yahoo 1.svg',
 'assets/images/Bing 1.svg',
 'assets/images/DuckDuckGo 2.svg',
 'assets/images/Ecosia.svg'
];







class SearchShortcutModel {
  final String name;
  final String assetIcon;
  final String url;
  final String searchUrl;
   bool isActive;

   SearchShortcutModel(
      {required this.name,
      required this.url,
      required this.searchUrl,
      required this.assetIcon,
      required this.isActive, 
      });

  static SearchShortcutModel? fromMap(Map<String, dynamic>? map) {
    return map != null
        ? SearchShortcutModel(
            name: map["name"],
            assetIcon: map["assetIcon"],
            url: map["url"],
            searchUrl: map["searchUrl"],
            isActive: map["isActive"]
            )
        : null;
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "assetIcon": assetIcon,
      "url": url,
      "searchUrl": searchUrl,
      "isActive": isActive
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

 List<SearchShortcutModel> searchShortcutItems = [
SearchShortcutModel(
  name: 'Beldex search engine', 
  url: '',
  searchUrl: '', 
  assetIcon: 'assets/images/Beldex_logo_svg 1.svg',
  isActive: true
  ),


 SearchShortcutModel(
  name: 'Google', 
  url: '',
  searchUrl: '', 
  assetIcon: 'assets/images/Google 1.svg',
  isActive: true
  ),

SearchShortcutModel(
  name: 'DuckDuckGo', 
  url: '',
  searchUrl: '', 
  assetIcon: 'assets/images/DuckDuckGo 2.svg',
  isActive: true
  ),

SearchShortcutModel(
  name: 'Yahoo', 
  url: '',
  searchUrl: '', 
  assetIcon: 'assets/images/Yahoo 1.svg',
  isActive: true
  ),

SearchShortcutModel(
  name: 'Bing', 
  url: '',
  searchUrl: '',
  assetIcon: 'assets/images/Bing 1.svg',
  isActive: true
  ),

SearchShortcutModel(
  name: 'Ecosia', 
  url: '',
  searchUrl: '', 
  assetIcon: 'assets/images/Ecosia.svg',
  isActive: true
  ),

SearchShortcutModel(
  name: 'Youtube', 
  url: '',
  searchUrl: '', 
  assetIcon: 'assets/images/youtube.svg',
  isActive: false
  ),

SearchShortcutModel(
  name: 'Twitter', 
  url: '',
  searchUrl: '', 
  assetIcon: 'assets/images/twitter 1.svg',
  isActive: true
  ),

SearchShortcutModel(
  name: 'Wikipedia', 
  url: '',
  searchUrl: '', 
  assetIcon: 'assets/images/Wikipedia 1.svg',
  isActive: false
  ),

SearchShortcutModel(
  name: 'Reddit', 
  url: '',
  searchUrl: '', 
  assetIcon: 'assets/images/Reddit 1.svg',
  isActive: false 
  )



];




