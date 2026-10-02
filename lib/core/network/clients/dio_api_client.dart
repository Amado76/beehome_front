import 'dart:convert';

import 'package:dio/dio.dart';

import '../../auth/services/session_service.dart';
import '../../config/models/app_config.dart';
import '../../auth/models/session_tokens.dart';
import 'api_client.dart';
import '../models/api_error.dart';

class DioApiClient implements ApiClient {
  DioApiClient({
    required Dio dio,
    required AppConfig config,
    required SessionService session,
    required String Function() language,
    required Future<SessionTokens> Function(String) refreshTokens,
  }) : _dio = dio,
       _config = config,
       _session = session,
       _language = language,
       _refreshTokens = refreshTokens {
    _dio.options = BaseOptions(
      baseUrl: config.origin.toString(),
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.plain,
      validateStatus: (int? status) => status != null,
      followRedirects: false,
      headers: {'Accept': 'application/json, application/problem+json'},
    );
  }

  final Dio _dio;
  final AppConfig _config;
  final SessionService _session;
  final String Function() _language;
  final Future<SessionTokens> Function(String) _refreshTokens;

  static const Set<String> _publicPaths = {
    '/api/auth/login',
    '/api/auth/register',
    '/api/auth/refresh',
    '/api/auth/forgot-password',
    '/api/auth/reset-password',
    '/api/health',
  };

  @override
  Future<Object?> request(
    String path, {
    String method = 'GET',
    Object? data,
    Map<String, Object?>? queryParameters,
    bool protected = true,
  }) async {
    final Uri relative = Uri.parse(path);
    final String decodedPath = Uri.decodeComponent(path);
    if (!path.startsWith('/') ||
        path.startsWith('//') ||
        relative.hasAuthority ||
        relative.hasScheme ||
        relative.hasFragment ||
        relative.hasQuery ||
        decodedPath.contains('\\') ||
        decodedPath.startsWith('//') ||
        decodedPath
            .split('/')
            .any((String segment) => segment == '.' || segment == '..')) {
      throw ArgumentError(
        'API requests must use an absolute path on the configured origin.',
      );
    }
    final String verb = method.toUpperCase();
    final bool authenticated = protected && !_publicPaths.contains(decodedPath);
    final bool safe = verb == 'GET' || verb == 'HEAD';
    final int generation = _session.generation;
    final SessionTokens? initial = _session.tokens;
    if (authenticated && initial == null) {
      throw const ApiError(
        kind: ApiFailure.http,
        status: 401,
        code: 'UNAUTHENTICATED',
      );
    }
    try {
      return await _send(
        path,
        verb,
        data,
        queryParameters,
        authenticated,
        generation,
      );
    } on ApiError catch (error) {
      if (!authenticated ||
          error.status != 401 ||
          !safe ||
          generation != _session.generation) {
        rethrow;
      }
      // Another concurrent request may already have rotated these credentials.
      final bool renewed =
          _session.tokens?.accessToken != initial?.accessToken ||
          await _session.renew(_refreshTokens);
      if (!renewed || generation != _session.generation) rethrow;
      try {
        return await _send(path, verb, data, queryParameters, true, generation);
      } on ApiError catch (retryError) {
        if (retryError.status == 401 && generation == _session.generation) {
          await _session.clear();
        }
        rethrow;
      }
    }
  }

  Future<Object?> _send(
    String path,
    String method,
    Object? data,
    Map<String, Object?>? query,
    bool authenticated,
    int generation,
  ) async {
    final bool mutation = method != 'GET' && method != 'HEAD';
    try {
      final Response<String> response = await _dio.request<String>(
        '${_config.origin}$path',
        data: data,
        queryParameters: query,
        options: Options(
          method: method,
          headers: {
            'Accept-Language': _language(),
            if (authenticated)
              'Authorization': 'Bearer ${_session.tokens!.accessToken}',
          },
        ),
      );
      if (authenticated && generation != _session.generation) {
        throw ApiError(
          kind: ApiFailure.sessionChanged,
          uncertainMutation: mutation,
        );
      }
      final int status = response.statusCode!;
      Object? body;
      bool invalidJson = false;
      if (status != 204 &&
          response.data != null &&
          response.data!.trim().isNotEmpty) {
        try {
          body = jsonDecode(response.data!);
        } on FormatException {
          invalidJson = true;
        }
      }
      if (status < 200 || status >= 300) {
        throw ApiError.http(
          status,
          body,
          contentType: response.headers.value(Headers.contentTypeHeader),
          retryAfter: response.headers.value('retry-after'),
          mutation: mutation,
        );
      }
      if (invalidJson) {
        throw ApiError(
          kind: ApiFailure.invalidResponse,
          uncertainMutation: mutation,
        );
      }
      return body;
    } on DioException catch (error) {
      final ApiFailure kind = switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout => ApiFailure.timeout,
        DioExceptionType.cancel => ApiFailure.cancelled,
        _ => ApiFailure.connection,
      };
      throw ApiError(kind: kind, uncertainMutation: mutation);
    }
  }

  @override
  void close() => _dio.close(force: true);
}
