class BannerModel {
  final String id;
  final String storeId;
  final String userId;
  final String title;
  final String? description;
  final String imageUrl;
  final String location;
  final double latitude;
  final double longitude;
  final int radiusKm;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final String status; // 'active', 'pending', 'expired', 'cancelled'
  final DateTime createdAt;
  final Map<String, dynamic>? analytics;

  BannerModel({
    required this.id,
    required this.storeId,
    required this.userId,
    required this.title,
    this.description,
    required this.imageUrl,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.status,
    required this.createdAt,
    this.analytics,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      imageUrl: json['image_url'] ?? '',
      location: json['location'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      radiusKm: json['radius_km'] ?? 5,
      startDate: DateTime.parse(
          json['start_date'] ?? DateTime.now().toIso8601String()),
      endDate:
          DateTime.parse(json['end_date'] ?? DateTime.now().toIso8601String()),
      price: json['price']?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      analytics: json['analytics'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'user_id': userId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'radius_km': radiusKm,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'price': price,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'analytics': analytics,
    };
  }

  bool get isActive =>
      status == 'active' &&
      DateTime.now().isAfter(startDate) &&
      DateTime.now().isBefore(endDate);

  bool get isExpired => DateTime.now().isAfter(endDate);

  Duration get remainingTime => endDate.difference(DateTime.now());

  BannerModel copyWith({
    String? id,
    String? storeId,
    String? userId,
    String? title,
    String? description,
    String? imageUrl,
    String? location,
    double? latitude,
    double? longitude,
    int? radiusKm,
    DateTime? startDate,
    DateTime? endDate,
    double? price,
    String? status,
    DateTime? createdAt,
    Map<String, dynamic>? analytics,
  }) {
    return BannerModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      price: price ?? this.price,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      analytics: analytics ?? this.analytics,
    );
  }
}
