import 'package:flutter/foundation.dart';

import '../../preferences/repos/local_app_preferences_repository.dart';
import '../models/session_tokens.dart';
import '../models/session_user.dart';
import '../../network/models/api_error.dart';
import '../repos/local_session_repository.dart';

enum SessionState { loading, signedOut, signedIn, failure }

class SessionService extends ChangeNotifier {
  SessionService(
    this._repository,
    this._preferences, {
    Future<SessionUser> Function()? verifyCurrentUser,
  }) : _verifyCurrentUser = verifyCurrentUser;

  final Future<SessionUser> Function()? _verifyCurrentUser;
  SessionUser? _user;
  SessionUser? get user => _user;
  bool _persist = true;

  final SessionRepository _repository;
  final AppPreferencesRepository _preferences;
  SessionTokens? _tokens;
  SessionTokens? get tokens => _tokens;
  SessionState _state = SessionState.loading;
  SessionState get state => _state;
  int _generation = 0;
  int get generation => _generation;
  Future<void> _writes = Future<void>.value();
  Future<bool>? _renewal;
  bool _pendingClear = false;

  // Serialize persistence so a late write cannot overtake a sign-out deletion.
  Future<void> _serialize(Future<void> Function() action) {
    final Future<void> result = _writes.then((_) => action());
    _writes = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
    return result;
  }

  Future<void> restore() async {
    // Retry an unfinished sign-out before reading persisted credentials.
    if (_pendingClear) {
      await clear();
      return;
    }
    final int generation = ++_generation;
    _renewal = null;
    _tokens = null;
    _user = null;
    _state = SessionState.loading;
    notifyListeners();
    try {
      await _serialize(() async {
        final SessionTokens? restored = await _repository.read();
        if (generation != _generation) return;
        if (restored == null) await _preferences.setSelectedFamilyId(null);
        if (generation != _generation) return;
        _tokens = restored;
        _user = null;
        _persist = true;
        _state = restored == null
            ? SessionState.signedOut
            : SessionState.loading;
      });
      if (generation != _generation || _tokens == null) return;
      final SessionUser? user = await _verifyCurrentUser?.call();
      if (generation != _generation) return;
      _user = user;
      _state = SessionState.signedIn;
    } on ApiError catch (error) {
      if (generation != _generation) return;
      if (error.status == 401) {
        await clear();
        return;
      }
      _tokens = null;
      _user = null;
      _state = SessionState.failure;
    } catch (_) {
      if (generation != _generation) return;
      _tokens = null;
      _user = null;
      _state = SessionState.failure;
    } finally {
      if (generation == _generation) notifyListeners();
    }
  }

  Future<void> replace(SessionTokens tokens, {bool persist = true}) async {
    final int generation = ++_generation;
    _renewal = null;
    _tokens = null;
    _user = null;
    _persist = persist;
    _state = SessionState.loading;
    notifyListeners();
    try {
      await _serialize(() async {
        if (generation != _generation) return;
        await _preferences.setSelectedFamilyId(null);
        if (persist) {
          await _repository.write(tokens);
        } else {
          await _repository.clear();
        }
        if (generation != _generation) return;
        _tokens = tokens;
        _pendingClear = false;
      });
      if (generation != _generation) return;
      final SessionUser? user = await _verifyCurrentUser?.call();
      if (generation != _generation) return;
      _user = user;
      _state = SessionState.signedIn;
    } catch (_) {
      try {
        await _serialize(() async {
          if (generation == _generation) await _repository.clear();
        });
      } catch (_) {
        // Keep failure visible when the platform cannot remove credentials.
      }
      if (generation == _generation) {
        _tokens = null;
        _user = null;
        _state = SessionState.failure;
        notifyListeners();
      }
      rethrow;
    }
    if (generation == _generation) notifyListeners();
  }

  Future<void> clear() async {
    final int generation = ++_generation;
    _pendingClear = true;
    _renewal = null;
    _tokens = null;
    _user = null;
    _state = SessionState.signedOut;
    notifyListeners();
    try {
      await _serialize(() async {
        // Remove credentials even if clearing navigation preferences fails.
        await _repository.clear();
        await _preferences.setSelectedFamilyId(null);
        if (generation == _generation) _pendingClear = false;
      });
    } catch (_) {
      if (generation == _generation) {
        _state = SessionState.failure;
        notifyListeners();
      }
      rethrow;
    }
  }

  Future<bool> renew(Future<SessionTokens> Function(String) refresh) {
    if (_renewal != null) return _renewal!;
    final SessionTokens? current = _tokens;
    if (current == null) return Future<bool>.value(false);
    final int generation = _generation;
    final Future<bool> operation = _rotate(current, generation, refresh);
    _renewal = operation;
    return operation;
  }

  Future<bool> _rotate(
    SessionTokens current,
    int generation,
    Future<SessionTokens> Function(String) refresh,
  ) async {
    try {
      final SessionTokens replacement = await refresh(current.refreshToken);
      if (generation != _generation) return false;
      await _serialize(() async {
        if (generation != _generation) return;
        if (_persist) await _repository.write(replacement);
        if (generation == _generation) _tokens = replacement;
      });
      return generation == _generation;
    } catch (_) {
      if (generation == _generation) await clear();
      return false;
    } finally {
      if (generation == _generation) _renewal = null;
    }
  }
}
