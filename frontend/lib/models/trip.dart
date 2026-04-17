import 'user.dart';

enum TripRole { owner, editor, viewer }

class Trip {
  final String id;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String inviteCode;
  final User? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.inviteCode,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
    id: json['id'],
    title: json['title'],
    destination: json['destination'],
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    inviteCode: json['inviteCode'],
    createdBy: json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'destination': destination,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'inviteCode': inviteCode,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
