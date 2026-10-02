class SessionTokens {
  const SessionTokens(this.accessToken, this.refreshToken);

  final String accessToken;
  final String refreshToken;

  factory SessionTokens.fromJson(Object? value) {
    if (value is! Map<String, Object?> ||
        value['accessToken'] is! String ||
        value['refreshToken'] is! String) {
      throw const FormatException('Invalid session response.');
    }
    final String access = value['accessToken'] as String;
    final String refresh = value['refreshToken'] as String;
    if (access.isEmpty || refresh.isEmpty) {
      throw const FormatException('Invalid session response.');
    }
    return SessionTokens(access, refresh);
  }

  Map<String, String> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
  };
}
