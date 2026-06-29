import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
part 'drive_session.g.dart';

@HiveType(typeId: 0)
class DriveSession extends HiveObject {
  @HiveField(0)
  late DateTime startTime;

  @HiveField(1)
  late DateTime endTime;

  @HiveField(2)
  late int finalScore;

  @HiveField(3)
  late double distanceKm;

  @HiveField(4)
  late List<DriveEvent> events;

  DriveSession({
    required this.startTime,
    required this.endTime,
    required this.finalScore,
    required this.distanceKm,
    required this.events,
  });

  Duration get duration => endTime.difference(startTime);

  Map<String, dynamic> toMap() {
    return {
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'finalScore': finalScore,
      'distanceKm': distanceKm,
      'events': events.map((e) => e.toMap()).toList(),
    };
  }

  factory DriveSession.fromMap(Map<String, dynamic> map) {
    return DriveSession(
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      finalScore: map['finalScore'] as int,
      distanceKm: (map['distanceKm'] as num).toDouble(),
      events: (map['events'] as List)
          .map((e) => DriveEvent.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  String get statusText {
    if (finalScore >= 85) return 'You are doing great!';
    if (finalScore >= 60) return 'Needs improvement';
    return "Please don't drive again";
  }

  String get durationFormatted {
    final d = duration;
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m} min';
  }
}

@HiveType(typeId: 1)
class DriveEvent extends HiveObject {
  @HiveField(0)
  late String type;

  @HiveField(1)
  late int pointsDeducted;

  @HiveField(2)
  late DateTime timestamp;

  DriveEvent({
    required this.type,
    required this.pointsDeducted,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'pointsDeducted': pointsDeducted,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory DriveEvent.fromMap(Map<String, dynamic> map) {
    return DriveEvent(
      type: map['type'] as String,
      pointsDeducted: map['pointsDeducted'] as int,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
