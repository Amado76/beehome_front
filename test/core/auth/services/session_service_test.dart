import 'dart:async';
import 'package:beehome/core/auth/repos/local_session_repository.dart';
import 'package:beehome/core/auth/models/session_tokens.dart';
import 'package:beehome/core/preferences/repos/local_app_preferences_repository.dart';
import 'package:beehome/core/auth/services/session_service.dart';
import 'package:flutter_test/flutter_test.dart';

class BlockingSessionRepository extends MemorySessionRepository {
  bool block = false;
  final Completer<void> started = Completer<void>();
  final Completer<void> release = Completer<void>();
  @override
  Future<void> write(SessionTokens tokens) async {
    if (block) {
      started.complete();
      await release.future;
    }
    await super.write(tokens);
  }
}

void main() {
  test('sign-out deletion follows an already started rotation write', () async {
    final BlockingSessionRepository store = BlockingSessionRepository();
    final SessionService session = SessionService(
      store,
      MemoryAppPreferencesRepository(),
    );
    await session.replace(const SessionTokens('old-access', 'old-refresh'));
    store.block = true;
    final Future<bool> renewal = session.renew(
      (String token) async => const SessionTokens('new-access', 'new-refresh'),
    );
    await store.started.future;
    final Future<void> signOut = session.clear();
    store.release.complete();
    expect(await renewal, isFalse);
    await signOut;
    expect(await store.read(), isNull);
    expect(session.tokens, isNull);
    session.dispose();
  });

  test('session changes clear family selection but retain locale', () async {
    final MemoryAppPreferencesRepository preferences =
        MemoryAppPreferencesRepository();
    await preferences.setLocale('pt-BR');
    await preferences.setSelectedFamilyId('family');
    final SessionService session = SessionService(
      MemorySessionRepository(),
      preferences,
    );
    await session.restore();
    expect(session.state, SessionState.signedOut);
    await session.replace(const SessionTokens('access', 'refresh'));
    expect(await preferences.selectedFamilyId(), isNull);
    expect(await preferences.locale(), 'pt-BR');
    await preferences.setSelectedFamilyId('other-family');
    await session.clear();
    expect(session.state, SessionState.signedOut);
    expect(await preferences.selectedFamilyId(), isNull);
    session.dispose();
  });

  test('concurrent renewals share one operation and logout wins', () async {
    final MemorySessionRepository store = MemorySessionRepository();
    final SessionService session = SessionService(
      store,
      MemoryAppPreferencesRepository(),
    );
    await session.replace(const SessionTokens('old-access', 'old-refresh'));
    final Completer<SessionTokens> response = Completer<SessionTokens>();
    int calls = 0;
    Future<SessionTokens> renew(String token) {
      calls++;
      return response.future;
    }

    final Future<bool> first = session.renew(renew);
    final Future<bool> second = session.renew(renew);
    await session.clear();
    response.complete(const SessionTokens('new-access', 'new-refresh'));
    expect(await first, isFalse);
    expect(await second, isFalse);
    expect(calls, 1);
    expect(await store.read(), isNull);
    expect(session.state, SessionState.signedOut);
    session.dispose();
  });
}
