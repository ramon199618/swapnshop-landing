import 'package:flutter/foundation.dart';
import '../services/database_service.dart';

class MatchModel {
  final String id;
  final String userAId;
  final String userBId;
  final String? listingAId;
  final String? listingBId;
  final DateTime createdAt;
  final bool isActive;
  final String? lastMessageId;
  final DateTime? lastMessageAt;

  MatchModel({
    required this.id,
    required this.userAId,
    required this.userBId,
    this.listingAId,
    this.listingBId,
    required this.createdAt,
    this.isActive = true,
    this.lastMessageId,
    this.lastMessageAt,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] as String,
      userAId: json['user_a_id'] as String,
      userBId: json['user_b_id'] as String,
      listingAId: json['listing_a_id'] as String?,
      listingBId: json['listing_b_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      lastMessageId: json['last_message_id'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_a_id': userAId,
      'user_b_id': userBId,
      'listing_a_id': listingAId,
      'listing_b_id': listingBId,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
      'last_message_id': lastMessageId,
      'last_message_at': lastMessageAt?.toIso8601String(),
    };
  }

  MatchModel copyWith({
    String? id,
    String? userAId,
    String? userBId,
    String? listingAId,
    String? listingBId,
    DateTime? createdAt,
    bool? isActive,
    String? lastMessageId,
    DateTime? lastMessageAt,
  }) {
    return MatchModel(
      id: id ?? this.id,
      userAId: userAId ?? this.userAId,
      userBId: userBId ?? this.userBId,
      listingAId: listingAId ?? this.listingAId,
      listingBId: listingBId ?? this.listingBId,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    );
  }

  // Helper methods
  bool involvesUser(String userId) {
    return userAId == userId || userBId == userId;
  }

  String getOtherUserId(String currentUserId) {
    return currentUserId == userAId ? userBId : userAId;
  }

  String? getOtherListingId(String currentListingId) {
    if (currentListingId == listingAId) return listingBId;
    if (currentListingId == listingBId) return listingAId;
    return null;
  }

  bool isRecent() {
    final daysSinceMatch = DateTime.now().difference(createdAt).inDays;
    return daysSinceMatch <=
        7; // Match ist "recent" wenn weniger als 7 Tage alt
  }

  Future<bool> hasUnreadMessages(String currentUserId) async {
    try {
      final unreadCount =
          await DatabaseService.getUnreadMessageCount(id, currentUserId);
      return unreadCount > 0;
    } catch (e) {
      debugPrint('❌ Error checking unread messages: $e');
      return false;
    }
  }
}
