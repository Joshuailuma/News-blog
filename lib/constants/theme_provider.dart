import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode? themeMode = ThemeMode.system;
  bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get isLightMode => themeMode == ThemeMode.light;

  void toogleDarkTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : null;
    notifyListeners();
  }

  void toogleLightTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.light : null;
    notifyListeners();
  }
}

class MyThemes {
  static final darkTheme = ThemeData(
    primaryColor: Colors.black,
    colorScheme: ColorScheme.dark(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    cardColor: Colors.white,
  );

  static final lightTheme = ThemeData(
    primaryColor: Colors.white,
    colorScheme: ColorScheme.light(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    cardColor: Colors.black,
  );
}
