import 'package:beehome/core/auth/repos/local_session_repository.dart';
import 'package:beehome/core/auth/services/session_service.dart';
import 'package:beehome/core/preferences/repos/local_app_preferences_repository.dart';
import 'package:beehome/design_system/theme/app_theme.dart';
import 'package:beehome/features/authentication/view_models/authentication_view_model.dart';
import 'package:beehome/features/authentication/views/authentication_view.dart';
import 'package:beehome/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_accounts.dart';

void main() {
  late AuthenticationViewModel model;
  late SessionService session;
  setUp(() {
    session = SessionService(
      MemorySessionRepository(),
      MemoryAppPreferencesRepository(),
    );
    model = AuthenticationViewModel(
      repository: FakeAccounts(),
      session: session,
    );
  });
  tearDown(() {
    model.dispose();
    session.dispose();
  });

  Future<void> mount(WidgetTester tester, Size size, {double scale = 1}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('pt', 'BR'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (BuildContext context, Widget? child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: true,
            textScaler: TextScaler.linear(scale),
          ),
          child: child!,
        ),
        home: AuthenticationView(viewModel: model),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final Size size in [
    const Size(360, 800),
    const Size(600, 900),
    const Size(1024, 768),
    const Size(1440, 900),
  ]) {
    testWidgets('responsive form at $size has no overflow', (
      WidgetTester tester,
    ) async {
      await mount(tester, size);
      expect(
        find.byKey(
          ValueKey(size.width < 600 ? 'auth-mobile' : 'auth-notebook'),
        ),
        findsOneWidget,
      );
      expect(find.widgetWithText(FilledButton, 'Entrar'), findsOneWidget);
      expect(find.text('Google'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(tester.takeException(), isNull);
      if (size.width >= 1200) {
        final RenderBox canvas = tester.renderObject(
          find.byKey(const ValueKey('auth-notebook')),
        );
        expect(canvas.size.width, closeTo(size.width, 2));
      }
    });
  }
  testWidgets('large text and keyboard keep the form scrollable', (
    WidgetTester tester,
  ) async {
    await mount(tester, const Size(320, 600), scale: 2);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('auth-submit')));
    await tester.tap(find.byKey(const ValueKey('auth-submit')));
    await tester.pumpAndSettle();
    expect(model.validation, isNotEmpty);
    expect(tester.takeException(), isNull);
  });
  testWidgets('registration returns to login with email and cleared password', (
    WidgetTester tester,
  ) async {
    await mount(tester, const Size(390, 844));
    await tester.tap(find.byKey(const ValueKey('auth-tab-register')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('auth-name')), 'Ana');
    await tester.enterText(
      find.byKey(const ValueKey('auth-email')),
      'ana@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('auth-password')),
      'Secure123!',
    );
    await tester.enterText(
      find.byKey(const ValueKey('auth-confirmPassword')),
      'Secure123!',
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('auth-submit')));
    await tester.tap(find.byKey(const ValueKey('auth-submit')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Conta criada!'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('auth-email')))
          .controller!
          .text,
      'ana@example.com',
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('auth-password')))
          .controller!
          .text,
      isEmpty,
    );
    expect(model.mode, AuthMode.login);
  });
}
