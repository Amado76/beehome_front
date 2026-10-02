import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

import '../services/app_services.dart';
import '../../core/auth/services/session_service.dart';

enum AppViewState { loading, signedOut, signedIn, failure }

class AppViewModel extends ChangeNotifier {
  AppViewModel({
    required AppServices services,
    required List<Locale> Function() deviceLocales,
    bool previewSplash = false,
  }) : _services = services,
       _deviceLocales = deviceLocales,
       _previewSplash = previewSplash {
    _services.session.addListener(_onServicesChanged);
    _services.locale.addListener(_onServicesChanged);
  }

  final AppServices _services;
  final List<Locale> Function() _deviceLocales;
  final bool _previewSplash;
  bool _initializing = false;
  bool _startupFailure = false;
  bool _disposed = false;
  bool _localeSaving = false;
  bool _localeSaveFailed = false;
  final Random _random = Random();
  Timer? _splashPhraseTimer;
  int _splashPhraseIndex = 0;

  int get splashPhraseIndex => _splashPhraseIndex;

  static List<Locale> get supportedLocales => AppServices.supportedLocales;

  static Locale resolveLocale(List<Locale>? deviceLocales) =>
      AppServices.resolveLocale(null, deviceLocales ?? []);

  Locale get locale => _services.locale.value;
  Locale? get localeOverride => _services.localeOverride;
  bool get localeSaving => _localeSaving;
  bool get localeSaveFailed => _localeSaveFailed;

  void updateDeviceLocales() {
    if (_disposed) return;
    _services.updateDeviceLocales(_deviceLocales());
  }

  Future<void> selectLocale(Locale? selected) async {
    if (_disposed || _initializing || _localeSaving) return;
    _localeSaving = true;
    _localeSaveFailed = false;
    _onServicesChanged();
    try {
      await _services.selectLocale(selected, _deviceLocales());
    } catch (_) {
      _localeSaveFailed = true;
    } finally {
      _localeSaving = false;
      _onServicesChanged();
    }
  }

  AppViewState get state {
    if (_previewSplash) return AppViewState.loading;
    if (_startupFailure) return AppViewState.failure;
    if (_initializing) return AppViewState.loading;
    return switch (_services.session.state) {
      SessionState.loading => AppViewState.loading,
      SessionState.signedOut => AppViewState.signedOut,
      SessionState.signedIn => AppViewState.signedIn,
      SessionState.failure => AppViewState.failure,
    };
  }

  Future<void> initialize() async {
    if (_disposed || _initializing) return;
    _initializing = true;
    _startupFailure = false;
    _onServicesChanged();
    try {
      await _services.initialize(_deviceLocales());
    } catch (_) {
      _startupFailure = true;
    } finally {
      _initializing = false;
      _onServicesChanged();
    }
  }

  Future<void> signOut() async {
    if (_disposed) return;
    try {
      await _services.session.clear();
    } catch (_) {
      // SessionService exposes persistence failures through its state.
    }
  }

  void _onServicesChanged() {
    if (_disposed) return;
    if (state == AppViewState.loading) {
      _splashPhraseTimer ??= Timer.periodic(
        const Duration(milliseconds: 1800),
        (_) {
          // Pick another phrase without an immediate repeat.
          final int next = _random.nextInt(4);
          _splashPhraseIndex = next >= _splashPhraseIndex ? next + 1 : next;
          notifyListeners();
        },
      );
    } else {
      _splashPhraseTimer?.cancel();
      _splashPhraseTimer = null;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _splashPhraseTimer?.cancel();
    _services.session.removeListener(_onServicesChanged);
    _services.locale.removeListener(_onServicesChanged);
    super.dispose();
  }
}
