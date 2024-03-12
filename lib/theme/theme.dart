import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    // Define the primary color
    primaryColor: Colors.blue,
    // Define the accent color
    hintColor: Colors.deepOrange,
    // Define the typography
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black),
      bodyMedium: TextStyle(fontSize: 14.0, color: Colors.grey),
      displayLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black),
      // Add more text styles as needed
    ),
    // Define the button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      ),
    ),
    // Define the card theme
    cardTheme: CardTheme(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    // Define the bottom app bar theme
    bottomAppBarTheme: const BottomAppBarTheme(
      color: Colors.orangeAccent,
      elevation: 0.0, // Remove elevation
    ),
    // Define the floating action button theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    // Define the primary color
    primaryColor: Colors.black,
    // Define the accent color
    hintColor: Colors.orange,
    // Define the typography
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16.0, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 14.0, color: Colors.grey),
      displayLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
      // Add more text styles as needed
    ),
    // Define the button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      ),
    ),
    // Define the card theme
    cardTheme: CardTheme(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    // Define the bottom app bar theme
    bottomAppBarTheme: const BottomAppBarTheme(
      color: Colors.black,
      elevation: 0.0, // Remove elevation
    ),
    // Define the floating action button theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.black,
    ),
  );
}
