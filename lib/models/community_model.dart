class CommunityModel {
  final String id;
  final String name;
  final String? description;
  final String? category;
  final String? imageUrl;
  final bool isPublic;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int memberCount;
  final double? radius;
  final String? location;
  final List<String> categories;
  final bool isActive;

  CommunityModel({
    required this.id,
    required this.name,
    this.description,
    this.category,
    this.imageUrl,
    required this.isPublic,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.memberCount = 0,
    this.radius,
    this.location,
    this.categories = const [],
    this.isActive = true,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      imageUrl: json['image_url'] as String?,
      isPublic: json['is_public'] as bool? ?? true,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      memberCount: json['member_count'] as int? ?? 0,
      radius: json['radius'] as double?,
      location: json['location'] as String?,
      categories: (json['categories'] as List<dynamic>?)?.cast<String>() ?? [],
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'image_url': imageUrl,
      'is_public': isPublic,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'member_count': memberCount,
      'radius': radius,
      'location': location,
      'categories': categories,
      'is_active': isActive,
    };
  }

  CommunityModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? imageUrl,
    bool? isPublic,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? memberCount,
    double? radius,
    String? location,
    List<String>? categories,
    bool? isActive,
  }) {
    return CommunityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isPublic: isPublic ?? this.isPublic,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      memberCount: memberCount ?? this.memberCount,
      radius: radius ?? this.radius,
      location: location ?? this.location,
      categories: categories ?? this.categories,
      isActive: isActive ?? this.isActive,
    );
  }

  // Helper methods for membership checks
  bool isMember(String userId) {
    // Simple check - in real app, this would query the database
    return createdBy == userId; // Placeholder logic
  }

  bool isAdmin(String userId) {
    return createdBy == userId;
  }

  bool canJoin(String userId) {
    return !isMember(userId) && isPublic;
  }

  bool canLeave(String userId) {
    return isMember(userId) && !isAdmin(userId);
  }
}
