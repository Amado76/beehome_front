import 'dart:async';
import 'package:beehome/core/auth/models/session_tokens.dart';
import 'package:beehome/core/auth/models/session_user.dart';
import 'package:beehome/core/auth/repos/local_session_repository.dart';
import 'package:beehome/core/auth/services/session_service.dart';
import 'package:beehome/core/network/models/api_error.dart';
import 'package:beehome/core/preferences/repos/local_app_preferences_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'stored tokens require a server-confirmed user and logout wins over restoration',
    () async {
      final MemorySessionRepository store = MemorySessionRepository();
      await store.write(const SessionTokens('access', 'refresh'));
      final Completer<void> requested = Completer<void>();
      final Completer<SessionUser> response = Completer<SessionUser>();
      final SessionService session = SessionService(
        store,
        MemoryAppPreferencesRepository(),
        verifyCurrentUser: () {
          requested.complete();
          return response.future;
        },
      );
      addTearDown(session.dispose);
      final Future<void> restoring = session.restore();
      await requested.future;
      expect(session.state, SessionState.loading);
      expect(session.user, isNull);
      await session.clear();
      response.complete(const SessionUser('id', 'Ana', 'ana@example.com'));
      await restoring;
      expect(session.state, SessionState.signedOut);
      expect(session.tokens, isNull);
      expect(session.user, isNull);
    },
  );
  test('rejected current user clears stored credentials', () async {
    final MemorySessionRepository store = MemorySessionRepository();
    await store.write(const SessionTokens('access', 'refresh'));
    final SessionService session = SessionService(
      store,
      MemoryAppPreferencesRepository(),
      verifyCurrentUser: () async => throw const ApiError(
        kind: ApiFailure.http,
        status: 401,
        code: 'UNAUTHENTICATED',
      ),
    );
    addTearDown(session.dispose);
    await session.restore();
    expect(session.state, SessionState.signedOut);
    expect(await store.read(), isNull);
  });
  test('temporary verification failure permits restoration retry', () async {
    final MemorySessionRepository store = MemorySessionRepository();
    await store.write(const SessionTokens('access', 'refresh'));
    bool failed = true;
    final SessionService session = SessionService(
      store,
      MemoryAppPreferencesRepository(),
      verifyCurrentUser: () async {
        if (failed) throw const ApiError(kind: ApiFailure.connection);
        return const SessionUser('id', 'Ana', 'ana@example.com');
      },
    );
    addTearDown(session.dispose);
    await session.restore();
    expect(session.state, SessionState.failure);
    expect(session.tokens, isNull);
    failed = false;
    await session.restore();
    expect(session.state, SessionState.signedIn);
    expect(session.user?.name, 'Ana');
  });
  test('rotation of an unremembered session never persists tokens', () async {
    final MemorySessionRepository store = MemorySessionRepository();
    final SessionService session = SessionService(
      store,
      MemoryAppPreferencesRepository(),
    );
    addTearDown(session.dispose);
    await session.replace(
      const SessionTokens('access', 'refresh'),
      persist: false,
    );
    await session.renew(
      (String token) async => const SessionTokens('next', 'nextRefresh'),
    );
    expect(session.tokens?.accessToken, 'next');
    expect(await store.read(), isNull);
  });
}
