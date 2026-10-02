import 'package:beehome/app/di/modules/app_module.dart';
import 'package:beehome/app/di/modules/core_module.dart';
import 'package:beehome/app/services/app_services.dart';
import 'package:beehome/app/view_models/app_view_model.dart';
import 'package:beehome/core/auth/repos/remote_authentication_repository.dart';
import 'package:beehome/core/auth/services/session_service.dart';
import 'package:beehome/core/config/models/app_config.dart';
import 'package:beehome/core/network/clients/api_client.dart';
import 'package:beehome/core/preferences/repos/local_app_preferences_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GetIt container;

  setUp(() async {
    container = GetIt.asNewInstance();
    registerCoreDependencies(
      container,
      config: AppConfig.parse('https://api.example.com'),
    );
    // Replace platform storage before the application resolves shared services.
    await container.unregister<AppPreferencesRepository>();
    container.registerSingleton<AppPreferencesRepository>(
      MemoryAppPreferencesRepository(),
    );
    registerAppDependencies(
      container,
      deviceLocales: () => [const Locale('en')],
    );
  });

  tearDown(() => container.reset());

  test('shares repositories, session, and API across ViewModel instances', () {
    final AppViewModel first = container<AppViewModel>();
    final AppViewModel second = container<AppViewModel>();
    addTearDown(() {
      first.dispose();
      second.dispose();
    });

    expect(first, isNot(same(second)));
    final AppServices services = container<AppServices>();
    expect(services.session, same(container<SessionService>()));
    expect(services.preferences, same(container<AppPreferencesRepository>()));
    expect(container<ApiClient>(), same(container<ApiClient>()));
    expect(
      container<AuthenticationRepository>(),
      same(container<AuthenticationRepository>()),
    );

    services.locale.value = const Locale('es');
    expect(first.locale, const Locale('es'));
    expect(second.locale, const Locale('es'));
  });

  test(
    'reset disposes resources even when no ViewModel was resolved',
    () async {
      final AppServices services = container<AppServices>();
      final Dio dio = container<Dio>();

      await container.reset();

      expect(container.isRegistered<AppServices>(), isFalse);
      expect(() => services.locale.addListener(() {}), throwsFlutterError);
      expect(() => services.session.addListener(() {}), throwsFlutterError);
      await expectLater(
        dio.get<Object?>('/api/health'),
        throwsA(isA<DioException>()),
      );
    },
  );
}
