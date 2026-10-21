import 'package:flutter/material.dart';
import '../../../design_system/components/notebook_header.dart';
import '../../../design_system/components/app_field.dart';
import '../../../design_system/theme/app_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../family_profiles/models/family_profile.dart';
import '../../../core/network/models/api_error.dart';
import '../view_models/family_home_view_model.dart';
import '../models/family.dart';
import '../../daily_execution/models/daily_execution.dart';
import 'pastel_color_picker.dart';
import 'family_members_editor.dart';
import 'task_form_sheet.dart';

enum WorkspaceFormMode {
  createFamily,
  editFamily,
  createProfile,
  editProfile,
  addTask,
}

class WorkspaceForm extends StatefulWidget {
  const WorkspaceForm({
    required this.viewModel,
    required this.mode,
    required this.onClose,
    this.canClose = true,
    super.key,
  });
  final FamilyHomeViewModel viewModel;
  final WorkspaceFormMode mode;
  final VoidCallback onClose;
  final bool canClose;
  @override
  State<WorkspaceForm> createState() => _WorkspaceFormState();
}

class _WorkspaceFormState extends State<WorkspaceForm> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final GlobalKey<FamilyMembersEditorState> _membersKey =
      GlobalKey<FamilyMembersEditorState>();
  late final TextEditingController _name;
  late final TextEditingController _birthDate;
  FamilyProfile? _profile;
  String? _color;
  String? _completionColor;
  MemberType _type = MemberType.adult;
  bool _familyCreated = false;
  bool _repeatDaily = false;
  final Set<String> _taskMemberIds = {};
  FamilyHomeViewModel get vm => widget.viewModel;
  bool get _family =>
      widget.mode == WorkspaceFormMode.createFamily ||
      widget.mode == WorkspaceFormMode.editFamily;
  bool get _task => widget.mode == WorkspaceFormMode.addTask;
  @override
  void initState() {
    super.initState();
    if (_task) {
      vm.beginTaskForm();
      if (vm.taskDraftMemberIds != null) {
        _taskMemberIds.addAll(vm.taskDraftMemberIds!);
        _repeatDaily = vm.taskDraftRepeatDaily;
      } else if (vm.selected != null) {
        _taskMemberIds.add(vm.selected!.id);
      }
    }
    _profile = widget.mode == WorkspaceFormMode.editProfile
        ? vm.selected
        : null;
    _name = TextEditingController(
      text: _task
          ? vm.taskDraftTitle
          : widget.mode == WorkspaceFormMode.editFamily
          ? vm.family?.name
          : _profile?.name,
    );
    _birthDate = TextEditingController(text: _profile?.birthDate);
    _color = _profile?.color;
    _completionColor = _profile?.completedTaskColor;
    _type = _profile?.type ?? MemberType.adult;
  }

  @override
  void dispose() {
    _name.dispose();
    _birthDate.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    final bool saved;
    if (_family) {
      if (!await (_membersKey.currentState?.savePending() ??
              Future.value(true)) ||
          !mounted) {
        return;
      }
      saved = await vm.saveFamily(
        _name.text.trim(),
        edit:
            widget.mode == WorkspaceFormMode.editFamily ||
            _familyCreated ||
            vm.family != null,
      );
    } else if (_task) {
      saved = await vm.addTask(
        _name.text.trim(),
        memberIds: _taskMemberIds,
        repeatDaily: _repeatDaily,
      );
    } else {
      saved = await vm.saveProfile(
        _name.text.trim(),
        _type,
        profile: _profile,
        birthDate: _birthDate.text.trim().isEmpty
            ? null
            : _birthDate.text.trim(),
        color: _color,
        completionColor: _completionColor,
      );
    }
    if (!saved &&
        mounted &&
        !_family &&
        !_task &&
        _profile == null &&
        vm.formSavedProfile != null) {
      setState(() => _profile = vm.formSavedProfile);
    }
    if (saved && mounted) widget.onClose();
  }

  Future<bool> _ensureFamily() async {
    if (!_key.currentState!.validate()) return false;
    if (widget.mode == WorkspaceFormMode.editFamily ||
        _familyCreated ||
        vm.family != null) {
      return true;
    }
    final saved = await vm.saveFamily(_name.text.trim());
    if (saved && mounted) setState(() => _familyCreated = true);
    return saved;
  }

  Widget _colorOptions(
    String? selected,
    bool busy,
    void Function(String?) select,
  ) {
    return PastelColorPicker(
      selected: selected,
      onChanged: busy ? null : select,
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: vm,
    builder: (BuildContext context, Widget? child) {
      final AppLocalizations strings = AppLocalizations.of(context)!;
      final bool busy = _family ? vm.busy || vm.formBusy : vm.formBusy;
      final bool uncertain = _family ? vm.uncertain : vm.formUncertain;
      final ApiError? error = _family ? vm.error : vm.formError;
      final String title = switch (widget.mode) {
        WorkspaceFormMode.createFamily => strings.homeFamilySettings,
        WorkspaceFormMode.editFamily => strings.homeFamilySettings,
        WorkspaceFormMode.createProfile => strings.homeAddProfile,
        WorkspaceFormMode.editProfile => strings.homeEditProfile,
        WorkspaceFormMode.addTask => strings.homeAddTask,
      };
      final wideTask =
          _task && MediaQuery.sizeOf(context).width >= AppLayout.tablet;
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (!didPop && !busy && widget.canClose) widget.onClose();
        },
        child: Scaffold(
          backgroundColor: wideTask ? AppColors.paperWarm : AppColors.notebook,
          bottomNavigationBar: wideTask
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'BeeHome · ${strings.homeFooter}',
                    textAlign: TextAlign.center,
                    style: AppTypography.smallCaption.copyWith(
                      color: AppColors.pencil.withValues(alpha: .6),
                    ),
                  ),
                )
              : null,
          appBar: NotebookHeader(
            backgroundColor: wideTask
                ? AppColors.paperWarm
                : AppColors.notebook,
            title: wideTask
                ? TaskFormBadge(label: strings.homeTaskNewLabel)
                : Text(
                    _family ? title.toUpperCase() : title,
                    style: const TextStyle(
                      color: AppColors.onHoney,
                      fontSize: 14,
                      fontFamily: AppTypography.typewriterFamily,
                    ),
                  ),
            leading: widget.canClose
                ? wideTask && MediaQuery.sizeOf(context).width >= 1000
                      ? TextButton.icon(
                          onPressed: busy ? null : widget.onClose,
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: Text(
                            strings.homeTaskBack.toUpperCase(),
                            style: AppTypography.smallCaption,
                          ),
                        )
                      : IconButton(
                          onPressed: busy ? null : widget.onClose,
                          tooltip: wideTask ? strings.homeTaskBack : null,
                          icon: const Icon(Icons.arrow_back),
                        )
                : null,
          ),
          body: SafeArea(
            child: CustomPaint(
              painter: wideTask ? null : _NotebookDots(),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  wideTask
                      ? 40
                      : _family
                      ? 8
                      : 24,
                  24,
                  24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: wideTask ? 640 : AppLayout.formWidth,
                    ),
                    child: TaskFormSheet(
                      wide: wideTask,
                      child: Form(
                        key: _key,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_family) ...[
                              Text(
                                strings.familySetupTitle,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(color: AppColors.onHoney),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                strings.familySetupIntro,
                                style: const TextStyle(color: AppColors.pencil),
                              ),
                              const SizedBox(height: 24),
                            ],
                            AppField(
                              label: _family
                                  ? strings.homeFamilyName
                                  : _task
                                  ? strings.homeTaskTitle
                                  : strings.homeProfileName,
                              child: TextFormField(
                                controller: _name,
                                style: AppTypography.input,
                                enabled: !busy && (!_task || !vm.taskStarted),
                                maxLength: 120,
                                decoration: InputDecoration(
                                  border: wideTask
                                      ? const UnderlineInputBorder()
                                      : null,
                                  enabledBorder: wideTask
                                      ? const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColors.paperBorder,
                                          ),
                                        )
                                      : null,
                                  focusedBorder: wideTask
                                      ? const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColors.honey,
                                            width: 2,
                                          ),
                                        )
                                      : null,
                                  filled: wideTask ? false : null,
                                  contentPadding: wideTask
                                      ? const EdgeInsets.symmetric(vertical: 16)
                                      : null,
                                  hintText: strings.homeFieldExample(
                                    _family
                                        ? strings.homeFamilyNameHint
                                        : _task
                                        ? strings.homeTaskTitleHint
                                        : strings.authNameHint,
                                  ),
                                  counterText: '',
                                ),
                                validator: (String? value) =>
                                    vm.validName(value ?? '')
                                    ? null
                                    : (value?.trim().isEmpty ?? true)
                                    ? strings.authRequired
                                    : strings.authNameLength,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (_task) ...[
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: Text(
                                  strings.homeTaskRepeatDaily,
                                  style: wideTask
                                      ? AppTypography.notebookCaption
                                      : null,
                                ),
                                value: _repeatDaily,
                                onChanged: busy || vm.taskStarted
                                    ? null
                                    : (value) => setState(
                                        () => _repeatDaily = value ?? false,
                                      ),
                              ),
                              const SizedBox(height: 12),
                              AppField(
                                label: wideTask
                                    ? strings.homeTaskAssignees
                                    : strings.homeTaskProfiles,
                                child: FormField<Set<String>>(
                                  validator: (_) => _taskMemberIds.isEmpty
                                      ? strings.homeTaskSelectProfile
                                      : null,
                                  builder: (field) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      if (wideTask) ...[
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            strings.homeTaskSelectionCount(
                                              _taskMemberIds.length,
                                            ),
                                            style: AppTypography.smallCaption
                                                .copyWith(
                                                  color: AppColors.pencil,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 20,
                                          runSpacing: 16,
                                          children: [
                                            for (final profile in vm.profiles)
                                              TaskProfileOption(
                                                profile: profile,
                                                selected: _taskMemberIds
                                                    .contains(profile.id),
                                                onTap: busy || vm.taskStarted
                                                    ? null
                                                    : () => setState(() {
                                                        if (!_taskMemberIds.add(
                                                          profile.id,
                                                        )) {
                                                          _taskMemberIds.remove(
                                                            profile.id,
                                                          );
                                                        }
                                                        field.didChange(
                                                          _taskMemberIds,
                                                        );
                                                      }),
                                              ),
                                          ],
                                        ),
                                      ] else
                                        for (final profile in vm.profiles)
                                          CheckboxListTile(
                                            contentPadding: EdgeInsets.zero,
                                            controlAffinity:
                                                ListTileControlAffinity.leading,
                                            title: Text(profile.name),
                                            value: _taskMemberIds.contains(
                                              profile.id,
                                            ),
                                            onChanged: busy || vm.taskStarted
                                                ? null
                                                : (value) => setState(() {
                                                    if (value == true) {
                                                      _taskMemberIds.add(
                                                        profile.id,
                                                      );
                                                    } else {
                                                      _taskMemberIds.remove(
                                                        profile.id,
                                                      );
                                                    }
                                                    field.didChange(
                                                      _taskMemberIds,
                                                    );
                                                  }),
                                          ),
                                      if (vm.profilesLoading)
                                        const LinearProgressIndicator(),
                                      if (vm.profilesError != null)
                                        TextButton(
                                          onPressed: busy || vm.profilesLoading
                                              ? null
                                              : () => vm.loadProfiles(
                                                  more: vm.profilesHasNext,
                                                ),
                                          child: Text(strings.retry),
                                        ),
                                      if (vm.profilesHasNext)
                                        TextButton(
                                          onPressed: busy || vm.profilesLoading
                                              ? null
                                              : () =>
                                                    vm.loadProfiles(more: true),
                                          child: Text(strings.homeMore),
                                        ),
                                      if (field.hasError)
                                        Text(
                                          field.errorText!,
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              if (vm.taskStarted && error != null && !uncertain)
                                Text(strings.homeTaskRetryRemaining),
                              const SizedBox(height: 20),
                            ],
                            if (_family)
                              FamilyMembersEditor(
                                key: _membersKey,
                                viewModel: vm,
                                ensureFamily: _ensureFamily,
                                creating:
                                    widget.mode ==
                                        WorkspaceFormMode.createFamily &&
                                    !_familyCreated,
                              ),
                            if (!_family && !_task) ...[
                              DropdownButtonFormField<MemberType>(
                                initialValue: _type,
                                items: [
                                  DropdownMenuItem(
                                    value: MemberType.adult,
                                    child: Text(strings.homeAdult),
                                  ),
                                  DropdownMenuItem(
                                    value: MemberType.child,
                                    child: Text(strings.homeChild),
                                  ),
                                ],
                                onChanged: busy
                                    ? null
                                    : (MemberType? value) =>
                                          setState(() => _type = value!),
                              ),
                              const SizedBox(height: 20),
                              AppField(
                                label: strings.homeBirthDate,
                                child: TextFormField(
                                  controller: _birthDate,
                                  style: AppTypography.input,
                                  enabled: !busy,
                                  decoration: InputDecoration(
                                    hintText: strings.homeFieldExample(
                                      '2018-05-12',
                                    ),
                                  ),
                                  validator: (String? value) =>
                                      vm.validBirthDate(value ?? '')
                                      ? null
                                      : strings.homeInvalidDate,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(strings.homeProfileColor),
                              _colorOptions(
                                _color,
                                busy,
                                (String? value) =>
                                    setState(() => _color = value),
                              ),
                              ...[
                                const SizedBox(height: 20),
                                Text(strings.homeCompletionColor),
                                _colorOptions(
                                  _completionColor,
                                  busy,
                                  (String? value) =>
                                      setState(() => _completionColor = value),
                                ),
                              ],
                            ],
                            if (error != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Semantics(
                                  liveRegion: true,
                                  child: Text(
                                    uncertain
                                        ? strings.homeUncertain
                                        : error.status == 403
                                        ? strings.homeDenied
                                        : error.detail ?? strings.homeError,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                ),
                              ),
                            if (uncertain) ...[
                              Text(
                                _task
                                    ? strings.homeTaskUncertain
                                    : strings.homeUncertain,
                              ),
                              if (_family) ...[
                                if (vm.family != null) Text(vm.family!.name),
                                for (final Family family in vm.families)
                                  Text(family.name),
                              ] else if (_task) ...[
                                for (final profile in vm.profiles)
                                  if (_taskMemberIds.contains(profile.id)) ...[
                                    Text(profile.name),
                                    for (final ExecutionItem item
                                        in vm
                                                .taskReviewExecutions[profile
                                                    .id]
                                                ?.visibleItems ??
                                            <ExecutionItem>[])
                                      Text(item.title),
                                  ],
                              ] else ...[
                                for (final FamilyProfile profile in vm.profiles)
                                  Text(profile.name),
                              ],
                              TextButton(
                                onPressed: busy
                                    ? null
                                    : _family
                                    ? vm.reconcileFamily
                                    : vm.reconcileForm,
                                child: Text(strings.retry),
                              ),
                              TextButton(
                                onPressed:
                                    busy ||
                                        !(_family
                                            ? vm.reconciled
                                            : vm.formReconciled)
                                    ? null
                                    : () {
                                        if (_family) {
                                          vm.acknowledgeUncertain();
                                        } else {
                                          vm.acknowledgeFormUncertain();
                                          if (_task) widget.onClose();
                                        }
                                      },
                                child: Text(strings.homeReviewed),
                              ),
                            ],
                            const SizedBox(height: 24),
                            if (busy) const LinearProgressIndicator(),
                            FilledButton(
                              style: wideTask
                                  ? FilledButton.styleFrom(
                                      backgroundColor: AppColors.honey,
                                      foregroundColor: AppColors.ink,
                                      minimumSize: const Size.fromHeight(48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      textStyle: AppTypography.notebookCaption
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    )
                                  : null,
                              onPressed:
                                  busy ||
                                      uncertain ||
                                      (_family && vm.formUncertain)
                                  ? null
                                  : _save,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (wideTask) ...[
                                    const Icon(Icons.check, size: 18),
                                    const SizedBox(width: 10),
                                  ],
                                  Text(
                                    wideTask
                                        ? strings.homeTaskSave
                                        : _family
                                        ? strings.familySetupDone
                                        : strings.homeSave,
                                  ),
                                  if (_family) ...[
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward, size: 18),
                                  ],
                                ],
                              ),
                            ),
                            if (widget.canClose)
                              TextButton(
                                onPressed: busy ? null : widget.onClose,
                                child: Text(strings.homeCancel),
                              ),
                            if (_family) ...[
                              const SizedBox(height: 16),
                              Text(
                                strings.familySetupFooter,
                                textAlign: TextAlign.center,
                                style: AppTypography.smallCaption.copyWith(
                                  color: AppColors.pencil,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _NotebookDots extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.paperDot.withValues(alpha: .6);
    for (double x = 9; x < size.width; x += 18) {
      for (double y = 9; y < size.height; y += 18) {
        canvas.drawCircle(Offset(x, y), .75, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_NotebookDots oldDelegate) => false;
}
