import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_keys.dart';

class SupabaseConfig {
  // TODO(Ramon): Insert LIVE_SUPABASE_URL and LIVE_SUPABASE_ANON_KEY here
  // Für Produktion: --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=xxx

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://nqxgsuxyvhjveigbjyxb.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: SupabaseKeys.realAnonKey,
  );

  // Domain-spezifische URLs
  static const String appDomain = 'https://swapnshop.app';
  static const String apiDomain = 'https://api.swapnshop.app';

  // Build-Anweisungen
  static const String buildInstructions = '''
    Für Produktion:
    1. --dart-define=SUPABASE_URL=https://your-project.supabase.co
    2. --dart-define=SUPABASE_ANON_KEY=your-live-anon-key
    3. --dart-define=APP_ENV=prod
  ''';

  // Optional: Production vs Development
  static const bool isProduction = false;

  // API Endpoints
  static const String authEndpoint = '/auth/v1';
  static const String restEndpoint = '/rest/v1';
  static const String realtimeEndpoint = '/realtime/v1';

  // Storage Buckets
  static const String imagesBucket = 'images';
  static const String avatarsBucket = 'avatars';

  // Database Tables
  static const String profilesTable = 'profiles';
  static const String listingsTable = 'listings';
  static const String likesTable = 'likes';
  static const String communitiesTable = 'communities';
  static const String communityMembersTable = 'community_members';
  static const String communityPostsTable = 'community_posts';
  static const String communityPostLikesTable = 'community_post_likes';
  static const String communityPostCommentsTable = 'community_post_comments';
  static const String communityInvitesTable = 'community_invites';
  static const String chatsTable = 'chats';
  static const String chatParticipantsTable = 'chat_participants';
  static const String messagesTable = 'messages';

  // Monetization Tables
  static const String storesTable = 'stores';
  static const String bannersTable = 'banners';
  static const String subscriptionsTable = 'subscriptions';
  static const String donationsTable = 'donations';
  static const String userCreditsTable = 'user_credits';
  static const String paymentsTable = 'payments';

  // Functions
  static const String getMatchesFunction = 'get_user_matches';
  static const String getListingsWithinRadiusFunction =
      'get_listings_within_radius';

  // Validation
  static bool get isConfigured =>
      url != 'https://your-project.supabase.co' && 
      anonKey != 'your-anon-key' && 
      anonKey != 'HIER_DEIN_ECHTER_ANON_KEY_EINFÜGEN' &&
      SupabaseKeys.isConfigured;

  /// Initialisiert Supabase mit der konfigurierten URL und dem anon key
  static Future<void> initializeSupabase() async {
    if (!isConfigured) {
      throw Exception('Supabase ist nicht korrekt konfiguriert. Bitte URL und anon key prüfen.');
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      debug: false, // In Production auf false setzen
    );
  }

  /// Gibt den Supabase Client zurück
  static SupabaseClient get client => Supabase.instance.client;
}
