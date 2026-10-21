import '../../../core/network/clients/api_client.dart';
import '../models/family.dart';
import '../../../core/network/models/api_response.dart';

abstract interface class FamilyRepository {
  Future<ResultPage<Family>> list({int page = 0});
  Future<Family> read(String id);
  Future<Family> create(String name);
  Future<Family> edit(String id, String name);
}

class RemoteFamilyRepository implements FamilyRepository {
  const RemoteFamilyRepository(this._api);
  final ApiClient _api;
  @override
  Future<ResultPage<Family>> list({int page = 0}) async => ResultPage.fromJson(
    await _api.request(
      '/api/families',
      queryParameters: {'page': page, 'size': 20},
    ),
    Family.fromJson,
  );
  @override
  Future<Family> read(String id) async =>
      Family.fromJson(await _api.request('/api/families/$id'));
  @override
  Future<Family> create(String name) async => decodeMutation(
    await _api.request('/api/families', method: 'POST', data: {'name': name}),
    Family.fromJson,
  );
  @override
  Future<Family> edit(String id, String name) async => decodeMutation(
    await _api.request(
      '/api/families/$id',
      method: 'PATCH',
      data: {'name': name},
    ),
    Family.fromJson,
  );
}
