import 'package:beehome/core/network/models/api_error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/workspace_fakes.dart';

void main() {
  test('one-off task is assigned to every selected profile', () async {
    final harness = WorkspaceHarness();
    addTearDown(harness.dispose);
    await harness.start();
    expect(
      await harness.home.addTask(
        'Brush teeth',
        memberIds: {adult.id, child.id},
      ),
      isTrue,
    );
    expect(harness.planning.dailyMembers, [adult.id, child.id]);
    expect(harness.planning.routines, isEmpty);
    expect(harness.executions.synchronizations, [
      '${adult.id}/2026-10-03',
      '${child.id}/2026-10-03',
    ]);
  });

  test(
    'daily task shares one routine starting today across profiles',
    () async {
      final harness = WorkspaceHarness();
      addTearDown(harness.dispose);
      await harness.start();
      expect(
        await harness.home.addTask(
          'Brush teeth',
          memberIds: {adult.id, child.id},
          repeatDaily: true,
        ),
        isTrue,
      );
      expect(harness.planning.routines, [('Brush teeth', '2026-10-03')]);
      expect(harness.planning.routineMembers, [adult.id, child.id]);
      expect(harness.planning.dailyMembers, isEmpty);
      expect(harness.executions.synchronizations, [
        '${adult.id}/2026-10-03',
        '${child.id}/2026-10-03',
      ]);
    },
  );

  for (final repeatDaily in [false, true]) {
    test(
      'partial failure resumes without duplicates (daily: $repeatDaily)',
      () async {
        final harness = WorkspaceHarness();
        addTearDown(harness.dispose);
        await harness.start();
        harness.planning.failingMember = child.id;
        harness.planning.itemError = const ApiError(
          kind: ApiFailure.http,
          status: 400,
        );
        expect(
          await harness.home.addTask(
            'Brush teeth',
            memberIds: {adult.id, child.id},
            repeatDaily: repeatDaily,
          ),
          isFalse,
        );
        harness.planning.itemError = null;
        expect(
          await harness.home.addTask(
            'Brush teeth',
            memberIds: {adult.id, child.id},
            repeatDaily: repeatDaily,
          ),
          isTrue,
        );
        expect(
          repeatDaily
              ? harness.planning.routineMembers
              : harness.planning.dailyMembers,
          [adult.id, child.id],
        );
        expect(harness.planning.routines.length, repeatDaily ? 1 : 0);
      },
    );
  }

  test(
    'ambiguous write blocks another create and reviews all profiles',
    () async {
      final harness = WorkspaceHarness();
      addTearDown(harness.dispose);
      await harness.start();
      harness.planning.failingMember = child.id;
      harness.planning.itemError = const ApiError(
        kind: ApiFailure.timeout,
        uncertainMutation: true,
      );
      expect(
        await harness.home.addTask(
          'Brush teeth',
          memberIds: {adult.id, child.id},
        ),
        isFalse,
      );
      expect(harness.home.formUncertain, isTrue);
      expect(harness.home.taskReviewExecutions.keys, [adult.id, child.id]);
      expect(await harness.home.addTask('Brush teeth'), isFalse);
      expect(harness.planning.dailyMembers, [adult.id]);
    },
  );

  test(
    'saving updates the visible execution from the synchronization',
    () async {
      final harness = WorkspaceHarness();
      addTearDown(harness.dispose);
      await harness.start();
      harness.home.execution = null;
      expect(await harness.home.addTask('Brush teeth'), isTrue);
      expect(harness.home.execution?.memberId, adult.id);
      expect(harness.home.execution?.visibleItems, isNotEmpty);
      expect(harness.executions.synchronizations, ['${adult.id}/2026-10-03']);
    },
  );

  test(
    'failed sync can be retried without creating the assignments again',
    () async {
      final harness = WorkspaceHarness();
      addTearDown(harness.dispose);
      await harness.start();
      harness.executions.synchronizationError = const ApiError(
        kind: ApiFailure.http,
        status: 403,
      );
      expect(
        await harness.home.addTask(
          'Brush teeth',
          memberIds: {adult.id, child.id},
        ),
        isFalse,
      );
      harness.executions.synchronizationError = null;
      expect(
        await harness.home.addTask(
          'Brush teeth',
          memberIds: {adult.id, child.id},
        ),
        isTrue,
      );
      expect(harness.planning.dailyMembers, [adult.id, child.id]);
      expect(harness.executions.synchronizations, [
        '${adult.id}/2026-10-03',
        '${adult.id}/2026-10-03',
        '${child.id}/2026-10-03',
      ]);
    },
  );

  test('empty selection creates nothing', () async {
    final harness = WorkspaceHarness();
    addTearDown(harness.dispose);
    await harness.start();
    expect(await harness.home.addTask('Brush teeth', memberIds: {}), isFalse);
    expect(harness.planning.dailyMembers, isEmpty);
    expect(harness.home.taskStarted, isFalse);
  });
}
