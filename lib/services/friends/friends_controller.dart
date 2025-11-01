import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../auth/auth_user.dart';
import '../link/link_session.dart';
import 'friend_contact.dart';

class FriendsController extends ChangeNotifier {
  FriendsController(this._prefs);

  static const _prefsKey = 'rtg_saved_friends';

  final SharedPreferences _prefs;
  final Uuid _uuid = const Uuid();

  final List<FriendContact> _friends = [];
  bool _isInitialized = false;

  UnmodifiableListView<FriendContact> get friends =>
      UnmodifiableListView(_friends);

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    final stored = _prefs.getString(_prefsKey);
    final decoded = FriendContact.decodeList(stored);
    _friends
      ..clear()
      ..addAll(decoded);
    _friends.sort((a, b) =>
        a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
    _isInitialized = true;
    notifyListeners();
  }

  FriendContact? getFriend(String id) {
    try {
      return _friends.firstWhere((friend) => friend.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addFriend({
    required String displayName,
    String? friendCode,
    String? phoneNumber,
  }) async {
    final trimmedName = displayName.trim();
    final code = _normalizeCode(friendCode);
    final phone = _normalizePhone(phoneNumber);
    if (trimmedName.isEmpty) {
      throw ArgumentError('Display name cannot be empty');
    }

    final existing = _findByCodeOrNameOrPhone(code, phone, trimmedName);
    final now = DateTime.now();

    if (existing != null) {
      final updated = existing.copyWith(
        displayName: trimmedName,
        friendCode: code ?? existing.friendCode,
        phoneNumber: phone ?? existing.phoneNumber,
        updatedAt: now,
      );
      await _replaceFriend(existing.id, updated);
      return;
    }

    final friend = FriendContact(
      id: _uuid.v4(),
      displayName: trimmedName,
      friendCode: code,
      phoneNumber: phone,
      userId: null,
      createdAt: now,
      updatedAt: now,
    );
    _friends.add(friend);
    _sortFriends();
    await _persist();
    notifyListeners();
  }

  Future<void> addOrUpdateFromUser(AuthUser user) async {
    final existing = _friends.firstWhere(
      (friend) => friend.userId == user.id,
      orElse: () => _friends.firstWhere(
        (friend) => friend.friendCode == user.friendCode,
        orElse: () => FriendContact(
          id: _uuid.v4(),
          displayName: user.displayName,
          friendCode: user.friendCode,
          phoneNumber: null,
          userId: user.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ),
    );

    final now = DateTime.now();
    final updated = existing.copyWith(
      displayName: user.displayName,
      friendCode: user.friendCode,
      userId: user.id,
      phoneNumber: existing.phoneNumber,
      updatedAt: now,
    );

    final index = _friends.indexWhere((friend) => friend.id == existing.id);
    if (index >= 0) {
      _friends[index] = updated;
    } else {
      _friends.add(updated);
    }
    _sortFriends();
    await _persist();
    notifyListeners();
  }

  Future<void> importFromSession(LinkSession session) async {
    for (final participant in session.participants) {
      await addOrUpdateFromUser(participant);
    }
  }

  Future<void> removeFriend(String friendId) async {
    final index = _friends.indexWhere((friend) => friend.id == friendId);
    if (index == -1) return;
    _friends.removeAt(index);
    await _persist();
    notifyListeners();
  }

  Future<void> updateFriend(
    String friendId, {
    required String displayName,
    String? friendCode,
    String? phoneNumber,
  }) async {
    final friend = getFriend(friendId);
    if (friend == null) return;
    final trimmedName = displayName.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Display name cannot be empty');
    }
    final code = _normalizeCode(friendCode);
    final phone = _normalizePhone(phoneNumber);

    final updated = friend.copyWith(
      displayName: trimmedName,
      friendCode: code,
      phoneNumber: phone,
      updatedAt: DateTime.now(),
    );
    await _replaceFriend(friendId, updated);
  }

  bool isSavedUser(String userId) {
    return _friends.any((friend) => friend.userId == userId);
  }

  bool isSavedCode(String friendCode) {
    final normalized = _normalizeCode(friendCode);
    if (normalized == null) return false;
    return _friends.any((friend) => friend.friendCode == normalized);
  }

  List<FriendContact> search(String query) {
    final lower = query.toLowerCase();
    return _friends
        .where(
          (friend) =>
              friend.displayName.toLowerCase().contains(lower) ||
              (friend.friendCode?.toLowerCase().contains(lower) ?? false) ||
              (friend.phoneNumber?.contains(query) ?? false),
        )
        .toList();
  }

  Future<void> _persist() async {
    await _prefs.setString(_prefsKey, FriendContact.encodeList(_friends));
  }

  Future<void> _replaceFriend(String id, FriendContact updated) async {
    final index = _friends.indexWhere((friend) => friend.id == id);
    if (index >= 0) {
      _friends[index] = updated;
      _sortFriends();
      await _persist();
      notifyListeners();
    }
  }

  FriendContact? _findByCodeOrNameOrPhone(
    String? code,
    String? phone,
    String name,
  ) {
    if (code != null) {
      for (final friend in _friends) {
        if (friend.friendCode == code) {
          return friend;
        }
      }
    }

    if (phone != null) {
      for (final friend in _friends) {
        if (friend.phoneNumber == phone) {
          return friend;
        }
      }
    }

    final lower = name.toLowerCase();
    for (final friend in _friends) {
      if (friend.displayName.toLowerCase() == lower) {
        return friend;
      }
    }

    return null;
  }

  String? _normalizeCode(String? code) {
    if (code == null) return null;
    final trimmed = code.trim().toUpperCase();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _normalizePhone(String? phone) {
    if (phone == null) return null;
    final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty) return null;
    return digits;
  }

  void _sortFriends() {
    _friends.sort(
      (a, b) =>
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    );
  }
}
