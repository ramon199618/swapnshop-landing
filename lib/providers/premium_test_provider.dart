import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumTestProvider extends ChangeNotifier {
  static const String _premiumTestKey = 'premium_test_mode';
  bool _isPremiumTestMode = false;
  bool _isPremiumTestEnabled = false;

  bool get isPremiumTestMode => _isPremiumTestMode;
  bool get isPremiumTestEnabled => _isPremiumTestEnabled;

  PremiumTestProvider() {
    _loadPremiumTestMode();
  }

  Future<void> _loadPremiumTestMode() async {
    if (kDebugMode) {
      final prefs = await SharedPreferences.getInstance();
      _isPremiumTestMode = prefs.getBool(_premiumTestKey) ?? false;
      _isPremiumTestEnabled = true;
      notifyListeners();
    }
  }

  Future<void> togglePremiumTestMode() async {
    if (!kDebugMode) return;
    
    _isPremiumTestMode = !_isPremiumTestMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumTestKey, _isPremiumTestMode);
    notifyListeners();
  }

  Future<void> setPremiumTestMode(bool isPremium) async {
    if (!kDebugMode) return;
    
    _isPremiumTestMode = isPremium;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumTestKey, _isPremiumTestMode);
    notifyListeners();
  }

  // Reset to free mode
  Future<void> resetToFreeMode() async {
    if (!kDebugMode) return;
    
    _isPremiumTestMode = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumTestKey, false);
    notifyListeners();
  }
}
