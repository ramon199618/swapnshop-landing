class SubscriptionModel {
  final String id;
  final String userId;
  final String type; // 'monthly', 'lifetime'
  final double price;
  final DateTime startDate;
  final DateTime? endDate;
  final String status; // 'active', 'cancelled', 'expired'
  final String? paymentMethod;
  final Map<String, dynamic>? metadata;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.price,
    required this.startDate,
    this.endDate,
    required this.status,
    this.paymentMethod,
    this.metadata,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      type: json['type'] ?? 'monthly',
      price: json['price']?.toDouble() ?? 0.0,
      startDate: DateTime.parse(
          json['start_date'] ?? DateTime.now().toIso8601String()),
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      status: json['status'] ?? 'active',
      paymentMethod: json['payment_method'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'price': price,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status,
      'payment_method': paymentMethod,
      'metadata': metadata,
    };
  }

  bool get isActive =>
      status == 'active' &&
      (type == 'lifetime' ||
          (endDate != null && DateTime.now().isBefore(endDate!)));

  bool get isLifetime => type == 'lifetime';

  Duration? get remainingTime => endDate?.difference(DateTime.now());

  SubscriptionModel copyWith({
    String? id,
    String? userId,
    String? type,
    double? price,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? paymentMethod,
    Map<String, dynamic>? metadata,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      price: price ?? this.price,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      metadata: metadata ?? this.metadata,
    );
  }
}
