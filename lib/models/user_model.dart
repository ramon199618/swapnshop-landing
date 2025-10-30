class UserModel {
  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final String? bio;
  final String? location;
  final bool isPremium;
  final String? premiumExpiryDate;
  final int monthlySwapsUsed;
  final int monthlySellsUsed;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    this.bio,
    this.location,
    this.isPremium = false,
    this.premiumExpiryDate,
    this.monthlySwapsUsed = 0,
    this.monthlySellsUsed = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      bio: map['bio'] as String?,
      location: map['location'] as String?,
      isPremium: map['is_premium'] as bool? ?? false,
      premiumExpiryDate: map['premium_expiry_date'] as String?,
      monthlySwapsUsed: map['monthly_swaps_used'] as int? ?? 0,
      monthlySellsUsed: map['monthly_sells_used'] as int? ?? 0,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel.fromMap(json);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'avatar_url': avatarUrl,
        'bio': bio,
        'location': location,
        'is_premium': isPremium,
        'premium_expiry_date': premiumExpiryDate,
        'monthly_swaps_used': monthlySwapsUsed,
        'monthly_sells_used': monthlySellsUsed,
      };

  Map<String, dynamic> toJson() => toMap();

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? bio,
    String? location,
    bool? isPremium,
    String? premiumExpiryDate,
    int? monthlySwapsUsed,
    int? monthlySellsUsed,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
      monthlySwapsUsed: monthlySwapsUsed ?? this.monthlySwapsUsed,
      monthlySellsUsed: monthlySellsUsed ?? this.monthlySellsUsed,
    );
  }
}
