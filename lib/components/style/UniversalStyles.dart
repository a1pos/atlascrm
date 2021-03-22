import 'package:flutter/material.dart';

class UniversalStyles {
  static Color themeColor = Color.fromRGBO(54, 179, 170, 1.0);
  static Color backgroundColor = Color.fromARGB(255, 250, 251, 255);
  static Color actionColor = Color.fromRGBO(54, 179, 170, 1);
}

final ThemeData defaultTheme = _buildDefaultTheme();

ThemeData _buildDefaultTheme() {
  return ThemeData(
    appBarTheme: AppBarTheme(color: UniversalStyles.themeColor),
    primarySwatch: Colors.teal,
    scaffoldBackgroundColor: UniversalStyles.backgroundColor,
    cardTheme: CardTheme(color: Colors.white),
    brightness: Brightness.light,
    fontFamily: "LatoRegular",
    buttonColor: UniversalStyles.actionColor,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: UniversalStyles.actionColor),
    iconTheme: IconThemeData(size: 25, color: Colors.black, opacity: 1),
  );
}
