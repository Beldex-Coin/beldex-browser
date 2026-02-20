import 'package:beldex_browser/src/browser/app_bar/sample_popup.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/search_engine_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AddSearchEngineProvider extends ChangeNotifier {
  final List<SearchEngineModel> sessionSearchEngines = [];

 /// selected session engines for menu shortcuts
  final List<SearchEngineModel> selectedSessionEngines = [];

 bool _isLoading = false;

 bool get isLoading => _isLoading;

 updateLoader(bool value){
  _isLoading = value;
  notifyListeners();
 }



  List<SearchEngineModel> get allEngines =>
      [...SearchEngines, ...sessionSearchEngines];

  void addSearchEngine(SearchEngineModel engine) {
////added today
     // Prevent duplicate names or URLs
    if (sessionSearchEngines.any((e) =>
        e.name.toLowerCase() == engine.name.toLowerCase())) return;
///// added today

    sessionSearchEngines.add(engine);
    notifyListeners();
  }



///  Toggle selection from Manage Search Shortcuts screen
  void toggleSessionEngine(SearchEngineModel engine) {
    if (selectedSessionEngines.contains(engine)) {
      selectedSessionEngines.remove(engine);
    } else {
      selectedSessionEngines.add(engine);
    }
    notifyListeners();
  }


 void removeSessionEngineIfSelected(SearchEngineModel engine){
  if(selectedSessionEngines.contains(engine)){
    selectedSessionEngines.remove(engine);
  }
  notifyListeners();
 }



bool isSessionEngineSelected(SearchEngineModel engine) {
    return selectedSessionEngines.contains(engine);
  }












  /// DELETE (Only deletes user-added engines)
  // void removeSearchEngine(SearchEngineModel engine,BrowserSettings settings,BrowserModel browserModel,SelectedItemsProvider selectedItemProvider) {
  //   // Only delete if engine exists in user-added list
  //   if (_sessionSearchEngines.contains(engine)) {
  //     _sessionSearchEngines.remove(engine);
  //     notifyListeners();
  //   }
  //   if(engine.name == settings.searchEngine.name){
  //      settings.searchEngine = GoogleSearchEngine;
  //                   browserModel.updateSettings(settings); 
  //     selectedItemProvider
  //                       .updateIconValue('assets/images/Google 1.svg');

  //   notifyListeners();
  //   }
  // }

  void removeSearchEngine(
  SearchEngineModel engine,
  BrowserSettings settings,
  BrowserModel browserModel,
 // SelectedItemsProvider selectedItemProvider,
) {
  int before = sessionSearchEngines.length;

  // Remove engine using name match
  sessionSearchEngines.removeWhere(
    (e) => e.name.toLowerCase() == engine.name.toLowerCase(),
  );

  bool removed = sessionSearchEngines.length < before;

  if (removed) {
    // If deleted engine was active engine → reset to Google
    if (settings.searchEngine.name.toLowerCase() ==
        engine.name.toLowerCase()) {
      settings.searchEngine = GoogleSearchEngine;
      browserModel.updateSettings(settings);

      browserModel.updateIconValue(
        'assets/images/Google 1.svg',
      );
    }

    notifyListeners();
  }
}



 /// EDIT FUNCTION (Only updates user-added engines)
  void updateSearchEngine(
      SearchEngineModel oldEngine, SearchEngineModel newEngine) {
    int index = sessionSearchEngines.indexOf(oldEngine);
    if (index != -1) {
      sessionSearchEngines[index] = newEngine;
      notifyListeners();
    }
  }

void restoreDefaultIfInvalid(
  BrowserSettings settings,
  BrowserModel browserModel,
  BuildContext context
) {
 // final provider = Provider.of<SelectedItemsProvider>(context,listen: false);
  bool exists = allEngines.any(
    (e) => e.name == settings.searchEngine.name,
  );

  if (!exists) {
    settings.searchEngine = GoogleSearchEngine;
    browserModel.updateSettings(settings);

   //Provider.of<SelectedItemsProvider>(context,listen: false).updateIconValue('assets/images/Google 1.svg');

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   provider.updateIconValue('assets/images/Google 1.svg');
    //   print('Restored to Google icon: ${provider.value}');
    // });

    notifyListeners();
  } else {
    notifyListeners();
  }
}

// void restoreDefaultIfInvalid(BrowserSettings settings,BrowserModel browserModel,SelectedItemsProvider selectedItemProvider) {
//     // When app restarts, session engines vanish
//     // So selected engine might point to a removed engine
//     bool exists = allEngines.any((e) => e.name == settings.searchEngine.name);

//     if (!exists) {
//       settings.searchEngine = GoogleSearchEngine;
//                     browserModel.updateSettings(settings); 
//       selectedItemProvider
//                         .updateIconValue('assets/images/Google 1.svg');
//       print('The cachedNetwork image from reset ${selectedItemProvider.value}');
//       notifyListeners();
//     }

//     notifyListeners();
//   }


  void clearSessionEngines(BrowserSettings settings,BrowserModel browserModel,BuildContext context) {
    sessionSearchEngines.clear();
    notifyListeners();
    restoreDefaultIfInvalid(settings,browserModel,context);
    
  }

  // This Helper will help to check Added search engines
  bool isUserEngine(SearchEngineModel engine) {
  return sessionSearchEngines.contains(engine);
}

}
