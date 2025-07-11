import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/texts.dart';
import '../widgets/chat_message_tile.dart';
// import '../services/chat_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String otherUserName;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  // final ChatService _chatService = ChatService();
  // String? _currentUserId;
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    // _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _loadDummyMessages();
  }

  void _loadDummyMessages() {
    // TODO: Firebase wieder aktivieren
    // _chatService.getChatMessages(widget.chatId).listen((snapshot) {
    //   if (snapshot != null) {
    //     setState(() {
    //       _messages.clear();
    //       for (var doc in snapshot.docs) {
    //         _messages.add(doc.data());
    //       }
    //     });
    //   }
    // });

    // Dummy-Nachrichten für Entwicklung
    setState(() {
      _messages.addAll([
        {
          'text': 'Hallo! Ist das Snowboard noch verfügbar?',
          'senderId': 'other_user',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
        },
        {
          'text': 'Ja, ist es! Möchtest du es tauschen?',
          'senderId': 'dummy_user_123',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 3)),
        },
        {
          'text': 'Gerne! Was suchst du dafür?',
          'senderId': 'other_user',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 1)),
        },
      ]);
    });
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final newMessage = {
      'text': message,
      'senderId': 'dummy_user_123',
      'timestamp': DateTime.now(),
    };

    setState(() {
      _messages.add(newMessage);
    });

    _messageController.clear();

    // TODO: Firebase wieder aktivieren
    // await _chatService.sendMessage(widget.chatId, message, _currentUserId!);
    await Future.delayed(const Duration(milliseconds: 200));
    print('Nachricht würde gesendet: $message');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                final isMe = message['senderId'] == 'dummy_user_123';

                return ChatMessageTile(
                  message: message['text'],
                  isMe: isMe,
                  timestamp: message['timestamp'],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: AppTexts.typeMessage,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
