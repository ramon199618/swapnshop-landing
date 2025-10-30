import 'package:flutter/material.dart';
import '../widgets/chat_tile.dart';
import '../widgets/gradient_background.dart';
import '../constants/colors.dart';
import '../constants/texts.dart';
import '../navigation/app_router.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void _openChat(String chatId, String userName) {
    AppRouter.pushNamed(
      context,
      AppRouter.chatDetail,
      arguments: {
        'chatId': chatId,
        'otherUserName': userName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
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
                Icon(Icons.chat_bubble, color: AppColors.primary, size: 28),
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
                      onTap: () => _openChat(chat['chatId'], chat['userName']),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
        'lastMessage': 'Hey, ist das Bike noch verfügbar?',
        'time': '14:30',
        'unreadCount': 2,
      },
      {
        'chatId': 'chat_2',
        'userName': 'Max',
        'lastMessage': 'Danke für den Tausch!',
        'time': '12:15',
        'unreadCount': 0,
      },
      {
        'chatId': 'chat_3',
        'userName': 'Anna',
        'lastMessage': 'Wann können wir uns treffen?',
        'time': '10:45',
        'unreadCount': 1,
      },
      {
        'chatId': 'chat_4',
        'userName': 'Tom',
        'lastMessage': 'Perfekt, das passt mir!',
        'time': 'Gestern',
        'unreadCount': 0,
      },
    ];
  }
}
