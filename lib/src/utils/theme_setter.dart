// import 'package:beldex_browser/src/utils/themes.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ThemeProvider with ChangeNotifier {
//   ThemeData _themeData = ThemeData.dark();

//   ThemeData get themeData => _themeData;

//   Future<void> toggleTheme() async {
//     _themeData = _themeData == Themes.lightTheme
//         ? Themes.darkTheme
//         : Themes.lightTheme;

//     notifyListeners();

//     // Save the theme preference
//     await saveThemePreference(_themeData);
//   }

//   Future<void> saveThemePreference(ThemeData themeData) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setBool('isDarkTheme', themeData == ThemeData.dark());
//   }

//   Future<void> loadThemePreference() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool isDarkTheme = prefs.getBool('isDarkTheme') ?? true;
//     _themeData = isDarkTheme ? ThemeData.dark() : ThemeData.light();
//     notifyListeners();
//   }
// }
