import 'api_error.dart';

Map<String, Object?> responseObject(Object? value) {
  if (value is! Map<String, Object?>) {
    throw const ApiError(kind: ApiFailure.invalidResponse);
  }
  return value;
}

T responseValue<T>(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value is! T) throw const ApiError(kind: ApiFailure.invalidResponse);
  return value;
}

T decodeMutation<T>(Object? response, T Function(Object?) decode) {
  try {
    return decode(response);
  } catch (_) {
    throw const ApiError(
      kind: ApiFailure.invalidResponse,
      uncertainMutation: true,
    );
  }
}
