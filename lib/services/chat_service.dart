import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';

class ChatService extends ChangeNotifier {
  final StreamController<List<ChatModel>> _chatsController =
      StreamController<List<ChatModel>>.broadcast();

  Stream<List<ChatModel>> get chatsStream => _chatsController.stream;

  // Chat erstellen oder abrufen
  Future<String> createOrGetChat(String userA, String userB) async {
    try {
      final currentUser = AuthService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User nicht angemeldet');
      }

      // Prüfe ob Chat bereits existiert
      final existingChats = await DatabaseService.getUserChats(currentUser.id);
      try {
        final existingChat = existingChats.firstWhere(
          (chat) =>
              (chat.buyerId == userA && chat.sellerId == userB) ||
              (chat.buyerId == userB && chat.sellerId == userA),
        );
        return existingChat.id;
      } catch (e) {
        // Chat nicht gefunden, erstelle neuen
      }

      // Erstelle neuen Chat
      final newChat = await DatabaseService.createChat(
        '', // listingId (optional)
        userA, // buyerId
        userB, // sellerId
      );

      return newChat?.id ?? '';
    } catch (e) {
      debugPrint('❌ Fehler beim Erstellen/Abrufen des Chats: $e');
      return '';
    }
  }

  // Alle Chats für User laden
  Future<List<ChatModel>> getChats(String userId) async {
    try {
      return await DatabaseService.getUserChats(userId);
    } catch (e) {
      debugPrint('❌ Fehler beim Laden der Chats: $e');
      return [];
    }
  }

  // Nachrichten für Chat laden
  Future<List<ChatMessage>> getChatMessages(String chatId) async {
    try {
      return await DatabaseService.getChatMessages(chatId);
    } catch (e) {
      debugPrint('❌ Fehler beim Laden der Nachrichten: $e');
      return [];
    }
  }

  // Nachricht senden
  Future<bool> sendMessage(
    String chatId,
    String message,
    String senderId,
  ) async {
    try {
      final chatMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: chatId,
        userId: senderId,
        message: message,
        createdAt: DateTime.now(),
      );

      await DatabaseService.sendMessage(chatMessage);
      return true;
    } catch (e) {
      debugPrint('❌ Fehler beim Senden der Nachricht: $e');
      return false;
    }
  }

  // Dispose
  @override
  void dispose() {
    _chatsController.close();
    super.dispose();
  }
}
