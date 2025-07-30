import 'dart:ui';

import 'package:flutter/material.dart';

 class Styles {
   
 static ThemeData themeData(bool isDarkTheme, BuildContext context) {
  final background = isDarkTheme ? Color(0xff171720) : Color(0xffFFFFFF);
  return ThemeData(
    useMaterial3: true,
    primarySwatch: Colors.red,
    primaryColor: isDarkTheme ? Colors.black : Colors.white,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme(
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      primary: Colors.red,
      onPrimary: Colors.white,
      secondary: Colors.green,
      onSecondary: Colors.white,
      background: background,
      onBackground: isDarkTheme ? Colors.white : Colors.black,
      surface: isDarkTheme ? Color(0xFF151515) : Colors.white,
      onSurface: isDarkTheme ? Colors.white : Colors.black,
      error: Colors.red,
      onError: Colors.white,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        color: isDarkTheme ? Colors.white : Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      bodyMedium: TextStyle(
        color: isDarkTheme ? Colors.white : Colors.black,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        color: isDarkTheme ? Colors.white : Colors.black,
        fontWeight: FontWeight.normal,
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Color(0xff3EC745),
      selectionColor: Color(0xff3EC745),
      selectionHandleColor: Color(0xff3EC745),
    ),
    indicatorColor: isDarkTheme ? Color(0xff0E1D36) : Color(0xffCBDCF8),
    bottomSheetTheme: const BottomSheetThemeData(
      modalBackgroundColor: Colors.transparent,
      modalElevation: 0,
    ),
    dialogTheme: const DialogTheme(elevation: 0),
    hintColor: isDarkTheme ? Color(0xff280C0B) : Color(0xffEECED3),
    hoverColor: isDarkTheme ? Color(0xff3A3A3B) : Color(0xff4285F4),
    focusColor: isDarkTheme ? Color(0xff0B2512) : Color(0xffA8DAB5),
    disabledColor: Colors.grey,
    cardColor: isDarkTheme ? Color(0xFF151515) : Colors.white,
    brightness: isDarkTheme ? Brightness.dark : Brightness.light,
    buttonTheme: Theme.of(context).buttonTheme.copyWith(
      colorScheme: isDarkTheme ? const ColorScheme.dark() : const ColorScheme.light(),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      elevation: 0.0,
      scrolledUnderElevation: 0,
    ),
  );
}

}