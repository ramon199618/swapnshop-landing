import 'package:flutter/material.dart';
import '../widgets/swipe_card.dart';
import '../constants/colors.dart';
import '../constants/texts.dart';
import '../services/chat_service.dart';
import 'chat_detail_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ChatService _chatService = ChatService();

  List<Map<String, dynamic>> matches = [];
  List<Map<String, dynamic>> likedItems = [];
  bool isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _currentUserId = 'dummy_user_123';
    _loadMatches();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMatches() async {
    if (_currentUserId == null) return;
    setState(() {
      isLoading = true;
    });
    // TODO: Echte Matches aus Firestore laden
    // final query = await FirebaseFirestore.instance
    //     .collection('matches')
    //     .where('participants', arrayContains: _currentUserId)
    //     .where('isActive', isEqualTo: true)
    //     .get();
    // final List<Map<String, dynamic>> loadedMatches = [];
    // for (final doc in query.docs) {
    //   final data = doc.data();
    //   // Logik: Nur anzeigen, wenn beide sich gegenseitig geliked haben
    //   if ((data['userA'] == _currentUserId &&
    //           data['userALiked'] == true &&
    //           data['userBLiked'] == true) ||
    //       (data['userB'] == _currentUserId &&
    //           data['userALiked'] == true &&
    //           data['userBLiked'] == true)) {
    //     loadedMatches.add({...data, 'id': doc.id});
    //   }
    // }

    // Dummy-Daten für Entwicklung
    await Future.delayed(const Duration(milliseconds: 500));
    final List<Map<String, dynamic>> loadedMatches = [];

    setState(() {
      matches = loadedMatches;
      isLoading = false;
    });
  }

  void _openChat(String otherUserId, String userName) async {
    // final myUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final myUserId = 'dummy_user_123';
    final chatId = await _chatService.createOrGetChat(
      userA: myUserId,
      userB: otherUserId,
    );
    if (!mounted) return;
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromRGBO(255, 255, 255, 0.1), Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite, color: AppColors.primary, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        AppTexts.matchesTitle,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.refresh, color: AppColors.primary),
                        onPressed: _loadMatches,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey.shade600,
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.favorite, size: 16),
                              const SizedBox(width: 4),
                              Text(AppTexts.matchesTab),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.favorite_border, size: 16),
                              const SizedBox(width: 4),
                              Text(AppTexts.likedTab),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        // Matches Tab
                        _buildMatchesList(matches, AppTexts.noMatches),
                        // Liked Tab
                        _buildMatchesList(likedItems, AppTexts.noLikes),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchesList(
    List<Map<String, dynamic>> items,
    String emptyMessage,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return SwipeCard(
          userName: item['userName'] ?? '',
          itemTitle: item['itemTitle'] ?? '',
          matchType: item['matchType'] ?? '',
          onChat: () => _openChat(item['userId'] ?? '', item['userName'] ?? ''),
          isSwipeable: false,
        );
      },
    );
  }
}
