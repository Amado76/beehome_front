import 'package:beehome/features/scratchpad/models/board_note.dart';
import 'package:beehome/features/scratchpad/repos/remote_notes_repository.dart';
import 'dart:async';
import 'package:beehome/core/auth/models/session_tokens.dart';
import 'package:beehome/core/auth/repos/local_session_repository.dart';
import 'package:beehome/core/auth/services/session_service.dart';
import 'package:beehome/core/preferences/repos/local_app_preferences_repository.dart';
import 'package:beehome/features/family_workspace/models/family.dart';
import 'package:beehome/features/family_workspace/repos/remote_family_repository.dart';
import 'package:beehome/features/family_workspace/services/family_workspace_service.dart';
import 'package:beehome/features/family_workspace/services/family_clock.dart';
import 'package:beehome/features/family_workspace/view_models/family_home_view_model.dart';
import 'package:beehome/features/family_profiles/models/family_profile.dart';
import 'package:beehome/features/family_profiles/repos/remote_profile_repository.dart';
import 'package:beehome/features/daily_execution/models/daily_execution.dart';
import 'package:beehome/features/daily_execution/repos/remote_execution_repository.dart';
import 'package:beehome/features/planning/repos/remote_planning_repository.dart';
import 'package:beehome/features/scratchpad/models/drawing_document.dart';
import 'package:beehome/features/scratchpad/repos/remote_scratchpad_repository.dart';
import 'package:beehome/core/network/models/api_error.dart';

const Family homeFamily = Family(
  id: 'home',
  name: 'Our family',
  role: FamilyRole.owner,
);
const FamilyProfile adult = FamilyProfile(
  id: 'adult',
  familyId: 'home',
  name: 'Alex',
  type: MemberType.adult,
  active: true,
);
const FamilyProfile child = FamilyProfile(
  id: 'child',
  familyId: 'home',
  name: 'Sam',
  type: MemberType.child,
  active: true,
);
const ExecutionItem pendingTask = ExecutionItem(
  id: 'snapshot',
  title: 'Read together',
  status: ExecutionItemStatus.pending,
);

class FakeFamilies implements FamilyRepository {
  List<Family> families = [homeFamily];
  Completer<Family>? delayedRead;
  ApiError? saveError;
  ApiError? listError;
  int createCount = 0;
  @override
  Future<ResultPage<Family>> list({int page = 0}) async {
    if (listError != null) throw listError!;
    return ResultPage(
      items: page == 0 ? families : [],
      page: page,
      hasNext: false,
    );
  }

  @override
  Future<Family> read(String id) async {
    if (delayedRead != null) return delayedRead!.future;
    return families.firstWhere(
      (Family family) => family.id == id,
      orElse: () => throw const ApiError(
        kind: ApiFailure.http,
        status: 404,
        code: 'FAMILY_NOT_FOUND',
      ),
    );
  }

  @override
  Future<Family> create(String name) async {
    ++createCount;
    if (saveError != null) throw saveError!;
    return homeFamily;
  }

  @override
  Future<Family> edit(String id, String name) async {
    if (saveError != null) throw saveError!;
    return homeFamily;
  }
}

class FakeProfiles implements ProfileRepository {
  final List<(String?, String?, bool)> saves = [];
  ApiError? preferenceError;
  final Set<String> inactive = {};
  @override
  Future<FamilyProfile> deactivate(String familyId, String memberId) async {
    inactive.add(memberId);
    return adult;
  }

  @override
  Future<ResultPage<FamilyProfile>> list(
    String familyId, {
    int page = 0,
  }) async => ResultPage(
    items: [
      adult,
      child,
    ].where((profile) => !inactive.contains(profile.id)).toList(),
    page: 0,
    hasNext: false,
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
  }) async {
    saves.add((id, completionColor, updateCompletionColor));
    if (updateCompletionColor && preferenceError != null) {
      throw preferenceError!;
    }
    return adult;
  }
}

class FakeExecutions implements ExecutionRepository {
  Completer<DailyExecution>? delayedRead;
  bool failCommand = false;
  final List<String> reads = [];
  final List<String> synchronizations = [];
  ApiError? synchronizationError;
  final List<String> completedIds = [];
  DailyExecution day(String member, String date, {bool completed = false}) =>
      DailyExecution(
        date: date,
        memberId: member,
        finalized: false,
        items: [
          ExecutionItem(
            id: pendingTask.id,
            title: pendingTask.title,
            status: completed
                ? ExecutionItemStatus.completed
                : ExecutionItemStatus.pending,
          ),
        ],
      );
  @override
  Future<DailyExecution> read(
    String familyId,
    String memberId,
    String date,
  ) async {
    reads.add('$memberId/$date');
    if (memberId == adult.id && delayedRead != null) return delayedRead!.future;
    return day(memberId, date);
  }

  @override
  Future<DailyExecution> synchronize(
    String familyId,
    String memberId,
    String date,
  ) async {
    synchronizations.add('$memberId/$date');
    if (synchronizationError != null) throw synchronizationError!;
    return day(memberId, date);
  }

  @override
  Future<DailyExecution> setCompleted(
    String familyId,
    String memberId,
    String date,
    String itemId,
    bool completed,
  ) async {
    completedIds.add(itemId);
    if (failCommand) {
      throw const ApiError(kind: ApiFailure.timeout, uncertainMutation: true);
    }
    return day(memberId, date, completed: completed);
  }
}

class FakePlanning implements PlanningRepository {
  final List<(String, String)> routines = [];
  final List<String> dailyMembers = [];
  final List<String> routineMembers = [];
  String? failingMember;
  ApiError? itemError;

  void _check(String memberId) {
    if (memberId == failingMember && itemError != null) throw itemError!;
  }

  @override
  Future<String> createDailyRoutine(
    String familyId,
    String title,
    String date,
  ) async {
    routines.add((title, date));
    return 'routine';
  }

  @override
  Future<void> addRoutineItem(
    String familyId,
    String routineId,
    String memberId,
    String title,
    int sortOrder,
  ) async {
    _check(memberId);
    routineMembers.add(memberId);
  }

  @override
  Future<void> addDailyItem(
    String familyId,
    String memberId,
    String date,
    String title,
  ) async {
    _check(memberId);
    dailyMembers.add(memberId);
  }
}

class FakeDrawing implements ScratchpadRepository {
  ApiError? readError;
  DrawingDocument remote = DrawingDocument(revision: 0, strokes: []);
  Completer<DrawingDocument>? pendingSave;
  ApiError? saveError;
  final List<DrawingDocument> writes = [];
  @override
  Future<DrawingDocument> read(String familyId, String memberId) async {
    if (readError != null) throw readError!;
    return remote;
  }

  @override
  Future<DrawingDocument> save(
    String familyId,
    String memberId,
    DrawingDocument document,
  ) async {
    writes.add(document);
    if (saveError != null) throw saveError!;
    if (pendingSave != null) return pendingSave!.future;
    remote = DrawingDocument(
      revision: document.revision + 1,
      title: document.title,
      strokes: document.strokes,
    );
    return remote;
  }
}

class FakeNotes implements NotesRepository {
  @override
  Future<void> delete(
    String familyId,
    String memberId,
    String id,
    int revision,
  ) async {
    final stored = _member(familyId, memberId);
    if (stored[id] != null && stored[id]!.drawing.revision != revision) {
      throw const ApiError(kind: ApiFailure.http, status: 409);
    }
    stored.remove(id);
  }

  FakeNotes(this.drawings);
  final FakeDrawing drawings;
  ApiError? readError;
  ApiError? lostSaveResponse;
  final List<String> savedIds = [];
  final Map<String, Map<String, BoardNote>> stored = {};
  Map<String, BoardNote> _member(String family, String member) =>
      stored.putIfAbsent('$family/$member', () => {});
  @override
  Future<BoardNotePage> list(
    String familyId,
    String memberId, {
    int page = 0,
  }) async => BoardNotePage(_member(familyId, memberId).values.toList(), false);
  @override
  Future<BoardNote> read(String familyId, String memberId, String id) async {
    if (readError != null) throw readError!;
    final BoardNote? note = _member(familyId, memberId)[id];
    if (note == null) {
      throw const ApiError(
        kind: ApiFailure.http,
        status: 404,
        code: 'NOTE_NOT_FOUND',
      );
    }
    return note;
  }

  @override
  Future<BoardNote> save(
    String familyId,
    String memberId,
    String id,
    String title,
    DrawingDocument drawing,
  ) async {
    savedIds.add(id);
    final saved = await drawings.save(familyId, memberId, drawing);
    final note = BoardNote(
      id: id,
      title: title,
      drawing: DrawingDocument(
        revision: saved.revision,
        title: title,
        strokes: saved.strokes,
      ),
    );
    _member(familyId, memberId)[id] = note;
    if (lostSaveResponse != null) throw lostSaveResponse!;
    return note;
  }
}

class WorkspaceHarness {
  final MemoryAppPreferencesRepository preferences =
      MemoryAppPreferencesRepository();
  final FakeFamilies families = FakeFamilies();
  final FakeProfiles profiles = FakeProfiles();
  final FakeExecutions executions = FakeExecutions();
  final FakePlanning planning = FakePlanning();
  final FakeDrawing drawings = FakeDrawing();
  late final FakeNotes notes = FakeNotes(drawings);
  late final SessionService session = SessionService(
    MemorySessionRepository(),
    preferences,
  );
  late final FamilyWorkspaceService workspace = FamilyWorkspaceService(
    repository: families,
    preferences: preferences,
    session: session,
  );
  late final FamilyHomeViewModel home = FamilyHomeViewModel(
    workspace: workspace,
    profiles: profiles,
    executions: executions,
    planning: planning,
    notes: notes,
    clock: FamilyClock(now: () => DateTime(2026, 10, 3, 12)),
  );
  Future<void> start() async {
    workspace;
    home;
    await session.replace(const SessionTokens('access', 'refresh'));
    await settle();
  }

  Future<void> settle() async {
    for (int i = 0; i < 15; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  void dispose() {
    home.dispose();
    workspace.dispose();
    session.dispose();
  }
}
