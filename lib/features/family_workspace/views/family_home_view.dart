import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/network/models/api_error.dart';
import '../../../design_system/components/notebook_header.dart';
import '../../../design_system/theme/app_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../family_profiles/models/family_profile.dart';
import '../../daily_execution/models/daily_execution.dart';
import '../../scratchpad/views/drawing_canvas.dart';
import '../../scratchpad/models/board_note.dart';
import '../../scratchpad/views/scratchpad_editor.dart';
import '../../scratchpad/view_models/scratchpad_view_model.dart';
import '../view_models/family_home_view_model.dart';
import 'workspace_form.dart';

class FamilyHomeView extends StatefulWidget {
  const FamilyHomeView({
    required this.viewModel,
    required this.languageSelector,
    required this.onSignOut,
    required this.onChangePassword,
    super.key,
  });
  final FamilyHomeViewModel viewModel;
  final Widget languageSelector;
  final VoidCallback onSignOut;
  final VoidCallback onChangePassword;
  @override
  State<FamilyHomeView> createState() => _FamilyHomeViewState();
}

class _FamilyHomeViewState extends State<FamilyHomeView>
    with WidgetsBindingObserver {
  FamilyHomeViewModel get vm => widget.viewModel;
  WorkspaceFormMode? _form;
  ScratchpadViewModel? _editor;
  String _editorName = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    vm.addListener(_contextChanged);
  }

  void _contextChanged() {
    if (_editor != null &&
        (vm.family?.id != _editor!.familyId ||
            vm.selected?.id != _editor!.memberId)) {
      _editor!.dispose();
      _editor = null;
      if (mounted) setState(() {});
    }
    if (_form != null &&
        _form != WorkspaceFormMode.createFamily &&
        vm.family == null) {
      if (mounted) setState(() => _form = null);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _editor == null) {
      unawaited(vm.resume());
    }
  }

  void _openForm(WorkspaceFormMode mode) {
    vm.clearFormError();
    setState(() => _form = mode);
  }

  void _openBoard(BoardNote note) {
    if (vm.selected == null || !vm.hasBoard || vm.drawingLoading) return;
    setState(() {
      _editorName = note.title;
      _editor = vm.createEditor(note);
    });
  }

  Future<void> _newNote() async {
    if (!vm.canEdit || vm.noteCreating) return;
    final note = await vm.createNote();
    if (mounted && note != null) _openBoard(note);
  }

  void _closeEditor() {
    final ScratchpadViewModel? editor = _editor;
    setState(() => _editor = null);
    editor?.dispose();
    unawaited(vm.refreshDrawing());
  }

  @override
  void dispose() {
    vm.removeListener(_contextChanged);
    WidgetsBinding.instance.removeObserver(this);
    _editor?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: vm,
    builder: (BuildContext context, Widget? child) {
      if (_form == null &&
          vm.family == null &&
          vm.families.isEmpty &&
          !vm.busy &&
          vm.error == null &&
          !vm.uncertain) {
        _form = WorkspaceFormMode.createFamily;
      }
      if (_editor != null) {
        return ScratchpadEditor(
          viewModel: _editor!,
          profileName: _editorName,
          onClose: _closeEditor,
        );
      }
      if (_form != null) {
        return WorkspaceForm(
          viewModel: vm,
          mode: _form!,
          onClose: () {
            if (vm.family == null && vm.families.isEmpty) {
              widget.onSignOut();
              return;
            }
            if (mounted) setState(() => _form = null);
          },
        );
      }
      final AppLocalizations strings = AppLocalizations.of(context)!;
      if (vm.family == null && vm.families.isEmpty && !vm.uncertain) {
        return Scaffold(
          backgroundColor: AppColors.notebook,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: vm.error != null
                    ? _error(vm.error!, vm.reloadFamilies)
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
        );
      }
      return Scaffold(
        backgroundColor: AppColors.notebook,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool compact = constraints.maxWidth < AppLayout.tablet;
              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 20 : 32,
                        ),
                        child: _header(strings, compact: compact),
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, viewport) => SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              compact ? 20 : 32,
                              24,
                              compact ? 20 : 32,
                              compact ? 20 : 32,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (vm.family == null)
                                  _familyStatus(strings)
                                else ...[
                                  if (compact) ...[
                                    _profiles(strings),
                                    const SizedBox(height: 24),
                                    if (vm.hasBoard) ...[
                                      _board(strings),
                                      const SizedBox(height: 24),
                                    ],
                                    _tasks(strings),
                                  ] else
                                    _notebookLayout(
                                      strings,
                                      availableHeight: (viewport.maxHeight - 56)
                                          .clamp(480.0, double.infinity),
                                    ),
                                ],
                                if (compact || vm.family == null) ...[
                                  const SizedBox(height: 28),
                                  Text(
                                    'BeeHome · ${strings.homeFooter}',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: AppColors.pencil),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );
  Widget _header(AppLocalizations strings, {required bool compact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NotebookHeader(
          title: const Text(
            'BEEHOME',
            style: TextStyle(
              fontFamily: AppTypography.typewriterFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
              color: AppColors.notebookInk,
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              tooltip: strings.homeFamilySettings,
              onSelected: (String action) {
                switch (action) {
                  case 'settings':
                    _openForm(WorkspaceFormMode.editFamily);
                  case 'profile':
                    _openForm(WorkspaceFormMode.editProfile);
                  case 'password':
                    widget.onChangePassword();
                  case 'logout':
                    widget.onSignOut();
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Row(
                    children: [
                      Expanded(child: Text(strings.language)),
                      widget.languageSelector,
                    ],
                  ),
                ),
                if (vm.canEdit)
                  PopupMenuItem(
                    value: 'settings',
                    child: Text(strings.homeFamilySettings),
                  ),
                if (vm.canEdit && vm.selected != null)
                  PopupMenuItem(
                    value: 'profile',
                    child: Text(strings.homeEditProfile),
                  ),
                PopupMenuItem(
                  value: 'password',
                  child: Text(strings.authChange),
                ),
                PopupMenuItem(value: 'logout', child: Text(strings.signOut)),
              ],
            ),
          ],
        ),
        if (compact && vm.family != null) ...[
          const SizedBox(height: 16),
          _familyLabel(strings),
        ],
      ],
    );
  }

  Widget _familyLabel(AppLocalizations strings) => Center(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.paperWarm,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.paperBorder),
      ),
      child: Text(
        '${strings.homeNotebook} · ${vm.family!.name}'.toUpperCase(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: AppTypography.typewriterFamily,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: .6,
          color: AppColors.pencil,
        ),
      ),
    ),
  );

  Widget _familyStatus(AppLocalizations strings) => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          strings.homeFamilySettings,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (vm.busy) const LinearProgressIndicator(),
        if (vm.error != null) _error(vm.error!, vm.reloadFamilies),
        if (!vm.busy && vm.families.isEmpty && vm.error == null)
          Text(strings.homeNoFamilies),
      ],
    ),
  );
  Widget _notebookLayout(
    AppLocalizations strings, {
    required double availableHeight,
  }) => LayoutBuilder(
    builder: (context, constraints) {
      final profiles = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _familyLabel(strings),
          _profiles(strings, gallery: true),
          const SizedBox(height: 28),
          Text(
            'BeeHome · ${strings.homeFooter}',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.pencil),
          ),
        ],
      );
      if (constraints.maxWidth < 960) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            profiles,
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (vm.hasBoard) ...[
                  Expanded(
                    child: _board(
                      strings,
                      vertical: true,
                      height: availableHeight,
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
                Expanded(child: _tasks(strings)),
              ],
            ),
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (vm.hasBoard) ...[
            Expanded(
              flex: 3,
              child: _board(strings, vertical: true, height: availableHeight),
            ),
            const SizedBox(width: 28),
          ],
          Expanded(flex: 5, child: profiles),
          const SizedBox(width: 28),
          Expanded(flex: 4, child: _tasks(strings)),
        ],
      );
    },
  );

  Widget _profiles(AppLocalizations strings, {bool gallery = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (vm.profilesLoading) const LinearProgressIndicator(),
      if (vm.profilesError != null) _error(vm.profilesError!, vm.loadProfiles),
      if (vm.profiles.isEmpty &&
          !vm.profilesLoading &&
          vm.profilesError == null)
        Text(strings.homeNoProfiles),
      if (vm.profiles.isNotEmpty)
        if (gallery)
          LayoutBuilder(
            builder: (context, constraints) {
              final adultSize = ((constraints.maxWidth - 40) / 2).clamp(
                120.0,
                208.0,
              );
              final childSize = ((constraints.maxWidth - 56) / 3).clamp(
                88.0,
                144.0,
              );
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    for (final adult in [true, false]) ...[
                      if (vm.profiles.any(
                        (profile) => profile.isAdult == adult,
                      ))
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: adult ? 24 : 16,
                          runSpacing: 24,
                          children: [
                            for (final profile in vm.profiles.where(
                              (profile) => profile.isAdult == adult,
                            ))
                              _profileTile(
                                profile,
                                diameter: adult ? adultSize : childSize,
                                gallery: true,
                              ),
                          ],
                        ),
                      if (adult) const SizedBox(height: 36),
                    ],
                  ],
                ),
              );
            },
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final profile in vm.profiles)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _profileTile(profile),
                  ),
              ],
            ),
          ),
      if (vm.profilesHasNext)
        Align(
          alignment: gallery ? Alignment.center : Alignment.centerLeft,
          child: IconButton(
            tooltip: strings.homeMore,
            onPressed: vm.profilesLoading
                ? null
                : () => vm.loadProfiles(more: true),
            icon: const Icon(Icons.more_horiz),
          ),
        ),
    ],
  );

  Widget _profileTile(
    FamilyProfile profile, {
    double diameter = 88,
    bool gallery = false,
  }) {
    final selected = vm.selected?.id == profile.id;
    final color = _profileColor(profile.color);
    return Semantics(
      selected: selected,
      button: true,
      label: profile.name,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => vm.selectProfile(profile.id),
        child: SizedBox(
          width: diameter + 8,
          child: Column(
            children: [
              Container(
                width: diameter,
                height: diameter,
                margin: const EdgeInsets.all(4),
                padding: EdgeInsets.all(gallery ? 10 : 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gallery ? color.withValues(alpha: .22) : null,
                  border: Border.all(
                    color: selected ? AppColors.honey : color,
                    width: selected ? 3 : 1,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: gallery ? Colors.transparent : color,
                  child: Icon(
                    profile.isAdult ? Icons.face_outlined : Icons.child_care,
                    color: AppColors.notebookInk,
                    size: diameter * .56,
                  ),
                ),
              ),
              SizedBox(height: gallery ? 10 : 2),
              Text(
                profile.name.trim().split(RegExp(r'\s+')).first,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: gallery ? AppTypography.typewriterFamily : null,
                  fontSize: gallery ? 15 : 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              ExcludeSemantics(
                child: Container(
                  width: gallery ? 36 : 8,
                  height: gallery ? 4 : 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _board(
    AppLocalizations strings, {
    bool vertical = false,
    double? height,
  }) => SizedBox(
    height: height,
    child: _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('✏️', style: TextStyle(fontSize: 16)),
                  Text(strings.homeBoard.toUpperCase(), style: _sectionStyle),
                ],
              ),
              if (vm.canEdit)
                OutlinedButton.icon(
                  onPressed: vm.noteCreating || vm.drawingLoading
                      ? null
                      : _newNote,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 28),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    foregroundColor: AppColors.pencil,
                    side: const BorderSide(color: AppColors.paperBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    tapTargetSize: MaterialTapTargetSize.padded,
                  ),
                  icon: const Icon(Icons.add, size: 12),
                  label: Text(
                    strings.homeNewNote.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: AppTypography.typewriterFamily,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(color: AppColors.paperBorder),
          if (vm.drawingLoading || vm.noteCreating)
            const LinearProgressIndicator(),
          if (vm.drawingError != null)
            _error(vm.drawingError!, vm.refreshDrawing),
          if (vm.notes.isEmpty && !vm.drawingLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(strings.homeEmptyBoard, textAlign: TextAlign.center),
            ),
          if (vm.notes.isNotEmpty)
            if (height != null)
              Expanded(
                child: _boardNotes(strings, vertical: vertical, fill: true),
              )
            else
              _boardNotes(strings, vertical: vertical),
          if (height != null && vm.notes.isEmpty) const Spacer(),
          if (!vm.drawingLoading && vm.drawingError == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 6,
                children: [
                  if (vm.notes.isNotEmpty && !vertical)
                    Text(
                      strings.homeSwipeNotes,
                      style: AppTypography.smallCaption.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.pencil,
                      ),
                    ),
                  Text(
                    strings.homeActiveNotes(vm.notesTotal),
                    style: AppTypography.smallCaption.copyWith(
                      color: AppColors.pencil,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );

  Widget _boardNotes(
    AppLocalizations strings, {
    required bool vertical,
    bool fill = false,
  }) => LayoutBuilder(
    builder: (context, constraints) {
      final width = vertical
          ? constraints.maxWidth - 12
          : (constraints.maxWidth * .78).clamp(180.0, 280.0);
      return SizedBox(
        height: fill ? constraints.maxHeight : (vertical ? 440 : 224),
        child: ListView.separated(
          key: ValueKey('board-notes-${vm.selected!.id}'),
          scrollDirection: vertical ? Axis.vertical : Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          itemCount: vm.notes.length + (vm.notesHasNext ? 1 : 0),
          separatorBuilder: (_, _) =>
              SizedBox(width: vertical ? 0 : 14, height: vertical ? 24 : 0),
          itemBuilder: (context, index) {
            if (index == vm.notes.length) {
              return Center(
                child: TextButton(
                  onPressed: vm.drawingLoading ? null : vm.loadMoreNotes,
                  child: Text(strings.homeMore),
                ),
              );
            }
            final note = vm.notes[index];
            final tint = index.isEven
                ? AppColors.pastelHoney
                : AppColors.pastelBlue;
            final noteHue = HSLColor.fromColor(tint);
            final ruleColor = noteHue
                .withLightness((noteHue.lightness - .12).clamp(0.0, 1.0))
                .toColor();
            return SizedBox(
              width: width,
              height: vertical ? 200 : null,
              child: Transform.rotate(
                angle: index.isEven ? -.018 : .014,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Material(
                        color: tint.withValues(alpha: .45),
                        elevation: 1,
                        shadowColor: AppColors.paperBorder.withValues(
                          alpha: .35,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(color: tint),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _openBoard(note),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (note.title.isNotEmpty)
                                  Text(
                                    note.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily:
                                          AppTypography.typewriterFamily,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: note.drawing.strokes.isEmpty
                                      ? const SizedBox.shrink()
                                      : IgnorePointer(
                                          child: DrawingCanvas(
                                            strokes: note.drawing.strokes,
                                          ),
                                        ),
                                ),
                                Divider(
                                  height: 16,
                                  thickness: .75,
                                  indent: 4,
                                  endIndent: 4,
                                  color: ruleColor,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '– ${vm.selected!.name.trim().split(RegExp(r'\s+')).first}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.smallCaption
                                            .copyWith(
                                              fontStyle: FontStyle.italic,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const ExcludeSemantics(
                                      child: Text(
                                        '📎',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -8,
                      left: width / 2 - 34,
                      child: IgnorePointer(
                        child: CustomPaint(
                          foregroundPainter: const _NoteTapeBorder(),
                          child: Container(
                            width: 68,
                            height: 19,
                            color: AppColors.surface.withValues(alpha: .8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );

  Widget _tasks(AppLocalizations strings) => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('•  ${strings.homeTasks.toUpperCase()}', style: _sectionStyle),
            if (vm.execution != null)
              Text(
                strings.homeProgress(
                  vm.execution!.completed,
                  vm.execution!.visibleItems.length,
                ),
                style: Theme.of(context).textTheme.labelSmall,
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (vm.profiles.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final FamilyProfile profile in vm.profiles)
                ChoiceChip(
                  selected: vm.selected?.id == profile.id,
                  label: Text(profile.name),
                  showCheckmark: false,
                  selectedColor: AppColors.honey,
                  onSelected: (_) => vm.selectProfile(profile.id),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        if (vm.tasksLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: LinearProgressIndicator(),
          ),
        if (vm.tasksError != null) _error(vm.tasksError!, vm.refreshTasks),
        if (vm.selected != null &&
            !vm.tasksLoading &&
            vm.execution?.visibleItems.isEmpty == true)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(strings.homeNoTasks),
          ),
        if (vm.execution != null) ...[
          if (vm.execution!.finalized)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(strings.homeFinalized),
            ),
          for (final ExecutionItem item in vm.execution!.visibleItems) ...[
            const Divider(height: 16, color: AppColors.paperBorder),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: item.completed,
              activeColor: _profileColor(
                vm.selected?.completedTaskColor,
                fallback: AppColors.tertiary,
              ),
              checkColor: AppColors.ink,
              onChanged:
                  vm.pendingItem != null ||
                      vm.tasksLoading ||
                      vm.execution!.finalized
                  ? null
                  : (_) => vm.toggle(item),
              title: Text(
                item.title,
                style: TextStyle(
                  fontSize: 13,
                  color: item.completed
                      ? AppColors.pencil
                      : AppColors.notebookInk,
                  decoration: item.completed
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              subtitle: item.time == null && item.description == null
                  ? null
                  : Text(
                      [
                        if (item.time != null) item.time!,
                        if (item.description != null) item.description!,
                      ].join(' · '),
                    ),
              secondary: vm.pendingItem == item.id
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
          ],
        ],
        if (vm.selected != null)
          Wrap(
            spacing: 8,
            children: [
              if (vm.canEdit && vm.execution?.finalized != true)
                TextButton.icon(
                  onPressed: vm.tasksLoading
                      ? null
                      : () => _openForm(WorkspaceFormMode.addTask),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(strings.homeAddTask),
                ),
              IconButton(
                tooltip: strings.homeRefreshTasks,
                onPressed: vm.tasksLoading || vm.pendingItem != null
                    ? null
                    : vm.refreshTasks,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
      ],
    ),
  );
  TextStyle get _sectionStyle => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: .7,
  );
  Widget _card(Widget child) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.paperBorder.withValues(alpha: .6)),
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: AppColors.ink.withValues(alpha: .025),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );
  Widget _error(ApiError error, Future<void> Function() retry) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            error.status == 403
                ? strings.homeDenied
                : error.detail ?? strings.homeError,
          ),
          TextButton(onPressed: retry, child: Text(strings.retry)),
        ],
      ),
    );
  }

  Color _profileColor(
    String? value, {
    Color fallback = AppColors.pastelHoney,
  }) => value != null && RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(value)
      ? drawingColor(value)
      : fallback;
}

class _NoteTapeBorder extends CustomPainter {
  const _NoteTapeBorder();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.paperBorder
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    for (double x = 0; x < size.width; x += 5) {
      final end = (x + 3).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, 0), Offset(end, 0), paint);
      canvas.drawLine(Offset(x, size.height), Offset(end, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 5) {
      final end = (y + 3).clamp(0.0, size.height);
      canvas.drawLine(Offset(0, y), Offset(0, end), paint);
      canvas.drawLine(Offset(size.width, y), Offset(size.width, end), paint);
    }
  }

  @override
  bool shouldRepaint(_NoteTapeBorder oldDelegate) => false;
}
