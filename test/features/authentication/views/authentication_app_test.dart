import 'package:beehome/app/services/app_services.dart';
import 'package:beehome/app/view_models/app_view_model.dart';
import 'package:beehome/app/views/beehome_app.dart';
import 'package:beehome/core/auth/models/session_tokens.dart';
import 'package:beehome/core/auth/repos/local_session_repository.dart';
import 'package:beehome/core/auth/services/session_service.dart';
import 'package:beehome/core/network/models/api_error.dart';
import 'package:beehome/core/preferences/repos/local_app_preferences_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/fake_accounts.dart';

void main() {
  testWidgets(
    'login opens workspace, change password returns to login, and failed logout is explained',
    (WidgetTester tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final FakeAccounts accounts = FakeAccounts();
      final MemoryAppPreferencesRepository preferences =
          MemoryAppPreferencesRepository();
      final SessionService session = SessionService(
        MemorySessionRepository(),
        preferences,
        verifyCurrentUser: accounts.currentUser,
      );
      final AppServices services = AppServices(
        session: session,
        preferences: preferences,
        disposeResources: () {},
      );
      final AppViewModel model = AppViewModel(
        services: services,
        deviceLocales: () => [const Locale('en')],
        authenticationRepository: accounts,
      );
      addTearDown(() {
        model.dispose();
        services.dispose();
      });
      await model.initialize();
      await tester.pumpWidget(BeeHomeApp(viewModel: model));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('auth-email')),
        'ana@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('auth-password')),
        'password',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('auth-submit')));
      await tester.tap(find.byKey(const ValueKey('auth-submit')));
      await tester.pumpAndSettle();
      expect(model.authentication.validation, isEmpty);
      expect(model.authentication.failure, isNull);
      expect(accounts.calls, 1);
      expect(session.state, SessionState.signedIn);
      expect(find.text('Your workspace'), findsOneWidget);
      expect(session.user?.name, 'Ana');
      await tester.tap(find.text('Change password'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('auth-currentPassword')),
        'password',
      );
      await tester.enterText(
        find.byKey(const ValueKey('auth-newPassword')),
        'NewPass123!',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('auth-submit')));
      await tester.tap(find.byKey(const ValueKey('auth-submit')));
      await tester.pumpAndSettle();
      expect(
        find.text('Password changed. Sign in again with your new password.'),
        findsOneWidget,
      );
      await tester.enterText(
        find.byKey(const ValueKey('auth-password')),
        'NewPass123!',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('auth-submit')));
      await tester.tap(find.byKey(const ValueKey('auth-submit')));
      await tester.pumpAndSettle();
      accounts.error = const ApiError(kind: ApiFailure.connection);
      await tester.tap(find.text('Sign out on this device'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Server session revocation could not be confirmed'),
        findsOneWidget,
      );
      expect(session.tokens, isNull);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'reset route clears stored session without restoring the current user',
    (WidgetTester tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final FakeAccounts accounts = FakeAccounts();
      final MemorySessionRepository store = MemorySessionRepository();
      await store.write(const SessionTokens('access', 'refresh'));
      final MemoryAppPreferencesRepository preferences =
          MemoryAppPreferencesRepository();
      final SessionService session = SessionService(
        store,
        preferences,
        verifyCurrentUser: () async =>
            throw StateError('Reset must not restore the previous session.'),
      );
      final AppServices services = AppServices(
        session: session,
        preferences: preferences,
        disposeResources: () {},
      );
      final AppViewModel model = AppViewModel(
        services: services,
        deviceLocales: () => [const Locale('en')],
        authenticationRepository: accounts,
        resetLink: true,
        resetToken: 'secret',
      );
      addTearDown(() {
        model.dispose();
        services.dispose();
      });
      await model.initialize();
      await tester.pumpWidget(BeeHomeApp(viewModel: model));
      await tester.pumpAndSettle();
      expect(
        find.text('Choose a new password for your account.'),
        findsOneWidget,
      );
      expect(session.state, SessionState.signedOut);
      expect(await store.read(), isNull);
      await tester.enterText(
        find.byKey(const ValueKey('auth-newPassword')),
        'NewPass123!',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('auth-submit')));
      await tester.tap(find.byKey(const ValueKey('auth-submit')));
      await tester.pumpAndSettle();
      expect(
        find.text('Password reset. Sign in with your new password.'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );
}
