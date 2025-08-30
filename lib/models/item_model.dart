class ItemModel {
  final String id;
  final String name;
  final String? description;
  final String category;
  final double? price;
  final String condition;
  final List<String> images;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? location;
  final double? latitude;
  final double? longitude;

  ItemModel({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    this.price,
    required this.condition,
    this.images = const [],
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.location,
    this.latitude,
    this.longitude,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      price: json['price']?.toDouble(),
      condition: json['condition'] as String,
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      location: json['location'] as String?,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'condition': condition,
      'images': images,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  ItemModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    String? condition,
    List<String>? images,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? location,
    double? latitude,
    double? longitude,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      condition: condition ?? this.condition,
      images: images ?? this.images,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  // Helper methods
  bool isFree() {
    return price == null || price == 0.0;
  }

  bool isForSale() {
    return price != null && price! > 0.0;
  }

  bool isForSwap() {
    return price == null || price == 0.0;
  }

  bool hasLocation() {
    return latitude != null && longitude != null;
  }

  String getPriceDisplay() {
    if (isFree()) return 'Kostenlos';
    if (isForSale()) return 'CHF ${price!.toStringAsFixed(2)}';
    return 'Tausch';
  }

  bool isRecent() {
    final daysSinceCreated = DateTime.now().difference(createdAt).inDays;
    return daysSinceCreated <=
        7; // Item ist "recent" wenn weniger als 7 Tage alt
  }
}
