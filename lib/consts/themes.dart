import 'package:flutter/material.dart';

import 'consts.dart';

class Themes {
  ThemeData darkTheme = ThemeData(
    dialogBackgroundColor: Constants.kDarkThemeBGLightColor,
    canvasColor: Constants.kDarkThemeBGColor,
    drawerTheme: const DrawerThemeData(
        backgroundColor: Constants.kDarkThemeBGLightColor),
    fontFamily: 'Poppins',
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Constants.kDarkThemeAccentColor,
    ),
    appBarTheme: const AppBarTheme(
        foregroundColor: Constants.kDarkThemeTextColor,
        backgroundColor: Constants.kDarkThemeBGColor),
    textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Constants.kDarkThemeAccentColor),

    textTheme: const TextTheme(
      bodyText2: TextStyle(color: Constants.kDarkThemeTextColor),
      headline6: TextStyle(color: Constants.kDarkThemeTextColor),
      bodyText1: TextStyle(color: Constants.kDarkThemeTextColorAlternative),
      subtitle1: TextStyle(color: Constants.kDarkThemeTextColorAlternative),
      headline5: TextStyle(color: Constants.kDarkThemeTextColor),
    ),

    primaryTextTheme: const TextTheme(
      headline6: TextStyle(color: Constants.kDarkThemeTextColor),
      bodyText2: TextStyle(color: Constants.kRedColor),
      bodyText1: TextStyle(color: Constants.kRedColor),
    ),

    //accentColor: Colors.red,
    brightness: Brightness.dark,
    primaryColor: Colors.red,

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Constants.kWhiteBgColor,
        backgroundColor: Constants.kDarkThemeAccentColor,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        overlayColor:
            MaterialStateColor.resolveWith((states) => Colors.transparent),
        foregroundColor: MaterialStateColor.resolveWith(
            (states) => Constants.kDarkThemeTextColor),
      ),
    ),
    scaffoldBackgroundColor: Constants.kDarkThemeBGColor,
    iconTheme: const IconThemeData(color: Constants.kDarkThemeTextColor),
    //accentIconTheme: IconThemeData(color: Constants.kDarkThemeWhiteAccentColor),
    primaryIconTheme:
        const IconThemeData(color: Constants.kDarkThemeWhiteAccentColor),
  );

//LIGHT THEME
  ThemeData lightTheme = ThemeData(
    dialogBackgroundColor: Constants.kWhiteBgColor,
    canvasColor: Constants.kGrayBgColor,
    drawerTheme:
        const DrawerThemeData(backgroundColor: Constants.kWhiteBgColor),
    fontFamily: 'Poppins',
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Constants.kAccentColor),
    appBarTheme: const AppBarTheme(
        foregroundColor: Constants.kAlternativeTextColor,
        backgroundColor: Constants.kGrayBgColor),
    textSelectionTheme:
        const TextSelectionThemeData(cursorColor: Constants.kAccentColor),
    //primaryColor: Colors.red,
    textTheme: const TextTheme(
      headline1: TextStyle(color: Constants.kRedColor),
      headline2: TextStyle(color: Constants.kRedColor),
      headline3: TextStyle(color: Constants.kRedColor),
      headline4: TextStyle(color: Constants.kRedColor),
      headline5: TextStyle(color: Constants.kBlackTextOnWhiteBGColor),

      //caption: TextStyle(color: Constants.kRedColor),
      overline: TextStyle(color: Constants.kRedColor),
      bodyText1: TextStyle(color: Constants.kBlackTextOnWhiteBGColor),
      bodyText2: TextStyle(color: Constants.kAlternativeTextColor),
      headline6: TextStyle(color: Constants.kAlternativeTextColor),
      subtitle1: TextStyle(color: Constants.kBlackTextOnWhiteBGColor),
    ),
    primaryTextTheme: const TextTheme(
      headline6: TextStyle(color: Constants.kAlternativeTextColor),
      bodyText2: TextStyle(color: Constants.kAlternativeTextColor),
      bodyText1: TextStyle(color: Constants.kAlternativeTextColor),
    ),

    iconTheme: const IconThemeData(color: Constants.kAlternativeTextColor),
    //accentIconTheme: IconThemeData(color: Constants.kBlackTextOnWhiteBGColor),
    primaryIconTheme:
        const IconThemeData(color: Constants.kBlackTextOnWhiteBGColor),

    brightness: Brightness.light,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Constants.kLightGrayColor2,
        backgroundColor: Constants.kAccentColor,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        overlayColor:
            MaterialStateColor.resolveWith((states) => Colors.transparent),
        foregroundColor: MaterialStateColor.resolveWith(
            (states) => Constants.kAlternativeTextColor),
      ),
    ),
    scaffoldBackgroundColor: Constants.kGrayBgColor,
  );
}
