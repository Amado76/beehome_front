import 'package:beehome/core/network/clients/api_client.dart';
import 'package:beehome/features/scratchpad/repos/remote_notes_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class NotesApi implements ApiClient {
  Map<String, Object?>? query;
  @override
  Future<Object?> request(
    String path, {
    String method = 'GET',
    Object? data,
    Map<String, Object?>? queryParameters,
    bool protected = true,
  }) async {
    if (Uri.parse(path).hasQuery) {
      throw ArgumentError('Query must use queryParameters');
    }
    query = queryParameters;
    return {'items': [], 'hasNext': false};
  }

  @override
  void close() {}
}

void main() {
  test('loads note pages through the API query parameter contract', () async {
    final api = NotesApi();
    final page = await RemoteNotesRepository(
      api,
    ).list('family', 'member', page: 2);
    expect(page.items, isEmpty);
    expect(api.query, {'page': 2, 'size': 20});
  });
}
