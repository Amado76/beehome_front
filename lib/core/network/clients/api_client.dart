abstract interface class ApiClient {
  Future<Object?> request(
    String path, {
    String method = 'GET',
    Object? data,
    Map<String, Object?>? queryParameters,
    bool protected = true,
  });

  void close();
}
