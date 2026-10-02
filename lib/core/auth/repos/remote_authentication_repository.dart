import '../models/session_tokens.dart';
import '../../network/clients/api_client.dart';
import '../../network/models/api_error.dart';

abstract interface class AuthenticationRepository {
  Future<SessionTokens> refresh(String refreshToken);
}

class RemoteAuthenticationRepository implements AuthenticationRepository {
  RemoteAuthenticationRepository(this._api);

  final ApiClient _api;

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
