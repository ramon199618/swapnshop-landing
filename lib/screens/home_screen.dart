import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/like_provider.dart';
import '../services/swipe_service.dart';
import '../services/auth_service.dart';
import '../models/listing.dart';
import '../widgets/swipe_card.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/gradient_background.dart';
import '../widgets/category_selector.dart';
import '../widgets/filter_sheet.dart';
import '../l10n/app_localizations.dart';
import '../providers/language_provider.dart';
import '../navigation/app_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Listing> _listings = [];
  bool _isLoading = true;
  String _selectedCategory = 'Alle';
  String _searchQuery = '';
  double _radius = 25.0; // km

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    if (!mounted) return;

    // Race-Condition-Schutz: Prüfe ob bereits ein Load läuft
    if (_isLoading) return;

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
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
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
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
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
            backgroundColor: AppColors.likeAction,
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

        // Check if we need to load more listings
        if (_listings.length < 5) {
          _loadMoreListings();
        }
      }
    } catch (e) {
      debugPrint('Error unliking listing: $e');
      if (mounted) {
        _showErrorSnackBar('Fehler beim Entfernen des Artikels: $e');
      }
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
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
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
    if (category == _selectedCategory) return; // Verhindere unnötige Reloads

    setState(() {
      _selectedCategory = category;
    });
    _loadListings();
  }

  void _onFilterApplied(Map<String, dynamic> filters) {
    final newRadius = filters['radius'] ?? 25.0;
    final newSearchQuery = filters['keyword'] ?? '';

    // Verhindere unnötige Reloads wenn sich nichts geändert hat
    if (newRadius == _radius && newSearchQuery == _searchQuery) return;

    setState(() {
      _radius = newRadius;
      _searchQuery = newSearchQuery;
    });
    _loadListings();
  }

  void _onCreateListingPressed() {
    AppRouter.pushNamed(
      context,
      AppRouter.createListing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.home),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.location_on),
          onPressed: _showRadiusDialog,
          tooltip: AppLocalizations.of(context)!.radiusIcon,
        ),
        actions: [
          // Zeige aktuellen Suchbegriff an
          if (_searchQuery.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '"$_searchQuery"',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: _clearSearch,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                  initialKeyword: _searchQuery,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!
                            .articlesNearby(_radius.toInt()),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (_searchQuery.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Suche: "$_searchQuery"',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Listings
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
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
    final TextEditingController searchController =
        TextEditingController(text: _searchQuery);

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
                hintText: 'z.B. Bücher, iPhone, Fahrrad...',
                border: const OutlineInputBorder(),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                        },
                      )
                    : null,
              ),
              onSubmitted: (query) {
                Navigator.pop(context);
                _performSearch(query);
              },
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.searchInRadius(_radius.toInt())),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Aktuell: "$_searchQuery"',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearSearch();
              },
              child: const Text('Suche löschen'),
            ),
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

    // Setze Suchbegriff und lade neue Ergebnisse direkt im Swipe-Feed
    setState(() {
      _searchQuery = query.trim();
    });
    _loadListings();
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
    });
    _loadListings();
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
                  AppRouter.pushNamed(
                    context,
                    AppRouter.listingDetail,
                    arguments: {'listingId': listing.id},
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
