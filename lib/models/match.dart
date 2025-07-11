// import 'package:cloud_firestore/cloud_firestore.dart';

// MatchModel für Firestore-Matches
class MatchModel {
  final String id;
  final String userA;
  final String userB;
  final bool userALiked;
  final bool userBLiked;
  final bool isActive;
  final DateTime createdAt;

  MatchModel({
    required this.id,
    required this.userA,
    required this.userB,
    this.userALiked = false,
    this.userBLiked = false,
    this.isActive = true,
    required this.createdAt,
  });

  factory MatchModel.fromJson(String id, Map<String, dynamic> json) {
    return MatchModel(
      id: id,
      userA: json['userA'] ?? '',
      userB: json['userB'] ?? '',
      userALiked: json['userALiked'] ?? false,
      userBLiked: json['userBLiked'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userA': userA,
      'userB': userB,
      'userALiked': userALiked,
      'userBLiked': userBLiked,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// TODO: MatchModel für später implementieren
