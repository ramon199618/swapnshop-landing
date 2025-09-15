import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/listing.dart';
import '../config/feature_flags.dart';

/// Service für den vereinheitlichten Swipe-Feed
/// Zeigt alle public Listings (Gruppen, Stores, allgemein) in einer globalen Swipe-Ansicht
class SwipeService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Holt den Swipe-Feed mit allen public Listings
  /// Berücksichtigt Radius, Kategorie, Sprache, Suchbegriffe und bereits gelikte/passierte Listings
  static Future<List<Listing>> getSwipeFeed({
    required String userId,
    int radiusKm = 50,
    String? category,
    String? searchQuery,
    String language = 'de',
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        // Im Debug-Modus: Simuliere Dummy-Listings mit Suchfilter
        final dummyListings = _getDummyListings(limit);
        if (searchQuery != null && searchQuery.isNotEmpty) {
          return dummyListings
              .where((listing) =>
                  listing.title
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()) ||
                  listing.description
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()) ||
                  listing.tags.any((tag) =>
                      tag.toLowerCase().contains(searchQuery.toLowerCase())) ||
                  listing.category
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()))
              .toList();
        }
        return dummyListings;
      }

      // Rufe Swipe-Feed über Supabase RPC-Funktion ab
      final response = await _supabase.rpc('get_swipe_feed', params: {
        'p_user_id': userId,
        'p_radius_km': radiusKm,
        'p_category': category,
        'p_search_query': searchQuery,
        'p_language': language,
        'p_limit': limit,
        'p_offset': offset,
      });

      if (response == null) return [];

      // Konvertiere Response zu Listing-Objekten
      final listings = <Listing>[];
      for (final item in response as List) {
        try {
          final listing = Listing.fromJson({
            'id': item['listing_id'],
            'title': item['title'],
            'description': item['description'],
            'type': item['type'],
            'category': item['category'],
            'price': item['price'],
            'value': item['value'],
            'desired_item': item['desired_item'],
            'owner_id': item['owner_id'],
            'owner_name': item['owner_name'],
            'images': item['images'] ?? [],
            'tags': item['tags'] ?? [],
            'offer_tags': item['offer_tags'] ?? [],
            'want_tags': item['want_tags'] ?? [],
            'latitude': item['latitude'],
            'longitude': item['longitude'],
            'location_name': item['location_name'],
            'radius_km': item['radius_km'] ?? 50,
            'is_active': true,
            'visibility': 'public',
            'language': item['language'] ?? language,
            'group_id': item['group_id'],
            'store_id': item['store_id'],
            'created_at': item['created_at'],
            'updated_at': item['created_at'],
            'is_anonymous': item['is_anonymous'] ?? false,
            'condition': item['condition'] ?? 'used',
          });
          listings.add(listing);
        } catch (e) {
          debugPrint('Fehler beim Parsen des Listings: $e');
        }
      }

      return listings;
    } catch (e) {
      debugPrint('Fehler beim Abrufen des Swipe-Feeds: $e');
      return [];
    }
  }

  /// Liked ein Listing (Swipe nach rechts)
  static Future<bool> likeListing(String userId, String listingId) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        // Im Debug-Modus: Simuliere erfolgreiches Liken
        return true;
      }

      // Füge Like hinzu
      await _supabase.from('likes').insert({
        'user_id': userId,
        'listing_id': listingId,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Aktualisiere Swipe-Score (optional, für bessere Ranking-Qualität)
      try {
        await _supabase.rpc('update_swipe_score', params: {
          'listing_uuid': listingId,
        });
      } catch (e) {
        debugPrint('Fehler beim Aktualisieren des Swipe-Scores: $e');
      }

      return true;
    } catch (e) {
      debugPrint('Fehler beim Liken des Listings: $e');
      return false;
    }
  }

  /// Entfernt ein Like (Unlike-Funktionalität)
  static Future<bool> unlikeListing(String userId, String listingId) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        // Im Debug-Modus: Simuliere erfolgreiches Unliken
        return true;
      }

      // Entferne Like
      await _supabase
          .from('likes')
          .delete()
          .eq('user_id', userId)
          .eq('listing_id', listingId);

      // Aktualisiere Swipe-Score (optional, für bessere Ranking-Qualität)
      try {
        await _supabase.rpc('update_swipe_score', params: {
          'listing_uuid': listingId,
        });
      } catch (e) {
        debugPrint('Fehler beim Aktualisieren des Swipe-Scores: $e');
      }

      return true;
    } catch (e) {
      debugPrint('Fehler beim Unliken des Listings: $e');
      return false;
    }
  }

  /// Passed ein Listing (Swipe nach links)
  static Future<bool> passListing(String userId, String listingId) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        // Im Debug-Modus: Simuliere erfolgreiches Passen
        return true;
      }

      // Füge Pass hinzu
      await _supabase.from('passes').insert({
        'user_id': userId,
        'listing_id': listingId,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Fehler beim Passen des Listings: $e');
      return false;
    }
  }

  /// Prüft ob ein Listing bereits geliked wurde
  static Future<bool> isListingLiked(String userId, String listingId) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        return false;
      }

      await _supabase
          .from('likes')
          .select('id')
          .eq('user_id', userId)
          .eq('listing_id', listingId)
          .single();

      return true; // single() wirft Exception bei Fehler, daher immer erfolgreich
    } catch (e) {
      return false;
    }
  }

  /// Prüft ob ein Listing bereits gepasst wurde
  static Future<bool> isListingPassed(String userId, String listingId) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        return false;
      }

      await _supabase
          .from('passes')
          .select('id')
          .eq('user_id', userId)
          .eq('listing_id', listingId)
          .single();

      return true; // single() wirft Exception bei Fehler, daher immer erfolgreich
    } catch (e) {
      return false;
    }
  }

  /// Sucht nach Listings basierend auf Keywords
  static Future<List<Listing>> searchListings({
    required String userId,
    required String query,
    int radiusKm = 50,
    String? category,
    String language = 'de',
    int limit = 20,
  }) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        // Im Debug-Modus: Simuliere Suchergebnisse
        return _getDummyListings(limit)
            .where((listing) =>
                listing.title.toLowerCase().contains(query.toLowerCase()) ||
                listing.description
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                listing.tags.any(
                    (tag) => tag.toLowerCase().contains(query.toLowerCase())))
            .toList();
      }

      // Volltext-Suche über keywords_tsv
      final response = await _supabase
          .from('swipe_index')
          .select('''
            listing_id, keywords_tsv, category, language, 
            latitude, longitude, radius_km, created_at
          ''')
          .textSearch('keywords_tsv', query, config: 'german')
          .eq('is_public', true)
          .neq('listing_id', userId) // Nicht eigene Listings
          .limit(limit);

      // Hole vollständige Listing-Daten
      final listingIds = (response as List)
          .map((item) => item['listing_id'] as String)
          .toList();

      if (listingIds.isEmpty) return [];

      final listingsResponse = await _supabase
          .from('listings')
          .select()
          .inFilter('id', listingIds)
          .eq('is_active', true)
          .eq('visibility', 'public');

      // Konvertiere zu Listing-Objekten
      final listings = <Listing>[];
      for (final item in listingsResponse as List) {
        try {
          final listing = Listing.fromJson(item);
          listings.add(listing);
        } catch (e) {
          debugPrint('Fehler beim Parsen des Listings: $e');
        }
      }

      return listings;
    } catch (e) {
      debugPrint('Fehler bei der Listing-Suche: $e');
      return [];
    }
  }

  /// Holt Statistiken für den Swipe-Feed
  static Future<Map<String, dynamic>> getSwipeStats(String userId) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        return {
          'total_listings': 150,
          'available_listings': 120,
          'liked_count': 25,
          'passed_count': 5,
          'matches_count': 3,
        };
      }

      // Zähle verfügbare Listings
      final availableResponse = await _supabase
          .from('swipe_index')
          .select('listing_id')
          .eq('is_public', true)
          .neq('listing_id', userId);

      // Zähle Likes
      final likedResponse =
          await _supabase.from('likes').select('id').eq('user_id', userId);

      // Zähle Passes
      final passedResponse =
          await _supabase.from('passes').select('id').eq('user_id', userId);

      // Zähle Matches
      final matchesResponse = await _supabase
          .from('matches')
          .select('id')
          .or('user_a_id.eq.$userId,user_b_id.eq.$userId');

      final totalListings = availableResponse.length;
      final likedCount = likedResponse.length;
      final passedCount = passedResponse.length;
      final matchesCount = matchesResponse.length;

      return {
        'total_listings': totalListings,
        'available_listings': totalListings - likedCount - passedCount,
        'liked_count': likedCount,
        'passed_count': passedCount,
        'matches_count': matchesCount,
      };
    } catch (e) {
      debugPrint('Fehler beim Abrufen der Swipe-Statistiken: $e');
      return {
        'total_listings': 0,
        'available_listings': 0,
        'liked_count': 0,
        'passed_count': 0,
        'matches_count': 0,
      };
    }
  }

  /// Aktualisiert den Swipe-Score für ein Listing
  static Future<bool> updateSwipeScore(String listingId) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        return true;
      }

      await _supabase.rpc('update_swipe_score', params: {
        'listing_uuid': listingId,
      });

      return true;
    } catch (e) {
      debugPrint('Fehler beim Aktualisieren des Swipe-Scores: $e');
      return false;
    }
  }

  /// Dummy-Listings für Debug-Modus
  static List<Listing> _getDummyListings(int count) {
    final dummyListings = <Listing>[];

    // Realistischere Dummy-Daten für bessere Suchfunktionalität
    final items = [
      {
        'title': 'Harry Potter Buchreihe',
        'category': 'books',
        'tags': ['bücher', 'fantasy', 'harry potter', 'romane']
      },
      {
        'title': 'MacBook Pro 13"',
        'category': 'electronics',
        'tags': ['laptop', 'apple', 'macbook', 'computer']
      },
      {
        'title': 'Nike Air Max Schuhe',
        'category': 'clothing',
        'tags': ['schuhe', 'nike', 'sport', 'laufschuhe']
      },
      {
        'title': 'Vintage Fahrrad',
        'category': 'sports',
        'tags': ['fahrrad', 'vintage', 'rad', 'transport']
      },
      {
        'title': 'IKEA Regal Billy',
        'category': 'furniture',
        'tags': ['regal', 'ikea', 'möbel', 'aufbewahrung']
      },
      {
        'title': 'Kochbücher Sammlung',
        'category': 'books',
        'tags': ['bücher', 'kochen', 'rezepte', 'küche']
      },
      {
        'title': 'iPhone 12',
        'category': 'electronics',
        'tags': ['handy', 'iphone', 'apple', 'smartphone']
      },
      {
        'title': 'Designer Handtasche',
        'category': 'clothing',
        'tags': ['tasche', 'designer', 'mode', 'accessoire']
      },
      {
        'title': 'Yoga Matte',
        'category': 'sports',
        'tags': ['yoga', 'fitness', 'sport', 'matte']
      },
      {
        'title': 'Antiker Schreibtisch',
        'category': 'furniture',
        'tags': ['schreibtisch', 'antik', 'möbel', 'holz']
      },
      {
        'title': 'Kinderbücher',
        'category': 'books',
        'tags': ['bücher', 'kinder', 'bilderbücher', 'lernen']
      },
      {
        'title': 'Gaming Laptop',
        'category': 'electronics',
        'tags': ['laptop', 'gaming', 'computer', 'spiele']
      },
      {
        'title': 'Winterjacke',
        'category': 'clothing',
        'tags': ['jacke', 'winter', 'kleidung', 'warm']
      },
      {
        'title': 'Tennis Schläger',
        'category': 'sports',
        'tags': ['tennis', 'schläger', 'sport', 'racket']
      },
      {
        'title': 'Esstisch 6 Personen',
        'category': 'furniture',
        'tags': ['tisch', 'essen', 'möbel', 'familie']
      },
    ];

    final types = [ListingType.swap, ListingType.sell, ListingType.giveaway];
    final conditions = ['new', 'like_new', 'used', 'worn'];

    for (int i = 0; i < count; i++) {
      final item = items[i % items.length];
      final listing = Listing(
        id: 'dummy_${i + 1}',
        title: item['title'] as String,
        description:
            '${item['title']} in gutem Zustand. Perfekt für den täglichen Gebrauch.',
        type: types[i % types.length],
        category: item['category'] as String,
        price: types[i % types.length] == ListingType.giveaway
            ? null
            : (i + 1) * 15.0,
        value: (i + 1) * 20.0,
        desiredItem: types[i % types.length] == ListingType.swap
            ? 'Ähnlicher Gegenstand'
            : null,
        ownerId: 'dummy_user_${i % 3 + 1}',
        ownerName: 'User ${i % 3 + 1}',
        images: [
          'https://via.placeholder.com/300x200?text=${Uri.encodeComponent(item['title'] as String)}'
        ],
        tags: (item['tags'] as List<String>),
        offerTags: (item['tags'] as List<String>).take(2).toList(),
        wantTags: types[i % types.length] == ListingType.swap
            ? ['tausch', 'ähnlich']
            : [],
        latitude: 47.3769 + (i * 0.01), // Zürich + Offset
        longitude: 8.5417 + (i * 0.01),
        locationName: 'Zürich',
        radiusKm: 25,
        isActive: true,
        visibility: ListingVisibility.public,
        language: 'de',
        groupId: i % 2 == 0 ? 'dummy_group_${i % 2 + 1}' : null,
        storeId: i % 3 == 0 ? 'dummy_store_${i % 3 + 1}' : null,
        createdAt: DateTime.now().subtract(Duration(hours: i)),
        updatedAt: DateTime.now().subtract(Duration(hours: i)),
        isAnonymous: i % 4 == 0,
        condition: conditions[i % conditions.length],
      );
      dummyListings.add(listing);
    }

    return dummyListings;
  }
}
