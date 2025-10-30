import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Get current user
  static User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: name != null ? {'name': name} : null,
    );

    // Create user profile after successful signup
    if (response.user != null) {
      final userProfile = UserModel(
        id: response.user!.id,
        name: name ?? email.split('@')[0],
        email: email,
      );

      try {
        await DatabaseService.createUserProfile(userProfile);
      } catch (e) {
        debugPrint('⚠️ Error creating user profile: $e');
        // Don't throw here, as the user is already created
      }
    }

    return response;
  }

  // Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.swapshop://reset-password/',
      );
    } catch (e) {
      throw Exception('Passwort-Reset fehlgeschlagen: $e');
    }
  }

  // Update password
  static Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // Update user profile
  static Future<void> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    await _client.auth.updateUser(
      UserAttributes(
        data: {
          if (name != null) 'name': name,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        },
      ),
    );
  }

  // Get auth state changes stream
  static Stream<AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange;
  }

  // Check if user is authenticated
  static bool get isAuthenticated => _client.auth.currentUser != null;

  // Get user ID
  static String? get userId => _client.auth.currentUser?.id;

  // Enhanced sign in with email
  static Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Anmeldung fehlgeschlagen - Benutzer nicht gefunden');
      }
      
      debugPrint('✅ Benutzer erfolgreich angemeldet: ${response.user!.email}');
    } catch (e) {
      debugPrint('❌ Anmeldung fehlgeschlagen: $e');
      
      // Spezifische Fehlermeldungen
      if (e.toString().contains('Invalid login credentials')) {
        throw Exception('Ungültige E-Mail-Adresse oder Passwort');
      } else if (e.toString().contains('Email not confirmed')) {
        throw Exception('Bitte bestätige zuerst deine E-Mail-Adresse');
      } else if (e.toString().contains('Too many requests')) {
        throw Exception('Zu viele Anmeldeversuche. Bitte warte einen Moment');
      } else if (e.toString().contains('Invalid email')) {
        throw Exception('Ungültige E-Mail-Adresse');
      } else if (e.toString().contains('Password should be at least')) {
        throw Exception('Passwort muss mindestens 6 Zeichen lang sein');
      } else if (e.toString().contains('Network error') || e.toString().contains('Connection')) {
        throw Exception('Netzwerkfehler. Bitte überprüfe deine Internetverbindung');
      } else {
        throw Exception('Anmeldung fehlgeschlagen: ${e.toString()}');
      }
    }
  }

  // Enhanced sign up with email
  static Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
      );

      if (response.user == null) {
        throw Exception('Registrierung fehlgeschlagen - Benutzer konnte nicht erstellt werden');
      }

      debugPrint('✅ Benutzer erfolgreich registriert: ${response.user!.email}');

      // Create user profile
      final userProfile = UserModel(
        id: response.user!.id,
        name: name ?? email.split('@')[0],
        email: email,
      );

      await DatabaseService.createUserProfile(userProfile);
      debugPrint('✅ Benutzerprofil erfolgreich erstellt');
    } catch (e) {
      debugPrint('❌ Registrierung fehlgeschlagen: $e');
      
      // Spezifische Fehlermeldungen
      if (e.toString().contains('User already registered')) {
        throw Exception('Diese E-Mail-Adresse ist bereits registriert');
      } else if (e.toString().contains('Invalid email')) {
        throw Exception('Ungültige E-Mail-Adresse');
      } else if (e.toString().contains('Password should be at least')) {
        throw Exception('Passwort muss mindestens 6 Zeichen lang sein');
      } else if (e.toString().contains('Password is too weak')) {
        throw Exception('Passwort ist zu schwach. Verwende mindestens 8 Zeichen mit Buchstaben und Zahlen');
      } else if (e.toString().contains('Network error') || e.toString().contains('Connection')) {
        throw Exception('Netzwerkfehler. Bitte überprüfe deine Internetverbindung');
      } else {
        throw Exception('Registrierung fehlgeschlagen: ${e.toString()}');
      }
    }
  }

  // Google Sign In
  static Future<void> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.swapshop://login-callback/',
      );
    } catch (e) {
      throw Exception('Google-Anmeldung fehlgeschlagen: $e');
    }
  }

  // Apple Sign In
  static Future<void> signInWithApple() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.swapshop://login-callback/',
      );
    } catch (e) {
      throw Exception('Apple-Anmeldung fehlgeschlagen: $e');
    }
  }

  // Get current user profile
  static Future<UserModel?> getCurrentUserProfile() async {
    return await DatabaseService.getCurrentUserProfile();
  }

  // Update user profile
  static Future<void> updateUserProfile(UserModel profile) async {
    await DatabaseService.updateUserProfile(profile);
  }
}
