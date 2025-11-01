import 'dart:async';

import 'package:flutter/foundation.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_user.dart';
import 'link_service.dart';
import 'link_session.dart';

class LinkController extends ChangeNotifier {
  LinkController(this._authController, this._service) {
    _authController.addListener(_handleAuthChanged);
  }

  final AuthController _authController;
  final LinkService _service;

  LinkSession? _session;
  bool _isBusy = false;
  String? _error;

  LinkSession? get session => _session;
  bool get isBusy => _isBusy;
  String? get error => _error;
  bool get hasSession => _session != null;

  AuthUser? get _currentUser => _authController.user;

  Future<void> initialize() async {
    if (_currentUser == null) {
      _session = null;
      _error = null;
      notifyListeners();
      return;
    }

    final code = await _service.getCurrentSessionCode();
    if (code == null) {
      _session = null;
    } else {
      final session = await _service.fetchSession(code);
      if (session != null && session.containsUser(_currentUser!.id)) {
        _session = session;
      } else {
        _session = null;
        await _service.clearCurrentSession();
      }
    }
    _error = null;
    notifyListeners();
  }

  Future<void> hostNewSession() async {
    final user = _requireUser();
    await _runGuarded(() async {
      _session = await _service.createSession(user);
    });
  }

  Future<void> joinSession(String code) async {
    final user = _requireUser();
    final trimmed = code.trim().toUpperCase();
    if (trimmed.length < 4) {
      _error = 'Enter a valid session code.';
      notifyListeners();
      return;
    }
    await _runGuarded(() async {
      _session = await _service.joinSession(trimmed, user);
    });
  }

  Future<void> leaveSession() async {
    final user = _requireUser();
    final session = _session;
    if (session == null) return;

    await _runGuarded(() async {
      _session = await _service.leaveSession(session.code, user);
    });
  }

  Future<void> refreshSession() async {
    final session = _session;
    if (session == null) return;

    await _runGuarded(() async {
      final refreshed = await _service.fetchSession(session.code);
      if (refreshed == null) {
        _session = null;
        await _service.clearCurrentSession();
      } else {
        _session = refreshed;
      }
    }, silent: true);
  }

  AuthUser _requireUser() {
    final user = _currentUser;
    if (user == null) {
      throw StateError('User must be logged in');
    }
    return user;
  }

  Future<void> _runGuarded(Future<void> Function() action,
      {bool silent = false}) async {
    if (!silent) {
      _isBusy = true;
      _error = null;
      notifyListeners();
    }

    try {
      await action();
      _error = null;
    } on StateError catch (err) {
      _error = err.message;
    } catch (err) {
      _error = err.toString();
    } finally {
      if (!silent) {
        _isBusy = false;
        notifyListeners();
      } else {
        notifyListeners();
      }
    }
  }

  void _handleAuthChanged() {
    if (_currentUser == null) {
      _session = null;
      _service.clearCurrentSession();
      notifyListeners();
    } else {
      unawaited(initialize());
    }
  }

  @override
  void dispose() {
    _authController.removeListener(_handleAuthChanged);
    super.dispose();
  }
}
