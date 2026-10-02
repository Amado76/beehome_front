import 'package:beehome/app/services/app_services.dart';
import 'package:beehome/app/view_models/app_view_model.dart';
import 'package:beehome/core/auth/repos/local_session_repository.dart';
import 'package:beehome/core/auth/models/session_tokens.dart';
import 'package:beehome/core/auth/services/session_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/app_test_support.dart';

void main() {
  test(
    'view model recovers from startup preference failure on retry',
    () async {
      final FailingLocalePreferences preferences = FailingLocalePreferences();
      final AppServices app = services(
        MemorySessionRepository(),
        preferencesRepository: preferences,
      );
      final AppViewModel viewModel = AppViewModel(
        services: app,
        deviceLocales: () => [const Locale('en')],
      );
      addTearDown(app.dispose);
      addTearDown(viewModel.dispose);

      await viewModel.initialize();
      expect(viewModel.state, AppViewState.failure);
      preferences.fail = false;
      await viewModel.initialize();
      expect(viewModel.state, AppViewState.signedOut);
      expect(viewModel.locale, const Locale('es'));
    },
  );

  test('disposing view model during startup stops notifications', () async {
    final DelayedLocalePreferences preferences = DelayedLocalePreferences();
    final AppServices app = services(
      MemorySessionRepository(),
      preferencesRepository: preferences,
    );
    final AppViewModel viewModel = AppViewModel(
      services: app,
      deviceLocales: () => [const Locale('en')],
    );
    addTearDown(app.dispose);
    int notifications = 0;
    viewModel.addListener(() => notifications++);
    final Future<void> startup = viewModel.initialize();
    expect(viewModel.state, AppViewState.loading);
    final int beforeDispose = notifications;
    viewModel.dispose();
    preferences.restored.complete('es');
    await startup;
    await app.session.replace(const SessionTokens('access', 'refresh'));
    expect(notifications, beforeDispose);
    expect(app.session.state, SessionState.signedIn);
  });
}
