import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/monetization_service.dart';
import 'create_store_screen.dart';

class MyStoreScreen extends StatefulWidget {
  const MyStoreScreen({super.key});

  @override
  State<MyStoreScreen> createState() => _MyStoreScreenState();
}

class _MyStoreScreenState extends State<MyStoreScreen> {
  Map<String, dynamic>? _store;
  final List<Map<String, dynamic>> _banners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload store when screen becomes active
    _loadStore();
  }

  Future<void> _loadStore() async {
    try {
      final user = AuthService.getCurrentUser();
      if (user != null) {
        final store = await MonetizationService.getUserStore(user.id);
        if (store != null) {
          setState(() {
            _store = store;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading store: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_store == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mein Store'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.store,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Du hast noch keinen Store',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Erstelle deinen eigenen Store und verkaufe unbegrenzt!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateStoreScreen(),
                    ),
                  );

                  // Wenn ein Store erstellt wurde, sofort anzeigen
                  if (result != null) {
                    setState(() {
                      _store = result;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Store erstellen'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_store!['name']),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, '/edit-store', arguments: _store);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (_store!['logoUrl'] != null)
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(_store!['logoUrl']!),
                          )
                        else
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.store, color: Colors.white),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _store!['name'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _store!['location'],
                                style: const TextStyle(color: Colors.grey),
                              ),
                              if (_store!['isPremium'])
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
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
                    const SizedBox(height: 16),
                    Text(
                      _store!['description'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: (_store!['categories'] as List<dynamic>?)
                              ?.map((category) => Chip(
                                    label: Text(category),
                                    backgroundColor: AppColors.primary
                                        .withValues(alpha: 0.1),
                                  ))
                              .toList() ??
                          [],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Store Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Store-Aktionen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.add_shopping_cart,
                          color: AppColors.primary),
                      title: const Text('Produkt hinzufügen'),
                      subtitle: const Text('Neues Verkaufsinserat erstellen'),
                      onTap: () {
                        Navigator.pushNamed(context, '/create-listing');
                      },
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.analytics, color: AppColors.primary),
                      title: const Text('Statistiken'),
                      subtitle: const Text('Store-Performance anzeigen'),
                      onTap: () {
                        Navigator.pushNamed(context, '/store-analytics',
                            arguments: _store);
                      },
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.campaign, color: AppColors.primary),
                      title: const Text('Banner buchen'),
                      subtitle: const Text('Radius-Werbung schalten'),
                      onTap: () {
                        Navigator.pushNamed(context, '/create-banner',
                            arguments: _store);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Active Banners
            if (_banners.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aktive Banner',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._banners.map((banner) => ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                banner['imageUrl'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image),
                                  );
                                },
                              ),
                            ),
                            title: Text(banner['title']),
                            subtitle: Text(
                              '${banner['radiusKm']}km • ${banner['remainingTime'].inHours}h verbleibend',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _cancelBanner(banner['id']);
                              },
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _cancelBanner(String bannerId) async {
    final navigatorContext = context;
    if (!navigatorContext.mounted) return;

    try {
      final success = await DatabaseService.cancelBanner(bannerId);
      if (navigatorContext.mounted) {
        if (success) {
          ScaffoldMessenger.of(navigatorContext).showSnackBar(
            const SnackBar(content: Text('Banner storniert!')),
          );
          // Reload banners
          _loadBanners();
        } else {
          ScaffoldMessenger.of(navigatorContext).showSnackBar(
            const SnackBar(content: Text('Fehler beim Stornieren')),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error cancelling banner: $e');
      if (navigatorContext.mounted) {
        ScaffoldMessenger.of(navigatorContext).showSnackBar(
          const SnackBar(content: Text('Fehler beim Stornieren')),
        );
      }
    }
  }

  Future<void> _loadBanners() async {
    try {
      final user = AuthService.getCurrentUser();
      if (user != null) {
        final banners = await DatabaseService.getUserBanners(user.id);
        setState(() {
          _banners.clear();
          _banners.addAll(banners);
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading banners: $e');
    }
  }
}
