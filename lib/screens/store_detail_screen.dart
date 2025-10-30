import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/database_service.dart';
import '../services/monetization_service.dart';
import '../models/listing.dart';

class StoreDetailScreen extends StatefulWidget {
  final String storeId;
  final String? bannerId;

  const StoreDetailScreen({
    super.key,
    required this.storeId,
    this.bannerId,
  });

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  Map<String, dynamic>? _store;
  List<Listing> _listings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStoreDetails();
  }

  Future<void> _loadStoreDetails() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load store details
      final store = await MonetizationService.getStoreById(widget.storeId);
      if (store != null) {
        setState(() {
          _store = store;
        });
      }

      // Load store listings
      final listings = await DatabaseService.getStoreListings(widget.storeId);
      setState(() {
        _listings = listings;
      });
    } catch (e) {
      debugPrint('❌ Error loading store details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Store Details'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_store == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Store nicht gefunden'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Store konnte nicht geladen werden.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_store!['name']),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (widget.bannerId != null)
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () => _showBannerInfo(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_store!['logoUrl'] != null)
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(_store!['logoUrl']!),
                      )
                    else
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.store,
                            color: Colors.white, size: 32),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _store!['name'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _store!['location'],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          if (_store!['isPremium'])
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Premium Store',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Store Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Über diesen Store',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _store!['description'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: (_store!['categories'] as List<dynamic>?)
                              ?.map((category) {
                            return Chip(
                              label: Text(category),
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.1),
                            );
                          }).toList() ??
                          [],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Store Listings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Produkte',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_listings.isEmpty)
                      const Center(
                        child: Text(
                          'Noch keine Produkte verfügbar',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _listings.length,
                        itemBuilder: (context, index) {
                          final listing = _listings[index];
                          return ListTile(
                            leading: listing.images.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      listing.images.first,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.image),
                                        );
                                      },
                                    ),
                                  )
                                : Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image),
                                  ),
                            title: Text(listing.title),
                            subtitle: Text(listing.price != 0.0
                                ? 'CHF ${listing.price}'
                                : 'Preis auf Anfrage'),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/listing-detail',
                                arguments: listing.id,
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBannerInfo() {
    if (widget.bannerId != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Banner-Information'),
            content: const Text(
              'Dieser Store hat ein aktives Banner in deiner Nähe geschaltet.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Verstanden'),
              ),
            ],
          );
        },
      );
    }
  }
}
