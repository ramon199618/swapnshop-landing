import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../widgets/chat_message_tile.dart';

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
  final List<Map<String, dynamic>> _messages = [];
  final ChatService _chatService = ChatService();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadMessages();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = AuthService.getCurrentUser();
      if (user != null) {
        setState(() {
          _currentUserId = user.id;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading current user: $e');
    }
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _chatService.getChatMessages(widget.chatId);

      setState(() {
        _messages.clear();
        for (final message in messages) {
          _messages.add({
            'text': message.message,
            'senderId': message.userId,
            'timestamp': message.createdAt,
          });
        }
      });
    } catch (e) {
      debugPrint('❌ Error loading messages: $e');
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _currentUserId == null) return;

    final newMessage = {
      'text': message,
      'senderId': _currentUserId,
      'timestamp': DateTime.now(),
    };

    setState(() {
      _messages.add(newMessage);
    });

    _messageController.clear();

    try {
      final success = await _chatService.sendMessage(
        widget.chatId,
        message,
        _currentUserId!,
      );

      if (!success && mounted) {
        // Remove the message if sending failed
        setState(() {
          _messages.removeLast();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Senden der Nachricht')),
        );
      }
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      if (mounted) {
        setState(() {
          _messages.removeLast();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Senden der Nachricht')),
        );
      }
    }
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
                final isMe = message['senderId'] == _currentUserId;

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
                  color: Colors.black.withValues(alpha: 0.1),
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
                      hintText:
                          'Type a message...', // Changed from AppTexts.typeMessage
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: AppColors.primary),
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
