import 'dart:async';
import 'package:flutter/material.dart';
import '../models/banner_model.dart';
import '../services/monetization_service.dart';
import '../services/location_service.dart';
import '../constants/colors.dart';
import '../services/auth_service.dart'; // Added for AuthService

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  List<BannerModel> _banners = [];
  bool _isLoading = true;
  final PageController _pageController = PageController();
  Timer? _autoRotationTimer;
  int _currentIndex = 0;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  @override
  void dispose() {
    _autoRotationTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadBanners() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Versuche echte Banner zu laden (optional)
      try {
        final location = await LocationService.getCurrentPosition();
        if (location != null) {
          final bannerMaps = await MonetizationService.getActiveBanners(
            latitude: location.latitude,
            longitude: location.longitude,
            radius: 50, // Show banners within 50km
          );

          if (bannerMaps.isNotEmpty) {
            // Konvertiere Map<String, dynamic> zu BannerModel
            final realBanners = bannerMaps.map((bannerMap) {
              return BannerModel(
                id: bannerMap['id'] ?? '',
                storeId: bannerMap['store_id'] ?? bannerMap['userId'] ?? '',
                title: bannerMap['title'] ?? '',
                description: bannerMap['description'] ?? '',
                imageUrl: bannerMap['image_url'] ?? bannerMap['imageUrl'] ?? '',
                location: bannerMap['location'] ?? '',
                latitude:
                    bannerMap['center_lat'] ?? bannerMap['latitude'] ?? 0.0,
                longitude:
                    bannerMap['center_lon'] ?? bannerMap['longitude'] ?? 0.0,
                radiusKm: bannerMap['radius_km'] ?? bannerMap['radiusKm'] ?? 25,
                startDate: bannerMap['start_at'] ??
                    bannerMap['startDate'] ??
                    DateTime.now(),
                endDate: bannerMap['end_at'] ??
                    bannerMap['endDate'] ??
                    DateTime.now().add(const Duration(days: 30)),
                price: bannerMap['price_chf'] ?? bannerMap['price'] ?? 0.0,
                status: bannerMap['status'] ?? bannerMap['status'] ?? 'active',
                createdAt: bannerMap['created_at'] ??
                    bannerMap['createdAt'] ??
                    DateTime.now(),
                userId: bannerMap['store_id'] ?? bannerMap['userId'] ?? '',
              );
            }).toList();

            setState(() {
              _banners = realBanners;
              _isLoading = false;
            });

            // Tracke Impression für das erste Banner
            if (realBanners.isNotEmpty) {
              _trackBannerImpression(
                  realBanners[0], location.latitude, location.longitude);
            }

            // Starte Auto-Rotation nur wenn Banner vorhanden
            if (realBanners.length > 1) {
              _startAutoRotation();
            }

            return; // Erfolgreich geladen, beende hier
          }
        }
      } catch (e) {
        debugPrint('❌ Error loading real banners: $e');
        // Fallback-Banner werden geladen
      }

      // Fallback: Lade Demo-Banner wenn keine echten Banner verfügbar sind
      _loadFallbackBanners();
    } catch (e) {
      debugPrint('❌ Error loading banners: $e');
      // Lade Fallback-Banner bei Fehlern
      _loadFallbackBanners();
    }
  }

  void _loadFallbackBanners() {
    // Demo-Banner für Fallback
    final fallbackBanners = [
      BannerModel(
        id: 'demo_1',
        storeId: 'demo_store_1',
        title: 'Willkommen bei Swap&Shop',
        description:
            'Entdecke lokale Angebote und tausche mit deiner Community',
        imageUrl: 'assets/images/placeholder_banner.jpg',
        location: 'Zürich',
        latitude: 47.3769,
        longitude: 8.5417,
        radiusKm: 25,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        price: 0.0,
        status: 'active',
        createdAt: DateTime.now(),
        userId: 'demo_user_1',
      ),
      BannerModel(
        id: 'demo_2',
        storeId: 'demo_store_2',
        title: 'Premium Features freischalten',
        description: 'Erstelle Stores, Gruppen und nutze alle Funktionen',
        imageUrl: 'assets/images/placeholder_banner.jpg',
        location: 'Zürich',
        latitude: 47.3769,
        longitude: 8.5417,
        radiusKm: 25,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        price: 9.99,
        status: 'active',
        createdAt: DateTime.now(),
        userId: 'demo_user_2',
      ),
    ];

    setState(() {
      _banners = fallbackBanners;
      _isLoading = false;
    });

    // Starte Auto-Rotation für Demo-Banner
    _startAutoRotation();
  }

  /// Tracket Banner-Impression
  Future<void> _trackBannerImpression(
      BannerModel banner, double userLat, double userLon) async {
    try {
      final currentUser = AuthService.getCurrentUser();
      if (currentUser != null) {
        await MonetizationService.trackBannerImpression(
          banner.id,
          currentUser.id,
          userLat,
          userLon,
          _currentIndex,
        );
      }
    } catch (e) {
      debugPrint('Error tracking banner impression: $e');
    }
  }

  /// Tracket Banner-Click
  Future<void> _trackBannerClick(BannerModel banner) async {
    try {
      final location = await LocationService.getCurrentPosition();
      if (location != null) {
        final currentUser = AuthService.getCurrentUser();
        if (currentUser != null) {
          await MonetizationService.trackBannerClick(
            banner.id,
            currentUser.id,
            location.latitude,
            location.longitude,
          );
        }
      }
    } catch (e) {
      debugPrint('Error tracking banner click: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: PageView.builder(
        controller: _pageController,
        itemCount: _banners.length,
        onPageChanged: (index) async {
          _currentIndex = index;

          // Tracke Impression für das neue Banner
          if (_banners.isNotEmpty && index < _banners.length) {
            try {
              final location = await LocationService.getCurrentPosition();
              if (location != null) {
                await _trackBannerImpression(
                    _banners[index], location.latitude, location.longitude);
              }
            } catch (e) {
              debugPrint('Error tracking page change impression: $e');
            }
          }
        },
        itemBuilder: (context, index) {
          final banner = _banners[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // Banner Image - Verwende Container mit Fallback statt AssetImage
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Banner Content
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            banner.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (banner.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              banner.description!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white70,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${banner.location} • ${banner.radiusKm}km',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Werbung',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Tap Handler
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _onBannerTap(banner);
                        },
                        onTapDown: (_) => _pauseAutoRotation(),
                        onLongPress: () => _pauseAutoRotation(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _startAutoRotation() {
    _autoRotationTimer?.cancel();
    _autoRotationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isUserInteracting && mounted && _banners.length > 1) {
        _currentIndex = (_currentIndex + 1) % _banners.length;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _pauseAutoRotation() {
    if (!_isUserInteracting) {
      _isUserInteracting = true;
      _autoRotationTimer?.cancel();
      debugPrint('⏸️ Banner rotation paused');

      // Resume after 5 seconds
      Timer(const Duration(seconds: 5), () {
        if (mounted) {
          _isUserInteracting = false;
          debugPrint('▶️ Banner rotation resumed');
          _startAutoRotation();
        }
      });
    }
  }

  void _onBannerTap(BannerModel banner) async {
    _pauseAutoRotation();

    // Tracke Banner-Click
    await _trackBannerClick(banner);

    // Check if context is still mounted before navigation
    if (!mounted) return;

    // Navigate to store detail
    Navigator.pushNamed(
      context,
      '/store-detail',
      arguments: {
        'storeId': banner.storeId,
        'bannerId': banner.id,
        'storeName': banner.title,
        'storeDescription': banner.description,
        'storeLocation': banner.location,
        'storeImage': banner.imageUrl,
      },
    );
  }
}
