import 'package:get_it/get_it.dart';
import '../../../features/scratchpad/repos/remote_notes_repository.dart';
import '../../../core/auth/services/session_service.dart';
import '../../../core/network/clients/api_client.dart';
import '../../../core/preferences/repos/local_app_preferences_repository.dart';
import '../../../features/family_workspace/repos/remote_family_repository.dart';
import '../../../features/family_workspace/services/family_workspace_service.dart';
import '../../../features/family_workspace/services/family_clock.dart';
import '../../../features/family_workspace/view_models/family_home_view_model.dart';
import '../../../features/family_profiles/repos/remote_profile_repository.dart';
import '../../../features/daily_execution/repos/remote_execution_repository.dart';
import '../../../features/planning/repos/remote_planning_repository.dart';
import '../../../features/scratchpad/repos/remote_scratchpad_repository.dart';

void registerFamilyWorkspaceDependencies(GetIt container) {
  container.registerLazySingleton<FamilyRepository>(
    () => RemoteFamilyRepository(container<ApiClient>()),
  );
  container.registerLazySingleton<ProfileRepository>(
    () => RemoteProfileRepository(container<ApiClient>()),
  );
  container.registerLazySingleton<ExecutionRepository>(
    () => RemoteExecutionRepository(container<ApiClient>()),
  );
  container.registerLazySingleton<PlanningRepository>(
    () => RemotePlanningRepository(container<ApiClient>()),
  );
  container.registerLazySingleton<ScratchpadRepository>(
    () => RemoteScratchpadRepository(container<ApiClient>()),
  );
  container.registerLazySingleton<NotesRepository>(
    () => RemoteNotesRepository(container<ApiClient>()),
  );
  container.registerLazySingleton<FamilyClock>(FamilyClock.new);
  container.registerLazySingleton<FamilyWorkspaceService>(
    () => FamilyWorkspaceService(
      repository: container<FamilyRepository>(),
      preferences: container<AppPreferencesRepository>(),
      session: container<SessionService>(),
    ),
    dispose: (FamilyWorkspaceService service) => service.dispose(),
  );
  container.registerFactory<FamilyHomeViewModel>(
    () => FamilyHomeViewModel(
      workspace: container<FamilyWorkspaceService>(),
      profiles: container<ProfileRepository>(),
      executions: container<ExecutionRepository>(),
      planning: container<PlanningRepository>(),
      notes: container<NotesRepository>(),
      clock: container<FamilyClock>(),
    ),
  );
}
