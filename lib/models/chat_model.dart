// import 'package:cloud_firestore/cloud_firestore.dart';

// ChatModel für Firestore-Chats
class ChatModel {
  final String id;
  final String? listingId;
  final String? buyerId;
  final String? sellerId;
  final DateTime createdAt;
  final DateTime lastMessageAt;

  ChatModel({
    required this.id,
    this.listingId,
    this.buyerId,
    this.sellerId,
    required this.createdAt,
    required this.lastMessageAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String,
      listingId: json['listing_id'] as String?,
      buyerId: json['buyer_id'] as String?,
      sellerId: json['seller_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastMessageAt: DateTime.parse(json['last_message_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listing_id': listingId,
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'created_at': createdAt.toIso8601String(),
      'last_message_at': lastMessageAt.toIso8601String(),
    };
  }

  ChatModel copyWith({
    String? id,
    String? listingId,
    String? buyerId,
    String? sellerId,
    DateTime? createdAt,
    DateTime? lastMessageAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    );
  }
}

class ChatMessage {
  final String id;
  final String chatId;
  final String userId;
  final String message;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.userId,
    required this.message,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      userId: json['user_id'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'user_id': userId,
      'message': message,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ChatMessage copyWith({
    String? id,
    String? chatId,
    String? userId,
    String? message,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
