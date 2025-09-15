class DonationModel {
  final String id;
  final String userId;
  final double amount;
  final int listingCredits; // Anzahl freigeschalteter Inserate
  final String purpose; // 'app_development', 'charity', 'both'
  final String? charityName;
  final String status; // 'pending', 'completed', 'failed'
  final String? paymentMethod;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  DonationModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.listingCredits,
    required this.purpose,
    this.charityName,
    required this.status,
    this.paymentMethod,
    required this.createdAt,
    this.metadata,
  });

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      amount: json['amount']?.toDouble() ?? 0.0,
      listingCredits: json['listing_credits'] ?? 0,
      purpose: json['purpose'] ?? 'both',
      charityName: json['charity_name'],
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'listing_credits': listingCredits,
      'purpose': purpose,
      'charity_name': charityName,
      'status': status,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  bool get isCompleted => status == 'completed';

  double get appDevelopmentAmount => purpose == 'app_development'
      ? amount
      : purpose == 'charity'
          ? 0.0
          : amount * 0.5;

  double get charityAmount => purpose == 'charity'
      ? amount
      : purpose == 'app_development'
          ? 0.0
          : amount * 0.5;

  DonationModel copyWith({
    String? id,
    String? userId,
    double? amount,
    int? listingCredits,
    String? purpose,
    String? charityName,
    String? status,
    String? paymentMethod,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return DonationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      listingCredits: listingCredits ?? this.listingCredits,
      purpose: purpose ?? this.purpose,
      charityName: charityName ?? this.charityName,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
