import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'l10n/app_localizations.dart';
import 'constants/colors.dart';
import 'constants/texts.dart';
import 'providers/like_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/premium_test_provider.dart';
import 'screens/home_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/matches_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/create_listing_screen.dart';
import 'screens/login_screen.dart';
import 'config/supabase_config.dart';
import 'services/auth_service.dart';
import 'dart:ui';

void main() async {
  // Wichtig: WidgetsFlutterBinding.ensureInitialized() MUSS als erstes aufgerufen werden
  WidgetsFlutterBinding.ensureInitialized();

  // Umfassendes Error-Handling für App-Start
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('🚨 Flutter Error: ${details.exception}');
    debugPrint('🚨 Stack: ${details.stack}');
  };

  // PlatformDispatcher Error Handling
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('🚨 Platform Error: $error');
    debugPrint('🚨 Stack: $stack');
    return true;
  };

  debugPrint('🚀 App-Start beginnt...');

  // App IMMER starten, auch ohne Supabase
  debugPrint('🚀 Starte App ohne Supabase-Abhängigkeit...');
  runApp(const SwapAndShopApp());
}

class SwapAndShopApp extends StatelessWidget {
  const SwapAndShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LikeProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => PremiumTestProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            title: AppTexts.appTitle,
            debugShowCheckedModeBanner: false,

            // Internationalisierung
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('de'), // Deutsch
              Locale('en'), // Englisch
              Locale('fr'), // Französisch
              Locale('it'), // Italienisch
              Locale('pt'), // Portugiesisch
            ],
            locale: languageProvider.currentLocale,

            // Themes
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            home: const AuthWrapper(),

            // Fallback für Fehler
            builder: (context, child) {
              return child ?? const FallbackScreen();
            },
          );
        },
      ),
    );
  }
}

class FallbackScreen extends StatelessWidget {
  const FallbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'App konnte nicht geladen werden',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bitte starte die App neu',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Versuche App neu zu starten
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const AuthWrapper()),
                );
              },
              child: const Text('Erneut versuchen'),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitializing = true;
  bool _supabaseInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSupabase();
  }

  Future<void> _initializeSupabase() async {
    try {
      debugPrint('🔄 Starte Supabase-Initialisierung...');
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      setState(() {
        _supabaseInitialized = true;
        _isInitializing = false;
      });
      debugPrint('✅ Supabase erfolgreich initialisiert');
    } catch (e) {
      debugPrint('❌ Supabase-Initialisierung fehlgeschlagen: $e');
      setState(() {
        _supabaseInitialized = false;
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('App wird geladen...'),
            ],
          ),
        ),
      );
    }

    try {
      debugPrint('🔍 Prüfe User-Status...');
      debugPrint('🔍 Supabase verfügbar: $_supabaseInitialized');

      if (!_supabaseInitialized) {
        debugPrint('❌ Supabase nicht verfügbar, zeige Login-Screen');
        return const LoginScreen();
      }

      final currentUser = AuthService.getCurrentUser();
      debugPrint('🔍 User gefunden: ${currentUser != null}');

      if (currentUser != null) {
        debugPrint('✅ User eingeloggt, zeige Haupt-App');
        return const MainNavigationScreen();
      } else {
        debugPrint('❌ Kein User, zeige Login-Screen');
        return const LoginScreen();
      }
    } catch (e) {
      debugPrint('❌ Fehler beim Prüfen des User-Status: $e');
      return const LoginScreen();
    }
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DiscoverScreen(),
    const MatchesScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onCreateListingPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateListingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Entdecken',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
            bottom: 80.0, right: 16.0), // Höher und rechts positioniert
        child: FloatingActionButton(
          onPressed: _onCreateListingPressed,
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
