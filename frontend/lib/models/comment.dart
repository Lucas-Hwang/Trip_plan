import 'user.dart';

class Comment {
  final String id;
  final String itineraryId;
  final String userId;
  final String content;
  final User? user;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.itineraryId,
    required this.userId,
    required this.content,
    this.user,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'itineraryId': itineraryId,
    'userId': userId,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'],
    itineraryId: json['itineraryId'],
    userId: json['userId'],
    content: json['content'],
    user: json['user'] != null ? User.fromJson(json['user']) : null,
    createdAt: DateTime.parse(json['createdAt']),
  );
}
