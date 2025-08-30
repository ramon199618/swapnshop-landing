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
        throw Exception('Anmeldung fehlgeschlagen');
      }
    } catch (e) {
      throw Exception('Anmeldung fehlgeschlagen: $e');
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
        throw Exception('Registrierung fehlgeschlagen');
      }

      // Create user profile
      final userProfile = UserModel(
        id: response.user!.id,
        name: name ?? email.split('@')[0],
        email: email,
      );

      await DatabaseService.createUserProfile(userProfile);
    } catch (e) {
      throw Exception('Registrierung fehlgeschlagen: $e');
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
