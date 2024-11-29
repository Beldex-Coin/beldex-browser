import 'package:flutter/material.dart';
import 'palette.dart';

class Themes {

  static final ThemeData lightTheme = ThemeData(
    //fontFamily: 'OpenSans',
    brightness: Brightness.light,
    backgroundColor: Palette.lightThemeBackground,
    scaffoldBackgroundColor: Palette.lightThemeBlack,
    appBarTheme: AppBarTheme(
      backgroundColor: Palette.lightThemeBlack,
    ),
    hintColor: Colors.grey[500],
    focusColor: Palette.lightGrey, // focused and enabled border color for text fields
    primaryTextTheme: TextTheme(
      headline6: TextStyle(
        color: BeldexPalette.black
      ),
      caption: TextStyle(
        color: BeldexPalette.black,
      ),
      button: TextStyle(
        color: Colors.white,//BeldexPalette.black,
          backgroundColor: BeldexPalette.tealWithOpacity,
          decorationColor: BeldexPalette.teal
      ),
      headline5: TextStyle(
        color: Palette.darkThemeGrey,
        //color: BeldexPalette.black // account list tile, contact page
      ),
      subtitle2: TextStyle(
        color: Palette.wildDarkBlue, // filters
        backgroundColor:Palette.saveAndCopyButtonColor1
      ),
      subtitle1: TextStyle(
        color: BeldexPalette.black // transaction raw, trade raw
      ),
      overline: TextStyle(
        color: PaletteDark.darkThemeCloseButton // standard list row, transaction details
      )
    ),
    toggleButtonsTheme: ToggleButtonsThemeData(
      selectedColor: BeldexPalette.teal,
      disabledColor: Palette.wildDarkBlue,
      color: Palette.switchBackground,
      borderColor: Palette.switchBorder
    ),
    selectedRowColor: Colors.grey,//BeldexPalette.tealWithOpacity,
    dividerColor: Colors.black,//Palette.lightGrey,
    dividerTheme: DividerThemeData(
      color: Colors.grey,//Palette.lightGrey
    ),
    cardColor: Palette.cardBackgroundColor,
    cardTheme: CardTheme(
      color: Palette.cardColor,
      shadowColor: Palette.cardButtonColor,
    ),
    primaryIconTheme: IconThemeData(
      color: Colors.white
    ),
  );


  static final ThemeData darkTheme = ThemeData(
    //fontFamily: 'OpenSans',
    brightness: Brightness.dark,
    backgroundColor: PaletteDark.darkThemeBackground,
    scaffoldBackgroundColor: PaletteDark.darkThemeBlack,
    appBarTheme: AppBarTheme(
      backgroundColor: PaletteDark.darkThemeBlack,
    ),
    hintColor: PaletteDark.darkThemeGrey,
    focusColor: PaletteDark.darkThemeGreyWithOpacity, // focused and enabled border color for text fields
    primaryTextTheme: TextTheme(
      headline6: TextStyle(
        color: Colors.white
      ),
      caption: TextStyle(
        color: Colors.white
      ),
      button: TextStyle(
        color: Colors.white,
        backgroundColor: BeldexPalette.tealWithOpacity, // button indigo background color
        decorationColor: BeldexPalette.tealWithOpacity // button indigo border color
      ),
      headline5: TextStyle(
        color: PaletteDark.darkThemeGrey // account list tile, contact page
      ),
      subtitle2: TextStyle(
        color: PaletteDark.darkThemeGrey ,// filters
        backgroundColor:PaletteDark.saveAndCopyButtonColor1
      ),
        subtitle1: TextStyle(
        color: Palette.blueGrey // transaction raw, trade raw
      ),
      overline: TextStyle(
        color: PaletteDark.darkThemeGrey // standard list row, transaction details
      )
    ),
    toggleButtonsTheme: ToggleButtonsThemeData(
      selectedColor: BeldexPalette.teal,
      disabledColor: Palette.wildDarkBlue,
      color: PaletteDark.switchBackground,
      borderColor: PaletteDark.darkThemeMidGrey
    ),
    selectedRowColor: Colors.grey,//BeldexPalette.tealWithOpacity,
    dividerColor: Colors.white,//PaletteDark.darkThemeDarkGrey,
    dividerTheme: DividerThemeData(
      color: PaletteDark.darkThemeGreyWithOpacity
    ),
    cardColor: PaletteDark.cardBackgroundColor,
    cardTheme: CardTheme(
      color: PaletteDark.cardColor,
      shadowColor: PaletteDark.cardButtonColor,
    ),
    primaryIconTheme: IconThemeData(
      color: PaletteDark.darkThemeViolet
    ),
  );

}