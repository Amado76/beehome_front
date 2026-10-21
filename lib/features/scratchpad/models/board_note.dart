import '../../../core/network/models/api_response.dart';
import 'drawing_document.dart';

class BoardNote {
  const BoardNote({
    required this.id,
    required this.title,
    required this.drawing,
  });
  final String id;
  final String title;
  final DrawingDocument drawing;
  factory BoardNote.fromJson(Object? value) {
    final json = responseObject(value);
    return BoardNote(
      id: responseValue<String>(json, 'id'),
      title: responseValue<String>(json, 'title'),
      drawing: DrawingDocument.fromJson(value),
    );
  }
}

class BoardNotePage {
  const BoardNotePage(this.items, this.hasNext, {int? total}) : _total = total;
  final int? _total;
  int get total => _total ?? items.length;
  final List<BoardNote> items;
  final bool hasNext;
}
