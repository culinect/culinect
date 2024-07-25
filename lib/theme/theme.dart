import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    // Define the primary color
    primaryColor: Colors.cyanAccent,
    // Define the scaffold background color
    scaffoldBackgroundColor: Colors.black45,
    // Define the app bar theme
    appBarTheme: const AppBarTheme(
      color: Colors.black45,
      elevation: 0.0,
      iconTheme: IconThemeData(color: Colors.cyanAccent),
      titleTextStyle: TextStyle(
        color: Colors.cyanAccent,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    // Define the typography
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16.0, color: Colors.cyanAccent),
      bodyMedium: TextStyle(fontSize: 14.0, color: Colors.cyanAccent),
      displayLarge: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: Colors.cyanAccent),
      titleLarge: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.cyanAccent),
      // Add more text styles as needed
    ),
    // Define the button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black45,
        backgroundColor: Colors.cyanAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.cyanAccent,
        textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.cyanAccent,
        side: const BorderSide(color: Colors.cyanAccent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
    ),
    // Define the input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.black45,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.cyanAccent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.cyanAccent),
      ),
    ),
    // Define the card theme
    cardTheme: CardTheme(
      color: Colors.black45,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
    // Define the bottom app bar theme
    bottomAppBarTheme: const BottomAppBarTheme(
      color: Colors.black45,
      elevation: 4.0,
    ),
    // Define the floating action button theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.cyanAccent,
      foregroundColor: Colors.black45,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    // Define the primary color
    primaryColor: Colors.black45,
    // Define the scaffold background color
    scaffoldBackgroundColor: Colors.black45,
    // Define the app bar theme
    appBarTheme: const AppBarTheme(
      color: Colors.black45,
      elevation: 0.0,
      iconTheme: IconThemeData(color: Colors.cyanAccent),
      titleTextStyle: TextStyle(
        color: Colors.cyanAccent,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    // Define the typography
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16.0, color: Colors.cyanAccent),
      bodyMedium: TextStyle(fontSize: 14.0, color: Colors.cyanAccent),
      displayLarge: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: Colors.cyanAccent),
      titleLarge: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.cyanAccent),
      // Add more text styles as needed
    ),
    // Define the button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black45,
        backgroundColor: Colors.cyanAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.cyanAccent,
        textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.cyanAccent,
        side: const BorderSide(color: Colors.cyanAccent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
    ),
    // Define the input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.black45,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.cyanAccent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.cyanAccent),
      ),
    ),
    // Define the card theme
    cardTheme: CardTheme(
      color: Colors.black45,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
    // Define the bottom app bar theme
    bottomAppBarTheme: const BottomAppBarTheme(
      color: Colors.black45,
      elevation: 4.0,
    ),
    // Define the floating action button theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.cyanAccent,
      foregroundColor: Colors.black45,
    ),
  );
}
