import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/like_provider.dart';
import '../services/swipe_service.dart';
import '../services/auth_service.dart';
import '../models/listing.dart';
import '../widgets/swipe_card.dart';
import '../widgets/banner_carousel.dart';

import '../widgets/category_selector.dart';
import '../widgets/filter_sheet.dart';
import '../l10n/app_localizations.dart';
import 'listing_detail_screen.dart';
import 'create_listing_screen.dart';
import 'search_results_screen.dart';
import '../providers/language_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Listing> _listings = [];
  bool _isLoading = true;
  String _selectedCategory = 'Alle';
  double? _userLatitude;
  double? _userLongitude;
  double _radius = 25.0; // km

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Prüfe ob User eingeloggt ist
      final currentUser = AuthService.getCurrentUser();
      if (currentUser == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showErrorSnackBar(
              AppLocalizations.of(context)!.pleaseLoginToSeeListings);
        }
        return;
      }

      final listings = await SwipeService.getSwipeFeed(
        userId: currentUser.id,
        radiusKm: _radius.toInt(),
        category: _selectedCategory == 'Alle' ? null : _selectedCategory,
        language: Localizations.localeOf(context).languageCode,
      );

      if (mounted) {
        setState(() {
          _listings = listings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Fehler beim Laden der Artikel: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _onSwipeRight(Listing listing) async {
    try {
      final currentUser = AuthService.getCurrentUser();
      if (currentUser == null) {
        if (mounted) {
          _showErrorSnackBar(AppLocalizations.of(context)!.pleaseLoginToLike);
        }
        return;
      }

      await SwipeService.likeListing(listing.id, currentUser.id);

      // Update local state
      if (mounted) {
        context.read<LikeProvider>().addLike(listing.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.itemLiked(listing.title)),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );

        // Remove swiped listing and check for deck replenishment
        _removeListingAndReplenish(listing);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('${AppLocalizations.of(context)!.likeError}: $e');
      }
    }
  }

  Future<void> _onSwipeLeft(Listing listing) async {
    try {
      final currentUser = AuthService.getCurrentUser();
      if (currentUser == null) return;

      // Unlike listing
      await SwipeService.unlikeListing(currentUser.id, listing.id);

      // Update local state
      if (mounted) {
        context.read<LikeProvider>().removeLike(listing.id);

        setState(() {
          _listings.removeWhere((l) => l.id == listing.id);
        });
      }
    } catch (e) {
      debugPrint('Error unliking listing: $e');
    }
  }

  void _removeListingAndReplenish(Listing listing) {
    setState(() {
      _listings.remove(listing);
    });

    // Check if we need to load more listings
    if (_listings.length < 5) {
      _loadMoreListings();
    }
  }

  Future<void> _loadMoreListings() async {
    try {
      final currentUser = AuthService.getCurrentUser();
      if (currentUser == null) return;

      final moreListings = await SwipeService.getSwipeFeed(
        userId: currentUser.id,
        radiusKm: _radius.toInt(),
        category: _selectedCategory == 'Alle' ? null : _selectedCategory,
        language: Provider.of<LanguageProvider>(context, listen: false)
            .currentLocale
            .languageCode,
        offset: _listings.length,
      );

      if (mounted && moreListings.isNotEmpty) {
        setState(() {
          _listings.addAll(moreListings);
        });
      }
    } catch (e) {
      debugPrint('Error loading more listings: $e');
    }
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadListings();
  }

  void _onFilterApplied(Map<String, dynamic> filters) {
    setState(() {
      _radius = filters['radius'] ?? 25.0;
      _userLatitude = filters['latitude'];
      _userLongitude = filters['longitude'];
    });
    _loadListings();
  }

  void _onCreateListingPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateListingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.home),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.location_on),
          onPressed: _showRadiusDialog,
          tooltip: AppLocalizations.of(context)!.radiusIcon,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: AppLocalizations.of(context)!.searchIcon,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => FilterSheet(
                  onFilterApplied: _onFilterApplied,
                ),
              );
            },
            tooltip: AppLocalizations.of(context)!.filterButton,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _onCreateListingPressed,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Selector
          CategorySelector(
            selectedCategory: _selectedCategory,
            onCategoryChanged: _onCategoryChanged,
          ),

          // Banner Carousel
          const BannerCarousel(),

          // Filter Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!
                        .articlesNearby(_radius.toInt()),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),

          // Listings
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _listings.isEmpty
                    ? _buildEmptyState()
                    : _buildListingsList(),
          ),
        ],
      ),
    );
  }

  void _showRadiusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.radiusSettings),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.currentRadius(_radius.toInt())),
            const SizedBox(height: 16),
            Slider(
              value: _radius,
              min: 1.0,
              max: 100.0,
              divisions: 19,
              label: '${_radius.toInt()} km',
              onChanged: (value) {
                setState(() {
                  _radius = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [5, 10, 20, 50, 100].map((km) {
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _radius = km.toDouble();
                    });
                    Navigator.pop(context);
                    _loadListings();
                  },
                  child: Text('$km km'),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadListings();
            },
            child: Text(AppLocalizations.of(context)!.apply),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    final TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.searchDialog),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: searchController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.searchTerm,
                hintText: AppLocalizations.of(context)!.searchHintText,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (query) {
                Navigator.pop(context);
                _performSearch(query);
              },
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.searchInRadius(_radius.toInt())),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final query = searchController.text.trim();
              Navigator.pop(context);
              _performSearch(query);
            },
            child: Text(AppLocalizations.of(context)!.searchButton),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(
          query: query,
          radius: _radius,
          latitude: _userLatitude,
          longitude: _userLongitude,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noArticlesFound,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.tryOtherFilters,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _onCreateListingPressed,
            child: Text(AppLocalizations.of(context)!.firstListing),
          ),
        ],
      ),
    );
  }

  Widget _buildListingsList() {
    if (_listings.isEmpty) {
      return _buildEmptyState();
    }

    return Stack(
      children: _listings.asMap().entries.map((entry) {
        final index = entry.key;
        final listing = entry.value;

        // Nur die obersten 3 Karten anzeigen für Performance
        if (index >= _listings.length - 3) {
          return Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SwipeCard(
                item: listing,
                onSwipeRight: () => _onSwipeRight(listing),
                onSwipeLeft: () => _onSwipeLeft(listing),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ListingDetailScreen(listingId: listing.id),
                    ),
                  );
                },
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }
}
