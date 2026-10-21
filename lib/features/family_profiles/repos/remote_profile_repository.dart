import '../../../core/network/clients/api_client.dart';
import '../../family_workspace/models/family.dart';
import '../models/family_profile.dart';
import '../../../core/network/models/api_response.dart';

abstract interface class ProfileRepository {
  Future<FamilyProfile> deactivate(String familyId, String memberId);
  Future<ResultPage<FamilyProfile>> list(String familyId, {int page = 0});
  Future<FamilyProfile> save(
    String familyId, {
    String? id,
    required String name,
    required MemberType type,
    String? birthDate,
    String? color,
    String? completionColor,
    bool updateCompletionColor = false,
  });
}

class RemoteProfileRepository implements ProfileRepository {
  const RemoteProfileRepository(this._api);
  final ApiClient _api;
  @override
  Future<FamilyProfile> deactivate(String familyId, String memberId) async =>
      decodeMutation(
        await _api.request(
          '/api/families/$familyId/members/$memberId/deactivate',
          method: 'POST',
        ),
        FamilyProfile.fromJson,
      );
  @override
  Future<ResultPage<FamilyProfile>> list(
    String familyId, {
    int page = 0,
  }) async => ResultPage.fromJson(
    await _api.request(
      '/api/families/$familyId/members',
      queryParameters: {'page': page, 'size': 20},
    ),
    FamilyProfile.fromJson,
  );
  @override
  Future<FamilyProfile> save(
    String familyId, {
    String? id,
    required String name,
    required MemberType type,
    String? birthDate,
    String? color,
    String? completionColor,
    bool updateCompletionColor = false,
  }) async => decodeMutation(
    await _api.request(
      '/api/families/$familyId/members${id == null ? '' : '/$id'}',
      method: id == null ? 'POST' : 'PATCH',
      data: {
        'name': name,
        'memberType': type == MemberType.adult ? 'ADULT' : 'CHILD',
        'birthDate': birthDate,
        'color': color,
        if (id != null && updateCompletionColor)
          'preferences': {'completedTaskColor': completionColor},
      },
    ),
    FamilyProfile.fromJson,
  );
}
