import 'user.dart';

class Vote {
  final String id;
  final String itineraryId;
  final String userId;
  final String option;
  final User? user;
  final DateTime createdAt;

  Vote({
    required this.id,
    required this.itineraryId,
    required this.userId,
    required this.option,
    this.user,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'itineraryId': itineraryId,
    'userId': userId,
    'option': option,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Vote.fromJson(Map<String, dynamic> json) => Vote(
    id: json['id'],
    itineraryId: json['itineraryId'],
    userId: json['userId'],
    option: json['option'],
    user: json['user'] != null ? User.fromJson(json['user']) : null,
    createdAt: DateTime.parse(json['createdAt']),
  );
}
