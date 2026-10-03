import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/auth/repos/local_session_repository.dart';
import '../../../core/auth/repos/remote_authentication_repository.dart';
import '../../../core/auth/services/session_service.dart';
import '../../../core/config/models/app_config.dart';
import '../../../core/network/clients/api_client.dart';
import '../../../core/network/clients/dio_api_client.dart';
import '../../../core/preferences/repos/local_app_preferences_repository.dart';
import '../../services/app_services.dart';

void registerCoreDependencies(GetIt container, {required AppConfig config}) {
  container.registerSingleton<AppConfig>(config);
  container.registerLazySingleton<SharedPreferencesAsync>(
    SharedPreferencesAsync.new,
  );
  container.registerLazySingleton<AppPreferencesRepository>(
    () => LocalAppPreferencesRepository(container<SharedPreferencesAsync>()),
  );
  container.registerLazySingleton<SessionRepository>(createSessionRepository);
  container.registerLazySingleton<SessionService>(
    () => SessionService(
      container<SessionRepository>(),
      container<AppPreferencesRepository>(),
      verifyCurrentUser: () =>
          container<UserAuthenticationRepository>().currentUser(),
    ),
  );
  container.registerLazySingleton<Dio>(Dio.new);
  container.registerLazySingleton<ApiClient>(
    () => DioApiClient(
      dio: container<Dio>(),
      config: container<AppConfig>(),
      session: container<SessionService>(),
      // Resolve only when a request runs, after AppServices is registered.
      language: () => container<AppServices>().backendLanguage,
      // Public refresh requests cannot trigger another renewal.
      refreshTokens: (String token) =>
          container<AuthenticationRepository>().refresh(token),
    ),
  );
  container.registerLazySingleton<UserAuthenticationRepository>(
    () => RemoteAuthenticationRepository(container<ApiClient>()),
  );
  container.registerLazySingleton<AuthenticationRepository>(
    () => container<UserAuthenticationRepository>(),
  );
}
