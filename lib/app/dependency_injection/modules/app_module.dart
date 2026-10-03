import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../../core/auth/services/session_service.dart';
import '../../../core/auth/repos/remote_authentication_repository.dart';
import '../../../core/auth/platform/reset_link.dart';
import '../../../core/network/clients/api_client.dart';
import '../../../core/preferences/repos/local_app_preferences_repository.dart';
import '../../services/app_services.dart';
import '../../view_models/app_view_model.dart';

void registerAppDependencies(
  GetIt container, {
  required List<Locale> Function() deviceLocales,
  bool previewSplash = false,
}) {
  // AppServices owns the shared session and API client. Register it eagerly so
  // reset always releases these resources, even before a ViewModel is resolved.
  final ApiClient api = container<ApiClient>();
  container.registerSingleton<AppServices>(
    AppServices(
      session: container<SessionService>(),
      preferences: container<AppPreferencesRepository>(),
      disposeResources: api.close,
    ),
    dispose: (AppServices services) => services.dispose(),
  );
  // The widget that resolves a factory owns and disposes its ViewModel.
  final ({bool resetLink, String? token}) reset = consumeResetLink();
  final bool resetLink = reset.resetLink;
  String? resetToken = reset.token;
  container.registerFactory<AppViewModel>(() {
    final String? token = resetToken;
    resetToken = null;
    return AppViewModel(
      services: container<AppServices>(),
      deviceLocales: deviceLocales,
      previewSplash: previewSplash,
      minimumSplashDuration: const Duration(milliseconds: 1500),
      authenticationRepository: container<UserAuthenticationRepository>(),
      resetToken: token,
      resetLink: resetLink,
    );
  });
}
