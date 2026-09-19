


import 'dart:async';

import 'package:beldex_browser/src/browser/ai/network_model.dart';
import 'package:beldex_browser/src/browser/ai/repositories/openai_repository.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VpnStatusProvider extends ChangeNotifier{
  String _value = 'Disconnected';

 AppLifecycleState? _state;


bool _isChangeNode = false;
  bool _canClose = false; // will helps closing the app if disconnect from the system while changing node

  String get value => _value;
  


// Has internet 

bool _isNetConnected = true;

bool get isNetConnected => _isNetConnected;

updateNetStatus(bool value){
  _isNetConnected = value;
  notifyListeners();
}



// bool _isNetConnect = true;

// bool get isNetConnect => _isNetConnect;

// void updateNetStatus(bool value){
//   _isNetConnect = value;
//   notifyListeners();
// }

  // -----------------------------------------------------------------------
  // Ported from belnet-app commit df16d27 (audit F1): daemon-status polling.
  // -----------------------------------------------------------------------
  Timer? _pollTimer;
  DateTime? _pollDeadline;
  bool _pollBusy = false;

  bool get isPolling => _pollTimer != null;

  /// Polls the daemon status until the exit tunnel is actually ready,
  /// replacing the old fixed 19-second delay.
  ///
  /// "Ready" means the daemon reports:
  ///   isconnected == true  AND  an exit is mapped  AND  numPathsBuilt > 0.
  ///
  /// Calls [onConnected] as soon as that is true (typically 4-8 s), or
  /// [onFailed] with the last observed daemon state if [timeout] elapses.
  ///
  /// [getStatus] is injected (defaults to [BelnetLib.getSpeedStatus] at the
  /// call site) so the polling logic stays unit-testable, exactly as in
  /// belnet-app.
  void startStatusPolling({
    required Future<Map<String, dynamic>?> Function() getStatus,
    required void Function() onConnected,
    required void Function(String reason) onFailed,
    Duration interval = const Duration(milliseconds: 500),
    Duration timeout = const Duration(seconds: 30),
  }) {
    cancelPolling();
    _pollDeadline = DateTime.now().add(timeout);
    String lastState = 'no status received from daemon';

    _pollTimer = Timer.periodic(interval, (timer) async {
      // Never let a slow platform call overlap the next tick.
      if (_pollBusy) return;

      if (_pollDeadline != null && DateTime.now().isAfter(_pollDeadline!)) {
        cancelPolling();
        onFailed(lastState);
        return;
      }

      _pollBusy = true;
      try {
        final raw = await getStatus();
        if (raw != null) {
          lastState = _describeDaemonState(raw);
          if (_statusIndicatesReady(raw)) {
            cancelPolling();
            onConnected();
          }
        }
      } catch (_) {
        // Keep polling; transient platform-channel errors are expected
        // while the service is still binding.
      } finally {
        _pollBusy = false;
      }
    });
  }

  void cancelPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _pollDeadline = null;
    _pollBusy = false;
  }

  /// Readiness check: isconnected && exit mapped && numPathsBuilt > 0.
  ///
  /// Browser adaptation: belnet-app parses top-level keys
  /// (isconnected / exitMap / numPathsBuilt) while the browser's own
  /// isExitReady walks a nested `services` map — the two repos' audit
  /// commits disagree on the daemon's status schema. This parser accepts
  /// BOTH shapes so it is correct regardless of which one the loaded
  /// daemon actually emits.
  static bool _statusIndicatesReady(Map<String, dynamic> status) {
    // Shape 1: belnet-app schema (top-level keys).
    final isConnected = status['isconnected'];
    if (isConnected is bool) {
      final pathsBuilt = status['numPathsBuilt'];
      final exitMap = status['exitMap'];
      final exitMapped = exitMap is Map && exitMap.isNotEmpty;
      final paths = pathsBuilt is num ? pathsBuilt.toInt() : 0;
      if (isConnected && exitMapped && paths > 0) return true;
      // Top-level schema present but not ready yet: also try shape 2 below
      // in case only part of the document matches.
    }

    // Shape 2: nested `services` schema (browser isExitReady).
    if (status['running'] == false) return false;
    final services = status['services'];
    if (services is Map) {
      for (final svc in services.values) {
        if (svc is Map) {
          final exitMap = svc['exitMap'];
          if (exitMap is Map && exitMap.isNotEmpty) {
            // An exit is mapped; require built paths too when the service
            // exposes the counter, matching belnet-app's stricter check.
            final paths = svc['numPathsBuilt'];
            if (paths is num) return paths.toInt() > 0;
            return true;
          }
        }
      }
    }
    return false;
  }

  /// Human-readable summary of the daemon state for [onFailed] reasons,
  /// e.g. "connected=true, exit mapped=false, paths built=0".
  static String _describeDaemonState(Map<String, dynamic> status) {
    bool? connected;
    bool exitMapped = false;
    int paths = 0;

    final isConnected = status['isconnected'];
    if (isConnected is bool) connected = isConnected;
    final exitMap = status['exitMap'];
    if (exitMap is Map && exitMap.isNotEmpty) exitMapped = true;
    final pathsBuilt = status['numPathsBuilt'];
    if (pathsBuilt is num) paths = pathsBuilt.toInt();

    final services = status['services'];
    if (services is Map) {
      for (final svc in services.values) {
        if (svc is Map) {
          final svcExit = svc['exitMap'];
          if (svcExit is Map && svcExit.isNotEmpty) exitMapped = true;
          final svcPaths = svc['numPathsBuilt'];
          if (svcPaths is num && svcPaths.toInt() > paths) {
            paths = svcPaths.toInt();
          }
        }
      }
      connected ??= status['running'] != false;
    }

    return 'connected=${connected ?? 'unknown'}, '
        'exit mapped=$exitMapped, paths built=$paths';
  }

  @override
  void dispose() {
    cancelPolling();
    super.dispose();
  }

 bool get isChangeNode => _isChangeNode;

  bool get canClose => _canClose;


AppLifecycleState? get state => _state;

bool _isUrlValid = true;

bool get isUrlValid => _isUrlValid;


void updateIsUrlValid(bool isTheUrlValid){
  _isUrlValid = isTheUrlValid;
  notifyListeners();
}


  void updateChangeNodevalue(bool changeNodevalue)async{
    _isChangeNode = changeNodevalue;
    notifyListeners();
  }

void updateCanClose(bool canCloseValue)async{
  _canClose = canCloseValue;
  notifyListeners();
}

void updateAppState(AppLifecycleState states)async{
  _state = states;
  notifyListeners();
}






  void updateValue(String newValue)async{
    _value = newValue;
    notifyListeners();

    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString('vpnStatus', newValue);

  }


   // Load the value from SharedPreferences
  Future<void> loadSavedValue() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String savedValue = prefs.getString('vpnStatus') ?? 'Disconnected';
    // _value = savedValue;
    // notifyListeners();
  }


// home button 
bool _canShowHomeScreen = false;

  bool get canShowHomeScreen => _canShowHomeScreen;

 void updateCanShowHomeScreen(bool canshowHome){
   _canShowHomeScreen = canshowHome;
   notifyListeners();
 }





//settings values 

bool _cacheEbld = true;

bool get cacheEbld => _cacheEbld;

void updateCacheValue(bool value)async{
  _cacheEbld = value;
  notifyListeners();
}

bool _jsEbld = true;

bool get jsEbld => _jsEbld;

void updateJSEnabled(bool value)async{
 _jsEbld = value;
 notifyListeners();
}

bool _supportZoomEbld = true;

bool get supportZoomEbld => _supportZoomEbld;

void updateSupportZoomEbld(bool value)async{
 _supportZoomEbld = value;
 notifyListeners();
}


bool _clearSessionCache = false;

bool get clearSessionCache => _clearSessionCache;

void updateClearSessionCache(bool value){
  _clearSessionCache = value;
  notifyListeners();
}

bool _builtinZoomControl = false;
bool get builtinZoomControl => _builtinZoomControl;

void updateBuiltinZoomControl(bool value){
  _builtinZoomControl = value;
  notifyListeners();
}


bool _displayZoomControls = false;

bool get displayZoomControls => _displayZoomControls;

void updateDisplayZoomControls(bool value){
  _displayZoomControls = value;
  notifyListeners();
}

bool _thirdpartyCookies = true;

bool get thirdpartyCookies => _thirdpartyCookies;

void updateThirdpartyCookies(bool value){
  _thirdpartyCookies = value;
  notifyListeners();
}




//Show FAB for summaise 

bool _showFAB = false;

bool get showFAB => _showFAB;

void updateFAB(bool value){
  _showFAB = value;
  notifyListeners();
}

bool _showErrorPage = false;
bool get showErrorPage => _showErrorPage;

void setErrorPage(bool value)async{
_showErrorPage = value;
notifyListeners();
}


// AI response 

String _aiResponse = 'loading';

String get aiResponse => _aiResponse;

void updateAIResponse(String aiText)async{
    _aiResponse = aiText;
    notifyListeners();
}


// Zoom contoller for readingmode content

double _fontSize = 16;

double get fontSize => _fontSize;

void updateReaderContentFontSize(double value){
  _fontSize = value;
  notifyListeners();
}


bool _changeReaderMenu = false;

bool get changeReaderMenu => _changeReaderMenu;

void updateReaderMenu(bool value){
  _changeReaderMenu = value;
  notifyListeners();
}



bool _isTTSDisabled = false;

bool get isTTSDisabled => _isTTSDisabled;

void setTTSStatus(bool value){
  _isTTSDisabled = value;
  notifyListeners();
}

bool _isNoInternet = false;

bool get isNoInternet => _isNoInternet;

void setInternetStatus(bool value){
 _isNoInternet = value;
 notifyListeners();
}



  // Freename support : by default it will be disabled

   bool _isEnabledFreeName = false;

   bool get isEnabledFreeName => _isEnabledFreeName;

   void updateIsEnableFreeName(bool enable){
    _isEnabledFreeName = enable;
    notifyListeners();
    saveFreenameStatusToPrefs();
   }


Future<void> saveFreenameStatusToPrefs()async{
  SharedPreferences prefs =  await SharedPreferences.getInstance();
    await prefs.setBool('freename', _isEnabledFreeName);

}


Future<void> loadFreenameStatusPrefs()async{
  SharedPreferences prefs = await SharedPreferences.getInstance();

   _isEnabledFreeName = prefs.getBool('freename') ?? false;
 
  notifyListeners();
}



bool _isSEDropdownOpened = false;

bool get isSEDropdownOpened => _isSEDropdownOpened;

void updateSEDrowpdownState(bool value){
  _isSEDropdownOpened = value;
}
bool _isSearchbarDropdownOpened = false;

bool get isSearchbarDropdownOpened => _isSearchbarDropdownOpened;

void updateSearchbarDrowpdownState(bool value){
  _isSearchbarDropdownOpened = value;
}


  }


  class SearchEngineProvider extends ChangeNotifier{

    String _value = 'assets/images/Beldex_logo_svg 1.svg';


    String get value => _value;

    void updateIconValue(String newvalue){
      _value = newvalue;
      notifyListeners();
    }
  }



  class LoadingtickValueProvider extends ChangeNotifier{

    double _progressValue = 0.0;

    double get progressValue => _progressValue;

    void updateProgressValue(double newvalue){
      _progressValue += newvalue;
      notifyListeners();
    }

  }

  //clear all cookies 
   void clearCookie()async{
CookieManager cookieManager = CookieManager.instance();
 await cookieManager.deleteAllCookies();
 print('Cookies deleted');
}


// For Floating Action button
class UrlSummaryProvider with ChangeNotifier {
  ChatGPTService chatGPTService = ChatGPTService(apiKey: '');

  String currentUrl = "";
  bool isLoading = false;
  String summaryText = "";
  Map<String, String> cache = {}; // Cache for storing summaries

  /// Updates the current URL
  void updateUrl(String url) {
    if (currentUrl != url) {
      currentUrl = url;
      summaryText = ""; // Clear previous summary
      notifyListeners();
    }
  }

  /// Fetches summary for the current URL
  Future<void> fetchSummary(WebViewModel webViewModel,{String modelType = 'openai'}) async {
    if (currentUrl.isEmpty || cache.containsKey(currentUrl)) {
      if(cache[currentUrl] == 'Erroring'){
        cache.remove(currentUrl);
        notifyListeners();
      }else{
       summaryText = cache[currentUrl] ?? summaryText;
      print('BELDEX AI SUmmarise text $summaryText');
      notifyListeners();
      return;
      }
    }
   print('BELDEX CURRENTURL DATA -----> $currentUrl');
    isLoading = true;
    notifyListeners();

    try {
      final response = await OpenAIRepository().fetchAndSummarizeContent(currentUrl, webViewModel,modelType);  //callOpenAiApi(currentUrl);
      cache[currentUrl] = response;
      summaryText = response;
    } catch (e) {
      summaryText = "Failed to fetch summary: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }



  bool _isSummarise = false;
  bool get isSummarise => _isSummarise;

    void updateSummariser(bool newvalue){
      _isSummarise = newvalue;
      notifyListeners();
    }


  bool _canStopAndRegenerate = false;
  bool get canStopAndRegenerate => _canStopAndRegenerate;

    void updateCanStop(bool newvalue){
      _canStopAndRegenerate = newvalue;
      notifyListeners();
    }
 
  // /// Calls OpenAI API to get a summary
  // Future<String> callOpenAiApi(String url) async {
  //   const openAiApiKey = "your_openai_api_key"; // Replace with your API key
  //   final apiEndpoint = "https://api.openai.com/v1/completions";

  //   final response = await http.post(
  //     Uri.parse(apiEndpoint),
  //     headers: {
  //       "Authorization": "Bearer $openAiApiKey",
  //       "Content-Type": "application/json",
  //     },
  //     body: jsonEncode({
  //       "model": "text-davinci-003",
  //       "prompt": "Summarize the content of this URL: $url",
  //       "max_tokens": 100,
  //     }),
  //   );

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     return data['choices'][0]['text'].trim();
  //   } else {
  //     throw Exception("Error: ${response.statusCode}");
  //   }
  // }
}



//  final List<Map<String, String>> countryInfo = [
//     {'name': 'Australia', 'url': 'assets/images/flags/Australia.png'},
//     {'name': 'Canada', 'url': 'assets/images/flags/Canada.png'},
//     {'name': 'France', 'url': 'assets/images/flags/france.png'},
//     {'name': 'Germany', 'url': 'assets/images/flags/Germany.png'},
//     {'name': 'Japan', 'url': 'assets/images/flags/japan.png'},
//     {'name': 'Lithuania', 'url': 'assets/images/flags/Lithuania.png'},
//     {'name': 'Netherlands', 'url': 'assets/images/flags/Netherlands.png'},
//     {'name': 'Singapore', 'url': 'assets/images/flags/Singapore.png'},
//     {'name': 'USA', 'url': 'assets/images/flags/USA.png'},
//   ];