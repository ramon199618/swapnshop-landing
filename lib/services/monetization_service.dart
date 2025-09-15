import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/premium_limits.dart';
import '../config/feature_flags.dart';

class MonetizationService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Prüft ob ein User ein Listing erstellen kann
  static Future<Map<String, dynamic>> checkCanPost(
      String userId, String category) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        // Im Debug-Modus: Simuliere erfolgreiche Prüfung
        return _getDummyQuota(category);
      }

      final response = await _supabase.rpc('rpc_can_post', params: {
        'p_user_id': userId,
        'p_category': category,
      });

      if (response != null) {
        return {
          'allowed': response['allowed'] ?? false,
          'reason': response['reason'] ?? 'unknown',
          'remaining': response['remaining'] ?? 0,
        };
      }

      return {
        'allowed': false,
        'reason': 'error',
        'remaining': 0,
      };
    } catch (e) {
      debugPrint('Error checking can post: $e');
      return {
        'allowed': false,
        'reason': 'error',
        'remaining': 0,
      };
    }
  }

  /// Bestätigt ein erfolgreich erstelltes Listing
  static Future<bool> confirmPost(
      String userId, String category, String listingId) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        // Im Debug-Modus: Simuliere erfolgreiche Bestätigung
        return true;
      }

      final response = await _supabase.rpc('rpc_confirm_post', params: {
        'p_user_id': userId,
        'p_category': category,
        'p_listing_id': listingId,
      });

      return response == true;
    } catch (e) {
      debugPrint('Error confirming post: $e');
      return false;
    }
  }

  /// Fügt Swap-Bonus nach erfolgreicher Spende hinzu
  static Future<bool> addSwapBonus(String userId, int amount) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        // Im Debug-Modus: Simuliere erfolgreiche Bonus-Zuweisung
        return true;
      }

      final response = await _supabase.rpc('rpc_add_swap_bonus', params: {
        'p_user_id': userId,
        'p_amount': amount,
      });

      return response == true;
    } catch (e) {
      debugPrint('Error adding swap bonus: $e');
      return false;
    }
  }

  /// Holt aktuelle Quota-Informationen für einen User
  static Future<Map<String, dynamic>> getUserQuota(String userId) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        // Im Debug-Modus: Simuliere Quota-Daten
        return _getDummyQuota('all');
      }

      final response = await _supabase
          .from('usage_quota')
          .select()
          .eq('user_id', userId)
          .eq('month_key', _getCurrentMonthKey())
          .single();

      return {
        'swap_used': response['swap_used'] ?? 0,
        'sell_used': response['sell_used'] ?? 0,
        'swap_bonus': response['swap_bonus'] ?? 0,
        'swap_remaining':
            (PremiumLimits.maxFreeSwaps + (response['swap_bonus'] ?? 0)) -
                (response['swap_used'] ?? 0),
        'sell_remaining':
            PremiumLimits.maxFreeSells - (response['sell_used'] ?? 0),
      };
    } catch (e) {
      debugPrint('Error getting user quota: $e');
      return {
        'swap_used': 0,
        'sell_used': 0,
        'swap_bonus': 0,
        'swap_remaining': PremiumLimits.maxFreeSwaps,
        'sell_remaining': PremiumLimits.maxFreeSells,
      };
    }
  }

  /// Prüft Premium-Status eines Users
  static Future<bool> isUserPremium(String userId) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        // Im Debug-Modus: Simuliere nicht-Premium User
        return false;
      }

      final response = await _supabase
          .from('profiles')
          .select('is_premium')
          .eq('id', userId)
          .single();

      return response['is_premium'] ?? false;
    } catch (e) {
      debugPrint('Error checking premium status: $e');
      return false;
    }
  }

  /// Aktualisiert Premium-Status nach erfolgreicher Zahlung
  static Future<bool> updatePremiumStatus(String userId, bool isPremium,
      {DateTime? expiresAt}) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        // Im Debug-Modus: Simuliere erfolgreiche Aktualisierung
        return true;
      }

      await _supabase.from('profiles').update({
        'is_premium': isPremium,
        if (expiresAt != null)
          'premium_expires_at': expiresAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      return true; // update() wirft Exception bei Fehler, daher immer erfolgreich
    } catch (e) {
      debugPrint('Error updating premium status: $e');
      return false;
    }
  }

  /// Speichert eine erfolgreiche Zahlung
  static Future<bool> savePayment(Map<String, dynamic> paymentData) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        // Im Debug-Modus: Simuliere erfolgreiche Speicherung
        return true;
      }

      await _supabase.from('payments').insert(paymentData);

      return true; // insert() wirft Exception bei Fehler, daher immer erfolgreich
    } catch (e) {
      debugPrint('Error saving payment: $e');
      return false;
    }
  }

  /// Speichert eine Spende
  static Future<bool> saveDonation(Map<String, dynamic> donationData) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        // Im Debug-Modus: Simuliere erfolgreiche Speicherung
        return true;
      }

      await _supabase.from('donations').insert(donationData);

      return true; // insert() wirft Exception bei Fehler, daher immer erfolgreich
    } catch (e) {
      debugPrint('Error saving donation: $e');
      return false;
    }
  }

  /// Holt Spenden-Übersicht für einen User
  static Map<String, dynamic> getDonationOverview() {
    if (FeatureFlags.useDummies && kDebugMode) {
      // Im Debug-Modus: Simuliere Spenden-Daten
      return {
        'isPremium': false,
        'totalDonations': 0.0,
        'swapListings': 0,
        'sellListings': 0,
        'giveawayListings': 0,
      };
    }

    // Im Release-Modus: Echte Daten aus Supabase
    return {
      'isPremium': false,
      'totalDonations': 0.0,
      'swapListings': 0,
      'sellListings': 0,
      'giveawayListings': 0,
    };
  }

  /// Prüft und aktualisiert Usage vor dem Erstellen eines Listings
  static Future<bool> checkAndUpdateUsage(
      String userId, String category) async {
    try {
      final canPost = await checkCanPost(userId, category);

      if (canPost['allowed']) {
        // Bestätige den Post (Counter wird erst nach erfolgreicher Erstellung inkrementiert)
        return true;
      } else {
        debugPrint('User cannot post: ${canPost['reason']}');
        return false;
      }
    } catch (e) {
      debugPrint('Error checking usage: $e');
      return false;
    }
  }

  /// Holt den aktuellen Monatsschlüssel (Europe/Zurich)
  static String _getCurrentMonthKey() {
    final now = DateTime.now()
        .toUtc()
        .add(const Duration(hours: 1)); // Europe/Zurich = UTC+1
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  /// Dummy-Quota für Debug-Modus
  static Map<String, dynamic> _getDummyQuota(String category) {
    switch (category) {
      case 'swap':
        return {
          'allowed': true,
          'reason': 'ok',
          'remaining': 3, // Simuliere 3 verbleibende Swaps
        };
      case 'sell':
        return {
          'allowed': true,
          'reason': 'ok',
          'remaining': 1, // Simuliere 1 verbleibenden Sell
        };
      case 'giveaway':
        return {
          'allowed': true,
          'reason': 'ok',
          'remaining': -1, // Unbegrenzt
        };
      case 'all':
        return {
          'swap_used': 2,
          'sell_used': 1,
          'swap_bonus': 0,
          'swap_remaining': 3,
          'sell_remaining': 1,
        };
      default:
        return {
          'allowed': false,
          'reason': 'invalid_category',
          'remaining': 0,
        };
    }
  }

  /// Berechnet verbleibende Tage bis zum Monatsreset
  static int getDaysUntilReset() {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final daysUntilReset = nextMonth.difference(now).inDays;
    return daysUntilReset;
  }

  /// Formatiert verbleibende Zeit bis zum Reset
  static String getResetCountdown() {
    final days = getDaysUntilReset();
    if (days == 0) {
      return 'Heute';
    } else if (days == 1) {
      return 'Morgen';
    } else {
      return 'In $days Tagen';
    }
  }

  // Store-Funktionen (für Kompatibilität)
  static Future<Map<String, dynamic>?> getUserStore(String userId) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        // Im Debug-Modus: Simuliere Store-Daten
        return {
          'id': 'store_1',
          'name': 'Mein Store',
          'description': 'Ein persönlicher Store für meine Verkäufe',
          'location': 'Zürich, Schweiz',
          'logoUrl': 'https://example.com/store_logo.jpg',
          'isPremium': true,
          'categories': ['Electronics', 'Books', 'Clothing'],
          'createdAt': DateTime.now().subtract(const Duration(days: 30)),
          'latitude': 47.3769,
          'longitude': 8.5417,
        };
      }

      // Im Release-Modus: Echte Daten aus Supabase
      final response = await _supabase
          .from('stores')
          .select('*')
          .eq('owner_id', userId)
          .eq('is_active', true)
          .single();

      return response;
    } catch (e) {
      debugPrint('Error getting user store: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getNearbyStores({
    double? latitude,
    double? longitude,
    int? radius,
    List<String>? storeTypes,
    String? searchQuery,
    String? sortBy,
  }) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        // Im Debug-Modus: Simuliere Store-Daten
        await Future.delayed(const Duration(milliseconds: 500));

        var stores = [
          {
            'id': 'store_1',
            'name': 'Schmuckladen Zürich',
            'description': 'Handgefertigter Schmuck aus Silber und Gold',
            'location': 'Zürich, Schweiz',
            'logoUrl': 'https://example.com/jewelry.jpg',
            'isPremium': true,
            'storeType': 'Kleiner Store',
            'categories': ['Jewelry', 'Accessories'],
            'createdAt': DateTime.now().subtract(const Duration(days: 5)),
            'latitude': 47.3769,
            'longitude': 8.5417,
          },
          {
            'id': 'store_2',
            'name': 'Velotausch & Reparatur',
            'description': 'Professionelle Fahrradreparatur und Tausch',
            'location': 'Zürich, Schweiz',
            'logoUrl': 'https://example.com/bike.jpg',
            'isPremium': false,
            'storeType': 'Second-Hand-Händler:in',
            'categories': ['Sports', 'Bikes'],
            'createdAt': DateTime.now().subtract(const Duration(days: 3)),
            'latitude': 47.3769,
            'longitude': 8.5417,
          },
        ];

        // Filter nach Store-Typen
        if (storeTypes != null && storeTypes.isNotEmpty) {
          stores = stores
              .where((store) => storeTypes.contains(store['storeType']))
              .toList();
        }

        // Filter nach Suchbegriff
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final query = searchQuery.toLowerCase();
          stores = stores
              .where((store) =>
                  store['name'].toString().toLowerCase().contains(query) ||
                  store['description'].toString().toLowerCase().contains(query))
              .toList();
        }

        return stores;
      }

      // Im Release-Modus: Echte Daten aus Supabase
      var query = _supabase.from('stores').select('*').eq('is_active', true);

      // Filter nach Standort (falls verfügbar)
      if (latitude != null && longitude != null && radius != null) {
        // Hier könnte eine geografische Abfrage implementiert werden
        // Für jetzt verwenden wir alle aktiven Stores
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting nearby stores: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getStoreById(String storeId) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        // Im Debug-Modus: Simuliere Store-Daten
        final stores = await getNearbyStores();
        try {
          return stores.firstWhere(
            (store) => store['id'] == storeId,
          );
        } catch (e) {
          return null;
        }
      }

      // Im Release-Modus: Echte Daten aus Supabase
      final response = await _supabase
          .from('stores')
          .select('*')
          .eq('id', storeId)
          .eq('is_active', true)
          .single();

      return response;
    } catch (e) {
      debugPrint('Error getting store by id: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getActiveBanners({
    double? latitude,
    double? longitude,
    int? radius,
  }) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        // Im Debug-Modus: Simuliere Banner-Daten
        await Future.delayed(const Duration(milliseconds: 300));

        return [
          {
            'id': '1',
            'title': 'Schmuckladen Zürich',
            'description': 'Handgefertigter Schmuck aus Silber und Gold',
            'imageUrl':
                'https://via.placeholder.com/400x200/FF5722/FFFFFF?text=Jewelry',
            'location': 'Zürich, Schweiz',
            'latitude': 47.3769,
            'longitude': 8.5417,
            'radiusKm': 25,
            'startDate': DateTime.now().subtract(const Duration(days: 5)),
            'endDate': DateTime.now().add(const Duration(days: 25)),
            'price': 5.0,
            'status': 'active',
            'createdAt': DateTime.now().subtract(const Duration(days: 5)),
            'userId': 'store_1',
          },
          {
            'id': '2',
            'title': 'Velotausch & Reparatur',
            'description': 'Professionelle Fahrradreparatur und Tausch',
            'imageUrl':
                'https://via.placeholder.com/400x200/4CAF50/FFFFFF?text=Bike',
            'location': 'Zürich, Schweiz',
            'latitude': 47.3769,
            'longitude': 8.5417,
            'radiusKm': 10,
            'startDate': DateTime.now().subtract(const Duration(days: 3)),
            'endDate': DateTime.now().add(const Duration(days: 27)),
            'price': 2.0,
            'status': 'active',
            'createdAt': DateTime.now().subtract(const Duration(days: 3)),
            'userId': 'store_2',
          },
        ];
      }

      // Im Release-Modus: Echte Daten aus Supabase mit Targeting
      if (latitude != null && longitude != null) {
        final response = await _supabase.rpc('get_targeted_banners', params: {
          'p_user_lat': latitude,
          'p_user_lon': longitude,
          'p_limit': 10,
        });

        if (response != null) {
          return List<Map<String, dynamic>>.from(response);
        }
      }

      // Fallback: Alle aktiven Banner
      final response = await _supabase
          .from('store_ads')
          .select('*')
          .eq('is_active', true)
          .eq('status', 'active')
          .gte('start_at', DateTime.now().toIso8601String())
          .lte('end_at', DateTime.now().toIso8601String())
          .order('priority', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting active banners: $e');
      return [];
    }
  }

  /// Tracket Banner-Impression
  static Future<bool> trackBannerImpression(
    String adId,
    String userId,
    double userLat,
    double userLon,
    int rotationSlot,
  ) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        // Im Debug-Modus: Simuliere erfolgreiches Tracking
        return true;
      }

      final response = await _supabase.rpc('track_banner_impression', params: {
        'p_ad_id': adId,
        'p_user_id': userId,
        'p_user_lat': userLat,
        'p_user_lon': userLon,
        'p_rotation_slot': rotationSlot,
      });

      return response == true;
    } catch (e) {
      debugPrint('Error tracking banner impression: $e');
      return false;
    }
  }

  /// Tracket Banner-Click
  static Future<bool> trackBannerClick(
    String adId,
    String userId,
    double userLat,
    double userLon,
  ) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        // Im Debug-Modus: Simuliere erfolgreiches Tracking
        return true;
      }

      final response = await _supabase.rpc('track_banner_click', params: {
        'p_ad_id': adId,
        'p_user_id': userId,
        'p_user_lat': userLat,
        'p_user_lon': userLon,
      });

      return response == true;
    } catch (e) {
      debugPrint('Error tracking banner click: $e');
      return false;
    }
  }

  /// Erstellt ein neues Store-Ad
  static Future<bool> createStoreAd(Map<String, dynamic> adData) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        // Im Debug-Modus: Simuliere erfolgreiche Erstellung
        return true;
      }

      // Berechne den Preis basierend auf dem Radius
      final radiusKm = adData['radius_km'] ?? 5;
      final priceChf = _calculateBannerPrice(radiusKm);

      // Füge den berechneten Preis hinzu
      adData['price_chf'] = priceChf;

      // Erstelle Geography-Point für den Standort
      adData['center_geo'] =
          'POINT(${adData['center_lon']} ${adData['center_lat']})';

      final response = await _supabase.from('store_ads').insert(adData);

      return response != null;
    } catch (e) {
      debugPrint('Error creating store ad: $e');
      return false;
    }
  }

  /// Berechnet den Preis für Banner-Werbung basierend auf dem Radius
  static double _calculateBannerPrice(int radiusKm) {
    if (radiusKm <= 5) {
      return 1.0; // Konstanter Niedrigpreis für lokale Banner
    } else if (radiusKm <= 10) {
      return 2.0;
    } else if (radiusKm <= 20) {
      return 5.0;
    } else if (radiusKm <= 50) {
      return 10.0;
    } else {
      return 15.0; // Maximaler Radius
    }
  }

  /// Holt alle aktiven Store-Ads für einen Store
  static Future<List<Map<String, dynamic>>> getStoreAds(String storeId) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        // Im Debug-Modus: Simuliere Store-Ads
        await Future.delayed(const Duration(milliseconds: 300));

        return [
          {
            'id': 'ad_1',
            'title': 'Sommer-Sale',
            'description': 'Alle Artikel 20% reduziert',
            'status': 'active',
            'radius_km': 5,
            'price_chf': 1.0,
            'impressions_count': 150,
            'clicks_count': 12,
          },
        ];
      }

      // Im Release-Modus: Echte Daten aus Supabase
      final response = await _supabase
          .from('store_ads')
          .select('*')
          .eq('store_id', storeId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting store ads: $e');
      return [];
    }
  }

  static Future<Map<String, int>> getUsageLimits(String userId) async {
    try {
      if (FeatureFlags.useDummies && kDebugMode) {
        // Im Debug-Modus: Simuliere Usage-Daten
        await Future.delayed(const Duration(milliseconds: 500));

        return {
          'swaps': 3,
          'sells': 1,
        };
      }

      // Im Release-Modus: Echte Daten aus Supabase
      final quota = await getUserQuota(userId);
      return {
        'swaps': quota['swap_used'] ?? 0,
        'sells': quota['sell_used'] ?? 0,
      };
    } catch (e) {
      debugPrint('Error getting usage limits: $e');
      return {
        'swaps': 0,
        'sells': 0,
      };
    }
  }

  // ===== DISCOVER SCREEN - JOBS =====

  /// Get jobs for discover screen
  static Future<List<Map<String, dynamic>>> getJobs({
    String? category,
    double? radiusKm,
    String? searchQuery,
    String? sortBy,
    String? jobType, // 'paid', 'barter', 'both'
  }) async {
    try {
      if (kDebugMode) {
        // Simuliere Jobs-Daten
        await Future.delayed(const Duration(milliseconds: 300));
        return [
          {
            'id': 'job_1',
            'title': 'Gartenarbeit',
            'description': 'Hilfe bei der Gartenarbeit gesucht',
            'payment': '15 CHF/Stunde',
            'location': 'Zürich-West',
            'type': 'Bezahlt',
            'imageUrl': 'assets/images/placeholder_job.jpg',
            'latitude': 47.3769,
            'longitude': 8.5417,
            'category': 'Haushalt & Garten',
            'isPremium': false,
            'categories': ['Haushalt', 'Garten', 'Bezahlt'],
          },
          {
            'id': 'job_2',
            'title': 'Babysitting',
            'description': 'Babysitter für 2 Kinder (4 & 6 Jahre)',
            'payment': 'Tausch: Reparatur von Elektronik',
            'location': 'Zürich-Ost',
            'type': 'Tausch',
            'imageUrl': 'assets/images/placeholder_job.jpg',
            'latitude': 47.3769,
            'longitude': 8.5417,
            'category': 'Betreuung',
            'isPremium': true,
            'categories': ['Betreuung', 'Kinder', 'Tausch'],
          },
          {
            'id': 'job_3',
            'title': 'Umzugshilfe',
            'description': 'Hilfe beim Umzug in neue Wohnung',
            'payment': '20 CHF/Stunde',
            'location': 'Zürich-Nord',
            'type': 'Bezahlt',
            'imageUrl': 'assets/images/placeholder_job.jpg',
            'latitude': 47.3769,
            'longitude': 8.5417,
            'category': 'Transport & Logistik',
            'isPremium': false,
            'categories': ['Transport', 'Logistik', 'Bezahlt'],
          },
        ];
      }

      // Rufe Jobs über Supabase ab
      var query = _supabase
          .from('jobs')
          .select('*')
          .eq('is_active', true);

      if (category != null && category != 'Alle') {
        query = query.eq('category', category);
      }

      if (jobType != null && jobType != 'both') {
        query = query.eq('payment_type', jobType);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      // Sortierung
      dynamic finalQuery;
      switch (sortBy) {
        case 'popular':
          finalQuery = query.order('views', ascending: false);
          break;
        case 'newest':
          finalQuery = query.order('created_at', ascending: false);
          break;
        case 'distance':
          // TODO: Implementiere Distanz-Sortierung
          finalQuery = query.order('created_at', ascending: false);
          break;
        default:
          finalQuery = query.order('created_at', ascending: false);
      }

      final response = await finalQuery.limit(50);
      
      if (response.isEmpty) return [];

      return response.map((job) => {
        'id': job['id'],
        'title': job['title'],
        'description': job['description'],
        'payment': job['payment_amount'] != null 
            ? '${job['payment_amount']} ${job['payment_currency'] ?? 'CHF'}'
            : job['payment_description'] ?? 'Tausch',
        'location': job['location_name'] ?? 'Unbekannt',
        'type': job['payment_type'] == 'paid' ? 'Bezahlt' : 'Tausch',
        'imageUrl': job['image_url'],
        'latitude': job['latitude'],
        'longitude': job['longitude'],
        'category': job['category'] ?? 'Sonstiges',
        'isPremium': job['is_premium'] ?? false,
        'categories': job['tags'] ?? [],
      }).toList();
    } catch (e) {
      debugPrint('Fehler beim Abrufen der Jobs: $e');
      return [];
    }
  }

  /// Create a new job
  static Future<bool> createJob(Map<String, dynamic> jobData) async {
    try {
      if (kDebugMode) {
        return true;
      }

      await _supabase.from('jobs').insert({
        'title': jobData['title'],
        'description': jobData['description'],
        'category': jobData['category'],
        'payment_type': jobData['paymentType'], // 'paid', 'barter'
        'payment_amount': jobData['paymentAmount'],
        'payment_currency': jobData['paymentCurrency'] ?? 'CHF',
        'payment_description': jobData['paymentDescription'],
        'owner_id': jobData['ownerId'],
        'latitude': jobData['latitude'],
        'longitude': jobData['longitude'],
        'location_name': jobData['location'],
        'is_active': true,
        'is_premium': false,
        'tags': jobData['tags'] ?? [],
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Fehler beim Erstellen des Jobs: $e');
      return false;
    }
  }

  /// Apply for a job
  static Future<bool> applyForJob(String userId, String jobId, String message) async {
    try {
      if (kDebugMode) {
        return true;
      }

      await _supabase.from('job_applications').insert({
        'user_id': userId,
        'job_id': jobId,
        'message': message,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Fehler beim Bewerben für den Job: $e');
      return false;
    }
  }
}
