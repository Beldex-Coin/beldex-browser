import 'package:beldex_browser/src/utils/themes/dark_theme_preference.dart';
import 'package:flutter/material.dart';

class DarkThemeProvider with ChangeNotifier {
  DarkThemePreference darkThemePreference = DarkThemePreference();
  bool _darkTheme = true;

  bool get darkTheme => _darkTheme;


  set darkTheme(bool value) {
    _darkTheme = value;
    darkThemePreference.setDarkTheme(value);
    notifyListeners();
  }

 bool _readerDarkTheme = true;

 bool get readerDarkTheme => _readerDarkTheme;

 set readerDarkTheme(bool value){
  _readerDarkTheme = value;
  notifyListeners();
 }

}