import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/database_service.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../constants/colors.dart';

class ListingDetailScreen extends StatefulWidget {
  final String listingId;

  const ListingDetailScreen({
    super.key,
    required this.listingId,
  });

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  Map<String, dynamic>? _listing;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadListingDetails();
  }

  Future<void> _loadListingDetails() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final listing = await DatabaseService.getListingById(widget.listingId);
      setState(() {
        _listing = listing;
      });
    } catch (e) {
      debugPrint('❌ Error loading listing details: $e');
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
          title: const Text('Produkt Details'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_listing == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Produkt nicht gefunden'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Produkt konnte nicht geladen werden.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_listing!['title'] ?? 'Produkt Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareListing(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Images
            if (_listing!['images'] != null &&
                (_listing!['images'] as List).isNotEmpty)
              SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: (_listing!['images'] as List).length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _listing!['images'][index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(child: Icon(Icons.image)),
                          );
                        },
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.image, size: 64, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 16),

            // Product Title
            Text(
              _listing!['title'] ?? 'Kein Titel',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Price
            if (_listing!['price'] != null && _listing!['price'] > 0)
              Text(
                'CHF ${_listing!['price']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            const SizedBox(height: 16),

            // Description
            if (_listing!['description'] != null &&
                _listing!['description'].isNotEmpty) ...[
              const Text(
                'Beschreibung',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _listing!['description'],
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
            ],

            // Category
            if (_listing!['category'] != null) ...[
              const Text(
                'Kategorie',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(_listing!['category']),
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 16),
            ],

            // Condition
            if (_listing!['condition'] != null) ...[
              const Text(
                'Zustand',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _listing!['condition'],
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
            ],

            // Contact Seller Button
            ElevatedButton(
              onPressed: () => _contactSeller(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Verkäufer kontaktieren',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareListing() {
    final title = _listing!['title'] ?? 'Produkt';
    final price = _listing!['price'] != null ? 'CHF ${_listing!['price']}' : '';
    final description = _listing!['description'] ?? '';

    // Share functionality implementation
    final shareText = '$title $price\n\n$description\n\nGefunden auf Swap&Shop';

    _copyToClipboard(shareText);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title $price wird geteilt...'),
        action: SnackBarAction(
          label: 'Kopiert!',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Link kopiert!')),
            );
          },
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('In Zwischenablage kopiert!')),
    );
  }

  Future<void> _contactSeller() async {
    final navigatorContext = context;
    if (!navigatorContext.mounted) return;

    final sellerId = _listing!['user_id'];
    final sellerName = _listing!['user_name'] ?? 'Verkäufer';

    try {
      final currentUser = AuthService.getCurrentUser();
      if (currentUser != null) {
        final chatService = ChatService();
        final chatId = await chatService.createOrGetChat(
          currentUser.id,
          sellerId,
        );

        if (navigatorContext.mounted) {
          Navigator.pushNamed(
            navigatorContext,
            '/chat-detail',
            arguments: {
              'chatId': chatId,
              'otherUserName': sellerName,
            },
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error contacting seller: $e');
      if (navigatorContext.mounted) {
        ScaffoldMessenger.of(navigatorContext).showSnackBar(
          const SnackBar(content: Text('Fehler beim Öffnen des Chats')),
        );
      }
    }
  }
}
