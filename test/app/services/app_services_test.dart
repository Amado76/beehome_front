import 'package:beehome/app/services/app_services.dart';
import 'package:beehome/core/auth/repos/local_session_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/app_test_support.dart';

void main() {
  test('device changes apply only without an explicit override', () async {
    final AppServices app = services(MemorySessionRepository());
    addTearDown(app.dispose);
    await app.initialize([const Locale('en')]);
    expect(await app.preferences.locale(), isNull);
    app.updateDeviceLocales([const Locale('et', 'EE')]);
    expect(app.locale.value, const Locale('et'));
    expect(app.backendLanguage, 'en');
    await app.selectLocale(const Locale('pt', 'BR'), [const Locale('et')]);
    expect(await app.preferences.locale(), 'pt-BR');
    app.updateDeviceLocales([const Locale('es')]);
    expect(app.locale.value, const Locale('pt', 'BR'));
    await app.selectLocale(null, [const Locale('es')]);
    expect(app.locale.value, const Locale('es'));
    expect(app.localeOverride, isNull);
    expect(await app.preferences.locale(), isNull);
  });

  test('selection updates immediately and rolls back a failed save', () async {
    final DelayedSavePreferences preferences = DelayedSavePreferences();
    final AppServices app = services(
      MemorySessionRepository(),
      preferencesRepository: preferences,
    );
    addTearDown(app.dispose);
    await app.initialize([const Locale('en')]);
    final Future<void> saving = app.selectLocale(const Locale('es'), [
      const Locale('en'),
    ]);
    expect(app.locale.value, const Locale('es'));
    expect(app.backendLanguage, 'es');
    final Future<void> failure = expectLater(saving, throwsStateError);
    app.updateDeviceLocales([const Locale('et')]);
    preferences.saved.completeError(StateError('private storage details'));
    await failure;
    expect(app.locale.value, const Locale('et'));
    expect(app.localeOverride, isNull);
  });

  test('regional overrides restore in canonical form', () async {
    final AppServices app = services(MemorySessionRepository());
    addTearDown(app.dispose);
    await app.preferences.setLocale('pt_BR');
    await app.initialize([const Locale('en')]);
    expect(app.localeOverride, const Locale('pt', 'BR'));
    expect(app.backendLanguage, 'pt');
  });

  test(
    'locale resolution uses override, supported device, then Portuguese',
    () {
      expect(
        AppServices.resolveLocale('es', [const Locale('en')]),
        const Locale('es'),
      );
      expect(
        AppServices.resolveLocale(null, [
          const Locale('de'),
          const Locale('et', 'EE'),
        ]),
        const Locale('et'),
      );
      expect(
        AppServices.resolveLocale(null, [const Locale('de')]),
        const Locale('pt', 'BR'),
      );
    },
  );

  test('services dispose the injected API client', () {
    final FakeApiClient api = FakeApiClient();
    final AppServices app = services(
      MemorySessionRepository(),
      disposeResources: api.close,
    );
    expect(api.closed, isFalse);
    app.dispose();
    expect(api.closed, isTrue);
  });
}
