import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  // Light Theme Colors - Landingpage Design
  static const Color primary = Color(0xFF4A69FF); // Kräftiges Blau
  static const Color secondary = Color(0xFF6A4DFF); // Violett-Blau
  static const Color accent =
      Color(0xFF4A69FF); // Kräftiges Blau als Akzentfarbe
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

  // Background Colors - Landingpage Design
  static const Color backgroundSoftBlue = Color.fromRGBO(74, 105, 255, 0.1);
  static const Color backgroundGradientStart =
      Color.fromRGBO(74, 105, 255, 0.1);
  static const Color backgroundGradientEnd = Color(0xFFFFFFFF);

  // Gradient Colors - Landingpage Design
  static const Color gradientStart = Color(0xFF4A69FF); // Kräftiges Blau
  static const Color gradientEnd = Color(0xFF6A4DFF); // Violett-Blau

  // Status Colors
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;
  static const Color info = Colors.blue;

  // Swap&Shop specific action colors (distinct from Tinder)
  static const Color likeAction =
      Color(0xFF10B981); // Emerald green for "interested"
  static const Color dislikeAction =
      Color(0xFF6B7280); // Gray for "not interested"
  static const Color contactAction = Color(0xFFF59E0B); // Amber for "contact"
  static const Color likeActionLight = Color(0xFFD1FAE5); // Light emerald
  static const Color dislikeActionLight = Color(0xFFF3F4F6); // Light gray
  static const Color contactActionLight = Color(0xFFFEF3C7); // Light amber

  // High Contrast Colors for better visibility
  static const Color textOnWhite = Color(0xFF1A1A1A); // Dark text on white
  static const Color textOnBlue = Colors.white; // White text on blue gradient
  static const Color textOnLight =
      Color(0xFF2C2C2C); // Dark text on light backgrounds
  static const Color textSecondary = Color(0xFF666666); // Secondary text
  static const Color iconOnWhite = Color(0xFF424242); // Icons on white
  static const Color iconOnBlue = Colors.white; // Icons on blue gradient
  static const Color borderLight = Color(0xFFE0E0E0); // Light borders
  static const Color backgroundLight = Color(0xFFF8F9FA); // Light background
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
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
        bodyLarge: TextStyle(color: AppColors.textOnWhite),
        bodyMedium: TextStyle(color: AppColors.textOnWhite),
        titleLarge: TextStyle(color: AppColors.textOnWhite),
        titleMedium: TextStyle(color: AppColors.textOnWhite),
        titleSmall: TextStyle(color: AppColors.textOnWhite),
      ),
      iconTheme: const IconThemeData(color: AppColors.iconOnWhite),
      dividerTheme: const DividerThemeData(color: AppColors.borderLight),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: AppColors.textOnWhite),
        hintStyle: TextStyle(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
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
