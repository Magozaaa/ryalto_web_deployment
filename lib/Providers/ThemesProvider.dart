// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:rightnurse/Helper/StorageManager.dart';

class ThemesProvider with ChangeNotifier {


  Map<int, Color> colorCodes = {
    50: const Color.fromRGBO(28, 39, 85, .1),
    100: const Color.fromRGBO(28, 39, 85, .2),
    200: const Color.fromRGBO(28, 39, 85, .3),
    300: const Color.fromRGBO(28, 39, 85, .4),
    400: const Color.fromRGBO(28, 39, 85, .5),
    500: const Color.fromRGBO(28, 39, 85, .6),
    600: const Color.fromRGBO(28, 39, 85, .7),
    700: const Color.fromRGBO(28, 39, 85, .8),
    800: const Color.fromRGBO(28, 39, 85, .9),
    900: const Color.fromRGBO(28, 39, 85, 1),
  };// Green color code: FF93cd48MaterialColor customColor = MaterialColor(0xFF93cd48, colorCodes);
  bool _isDarkTheme = false;
  bool get isDarkTheme =>this._isDarkTheme;

  setIsDarkThemeGetter(bool isDark){
    _isDarkTheme = isDark;
  }

  final darkTheme = ThemeData(
    pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }
    ),
    brightness: Brightness.dark,
    primaryColor: const Color(0xff1c2755),
    accentColor: const Color(0xFF3558d6),
    backgroundColor: const Color(0xFF777d95),
    scaffoldBackgroundColor: const Color(0xFF131d3e),
    primarySwatch: const MaterialColor(0xff1c2755,{
      50: Color.fromRGBO(28, 39, 85, .1),
      100: Color.fromRGBO(28, 39, 85, .2),
      200: Color.fromRGBO(28, 39, 85, .3),
      300: Color.fromRGBO(28, 39, 85, .4),
      400: Color.fromRGBO(28, 39, 85, .5),
      500: Color.fromRGBO(28, 39, 85, .6),
      600: Color.fromRGBO(28, 39, 85, .7),
      700: Color.fromRGBO(28, 39, 85, .8),
      800: Color.fromRGBO(28, 39, 85, .9),
      900: Color.fromRGBO(28, 39, 85, 1),
    }),
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
    visualDensity: VisualDensity.adaptivePlatformDensity,

    appBarTheme: const AppBarTheme(
      color: Color(0xff1c2755),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xff1c2755),
      selectedIconTheme: IconThemeData(
        color: Colors.white
      ),
      unselectedIconTheme: IconThemeData(
        color: Color(0xff777d95)
      ),
      unselectedItemColor: Color(0xff777d95),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Color(0xFF3558d6),
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 12,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 12,
      ),
    ),
    textTheme: ThemeData.light().textTheme.copyWith(
      //   bodyText1: TextStyle(
      //       fontSize: appFontSize['bodyText1']??null,
      //       color: Colors.grey[700],
      //       fontWeight: FontWeight.bold,
      //       fontFamily: 'CairoBold'),
      //   headline1: TextStyle(
      //       color: Colors.white70,
      //       fontSize: appFontSize['headline1']??null,
      //       fontWeight: FontWeight.normal,
      //       fontFamily: 'CairoRegular'),
      //   headline3: TextStyle(
      //       fontSize: appFontSize['headline3']??null,
      //       color: Colors.grey[700],
      //       fontWeight: FontWeight.bold,
      //       fontFamily: 'CairoBold'),
      //   bodyText2: TextStyle(
      //       fontSize: appFontSize['bodyText2']??null,
      //       color: Colors.grey[900],
      //       fontWeight: FontWeight.bold,
      //       fontFamily: 'CairoSemiBold'),
      //   headline2: TextStyle(
      //       fontSize: appFontSize['headline2']??null,
      //       color: Colors.grey[800],
      //       // fontWeight: FontWeight.bold,
      //       fontFamily: 'CairoBold'),
      //   headline4: TextStyle(
      //       fontSize: appFontSize['headline4']??null,
      //       color: Colors.grey[700],
      //       fontWeight: FontWeight.bold,
      //       fontFamily: 'CairoBold'),
      // subtitle1: TextStyle(
      //     fontSize: appFontSize['subtitle1']??null,
      //     color: Colors.grey[700],
      //     fontWeight: FontWeight.bold,
      //     fontFamily: 'CairoBold'),
      // button: TextStyle(
      //     fontSize: appFontSize['button']??null,
      //     color: Colors.grey[700],
      //     fontWeight: FontWeight.bold,
      //     fontFamily: 'CairoBold'),
      // caption: TextStyle(
      //     fontSize: appFontSize['caption']??null,
      //     color: Colors.grey[700],
      //     fontWeight: FontWeight.bold,
      //     fontFamily: 'CairoBold'),
      // headline5: TextStyle(
      //     fontSize: appFontSize['headline5']??null,
      //     color: Colors.grey[400],
      //     fontWeight: FontWeight.bold,
      //     fontFamily: 'CairoBold'),
      // headline6: TextStyle(
      //     fontSize: appFontSize['headline6']??null,
      //     color: Colors.grey[700],
      //     fontWeight: FontWeight.bold,
      //     fontFamily: 'CairoBold'),
      // overline: TextStyle(
      //     fontSize: appFontSize['overline']??null,
      //     color: Colors.grey[400],
      //     fontWeight: FontWeight.bold,
      //     fontFamily: 'CairoBold'),
      // subtitle2: TextStyle(
      //     fontSize: appFontSize['subtitle2']??null,
      //     color: Colors.grey[700],
      //     fontWeight: FontWeight.bold,
      //     fontFamily: 'CairoBold'),
    ),
  );

  final lightTheme = ThemeData(
    pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }
    ),
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    highlightColor: Colors.transparent,
    backgroundColor: const Color(0xFFFFFFFF),
    splashColor: Colors.transparent,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: const AppBarTheme(
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedIconTheme:
      IconThemeData(color: Colors.blue, size: 25),
      unselectedIconTheme:
      IconThemeData(color: Colors.black45, size: 25),
      selectedItemColor: Colors.blue,
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 12,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 12,
      ),
    ),
    textTheme: ThemeData.light().textTheme.copyWith(
      //   bodyText1: TextStyle(
      //       fontSize: appFontSize['bodyText1']??null,
      //       color: Colors.grey[700],
      //       fontWeight: FontWeight.bold,
      //       fontFamily: 'CairoBold'),
      //   headline1: TextStyle(
      //       color: Colors.white70,
      //       fontSize: appFontSize['headline1']??null,
      //       fontWeight: FontWeight.normal,
      //       fontFamily: 'CairoRegular'),
      //   headline3: TextStyle(
      //       fontSize: appFontSize['headline3']??null,
      //       color: Colors.grey[700],
      //       fontWeight: FontWeight.bold,
      //       fontFamily: 'CairoBold'),
      //   bodyText2: TextStyle(
      //       fontSize: appFontSize['bodyText2']??null,
      //       color: Colors.grey[900],
      //       fontWeight: FontWeight.bold,
      //       fontFamily: 'CairoSemiBold'),
      //   headline2: TextStyle(
      //       fontSize: appFontSize['headline2']??null,
      //       color: Colors.grey[800],
      //       // fontWeight: FontWeight.bold,
      //       fontFamily: 'CairoBold'),
      //   headline4: TextStyle(
      //       fontSize: appFontSize['headline4']??null,
      //       color: Colors.grey[700],
      //       fontWeight: FontWeight.bold,
      //       fontFamily: 'CairoBold'),
      // subtitle1: TextStyle(
      //     fontSize: appFontSize['subtitle1']??null,
      //     color: Colors.grey[700],
      //     fontWeight: FontWeight.bold,
      //     fontFamily: 'CairoBold'),
      // button: TextStyle(
      //     fontSize: appFontSize['button']??null,
      //     color: Colors.grey[700],
      //     fontWeight: FontWeight.bold,
      //     fontFamily: 'CairoBold'),
      // caption: TextStyle(
      //     fontSize: appFontSize['caption']??null,
      //     color: Colors.grey[700],
      //     fontWeight: FontWeight.bold,
      //     fontFamily: 'CairoBold'),
      // headline5: TextStyle(
      //     fontSize: appFontSize['headline5']??null,
      //     color: Colors.grey[400],
      //     fontWeight: FontWeight.bold,
      //     fontFamily: 'CairoBold'),
      // headline6: TextStyle(
      //     fontSize: appFontSize['headline6']??null,
      //     color: Colors.grey[700],
      //     fontWeight: FontWeight.bold,
      //     fontFamily: 'CairoBold'),
      // overline: TextStyle(
      //     fontSize: appFontSize['overline']??null,
      //     color: Colors.grey[400],
      //     fontWeight: FontWeight.bold,
      //     fontFamily: 'CairoBold'),
      // subtitle2: TextStyle(
      //     fontSize: appFontSize['subtitle2']??null,
      //     color: Colors.grey[700],
      //     fontWeight: FontWeight.bold,
      //     fontFamily: 'CairoBold'),
    ),
  );

  ThemeData _themeData;
  ThemeData getTheme() => _themeData;

  ThemesProvider() {
    StorageManager.readData('themeMode').then((value) {
      // print('value read from storage: ' + value.toString());
      var themeMode = value ?? 'light';
      if (themeMode == 'light') {
        _themeData = lightTheme;
        setIsDarkThemeGetter(false);

      } else {
        print('setting dark theme');
        _themeData = darkTheme;
        setIsDarkThemeGetter(true);
      }
      notifyListeners();
    });
  }

  void setDarkMode() async {
    _themeData = darkTheme;
    StorageManager.saveData('themeMode', 'dark');
    setIsDarkThemeGetter(true);
    notifyListeners();
  }

  void setLightMode() async {
    _themeData = lightTheme;
    StorageManager.saveData('themeMode', 'light');
    setIsDarkThemeGetter(false);

    notifyListeners();
  }
}