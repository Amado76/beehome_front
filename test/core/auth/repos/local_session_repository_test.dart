import 'package:beehome/core/auth/repos/local_session_repository.dart';
import 'package:beehome/core/auth/models/session_tokens.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'native adapter replaces and clears a pair in one secure value',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      const FlutterSecureStorage secure = FlutterSecureStorage();
      final LocalSessionRepository store = LocalSessionRepository(secure);
      await store.write(const SessionTokens('old-access', 'old-refresh'));
      await store.write(const SessionTokens('new-access', 'new-refresh'));
      expect((await secure.readAll()).keys, [
        LocalSessionRepository.storageKey,
      ]);
      expect((await store.read())?.refreshToken, 'new-refresh');
      await store.clear();
      expect(await secure.readAll(), isEmpty);
    },
  );

  test(
    'corrupt native credentials are removed without exposing their content',
    () async {
      FlutterSecureStorage.setMockInitialValues({
        LocalSessionRepository.storageKey: '{broken private content',
      });
      final LocalSessionRepository store = LocalSessionRepository(
        const FlutterSecureStorage(),
      );
      expect(await store.read(), isNull);
      expect(await const FlutterSecureStorage().readAll(), isEmpty);
    },
  );

  test('web memory sessions do not survive a new store', () async {
    final MemorySessionRepository store = MemorySessionRepository();
    await store.write(const SessionTokens('access', 'refresh'));
    expect((await store.read())?.accessToken, 'access');
    expect(await MemorySessionRepository().read(), isNull);
  });
}
