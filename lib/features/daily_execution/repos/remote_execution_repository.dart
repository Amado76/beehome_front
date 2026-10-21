import '../../../core/network/clients/api_client.dart';
import '../models/daily_execution.dart';

abstract interface class ExecutionRepository {
  Future<DailyExecution> read(String familyId, String memberId, String date);
  Future<DailyExecution> synchronize(
    String familyId,
    String memberId,
    String date,
  );
  Future<DailyExecution> setCompleted(
    String familyId,
    String memberId,
    String date,
    String itemId,
    bool completed,
  );
}

class RemoteExecutionRepository implements ExecutionRepository {
  const RemoteExecutionRepository(this._api);
  final ApiClient _api;
  String _path(String familyId, String memberId, String date) =>
      '/api/families/$familyId/members/$memberId/executions/$date';
  @override
  Future<DailyExecution> read(
    String familyId,
    String memberId,
    String date,
  ) async => DailyExecution.fromJson(
    await _api.request(_path(familyId, memberId, date)),
  );
  @override
  Future<DailyExecution> synchronize(
    String familyId,
    String memberId,
    String date,
  ) async => DailyExecution.fromJson(
    await _api.request(_path(familyId, memberId, date), method: 'PUT'),
  );
  @override
  Future<DailyExecution> setCompleted(
    String familyId,
    String memberId,
    String date,
    String itemId,
    bool completed,
  ) async => DailyExecution.fromJson(
    await _api.request(
      '${_path(familyId, memberId, date)}/items/$itemId/${completed ? 'complete' : 'uncomplete'}',
      method: 'POST',
    ),
  );
}
