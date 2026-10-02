import 'package:flutter/material.dart';

const Color primary = Color(0xFF2F993F);
const Color primaryLight = Color.fromARGB(255, 70, 201, 89);
const Color primaryDark = Color(0xFF1C5C26);

const Color secondary = Colors.orange;
const Color secondaryDark = Colors.deepOrange;
const Color secondaryLight = Color.fromRGBO(241, 199, 85, 1);

ThemeData lightTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primary,
    secondary: secondaryDark,

    brightness: Brightness.light,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryDark,
    foregroundColor: Colors.white,
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.green[900]),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.green[900]),
    bodySmall: TextStyle(fontSize: 14, color: Colors.green[900]),
  ),
);

ThemeData darkTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryLight,
    secondary: secondary,
    brightness: Brightness.dark,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 58, 58, 58),
    foregroundColor: Colors.white,
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.green[50]),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.green[50]),
    bodySmall: TextStyle(fontSize: 14, color: Colors.green[50]),
  ),
);
