import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/drive_session.dart';

class SessionStorage {
  static const _boxName = 'drive_sessions';
  static Box<DriveSession>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DriveSessionAdapter());
    Hive.registerAdapter(DriveEventAdapter());
    _box = await Hive.openBox<DriveSession>(_boxName);
  }

  static Future<void> saveSession(DriveSession session) async {
    await _box?.add(session);
    await FirebaseFirestore.instance
        .collection('sessions')
        .add(session.toMap());
  }

  static List<DriveSession> getSessions() {
    final sessions = _box?.values.toList() ?? [];
    // Most recent first
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions;
  }

  static Future<void> deleteSession(DriveSession session) async {
    await session.delete();
  }

  static Future<void> clearAll() async {
    await _box?.clear();
  }
}
