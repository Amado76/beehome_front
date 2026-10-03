import 'package:beehome/core/auth/repos/remote_authentication_repository.dart';
import 'package:beehome/core/auth/models/session_tokens.dart';
import 'package:beehome/core/auth/models/session_user.dart';
import 'package:beehome/core/network/clients/api_client.dart';
import 'package:beehome/core/network/models/api_error.dart';
import 'package:flutter_test/flutter_test.dart';

class RecordingApi implements ApiClient {
  String? path;
  String? method;
  Object? data;
  bool? protected;
  Object? response;
  @override
  Future<Object?> request(
    String path, {
    String method = 'GET',
    Object? data,
    Map<String, Object?>? queryParameters,
    bool protected = true,
  }) async {
    this.path = path;
    this.method = method;
    this.data = data;
    this.protected = protected;
    return response;
  }

  @override
  void close() {}
}

void main() {
  late RecordingApi api;
  late RemoteAuthenticationRepository repository;
  setUp(() {
    api = RecordingApi();
    repository = RemoteAuthenticationRepository(api);
  });
  test('login submits exact password publicly and decodes the pair', () async {
    api.response = {
      'accessToken': 'access',
      'refreshToken': 'refresh',
      'tokenType': 'Bearer',
      'expiresIn': 900,
    };
    final SessionTokens tokens = await repository.login(
      'ana@example.com',
      ' password ',
    );
    expect(api.path, '/api/auth/login');
    expect(api.method, 'POST');
    expect(api.protected, isFalse);
    expect(api.data, {'email': 'ana@example.com', 'password': ' password '});
    expect(tokens.accessToken, 'access');
  });
  test('current user uses only the protected documented endpoint', () async {
    api.response = {'id': 'id', 'name': 'Ana', 'email': 'ana@example.com'};
    final SessionUser user = await repository.currentUser();
    expect(api.path, '/api/users/me');
    expect(api.method, 'GET');
    expect(api.protected, isTrue);
    expect(user.name, 'Ana');
  });
  test('password operations and logout send exact documented fields', () async {
    await repository.register('Ana', 'ana@example.com', ' Secure123! ');
    expect(api.path, '/api/auth/register');
    expect(api.data, {
      'name': 'Ana',
      'email': 'ana@example.com',
      'password': ' Secure123! ',
    });
    expect(api.protected, isFalse);
    await repository.forgotPassword('ana@example.com');
    expect(api.path, '/api/auth/forgot-password');
    expect(api.data, {'email': 'ana@example.com'});
    expect(api.protected, isFalse);
    await repository.resetPassword('secret', ' NewPass123! ');
    expect(api.path, '/api/auth/reset-password');
    expect(api.data, {'token': 'secret', 'newPassword': ' NewPass123! '});
    expect(api.protected, isFalse);
    await repository.changePassword(' OldPass123! ', ' NewPass123! ');
    expect(api.path, '/api/auth/change-password');
    expect(api.data, {
      'currentPassword': ' OldPass123! ',
      'newPassword': ' NewPass123! ',
    });
    expect(api.protected, isTrue);
    api.response = null;
    await repository.logout('refresh');
    expect(api.path, '/api/auth/logout');
    expect(api.data, {'refreshToken': 'refresh'});
    expect(api.protected, isTrue);
  });
  test('malformed token response remains an uncertain mutation', () async {
    api.response = {};
    await expectLater(
      repository.login('ana@example.com', 'password'),
      throwsA(
        isA<ApiError>().having(
          (ApiError error) => error.uncertainMutation,
          'uncertain',
          true,
        ),
      ),
    );
  });
}
