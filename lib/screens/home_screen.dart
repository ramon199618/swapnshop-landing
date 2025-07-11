import 'package:flutter/material.dart';
import '../widgets/category_selector.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/search_bar.dart' as custom_search;
import '../constants/texts.dart';
import '../constants/colors.dart';
import '../models/listing.dart';
import '../services/chat_service.dart';
import 'chat_detail_screen.dart' as chat_detail;
import '../widgets/swipe_card.dart';
import '../utils/radius_utils.dart';
import 'dart:math';
// import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int cardIndex = 0;
  String selectedCategory = 'Swap';
  String searchQuery = '';
  double radiusFilter = 10.0;
  bool showSearchBar = false;

  // Beispiel-Daten, später durch Firestore ersetzen
  final Map<String, List<Listing>> categoryItems = {
    'Swap': [
      Listing(
        id: '1',
        title: 'Turntable',
        subtitle: 'for exchange',
        userId: 'user_001',
        userName: 'Ramon',
        description: '',
        price: 0.0,
        category: 'Swap',
        images: const [],
        createdAt: DateTime.now(),
        location: '',
        condition: 'used',
      ),
      Listing(
        id: '2',
        title: 'Bluetooth Speaker',
        subtitle: 'Bluetooth',
        userId: 'user_002',
        userName: 'Lina',
        description: '',
        price: 0.0,
        category: 'Swap',
        images: const [],
        createdAt: DateTime.now(),
        location: '',
        condition: 'used',
      ),
    ],
    'Give away': [
      Listing(
        id: '3',
        title: 'Snowboard',
        subtitle: 'Give away',
        userId: 'user_003',
        userName: 'Ben',
        description: '',
        price: 0.0,
        category: 'Give away',
        images: const [],
        createdAt: DateTime.now(),
        location: '',
        condition: 'used',
      ),
      Listing(
        id: '4',
        title: 'Old Books',
        subtitle: 'free',
        userId: 'user_004',
        userName: 'Anna',
        description: '',
        price: 0.0,
        category: 'Give away',
        images: const [],
        createdAt: DateTime.now(),
        location: '',
        condition: 'used',
      ),
    ],
    'Sell': [
      Listing(
        id: '5',
        title: 'Gaming chair',
        subtitle: 'CHF 75',
        userId: 'user_005',
        userName: 'Max',
        description: '',
        price: 75.0,
        category: 'Sell',
        images: const [],
        createdAt: DateTime.now(),
        location: '',
        condition: 'used',
      ),
      Listing(
        id: '6',
        title: 'Coffee machine',
        subtitle: 'CHF 25',
        userId: 'user_006',
        userName: 'Nina',
        description: '',
        price: 25.0,
        category: 'Sell',
        images: const [],
        createdAt: DateTime.now(),
        location: '',
        condition: 'used',
      ),
    ],
  };
  List<Listing> items = [];
  final List<Listing> matchedItems = [];
  final List<Listing> likedItems = [];
  final ChatService _chatService = ChatService();

  // Dummy-Koordinaten für Zürich
  static final double userLat = 47.3769;
  static final double userLon = 8.5417;

  // Hilfsfunktion für zufällige Koordinaten im Umkreis von Zürich (max 30km)
  Map<String, double> randomNearbyCoords(Random rng) {
    // Radius in km
    final r = rng.nextDouble() * 30;
    final angle = rng.nextDouble() * 2 * pi;
    // 1° Breitengrad ≈ 111km, 1° Längengrad ≈ 85km in Zürich
    final lat = userLat + (r * cos(angle)) / 111.0;
    final lon = userLon + (r * sin(angle)) / 85.0;
    return {'lat': lat, 'lon': lon};
  }

  final Map<String, Map<String, double>> itemCoords = {};
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    try {
      items = categoryItems[selectedCategory] ?? [];
      // Dummy-Koordinaten für alle Items generieren
      for (final item in categoryItems.values.expand((e) => e)) {
        itemCoords[item.id] = randomNearbyCoords(_rng);
      }
    } catch (e, stack) {
      debugPrint('💥 Crash in initState: $e');
      debugPrint('💥 Stack: $stack');
      items = [];
    }
  }

  void onCategoryTap(String category) {
    setState(() {
      selectedCategory = category;
      cardIndex = 0;
      items = categoryItems[category]!;
    });
  }

  void swipeLeft() {
    setState(() {
      if (cardIndex < items.length - 1) cardIndex++;
    });
  }

  void swipeRight() {
    setState(() {
      likedItems.add(items[cardIndex]);
      matchedItems.add(items[cardIndex]);
      if (cardIndex < items.length - 1) cardIndex++;
    });
  }

  void showSearchDialog(BuildContext context) {
    String searchQuery = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AppTexts.searchTitle),
          content: TextField(
            decoration: const InputDecoration(hintText: AppTexts.searchHint),
            onChanged: (value) => searchQuery = value,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                debugPrint('Suche gestartet nach: $searchQuery');
              },
              child: const Text(AppTexts.searchButton),
            ),
          ],
        );
      },
    );
  }

  void toggleSearchBar() {
    setState(() {
      showSearchBar = !showSearchBar;
      if (!showSearchBar) {
        searchQuery = '';
      }
    });
  }

  void onSearch(String query) {
    setState(() {
      searchQuery = query;
      // Hinweis: Firebase-Suche kann hier ergänzt werden
      debugPrint('🔍 Suche nach: $query');
    });
  }

  void onRadiusChanged(double radius) {
    setState(() {
      radiusFilter = radius;
      cardIndex = 0;
      debugPrint('📍 Radius geändert auf: ${radius.round()} km');
    });
  }

  Future<void> startChatWithUser(
    String otherUserId,
    String otherUserName,
  ) async {
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
        builder: (context) => chat_detail.ChatDetailScreen(
          chatId: chatId,
          otherUserName: otherUserName,
        ),
      ),
    );
  }

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return const FilterSheet();
      },
    );
  }

  List<Listing> get filteredItems {
    return items.where((item) {
      final coords = itemCoords[item.id];
      if (coords == null) return true;
      final dist = RadiusUtils.calculateDistance(
        userLat,
        userLon,
        coords['lat']!,
        coords['lon']!,
      );
      return dist <= radiusFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredItems;
    final showNoItems = filtered.isEmpty;
    final item = showNoItems
        ? Listing(
            id: '0',
            title: 'Keine Artikel gefunden',
            subtitle: '',
            userId: '',
            userName: '',
            description: '',
            price: 0.0,
            category: '',
            images: const [],
            createdAt: DateTime.now(),
            location: '',
            condition: 'used',
          )
        : filtered[cardIndex % filtered.length];
    final coords = itemCoords[item.id];
    final dist = coords != null
        ? RadiusUtils.calculateDistance(
            userLat,
            userLon,
            coords['lat']!,
            coords['lon']!,
          )
        : 0.0;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.1),
              Colors.white,
              Colors.orange.shade50,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header mit Filter, Radius und Search
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Radius Filter Button
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: PopupMenuButton<double>(
                      onSelected: onRadiusChanged,
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 5.0, child: Text('5 km')),
                        const PopupMenuItem(value: 10.0, child: Text('10 km')),
                        const PopupMenuItem(value: 25.0, child: Text('25 km')),
                        const PopupMenuItem(value: 50.0, child: Text('50 km')),
                      ],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              '${radiusFilter.round()} km',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Filter Button
                  IconButton(
                    icon: Icon(Icons.filter_alt, color: AppColors.primary),
                    onPressed: () => _openFilterSheet(context),
                  ),
                  Expanded(
                    child: Text(
                      AppTexts.appTitle,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Search Button
                  IconButton(
                    icon: Icon(
                      showSearchBar ? Icons.close : Icons.search,
                      color: AppColors.primary,
                    ),
                    onPressed: toggleSearchBar,
                  ),
                ],
              ),
            ),
            // Suchleiste
            if (showSearchBar)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: custom_search.SearchBar(
                  onSearch: onSearch,
                  hintText: 'Artikel suchen...',
                  suggestions: const [
                    'Snowboard',
                    'Bücher',
                    'Elektronik',
                    'Kleidung',
                  ],
                ),
              ),
            // Kategorie-Tabs
            Container(
              color: Colors.white,
              child: CategorySelector(
                categories: categoryItems.keys.toList(),
                selectedCategory: selectedCategory,
                onCategoryTap: onCategoryTap,
              ),
            ),
            // Hauptinhalt: SwipeCard oder Dummy
            Expanded(
              child: Center(
                child: SwipeCard(
                  item: item,
                  onSwipeLeft: showNoItems ? null : swipeLeft,
                  onSwipeRight: showNoItems ? null : swipeRight,
                  onChat: showNoItems
                      ? null
                      : () => startChatWithUser(item.userId, item.userName),
                  extraInfo: showNoItems
                      ? null
                      : '${dist.toStringAsFixed(1)} km entfernt',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
