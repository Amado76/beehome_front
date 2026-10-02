import 'package:beehome/app/services/app_services.dart';
import 'package:beehome/app/view_models/app_view_model.dart';
import 'package:beehome/app/views/beehome_app.dart';
import 'package:beehome/app/views/splash_view.dart';
import 'package:beehome/design_system/theme/app_theme.dart';
import 'package:beehome/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final String family in [
      'PlusJakartaSans',
      'CourierPrime',
      'Fredoka',
    ]) {
      final FontLoader loader = FontLoader(family)
        ..addFont(rootBundle.load('assets/fonts/$family/$family.ttf'));
      await loader.load();
    }
    final FontLoader journal = FontLoader(
      'SpaceMono',
    )..addFont(rootBundle.load('assets/fonts/SpaceMono/SpaceMono-Regular.ttf'));
    await journal.load();
  });

  for (final (String, String) translation in [
    ('pt', 'Preparando seus cadernos...'),
    ('en', 'Preparing your notebooks...'),
    ('es', 'Preparando tus cuadernos...'),
    ('et', 'Valmistame sinu märkmikke ette...'),
  ]) {
    testWidgets('splash localizes its loading phrase in ${translation.$1}', (
      WidgetTester tester,
    ) async {
      final DelayedSessionRepository repository = DelayedSessionRepository();
      final AppServices app = services(repository);
      await app.preferences.setLocale(translation.$1);
      final AppViewModel viewModel = viewModelFor(app);
      await tester.pumpWidget(BeeHomeApp(viewModel: viewModel));
      await tester.pump();
      expect(find.text(translation.$2), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byKey(const ValueKey('splash-progress')), findsOneWidget);
      repository.restored.complete(null);
      await tester.pumpAndSettle();
      expect(find.byType(SplashView), findsNothing);
      await tester.pumpWidget(const SizedBox());
      app.dispose();
    });
  }

  testWidgets('loading phrases change and stop when startup completes', (
    WidgetTester tester,
  ) async {
    final DelayedSessionRepository repository = DelayedSessionRepository();
    final AppServices app = services(repository);
    final AppViewModel viewModel = viewModelFor(app);
    await tester.pumpWidget(BeeHomeApp(viewModel: viewModel));
    await tester.pump(const Duration(milliseconds: 1800));
    expect(viewModel.splashPhraseIndex, isNot(0));
    final int second = viewModel.splashPhraseIndex;
    await tester.pump(const Duration(milliseconds: 1800));
    expect(viewModel.splashPhraseIndex, isNot(second));
    repository.restored.complete(null);
    await tester.pumpAndSettle();
    final int last = viewModel.splashPhraseIndex;
    await tester.pump(const Duration(seconds: 4));
    expect(viewModel.splashPhraseIndex, last);
    await tester.pumpWidget(const SizedBox());
    app.dispose();
  });

  for (final Size size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(1024, 800),
    const Size(1280, 800),
    const Size(1440, 900),
    const Size(768, 1024),
    const Size(1024, 600),
  ]) {
    testWidgets('splash fits $size with large text and reduced motion', (
      WidgetTester tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final DelayedSessionRepository repository = DelayedSessionRepository();
      final AppServices app = services(repository);
      final AppViewModel viewModel = viewModelFor(app);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppViewModel.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(
              size: size,
              disableAnimations: true,
              textScaler: TextScaler.linear(1.6),
            ),
            child: SplashView(viewModel: viewModel),
          ),
        ),
      );
      await tester.pump();
      final Transform initial = tester.widget(
        find.byKey(const ValueKey('floating-mascot')),
      );
      await tester.pump(const Duration(milliseconds: 600));
      final Transform later = tester.widget(
        find.byKey(const ValueKey('floating-mascot')),
      );
      expect(later.transform, initial.transform);
      expect(tester.takeException(), isNull);
      repository.restored.complete(null);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      app.dispose();
    });
  }
}
