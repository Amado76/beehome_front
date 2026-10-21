import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/auth/services/session_service.dart';
import '../../../core/network/models/api_error.dart';
import '../../../core/preferences/repos/local_app_preferences_repository.dart';
import '../models/family.dart';
import '../repos/remote_family_repository.dart';

class FamilyWorkspaceService extends ChangeNotifier {
  FamilyWorkspaceService({
    required FamilyRepository repository,
    required AppPreferencesRepository preferences,
    required SessionService session,
  }) : _repository = repository,
       _preferences = preferences,
       _session = session {
    _session.addListener(_sessionChanged);
    _sessionChanged();
  }
  final FamilyRepository _repository;
  final AppPreferencesRepository _preferences;
  final SessionService _session;
  Family? active;
  List<Family> families = const [];
  bool busy = false;
  ApiError? error;
  bool uncertain = false;
  bool reconciled = false;
  String? _uncertainFamilyId;
  String? _actor;
  int _generation = 0;
  bool _disposed = false;
  Future<void> _writes = Future<void>.value();

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  bool _current(int generation) => !_disposed && generation == _generation;
  Future<void> _persist(String? id, int generation) {
    final Future<void> write = _writes.then((_) async {
      if (_current(generation)) await _preferences.setSelectedFamilyId(id);
    });
    _writes = write.catchError((Object _) {});
    return write;
  }

  void _sessionChanged() {
    final String? actor = _session.state == SessionState.signedIn
        ? (_session.user?.id ?? 'session')
        : null;
    if (actor == _actor) return;
    final bool hadActor = _actor != null;
    _actor = actor;
    final int generation = ++_generation;
    active = null;
    families = const [];
    busy = false;
    error = null;
    uncertain = false;
    if (hadActor) {
      unawaited(_persist(null, generation).catchError((Object _) {}));
    }
    _emit();
    if (actor != null) unawaited(reload());
  }

  Future<void> reload({bool restoreSaved = true}) async {
    if (_actor == null || _disposed) return;
    final int generation = ++_generation;
    busy = true;
    error = null;
    active = null;
    families = const [];
    _emit();
    try {
      final String? saved = restoreSaved
          ? await _preferences.selectedFamilyId()
          : null;
      if (!_current(generation)) return;
      if (saved != null) {
        try {
          final Family family = await _repository.read(saved);
          if (!_current(generation)) return;
          active = family;
          return;
        } on ApiError catch (failure) {
          if (failure.status != 404) rethrow;
          await _persist(null, generation);
        }
      }
      final ResultPage<Family> result = await _repository.list();
      if (!_current(generation)) return;
      families = result.items;
      if (families.isNotEmpty) {
        final Family family = await _repository.read(families.first.id);
        if (!_current(generation)) return;
        active = family;
        await _persist(family.id, generation);
      }
    } catch (failure) {
      if (_current(generation)) error = _failure(failure);
    } finally {
      if (_current(generation)) {
        busy = false;
        _emit();
      }
    }
  }

  Future<bool> save(String name, {bool edit = false}) async {
    if (busy || uncertain || (edit && active?.canEdit != true)) return false;
    if (!edit && (active != null || families.isNotEmpty)) return false;
    final int generation = _generation;
    final String? previousId = active?.id;
    busy = true;
    error = null;
    _emit();
    try {
      final Family result = edit
          ? await _repository.edit(previousId!, name)
          : await _repository.create(name);
      if (!_current(generation)) return false;
      active = result;
      await _persist(result.id, generation).catchError((Object _) {});
      return true;
    } catch (failure) {
      if (!_current(generation)) return false;
      error = _failure(failure);
      if (error!.uncertainMutation) {
        uncertain = true;
        reconciled = false;
        _uncertainFamilyId = edit ? previousId : null;
        await _reconcile(generation);
      }
      return false;
    } finally {
      if (_current(generation)) {
        busy = false;
        _emit();
      }
    }
  }

  Future<void> reconcileUncertain() async {
    if (busy || !uncertain) return;
    final int generation = _generation;
    busy = true;
    _emit();
    await _reconcile(generation);
    if (_current(generation)) {
      busy = false;
      _emit();
    }
  }

  Future<void> _reconcile(int generation) async {
    try {
      // Duplicate names cannot identify the result of a creation request.
      if (_uncertainFamilyId != null) {
        final Family result = await _repository.read(_uncertainFamilyId!);
        if (!_current(generation)) return;
        active = result;
      } else {
        final ResultPage<Family> result = await _repository.list();
        if (!_current(generation)) return;
        families = result.items;
        if (families.isNotEmpty) {
          final Family family = await _repository.read(families.first.id);
          if (!_current(generation)) return;
          active = family;
          await _persist(family.id, generation);
        }
      }
      reconciled = true;
    } catch (failure) {
      if (_current(generation)) {
        reconciled = false;
        error = _failure(failure);
      }
    }
  }

  void acknowledgeUncertain() {
    if (!reconciled) return;
    uncertain = false;
    _emit();
  }

  Future<void> unavailable() async {
    final int generation = ++_generation;
    active = null;
    await _persist(null, generation);
    await reload(restoreSaved: false);
  }

  ApiError _failure(Object failure) => failure is ApiError
      ? failure
      : const ApiError(kind: ApiFailure.invalidResponse);
  @override
  void dispose() {
    _disposed = true;
    ++_generation;
    _session.removeListener(_sessionChanged);
    super.dispose();
  }
}
