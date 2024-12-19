


import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VpnStatusProvider extends ChangeNotifier{
  String _value = 'Disconnected';

 AppLifecycleState? _state;


bool _isChangeNode = false;
  bool _canClose = false; // will helps closing the app if disconnect from the system while changing node

  String get value => _value;
  

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