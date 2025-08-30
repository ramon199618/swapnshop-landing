/// Einheitliches Listing-Model für alle Inhalte (Gruppen, Stores, allgemein)
class Listing {
  final String id;
  final String title;
  final String description;
  final ListingType type;
  final String category;
  final double? price; // nullable für Giveaways
  final double? value; // geschätzter Wert für Versicherung etc.
  final String? desiredItem; // Was wird gesucht? (nur bei Swap)
  final String ownerId;
  final String ownerName;
  final List<String> images;
  final List<String> tags;
  final List<String> offerTags; // Was wird angeboten? (nur bei Swap)
  final List<String> wantTags; // Was wird gesucht? (nur bei Swap)
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final int radiusKm;
  final bool isActive;
  final ListingVisibility visibility;
  final String language; // DE, IT, FR, EN, PT
  final String? groupId; // Optional: Quelle Gruppe
  final String? storeId; // Optional: Quelle Store
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isAnonymous;
  final String condition; // new, used, etc.
  // Job-spezifische Felder
  final String? jobCategory; // Alltagsjobs, Sommerjobs, Hauptjobs
  final String? paymentType; // Bezahlt, Tausch, Freiwillig

  Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    this.price,
    this.value,
    this.desiredItem,
    required this.ownerId,
    required this.ownerName,
    required this.images,
    required this.tags,
    required this.offerTags,
    required this.wantTags,
    this.latitude,
    this.longitude,
    this.locationName,
    this.radiusKm = 50,
    this.isActive = true,
    this.visibility = ListingVisibility.public,
    this.language = 'de',
    this.groupId,
    this.storeId,
    required this.createdAt,
    required this.updatedAt,
    this.isAnonymous = false,
    this.condition = 'used',
    this.jobCategory,
    this.paymentType,
  });

  /// Erstellt ein Listing aus JSON (Supabase)
  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: ListingType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ListingType.swap,
      ),
      category: json['category'] ?? '',
      price: json['price']?.toDouble(),
      value: json['value']?.toDouble(),
      desiredItem: json['desired_item'],
      ownerId: json['owner_id'] ?? '',
      ownerName: json['owner_name'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      offerTags: List<String>.from(json['offer_tags'] ?? []),
      wantTags: List<String>.from(json['want_tags'] ?? []),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      locationName: json['location_name'],
      radiusKm: json['radius_km'] ?? 50,
      isActive: json['is_active'] ?? true,
      visibility: ListingVisibility.values.firstWhere(
        (e) => e.name == json['visibility'],
        orElse: () => ListingVisibility.public,
      ),
      language: json['language'] ?? 'de',
      groupId: json['group_id'],
      storeId: json['store_id'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      isAnonymous: json['is_anonymous'] ?? false,
      condition: json['condition'] ?? 'used',
      jobCategory: json['job_category'],
      paymentType: json['payment_type'],
    );
  }

  /// Konvertiert Listing zu JSON (Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'category': category,
      'price': price,
      'value': value,
      'desired_item': desiredItem,
      'owner_id': ownerId,
      'owner_name': ownerName,
      'images': images,
      'tags': tags,
      'offer_tags': offerTags,
      'want_tags': wantTags,
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
      'radius_km': radiusKm,
      'is_active': isActive,
      'visibility': visibility.name,
      'language': language,
      'group_id': groupId,
      'store_id': storeId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_anonymous': isAnonymous,
      'condition': condition,
      'job_category': jobCategory,
      'payment_type': paymentType,
    };
  }

  /// Erstellt eine Kopie mit geänderten Werten
  Listing copyWith({
    String? id,
    String? title,
    String? description,
    ListingType? type,
    String? category,
    double? price,
    double? value,
    String? desiredItem,
    String? ownerId,
    String? ownerName,
    List<String>? images,
    List<String>? tags,
    List<String>? offerTags,
    List<String>? wantTags,
    double? latitude,
    double? longitude,
    String? locationName,
    int? radiusKm,
    bool? isActive,
    ListingVisibility? visibility,
    String? language,
    String? groupId,
    String? storeId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isAnonymous,
    String? condition,
    String? jobCategory,
    String? paymentType,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      price: price ?? this.price,
      value: value ?? this.value,
      desiredItem: desiredItem ?? this.desiredItem,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      offerTags: offerTags ?? this.offerTags,
      wantTags: wantTags ?? this.wantTags,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      radiusKm: radiusKm ?? this.radiusKm,
      isActive: isActive ?? this.isActive,
      visibility: visibility ?? this.visibility,
      language: language ?? this.language,
      groupId: groupId ?? this.groupId,
      storeId: storeId ?? this.storeId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      condition: condition ?? this.condition,
      jobCategory: jobCategory ?? this.jobCategory,
      paymentType: paymentType ?? this.paymentType,
    );
  }

  // Getter für anonyme Anzeige
  String get displayName => isAnonymous ? 'Anonym' : ownerName;

  // Getter für Geo-Position
  bool get hasPosition => latitude != null && longitude != null;

  // Getter für Quelle-Badge
  String? get sourceBadge {
    if (groupId != null) return 'Aus Gruppe';
    if (storeId != null) return 'Aus Store';
    return null;
  }

  // Getter für Preis-Anzeige
  String get priceDisplay {
    switch (type) {
      case ListingType.giveaway:
        return 'Kostenlos';
      case ListingType.swap:
        return desiredItem != null ? 'Tausch' : 'Tausch';
      case ListingType.sell:
        return price != null
            ? 'CHF ${price!.toStringAsFixed(2)}'
            : 'Preis auf Anfrage';
      case ListingType.job:
        return paymentType ?? 'Bezahlung auf Anfrage';
    }
  }

  // Getter für Kategorie-Anzeige
  String get categoryDisplay {
    // Job-Kategorien haben Vorrang
    if (type == ListingType.job && jobCategory != null) {
      switch (jobCategory) {
        case 'alltagsjobs':
          return 'Alltagsjobs';
        case 'sommerjobs':
          return 'Sommerjobs';
        case 'hauptjobs':
          return 'Hauptjobs';
        default:
          return jobCategory!;
      }
    }

    // Normale Kategorien
    switch (category) {
      case 'electronics':
        return 'Elektronik';
      case 'clothing':
        return 'Kleidung';
      case 'sports':
        return 'Sport';
      case 'books':
        return 'Bücher';
      case 'furniture':
        return 'Möbel';
      case 'automotive':
        return 'Auto & Motorrad';
      case 'real_estate':
        return 'Immobilien';
      case 'antiques':
        return 'Antiquitäten';
      case 'art':
        return 'Kunst';
      case 'music':
        return 'Musik';
      case 'toys':
        return 'Spielzeug';
      case 'household':
        return 'Haushalt';
      case 'plants':
        return 'Pflanzen';
      default:
        return category;
    }
  }
}

/// Listing-Typen
enum ListingType {
  swap, // Tausch
  sell, // Verkauf
  giveaway, // Verschenken
  job, // Job/Hilfe inserieren
}

/// Sichtbarkeit der Listings
enum ListingVisibility {
  public, // Global sichtbar in Swipe
  groupOnly, // Nur in Gruppen-Feed
  storeOnly, // Nur im Store
  private, // Nicht öffentlich
}
