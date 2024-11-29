


import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BasicProvider extends ChangeNotifier{


bool _scrnSecurity = true;

bool get scrnSecurity => _scrnSecurity;

void updateScrnSecurity(bool newValue){
  _scrnSecurity = newValue;
  notifyListeners();
  saveToPrefs();
}


Future<void> loadFromPrefs()async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  _scrnSecurity = prefs.getBool('scrnSecurity') ?? true;
   print('screenSecurity2-----> $_scrnSecurity');
  notifyListeners();
}

Future<void> saveToPrefs()async{
  print('screenSecurity1-----> $_scrnSecurity');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('scrnSecurity', _scrnSecurity);

}



}