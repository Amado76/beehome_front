import '../../../core/network/clients/api_client.dart';
import '../../../core/network/models/api_response.dart';
import '../models/board_note.dart';
import '../models/drawing_document.dart';
import 'remote_scratchpad_repository.dart';

abstract interface class NotesRepository {
  Future<void> delete(
    String familyId,
    String memberId,
    String id,
    int revision,
  );
  Future<BoardNotePage> list(String familyId, String memberId, {int page = 0});
  Future<BoardNote> read(String familyId, String memberId, String id);
  Future<BoardNote> save(
    String familyId,
    String memberId,
    String id,
    String title,
    DrawingDocument drawing,
  );
}

class RemoteNotesRepository implements NotesRepository {
  const RemoteNotesRepository(this._api);
  final ApiClient _api;
  @override
  Future<void> delete(
    String familyId,
    String memberId,
    String id,
    int revision,
  ) async {
    await _api.request(
      '${_path(familyId, memberId)}/$id',
      method: 'DELETE',
      queryParameters: {'revision': revision},
    );
  }

  String _path(String family, String member) =>
      '/api/families/$family/members/$member/notes';
  @override
  Future<BoardNotePage> list(
    String familyId,
    String memberId, {
    int page = 0,
  }) async {
    final json = responseObject(
      await _api.request(
        _path(familyId, memberId),
        queryParameters: {'page': page, 'size': 20},
      ),
    );
    return BoardNotePage(
      responseValue<List<Object?>>(
        json,
        'items',
      ).map(BoardNote.fromJson).toList(),
      responseValue<bool>(json, 'hasNext'),
      total: json['total'] as int?,
    );
  }

  @override
  Future<BoardNote> read(String familyId, String memberId, String id) async =>
      BoardNote.fromJson(
        await _api.request('${_path(familyId, memberId)}/$id'),
      );
  @override
  Future<BoardNote> save(
    String familyId,
    String memberId,
    String id,
    String title,
    DrawingDocument drawing,
  ) async => decodeMutation(
    await _api.request(
      '${_path(familyId, memberId)}/$id',
      method: 'PUT',
      data: {...drawing.toJson(), 'title': title},
    ),
    BoardNote.fromJson,
  );
}

/// Adapts a single note to the existing vector editor and its revision handling.
class NoteScratchpadRepository implements DeletableScratchpadRepository {
  const NoteScratchpadRepository(this.notes, this.id, this.title);
  final NotesRepository notes;
  final String id;
  final String title;
  @override
  Future<void> delete(String familyId, String memberId, int revision) =>
      notes.delete(familyId, memberId, id, revision);
  @override
  Future<DrawingDocument> read(String familyId, String memberId) async =>
      (await notes.read(familyId, memberId, id)).drawing;
  @override
  Future<DrawingDocument> save(
    String familyId,
    String memberId,
    DrawingDocument document,
  ) async => (await notes.save(
    familyId,
    memberId,
    id,
    document.title ?? title,
    document,
  )).drawing;
}
