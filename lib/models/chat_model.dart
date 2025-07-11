// import 'package:cloud_firestore/cloud_firestore.dart';

// ChatModel für Firestore-Chats
class ChatModel {
  final String id;
  final List<String> participants;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  ChatModel({
    required this.id,
    required this.participants,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory ChatModel.fromJson(String id, Map<String, dynamic> json) {
    return ChatModel(
      id: id,
      participants: List<String>.from(json['participants'] ?? []),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participants': participants,
      'createdAt': createdAt.toIso8601String(),
      if (lastMessage != null) 'lastMessage': lastMessage,
      if (lastMessageTime != null)
        'lastMessageTime': lastMessageTime!.toIso8601String(),
    };
  }
}

// TODO: ChatModel für später implementieren
