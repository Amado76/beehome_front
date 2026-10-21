import '../../../core/network/clients/api_client.dart';
import '../../../core/network/models/api_error.dart';
import '../models/drawing_document.dart';
import '../../../core/network/models/api_response.dart';

abstract interface class ScratchpadRepository {
  Future<DrawingDocument> read(String familyId, String memberId);
  Future<DrawingDocument> save(
    String familyId,
    String memberId,
    DrawingDocument document,
  );
}

abstract interface class DeletableScratchpadRepository
    implements ScratchpadRepository {
  Future<void> delete(String familyId, String memberId, int revision);
}

class RemoteScratchpadRepository implements ScratchpadRepository {
  const RemoteScratchpadRepository(this._api);
  final ApiClient _api;
  String _path(String familyId, String memberId) =>
      '/api/families/$familyId/members/$memberId/drawings/profile-scratchpad';
  @override
  Future<DrawingDocument> read(String familyId, String memberId) async =>
      DrawingDocument.fromJson(await _api.request(_path(familyId, memberId)));
  @override
  Future<DrawingDocument> save(
    String familyId,
    String memberId,
    DrawingDocument document,
  ) async {
    if (!document.withinLimits) {
      throw const ApiError(
        kind: ApiFailure.http,
        status: 413,
        code: 'DRAWING_TOO_LARGE',
      );
    }
    return decodeMutation(
      await _api.request(
        _path(familyId, memberId),
        method: 'PUT',
        data: document.toJson(),
      ),
      DrawingDocument.fromJson,
    );
  }
}
