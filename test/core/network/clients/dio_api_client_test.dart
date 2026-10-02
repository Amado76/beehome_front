import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:beehome/core/auth/services/session_service.dart';
import 'package:beehome/core/config/models/app_config.dart';
import 'package:beehome/core/network/clients/api_client.dart';
import 'package:beehome/core/network/models/api_error.dart';
import 'package:beehome/core/network/clients/dio_api_client.dart';
import 'package:beehome/core/preferences/repos/local_app_preferences_repository.dart';
import 'package:beehome/core/auth/repos/local_session_repository.dart';
import 'package:beehome/core/auth/models/session_tokens.dart';
import 'package:beehome/core/auth/repos/remote_authentication_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.respond);
  final Future<ResponseBody> Function(RequestOptions) respond;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonBody(int status, Object? value, {bool problem = false}) =>
    ResponseBody.fromString(
      jsonEncode(value),
      status,
      headers: {
        Headers.contentTypeHeader: [
          problem ? 'application/problem+json' : 'application/json',
        ],
      },
    );

void main() {
  late SessionService session;
  late ApiClient api;
  late Dio dio;
  late MemorySessionRepository store;
  late MemoryAppPreferencesRepository preferences;
  late String language;

  setUp(() async {
    store = MemorySessionRepository();
    preferences = MemoryAppPreferencesRepository();
    session = SessionService(store, preferences);
    await session.replace(const SessionTokens('old-access', 'old-refresh'));
    dio = Dio();
    language = 'pt';
    api = DioApiClient(
      dio: dio,
      config: AppConfig.parse('https://example.com'),
      session: session,
      language: () => language,
      refreshTokens: (String token) =>
          RemoteAuthenticationRepository(api).refresh(token),
    );
  });
  tearDown(() {
    api.close();
    session.dispose();
  });

  test('protected requests use Bearer; all public routes omit it', () async {
    final FakeAdapter adapter = FakeAdapter(
      (RequestOptions options) async => jsonBody(200, {}),
    );
    dio.httpClientAdapter = adapter;
    await api.request('/api/users/me');
    expect(
      adapter.requests.first.headers['Authorization'],
      'Bearer old-access',
    );
    for (final String path in [
      '/api/auth/login',
      '/api/auth/register',
      '/api/auth/forgot-password',
      '/api/auth/reset-password',
      '/api/auth/refresh',
      '/api/health',
    ]) {
      await api.request(path);
      expect(adapter.requests.last.headers['Accept-Language'], 'pt');
      expect(
        adapter.requests.last.headers.containsKey('Authorization'),
        isFalse,
      );
    }
    expect(adapter.requests.last.headers['Accept-Language'], 'pt');
  });

  test('each request uses the current backend language', () async {
    final FakeAdapter adapter = FakeAdapter(
      (RequestOptions options) async => jsonBody(200, {}),
    );
    dio.httpClientAdapter = adapter;
    await api.request('/api/users/me');
    expect(adapter.requests.last.headers['Accept-Language'], 'pt');
    language = 'es';
    await api.request('/api/health');
    expect(adapter.requests.last.headers['Accept-Language'], 'es');
    language = 'en';
    await api.request('/api/users/me');
    expect(adapter.requests.last.headers['Accept-Language'], 'en');
  });

  test('204 and empty successes do not require JSON', () async {
    dio.httpClientAdapter = FakeAdapter(
      (RequestOptions options) async => ResponseBody.fromString('', 204),
    );
    expect(await api.request('/api/auth/logout', method: 'POST'), isNull);
    dio.httpClientAdapter = FakeAdapter(
      (RequestOptions options) async => ResponseBody.fromString('', 200),
    );
    expect(await api.request('/api/health'), isNull);
  });

  test(
    'problem parsing retains stable code and repeated field errors',
    () async {
      dio.httpClientAdapter = FakeAdapter(
        (RequestOptions options) async => jsonBody(400, {
          'code': 'VALIDATION_ERROR',
          'detail': 'Confira os campos',
          'errors': [
            {'field': 'email', 'message': 'Invalid'},
            {'field': 'email', 'message': 'Too long'},
          ],
        }, problem: true),
      );
      await expectLater(
        api.request('/api/auth/register', method: 'POST'),
        throwsA(
          isA<ApiError>()
              .having((ApiError e) => e.status, 'status', 400)
              .having((ApiError e) => e.code, 'code', 'VALIDATION_ERROR')
              .having((ApiError e) => e.detail, 'detail', 'Confira os campos')
              .having((ApiError e) => e.fieldErrors['email'], 'fields', [
                'Invalid',
                'Too long',
              ]),
        ),
      );
    },
  );

  test(
    'proxy HTML, empty errors and server internals stay out of display text',
    () async {
      for (final ResponseBody response in [
        ResponseBody.fromString('<html>private internals</html>', 502),
        ResponseBody.fromString('', 403),
        jsonBody(500, {
          'code': 'INTERNAL_SERVER_ERROR',
          'detail': 'private database error',
        }, problem: true),
        jsonBody(400, {'detail': 'framework internals'}, problem: true),
      ]) {
        dio.httpClientAdapter = FakeAdapter(
          (RequestOptions options) async => response,
        );
        await expectLater(
          api.request('/api/data'),
          throwsA(
            isA<ApiError>().having(
              (ApiError e) => e.detail,
              'display detail',
              isNull,
            ),
          ),
        );
      }
    },
  );

  test(
    'concurrent 401s rotate once, persist a pair and retry each GET once',
    () async {
      int refreshes = 0;
      final Completer<void> refreshGate = Completer<void>();
      final FakeAdapter adapter = FakeAdapter((RequestOptions options) async {
        if (options.path.endsWith('/api/auth/refresh')) {
          refreshes++;
          expect(options.headers.containsKey('Authorization'), isFalse);
          expect(options.data, {'refreshToken': 'old-refresh'});
          await refreshGate.future;
          return jsonBody(200, {
            'accessToken': 'new-access',
            'refreshToken': 'new-refresh',
          });
        }
        return options.headers['Authorization'] == 'Bearer old-access'
            ? jsonBody(401, {'code': 'UNAUTHENTICATED'}, problem: true)
            : jsonBody(200, {'ok': true});
      });
      dio.httpClientAdapter = adapter;
      await preferences.setSelectedFamilyId('family');
      final Future<Object?> first = api.request('/api/data');
      final Future<Object?> second = api.request('/api/other');
      while (refreshes == 0) {
        await Future<void>.delayed(Duration.zero);
      }
      refreshGate.complete();
      expect(await first, {'ok': true});
      expect(await second, {'ok': true});
      expect(refreshes, 1);
      expect(adapter.requests.length, 5);
      expect((await store.read())?.refreshToken, 'new-refresh');
      expect(await preferences.selectedFamilyId(), 'family');
    },
  );

  test('second 401 terminates session without a second renewal', () async {
    int refreshes = 0;
    dio.httpClientAdapter = FakeAdapter((RequestOptions options) async {
      if (options.path.endsWith('/api/auth/refresh')) {
        refreshes++;
        return jsonBody(200, {
          'accessToken': 'new-access',
          'refreshToken': 'new-refresh',
        });
      }
      return jsonBody(401, {'code': 'UNAUTHENTICATED'}, problem: true);
    });
    await expectLater(api.request('/api/data'), throwsA(isA<ApiError>()));
    expect(refreshes, 1);
    expect(session.state, SessionState.signedOut);
  });

  test('failed refresh clears credentials and account selection', () async {
    await preferences.setSelectedFamilyId('family');
    dio.httpClientAdapter = FakeAdapter(
      (RequestOptions options) async =>
          jsonBody(401, {'code': 'UNAUTHENTICATED'}, problem: true),
    );
    await expectLater(api.request('/api/data'), throwsA(isA<ApiError>()));
    expect(await store.read(), isNull);
    expect(await preferences.selectedFamilyId(), isNull);
  });

  test(
    '403 and mutation 401 never trigger automatic renewal or retry',
    () async {
      for (final int status in [403, 401]) {
        final FakeAdapter adapter = FakeAdapter(
          (RequestOptions options) async => jsonBody(status, {}, problem: true),
        );
        dio.httpClientAdapter = adapter;
        await expectLater(
          api.request('/api/data', method: status == 401 ? 'POST' : 'GET'),
          throwsA(isA<ApiError>()),
        );
        expect(adapter.requests.length, 1);
      }
    },
  );

  test(
    'mutation timeout is uncertain and never automatically retried',
    () async {
      final FakeAdapter adapter = FakeAdapter(
        (RequestOptions options) async => throw DioException(
          requestOptions: options,
          type: DioExceptionType.receiveTimeout,
        ),
      );
      dio.httpClientAdapter = adapter;
      await expectLater(
        api.request('/api/data', method: 'POST'),
        throwsA(
          isA<ApiError>()
              .having((ApiError e) => e.kind, 'kind', ApiFailure.timeout)
              .having((ApiError e) => e.uncertainMutation, 'uncertain', isTrue),
        ),
      );
      expect(adapter.requests.length, 1);
    },
  );

  test('late protected response cannot enter a changed session', () async {
    final Completer<ResponseBody> response = Completer<ResponseBody>();
    final Completer<void> started = Completer<void>();
    dio.httpClientAdapter = FakeAdapter((RequestOptions options) {
      started.complete();
      return response.future;
    });
    final Future<Object?> request = api.request('/api/data');
    final Future<void> assertion = expectLater(
      request,
      throwsA(
        isA<ApiError>().having(
          (ApiError e) => e.kind,
          'kind',
          ApiFailure.sessionChanged,
        ),
      ),
    );
    await started.future;
    await session.clear();
    response.complete(jsonBody(200, {'private': true}));
    await assertion;
  });

  test(
    'absolute URLs and origin-changing paths are rejected before transport',
    () async {
      final FakeAdapter adapter = FakeAdapter(
        (RequestOptions options) async => jsonBody(200, {}),
      );
      dio.httpClientAdapter = adapter;
      for (final String path in [
        'https://other.example/api',
        '//other.example/api',
        '/api/../auth/login',
      ]) {
        await expectLater(api.request(path), throwsArgumentError);
      }
      expect(adapter.requests, isEmpty);
    },
  );
}
