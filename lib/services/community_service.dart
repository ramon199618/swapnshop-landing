import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/community_model.dart';
import '../models/user_model.dart';
import '../config/supabase_config.dart';

class CommunityService {
  static final SupabaseClient _client = Supabase.instance.client;

  // ===== COMMUNITY CRUD =====

  static Future<List<CommunityModel>> getCommunities({
    String? userId,
    double? lat,
    double? lon,
    double? radius,
  }) async {
    try {
      var query = _client.from(SupabaseConfig.communitiesTable).select();

      // Filter by location if provided
      if (lat != null && lon != null && radius != null) {
        // Implement location-based filtering with PostGIS
        // This requires PostGIS extension in Supabase
        // For now, return all communities - PostGIS function needs to be created
        debugPrint(
            '📍 Location filtering: lat=$lat, lon=$lon, radius=${radius}km');
      }

      final response = await query;
      if (response.isNotEmpty) {
        return response.map((json) => CommunityModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error getting communities: $e');
      return [];
    }
  }

  static Future<CommunityModel?> createCommunity(
      CommunityModel community) async {
    try {
      final response = await _client
          .from(SupabaseConfig.communitiesTable)
          .insert(community.toJson())
          .select()
          .single();

      return CommunityModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error creating community: $e');
      return null;
    }
  }

  static Future<bool> updateCommunity(
      String id, Map<String, dynamic> updates) async {
    try {
      await _client
          .from(SupabaseConfig.communitiesTable)
          .update(updates)
          .eq('id', id);
      return true;
    } catch (e) {
      debugPrint('❌ Error updating community: $e');
      return false;
    }
  }

  static Future<bool> deleteCommunity(String id) async {
    try {
      // Delete members first
      await _client
          .from(SupabaseConfig.communityMembersTable)
          .delete()
          .eq('community_id', id);

      // Delete posts
      await _client
          .from(SupabaseConfig.communityPostsTable)
          .delete()
          .eq('community_id', id);

      // Delete community
      await _client.from(SupabaseConfig.communitiesTable).delete().eq('id', id);

      return true;
    } catch (e) {
      debugPrint('❌ Error deleting community: $e');
      return false;
    }
  }

  // ===== MEMBERSHIP =====

  static Future<bool> joinCommunity(String communityId, String userId) async {
    try {
      await _client.from(SupabaseConfig.communityMembersTable).insert({
        'community_id': communityId,
        'user_id': userId,
        'joined_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('❌ Error joining community: $e');
      return false;
    }
  }

  static Future<bool> leaveCommunity(String communityId, String userId) async {
    try {
      await _client
          .from(SupabaseConfig.communityMembersTable)
          .delete()
          .eq('community_id', communityId)
          .eq('user_id', userId);
      return true;
    } catch (e) {
      debugPrint('❌ Error leaving community: $e');
      return false;
    }
  }

  static Future<List<UserModel>> getCommunityMembers(String communityId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.communityMembersTable)
          .select('user_id, users(*)')
          .eq('community_id', communityId);

      return response.map((json) => UserModel.fromMap(json['users'])).toList();
    } catch (e) {
      debugPrint('❌ Error getting community members: $e');
      return [];
    }
  }

  // ===== POSTS =====

  static Future<List<Map<String, dynamic>>> getCommunityPosts(
      String communityId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.communityPostsTable)
          .select('*, users(name, avatar_url)')
          .eq('community_id', communityId)
          .order('created_at', ascending: false);

      return response
          .map((json) => {
                'id': json['id'],
                'content': json['content'],
                'userName': json['users']['name'],
                'userAvatar': json['users']['avatar_url'],
                'timestamp': DateTime.parse(json['created_at']),
              })
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting community posts: $e');
      return [];
    }
  }

  static Future<bool> createPost(
      String communityId, String userId, String content) async {
    try {
      await _client.from(SupabaseConfig.communityPostsTable).insert({
        'community_id': communityId,
        'user_id': userId,
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('❌ Error creating post: $e');
      return false;
    }
  }

  // ===== INVITE FUNCTIONALITY =====

  static Future<String?> generateInviteLink(String communityId) async {
    try {
      // Create a unique invite link
      final inviteCode = 'invite_${DateTime.now().millisecondsSinceEpoch}';

      await _client.from(SupabaseConfig.communityInvitesTable).insert({
        'community_id': communityId,
        'invite_code': inviteCode,
        'created_at': DateTime.now().toIso8601String(),
        'expires_at':
            DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      });

      return 'https://swapshop.app/join/$inviteCode';
    } catch (e) {
      debugPrint('❌ Error generating invite link: $e');
      return null;
    }
  }

  static Future<bool> joinCommunityByInvite(
      String inviteCode, String userId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.communityInvitesTable)
          .select('community_id')
          .eq('invite_code', inviteCode)
          .gte('expires_at', DateTime.now().toIso8601String())
          .single();

      return await joinCommunity(response['community_id'], userId);
    } catch (e) {
      debugPrint('❌ Error joining community by invite: $e');
      return false;
    }
  }

  // ===== DISCOVER SCREEN - GROUPS =====

  /// Get groups for discover screen
  static Future<List<Map<String, dynamic>>> getGroups({
    String? category,
    double? radiusKm,
    String? searchQuery,
    String? sortBy,
    double? lat,
    double? lon,
  }) async {
    try {
      if (kDebugMode) {
        // Simuliere Gruppen-Daten
        await Future.delayed(const Duration(milliseconds: 300));
        return [
          {
            'id': 'group_1',
            'name': 'Fahrradtouren Zürich',
            'description': 'Regelmäßige Fahrradtouren in und um Zürich',
            'memberCount': 45,
            'category': 'Sport & Freizeit',
            'imageUrl': 'assets/images/placeholder_group.jpg',
            'latitude': 47.3769,
            'longitude': 8.5417,
            'location': 'Zürich',
            'isPremium': false,
            'categories': ['Sport', 'Freizeit', 'Fahrrad'],
          },
          {
            'id': 'group_2',
            'name': 'Nachhaltigkeit Zürich',
            'description': 'Austausch über nachhaltige Lebensweise',
            'memberCount': 128,
            'category': 'Umwelt & Nachhaltigkeit',
            'imageUrl': 'assets/images/placeholder_group.jpg',
            'latitude': 47.3769,
            'longitude': 8.5417,
            'location': 'Zürich',
            'isPremium': true,
            'categories': ['Umwelt', 'Nachhaltigkeit', 'Lifestyle'],
          },
          {
            'id': 'group_3',
            'name': 'Lokale Events',
            'description': 'Entdeckung lokaler Veranstaltungen und Märkte',
            'memberCount': 89,
            'category': 'Events & Kultur',
            'imageUrl': 'assets/images/placeholder_group.jpg',
            'latitude': 47.3769,
            'longitude': 8.5417,
            'location': 'Zürich',
            'isPremium': false,
            'categories': ['Events', 'Kultur', 'Lokal'],
          },
        ];
      }

      // Rufe Gruppen über Supabase ab
      var query = _client
          .from(SupabaseConfig.communitiesTable)
          .select('*')
          .eq('type', 'group')
          .eq('is_active', true);

      if (category != null && category != 'Alle') {
        query = query.eq('category', category);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query
            .or('name.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      // Sortierung
      dynamic finalQuery;
      switch (sortBy) {
        case 'popular':
          finalQuery = query.order('member_count', ascending: false);
          break;
        case 'newest':
          finalQuery = query.order('created_at', ascending: false);
          break;
        case 'distance':
          // Distanz-Sortierung implementieren
          if (lat != null && lon != null) {
            // Sortiere nach Distanz wenn Standort verfügbar
            final response =
                await query.limit(100); // Mehr laden für Sortierung
            if (response.isNotEmpty) {
              final sortedGroups = _sortByDistance(lat, lon, response);
              return sortedGroups.take(50).toList(); // Nur erste 50 zurückgeben
            }
            return [];
          } else {
            // Fallback: Nach Erstellungsdatum sortieren
            finalQuery = query.order('created_at', ascending: false);
          }
          break;
        default:
          finalQuery = query.order('created_at', ascending: false);
      }

      final response = await finalQuery.limit(50);

      if (response.isEmpty) return [];

      return response
          .map((group) => {
                'id': group['id'],
                'name': group['name'],
                'description': group['description'],
                'memberCount': group['member_count'] ?? 0,
                'category': group['category'] ?? 'Sonstiges',
                'imageUrl': group['image_url'],
                'latitude': group['latitude'],
                'longitude': group['longitude'],
                'location': group['location_name'] ?? 'Unbekannt',
                'isPremium': group['is_premium'] ?? false,
                'categories': group['tags'] ?? [],
              })
          .toList();
    } catch (e) {
      debugPrint('Fehler beim Abrufen der Gruppen: $e');
      return [];
    }
  }

  /// Get group listings for swipe feed
  static Future<List<Map<String, dynamic>>> getGroupListings(
      String groupId) async {
    try {
      if (kDebugMode) {
        return [];
      }

      final response = await _client
          .from('listings')
          .select('*')
          .eq('group_id', groupId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      if (response.isEmpty) return [];

      return response
          .map((listing) => {
                'id': listing['id'],
                'title': listing['title'],
                'description': listing['description'],
                'type': listing['type'],
                'category': listing['category'],
                'owner_id': listing['owner_id'],
                'images': listing['images'] ?? [],
                'tags': listing['tags'] ?? [],
                'latitude': listing['latitude'],
                'longitude': listing['longitude'],
                'location_name': listing['location_name'],
                'created_at': listing['created_at'],
              })
          .toList();
    } catch (e) {
      debugPrint('Fehler beim Abrufen der Gruppen-Inserate: $e');
      return [];
    }
  }

  /// Sort groups by distance using Haversine formula
  static List<Map<String, dynamic>> _sortByDistance(
      double userLat, double userLon, List<Map<String, dynamic>> groups) {
    final sortedGroups = List<Map<String, dynamic>>.from(groups);

    sortedGroups.sort((a, b) {
      final aLat = (a['latitude'] ?? 0.0).toDouble();
      final aLon = (a['longitude'] ?? 0.0).toDouble();
      final bLat = (b['latitude'] ?? 0.0).toDouble();
      final bLon = (b['longitude'] ?? 0.0).toDouble();

      final aDistance = _calculateDistance(userLat, userLon, aLat, aLon);
      final bDistance = _calculateDistance(userLat, userLon, bLat, bLon);

      return aDistance.compareTo(bDistance);
    });

    return sortedGroups;
  }

  /// Calculate distance between two points using Haversine formula
  static double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        sin(lat1 * pi / 180) *
            sin(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
