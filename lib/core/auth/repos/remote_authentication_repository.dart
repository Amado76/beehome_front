import '../models/session_tokens.dart';
import '../models/session_user.dart';
import '../../network/clients/api_client.dart';
import '../../network/models/api_error.dart';

abstract interface class AuthenticationRepository {
  Future<SessionTokens> refresh(String refreshToken);
}

abstract interface class UserAuthenticationRepository
    implements AuthenticationRepository {
  Future<SessionTokens> login(String email, String password);
  Future<void> register(String name, String email, String password);
  Future<SessionUser> currentUser();
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String token, String newPassword);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> logout(String refreshToken);
}

class RemoteAuthenticationRepository implements UserAuthenticationRepository {
  RemoteAuthenticationRepository(this._api);

  final ApiClient _api;

  @override
  Future<SessionTokens> login(String email, String password) async {
    final Object? response = await _api.request(
      '/api/auth/login',
      method: 'POST',
      data: {'email': email, 'password': password},
      protected: false,
    );
    try {
      return SessionTokens.fromJson(response);
    } on FormatException {
      throw const ApiError(
        kind: ApiFailure.invalidResponse,
        uncertainMutation: true,
      );
    }
  }

  @override
  Future<void> register(String name, String email, String password) async {
    await _api.request(
      '/api/auth/register',
      method: 'POST',
      data: {'name': name, 'email': email, 'password': password},
      protected: false,
    );
  }

  @override
  Future<SessionUser> currentUser() async {
    final Object? response = await _api.request('/api/users/me');
    try {
      return SessionUser.fromJson(response);
    } on FormatException {
      throw const ApiError(kind: ApiFailure.invalidResponse);
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _api.request(
      '/api/auth/forgot-password',
      method: 'POST',
      data: {'email': email},
      protected: false,
    );
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    await _api.request(
      '/api/auth/reset-password',
      method: 'POST',
      data: {'token': token, 'newPassword': newPassword},
      protected: false,
    );
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    await _api.request(
      '/api/auth/change-password',
      method: 'POST',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _api.request(
      '/api/auth/logout',
      method: 'POST',
      data: {'refreshToken': refreshToken},
    );
  }

  @override
  Future<SessionTokens> refresh(String refreshToken) async {
    final Object? response = await _api.request(
      '/api/auth/refresh',
      method: 'POST',
      data: {'refreshToken': refreshToken},
      protected: false,
    );
    try {
      return SessionTokens.fromJson(response);
    } on FormatException {
      throw const ApiError(
        kind: ApiFailure.invalidResponse,
        uncertainMutation: true,
      );
    }
  }
}
