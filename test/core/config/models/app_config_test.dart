import 'package:beehome/core/config/models/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('origin rejects credentials, paths and insecure deployment', () {
    expect(
      () => AppConfig.parse('https://user:pass@example.com'),
      throwsFormatException,
    );
    expect(
      () => AppConfig.parse('https://example.com/api'),
      throwsFormatException,
    );
    expect(() => AppConfig.parse('http://example.com'), throwsFormatException);
    expect(
      AppConfig.parse('http://10.0.2.2:8080', development: true).origin.host,
      '10.0.2.2',
    );
  });
}
