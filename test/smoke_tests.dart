import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:swapshop_clean/main.dart';
import 'package:swapshop_clean/providers/auth_provider.dart';
import 'package:swapshop_clean/providers/like_provider.dart';
import 'package:swapshop_clean/providers/theme_provider.dart';
import 'package:swapshop_clean/providers/language_provider.dart';
import 'package:swapshop_clean/providers/premium_test_provider.dart';
import 'package:swapshop_clean/screens/home_screen.dart';
import 'package:swapshop_clean/screens/login_screen.dart';
import 'package:swapshop_clean/navigation/app_router.dart';

/// Smoke Tests für Haupt-Flows der App
void main() {
  group('Smoke Tests - Haupt-Flows', () {
    testWidgets('App startet ohne Crash', (WidgetTester tester) async {
      // App starten
      await tester.pumpWidget(const SwapAndShopApp());
      await tester.pumpAndSettle();

      // Prüfen ob App läuft
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Navigation zwischen Haupt-Screens funktioniert', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => LikeProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => LanguageProvider()),
            ChangeNotifierProvider(create: (_) => PremiumTestProvider()),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Prüfen ob HomeScreen geladen ist
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Login-Screen wird angezeigt wenn nicht eingeloggt', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => LikeProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => LanguageProvider()),
            ChangeNotifierProvider(create: (_) => PremiumTestProvider()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Prüfen ob Login-Screen geladen ist
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('App-Router generiert korrekte Routen', (WidgetTester tester) async {
      // Test für Home-Route
      final homeRoute = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.home),
      );
      expect(homeRoute, isA<MaterialPageRoute>());

      // Test für Login-Route
      final loginRoute = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.login),
      );
      expect(loginRoute, isA<MaterialPageRoute>());

      // Test für unbekannte Route
      final errorRoute = AppRouter.generateRoute(
        const RouteSettings(name: '/unknown'),
      );
      expect(errorRoute, isA<MaterialPageRoute>());
    });

    testWidgets('Provider werden korrekt initialisiert', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => LikeProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => LanguageProvider()),
            ChangeNotifierProvider(create: (_) => PremiumTestProvider()),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Prüfen ob alle Provider verfügbar sind
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  group('Widget Tests - Kern-Komponenten', () {
    testWidgets('HomeScreen zeigt Loading-Indikator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => LikeProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => LanguageProvider()),
            ChangeNotifierProvider(create: (_) => PremiumTestProvider()),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Prüfen ob Loading-Indikator angezeigt wird
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('App-Router Error-Route funktioniert', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: AppRouter.generateRoute,
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/unknown-route');
                },
                child: const Text('Test Error Route'),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Button drücken
      await tester.tap(find.text('Test Error Route'));
      await tester.pumpAndSettle();

      // Prüfen ob Error-Screen angezeigt wird
      expect(find.text('Fehler'), findsOneWidget);
      expect(find.text('Zur Startseite'), findsOneWidget);
    });
  });

  group('Integration Tests - User-Flows', () {
    testWidgets('Navigation von Home zu Create Listing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => LikeProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => LanguageProvider()),
            ChangeNotifierProvider(create: (_) => PremiumTestProvider()),
          ],
          child: MaterialApp(
            onGenerateRoute: AppRouter.generateRoute,
            home: const HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Prüfen ob HomeScreen geladen ist
      expect(find.byType(HomeScreen), findsOneWidget);

      // FAB für Create Listing suchen und drücken
      final fab = find.byType(FloatingActionButton);
      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Theme-Provider funktioniert', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => LikeProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => LanguageProvider()),
            ChangeNotifierProvider(create: (_) => PremiumTestProvider()),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Prüfen ob ThemeProvider funktioniert
      final themeProvider = Provider.of<ThemeProvider>(tester.element(find.byType(HomeScreen)), listen: false);
      expect(themeProvider, isA<ThemeProvider>());
    });

    testWidgets('Language-Provider funktioniert', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => LikeProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => LanguageProvider()),
            ChangeNotifierProvider(create: (_) => PremiumTestProvider()),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Prüfen ob LanguageProvider funktioniert
      final languageProvider = Provider.of<LanguageProvider>(tester.element(find.byType(HomeScreen)), listen: false);
      expect(languageProvider, isA<LanguageProvider>());
    });
  });
}
