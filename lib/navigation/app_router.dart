import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/discover_screen.dart';
import '../screens/matches_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/create_listing_screen.dart';
import '../screens/login_screen.dart';
import '../screens/listing_detail_screen.dart';
import '../screens/chat_detail_screen.dart';
import '../screens/premium_upgrade_screen.dart';
import '../screens/community_screen.dart';
import '../screens/create_community_screen.dart';
import '../screens/create_store_screen.dart';
import '../screens/my_store_screen.dart';
import '../screens/store_detail_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/search_results_screen.dart';

/// Zentraler App-Router für strukturierte Navigation
class AppRouter {
  static const String home = '/';
  static const String discover = '/discover';
  static const String matches = '/matches';
  static const String chat = '/chat';
  static const String profile = '/profile';
  static const String createListing = '/create-listing';
  static const String login = '/login';
  static const String listingDetail = '/listing-detail';
  static const String chatDetail = '/chat-detail';
  static const String premiumUpgrade = '/premium-upgrade';
  static const String community = '/community';
  static const String createCommunity = '/create-community';
  static const String createStore = '/create-store';
  static const String myStore = '/my-store';
  static const String storeDetail = '/store-detail';
  static const String settingsRoute = '/settings';
  static const String searchResults = '/search-results';

  /// Route-Generator für Named Routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case discover:
        return MaterialPageRoute(
          builder: (_) => const DiscoverScreen(),
          settings: settings,
        );

      case matches:
        return MaterialPageRoute(
          builder: (_) => const MatchesScreen(),
          settings: settings,
        );

      case chat:
        return MaterialPageRoute(
          builder: (_) => const ChatScreen(),
          settings: settings,
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );

      case createListing:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CreateListingScreen(
            groupId: args?['groupId'],
            storeId: args?['storeId'],
          ),
          settings: settings,
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case listingDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || args['listingId'] == null) {
          return _errorRoute('Listing-Details benötigen eine listingId');
        }
        return MaterialPageRoute(
          builder: (_) => ListingDetailScreen(
            listingId: args['listingId'],
          ),
          settings: settings,
        );

      case chatDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null ||
            args['chatId'] == null ||
            args['otherUserName'] == null) {
          return _errorRoute('Chat-Details benötigen chatId und otherUserName');
        }
        return MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            chatId: args['chatId'],
            otherUserName: args['otherUserName'],
          ),
          settings: settings,
        );

      case premiumUpgrade:
        return MaterialPageRoute(
          builder: (_) => const PremiumUpgradeScreen(),
          settings: settings,
        );

      case community:
        return MaterialPageRoute(
          builder: (_) => const CommunityScreen(),
          settings: settings,
        );

      case createCommunity:
        return MaterialPageRoute(
          builder: (_) => const CreateCommunityScreen(),
          settings: settings,
        );

      case createStore:
        return MaterialPageRoute(
          builder: (_) => const CreateStoreScreen(),
          settings: settings,
        );

      case myStore:
        return MaterialPageRoute(
          builder: (_) => const MyStoreScreen(),
          settings: settings,
        );

      case storeDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || args['storeId'] == null) {
          return _errorRoute('Store-Details benötigen eine storeId');
        }
        return MaterialPageRoute(
          builder: (_) => StoreDetailScreen(
            storeId: args['storeId'],
            bannerId: args['bannerId'],
          ),
          settings: settings,
        );

      case settingsRoute:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      case searchResults:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || args['query'] == null) {
          return _errorRoute('Suchergebnisse benötigen eine Suchanfrage');
        }
        return MaterialPageRoute(
          builder: (_) => SearchResultsScreen(
            query: args['query'],
            radius: args['radius'] ?? 25.0,
            latitude: args['latitude'],
            longitude: args['longitude'],
          ),
          settings: settings,
        );

      default:
        return _errorRoute('Route ${settings.name} nicht gefunden');
    }
  }

  /// Error-Route für unbekannte Routen
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Fehler')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(_).pushNamedAndRemoveUntil(
                  home,
                  (route) => false,
                ),
                child: const Text('Zur Startseite'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigation-Helper-Methoden
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context,
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String routeName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      predicate,
      arguments: arguments,
    );
  }
}
