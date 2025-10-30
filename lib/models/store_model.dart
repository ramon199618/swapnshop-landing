class StoreModel {
  final String id;
  final String name;
  final String description;
  final String storeType; // 'second_hand', 'small', 'pro'
  final String ownerId;
  final String? logoUrl;
  final String? bannerUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Store-Ads für Banner-Werbung
  final List<StoreAd>? ads;

  StoreModel({
    required this.id,
    required this.name,
    required this.description,
    required this.storeType,
    required this.ownerId,
    this.logoUrl,
    this.bannerUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.ads,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      storeType: json['store_type'] ?? 'second_hand',
      ownerId: json['owner_id'] ?? '',
      logoUrl: json['logo_url'],
      bannerUrl: json['banner_url'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      ads: json['ads'] != null 
          ? (json['ads'] as List).map((ad) => StoreAd.fromJson(ad)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'store_type': storeType,
      'owner_id': ownerId,
      'logo_url': logoUrl,
      'banner_url': bannerUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'ads': ads?.map((ad) => ad.toJson()).toList(),
    };
  }

  // Store-Typ-spezifische Eigenschaften
  String get displayName {
    switch (storeType) {
      case 'second_hand':
        return 'Second-Hand-Händler:in';
      case 'small':
        return 'Kleiner Store';
      case 'pro':
        return 'Professioneller Store';
      default:
        return 'Store';
    }
  }

  String get displayIcon {
    switch (storeType) {
      case 'second_hand':
        return '🛍️';
      case 'small':
        return '🏪';
      case 'pro':
        return '🏢';
      default:
        return '🏪';
    }
  }

  // Default Radius für Store-Typ
  int get defaultRadiusKm {
    switch (storeType) {
      case 'second_hand':
        return 5;
      case 'small':
        return 5; // Erste Auswahl = 5
      case 'pro':
        return 20;
      default:
        return 5;
    }
  }

  // Verfügbare Radius-Optionen für Store-Typ
  List<int> get availableRadiusOptions {
    switch (storeType) {
      case 'second_hand':
        return [5, 10, 25, 50];
      case 'small':
        return [5, 10, 25, 50];
      case 'pro':
        return [5, 10, 20, 25, 50];
      default:
        return [5, 10, 25, 50];
    }
  }

  // Preis für Banner-Werbung basierend auf Radius
  static double getBannerPrice(int radiusKm) {
    if (radiusKm <= 5) {
      return 1.0; // Konstanter Niedrigpreis für lokale Banner
    } else if (radiusKm <= 10) {
      return 2.0;
    } else if (radiusKm <= 20) {
      return 5.0;
    } else if (radiusKm <= 50) {
      return 10.0;
    } else {
      return 15.0; // Maximaler Radius
    }
  }

  // Kann Banner erstellen (alle Store-Typen können Banner erstellen)
  bool get canCreateBanners => true;

  // Kann Store erstellen (alle Store-Typen können Store erstellen)
  bool get canCreateStore => true;
}

// Store-Ad für Banner-Werbung
class StoreAd {
  final String id;
  final String storeId;
  final String title;
  final String description;
  final String imageUrl;
  final String? linkUrl;
  final int radiusKm;
  final double centerLat;
  final double centerLon;
  final DateTime startAt;
  final DateTime endAt;
  final String status; // 'scheduled', 'active', 'paused', 'ended'
  final int budgetTier; // 1-3
  final double priceChf;
  final int impressionsCount;
  final int clicksCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  StoreAd({
    required this.id,
    required this.storeId,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.linkUrl,
    required this.radiusKm,
    required this.centerLat,
    required this.centerLon,
    required this.startAt,
    required this.endAt,
    required this.status,
    required this.budgetTier,
    required this.priceChf,
    this.impressionsCount = 0,
    this.clicksCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoreAd.fromJson(Map<String, dynamic> json) {
    return StoreAd(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      linkUrl: json['link_url'],
      radiusKm: json['radius_km'] ?? 5,
      centerLat: (json['center_lat'] ?? 0.0).toDouble(),
      centerLon: (json['center_lon'] ?? 0.0).toDouble(),
      startAt: DateTime.parse(json['start_at'] ?? DateTime.now().toIso8601String()),
      endAt: DateTime.parse(json['end_at'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'scheduled',
      budgetTier: json['budget_tier'] ?? 1,
      priceChf: (json['price_chf'] ?? 0.0).toDouble(),
      impressionsCount: json['impressions_count'] ?? 0,
      clicksCount: json['clicks_count'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'link_url': linkUrl,
      'radius_km': radiusKm,
      'center_lat': centerLat,
      'center_lon': centerLon,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'status': status,
      'budget_tier': budgetTier,
      'price_chf': priceChf,
      'impressions_count': impressionsCount,
      'clicks_count': clicksCount,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Status-Überprüfungen
  bool get isCurrentlyActive => status == 'active' && isActive;
  bool get isScheduled => status == 'scheduled';
  bool get isPaused => status == 'paused';
  bool get isEnded => status == 'ended';

  // Lokales Banner (≤ 5 km)
  bool get isLocalBanner => radiusKm <= 5;

  // Banner ist aktuell sichtbar
  bool get isCurrentlyVisible {
    final now = DateTime.now();
    return isCurrentlyActive && 
           now.isAfter(startAt) && 
           now.isBefore(endAt);
  }

  // Preis für den gewählten Radius
  double get calculatedPrice => StoreModel.getBannerPrice(radiusKm);

  // Budget-Tier-Name
  String get budgetTierName {
    switch (budgetTier) {
      case 1:
        return 'Basic';
      case 2:
        return 'Standard';
      case 3:
        return 'Premium';
      default:
        return 'Basic';
    }
  }

  // Status-Name für UI
  String get statusDisplayName {
    switch (status) {
      case 'scheduled':
        return 'Geplant';
      case 'active':
        return 'Aktiv';
      case 'paused':
        return 'Pausiert';
      case 'ended':
        return 'Beendet';
      default:
        return 'Unbekannt';
    }
  }
}
