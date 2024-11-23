import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    primaryColor: Colors.white24,
    scaffoldBackgroundColor: const Color(0xFFFAFAFA),
    colorScheme: const ColorScheme.light(
      primary: Colors.blueAccent,
      secondary: Colors.cyan,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFFAFAFA),
      elevation: 2.0,
      iconTheme: const IconThemeData(color: Colors.blueAccent),
      titleTextStyle: TextStyle(
        color: Colors.blueGrey[900],
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(fontSize: 16.0, color: Colors.blueGrey[800]),
      bodyMedium: TextStyle(fontSize: 14.0, color: Colors.blueGrey[700]),
      displayLarge: const TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
      ),
      titleLarge: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.w600,
        color: Colors.blueGrey[900],
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.blueAccent,
        textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blueAccent,
        side: const BorderSide(color: Colors.blueAccent),
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.blueAccent),
      ),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFFFFFFFF),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: Color(0xFFFAFAFA),
      elevation: 4.0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
      elevation: 4.0,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    primaryColor: Colors.cyan,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: Colors.cyan,
      secondary: Colors.blueAccent,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      surface: Colors.grey,
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      elevation: 4.0,
      iconTheme: IconThemeData(color: Colors.blueAccent),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(fontSize: 16.0, color: Colors.grey[50]),
      bodyMedium: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
      displayLarge: const TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
        color: Colors.cyan,
      ),
      titleLarge: const TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.cyan,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.cyan,
        textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.cyan,
        side: const BorderSide(color: Colors.cyan),
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade800),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.cyan),
      ),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF121212),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: Color(0xFF121212),
      elevation: 4.0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.cyan,
      foregroundColor: Colors.white,
      elevation: 4.0,
    ),
  );
}
