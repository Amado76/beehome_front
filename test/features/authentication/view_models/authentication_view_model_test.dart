import 'dart:async';

import 'package:beehome/core/auth/models/session_tokens.dart';
import 'package:beehome/core/auth/repos/local_session_repository.dart';
import 'package:beehome/core/auth/services/session_service.dart';
import 'package:beehome/core/network/models/api_error.dart';
import 'package:beehome/core/preferences/repos/local_app_preferences_repository.dart';
import 'package:beehome/features/authentication/view_models/authentication_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/fake_accounts.dart';

void main() {
  late FakeAccounts accounts;
  late SessionService session;
  late MemorySessionRepository store;
  late AuthenticationViewModel model;
  setUp(() async {
    accounts = FakeAccounts();
    store = MemorySessionRepository();
    session = SessionService(
      store,
      MemoryAppPreferencesRepository(),
      verifyCurrentUser: accounts.currentUser,
    );
    await session.restore();
    model = AuthenticationViewModel(repository: accounts, session: session);
  });
  tearDown(() {
    model.dispose();
    session.dispose();
  });

  test(
    'registration returns to login, prefilled, without signing in',
    () async {
      model.selectMode(AuthMode.register);
      await model.submit(
        name: 'Ana',
        email: 'ana@example.com',
        password: ' Secure123! ',
        confirmPassword: ' Secure123! ',
      );
      expect(model.mode, AuthMode.login);
      expect(model.email, 'ana@example.com');
      expect(model.notice, AuthNotice.registered);
      expect(session.state, SessionState.signedOut);
      expect(accounts.password, ' Secure123! ');
    },
  );
  test(
    'login validates current user and can keep tokens only in memory',
    () async {
      model.setRememberDevice(false);
      await model.submit(email: 'ana@example.com', password: ' password ');
      expect(session.state, SessionState.signedIn);
      expect(session.user?.name, 'Ana');
      expect(await store.read(), isNull);
      expect(accounts.password, ' password ');
    },
  );
  test(
    'invalid credentials stay generic and do not create a session',
    () async {
      accounts.error = const ApiError(
        kind: ApiFailure.http,
        status: 401,
        code: 'INVALID_CREDENTIALS',
      );
      await model.submit(email: 'ana@example.com', password: 'wrong');
      expect(model.failure, AuthFailure.credentials);
      expect(session.tokens, isNull);
    },
  );
  test(
    'recovery has neutral confirmation and rate limit prevents resubmission',
    () async {
      model.selectMode(AuthMode.forgotPassword);
      await model.submit(email: 'missing@example.com', password: '');
      expect(model.notice, AuthNotice.recoveryRequested);
      accounts.error = const ApiError(
        kind: ApiFailure.http,
        status: 429,
        code: 'RATE_LIMITED',
        retryAfter: '60',
      );
      await model.submit(email: 'missing@example.com', password: '');
      expect(model.failure, AuthFailure.rateLimited);
      final int count = accounts.calls;
      await model.submit(email: 'missing@example.com', password: '');
      expect(accounts.calls, count);
      expect(model.canSubmit, isFalse);
    },
  );
  test('late login cannot replace a newer sign-out', () async {
    accounts.pendingLogin = Completer<SessionTokens>();
    final Future<void> login = model.submit(
      email: 'ana@example.com',
      password: 'password',
    );
    await session.clear();
    accounts.pendingLogin!.complete(const SessionTokens('access', 'refresh'));
    await login;
    expect(session.state, SessionState.signedOut);
    expect(session.tokens, isNull);
  });
  test(
    'registration rejects mismatched confirmation before calling the API',
    () async {
      model.selectMode(AuthMode.register);
      await model.submit(
        name: 'Ana',
        email: 'ana@example.com',
        password: 'Secure123!',
        confirmPassword: 'Different123!',
      );
      expect(
        model.validation['confirmPassword'],
        AuthValidation.passwordMismatch,
      );
      expect(accounts.calls, 0);
      expect(model.canSubmitForm('Secure123!', 'Different123!'), isFalse);
      expect(model.canSubmitForm('Secure123!', 'Secure123!'), isTrue);
    },
  );

  test(
    'expired password-change session returns to login and clears credentials',
    () async {
      await session.replace(const SessionTokens('access', 'refresh'));
      model.selectMode(AuthMode.changePassword);
      accounts.error = const ApiError(
        kind: ApiFailure.http,
        status: 401,
        code: 'UNAUTHENTICATED',
      );
      await model.submit(
        email: '',
        password: 'Secure123!',
        currentPassword: 'old',
      );
      expect(model.failure, AuthFailure.sessionExpired);
      expect(model.mode, AuthMode.login);
      expect(session.tokens, isNull);
      expect(await store.read(), isNull);
    },
  );

  test('password policy is enforced without trimming', () async {
    model.selectMode(AuthMode.register);
    await model.submit(
      name: 'Ana',
      email: 'ana@example.com',
      password: 'short',
    );
    expect(model.validation['password'], AuthValidation.passwordPolicy);
    expect(accounts.calls, 0);
  });
  test(
    'ambiguous password change clears credentials and never retries',
    () async {
      await session.replace(const SessionTokens('access', 'refresh'));
      model.selectMode(AuthMode.changePassword);
      accounts.error = const ApiError(
        kind: ApiFailure.timeout,
        uncertainMutation: true,
      );
      await model.submit(
        email: '',
        password: 'NewPass123!',
        currentPassword: 'old',
      );
      expect(model.failure, AuthFailure.uncertainPasswordChange);
      expect(session.tokens, isNull);
      expect(accounts.calls, 1);
    },
  );
  test('failed server logout still clears local credentials', () async {
    await session.replace(const SessionTokens('access', 'refresh'));
    accounts.error = const ApiError(kind: ApiFailure.connection);
    await model.signOut();
    expect(session.tokens, isNull);
    expect(model.notice, AuthNotice.localSignOut);
  });
  test(
    'expired access renews once and logs out with the rotated pair',
    () async {
      await session.replace(const SessionTokens('access', 'refresh'));
      final List<String> attempts = [];
      int renewals = 0;
      accounts.onRefresh = (String token) async {
        renewals++;
        expect(token, 'refresh');
        return const SessionTokens('newAccess', 'newRefresh');
      };
      accounts.onLogout = (String token) async {
        attempts.add(token);
        if (attempts.length == 1) {
          throw const ApiError(kind: ApiFailure.http, status: 401);
        }
        expect(session.tokens?.accessToken, 'newAccess');
      };
      await model.signOut();
      expect(attempts, ['refresh', 'newRefresh']);
      expect(renewals, 1);
      expect(session.tokens, isNull);
      expect(await store.read(), isNull);
      expect(model.notice, AuthNotice.signedOut);
    },
  );

  test('a rejected logout retry stops and clears local credentials', () async {
    await session.replace(const SessionTokens('access', 'refresh'));
    int attempts = 0;
    accounts.onLogout = (_) async {
      attempts++;
      throw const ApiError(kind: ApiFailure.http, status: 401);
    };
    await model.signOut();
    expect(attempts, 2);
    expect(session.tokens, isNull);
    expect(model.notice, AuthNotice.localSignOut);
  });

  test(
    'failed renewal reports local sign-out and removes stored tokens',
    () async {
      await session.replace(const SessionTokens('access', 'refresh'));
      accounts.onLogout = (_) async {
        throw const ApiError(kind: ApiFailure.http, status: 401);
      };
      accounts.onRefresh = (_) async {
        throw const ApiError(kind: ApiFailure.connection);
      };
      await model.signOut();
      expect(session.state, SessionState.signedOut);
      expect(await store.read(), isNull);
      expect(model.notice, AuthNotice.localSignOut);
    },
  );

  test('logout renewal cannot clear a newer session', () async {
    await session.replace(const SessionTokens('access', 'refresh'));
    final Completer<SessionTokens> renewal = Completer<SessionTokens>();
    final Completer<void> started = Completer<void>();
    int attempts = 0;
    accounts.onLogout = (_) async {
      attempts++;
      throw const ApiError(kind: ApiFailure.http, status: 401);
    };
    accounts.onRefresh = (_) {
      started.complete();
      return renewal.future;
    };
    final Future<void> logout = model.signOut();
    await started.future;
    await session.replace(const SessionTokens('otherAccess', 'otherRefresh'));
    renewal.complete(const SessionTokens('lateAccess', 'lateRefresh'));
    await logout;
    expect(attempts, 1);
    expect(session.tokens?.accessToken, 'otherAccess');
    expect(model.notice, isNull);
  });

  test('an ambiguous logout is never retried or renewed', () async {
    await session.replace(const SessionTokens('access', 'refresh'));
    int attempts = 0;
    accounts.onLogout = (_) async {
      attempts++;
      throw const ApiError(kind: ApiFailure.timeout, uncertainMutation: true);
    };
    accounts.onRefresh = (_) async => throw StateError('Unexpected renewal');
    await model.signOut();
    expect(attempts, 1);
    expect(session.tokens, isNull);
    expect(model.notice, AuthNotice.localSignOut);
  });

  test('invalid reset links make no request and allow recovery', () async {
    final AuthenticationViewModel reset = AuthenticationViewModel(
      repository: accounts,
      session: session,
      resetLink: true,
    );
    addTearDown(reset.dispose);
    await reset.submit(email: '', password: 'Secure123!');
    expect(reset.failure, AuthFailure.invalidReset);
    expect(accounts.calls, 0);
    reset.selectMode(AuthMode.forgotPassword);
    await reset.submit(email: 'ana@example.com', password: '');
    expect(reset.notice, AuthNotice.recoveryRequested);
  });
  test(
    'successful reset consumes the link and clears the current session',
    () async {
      await session.replace(const SessionTokens('access', 'refresh'));
      final AuthenticationViewModel reset = AuthenticationViewModel(
        repository: accounts,
        session: session,
        resetLink: true,
        resetToken: 'oneTimeToken',
      );
      addTearDown(reset.dispose);
      await reset.submit(email: '', password: 'Secure123!');
      expect(reset.hasResetToken, isFalse);
      expect(reset.mode, AuthMode.login);
      expect(reset.notice, AuthNotice.passwordReset);
      expect(session.tokens, isNull);
      expect(await store.read(), isNull);
    },
  );
  test('successful password change clears every local credential', () async {
    await session.replace(const SessionTokens('access', 'refresh'));
    model.selectMode(AuthMode.changePassword);
    await model.submit(
      email: '',
      password: 'Secure123!',
      currentPassword: 'old',
    );
    expect(model.notice, AuthNotice.passwordChanged);
    expect(session.tokens, isNull);
    expect(await store.read(), isNull);
  });
  test('invalid current password is recoverable without signing out', () async {
    await session.replace(const SessionTokens('access', 'refresh'));
    model.selectMode(AuthMode.changePassword);
    accounts.error = const ApiError(
      kind: ApiFailure.http,
      status: 400,
      code: 'INVALID_CURRENT_PASSWORD',
    );
    await model.submit(
      email: '',
      password: 'Secure123!',
      currentPassword: 'wrong',
    );
    expect(model.failure, AuthFailure.currentPassword);
    expect(session.state, SessionState.signedIn);
  });
  test(
    'backend field messages remain available for localized rendering',
    () async {
      model.selectMode(AuthMode.register);
      accounts.error = const ApiError(
        kind: ApiFailure.http,
        status: 400,
        code: 'VALIDATION_ERROR',
        fieldErrors: {
          'email': ['Informe um e-mail válido.'],
        },
      );
      await model.submit(
        name: 'Ana',
        email: 'ana@example.com',
        password: 'Secure123!',
        confirmPassword: 'Secure123!',
      );
      expect(model.fieldErrors['email'], ['Informe um e-mail válido.']);
    },
  );
}
