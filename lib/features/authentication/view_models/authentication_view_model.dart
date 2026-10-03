import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/models/session_tokens.dart';
import '../../../core/auth/repos/remote_authentication_repository.dart';
import '../../../core/auth/services/session_service.dart';
import '../../../core/network/models/api_error.dart';

enum AuthMode { login, register, forgotPassword, resetPassword, changePassword }

enum AuthFailure {
  currentPassword,
  forbidden,
  sessionExpired,
  credentials,
  duplicateEmail,
  invalidReset,
  rateLimited,
  network,
  unknown,
  uncertain,
  uncertainPasswordChange,
  storage,
}

enum AuthNotice {
  registered,
  recoveryRequested,
  passwordReset,
  passwordChanged,
  signedOut,
  localSignOut,
}

enum AuthValidation {
  required,
  email,
  nameLength,
  passwordLength,
  passwordPolicy,
  passwordMismatch,
}

class AuthenticationViewModel extends ChangeNotifier {
  AuthenticationViewModel({
    required UserAuthenticationRepository repository,
    required SessionService session,
    String? resetToken,
    bool resetLink = false,
    this.allowRememberDevice = !kIsWeb,
  }) : _repository = repository,
       _session = session,
       _resetToken = resetToken,
       _mode = resetLink ? AuthMode.resetPassword : AuthMode.login {
    if (resetLink && !hasResetToken) failure = AuthFailure.invalidReset;
  }

  final UserAuthenticationRepository _repository;
  final SessionService _session;
  final bool allowRememberDevice;
  String? _resetToken;
  AuthMode _mode;
  AuthMode get mode => _mode;
  bool busy = false;
  bool rememberDevice = true;
  bool passwordVisible = false;
  bool providerUnavailable = false;
  String email = '';
  AuthFailure? failure;
  AuthNotice? notice;
  Map<String, AuthValidation> validation = {};
  Map<String, List<String>> fieldErrors = {};
  int cooldownSeconds = 0;
  Timer? _cooldown;
  bool _disposed = false;
  bool get canSubmit => !busy && cooldownSeconds == 0;
  bool get hasResetToken => _resetToken != null && _resetToken!.isNotEmpty;

  void selectMode(AuthMode mode) {
    if (busy) return;
    _mode = mode;
    failure = null;
    notice = null;
    providerUnavailable = false;
    validation = {};
    fieldErrors = {};
    passwordVisible = false;
    _notify();
  }

  void showProviderUnavailable() {
    if (busy) return;
    providerUnavailable = true;
    _notify();
  }

  void setRememberDevice(bool value) {
    rememberDevice = value;
    _notify();
  }

  void togglePasswordVisibility() {
    passwordVisible = !passwordVisible;
    _notify();
  }

  bool isValidNewPassword(String password) =>
      password.length >= 8 &&
      password.length <= 128 &&
      RegExp(r'\p{Lu}', unicode: true).hasMatch(password) &&
      RegExp(r'[0-9]').hasMatch(password) &&
      RegExp(r'[\p{P}\p{S}]', unicode: true).hasMatch(password);

  bool canSubmitForm(String password, String confirmation) =>
      canSubmit &&
      (mode != AuthMode.register ||
          (isValidNewPassword(password) && password == confirmation));

  AuthValidation? confirmationValidation(
    String password,
    String confirmation,
  ) => password == confirmation ? null : AuthValidation.passwordMismatch;

  Map<String, AuthValidation> _validate(
    String name,
    String email,
    String password,
    String currentPassword,
    String confirmPassword,
  ) {
    final Map<String, AuthValidation> result = {};
    if (mode == AuthMode.register) {
      if (name.trim().isEmpty) result['name'] = AuthValidation.required;
      if (name.length > 120) result['name'] = AuthValidation.nameLength;
      final AuthValidation? mismatch = confirmationValidation(
        password,
        confirmPassword,
      );
      if (mismatch != null) result['confirmPassword'] = mismatch;
    }
    if (mode == AuthMode.login ||
        mode == AuthMode.register ||
        mode == AuthMode.forgotPassword) {
      if (email.isEmpty) {
        result['email'] = AuthValidation.required;
      } else if (email.length > 254 ||
          !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
        result['email'] = AuthValidation.email;
      }
    }
    if (mode != AuthMode.forgotPassword) {
      if (mode == AuthMode.login) {
        if (password.trim().isEmpty) {
          result['password'] = AuthValidation.required;
        }
        if (password.length > 128) {
          result['password'] = AuthValidation.passwordLength;
        }
      } else if (!isValidNewPassword(password)) {
        result['password'] = AuthValidation.passwordPolicy;
      }
    }
    if (mode == AuthMode.changePassword) {
      if (currentPassword.trim().isEmpty) {
        result['currentPassword'] = AuthValidation.required;
      }
      if (currentPassword.length > 128) {
        result['currentPassword'] = AuthValidation.passwordLength;
      }
    }
    return result;
  }

  Future<void> submit({
    String name = '',
    required String email,
    required String password,
    String currentPassword = '',
    String confirmPassword = '',
  }) async {
    if (!canSubmit || _disposed) return;
    this.email = email.trim();
    failure = null;
    notice = null;
    providerUnavailable = false;
    fieldErrors = {};
    validation = _validate(
      name,
      this.email,
      password,
      currentPassword,
      confirmPassword,
    );
    if (validation.isNotEmpty) {
      _notify();
      return;
    }
    if (mode == AuthMode.resetPassword && !hasResetToken) {
      failure = AuthFailure.invalidReset;
      _notify();
      return;
    }
    final AuthMode submittedMode = mode;
    final int generation = _session.generation;
    busy = true;
    _notify();
    try {
      switch (submittedMode) {
        case AuthMode.login:
          final SessionTokens tokens = await _repository.login(
            this.email,
            password,
          );
          if (_disposed || generation != _session.generation) return;
          try {
            await _session.replace(
              tokens,
              persist: allowRememberDevice && rememberDevice,
            );
          } catch (_) {
            if (_session.tokens == null) await _session.clear();
            rethrow;
          }
        case AuthMode.register:
          await _repository.register(name, this.email, password);
          if (_disposed) return;
          _mode = AuthMode.login;
          notice = AuthNotice.registered;
        case AuthMode.forgotPassword:
          await _repository.forgotPassword(this.email);
          if (_disposed) return;
          notice = AuthNotice.recoveryRequested;
        case AuthMode.resetPassword:
          await _repository.resetPassword(_resetToken!, password);
          if (_disposed) return;
          _resetToken = null;
          await _session.clear();
          _mode = AuthMode.login;
          notice = AuthNotice.passwordReset;
        case AuthMode.changePassword:
          await _repository.changePassword(currentPassword, password);
          if (_disposed || generation != _session.generation) return;
          await _session.clear();
          _mode = AuthMode.login;
          notice = AuthNotice.passwordChanged;
      }
      passwordVisible = false;
    } on ApiError catch (error) {
      if (_disposed ||
          (submittedMode == AuthMode.changePassword &&
              generation != _session.generation)) {
        return;
      }
      fieldErrors = error.fieldErrors;
      failure = switch (error.code) {
        'INVALID_CREDENTIALS' => AuthFailure.credentials,
        'INVALID_CURRENT_PASSWORD' => AuthFailure.currentPassword,
        'FORBIDDEN' => AuthFailure.forbidden,
        'UNAUTHENTICATED' => AuthFailure.sessionExpired,
        'EMAIL_ALREADY_REGISTERED' => AuthFailure.duplicateEmail,
        'INVALID_RESET_TOKEN' ||
        'EXPIRED_RESET_TOKEN' => AuthFailure.invalidReset,
        _ when error.status == 429 => AuthFailure.rateLimited,
        _ when error.uncertainMutation => AuthFailure.uncertain,
        _
            when error.kind == ApiFailure.connection ||
                error.kind == ApiFailure.timeout =>
          AuthFailure.network,
        _ => AuthFailure.unknown,
      };
      if (error.status == 429) _startCooldown(error.retryAfter);
      if (submittedMode == AuthMode.changePassword &&
          (error.code == 'UNAUTHENTICATED' || error.uncertainMutation)) {
        await _endSessionAfterFailure(
          error.uncertainMutation
              ? AuthFailure.uncertainPasswordChange
              : AuthFailure.sessionExpired,
        );
      }
    } catch (_) {
      failure = AuthFailure.storage;
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> _endSessionAfterFailure(AuthFailure reason) async {
    failure = reason;
    try {
      await _session.clear();
    } catch (_) {
      failure = AuthFailure.storage;
    }
    _mode = AuthMode.login;
  }

  void _startCooldown(String? retryAfter) {
    final int? seconds = int.tryParse(retryAfter ?? '');
    DateTime? date;
    if (seconds == null && retryAfter != null) {
      try {
        date = DateFormat(
          'EEE, dd MMM yyyy HH:mm:ss',
          'en',
        ).parseUtc(retryAfter.replaceFirst(RegExp(r' GMT$'), ''));
      } catch (_) {
        /* Use the contract default when the header is malformed. */
      }
    }
    cooldownSeconds =
        (seconds ?? date?.difference(DateTime.now().toUtc()).inSeconds ?? 60)
            .clamp(1, 86400);
    _cooldown?.cancel();
    _cooldown = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      cooldownSeconds--;
      if (cooldownSeconds == 0) timer.cancel();
      _notify();
    });
  }

  Future<void> signOut() async {
    if (busy || _disposed) return;
    busy = true;
    _notify();
    final SessionTokens? tokens = _session.tokens;
    final int generation = _session.generation;
    bool revoked = tokens == null;
    try {
      if (tokens != null) await _revokeSession(tokens, generation);
      revoked = true;
    } catch (_) {
      revoked = false;
    } finally {
      if (generation == _session.generation) {
        try {
          await _session.clear();
          _mode = AuthMode.login;
          notice = revoked ? AuthNotice.signedOut : AuthNotice.localSignOut;
        } catch (_) {
          failure = AuthFailure.storage;
        }
      }
      busy = false;
      _notify();
    }
  }

  Future<void> _revokeSession(SessionTokens tokens, int generation) async {
    try {
      await _repository.logout(tokens.refreshToken);
    } on ApiError catch (error) {
      // Only an explicit authentication rejection permits a logout retry.
      if (error.status != 401 || generation != _session.generation) rethrow;
      final bool renewed = await _session.renew(_repository.refresh);
      if (!renewed && _session.state == SessionState.signedOut) {
        // Renewal failure already cleared local credentials.
        _mode = AuthMode.login;
        notice = AuthNotice.localSignOut;
      }
      if (!renewed || generation != _session.generation) rethrow;
      await _repository.logout(_session.tokens!.refreshToken);
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _resetToken = null;
    _cooldown?.cancel();
    super.dispose();
  }
}
