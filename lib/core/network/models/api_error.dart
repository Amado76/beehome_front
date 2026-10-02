enum ApiFailure {
  http,
  connection,
  timeout,
  cancelled,
  invalidResponse,
  sessionChanged,
}

class ApiError implements Exception {
  const ApiError({
    required this.kind,
    this.status,
    this.code,
    this.detail,
    this.fieldErrors = const {},
    this.retryAfter,
    this.uncertainMutation = false,
  });

  final ApiFailure kind;
  final int? status;
  final String? code;
  final String? detail;
  final Map<String, List<String>> fieldErrors;
  final String? retryAfter;
  final bool uncertainMutation;

  factory ApiError.http(
    int status,
    Object? body, {
    String? contentType,
    String? retryAfter,
    required bool mutation,
  }) {
    final bool problem =
        contentType?.split(';').first.trim().toLowerCase() ==
        'application/problem+json';
    final Map<String, Object?>? data = problem && body is Map<String, Object?>
        ? body
        : null;
    final String? code = data?['code'] is String
        ? data!['code'] as String
        : null;
    // Only contract-owned client failures can supply display text.
    final bool display = code != null && status >= 400 && status < 500;
    final Map<String, List<String>> fields = {};
    final Object? errors = data?['errors'];
    if (display && code == 'VALIDATION_ERROR' && errors is List) {
      for (final Object? entry in errors) {
        if (entry is Map<String, Object?> &&
            entry['field'] is String &&
            entry['message'] is String) {
          fields
              .putIfAbsent(entry['field'] as String, () => [])
              .add(entry['message'] as String);
        }
      }
    }
    return ApiError(
      kind: ApiFailure.http,
      status: status,
      code: code,
      detail: display && data?['detail'] is String
          ? data!['detail'] as String
          : null,
      fieldErrors: Map.unmodifiable(
        fields.map(
          (String key, List<String> value) =>
              MapEntry(key, List<String>.unmodifiable(value)),
        ),
      ),
      retryAfter: retryAfter,
      uncertainMutation: mutation && status >= 500,
    );
  }

  @override
  String toString() => 'ApiError(kind: $kind, status: $status, code: $code)';
}
