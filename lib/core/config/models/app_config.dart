import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._(this.origin);

  final Uri origin;

  factory AppConfig.fromEnvironment() {
    const String configured = String.fromEnvironment('API_ORIGIN');
    return AppConfig.parse(
      configured.isEmpty && !kReleaseMode
          ? 'http://localhost:8080'
          : configured,
      development: !kReleaseMode,
    );
  }

  factory AppConfig.parse(String value, {bool development = false}) {
    final Uri? uri = Uri.tryParse(value);
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.path.isNotEmpty && uri.path != '/') ||
        (uri.scheme != 'https' && !(development && uri.scheme == 'http'))) {
      throw const FormatException(
        'Configure API_ORIGIN with a valid HTTPS origin.',
      );
    }
    return AppConfig._(Uri.parse(uri.origin));
  }
}
