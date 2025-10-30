import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/listing.dart';
import '../models/user_model.dart';
import '../models/community_model.dart';
import '../models/chat_model.dart';
import '../config/supabase_config.dart';

class DatabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // ===== USER PROFILE OPERATIONS =====

  static Future<UserModel?> getCurrentUserProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response = await _client
          .from(SupabaseConfig.profilesTable)
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error getting user profile: $e');
      return null;
    }
  }

  static Future<void> createUserProfile(UserModel profile) async {
    try {
      await _client.from(SupabaseConfig.profilesTable).insert(profile.toJson());
    } catch (e) {
      debugPrint('❌ Error creating user profile: $e');
      rethrow;
    }
  }

  static Future<void> updateUserProfile(UserModel profile) async {
    try {
      await _client
          .from(SupabaseConfig.profilesTable)
          .update(profile.toJson())
          .eq('id', profile.id);
    } catch (e) {
      debugPrint('❌ Error updating user profile: $e');
      rethrow;
    }
  }

  // ===== MONTHLY LIMITS OPERATIONS =====

  static Future<void> resetMonthlyLimitsIfNeeded(String userId) async {
    try {
      await _client
          .rpc('reset_monthly_limits_if_needed', params: {'user_uuid': userId});
    } catch (e) {
      debugPrint('❌ Error resetting monthly limits: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getUserMonthlyLimits(
      String userId) async {
    try {
      final currentMonth = DateTime.now().toString().substring(0, 7); // YYYY-MM

      final response = await _client
          .from('user_monthly_limits')
          .select()
          .eq('user_id', userId)
          .eq('month_key', currentMonth)
          .single();

      return response;
    } catch (e) {
      debugPrint('❌ Error getting user monthly limits: $e');
      return null;
    }
  }

  static Future<void> updateUserMonthlyLimits(
    String userId, {
    int? swapsUsed,
    int? sellsUsed,
    int? addonSwapsRemaining,
    int? addonSellsRemaining,
  }) async {
    try {
      final currentMonth = DateTime.now().toString().substring(0, 7); // YYYY-MM

      final updateData = <String, dynamic>{};
      if (swapsUsed != null) updateData['swaps_used'] = swapsUsed;
      if (sellsUsed != null) updateData['sells_used'] = sellsUsed;
      if (addonSwapsRemaining != null) {
        updateData['addon_swaps_remaining'] = addonSwapsRemaining;
      }
      if (addonSellsRemaining != null) {
        updateData['addon_sells_remaining'] = addonSellsRemaining;
      }

      await _client
          .from('user_monthly_limits')
          .update(updateData)
          .eq('user_id', userId)
          .eq('month_key', currentMonth);
    } catch (e) {
      debugPrint('❌ Error updating user monthly limits: $e');
      rethrow;
    }
  }

  static Future<void> addAddonSwaps(String userId, int count) async {
    try {
      final limits = await getUserMonthlyLimits(userId);
      if (limits != null) {
        final currentCount = limits['addon_swaps_remaining'] ?? 0;
        await updateUserMonthlyLimits(userId,
            addonSwapsRemaining: currentCount + count);
      }
    } catch (e) {
      debugPrint('❌ Error adding addon swaps: $e');
      rethrow;
    }
  }

  static Future<void> addAddonSells(String userId, int count) async {
    try {
      final limits = await getUserMonthlyLimits(userId);
      if (limits != null) {
        final currentCount = limits['addon_sells_remaining'] ?? 0;
        await updateUserMonthlyLimits(userId,
            addonSellsRemaining: currentCount + count);
      }
    } catch (e) {
      debugPrint('❌ Error adding addon sells: $e');
      rethrow;
    }
  }

  // ===== STORE OPERATIONS =====

  static Future<void> createStore(Map<String, dynamic> storeData) async {
    try {
      debugPrint('🔧 Creating store with data: $storeData');
      debugPrint('🔧 Using table: ${SupabaseConfig.storesTable}');

      // Stelle sicher, dass alle erforderlichen Felder vorhanden sind
      final completeStoreData = {
        ...storeData,
        'status': 'active', // Füge Status hinzu, falls nicht vorhanden
        'updated_at': DateTime.now().toIso8601String(), // Füge updated_at hinzu
      };

      // Prüfe zuerst, ob die Tabelle existiert
      try {
        await _client.from(SupabaseConfig.storesTable).select('id').limit(1);
      } catch (e) {
        if (e.toString().contains('404') ||
            e.toString().contains('Not Found')) {
          throw Exception(
              'Stores-Tabelle existiert nicht in Supabase. Bitte führe fix_stores_table.sql aus.');
        }
        rethrow;
      }

      final response = await _client
          .from(SupabaseConfig.storesTable)
          .insert(completeStoreData)
          .select();
      debugPrint('✅ Store created successfully: $response');
    } catch (e) {
      debugPrint('❌ Error creating store: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      debugPrint('❌ Error details: ${e.toString()}');

      // Spezifische Fehlerbehandlung
      final errorStr = e.toString().toLowerCase();

      if (errorStr.contains('404') || errorStr.contains('not found')) {
        throw Exception(
            'Stores-Tabelle existiert nicht in Supabase.\n\nBitte führe diese Migration aus:\nsupabase_migration_stores_production.sql');
      } else if (errorStr.contains('permission') ||
          errorStr.contains('policy') ||
          errorStr.contains('row-level security')) {
        throw Exception(
            'RLS-Policy-Fehler: Sie haben keine Berechtigung, einen Store zu erstellen.\nBitte melden Sie sich an und versuchen Sie es erneut.');
      } else if (errorStr.contains('violates foreign key')) {
        throw Exception('Ungültige user_id. Bitte melden Sie sich erneut an.');
      } else if (errorStr.contains('null value in column')) {
        final match = RegExp(r'column "(\w+)"').firstMatch(errorStr);
        final column = match?.group(1) ?? 'unbekanntes Feld';
        throw Exception(
            'Pflichtfeld fehlt: $column. Bitte füllen Sie alle Felder aus.');
      } else if (errorStr.contains('violates check constraint')) {
        throw Exception(
            'Ungültiger Wert in einem Feld. Bitte überprüfen Sie Ihre Eingaben.');
      } else {
        throw Exception('Store konnte nicht erstellt werden:\n${e.toString()}');
      }
    }
  }

  static Future<Map<String, dynamic>?> getUserStore(String userId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.storesTable)
          .select()
          .eq('user_id', userId)
          .single();

      return response;
    } catch (e) {
      debugPrint('❌ Error getting user store: $e');
      return null;
    }
  }

  // ===== LISTINGS OPERATIONS =====

  static Future<List<Listing>> getListings({
    String? category,
    double? latitude,
    double? longitude,
    double? radius,
    String? userId,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client
          .from(SupabaseConfig.listingsTable)
          .select('*, profiles(*)')
          .eq('status', 'active');

      if (category != null && category != 'Alle') {
        query = query.eq('category', category);
      }

      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      final response = await query.order('created_at', ascending: false);

      var listings = response.map((json) => Listing.fromJson(json)).toList();

      // Apply pagination after query if needed
      if (offset != null && limit != null) {
        final startIndex = offset;
        final endIndex = offset + limit;
        if (startIndex < listings.length) {
          listings = listings.sublist(startIndex,
              endIndex > listings.length ? listings.length : endIndex);
        } else {
          listings = [];
        }
      } else if (limit != null) {
        listings = listings.take(limit).toList();
      }

      return listings;
    } catch (e) {
      debugPrint('❌ Error getting listings: $e');
      return [];
    }
  }

  static Future<Listing?> createListing(Listing listing) async {
    try {
      final response = await _client
          .from(SupabaseConfig.listingsTable)
          .insert(listing.toJson())
          .select()
          .single();

      return Listing.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error creating listing: $e');
      rethrow;
    }
  }

  static Future<void> updateListing(Listing listing) async {
    try {
      await _client
          .from(SupabaseConfig.listingsTable)
          .update(listing.toJson())
          .eq('id', listing.id);
    } catch (e) {
      debugPrint('❌ Error updating listing: $e');
      rethrow;
    }
  }

  static Future<void> deleteListing(String listingId) async {
    try {
      await _client
          .from(SupabaseConfig.listingsTable)
          .delete()
          .eq('id', listingId);
    } catch (e) {
      debugPrint('❌ Error deleting listing: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getListingById(String listingId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.listingsTable)
          .select('*, profiles(*)')
          .eq('id', listingId)
          .single();

      return response;
    } catch (e) {
      debugPrint('❌ Error getting listing by id: $e');
      return null;
    }
  }

  // ===== LIKES OPERATIONS =====

  static Future<void> likeListing(String listingId, String userId) async {
    try {
      await _client.from(SupabaseConfig.likesTable).insert({
        'listing_id': listingId,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('❌ Error liking listing: $e');
      rethrow;
    }
  }

  static Future<void> unlikeListing(String listingId, String userId) async {
    try {
      await _client
          .from(SupabaseConfig.likesTable)
          .delete()
          .eq('listing_id', listingId)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('❌ Error unliking listing: $e');
      rethrow;
    }
  }

  static Future<List<Listing>> getLikedListings(String userId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.likesTable)
          .select('listings(*, profiles(*))')
          .eq('user_id', userId);

      return response
          .map((json) => Listing.fromJson(json['listings']))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting liked listings: $e');
      return [];
    }
  }

  static Future<List<Listing>> getMatches(String userId) async {
    try {
      // Get listings where current user liked and owner also liked current user's listings
      final response = await _client.rpc('get_user_matches', params: {
        'user_id': userId,
      });

      return response.map((json) => Listing.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error getting matches: $e');
      return [];
    }
  }

  // ===== CHAT OPERATIONS =====

  static Future<List<ChatModel>> getUserChats(String userId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.chatsTable)
          .select('*, chat_participants(*, profiles(*))')
          .contains('participant_ids', [userId]);

      return response.map((json) => ChatModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error getting user chats: $e');
      return [];
    }
  }

  static Future<List<ChatModel>> getChats(String userId) async {
    return getUserChats(userId);
  }

  static Future<ChatModel?> createChat(
      String listingId, String buyerId, String sellerId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.chatsTable)
          .insert({
            'listing_id': listingId,
            'buyer_id': buyerId,
            'seller_id': sellerId,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return ChatModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error creating chat: $e');
      rethrow;
    }
  }

  static Future<List<ChatMessage>> getChatMessages(String chatId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.messagesTable)
          .select('*, profiles(*)')
          .eq('chat_id', chatId)
          .order('created_at', ascending: true);

      return response.map((json) => ChatMessage.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error getting chat messages: $e');
      return [];
    }
  }

  static Future<void> sendMessage(ChatMessage message) async {
    try {
      await _client.from(SupabaseConfig.messagesTable).insert(message.toJson());
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      rethrow;
    }
  }

  // ===== COMMUNITY OPERATIONS =====

  static Future<List<CommunityModel>> getCommunities({
    String? category,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      var query = _client
          .from(SupabaseConfig.communitiesTable)
          .select('*, community_members(*)')
          .eq('status', 'active');

      if (category != null && category != 'Alle') {
        query = query.eq('category', category);
      }

      final response = await query.order('created_at', ascending: false);

      return response.map((json) => CommunityModel.fromJson(json)).toList();
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
      rethrow;
    }
  }

  static Future<CommunityModel?> getCommunity(String communityId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.communitiesTable)
          .select('*, community_members(*)')
          .eq('id', communityId)
          .single();

      return CommunityModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error getting community: $e');
      return null;
    }
  }

  static Future<bool> likePost(String postId, String userId) async {
    try {
      await _client.from(SupabaseConfig.communityPostLikesTable).insert({
        'post_id': postId,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('❌ Error liking post: $e');
      return false;
    }
  }

  static Future<bool> addComment(
      String postId, String userId, String comment) async {
    try {
      await _client.from(SupabaseConfig.communityPostCommentsTable).insert({
        'post_id': postId,
        'user_id': userId,
        'comment': comment,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('❌ Error adding comment: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getCommunityMembers(
      String communityId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.communityMembersTable)
          .select('*, profiles(name, avatar_url)')
          .eq('community_id', communityId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error getting community members: $e');
      return [];
    }
  }

  static Future<bool> promoteMemberToAdmin(
      String communityId, String userId) async {
    try {
      await _client
          .from(SupabaseConfig.communityMembersTable)
          .update({
            'role': 'admin',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('community_id', communityId)
          .eq('user_id', userId);

      return true;
    } catch (e) {
      debugPrint('❌ Error promoting member to admin: $e');
      return false;
    }
  }

  static Future<bool> demoteAdminToMember(
      String communityId, String userId) async {
    try {
      await _client
          .from(SupabaseConfig.communityMembersTable)
          .update({
            'role': 'member',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('community_id', communityId)
          .eq('user_id', userId);

      return true;
    } catch (e) {
      debugPrint('❌ Error demoting admin to member: $e');
      return false;
    }
  }

  static Future<bool> removeMember(String communityId, String userId) async {
    try {
      await _client
          .from(SupabaseConfig.communityMembersTable)
          .delete()
          .eq('community_id', communityId)
          .eq('user_id', userId);

      return true;
    } catch (e) {
      debugPrint('❌ Error removing member: $e');
      return false;
    }
  }

  static Future<void> joinCommunity(String communityId, String userId) async {
    try {
      await _client.from(SupabaseConfig.communityMembersTable).insert({
        'community_id': communityId,
        'user_id': userId,
        'joined_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('❌ Error joining community: $e');
      rethrow;
    }
  }

  static Future<void> leaveCommunity(String communityId, String userId) async {
    try {
      await _client
          .from(SupabaseConfig.communityMembersTable)
          .delete()
          .eq('community_id', communityId)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('❌ Error leaving community: $e');
      rethrow;
    }
  }

  // ===== STORE OPERATIONS =====

  static Future<List<Map<String, dynamic>>> getStores({
    String? category,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      var query = _client
          .from(SupabaseConfig.storesTable)
          .select('*')
          .eq('status', 'active');

      if (category != null && category != 'Alle') {
        query = query.eq('category', category);
      }

      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error getting stores: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getStoreById(String storeId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.storesTable)
          .select('*')
          .eq('id', storeId)
          .single();

      return response;
    } catch (e) {
      debugPrint('❌ Error getting store: $e');
      return null;
    }
  }

  static Future<List<Listing>> getStoreListings(String storeId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.listingsTable)
          .select('*, profiles(*)')
          .eq('store_id', storeId)
          .eq('status', 'active')
          .order('created_at', ascending: false);

      return response.map((json) => Listing.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error getting store listings: $e');
      return [];
    }
  }

  // ===== BANNER OPERATIONS =====

  static Future<bool> cancelBanner(String bannerId) async {
    try {
      await _client.from(SupabaseConfig.bannersTable).update({
        'status': 'cancelled',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', bannerId);

      return true;
    } catch (e) {
      debugPrint('❌ Error cancelling banner: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getUserBanners(
      String userId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.bannersTable)
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error getting user banners: $e');
      return [];
    }
  }

  // ===== MESSAGE OPERATIONS =====

  static Future<int> getUnreadMessageCount(String chatId, String userId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.messagesTable)
          .select('id')
          .eq('chat_id', chatId)
          .neq('user_id', userId)
          .filter('read_at', 'is', null);

      return response.length;
    } catch (e) {
      debugPrint('❌ Error getting unread message count: $e');
      return 0;
    }
  }

  // Search Operations
  static Future<List<Listing>> searchListings({
    required String query,
    double? radius,
    double? latitude,
    double? longitude,
  }) async {
    try {
      var searchQuery = _client
          .from(SupabaseConfig.listingsTable)
          .select('*, profiles(*)')
          .eq('status', 'active')
          .or('title.ilike.%$query%,description.ilike.%$query%,category.ilike.%$query%');

      if (radius != null && latitude != null && longitude != null) {
        // Hier würde die echte Radius-Suche implementiert werden
        // Für jetzt verwenden wir die bestehende getListings-Methode
        return await getListings(
          latitude: latitude,
          longitude: longitude,
          radius: radius,
        );
      }

      final response = await searchQuery.order('created_at', ascending: false);
      return response.map((json) => Listing.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error searching listings: $e');
      return [];
    }
  }

  // ===== TEST OPERATIONS =====

  static Future<bool> testConnection() async {
    try {
      await _client.from(SupabaseConfig.listingsTable).select('id').limit(1);
      return true;
    } catch (e) {
      debugPrint('Database connection test failed: $e');
      return false;
    }
  }

  // ===== LEGACY METHODS FOR COMPATIBILITY =====

  static Future<bool> likeItem(String userId, String listingId) async {
    try {
      await likeListing(listingId, userId);
      return true;
    } catch (e) {
      debugPrint('❌ Error liking item: $e');
      return false;
    }
  }

  static Future<List<String>> getLikedItems(String userId) async {
    try {
      final listings = await getLikedListings(userId);
      return listings.map((listing) => listing.id).toList();
    } catch (e) {
      debugPrint('❌ Error getting liked items: $e');
      return [];
    }
  }
}
