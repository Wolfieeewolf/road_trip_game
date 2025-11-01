import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_user.dart';
import 'link_session.dart';

class LinkService {
  LinkService(this._prefs);

  static const _sessionsKey = 'rtg_link_sessions';
  static const _currentKey = 'rtg_link_current_code';

  final SharedPreferences _prefs;
  final Random _random = Random.secure();

  Map<String, dynamic> _loadSessions() {
    final raw = _prefs.getString(_sessionsKey);
    if (raw == null || raw.isEmpty) {
      return <String, dynamic>{};
    }
    final decoded = jsonDecode(raw);
    return Map<String, dynamic>.from(decoded as Map);
  }

  Future<void> _saveSessions(Map<String, dynamic> sessions) async {
    await _prefs.setString(_sessionsKey, jsonEncode(sessions));
  }

  String _generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(6, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  LinkSession? _decodeSession(String code, Map<String, dynamic> sessions) {
    final raw = sessions[code];
    if (raw == null) return null;
    return LinkSession.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  Future<LinkSession> createSession(AuthUser host) async {
    final sessions = _loadSessions();
    String code;
    do {
      code = _generateJoinCode();
    } while (sessions.containsKey(code));

    final session = LinkSession(
      code: code,
      host: host,
      participants: [host],
      updatedAt: DateTime.now(),
    );

    sessions[code] = session.toJson();
    await _saveSessions(sessions);
    await _prefs.setString(_currentKey, code);
    return session;
  }

  Future<LinkSession> joinSession(String code, AuthUser user) async {
    final sessions = _loadSessions();
    final session = _decodeSession(code, sessions);
    if (session == null) {
      throw StateError('Session not found');
    }

    final updatedParticipants = List<AuthUser>.from(session.participants);
    final existingIndex = updatedParticipants
        .indexWhere((participant) => participant.id == user.id);
    if (existingIndex == -1) {
      updatedParticipants.add(user);
    } else {
      updatedParticipants[existingIndex] = user;
    }

    final updatedSession = session.copyWith(
      participants: updatedParticipants,
      updatedAt: DateTime.now(),
    );

    sessions[code] = updatedSession.toJson();
    await _saveSessions(sessions);
    await _prefs.setString(_currentKey, code);
    return updatedSession;
  }

  Future<LinkSession?> leaveSession(String code, AuthUser user) async {
    final sessions = _loadSessions();
    final session = _decodeSession(code, sessions);
    if (session == null) {
      await _prefs.remove(_currentKey);
      return null;
    }

    final remaining = session.participants
        .where((participant) => participant.id != user.id)
        .toList();

    if (remaining.isEmpty) {
      sessions.remove(code);
      await _saveSessions(sessions);
      await _prefs.remove(_currentKey);
      return null;
    }

    final newHost = session.isHost(user.id) ? remaining.first : session.host;
    if (session.isHost(user.id)) {
      remaining.removeAt(0);
      remaining.insert(0, newHost);
    }
    final updatedSession = LinkSession(
      code: code,
      host: newHost,
      participants: remaining,
      updatedAt: DateTime.now(),
    );

    sessions[code] = updatedSession.toJson();
    await _saveSessions(sessions);
    await _prefs.setString(_currentKey, code);
    return updatedSession;
  }

  Future<LinkSession?> fetchSession(String code) async {
    final sessions = _loadSessions();
    return _decodeSession(code, sessions);
  }

  Future<String?> getCurrentSessionCode() async {
    return _prefs.getString(_currentKey);
  }

  Future<void> clearCurrentSession() async {
    await _prefs.remove(_currentKey);
  }
}
