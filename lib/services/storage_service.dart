import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/practice_session.dart';

class StorageService {
  static const String _sessionsKey = 'practice_sessions';

  Future<List<PracticeSession>> loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getStringList(_sessionsKey) ?? [];
      return sessionsJson
          .map((json) => PracticeSession.fromJson(jsonDecode(json)))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      return [];
    }
  }

  Future<void> addSession(PracticeSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessions = await loadSessions();
      sessions.add(session);
      final sessionsJson = sessions.map((s) => jsonEncode(s.toJson())).toList();
      await prefs.setStringList(_sessionsKey, sessionsJson);
    } catch (e) {
      // Handle error silently or log it
    }
  }

  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionsKey);
    } catch (e) {
      // Handle error silently or log it
    }
  }
}

