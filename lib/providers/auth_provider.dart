import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _currentUser = AuthService.getCurrentUser();

    // Listen to auth state changes
    AuthService.authStateChanges.listen((data) {
      _currentUser = data.session?.user;
      _error = null;
      notifyListeners();
    });
  }

  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await AuthService.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = response.user;
        _setLoading(false);
        return true;
      } else {
        _setError('Registrierung fehlgeschlagen');
        return false;
      }
    } catch (e) {
      _setError('Registrierung fehlgeschlagen: ${e.toString()}');
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await AuthService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = response.user;
        _setLoading(false);
        return true;
      } else {
        _setError('Anmeldung fehlgeschlagen');
        return false;
      }
    } catch (e) {
      _setError('Anmeldung fehlgeschlagen: ${e.toString()}');
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);

    try {
      await AuthService.signOut();
      _currentUser = null;
      _setLoading(false);
    } catch (e) {
      _setError('Abmeldung fehlgeschlagen: ${e.toString()}');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
