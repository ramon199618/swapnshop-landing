class Listing {
  final String id;
  final String title;
  final String subtitle;
  final String userName;
  final String? swapWish;
  final String description;
  final double price;
  final String category;
  final List<String> images;
  final String userId;
  final DateTime createdAt;
  final bool isActive;
  final String location;
  final String condition; // new, used, etc.

  Listing({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.userName = '',
    this.swapWish,
    required this.description,
    required this.price,
    required this.category,
    required this.images,
    required this.userId,
    required this.createdAt,
    this.isActive = true,
    required this.location,
    required this.condition,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      userName: json['userName'] ?? '',
      swapWish: json['swapWish'],
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      category: json['category'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      userId: json['userId'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      isActive: json['isActive'] ?? true,
      location: json['location'] ?? '',
      condition: json['condition'] ?? 'used',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'userName': userName,
      if (swapWish != null) 'swapWish': swapWish,
      'description': description,
      'price': price,
      'category': category,
      'images': images,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'location': location,
      'condition': condition,
    };
  }

  Listing copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? userName,
    String? swapWish,
    String? description,
    double? price,
    String? category,
    List<String>? images,
    String? userId,
    DateTime? createdAt,
    bool? isActive,
    String? location,
    String? condition,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      userName: userName ?? this.userName,
      swapWish: swapWish ?? this.swapWish,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      images: images ?? this.images,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      location: location ?? this.location,
      condition: condition ?? this.condition,
    );
  }
}
