import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/swipe_card.dart';
import '../constants/colors.dart';
import '../constants/texts.dart';
import '../services/chat_service.dart';
import '../providers/like_provider.dart';
import '../models/user_model.dart';
import '../models/listing.dart';
import 'chat_detail_screen.dart';
// import '../services/auth_service.dart';
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

  // Dummy-Userdaten für die Anzeige
  final List<UserModel> allUsers = [
    UserModel(id: 'u1', name: 'Lina', avatarUrl: null),
    UserModel(id: 'u2', name: 'Max', avatarUrl: null),
    UserModel(id: 'u3', name: 'Anna', avatarUrl: null),
    UserModel(id: 'u4', name: 'Ben', avatarUrl: null),
    UserModel(id: 'u5', name: 'Sophie', avatarUrl: null),
    UserModel(id: 'u6', name: 'Jonas', avatarUrl: null),
  ];

  // Dummy-Listings für die Anzeige (synchronisiert mit HomeScreen)
  final List<Listing> allListings = [
    Listing(
      id: '1',
      title: 'Turntable',
      description: 'Ein hochwertiger Turntable für den Tausch',
      type: ListingType.swap,
      category: 'electronics',
      price: null,
      value: 150.0,
      desiredItem: 'Rennrad oder ähnlicher Wert',
      ownerId: 'user_001',
      ownerName: 'Ramon',
      images: const [],
      tags: ['turntable', 'vinyl', 'music'],
      offerTags: ['turntable', 'vinyl'],
      wantTags: ['rennrad', 'bike'],
      latitude: null,
      longitude: null,
      locationName: 'Zürich',
      radiusKm: 25,
      isActive: true,
      visibility: ListingVisibility.public,
      language: 'de',
      groupId: null,
      storeId: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isAnonymous: true, // Anonymer Post als Beispiel
      condition: 'used',
    ),
    Listing(
      id: '2',
      title: 'Bluetooth Speaker',
      description: 'Portabler Bluetooth-Lautsprecher',
      type: ListingType.swap,
      category: 'electronics',
      price: null,
      value: 80.0,
      desiredItem: 'Kopfhörer oder ähnlicher Wert',
      ownerId: 'user_002',
      ownerName: 'Lina',
      images: const [],
      tags: ['bluetooth', 'speaker', 'audio'],
      offerTags: ['bluetooth', 'speaker'],
      wantTags: ['kopfhörer', 'headphones'],
      latitude: null,
      longitude: null,
      locationName: 'Zürich',
      radiusKm: 25,
      isActive: true,
      visibility: ListingVisibility.public,
      language: 'de',
      groupId: null,
      storeId: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isAnonymous: false,
      condition: 'used',
    ),
    Listing(
      id: '3',
      title: 'Snowboard',
      description: 'Snowboard für Anfänger, kostenlos abzugeben',
      type: ListingType.giveaway,
      category: 'sports',
      price: null,
      value: 120.0,
      desiredItem: null,
      ownerId: 'user_003',
      ownerName: 'Anna',
      images: const [],
      tags: ['snowboard', 'winter', 'sport'],
      offerTags: ['snowboard'],
      wantTags: [],
      latitude: null,
      longitude: null,
      locationName: 'Zürich',
      radiusKm: 25,
      isActive: true,
      visibility: ListingVisibility.public,
      language: 'de',
      groupId: null,
      storeId: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isAnonymous: false,
      condition: 'used',
    ),
    Listing(
      id: '4',
      title: 'Old Books',
      description: 'Sammlung alter Bücher, kostenlos abzugeben',
      type: ListingType.giveaway,
      category: 'books',
      price: null,
      value: 50.0,
      desiredItem: null,
      ownerId: 'user_004',
      ownerName: 'Ben',
      images: const [],
      tags: ['books', 'reading', 'classics'],
      offerTags: ['books', 'classics'],
      wantTags: [],
      latitude: null,
      longitude: null,
      locationName: 'Zürich',
      radiusKm: 25,
      isActive: true,
      visibility: ListingVisibility.public,
      language: 'de',
      groupId: null,
      storeId: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isAnonymous: false,
      condition: 'used',
    ),
    Listing(
      id: '5',
      title: 'Gaming chair',
      description: 'Gaming-Stuhl in gutem Zustand',
      type: ListingType.sell,
      category: 'furniture',
      price: 75.0,
      value: 150.0,
      desiredItem: null,
      ownerId: 'user_005',
      ownerName: 'Sophie',
      images: const [],
      tags: ['gaming', 'chair', 'furniture'],
      offerTags: ['gaming', 'chair'],
      wantTags: [],
      latitude: null,
      longitude: null,
      locationName: 'Zürich',
      radiusKm: 25,
      isActive: true,
      visibility: ListingVisibility.public,
      language: 'de',
      groupId: null,
      storeId: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isAnonymous: false,
      condition: 'used',
    ),
    Listing(
      id: '6',
      title: 'Coffee machine',
      description: 'Kaffeemaschine, funktioniert einwandfrei',
      type: ListingType.sell,
      category: 'household',
      price: 25.0,
      value: 80.0,
      desiredItem: null,
      ownerId: 'user_006',
      ownerName: 'Jonas',
      images: const [],
      tags: ['coffee', 'machine', 'kitchen'],
      offerTags: ['coffee', 'machine'],
      wantTags: [],
      latitude: null,
      longitude: null,
      locationName: 'Zürich',
      radiusKm: 25,
      isActive: true,
      visibility: ListingVisibility.public,
      language: 'de',
      groupId: null,
      storeId: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isAnonymous: false,
      condition: 'used',
    ),
    Listing(
      id: '7',
      title: 'Mountainbike',
      description: 'Mountainbike für den Tausch gegen Rennrad',
      type: ListingType.swap,
      category: 'sports',
      price: null,
      value: 800.0,
      desiredItem: 'Rennrad oder ähnlicher Wert',
      ownerId: 'user_007',
      ownerName: 'Jonas',
      images: const [],
      tags: ['mountainbike', 'bike', 'sport'],
      offerTags: ['mountainbike', 'bike'],
      wantTags: ['rennrad', 'roadbike'],
      latitude: null,
      longitude: null,
      locationName: 'Zürich',
      radiusKm: 25,
      isActive: true,
      visibility: ListingVisibility.public,
      language: 'de',
      groupId: null,
      storeId: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isAnonymous: false,
      condition: 'used',
    ),
    Listing(
      id: '8',
      title: 'E-Gitarre',
      description: 'E-Gitarre für den Tausch gegen Keyboard',
      type: ListingType.swap,
      category: 'music',
      price: null,
      value: 100.0,
      desiredItem: 'Keyboard oder ähnlicher Wert',
      ownerId: 'user_008',
      ownerName: 'Mia',
      images: const [],
      tags: ['guitar', 'music', 'instrument'],
      offerTags: ['guitar', 'music'],
      wantTags: ['keyboard', 'piano'],
      latitude: null,
      longitude: null,
      locationName: 'Zürich',
      radiusKm: 25,
      isActive: true,
      visibility: ListingVisibility.public,
      language: 'de',
      groupId: null,
      storeId: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isAnonymous: false,
      condition: 'used',
    ),
  ];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();

    // Simuliere einige Likes für Test-Zwecke
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final likeProvider = Provider.of<LikeProvider>(context, listen: false);
      likeProvider.simulateLikeMe('u2');
      likeProvider.simulateLikeMe('u3');
      likeProvider.likeItem('1', 'u1'); // Artikel 1 von User u1
      likeProvider.likeItem('4', 'u4'); // Artikel 4 von User u4
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    // Simuliere Ladezeit
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      isLoading = false;
    });
  }

  void _openChat(String otherUserId, String userName) async {
    const myUserId = 'dummy_user_123';
    final chatId = await _chatService.createOrGetChat(
      myUserId,
      otherUserId,
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

  // Getter für die korrekt getrennten Listen
  List<UserModel> get matchesUsers {
    final likeProvider = Provider.of<LikeProvider>(context, listen: false);
    final matches = likeProvider.getMatches();
    return allUsers.where((user) => matches.contains(user.id)).toList();
  }

  List<UserModel> get likesUsers {
    final likeProvider = Provider.of<LikeProvider>(context, listen: false);
    final likes = likeProvider.getLikes();
    return allUsers.where((user) => likes.contains(user.id)).toList();
  }

  List<UserModel> get likedUsers {
    final likeProvider = Provider.of<LikeProvider>(context, listen: false);
    final liked = likeProvider.getLiked();
    return allUsers.where((user) => liked.contains(user.id)).toList();
  }

  // Getter für die entsprechenden Listings
  List<Listing> get matchesListings {
    final matches = matchesUsers.map((u) => u.id).toList();
    return allListings
        .where((listing) => matches.contains(listing.ownerId))
        .toList();
  }

  List<Listing> get likesListings {
    final likes = likesUsers.map((u) => u.id).toList();
    return allListings
        .where((listing) => likes.contains(listing.ownerId))
        .toList();
  }

  List<Listing> get likedListings {
    final likeProvider = Provider.of<LikeProvider>(context, listen: false);
    final likedArticleIds = likeProvider.getAllLikedArticleIds();
    return allListings
        .where((listing) => likedArticleIds.contains(listing.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LikeProvider>(
      builder: (context, likeProvider, child) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.backgroundGradientStart,
                  AppColors.backgroundGradientEnd,
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
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: AppColors.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            AppTexts.matchesTitle,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.refresh,
                                color: AppColors.primary),
                            onPressed: _loadData,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Tab Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade800
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade600,
                          tabs: const [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.favorite, size: 16),
                                  SizedBox(width: 4),
                                  Text('Matches'),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.favorite_border, size: 16),
                                  SizedBox(width: 4),
                                  Text('Likes'),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.favorite_border, size: 16),
                                  SizedBox(width: 4),
                                  Text('Meine Likes'),
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
                            // Matches Tab - Gegenseitig geliked
                            _buildListingsList(
                              matchesListings,
                              AppTexts.noMatches,
                            ),
                            // Likes Tab - Andere haben mich geliked
                            _buildListingsList(likesListings, AppTexts.noLikes),
                            // My Liked Tab - Ich habe andere geliked
                            _buildListingsList(
                              likedListings,
                              AppTexts.noMyLikes,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListingsList(List<Listing> listings, String emptyMessage) {
    if (listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
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
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        return SwipeCard(
          item: listing,
          showChatButton: true,
          onChat: () => _openChat(listing.ownerId, listing.ownerName),
        );
      },
    );
  }
}
