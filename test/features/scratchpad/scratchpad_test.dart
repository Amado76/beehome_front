import 'dart:async';
import 'package:beehome/core/network/models/api_error.dart';
import 'package:beehome/features/scratchpad/models/drawing_document.dart';
import 'package:beehome/features/scratchpad/view_models/scratchpad_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import '../family_workspace/support/workspace_fakes.dart';

void write(ScratchpadViewModel vm, int pointer) {
  vm.begin(pointer, .1, .2);
  vm.move(pointer, .3, .4);
  vm.end(pointer);
}

ScratchpadViewModel editor(FakeDrawing repo, {bool canEdit = true}) =>
    ScratchpadViewModel(
      repository: repo,
      familyId: 'home',
      memberId: 'adult',
      canEdit: canEdit,
    );

void main() {
  test('an optional title saves without drawing and can be removed', () async {
    final repo = FakeDrawing()
      ..remote = DrawingDocument(revision: 1, title: '', strokes: []);
    final vm = editor(repo);
    addTearDown(vm.dispose);
    await vm.load();
    vm.setTitle('Shopping');
    expect(vm.dirty, isTrue);
    expect(await vm.save(), isTrue);
    expect(repo.remote.title, 'Shopping');
    expect(repo.remote.strokes, isEmpty);
    vm.setTitle('');
    expect(await vm.save(), isTrue);
    expect(repo.remote.title, '');
  });
  test('equal strokes with a different title remain a conflict', () async {
    final repo = FakeDrawing()
      ..remote = DrawingDocument(revision: 1, title: '', strokes: []);
    final vm = editor(repo);
    addTearDown(vm.dispose);
    await vm.load();
    vm.setTitle('Local');
    repo.remote = DrawingDocument(revision: 2, title: 'Remote', strokes: []);
    repo.saveError = const ApiError(kind: ApiFailure.http, status: 409);
    expect(await vm.save(), isFalse);
    expect(vm.conflict?.title, 'Remote');
    vm.useRemote();
    expect(vm.title, 'Remote');
    expect(vm.dirty, isFalse);
  });

  test(
    'finger input emits canonical strokes and omits unavailable pressure',
    () async {
      final FakeDrawing repo = FakeDrawing();
      final ScratchpadViewModel vm = editor(repo);
      addTearDown(vm.dispose);
      await vm.load();
      write(vm, 1);
      await vm.save();
      final DrawingStroke stroke = repo.writes.single.strokes.single;
      expect(stroke.points.first.toJson(), {'x': .1, 'y': .2});
      expect(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ).hasMatch(stroke.id),
        isTrue,
      );
      expect(vm.dirty, isFalse);
    },
  );
  test(
    'edits made during save survive and use the returned revision',
    () async {
      final FakeDrawing repo = FakeDrawing()
        ..pendingSave = Completer<DrawingDocument>();
      final ScratchpadViewModel vm = editor(repo);
      addTearDown(vm.dispose);
      await vm.load();
      write(vm, 1);
      final Future<bool> saving = vm.save();
      write(vm, 2);
      repo.pendingSave!.complete(
        DrawingDocument(revision: 1, strokes: repo.writes.first.strokes),
      );
      await saving;
      expect(vm.strokes.length, 2);
      expect(vm.dirty, isTrue);
      repo.pendingSave = null;
      await vm.save();
      expect(repo.writes.last.revision, 1);
      expect(repo.writes.last.strokes.length, 2);
      expect(vm.dirty, isFalse);
    },
  );
  test(
    'revision conflict preserves local strokes until a deliberate choice',
    () async {
      final FakeDrawing repo = FakeDrawing();
      final ScratchpadViewModel vm = editor(repo);
      addTearDown(vm.dispose);
      await vm.load();
      write(vm, 1);
      repo.remote = DrawingDocument(revision: 4, strokes: []);
      repo.saveError = const ApiError(
        kind: ApiFailure.http,
        status: 409,
        code: 'DRAWING_VERSION_CONFLICT',
      );
      await vm.save();
      expect(vm.conflict?.revision, 4);
      expect(vm.strokes.length, 1);
      expect(vm.dirty, isTrue);
      vm.useRemote();
      expect(vm.strokes, isEmpty);
      expect(vm.dirty, isFalse);
    },
  );
  test(
    'lost save response is reconciled without writing the document twice',
    () async {
      final FakeDrawing repo = FakeDrawing();
      final ScratchpadViewModel vm = editor(repo);
      addTearDown(vm.dispose);
      await vm.load();
      write(vm, 1);
      repo.remote = DrawingDocument(revision: 1, strokes: vm.strokes);
      repo.saveError = const ApiError(
        kind: ApiFailure.timeout,
        uncertainMutation: true,
      );
      expect(await vm.save(), isTrue);
      expect(vm.dirty, isFalse);
      expect(vm.conflict, isNull);
      expect(repo.writes.length, 1);
    },
  );
  test(
    'an uncertain write is not retried before a successful reconciliation read',
    () async {
      final FakeDrawing repo = FakeDrawing();
      final ScratchpadViewModel vm = editor(repo);
      addTearDown(vm.dispose);
      await vm.load();
      write(vm, 1);
      repo.saveError = const ApiError(
        kind: ApiFailure.timeout,
        uncertainMutation: true,
      );
      repo.readError = const ApiError(kind: ApiFailure.connection);
      await vm.save();
      write(vm, 2);
      await vm.save();
      expect(repo.writes.length, 1);
      expect(vm.strokes.length, 2);
      repo.readError = null;
      repo.remote = DrawingDocument(
        revision: 1,
        strokes: repo.writes.first.strokes,
      );
      repo.saveError = null;
      await vm.save();
      expect(repo.writes.last.revision, 1);
      expect(repo.writes.last.strokes.length, 2);
    },
  );
  test('read-only members cannot draw or save', () async {
    final FakeDrawing repo = FakeDrawing();
    final ScratchpadViewModel vm = editor(repo, canEdit: false);
    addTearDown(vm.dispose);
    await vm.load();
    write(vm, 1);
    await vm.save();
    expect(vm.strokes, isEmpty);
    expect(repo.writes, isEmpty);
  });
  test(
    'undo and clear preserve whole-document persistence semantics',
    () async {
      final FakeDrawing repo = FakeDrawing();
      final ScratchpadViewModel vm = editor(repo);
      addTearDown(vm.dispose);
      await vm.load();
      write(vm, 1);
      vm.undo();
      expect(vm.strokes, isEmpty);
      vm.redo();
      expect(vm.strokes.length, 1);
      await vm.save();
      vm.clear();
      await vm.save();
      expect(repo.writes.last.revision, 1);
      expect(repo.writes.last.strokes, isEmpty);
    },
  );
}
