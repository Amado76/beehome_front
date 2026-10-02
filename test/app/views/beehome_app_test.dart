import 'package:beehome/app/services/app_services.dart';
import 'package:beehome/app/views/beehome_app.dart';
import 'package:beehome/app/views/splash_view.dart';
import 'package:beehome/core/auth/repos/local_session_repository.dart';
import 'package:beehome/core/auth/models/session_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/app_test_support.dart';

void main() {
  testWidgets(
    'loading resolves to signed out without a fabricated login flow',
    (WidgetTester tester) async {
      final DelayedSessionRepository store = DelayedSessionRepository();
      final AppServices app = services(store);
      await tester.pumpWidget(BeeHomeApp(viewModel: viewModelFor(app)));
      expect(find.byType(SplashView), findsOneWidget);
      store.restored.complete(null);
      await tester.pumpAndSettle();
      expect(find.text('Welcome to BeeHome'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      app.dispose();
    },
  );

  testWidgets('restored session shows workspace and local sign-out', (
    WidgetTester tester,
  ) async {
    final MemorySessionRepository store = MemorySessionRepository();
    await store.write(const SessionTokens('access', 'refresh'));
    final AppServices app = services(store);
    await tester.pumpWidget(BeeHomeApp(viewModel: viewModelFor(app)));
    await tester.pumpAndSettle();
    expect(find.text('Your workspace'), findsOneWidget);
    await tester.tap(find.text('Sign out on this device'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to BeeHome'), findsOneWidget);
    expect(await store.read(), isNull);
    await tester.pumpWidget(const SizedBox());
    app.dispose();
  });

  testWidgets('failed sign-out retries deletion instead of restoring tokens', (
    WidgetTester tester,
  ) async {
    final FailingDeletionSessionRepository store =
        FailingDeletionSessionRepository();
    await store.write(const SessionTokens('access', 'refresh'));
    final AppServices app = services(store);
    await tester.pumpWidget(BeeHomeApp(viewModel: viewModelFor(app)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign out on this device'));
    await tester.pumpAndSettle();
    expect(find.text('Unable to open your session'), findsOneWidget);
    expect(find.textContaining('private deletion'), findsNothing);
    expect(await store.read(), isNotNull);
    expect(app.session.tokens, isNull);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Unable to open your session'), findsOneWidget);
    expect(find.text('Your workspace'), findsNothing);
    expect(store.deletionAttempts, 2);

    store.failDeletion = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to BeeHome'), findsOneWidget);
    expect(await store.read(), isNull);
    expect(store.deletionAttempts, 3);
    await tester.pumpWidget(const SizedBox());
    app.dispose();
  });

  testWidgets('storage error hides internals and offers a working retry', (
    WidgetTester tester,
  ) async {
    final FailingSessionRepository store = FailingSessionRepository();
    final AppServices app = services(store);
    await tester.pumpWidget(BeeHomeApp(viewModel: viewModelFor(app)));
    await tester.pumpAndSettle();
    expect(find.text('Unable to open your session'), findsOneWidget);
    expect(find.textContaining('private platform'), findsNothing);
    store.fail = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to BeeHome'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    app.dispose();
  });

  for (final (double, String) layout in [
    (390, 'mobile-shell'),
    (1024, 'tablet-shell'),
    (1440, 'desktop-shell'),
  ]) {
    testWidgets('${layout.$2} works at ${layout.$1} pixels', (
      WidgetTester tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(layout.$1, 800);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final AppServices app = services(MemorySessionRepository());
      await tester.pumpWidget(BeeHomeApp(viewModel: viewModelFor(app)));
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey(layout.$2)), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      app.dispose();
    });
  }

  testWidgets(
    'saved interface locale controls shell translations and backend language',
    (WidgetTester tester) async {
      final AppServices app = services(MemorySessionRepository());
      await app.preferences.setLocale('et');
      await tester.pumpWidget(BeeHomeApp(viewModel: viewModelFor(app)));
      await tester.pumpAndSettle();
      expect(find.text('Tere tulemast BeeHome’i'), findsOneWidget);
      expect(app.backendLanguage, 'en');
      await app.selectLocale(const Locale('pt', 'BR'), [const Locale('en')]);
      await tester.pumpAndSettle();
      expect(find.text('Boas-vindas ao BeeHome'), findsOneWidget);
      expect(app.backendLanguage, 'pt');
      await tester.pumpWidget(const SizedBox());
      app.dispose();
    },
  );

  testWidgets('invalid configuration displays a diagnostic screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ConfigurationFailureApp());
    await tester.pumpAndSettle();
    expect(find.text('Configuration required'), findsOneWidget);
    expect(find.textContaining('API_ORIGIN'), findsOneWidget);
  });
}
