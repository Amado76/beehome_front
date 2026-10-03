import 'package:flutter/widgets.dart';

import '../../core/preferences/repos/local_app_preferences_repository.dart';
import '../../core/auth/services/session_service.dart';

class AppServices {
  AppServices({
    required this.session,
    required this.preferences,
    required void Function() disposeResources,
  }) : _disposeResources = disposeResources;

  static const List<Locale> supportedLocales = [
    Locale('pt', 'BR'),
    Locale('en'),
    Locale('es'),
    Locale('et'),
  ];
  final AppPreferencesRepository preferences;
  final SessionService session;
  final void Function() _disposeResources;
  final ValueNotifier<Locale> locale = ValueNotifier(const Locale('pt', 'BR'));
  Locale? _localeOverride;
  List<Locale> _deviceLocales = [];

  Locale? get localeOverride => _localeOverride;

  String get backendLanguage => switch (locale.value.languageCode) {
    'pt' => 'pt',
    'es' => 'es',
    _ => 'en',
  };

  static Locale resolveLocale(String? saved, List<Locale> deviceLocales) {
    final List<Locale> candidates = [
      if (saved != null) Locale(saved.replaceAll('_', '-').split('-').first),
      ...deviceLocales,
    ];
    for (final Locale candidate in candidates) {
      for (final Locale supported in supportedLocales) {
        if (candidate.languageCode == supported.languageCode) return supported;
      }
    }
    return supportedLocales.first;
  }

  Future<void> initialize(
    List<Locale> deviceLocales, {
    bool restoreSession = true,
  }) async {
    _deviceLocales = List.of(deviceLocales);
    final String? saved = await preferences.locale();
    final String? language = saved?.replaceAll('_', '-').split('-').first;
    _localeOverride = null;
    for (final Locale supported in supportedLocales) {
      if (supported.languageCode == language) _localeOverride = supported;
    }
    _resolveCurrentLocale();
    if (restoreSession) {
      await session.restore();
    } else {
      await session.clear();
    }
  }

  void updateDeviceLocales(List<Locale> deviceLocales) {
    _deviceLocales = List.of(deviceLocales);
    _resolveCurrentLocale();
  }

  void _resolveCurrentLocale() {
    locale.value = resolveLocale(
      _localeOverride?.toLanguageTag(),
      _deviceLocales,
    );
  }

  Future<void> selectLocale(
    Locale? selected,
    List<Locale> deviceLocales,
  ) async {
    if (selected != null && !supportedLocales.contains(selected)) {
      throw ArgumentError('Unsupported interface locale.');
    }
    final Locale? previous = _localeOverride;
    _localeOverride = selected;
    updateDeviceLocales(deviceLocales);
    try {
      await preferences.setLocale(selected?.toLanguageTag());
    } catch (_) {
      _localeOverride = previous;
      _resolveCurrentLocale();
      rethrow;
    }
  }

  void dispose() {
    _disposeResources();
    session.dispose();
    locale.dispose();
  }
}
