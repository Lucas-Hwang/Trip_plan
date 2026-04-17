import 'user.dart';
import 'comment.dart';
import 'vote.dart';

enum ItineraryType { food, sight, shopping, relax, transport }

class Itinerary {
  final String id;
  final String tripId;
  final int dayIndex;
  final String? time;
  final String title;
  final ItineraryType type;
  final int cost;
  final String? note;
  final int orderIndex;
  final bool done;
  final User? createdBy;
  final List<Comment> comments;
  final List<Vote> votes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Itinerary({
    required this.id,
    required this.tripId,
    required this.dayIndex,
    this.time,
    required this.title,
    required this.type,
    this.cost = 0,
    this.note,
    this.orderIndex = 0,
    this.done = false,
    this.createdBy,
    this.comments = const [],
    this.votes = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) => Itinerary(
    id: json['id'],
    tripId: json['tripId'],
    dayIndex: json['dayIndex'],
    time: json['time'],
    title: json['title'],
    type: ItineraryType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => ItineraryType.sight,
    ),
    cost: json['cost'] ?? 0,
    note: json['note'],
    orderIndex: json['orderIndex'] ?? 0,
    done: json['done'] ?? false,
    createdBy: json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
    comments: (json['comments'] as List?)?.map((c) => Comment.fromJson(c)).toList() ?? [],
    votes: (json['votes'] as List?)?.map((v) => Vote.fromJson(v)).toList() ?? [],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'tripId': tripId,
    'dayIndex': dayIndex,
    'time': time,
    'title': title,
    'type': type.name,
    'cost': cost,
    'note': note,
    'orderIndex': orderIndex,
    'done': done,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  Itinerary copyWith({
    String? id,
    int? dayIndex,
    String? time,
    String? title,
    ItineraryType? type,
    int? cost,
    String? note,
    int? orderIndex,
    bool? done,
    List<Comment>? comments,
    List<Vote>? votes,
  }) => Itinerary(
    id: id ?? this.id,
    tripId: tripId,
    dayIndex: dayIndex ?? this.dayIndex,
    time: time ?? this.time,
    title: title ?? this.title,
    type: type ?? this.type,
    cost: cost ?? this.cost,
    note: note ?? this.note,
    orderIndex: orderIndex ?? this.orderIndex,
    done: done ?? this.done,
    createdBy: createdBy,
    comments: comments ?? this.comments,
    votes: votes ?? this.votes,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
