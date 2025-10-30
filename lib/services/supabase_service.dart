import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/listing.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';
import '../models/community_model.dart';
import '../models/store_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  // =====================================================
  // AUTHENTICATION
  // =====================================================

  /// Sign up new user
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': displayName,
        },
      );

      if (response.user != null) {
        // Create profile
        await createProfile(
          id: response.user!.id,
          email: email,
          displayName: displayName,
        );
      }

      return response;
    } catch (e) {
      throw Exception('Registrierung fehlgeschlagen: $e');
    }
  }

  /// Sign in user
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Anmeldung fehlgeschlagen: $e');
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw Exception('Abmeldung fehlgeschlagen: $e');
    }
  }

  /// Get current user
  User? get currentUser => client.auth.currentUser;

  /// Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final response =
          await client.from('profiles').select().eq('id', user.id).single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Profil konnte nicht geladen werden: $e');
    }
  }

  // =====================================================
  // PROFILES
  // =====================================================

  /// Create user profile
  Future<void> createProfile({
    required String id,
    required String email,
    required String displayName,
  }) async {
    try {
      await client.from('profiles').insert({
        'id': id,
        'email': email,
        'display_name': displayName,
        'username': displayName.toLowerCase().replaceAll(' ', '_'),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Profil konnte nicht erstellt werden: $e');
    }
  }

  /// Update user profile
  Future<void> updateProfile(UserModel profile) async {
    try {
      await client.from('profiles').update({
        'display_name': profile.name,
        'bio': profile.bio,
        'location': profile.location,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', profile.id);
    } catch (e) {
      throw Exception('Profil konnte nicht aktualisiert werden: $e');
    }
  }

  /// Get profiles by location
  Future<List<UserModel>> getProfilesByLocation({
    required double latitude,
    required double longitude,
    required int radiusKm,
  }) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .order('last_active_at', ascending: false);

      return response.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Profile konnten nicht geladen werden: $e');
    }
  }

  // =====================================================
  // LISTINGS
  // =====================================================

  /// Get listings by location and type
  Future<List<Listing>> getListings({
    required double latitude,
    required double longitude,
    required int radiusKm,
    String? listingType,
    String? categoryId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('listings')
          .select('''
            *,
            listing_images(*),
            listing_tags(*),
            profiles!listings_user_id_fkey(*)
          ''')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map((json) => Listing.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Listings konnten nicht geladen werden: $e');
    }
  }

  /// Create new listing
  Future<Listing> createListing(Listing listing) async {
    try {
      final response = await client
          .from('listings')
          .insert({
            'user_id': listing.ownerId,
            'category_id': listing.category,
            'title': listing.title,
            'description': listing.description,
            'condition': listing.condition,
            'listing_type': listing.type.toString(),
            'price': listing.price,
            'currency': 'CHF',
            'location': listing.locationName,
            'latitude': listing.latitude,
            'longitude': listing.longitude,
            'is_anonymous': listing.isAnonymous,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return Listing.fromJson(response);
    } catch (e) {
      throw Exception('Listing konnte nicht erstellt werden: $e');
    }
  }

  /// Update listing
  Future<void> updateListing(Listing listing) async {
    try {
      await client.from('listings').update({
        'title': listing.title,
        'description': listing.description,
        'condition': listing.condition,
        'price': listing.price,
        'location': listing.locationName,
        'latitude': listing.latitude,
        'longitude': listing.longitude,
        'is_anonymous': listing.isAnonymous,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', listing.id);
    } catch (e) {
      throw Exception('Listing konnte nicht aktualisiert werden: $e');
    }
  }

  /// Delete listing
  Future<void> deleteListing(String listingId) async {
    try {
      await client.from('listings').delete().eq('id', listingId);
    } catch (e) {
      throw Exception('Listing konnte nicht gelöscht werden: $e');
    }
  }

  // =====================================================
  // LIKES & MATCHES
  // =====================================================

  /// Like or dislike a listing
  Future<void> likeListing({
    required String listingId,
    required bool isLike,
  }) async {
    try {
      await client.from('likes').upsert({
        'user_id': currentUser!.id,
        'listing_id': listingId,
        'is_like': isLike,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Like konnte nicht gespeichert werden: $e');
    }
  }

  /// Get user's likes
  Future<List<Map<String, dynamic>>> getUserLikes() async {
    try {
      final response = await client
          .from('likes')
          .select('''
            *,
            listings!likes_listing_id_fkey(*)
          ''')
          .eq('user_id', currentUser!.id)
          .eq('is_like', true)
          .order('created_at', ascending: false);

      return response;
    } catch (e) {
      throw Exception('Likes konnten nicht geladen werden: $e');
    }
  }

  /// Get matches
  Future<List<Map<String, dynamic>>> getMatches() async {
    try {
      final response = await client
          .from('matches')
          .select('''
            *,
            listings!matches_listing1_id_fkey(*),
            listings!matches_listing2_id_fkey(*),
            profiles!matches_user1_id_fkey(*),
            profiles!matches_user2_id_fkey(*)
          ''')
          .or('user1_id.eq.${currentUser!.id},user2_id.eq.${currentUser!.id}')
          .eq('status', 'active')
          .order('created_at', ascending: false);

      return response;
    } catch (e) {
      throw Exception('Matches konnten nicht geladen werden: $e');
    }
  }

  // =====================================================
  // CHATS & MESSAGES
  // =====================================================

  /// Get user's chats
  Future<List<ChatModel>> getUserChats() async {
    try {
      final response = await client
          .from('chats')
          .select('''
            *,
            profiles!chats_user1_id_fkey(*),
            profiles!chats_user2_id_fkey(*),
            messages(*)
          ''')
          .or('user1_id.eq.${currentUser!.id},user2_id.eq.${currentUser!.id}')
          .eq('is_active', true)
          .order('last_message_at', ascending: false);

      return response.map((json) => ChatModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Chats konnten nicht geladen werden: $e');
    }
  }

  /// Get chat messages
  Future<List<Map<String, dynamic>>> getChatMessages(String chatId) async {
    try {
      final response = await client.from('messages').select('''
            *,
            profiles!messages_sender_id_fkey(*)
          ''').eq('chat_id', chatId).order('created_at', ascending: true);

      return response;
    } catch (e) {
      throw Exception('Nachrichten konnten nicht geladen werden: $e');
    }
  }

  /// Send message
  Future<void> sendMessage({
    required String chatId,
    required String content,
    String? imageUrl,
  }) async {
    try {
      await client.from('messages').insert({
        'chat_id': chatId,
        'sender_id': currentUser!.id,
        'content': content,
        'message_type': imageUrl != null ? 'image' : 'text',
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update chat last_message_at
      await client.from('chats').update({
        'last_message_at': DateTime.now().toIso8601String(),
      }).eq('id', chatId);
    } catch (e) {
      throw Exception('Nachricht konnte nicht gesendet werden: $e');
    }
  }

  // =====================================================
  // COMMUNITIES
  // =====================================================

  /// Get communities by location
  Future<List<CommunityModel>> getCommunitiesByLocation({
    required double latitude,
    required double longitude,
    required int radiusKm,
  }) async {
    try {
      final response = await client
          .from('communities')
          .select('''
            *,
            community_members(*),
            profiles!communities_created_by_fkey(*)
          ''')
          .eq('is_public', true)
          .eq('is_active', true)
          .order('member_count', ascending: false);

      return response.map((json) => CommunityModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Communities konnten nicht geladen werden: $e');
    }
  }

  /// Join community
  Future<void> joinCommunity(String communityId) async {
    try {
      await client.from('community_members').insert({
        'community_id': communityId,
        'user_id': currentUser!.id,
        'role': 'member',
        'joined_at': DateTime.now().toIso8601String(),
      });

      // Update member count (placeholder - RPC function not implemented yet)
      // await client.rpc('increment_member_count', {'community_id': communityId});
    } catch (e) {
      throw Exception('Community konnte nicht beigetreten werden: $e');
    }
  }

  /// Leave community
  Future<void> leaveCommunity(String communityId) async {
    try {
      await client
          .from('community_members')
          .delete()
          .eq('community_id', communityId)
          .eq('user_id', currentUser!.id);

      // Update member count (placeholder - RPC function not implemented yet)
      // await client.rpc('decrement_member_count', {'community_id': communityId});
    } catch (e) {
      throw Exception('Community konnte nicht verlassen werden: $e');
    }
  }

  // =====================================================
  // STORES
  // =====================================================

  /// Get stores by location
  Future<List<StoreModel>> getStoresByLocation({
    required double latitude,
    required double longitude,
    required int radiusKm,
  }) async {
    try {
      final response = await client.from('stores').select('''
            *,
            profiles!stores_owner_id_fkey(*),
            store_listings(*)
          ''').eq('is_active', true).order('view_count', ascending: false);

      return response.map((json) => StoreModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Stores konnten nicht geladen werden: $e');
    }
  }

  /// Create store
  Future<StoreModel> createStore(StoreModel store) async {
    try {
      final response = await client
          .from('stores')
          .insert({
            'owner_id': store.ownerId,
            'name': store.name,
            'description': store.description,
            'store_type': store.storeType,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return StoreModel.fromJson(response);
    } catch (e) {
      throw Exception('Store konnte nicht erstellt werden: $e');
    }
  }

  // =====================================================
  // JOBS (Placeholder - Jobs feature not implemented yet)
  // =====================================================

  /// Get jobs by location (placeholder)
  Future<List<Map<String, dynamic>>> getJobsByLocation({
    required double latitude,
    required double longitude,
    required int radiusKm,
  }) async {
    try {
      final response = await client.from('jobs').select('''
            *,
            profiles!jobs_user_id_fkey(*)
          ''').eq('is_active', true).order('created_at', ascending: false);

      return response;
    } catch (e) {
      throw Exception('Jobs konnten nicht geladen werden: $e');
    }
  }

  /// Apply for job (placeholder)
  Future<void> applyForJob({
    required String jobId,
    String? coverLetter,
  }) async {
    try {
      await client.from('job_applications').insert({
        'job_id': jobId,
        'applicant_id': currentUser!.id,
        'cover_letter': coverLetter,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Bewerbung konnte nicht gesendet werden: $e');
    }
  }

  // =====================================================
  // REAL-TIME SUBSCRIPTIONS
  // =====================================================

  /// Subscribe to chat messages
  RealtimeChannel subscribeToChatMessages(
      String chatId, Function(Map<String, dynamic>) onMessage) {
    return client
        .channel('chat_$chatId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_id',
            value: chatId,
          ),
          callback: (payload) => onMessage(payload.newRecord),
        )
        .subscribe();
  }

  /// Subscribe to new matches
  RealtimeChannel subscribeToMatches(Function(Map<String, dynamic>) onMatch) {
    return client
        .channel('matches_${currentUser!.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'matches',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user1_id',
            value: currentUser!.id,
          ),
          callback: (payload) => onMatch(payload.newRecord),
        )
        .subscribe();
  }

  /// Subscribe to new listings
  RealtimeChannel subscribeToNewListings({
    required double latitude,
    required double longitude,
    required int radiusKm,
    Function(Map<String, dynamic>)? onNewListing,
  }) {
    return client
        .channel('listings_${currentUser!.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'listings',
          callback: (payload) {
            final listing = payload.newRecord;
            // Check if listing is within radius
            final listingLat = listing['latitude'] as double?;
            final listingLng = listing['longitude'] as double?;

            if (listingLat != null && listingLng != null) {
              final distance = _calculateDistance(
                  latitude, longitude, listingLat, listingLng);
              if (distance <= radiusKm && onNewListing != null) {
                onNewListing(listing);
              }
            }
          },
        )
        .subscribe();
  }

  // =====================================================
  // HELPER FUNCTIONS
  // =====================================================

  /// Calculate distance between two points
  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // km
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLng = _degreesToRadians(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
