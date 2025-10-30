class AppLinks {
  // Hauptdomain
  static const String baseUrl = 'https://swapnshop.app';
  static const String apiUrl = 'https://api.swapnshop.app';
  
  // App Store Links (werden nach Upload aktualisiert)
  static const String appStoreUrl = 'https://apps.apple.com/app/swapnshop/id123456789';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.ramonbieri.swapnshop';
  
  // Rechtliche Links
  static const String privacyUrl = '$baseUrl/privacy';
  static const String termsUrl = '$baseUrl/terms';
  
  // Support & Hilfe
  static const String helpUrl = '$baseUrl/help';
  static const String supportEmail = 'support@swapnshop.app';
  static const String bugReportEmail = 'bugs@swapnshop.app';
  
  // Social Media (optional)
  static const String instagramUrl = 'https://instagram.com/swapnshop_app';
  static const String twitterUrl = 'https://twitter.com/swapnshop_app';
  
  // Build-Anweisungen
  static const String buildInstructions = '''
    Nach App Store Upload aktualisieren:
    1. App Store ID in appStoreUrl eintragen
    2. Google Play Package ID in playStoreUrl eintragen
    3. Social Media Links eintragen (falls gewünscht)
  ''';
}
