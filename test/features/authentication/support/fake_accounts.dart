import 'dart:async';
import 'package:beehome/core/auth/models/session_tokens.dart';
import 'package:beehome/core/auth/models/session_user.dart';
import 'package:beehome/core/auth/repos/remote_authentication_repository.dart';
import 'package:beehome/core/network/models/api_error.dart';

class FakeAccounts implements UserAuthenticationRepository {
  ApiError? error;
  String? password;
  int calls = 0;
  Completer<SessionTokens>? pendingLogin;
  Future<void> Function(String)? onLogout;
  Future<SessionTokens> Function(String)? onRefresh;
  @override
  Future<SessionTokens> login(String email, String password) async {
    calls++;
    this.password = password;
    if (error != null) throw error!;
    return pendingLogin == null
        ? const SessionTokens('access', 'refresh')
        : pendingLogin!.future;
  }

  @override
  Future<void> register(String name, String email, String password) async {
    calls++;
    this.password = password;
    if (error != null) throw error!;
  }

  @override
  Future<SessionUser> currentUser() async =>
      const SessionUser('id', 'Ana', 'ana@example.com');
  @override
  Future<void> forgotPassword(String email) async {
    calls++;
    if (error != null) throw error!;
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    calls++;
    if (error != null) throw error!;
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    calls++;
    if (error != null) throw error!;
  }

  @override
  Future<void> logout(String refreshToken) async {
    if (onLogout != null) return onLogout!(refreshToken);
    if (error != null) throw error!;
  }

  @override
  Future<SessionTokens> refresh(String token) async => onRefresh != null
      ? onRefresh!(token)
      : const SessionTokens('next', 'nextRefresh');
}
