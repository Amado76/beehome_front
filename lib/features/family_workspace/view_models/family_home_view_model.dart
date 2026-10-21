import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/network/models/api_error.dart';
import '../../family_profiles/models/family_profile.dart';
import '../../family_profiles/repos/remote_profile_repository.dart';
import '../../daily_execution/models/daily_execution.dart';
import '../../daily_execution/repos/remote_execution_repository.dart';
import '../../planning/repos/remote_planning_repository.dart';
import '../../scratchpad/models/drawing_document.dart';
import '../../scratchpad/repos/remote_notes_repository.dart';
import '../../scratchpad/models/board_note.dart';
import '../../scratchpad/view_models/scratchpad_view_model.dart';
import '../models/family.dart';
import '../services/family_clock.dart';
import '../services/family_workspace_service.dart';

class FamilyHomeViewModel extends ChangeNotifier {
  FamilyHomeViewModel({
    required FamilyWorkspaceService workspace,
    required ProfileRepository profiles,
    required ExecutionRepository executions,
    required PlanningRepository planning,
    required NotesRepository notes,
    required FamilyClock clock,
  }) : _workspace = workspace,
       _profiles = profiles,
       _executions = executions,
       _planning = planning,
       _notes = notes,
       _clock = clock {
    _workspace.addListener(_workspaceChanged);
    _workspaceChanged();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => tick());
  }
  final FamilyWorkspaceService _workspace;
  final ProfileRepository _profiles;
  final ExecutionRepository _executions;
  final PlanningRepository _planning;
  final NotesRepository _notes;
  final FamilyClock _clock;
  Timer? _timer;
  bool _disposed = false;
  String? _familyId;
  int _generation = 0;
  int _selectionGeneration = 0;
  List<FamilyProfile> profiles = const [];
  FamilyProfile? selected;
  bool profilesLoading = false;
  bool profilesHasNext = false;
  int _profilePage = 0;
  ApiError? profilesError;
  DailyExecution? execution;
  bool tasksLoading = false;
  ApiError? tasksError;
  String? pendingItem;
  DrawingDocument? drawing;
  List<BoardNote> notes = const [];
  bool notesHasNext = false;
  int notesTotal = 0;
  bool noteCreating = false;
  final Map<(String, String), ({String id, String title})> _pendingNotes = {};
  int _notePage = 0;
  bool drawingLoading = false;
  ApiError? drawingError;
  bool formBusy = false;
  ApiError? formError;
  bool formUncertain = false;
  bool formReconciled = false;
  FamilyProfile? formSavedProfile;
  bool _uncertainTask = false;
  _TaskDraft? _taskDraft;
  final Map<String, DailyExecution> taskReviewExecutions = {};
  String? get taskDraftTitle => _taskDraft?.title;
  bool get taskDraftRepeatDaily => _taskDraft?.repeatDaily ?? false;
  List<String>? get taskDraftMemberIds => _taskDraft?.memberIds;
  bool get taskStarted => _taskDraft != null;

  void beginTaskForm() {
    if (formUncertain || formBusy) return;
    _taskDraft = null;
    taskReviewExecutions.clear();
    formError = null;
    formReconciled = false;
    _uncertainTask = false;
  }

  String? _date;

  Family? get family => _workspace.active;
  List<Family> get families => _workspace.families;
  bool get busy => _workspace.busy;
  ApiError? get error => _workspace.error;
  bool get uncertain => _workspace.uncertain;
  bool get reconciled => _workspace.reconciled;
  Future<void> reconcileFamily() => _workspace.reconcileUncertain();
  bool get canEdit => family?.canEdit == true;
  DateTime? get now => family == null ? null : _clock.localNow;
  bool get hasBoard => selected != null;
  void _emit() {
    if (!_disposed) notifyListeners();
  }

  bool _current(int generation) => !_disposed && generation == _generation;
  bool _selectionCurrent(int generation) =>
      !_disposed && generation == _selectionGeneration;
  void _workspaceChanged() {
    final String? next = family?.id;
    if (next != _familyId) {
      _familyId = next;
      _pendingNotes.clear();
      ++_generation;
      ++_selectionGeneration;
      profiles = const [];
      selected = null;
      execution = null;
      drawing = null;
      notes = const [];
      notesHasNext = false;
      notesTotal = 0;
      _notePage = 0;
      profilesError = null;
      tasksError = null;
      drawingError = null;
      profilesLoading = false;
      tasksLoading = false;
      drawingLoading = false;
      profilesHasNext = false;
      pendingItem = null;
      formBusy = false;
      formError = null;
      formSavedProfile = null;
      _taskDraft = null;
      taskReviewExecutions.clear();
      _uncertainTask = false;
      formUncertain = false;
      _date = family == null ? null : _clock.date();
      if (next != null) unawaited(loadProfiles());
    } else if (family != null && _date != _clock.date()) {
      tick();
    }
    _emit();
  }

  Future<void> reloadFamilies() => _workspace.reload();
  void acknowledgeUncertain() => _workspace.acknowledgeUncertain();
  Future<bool> saveFamily(String name, {bool edit = false}) =>
      _workspace.save(name, edit: edit);
  void tick() {
    if (_disposed || family == null) return;
    final String date = _clock.date();
    if (_date != date) {
      _date = date;
      unawaited(loadSelected());
    }
    _emit();
  }

  Future<void> resume() async {
    if (_disposed || family == null) return;
    _date = _clock.date();
    if (selected != null) await loadSelected();
    _emit();
  }

  Future<void> loadProfiles({bool more = false}) async {
    final Family? currentFamily = family;
    if (currentFamily == null || profilesLoading) return;
    final int generation = _generation;
    profilesLoading = true;
    profilesError = null;
    _emit();
    try {
      final ResultPage<FamilyProfile> result = await _profiles.list(
        currentFamily.id,
        page: more ? _profilePage + 1 : 0,
      );
      if (!_current(generation)) return;
      profiles = List.unmodifiable(
        {
          if (more)
            for (final FamilyProfile profile in profiles) profile.id: profile,
          for (final FamilyProfile profile in result.items)
            if (profile.active) profile.id: profile,
        }.values,
      );
      _profilePage = result.page;
      profilesHasNext = result.hasNext;
      final String? previous = selected?.id;
      selected = null;
      for (final FamilyProfile profile in profiles) {
        if (profile.id == previous) selected = profile;
      }
      selected ??= profiles.firstOrNull;
      await loadSelected();
    } catch (failure) {
      if (_current(generation)) {
        profilesError = _failure(failure);
        await _checkUnavailable(profilesError!);
      }
    } finally {
      if (_current(generation)) {
        profilesLoading = false;
        _emit();
      }
    }
  }

  void selectProfile(String id) {
    if (selected?.id == id) return;
    selected = profiles.firstWhere((FamilyProfile profile) => profile.id == id);
    unawaited(loadSelected());
    _emit();
  }

  Future<void> loadSelected() async {
    final Family? currentFamily = family;
    final FamilyProfile? profile = selected;
    final int generation = ++_selectionGeneration;
    execution = null;
    drawing = null;
    notes = const [];
    notesHasNext = false;
    notesTotal = 0;
    _notePage = 0;
    tasksError = null;
    drawingError = null;
    pendingItem = null;
    if (currentFamily == null || profile == null) {
      tasksLoading = false;
      drawingLoading = false;
      _emit();
      return;
    }
    final String date = _clock.date();
    _date = date;
    tasksLoading = true;
    drawingLoading = true;
    _emit();
    await Future.wait([
      _loadExecution(currentFamily.id, profile.id, date, generation),
      _loadDrawing(currentFamily.id, profile.id, generation),
    ]);
  }

  Future<void> _loadExecution(
    String familyId,
    String memberId,
    String date,
    int generation,
  ) async {
    try {
      DailyExecution result;
      try {
        result = await _executions.read(familyId, memberId, date);
      } on ApiError catch (failure) {
        if (failure.code != 'DAILY_EXECUTION_NOT_FOUND') rethrow;
        if (!_selectionCurrent(generation)) return;
        result = await _executions.synchronize(familyId, memberId, date);
      }
      if (_selectionCurrent(generation)) execution = result;
    } catch (failure) {
      if (_selectionCurrent(generation)) {
        tasksError = _failure(failure);
        await _checkUnavailable(tasksError!);
      }
    } finally {
      if (_selectionCurrent(generation)) {
        tasksLoading = false;
        _emit();
      }
    }
  }

  Future<void> _loadDrawing(
    String familyId,
    String memberId,
    int generation,
  ) async {
    try {
      final BoardNotePage result = await _notes.list(familyId, memberId);
      if (_selectionCurrent(generation)) {
        notes = result.items;
        notesHasNext = result.hasNext;
        notesTotal = result.total;
        _notePage = 0;
        drawing = notes.isEmpty ? null : notes.first.drawing;
      }
    } catch (failure) {
      if (_selectionCurrent(generation)) {
        drawingError = _failure(failure);
        await _checkUnavailable(drawingError!);
      }
    } finally {
      if (_selectionCurrent(generation)) {
        drawingLoading = false;
        _emit();
      }
    }
  }

  Future<void> refreshTasks() async {
    if (tasksLoading ||
        pendingItem != null ||
        family == null ||
        selected == null) {
      return;
    }
    final int generation = _selectionGeneration;
    final String familyId = family!.id;
    final String memberId = selected!.id;
    final String date = _clock.date();
    final bool reconcile = tasksError?.uncertainMutation == true;
    tasksLoading = true;
    tasksError = null;
    _emit();
    try {
      final DailyExecution result = reconcile
          ? await _executions.read(familyId, memberId, date)
          : await _executions.synchronize(familyId, memberId, date);
      if (_selectionCurrent(generation)) execution = result;
    } catch (failure) {
      if (_selectionCurrent(generation)) tasksError = _failure(failure);
    } finally {
      if (_selectionCurrent(generation)) {
        tasksLoading = false;
        _emit();
      }
    }
  }

  Future<void> toggle(ExecutionItem item) async {
    if (pendingItem != null ||
        tasksLoading ||
        execution?.finalized != false ||
        family == null ||
        selected == null) {
      return;
    }
    tick();
    if (tasksLoading || execution == null) return;
    final int generation = _selectionGeneration;
    final String familyId = family!.id;
    final String memberId = selected!.id;
    final String date = execution!.date;
    pendingItem = item.id;
    tasksError = null;
    _emit();
    try {
      final DailyExecution result = await _executions.setCompleted(
        familyId,
        memberId,
        date,
        item.id,
        !item.completed,
      );
      if (_selectionCurrent(generation)) execution = result;
    } catch (failure) {
      if (_selectionCurrent(generation)) {
        tasksError = _failure(failure);
        try {
          final DailyExecution result = await _executions.read(
            familyId,
            memberId,
            date,
          );
          if (_selectionCurrent(generation)) execution = result;
        } catch (_) {}
        await _checkUnavailable(tasksError!);
      }
    } finally {
      if (_selectionCurrent(generation)) {
        pendingItem = null;
        _emit();
      }
    }
  }

  bool validName(String value) =>
      value.trim().isNotEmpty && value.trim().length <= 120;
  bool validBirthDate(String value) {
    if (value.trim().isEmpty) return true;
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return false;
    final DateTime? date = DateTime.tryParse(value);
    if (date == null || date.toIso8601String().substring(0, 10) != value) {
      return false;
    }
    final DateTime utc = DateTime.now().toUtc();
    return !date.isAfter(DateTime(utc.year, utc.month, utc.day));
  }

  void clearFormError() {
    formError = null;
    _emit();
  }

  Future<void> reconcileForm() async {
    if (formBusy || !formUncertain) return;
    if (_uncertainTask) {
      await _reconcileTaskDraft();
    } else {
      await loadProfiles();
      formReconciled = profilesError == null;
    }
    _emit();
  }

  void acknowledgeFormUncertain() {
    if (!formReconciled) return;
    formUncertain = false;
    formError = null;
    _emit();
  }

  Future<bool> saveProfile(
    String name,
    MemberType type, {
    FamilyProfile? profile,
    String? birthDate,
    String? color,
    String? completionColor,
  }) async {
    if (family == null || !canEdit || formBusy || formUncertain) return false;
    final String id = family!.id;
    final int generation = _generation;
    formBusy = true;
    formError = null;
    formSavedProfile = null;
    _emit();
    try {
      final FamilyProfile result = await _profiles.save(
        id,
        id: profile?.id,
        name: name,
        type: type,
        birthDate: birthDate,
        color: color,
        completionColor: completionColor,
        updateCompletionColor: profile != null,
      );
      if (!_current(generation)) return false;
      formSavedProfile = result;
      await loadProfiles();
      if (!_current(generation)) return false;
      if (!profiles.any((FamilyProfile entry) => entry.id == result.id)) {
        profiles = List.unmodifiable([...profiles, result]);
      }
      selectProfile(result.id);
      if (profile == null && completionColor != null) {
        final updated = await _profiles.save(
          id,
          id: result.id,
          name: result.name,
          type: result.type,
          birthDate: result.birthDate,
          color: result.color,
          completionColor: completionColor,
          updateCompletionColor: true,
        );
        if (!_current(generation)) return false;
        formSavedProfile = updated;
        profiles = List.unmodifiable([
          for (final entry in profiles)
            entry.id == updated.id ? updated : entry,
        ]);
        selected = updated;
      }
      return true;
    } catch (failure) {
      if (_current(generation)) {
        formError = _failure(failure);
        formUncertain = formError!.uncertainMutation;
        if (formUncertain) {
          _uncertainTask = false;
          await loadProfiles();
          formReconciled = profilesError == null;
        }
        await _checkUnavailable(formError!);
      }
      return false;
    } finally {
      if (_current(generation)) {
        formBusy = false;
        _emit();
      }
    }
  }

  Future<bool> deactivateProfile(FamilyProfile profile) async {
    if (family == null || !canEdit || formBusy || formUncertain) return false;
    final id = family!.id;
    final generation = _generation;
    formBusy = true;
    formError = null;
    _emit();
    try {
      await _profiles.deactivate(id, profile.id);
      if (!_current(generation)) return false;
      profiles = List.unmodifiable(
        profiles.where((entry) => entry.id != profile.id),
      );
      if (selected?.id == profile.id) {
        selected = null;
        ++_selectionGeneration;
        execution = null;
        drawing = null;
        notes = const [];
        notesHasNext = false;
        notesTotal = 0;
        _notePage = 0;
      }
      await loadProfiles();
      return _current(generation);
    } catch (failure) {
      if (_current(generation)) {
        formError = _failure(failure);
        formUncertain = formError!.uncertainMutation;
        if (formUncertain) {
          _uncertainTask = false;
          await loadProfiles();
          formReconciled = profilesError == null;
        }
        await _checkUnavailable(formError!);
      }
      return false;
    } finally {
      if (_current(generation)) {
        formBusy = false;
        _emit();
      }
    }
  }

  Future<bool> addTask(
    String title, {
    Set<String>? memberIds,
    bool repeatDaily = false,
  }) async {
    if (family == null ||
        selected == null ||
        !canEdit ||
        formBusy ||
        formUncertain ||
        execution?.finalized == true) {
      return false;
    }
    final ids = memberIds ?? {selected!.id};
    if (_taskDraft == null &&
        (!validName(title) ||
            ids.isEmpty ||
            ids.any((id) => !profiles.any((profile) => profile.id == id)))) {
      return false;
    }
    final int familyGeneration = _generation;
    final String familyId = family!.id;
    final draft = _taskDraft ??= _TaskDraft(
      title: title,
      memberIds: ids.toList(),
      repeatDaily: repeatDaily,
      date: _clock.date(),
    );
    formBusy = true;
    formError = null;
    _emit();
    try {
      if (draft.repeatDaily && draft.routineId == null) {
        draft.routineId = await _planning.createDailyRoutine(
          familyId,
          draft.title,
          draft.date,
        );
        if (!_current(familyGeneration)) return false;
      }
      while (draft.nextMember < draft.memberIds.length) {
        final memberId = draft.memberIds[draft.nextMember];
        if (draft.repeatDaily) {
          await _planning.addRoutineItem(
            familyId,
            draft.routineId!,
            memberId,
            draft.title,
            draft.nextMember,
          );
        } else {
          await _planning.addDailyItem(
            familyId,
            memberId,
            draft.date,
            draft.title,
          );
        }
        if (!_current(familyGeneration)) return false;
        draft.nextMember++;
      }
      for (final memberId in draft.memberIds) {
        final selectionGeneration = _selectionGeneration;
        final result = await _executions.synchronize(
          familyId,
          memberId,
          draft.date,
        );
        if (!_current(familyGeneration)) return false;
        if (_selectionCurrent(selectionGeneration) &&
            selected?.id == memberId &&
            _clock.date() == draft.date) {
          execution = result;
          tasksError = null;
          _emit();
        }
      }
      return _current(familyGeneration);
    } catch (failure) {
      if (_current(familyGeneration)) {
        formError = _failure(failure);
        formUncertain = formError!.uncertainMutation;
        formReconciled = false;
        if (formUncertain) {
          _uncertainTask = true;
          await _reconcileTaskDraft();
        }
        await _checkUnavailable(formError!);
      }
      return false;
    } finally {
      if (_current(familyGeneration)) {
        formBusy = false;
        _emit();
      }
    }
  }

  Future<void> _reconcileTaskDraft() async {
    final draft = _taskDraft;
    final familyId = family?.id;
    if (draft == null || familyId == null) return;
    final generation = _generation;
    try {
      for (final memberId in draft.memberIds) {
        final result = await _executions.synchronize(
          familyId,
          memberId,
          draft.date,
        );
        if (!_current(generation)) return;
        taskReviewExecutions[memberId] = result;
      }
      await refreshTasks();
      if (_current(generation)) formReconciled = tasksError == null;
    } catch (_) {
      if (_current(generation)) formReconciled = false;
    }
  }

  ScratchpadViewModel createEditor([BoardNote? note]) {
    final current = note ?? notes.first;
    return ScratchpadViewModel(
      repository: NoteScratchpadRepository(_notes, current.id, current.title),
      familyId: family!.id,
      memberId: selected!.id,
      canEdit: canEdit,
    );
  }

  Future<BoardNote?> createNote([String title = '']) async {
    if (!canEdit || selected == null || family == null || noteCreating) {
      return null;
    }
    final familyId = family!.id, memberId = selected!.id;
    final generation = _selectionGeneration;
    final int familyGeneration = _generation;
    final (String, String) key = (familyId, memberId);
    final ({String id, String title})? pending = _pendingNotes[key];
    final ({String id, String title}) draft =
        pending ?? (id: newStrokeId(), title: title);
    noteCreating = true;
    drawingError = null;
    _emit();

    Future<BoardNote> write() async {
      try {
        return await _notes.save(
          familyId,
          memberId,
          draft.id,
          draft.title,
          DrawingDocument(revision: 0, strokes: []),
        );
      } on ApiError catch (failure) {
        if (!failure.uncertainMutation) rethrow;
        if (_current(familyGeneration)) _pendingNotes[key] = draft;
        return _notes.read(familyId, memberId, draft.id);
      }
    }

    try {
      BoardNote note;
      if (pending == null) {
        note = await write();
      } else {
        try {
          note = await _notes.read(familyId, memberId, draft.id);
        } on ApiError catch (failure) {
          if (failure.code != 'NOTE_NOT_FOUND') rethrow;
          // A confirmed absence permits a retry, retaining the original UUID.
          if (!_current(familyGeneration)) return null;
          note = await write();
        }
      }
      if (_current(familyGeneration)) _pendingNotes.remove(key);
      if (!_selectionCurrent(generation)) return null;
      final bool alreadyListed = notes.any((entry) => entry.id == note.id);
      notes = [note, ...notes.where((entry) => entry.id != note.id)];
      if (!alreadyListed) notesTotal++;
      drawing = note.drawing;
      return note;
    } catch (failure) {
      if (_selectionCurrent(generation)) drawingError = _failure(failure);
      return null;
    } finally {
      noteCreating = false;
      _emit();
    }
  }

  Future<void> loadMoreNotes() async {
    if (drawingLoading || !notesHasNext || family == null || selected == null) {
      return;
    }
    final generation = _selectionGeneration;
    final familyId = family!.id, memberId = selected!.id;
    drawingLoading = true;
    drawingError = null;
    _emit();
    try {
      final result = await _notes.list(familyId, memberId, page: _notePage + 1);
      if (!_selectionCurrent(generation)) return;
      final ids = notes.map((note) => note.id).toSet();
      notes = [
        ...notes,
        ...result.items.where((note) => !ids.contains(note.id)),
      ];
      notesHasNext = result.hasNext;
      notesTotal = result.total;
      _notePage++;
    } catch (failure) {
      if (_selectionCurrent(generation)) drawingError = _failure(failure);
    } finally {
      if (_selectionCurrent(generation)) {
        drawingLoading = false;
        _emit();
      }
    }
  }

  Future<void> refreshDrawing() async {
    if (family == null || selected == null) return;
    final int generation = _selectionGeneration;
    drawingLoading = true;
    drawingError = null;
    _emit();
    await _loadDrawing(family!.id, selected!.id, generation);
  }

  Future<void> _checkUnavailable(ApiError failure) async {
    if (failure.code == 'FAMILY_NOT_FOUND') await _workspace.unavailable();
  }

  ApiError _failure(Object failure) => failure is ApiError
      ? failure
      : const ApiError(kind: ApiFailure.invalidResponse);
  @override
  void dispose() {
    _disposed = true;
    ++_generation;
    ++_selectionGeneration;
    _timer?.cancel();
    _workspace.removeListener(_workspaceChanged);
    super.dispose();
  }
}

class _TaskDraft {
  _TaskDraft({
    required this.title,
    required this.memberIds,
    required this.repeatDaily,
    required this.date,
  });

  final String title;
  final List<String> memberIds;
  final bool repeatDaily;
  final String date;
  String? routineId;
  int nextMember = 0;
}
