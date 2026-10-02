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

  Future<void> initialize(List<Locale> deviceLocales) async {
    locale.value = resolveLocale(await preferences.locale(), deviceLocales);
    await session.restore();
  }

  Future<void> selectLocale(
    Locale? selected,
    List<Locale> deviceLocales,
  ) async {
    if (selected != null && !supportedLocales.contains(selected)) {
      throw ArgumentError('Unsupported interface locale.');
    }
    await preferences.setLocale(selected?.toLanguageTag());
    locale.value = resolveLocale(selected?.toLanguageTag(), deviceLocales);
  }

  void dispose() {
    _disposeResources();
    session.dispose();
    locale.dispose();
  }
}
