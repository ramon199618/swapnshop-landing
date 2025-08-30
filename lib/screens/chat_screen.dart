import 'package:flutter/material.dart';
import '../widgets/chat_tile.dart';
import '../constants/colors.dart';
import '../constants/texts.dart';
import 'chat_detail_screen.dart';
// import '../services/auth_service.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void _openChat(String chatId, String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChatDetailScreen(chatId: chatId, otherUserName: userName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(255, 87, 34, 0.1),
              Color(0x00000000), // Placeholder, wird durch Theme ersetzt
            ],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.chat_bubble,
                      color: AppColors.primary, size: 28),
                  SizedBox(width: 12),
                  Text(
                    AppTexts.chatTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Spacer(),
                  // Kein Refresh nötig, da StreamBuilder
                ],
              ),
            ),
            // Chat List - Dummy-Daten für Entwicklung
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _loadDummyChats(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final chats = snapshot.data ?? [];
                  if (chats.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            AppTexts.noChats,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      return ChatTile(
                        userName: chat['userName'],
                        lastMessage: chat['lastMessage'],
                        time: chat['time'],
                        unreadCount: chat['unreadCount'],
                        onTap: () =>
                            _openChat(chat['chatId'], chat['userName']),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadDummyChats() async {
    // Simuliere Netzwerk-Verzögerung
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      {
        'chatId': 'chat_1',
        'userName': 'Lina',
        'lastMessage': 'Hallo! Ist das Snowboard noch verfügbar?',
        'time': '14:30',
        'unreadCount': 1,
      },
      {
        'chatId': 'chat_2',
        'userName': 'Max',
        'lastMessage': 'Danke für das Angebot!',
        'time': 'Gestern',
        'unreadCount': 0,
      },
      {
        'chatId': 'chat_3',
        'userName': 'Anna',
        'lastMessage': 'Können wir uns morgen treffen?',
        'time': '2 Tage',
        'unreadCount': 2,
      },
    ];
  }
}
