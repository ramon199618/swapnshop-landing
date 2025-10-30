import 'package:flutter/foundation.dart';

class FeatureFlags {
  // Dummy-Daten nur im Debug-Modus erlauben
  static const bool useDummies = false; // Echte Supabase-Integration aktiviert

  // Payment-Integration aktivieren (für Produktion)
  static const bool enablePayments = true;

  // Premium-Features aktivieren
  static const bool enablePremium = true;

  // Supabase-Integration aktivieren
  static const bool enableSupabase = true;

  // Store-Features aktivieren
  static const bool enableStores = true;

  // Community-Features aktivieren
  static const bool enableCommunities = true;

  // Banner-Rotation aktivieren
  static const bool enableBannerRotation = true;

  // Debug-Logging nur im Debug-Modus
  static const bool enableDebugLogging = kDebugMode;

  // Performance-Monitoring im Release
  static const bool enablePerformanceMonitoring = !kDebugMode;

  // Produktions-Modus aktivieren
  static bool get isProduction =>
      const bool.fromEnvironment('PRODUCTION', defaultValue: false);

  // Dummy-Daten basierend auf Environment
  static bool get shouldUseDummies => useDummies && kDebugMode && !isProduction;

  // Monitoring
  static const bool enableSentry =
      false; // Setze auf true um Sentry zu aktivieren
  static const String sentryDsn = ''; // Sentry DSN - leer = deaktiviert
  static const bool enableAnalytics =
      false; // Setze auf true um Analytics zu aktivieren
  static const bool enableCrashReporting =
      false; // Setze auf true um Crash-Reporting zu aktivieren
}
