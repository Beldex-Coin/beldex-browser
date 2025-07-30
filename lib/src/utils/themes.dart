import 'package:flutter/material.dart';
import 'palette.dart';

class Themes {

  static final ThemeData lightTheme = ThemeData(
    //fontFamily: 'OpenSans',
    brightness: Brightness.light,
    scaffoldBackgroundColor: Palette.lightThemeBlack,
    appBarTheme: AppBarTheme(
      backgroundColor: Palette.lightThemeBlack,
    ),
    hintColor: Colors.grey[500],
    focusColor: Palette.lightGrey, // focused and enabled border color for text fields
    primaryTextTheme: TextTheme(
  titleLarge: TextStyle(
    color: BeldexPalette.black,
  ),
  bodySmall: TextStyle(
    color: BeldexPalette.black,
  ),
  labelLarge: TextStyle(
    color: Colors.white,
    backgroundColor: BeldexPalette.tealWithOpacity,
    decorationColor: BeldexPalette.teal,
  ),
  headlineSmall: TextStyle(
    color: Palette.darkThemeGrey,
  ),
  titleSmall: TextStyle(
    color: Palette.wildDarkBlue,
    backgroundColor: Palette.saveAndCopyButtonColor1,
  ),
  bodyLarge: TextStyle(
    color: BeldexPalette.black,
  ),
  labelSmall: TextStyle(
    color: PaletteDark.darkThemeCloseButton,
  ),
),
    toggleButtonsTheme: ToggleButtonsThemeData(
      selectedColor: BeldexPalette.teal,
      disabledColor: Palette.wildDarkBlue,
      color: Palette.switchBackground,
      borderColor: Palette.switchBorder
    ),
   // selectedRowColor: Colors.grey,//BeldexPalette.tealWithOpacity,
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
    ), //colorScheme: ColorScheme(background: Palette.lightThemeBackground, brightness: null, primary: null
   // ),
  );


  static final ThemeData darkTheme = ThemeData(
    //fontFamily: 'OpenSans',
    brightness: Brightness.dark,
    scaffoldBackgroundColor: PaletteDark.darkThemeBlack,
    appBarTheme: AppBarTheme(
      backgroundColor: PaletteDark.darkThemeBlack,
    ),
    hintColor: PaletteDark.darkThemeGrey,
    focusColor: PaletteDark.darkThemeGreyWithOpacity, // focused and enabled border color for text fields
    primaryTextTheme: TextTheme(
  titleLarge: TextStyle(
    color: Colors.white, // replaces headline6
  ),
  bodySmall: TextStyle(
    color: Colors.white, // replaces caption
  ),
  labelLarge: TextStyle(
    color: Colors.white, // replaces button
    backgroundColor: BeldexPalette.tealWithOpacity, // button background
    decorationColor: BeldexPalette.tealWithOpacity, // button border color
  ),
  headlineSmall: TextStyle(
    color: PaletteDark.darkThemeGrey, // replaces headline5
  ),
  titleSmall: TextStyle(
    color: PaletteDark.darkThemeGrey, // replaces subtitle2
    backgroundColor: PaletteDark.saveAndCopyButtonColor1,
  ),
  bodyLarge: TextStyle(
    color: Palette.blueGrey, // replaces subtitle1
  ),
  labelSmall: TextStyle(
    color: PaletteDark.darkThemeGrey, // replaces overline
  ),
),
    toggleButtonsTheme: ToggleButtonsThemeData(
      selectedColor: BeldexPalette.teal,
      disabledColor: Palette.wildDarkBlue,
      color: PaletteDark.switchBackground,
      borderColor: PaletteDark.darkThemeMidGrey
    ),
   // selectedRowColor: Colors.grey,//BeldexPalette.tealWithOpacity,
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
    ), //colorScheme: ColorScheme(background: PaletteDark.darkThemeBackground),
  );

}