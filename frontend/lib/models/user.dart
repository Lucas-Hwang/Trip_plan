class User {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String? fcmToken;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.fcmToken,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    email: json['email'],
    displayName: json['displayName'],
    avatarUrl: json['avatarUrl'],
    fcmToken: json['fcmToken'],
    createdAt: DateTime.parse(json['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'fcmToken': fcmToken,
    'createdAt': createdAt.toIso8601String(),
  };
}
