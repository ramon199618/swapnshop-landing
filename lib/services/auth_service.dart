// import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Dummy User für Entwicklung
  String? _currentUserId = 'dummy_user_123';
  String? _currentUserName = 'Ramon Bieri';

  // Stream<User?> get authStateChanges => _auth.authStateChanges();
  // User? get currentUser => _auth.currentUser;

  // Dummy-Methoden für Entwicklung
  String? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;

  Future<void> signInAnonymously() async {
    // await _auth.signInAnonymously();
    _currentUserId = 'dummy_user_${DateTime.now().millisecondsSinceEpoch}';
    _currentUserName = 'User ${_currentUserId!.substring(0, 8)}';
  }

  Future<void> signOut() async {
    // await _auth.signOut();
    _currentUserId = null;
    _currentUserName = null;
  }

  bool get isSignedIn => _currentUserId != null;

  // Optional: E-Mail/Passwort-Login (TODO: Firebase wieder aktivieren)
  // Future<User?> signInWithEmail(String email, String password) async {
  //   final cred = await _auth.signInWithEmailAndPassword(
  //     email: email,
  //     password: password,
  //   );
  //   return cred.user;
  // }

  // Future<User?> signUpWithEmail(String email, String password) async {
  //   final cred = await _auth.createUserWithEmailAndPassword(
  //     email: email,
  //     password: password,
  //   );
  //   return cred.user;
  // }
}
