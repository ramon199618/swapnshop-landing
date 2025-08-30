import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  // Light Theme Colors
  static const Color accent = Colors.orangeAccent;
  static const Color primary = Colors.deepOrange;
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Colors.white;
  static const Color lightOnSurface = Colors.black87;
  static const Color lightOnBackground = Colors.black87;
  static const Color lightCard = Colors.white;
  static const Color lightDivider = Colors.grey;
  static const Color lightText = Colors.black87;
  static const Color lightTextSecondary = Colors.grey;
  static const Color lightIcon = Colors.grey;

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnSurface = Colors.white;
  static const Color darkOnBackground = Colors.white;
  static const Color darkCard = Color(0xFF2C2C2C);
  static const Color darkDivider = Colors.grey;
  static const Color darkText = Colors.white;
  static const Color darkTextSecondary = Colors.grey;
  static const Color darkIcon = Colors.grey;

  // Background Colors
  static const Color backgroundSoftRed = Color.fromRGBO(255, 87, 34, 0.01);
  static const Color backgroundGradientStart =
      Color.fromRGBO(255, 87, 34, 0.01);
  static const Color backgroundGradientEnd = Color(0xFFFFFFFF);

  // Gradient Colors
  static const Color gradientStart = Color(0xFFFF5722);
  static const Color gradientEnd = Color(0xFFFF9800);

  // Status Colors
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;
  static const Color info = Colors.blue;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: Color(0xFFFFFFFF),
        onSurface: Colors.black87,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      cardTheme: const CardThemeData(
        color: AppColors.lightCard,
        elevation: 2,
        shadowColor: Colors.black12,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightText,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.lightText),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.lightText),
        bodyMedium: TextStyle(color: AppColors.lightText),
        titleLarge: TextStyle(color: AppColors.lightText),
        titleMedium: TextStyle(color: AppColors.lightText),
        titleSmall: TextStyle(color: AppColors.lightText),
      ),
      iconTheme: const IconThemeData(color: AppColors.lightIcon),
      dividerTheme: const DividerThemeData(color: AppColors.lightDivider),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardTheme: const CardThemeData(
        color: AppColors.darkCard,
        elevation: 2,
        shadowColor: Colors.black26,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkText),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.darkText),
        bodyMedium: TextStyle(color: AppColors.darkText),
        titleLarge: TextStyle(color: AppColors.darkText),
        titleMedium: TextStyle(color: AppColors.darkText),
        titleSmall: TextStyle(color: AppColors.darkText),
      ),
      iconTheme: const IconThemeData(color: AppColors.darkIcon),
      dividerTheme: const DividerThemeData(color: AppColors.darkDivider),
    );
  }
}
