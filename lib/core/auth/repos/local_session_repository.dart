import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/session_tokens.dart';

abstract interface class SessionRepository {
  Future<SessionTokens?> read();
  Future<void> write(SessionTokens tokens);
  Future<void> clear();
}

class MemorySessionRepository implements SessionRepository {
  SessionTokens? _tokens;

  @override
  Future<SessionTokens?> read() async => _tokens;
  @override
  Future<void> write(SessionTokens tokens) async => _tokens = tokens;
  @override
  Future<void> clear() async => _tokens = null;
}

class LocalSessionRepository implements SessionRepository {
  LocalSessionRepository(this._storage);

  static const String storageKey = 'beehome.session';
  final FlutterSecureStorage _storage;

  @override
  Future<SessionTokens?> read() async {
    final String? value = await _storage.read(key: storageKey);
    if (value == null) return null;
    try {
      return SessionTokens.fromJson(jsonDecode(value));
    } on FormatException {
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(SessionTokens tokens) =>
      _storage.write(key: storageKey, value: jsonEncode(tokens.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: storageKey);
}

SessionRepository createSessionRepository() {
  if (kIsWeb) return MemorySessionRepository();
  if (defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android) {
    return LocalSessionRepository(const FlutterSecureStorage());
  }
  throw UnsupportedError('BeeHome supports iOS, Android and Web.');
}
