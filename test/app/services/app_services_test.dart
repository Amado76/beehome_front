import 'package:beehome/app/services/app_services.dart';
import 'package:beehome/core/auth/repos/local_session_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/app_test_support.dart';

void main() {
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
