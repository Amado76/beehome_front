import 'dart:async';
import 'package:beehome/core/network/models/api_error.dart';
import 'package:beehome/features/family_workspace/services/family_clock.dart';
import 'package:beehome/features/family_workspace/models/family.dart';
import 'package:beehome/features/daily_execution/models/daily_execution.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/workspace_fakes.dart';

void main() {
  test(
    'a lost create response retains its UUID until reconciliation succeeds',
    () async {
      final harness = WorkspaceHarness();
      addTearDown(harness.dispose);
      await harness.start();
      harness.notes.lostSaveResponse = const ApiError(
        kind: ApiFailure.timeout,
        uncertainMutation: true,
      );
      harness.notes.readError = const ApiError(kind: ApiFailure.connection);
      expect(await harness.home.createNote('Original'), isNull);
      expect(await harness.home.createNote('Retry'), isNull);
      expect(harness.notes.savedIds, hasLength(1));
      harness.notes.readError = null;
      harness.notes.lostSaveResponse = null;
      final note = await harness.home.createNote('Retry');
      expect(note?.id, harness.notes.savedIds.single);
      expect(note?.title, 'Original');
      expect(harness.home.notes, hasLength(1));
      expect(harness.notes.savedIds, hasLength(1));
    },
  );

  test('an absent uncertain create retries the same UUID and title', () async {
    final harness = WorkspaceHarness();
    addTearDown(harness.dispose);
    await harness.start();
    harness.drawings.saveError = const ApiError(
      kind: ApiFailure.timeout,
      uncertainMutation: true,
    );
    expect(await harness.home.createNote('Original'), isNull);
    final id = harness.notes.savedIds.single;
    harness.drawings.saveError = null;
    final note = await harness.home.createNote('Retry');
    expect(note?.id, id);
    expect(note?.title, 'Original');
    expect(harness.notes.savedIds, [id, id]);
    expect(harness.home.notes, hasLength(1));
  });

  test(
    'deleting a note cancels pending autosave and preserves the other notes',
    () async {
      final harness = WorkspaceHarness();
      addTearDown(harness.dispose);
      await harness.start();
      final first = await harness.home.createNote('Keep');
      final second = await harness.home.createNote('Delete');
      final editor = harness.home.createEditor(second);
      addTearDown(editor.dispose);
      await editor.load();
      editor.setTitle('Unsaved title');
      expect(await editor.deleteNote(), isTrue);
      expect(await editor.save(), isFalse);
      await harness.home.refreshDrawing();
      expect(harness.home.notes.single.id, first!.id);
      expect(harness.home.notes.single.title, 'Keep');
      expect(editor.editable, isFalse);
    },
  );

  test(
    'creates separate notes and keeps edits scoped to the chosen profile',
    () async {
      final harness = WorkspaceHarness();
      addTearDown(harness.dispose);
      await harness.start();
      final first = await harness.home.createNote('First');
      final second = await harness.home.createNote('Second');
      expect(first, isNotNull);
      expect(second!.id, isNot(first!.id));
      expect(harness.home.notes.map((note) => note.title), ['Second', 'First']);
      final editor = harness.home.createEditor(first);
      await editor.load();
      editor.begin(1, .1, .1);
      editor.move(1, .2, .2);
      editor.end(1);
      expect(await editor.save(), isTrue);
      editor.dispose();
      await harness.home.refreshDrawing();
      expect(
        harness.home.notes
            .firstWhere((note) => note.id == first.id)
            .drawing
            .strokes,
        hasLength(1),
      );
      expect(
        harness.home.notes
            .firstWhere((note) => note.id == second.id)
            .drawing
            .strokes,
        isEmpty,
      );
      harness.home.selectProfile(child.id);
      await harness.settle();
      expect(harness.home.hasBoard, isTrue);
      expect(harness.home.notes, isEmpty);
      await harness.home.createNote('Child note');
      expect(harness.home.notes.single.title, 'Child note');
      harness.home.selectProfile(adult.id);
      await harness.settle();
      expect(harness.home.notes, hasLength(2));
    },
  );

  test('an empty account can create its family only once', () async {
    final harness = WorkspaceHarness();
    addTearDown(harness.dispose);
    harness.families.families = [];
    await harness.start();
    expect(await harness.home.saveFamily('Home'), isTrue);
    expect(harness.workspace.active?.id, homeFamily.id);
    expect(await harness.home.saveFamily('Another family'), isFalse);
    expect(harness.families.createCount, 1);
  });

  test(
    'login selects a family automatically even when more than one is available',
    () async {
      final harness = WorkspaceHarness();
      harness.families.families = [
        homeFamily,
        const Family(
          id: 'second',
          name: 'Another family',
          role: FamilyRole.owner,
        ),
      ];
      addTearDown(harness.dispose);
      await harness.start();
      expect(harness.workspace.active?.id, homeFamily.id);
      expect(await harness.preferences.selectedFamilyId(), homeFamily.id);
      expect(await harness.home.saveFamily('Another family'), isFalse);
      expect(harness.families.createCount, 0);
      expect(harness.workspace.active?.id, homeFamily.id);
      expect(harness.families.families, hasLength(2));
    },
  );
  test(
    'new profile persists completion color with a separate preference patch',
    () async {
      final harness = WorkspaceHarness();
      addTearDown(harness.dispose);
      await harness.start();
      expect(
        await harness.home.saveProfile(
          'Alex',
          adult.type,
          color: '#BFDBFE',
          completionColor: '#BBF7D0',
        ),
        isTrue,
      );
      expect(harness.profiles.saves, [
        (null, '#BBF7D0', false),
        (adult.id, '#BBF7D0', true),
      ]);
    },
  );
  test(
    'failed preference patch keeps the created profile available for editing',
    () async {
      final harness = WorkspaceHarness();
      addTearDown(harness.dispose);
      await harness.start();
      harness.profiles.preferenceError = const ApiError(
        kind: ApiFailure.timeout,
        uncertainMutation: true,
      );
      expect(
        await harness.home.saveProfile(
          'Alex',
          adult.type,
          completionColor: '#BBF7D0',
        ),
        isFalse,
      );
      expect(harness.home.formSavedProfile?.id, adult.id);
      expect(harness.home.formUncertain, isTrue);
      harness.profiles.preferenceError = null;
      harness.home.acknowledgeFormUncertain();
      expect(
        await harness.home.saveProfile(
          'Alex',
          adult.type,
          profile: harness.home.formSavedProfile,
          completionColor: '#BBF7D0',
        ),
        isTrue,
      );
      expect(
        harness.profiles.saves.where((call) => call.$1 == null),
        hasLength(1),
      );
    },
  );
  test(
    'removing a member clears its selected execution and selects an active member',
    () async {
      final harness = WorkspaceHarness();
      addTearDown(harness.dispose);
      await harness.start();
      expect(await harness.home.deactivateProfile(adult), isTrue);
      expect(harness.home.profiles.map((profile) => profile.id), [child.id]);
      expect(harness.home.selected?.id, child.id);
      expect(harness.home.execution?.memberId, child.id);
      expect(harness.home.drawing, isNull);
    },
  );
  test('editing the family name requires no timezone', () async {
    final WorkspaceHarness harness = WorkspaceHarness();
    addTearDown(harness.dispose);
    await harness.start();
    expect(await harness.home.saveFamily('Renamed', edit: true), isTrue);
  });
  test('header clock converts UTC instants to device-local time', () {
    final DateTime instant = DateTime.utc(2026, 10, 3, 1);
    final FamilyClock clock = FamilyClock(now: () => instant);
    expect(clock.localNow, instant.toLocal());
    expect(clock.localNow.isUtc, isFalse);
  });
  test('execution day follows the local device date across midnight', () {
    DateTime time = DateTime(2026, 10, 2, 23, 59);
    final FamilyClock clock = FamilyClock(now: () => time);
    expect(clock.date(), '2026-10-02');
    time = DateTime(2026, 10, 3);
    expect(clock.date(), '2026-10-03');
  });
  test(
    'sole family is selected and selection is cleared on sign-out',
    () async {
      final WorkspaceHarness harness = WorkspaceHarness();
      addTearDown(harness.dispose);
      await harness.start();
      expect(harness.workspace.active?.id, 'home');
      expect(await harness.preferences.selectedFamilyId(), 'home');
      expect(harness.home.selected?.id, adult.id);
      await harness.session.clear();
      await harness.settle();
      expect(harness.home.profiles, isEmpty);
      expect(harness.home.drawing, isNull);
      expect(await harness.preferences.selectedFamilyId(), isNull);
    },
  );
  test('late family read cannot restore private data after sign-out', () async {
    final WorkspaceHarness harness = WorkspaceHarness();
    addTearDown(harness.dispose);
    await harness.start();
    harness.families.delayedRead = Completer<Family>();
    final Future<void> request = harness.workspace.reload();
    await harness.settle();
    await harness.session.clear();
    harness.families.delayedRead!.complete(homeFamily);
    await request;
    expect(harness.workspace.active, isNull);
    expect(harness.home.selected, isNull);
  });
  test(
    'uncertain creation is reconciled and requires review before another POST',
    () async {
      final WorkspaceHarness harness = WorkspaceHarness();
      addTearDown(harness.dispose);
      harness.families.families = [];
      await harness.start();
      harness.families.saveError = const ApiError(
        kind: ApiFailure.timeout,
        uncertainMutation: true,
      );
      expect(await harness.workspace.save('New'), isFalse);
      expect(harness.workspace.uncertain, isTrue);
      await harness.workspace.save('New');
      expect(harness.families.createCount, 1);
      harness.families.families = [homeFamily];
      await harness.workspace.reconcileUncertain();
      harness.workspace.acknowledgeUncertain();
      expect(harness.workspace.active?.id, homeFamily.id);
      expect(await harness.workspace.save('New'), isFalse);
      expect(harness.families.createCount, 1);
    },
  );
  test('failed reconciliation keeps another family creation blocked', () async {
    final WorkspaceHarness harness = WorkspaceHarness();
    addTearDown(harness.dispose);
    harness.families.families = [];
    await harness.start();
    harness.families.saveError = const ApiError(
      kind: ApiFailure.timeout,
      uncertainMutation: true,
    );
    harness.families.listError = const ApiError(kind: ApiFailure.connection);
    await harness.workspace.save('New');
    harness.workspace.acknowledgeUncertain();
    expect(harness.workspace.uncertain, isTrue);
    await harness.workspace.save('New');
    expect(harness.families.createCount, 1);
    harness.families.listError = null;
    await harness.workspace.reconcileUncertain();
    harness.workspace.acknowledgeUncertain();
    expect(harness.workspace.uncertain, isFalse);
  });
  test(
    'late profile execution does not replace the newly selected profile',
    () async {
      final WorkspaceHarness harness = WorkspaceHarness();
      addTearDown(harness.dispose);
      await harness.start();
      harness.executions.delayedRead = Completer<DailyExecution>();
      final Future<void> previous = harness.home.loadSelected();
      harness.home.selectProfile(child.id);
      await harness.settle();
      expect(harness.home.execution?.memberId, child.id);
      expect(harness.home.hasBoard, isTrue);
      harness.executions.delayedRead!.complete(
        harness.executions.day(adult.id, '2026-10-03'),
      );
      await previous;
      expect(harness.home.execution?.memberId, child.id);
      expect(harness.home.drawing, isNull);
    },
  );
  test('failed completion reloads state and does not claim success', () async {
    final WorkspaceHarness harness = WorkspaceHarness();
    addTearDown(harness.dispose);
    await harness.start();
    harness.executions.failCommand = true;
    await harness.home.toggle(pendingTask);
    expect(harness.home.execution?.completed, 0);
    expect(harness.home.tasksError, isNotNull);
    expect(harness.home.pendingItem, isNull);
    expect(harness.executions.completedIds, ['snapshot']);
  });
}
