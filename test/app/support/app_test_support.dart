import '../../features/authentication/support/fake_accounts.dart';
import 'dart:async';
import 'package:beehome/app/services/app_services.dart';
import 'package:beehome/app/view_models/app_view_model.dart';
import 'package:beehome/core/auth/services/session_service.dart';
import 'package:beehome/core/network/clients/api_client.dart';
import 'package:beehome/core/preferences/repos/local_app_preferences_repository.dart';
import 'package:beehome/core/auth/repos/local_session_repository.dart';
import 'package:beehome/core/auth/models/session_tokens.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class DelayedSessionRepository extends MemorySessionRepository {
  final Completer<SessionTokens?> restored = Completer<SessionTokens?>();
  @override
  Future<SessionTokens?> read() => restored.future;
}

class FailingSessionRepository extends MemorySessionRepository {
  bool fail = true;
  @override
  Future<SessionTokens?> read() async {
    if (fail) throw StateError('private platform details');
    return null;
  }
}

class FailingDeletionSessionRepository extends MemorySessionRepository {
  bool failDeletion = true;
  int deletionAttempts = 0;

  @override
  Future<void> clear() async {
    deletionAttempts++;
    if (failDeletion) throw StateError('private deletion details');
    await super.clear();
  }
}

class FailingLocalePreferences extends MemoryAppPreferencesRepository {
  bool fail = true;

  @override
  Future<String?> locale() async {
    if (fail) throw StateError('private preference details');
    return 'es';
  }
}

class DelayedLocalePreferences extends MemoryAppPreferencesRepository {
  final Completer<String?> restored = Completer<String?>();

  @override
  Future<String?> locale() => restored.future;
}

class DelayedSavePreferences extends MemoryAppPreferencesRepository {
  final Completer<void> saved = Completer<void>();

  @override
  Future<void> setLocale(String? value) async {
    await saved.future;
    await super.setLocale(value);
  }
}

class FailingSavePreferences extends MemoryAppPreferencesRepository {
  bool fail = true;

  @override
  Future<void> setLocale(String? value) async {
    if (fail) throw StateError('private storage details');
    await super.setLocale(value);
  }
}

class FakeApiClient implements ApiClient {
  bool closed = false;

  @override
  Future<Object?> request(
    String path, {
    String method = 'GET',
    Object? data,
    Map<String, Object?>? queryParameters,
    bool protected = true,
  }) async => throw StateError('Unexpected API request: $path');

  @override
  void close() => closed = true;
}

AppServices services(
  SessionRepository store, {
  AppPreferencesRepository? preferencesRepository,
  void Function()? disposeResources,
}) {
  final AppPreferencesRepository preferences =
      preferencesRepository ?? MemoryAppPreferencesRepository();
  return AppServices(
    session: SessionService(store, preferences),
    preferences: preferences,
    disposeResources: disposeResources ?? FakeApiClient().close,
  );
}

AppViewModel viewModelFor(AppServices services) {
  final AppViewModel viewModel = AppViewModel(
    services: services,
    deviceLocales: () => WidgetsBinding.instance.platformDispatcher.locales,
    authenticationRepository: FakeAccounts(),
  );
  addTearDown(viewModel.dispose);
  unawaited(viewModel.initialize());
  return viewModel;
}
