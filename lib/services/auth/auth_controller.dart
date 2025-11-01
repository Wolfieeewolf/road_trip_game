import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'auth_user.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._prefs);

  static const _prefsKey = 'rtg_auth_user';

  final SharedPreferences _prefs;
  final Uuid _uuid = const Uuid();

  AuthUser? _user;
  bool _isLoading = true;

  AuthUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get friendCode => _user?.friendCode;

  Future<void> initialize() async {
    final stored = _prefs.getString(_prefsKey);
    _user = AuthUser.fromStorage(stored);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String displayName) async {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Display name cannot be empty');
    }

    final newUser = AuthUser(
      id: _uuid.v4().replaceAll('-', ''),
      displayName: trimmed,
      createdAt: DateTime.now(),
    );

    await _prefs.setString(_prefsKey, AuthUser.toStorage(newUser));
    _user = newUser;
    notifyListeners();
  }

  Future<void> updateDisplayName(String displayName) async {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty || _user == null) {
      return;
    }

    _user = _user!.copyWith(displayName: trimmed);
    await _prefs.setString(_prefsKey, AuthUser.toStorage(_user!));
    notifyListeners();
  }

  Future<void> logout() async {
    await _prefs.remove(_prefsKey);
    _user = null;
    notifyListeners();
  }
}
