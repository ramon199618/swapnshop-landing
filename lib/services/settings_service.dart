import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String keyLanguage = 'language';
  static const String keyNotifications = 'notifications_enabled';
  static const String keyLocation = 'location_enabled';
  static const String keyCategory = 'default_category';
  static const String keyRadius = 'default_radius';

  // Sprache
  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLanguage) ?? 'de';
  }

  Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLanguage, lang);
  }

  // Benachrichtigungen
  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyNotifications) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyNotifications, enabled);
  }

  // Standortfreigabe
  Future<bool> getLocationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyLocation) ?? false;
  }

  Future<void> setLocationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyLocation, enabled);
  }

  // Standard-Kategorie
  Future<String> getDefaultCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyCategory) ?? 'Velotausch';
  }

  Future<void> setDefaultCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyCategory, category);
  }

  // Radius
  Future<double> getDefaultRadius() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(keyRadius) ?? 25.0;
  }

  Future<void> setDefaultRadius(double radius) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(keyRadius, radius);
  }
}
