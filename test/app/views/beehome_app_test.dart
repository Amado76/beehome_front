import 'package:beehome/app/services/app_services.dart';
import 'package:beehome/app/views/beehome_app.dart';
import 'package:beehome/app/views/splash_view.dart';
import 'package:beehome/core/auth/repos/local_session_repository.dart';
import 'package:beehome/core/auth/models/session_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/app_test_support.dart';

void main() {
  setUp(() {
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(binding.platformDispatcher.clearAccessibilityFeaturesTestValue);
  });
  testWidgets('language selector persists override and returns to device', (
    WidgetTester tester,
  ) async {
    final AppServices app = services(MemorySessionRepository());
    await tester.pumpWidget(BeeHomeApp(viewModel: viewModelFor(app)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('language-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spanish').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Tu rincón de estudios y rutina familiar'),
      findsOneWidget,
    );
    expect(await app.preferences.locale(), 'es');
    expect(app.backendLanguage, 'es');
    await tester.tap(find.byKey(const ValueKey('language-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usar idioma del dispositivo').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Your cozy corner for studies and family routines'),
      findsOneWidget,
    );
    expect(await app.preferences.locale(), isNull);
    await tester.pumpWidget(const SizedBox());
    app.dispose();
  });

  testWidgets('language save failure shows a localized recoverable message', (
    WidgetTester tester,
  ) async {
    final FailingSavePreferences preferences = FailingSavePreferences();
    final AppServices app = services(
      MemorySessionRepository(),
      preferencesRepository: preferences,
    );
    await tester.pumpWidget(BeeHomeApp(viewModel: viewModelFor(app)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('language-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spanish').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Your cozy corner for studies and family routines'),
      findsOneWidget,
    );
    expect(find.textContaining('Could not save your language'), findsOneWidget);
    expect(find.textContaining('private storage'), findsNothing);
    preferences.fail = false;
    await tester.tap(find.byKey(const ValueKey('language-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spanish').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Tu rincón de estudios y rutina familiar'),
      findsOneWidget,
    );
    expect(find.textContaining('Could not save your language'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    app.dispose();
  });

  testWidgets('loading resolves to the authentication form', (
    WidgetTester tester,
  ) async {
    final DelayedSessionRepository store = DelayedSessionRepository();
    final AppServices app = services(store);
    await tester.pumpWidget(BeeHomeApp(viewModel: viewModelFor(app)));
    expect(find.byType(SplashView), findsOneWidget);
    store.restored.complete(null);
    await tester.pumpAndSettle();
    expect(
      find.text('Your cozy corner for studies and family routines'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
    app.dispose();
  });

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
    expect(
      find.text('Your cozy corner for studies and family routines'),
      findsOneWidget,
    );
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
    expect(
      find.text('Your cozy corner for studies and family routines'),
      findsOneWidget,
    );
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
    expect(
      find.text('Your cozy corner for studies and family routines'),
      findsOneWidget,
    );
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
      final MemorySessionRepository store = MemorySessionRepository();
      await store.write(const SessionTokens('access', 'refresh'));
      final AppServices app = services(store);
      await tester.pumpWidget(BeeHomeApp(viewModel: viewModelFor(app)));
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey(layout.$2)), findsOneWidget);
      final Finder languageSelector = find.byKey(
        const ValueKey('language-selector'),
      );
      if (layout.$1 < 600) {
        expect(languageSelector, findsNothing);
      } else {
        expect(languageSelector, findsOneWidget);
        expect(tester.getTopRight(languageSelector).dy, lessThan(80));
      }
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
      expect(
        find.text('Sinu hubane õpingute ja pere argipäeva paik'),
        findsOneWidget,
      );
      expect(app.backendLanguage, 'en');
      await app.selectLocale(const Locale('pt', 'BR'), [const Locale('en')]);
      await tester.pumpAndSettle();
      expect(
        find.text('Seu cantinho de estudos e rotina familiar'),
        findsOneWidget,
      );
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
