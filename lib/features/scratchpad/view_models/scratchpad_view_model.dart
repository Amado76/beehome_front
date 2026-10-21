import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/drawing_document.dart';
import '../repos/remote_scratchpad_repository.dart';
import '../../../core/network/models/api_error.dart';

enum DrawingTool { pen, erase }

class ScratchpadViewModel extends ChangeNotifier {
  ScratchpadViewModel({
    required ScratchpadRepository repository,
    required this.familyId,
    required this.memberId,
    required this.canEdit,
  }) : _repository = repository;
  final ScratchpadRepository _repository;
  final String familyId;
  final String memberId;
  final bool canEdit;
  List<DrawingStroke> strokes = const [];
  final List<List<DrawingStroke>> _undo = [];
  final List<List<DrawingStroke>> _redo = [];
  List<DrawingPoint> pending = [];
  int? _pointer;
  String color = '#2B2B2B';
  double width = 3;
  DrawingTool tool = DrawingTool.pen;
  bool loading = false;
  bool loaded = false;
  bool saving = false;
  bool deleteFailed = false;
  bool _deleted = false;
  bool _deleting = false;
  bool get canDelete => canEdit && _repository is DeletableScratchpadRepository;
  ApiError? error;
  DrawingDocument? conflict;
  DrawingDocument? _uncertainWrite;
  int _uncertainVersion = 0;
  int _revision = 0;
  String? _title;
  String? get title => _title;
  int _editVersion = 0;
  int _savedVersion = 0;
  bool _disposed = false;
  Timer? _debounce;
  int _loadGeneration = 0;
  bool get dirty => _editVersion != _savedVersion || pending.isNotEmpty;
  bool get canUndo => canEdit && _undo.isNotEmpty;
  bool get canRedo => canEdit && _redo.isNotEmpty;
  bool get editable =>
      !_deleted &&
      !_deleting &&
      canEdit &&
      loaded &&
      !loading &&
      conflict == null &&
      error?.status != 403;
  DrawingDocument get document => DrawingDocument(
    revision: _revision,
    title: _title?.trim(),
    strokes: strokes,
  );
  void _emit() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load() async {
    if (_disposed || dirty || saving) return;
    final int generation = ++_loadGeneration;
    loading = true;
    error = null;
    _emit();
    try {
      final DrawingDocument result = await _repository.read(familyId, memberId);
      if (_disposed || generation != _loadGeneration) return;
      _revision = result.revision;
      _title = result.title;
      strokes = result.strokes;
      loaded = true;
    } catch (failure) {
      if (!_disposed && generation == _loadGeneration) {
        error = _failure(failure);
      }
    } finally {
      if (!_disposed && generation == _loadGeneration) {
        loading = false;
        _emit();
      }
    }
  }

  void setTitle(String value) {
    if (!editable || _title == null || value.length > 120 || value == _title) {
      return;
    }
    _title = value;
    _changed();
  }

  void selectColor(String value) {
    color = value;
    tool = DrawingTool.pen;
    _emit();
  }

  void selectWidth(double value) {
    width = value;
    _emit();
  }

  void selectTool(DrawingTool value) {
    tool = value;
    _emit();
  }

  void begin(int pointer, double x, double y, {double? pressure}) {
    if (!editable || _pointer != null) return;
    _pointer = pointer;
    if (tool == DrawingTool.erase) {
      erase(x, y);
      return;
    }
    if (strokes.length >= 5000) {
      error = const ApiError(
        kind: ApiFailure.http,
        status: 413,
        code: 'DRAWING_TOO_LARGE',
      );
      _pointer = null;
      _emit();
      return;
    }
    pending = [DrawingPoint(x.clamp(0, 1), y.clamp(0, 1), pressure: pressure)];
    _emit();
  }

  void move(int pointer, double x, double y, {double? pressure}) {
    if (_pointer != pointer || !editable) return;
    if (tool == DrawingTool.erase) {
      erase(x, y);
      return;
    }
    if (pending.isEmpty || pending.length >= 10000) return;
    final DrawingPoint point = DrawingPoint(
      x.clamp(0, 1),
      y.clamp(0, 1),
      pressure: pressure,
    );
    final DrawingPoint last = pending.last;
    if ((point.x - last.x).abs() + (point.y - last.y).abs() < 0.001) return;
    pending = [...pending, point];
    _emit();
  }

  void end(int pointer) {
    if (_pointer != pointer) return;
    _pointer = null;
    if (pending.isEmpty) return;
    final DrawingStroke stroke = DrawingStroke(
      id: newStrokeId(),
      color: color,
      width: width,
      points: pending,
    );
    pending = [];
    _replace([...strokes, stroke]);
  }

  void cancel(int pointer) {
    if (_pointer == pointer) {
      _pointer = null;
      pending = [];
      _emit();
    }
  }

  void erase(double x, double y) {
    final DrawingPoint target = DrawingPoint(x, y);
    DrawingStroke? hit;
    for (final DrawingStroke stroke in strokes.reversed) {
      for (int i = 0; i < stroke.points.length; i++) {
        final DrawingPoint a = stroke.points[i];
        final DrawingPoint b = stroke.points[i == 0 ? 0 : i - 1];
        final double dx = b.x - a.x;
        final double dy = (b.y - a.y) * 0.75;
        final double length = dx * dx + dy * dy;
        final double t = length == 0
            ? 0
            : (((target.x - a.x) * dx + (target.y - a.y) * 0.75 * dy) / length)
                  .clamp(0, 1);
        final double ex = target.x - a.x - t * dx;
        final double ey = (target.y - a.y) * 0.75 - t * dy;
        if (ex * ex + ey * ey < 0.0004) {
          hit = stroke;
          break;
        }
      }
      if (hit != null) break;
    }
    if (hit != null) {
      _replace(
        strokes.where((DrawingStroke stroke) => stroke.id != hit!.id).toList(),
      );
    }
  }

  void _replace(List<DrawingStroke> next) {
    if (!editable) return;
    final DrawingDocument candidate = DrawingDocument(
      revision: _revision,
      strokes: next,
    );
    if (!candidate.withinLimits) {
      error = const ApiError(
        kind: ApiFailure.http,
        status: 413,
        code: 'DRAWING_TOO_LARGE',
      );
      _emit();
      return;
    }
    _undo.add(strokes);
    if (_undo.length > 30) _undo.removeAt(0);
    _redo.clear();
    strokes = List.unmodifiable(next);
    _changed();
  }

  void undo() {
    if (canUndo && editable) {
      _redo.add(strokes);
      strokes = _undo.removeLast();
      _changed();
    }
  }

  void redo() {
    if (canRedo && editable) {
      _undo.add(strokes);
      strokes = _redo.removeLast();
      _changed();
    }
  }

  void clear() {
    if (strokes.isNotEmpty) _replace([]);
  }

  void _changed() {
    deleteFailed = false;
    ++_editVersion;
    error = null;
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 1400),
      () => unawaited(save()),
    );
    _emit();
  }

  Future<bool> deleteNote() async {
    if (_disposed || _deleted || !canDelete || !loaded || saving) return false;
    _debounce?.cancel();
    saving = true;
    _deleting = true;
    deleteFailed = false;
    error = null;
    _emit();
    try {
      await (_repository as DeletableScratchpadRepository).delete(
        familyId,
        memberId,
        _revision,
      );
      _deleted = true;
      _savedVersion = _editVersion;
      pending = [];
      _pointer = null;
      _uncertainWrite = null;
      return true;
    } catch (failure) {
      if (!_disposed) {
        deleteFailed = true;
        error = _failure(failure);
        if (error?.status == 409) {
          try {
            conflict = await _repository.read(familyId, memberId);
          } catch (_) {}
        }
      }
      return false;
    } finally {
      if (!_disposed) {
        saving = false;
        _deleting = false;
        _emit();
      }
    }
  }

  Future<bool> save() async {
    _debounce?.cancel();
    if (_disposed ||
        _deleted ||
        !canEdit ||
        !loaded ||
        conflict != null ||
        error?.status == 403) {
      return false;
    }
    if (_pointer != null) end(_pointer!);
    if (saving) return false;
    if (_uncertainWrite != null) {
      saving = true;
      _emit();
      try {
        await _reconcile();
      } finally {
        if (!_disposed) {
          saving = false;
          _emit();
        }
      }
      if (_disposed || _uncertainWrite != null || conflict != null) {
        return false;
      }
    }
    if (!dirty) return true;
    final DrawingDocument submitted = document;
    final int version = _editVersion;
    saving = true;
    error = null;
    _emit();
    try {
      final DrawingDocument result = await _repository.save(
        familyId,
        memberId,
        submitted,
      );
      if (_disposed) return false;
      _revision = result.revision;
      _savedVersion = version;
      if (_editVersion == version) {
        strokes = result.strokes;
        _title = result.title;
      }
      return !dirty;
    } catch (failure) {
      if (_disposed) return false;
      error = _failure(failure);
      if (error!.status == 409 || error!.uncertainMutation) {
        _uncertainWrite = submitted;
        _uncertainVersion = version;
        await _reconcile();
      }
      return !dirty;
    } finally {
      if (!_disposed) {
        saving = false;
        _emit();
        if (dirty && error == null && conflict == null) {
          _debounce = Timer(
            const Duration(milliseconds: 1400),
            () => unawaited(save()),
          );
        }
      }
    }
  }

  Future<void> _reconcile() async {
    final DrawingDocument? submitted = _uncertainWrite;
    if (submitted == null) return;
    try {
      final DrawingDocument remote = await _repository.read(familyId, memberId);
      if (_disposed) return;
      if (remote.content == submitted.content) {
        _revision = remote.revision;
        _savedVersion = _uncertainVersion;
        error = null;
      } else {
        conflict = remote;
      }
      _uncertainWrite = null;
    } catch (failure) {
      if (!_disposed) error = _failure(failure);
    }
  }

  void useRemote() {
    final DrawingDocument? remote = conflict;
    if (remote == null) return;
    strokes = remote.strokes;
    _title = remote.title;
    _revision = remote.revision;
    _undo.clear();
    _redo.clear();
    _savedVersion = ++_editVersion;
    conflict = null;
    _uncertainWrite = null;
    error = null;
    _emit();
  }

  Future<void> keepLocal() async {
    if (conflict == null) return;
    _revision = conflict!.revision;
    conflict = null;
    _uncertainWrite = null;
    error = null;
    await save();
  }

  ApiError _failure(Object failure) => failure is ApiError
      ? failure
      : const ApiError(
          kind: ApiFailure.invalidResponse,
          uncertainMutation: true,
        );
  @override
  void dispose() {
    _disposed = true;
    ++_loadGeneration;
    _debounce?.cancel();
    super.dispose();
  }
}
