import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData theme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6C63FF),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF0F1115),
    textTheme: Typography.whiteMountainView,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.white,
    ),
    listTileTheme: const ListTileThemeData(
      textColor: Colors.white,
      subtitleTextStyle: TextStyle(color: Colors.white70),
      iconColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withOpacity(0.06),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white70),
      floatingLabelStyle: const TextStyle(color: Colors.white),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: const TextStyle(color: Colors.white),
      menuStyle: MenuStyle(
        backgroundColor: MaterialStatePropertyAll(const Color(0xFF1B2233)),
        shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: Color(0x336C63FF),
      iconTheme: WidgetStatePropertyAll(IconThemeData(color: Colors.white)),
      labelTextStyle: WidgetStatePropertyAll(TextStyle(color: Colors.white)),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.white,
      selectionColor: Color(0x446C63FF),
      selectionHandleColor: Colors.white,
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
