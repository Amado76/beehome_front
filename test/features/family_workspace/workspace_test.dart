import 'package:beehome/features/planning/repos/remote_planning_repository.dart';
import 'package:beehome/core/network/clients/api_client.dart';
import 'package:beehome/features/family_workspace/repos/remote_family_repository.dart';
import 'package:beehome/features/daily_execution/repos/remote_execution_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:beehome/core/network/models/api_error.dart';
import 'package:beehome/features/family_workspace/models/family.dart';
import 'package:beehome/features/daily_execution/models/daily_execution.dart';

class RecordingApi implements ApiClient {
  final List<(String, String, Object?)> calls = [];
  Object? response;
  @override
  Future<Object?> request(
    String path, {
    String method = 'GET',
    Object? data,
    Map<String, Object?>? queryParameters,
    bool protected = true,
  }) async {
    calls.add((path, method, data));
    return response;
  }

  @override
  void close() {}
}

void main() {
  test(
    'daily routine requests all weekdays and an inclusive start date',
    () async {
      final api = RecordingApi()..response = {'id': 'routine'};
      final repo = RemotePlanningRepository(api);
      expect(
        await repo.createDailyRoutine('family', 'Brush teeth', '2026-10-03'),
        'routine',
      );
      expect(api.calls.single.$1, '/api/families/family/routines');
      expect(api.calls.single.$2, 'POST');
      expect(api.calls.single.$3, {
        'name': 'Brush teeth',
        'startDate': '2026-10-03',
        'daysOfWeek': [
          'MONDAY',
          'TUESDAY',
          'WEDNESDAY',
          'THURSDAY',
          'FRIDAY',
          'SATURDAY',
          'SUNDAY',
        ],
      });
      await repo.addRoutineItem('family', 'routine', 'child', 'Brush teeth', 1);
      expect(api.calls.last.$1, '/api/families/family/routines/routine/items');
      expect(api.calls.last.$2, 'POST');
      expect(api.calls.last.$3, {
        'familyMemberId': 'child',
        'title': 'Brush teeth',
        'sortOrder': 1,
      });
    },
  );

  test('malformed routine creation response blocks blind retries', () async {
    final api = RecordingApi()..response = {};
    await expectLater(
      RemotePlanningRepository(
        api,
      ).createDailyRoutine('family', 'Brush teeth', '2026-10-03'),
      throwsA(
        isA<ApiError>().having(
          (error) => error.uncertainMutation,
          'uncertain',
          isTrue,
        ),
      ),
    );
  });

  test(
    'family creation sends only a name and accepts a response without timezone',
    () async {
      final RecordingApi api = RecordingApi()
        ..response = {
          'id': 'family',
          'name': 'Home',
          'myRole': 'OWNER',
          'createdAt': '2026-10-03T00:00:00Z',
          'updatedAt': '2026-10-03T00:00:00Z',
        };
      final RemoteFamilyRepository repo = RemoteFamilyRepository(api);
      final Family family = await repo.create('Home');
      expect(family.name, 'Home');
      expect(api.calls.single.$1, '/api/families');
      expect(api.calls.single.$2, 'POST');
      expect(api.calls.single.$3, {'name': 'Home'});
    },
  );

  test('malformed creation response is an uncertain mutation', () async {
    final RecordingApi api = RecordingApi()..response = {'id': 'unknown'};
    await expectLater(
      RemoteFamilyRepository(api).create('Home'),
      throwsA(
        isA<ApiError>().having(
          (ApiError error) => error.uncertainMutation,
          'uncertain',
          isTrue,
        ),
      ),
    );
  });
  test('completion uses execution item IDs and a bodyless command', () async {
    final RecordingApi api = RecordingApi()
      ..response = {
        'id': 'execution',
        'date': '2026-10-03',
        'status': 'OPEN',
        'reopened': false,
        'member': {'id': 'member'},
        'items': [
          {
            'id': 'snapshot',
            'title': 'Read',
            'status': 'COMPLETED',
            'scheduledTime': null,
            'description': null,
          },
          {
            'id': 'cancelled',
            'title': 'Removed',
            'status': 'CANCELLED',
            'scheduledTime': null,
            'description': null,
          },
        ],
      };
    final RemoteExecutionRepository repo = RemoteExecutionRepository(api);
    final DailyExecution execution = await repo.setCompleted(
      'family',
      'member',
      '2026-10-03',
      'snapshot',
      true,
    );
    expect(api.calls.single, (
      '/api/families/family/members/member/executions/2026-10-03/items/snapshot/complete',
      'POST',
      null,
    ));
    expect(execution.visibleItems.length, 1);
    expect(execution.completed, 1);
  });
}
