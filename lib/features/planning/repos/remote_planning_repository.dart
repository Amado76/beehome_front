import '../../../core/network/clients/api_client.dart';
import '../../../core/network/models/api_error.dart';
import '../../../core/network/models/api_response.dart';

abstract interface class PlanningRepository {
  Future<String> createDailyRoutine(String familyId, String title, String date);
  Future<void> addRoutineItem(
    String familyId,
    String routineId,
    String memberId,
    String title,
    int sortOrder,
  );
  Future<void> addDailyItem(
    String familyId,
    String memberId,
    String date,
    String title,
  );
}

class RemotePlanningRepository implements PlanningRepository {
  const RemotePlanningRepository(this._api);
  final ApiClient _api;
  @override
  Future<String> createDailyRoutine(
    String familyId,
    String title,
    String date,
  ) async {
    final response = await _api.request(
      '/api/families/$familyId/routines',
      method: 'POST',
      data: {
        'name': title,
        'startDate': date,
        'daysOfWeek': [
          'MONDAY',
          'TUESDAY',
          'WEDNESDAY',
          'THURSDAY',
          'FRIDAY',
          'SATURDAY',
          'SUNDAY',
        ],
      },
    );
    try {
      return responseValue<String>(responseObject(response), 'id');
    } catch (_) {
      throw const ApiError(
        kind: ApiFailure.invalidResponse,
        uncertainMutation: true,
      );
    }
  }

  @override
  Future<void> addRoutineItem(
    String familyId,
    String routineId,
    String memberId,
    String title,
    int sortOrder,
  ) async {
    await _api.request(
      '/api/families/$familyId/routines/$routineId/items',
      method: 'POST',
      data: {
        'familyMemberId': memberId,
        'title': title,
        'sortOrder': sortOrder,
      },
    );
  }

  @override
  Future<void> addDailyItem(
    String familyId,
    String memberId,
    String date,
    String title,
  ) async {
    final String path =
        '/api/families/$familyId/members/$memberId/daily-plan/$date/items';
    final Object? response = await _api.request(path);
    if (response is! List<Object?>) {
      throw const ApiError(kind: ApiFailure.invalidResponse);
    }
    int nextOrder = 0;
    for (final Object? item in response) {
      final int order = responseValue<int>(responseObject(item), 'sortOrder');
      if (order >= nextOrder) nextOrder = order + 1;
    }
    await _api.request(
      path,
      method: 'POST',
      data: {'title': title, 'sortOrder': nextOrder},
    );
  }
}
