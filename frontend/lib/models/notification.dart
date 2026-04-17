class AppNotification {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'],
    userId: json['userId'],
    type: json['type'],
    title: json['title'],
    body: json['body'],
    data: json['data'],
    isRead: json['isRead'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
  );
}
