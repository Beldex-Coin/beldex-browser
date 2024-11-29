import 'dart:ui';

import 'package:flutter/material.dart';

 class Styles {
   
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
      primarySwatch: Colors.red,
      primaryColor: isDarkTheme ? Colors.black : Colors.white,
      scaffoldBackgroundColor: isDarkTheme ? Color(0xff171720) : Color(0xffFFFFFF),
     textTheme :TextTheme(
          bodyLarge: TextStyle(color: isDarkTheme ? Colors.white : Colors.black, fontWeight: FontWeight.bold,fontSize: 20),
          bodyMedium: TextStyle(color: isDarkTheme ? Colors.white : Colors.black,//fontSize: 14.0,
          fontWeight: FontWeight.normal),
          bodySmall: TextStyle(color: isDarkTheme ? Colors.white : Colors.black,//fontSize: 13.0,
          fontWeight: FontWeight.normal)
        ),
     // primaryTextTheme: TextTheme(t),
      backgroundColor: isDarkTheme ? Color(0xff171720) : Color(0xffFFFFFF),
     textSelectionTheme: TextSelectionThemeData(
                            cursorColor: Color(0xff3EC745),
                             selectionColor:Color(0xff3EC745), // Set the selection bubble color
                             selectionHandleColor: Color(0xff3EC745),
                        ),
      indicatorColor: isDarkTheme ? Color(0xff0E1D36) : Color(0xffCBDCF8),
      //buttonColor: isDarkTheme ? Color(0xff3B3B3B) : Color(0xffF1F5FB),
     bottomSheetTheme: BottomSheetThemeData(
      modalBackgroundColor: Colors.transparent,modalElevation: 0
     ),
     dialogTheme: DialogTheme(
      elevation: 0
     ),
      hintColor: isDarkTheme ? Color(0xff280C0B) : Color(0xffEECED3),

     // highlightColor: isDarkTheme ? Color.fromRGBO(48, 47, 45, 1) : Color.fromARGB(255, 65, 64, 64),
      hoverColor: isDarkTheme ? Color(0xff3A3A3B) : Color(0xff4285F4),

      focusColor: isDarkTheme ? Color(0xff0B2512) : Color(0xffA8DAB5),
      disabledColor: Colors.grey,
     // textSelectionColor: isDarkTheme ? Colors.white : Colors.black,
      cardColor: isDarkTheme ? Color(0xFF151515) : Colors.white,
     // canvasColor: isDarkTheme ? Colors.black : Colors.grey[50],
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      buttonTheme: Theme.of(context).buttonTheme.copyWith(
          colorScheme: isDarkTheme ? ColorScheme.dark() : ColorScheme.light()),
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkTheme ? Color(0xff171720) : Color(0xffFFFFFF),
        elevation: 0.0,
        scrolledUnderElevation: 0
      ),
    );
    
  }
}