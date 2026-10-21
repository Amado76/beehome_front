import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../design_system/components/notebook_header.dart';
import '../../../design_system/theme/app_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../view_models/scratchpad_view_model.dart';
import 'drawing_canvas.dart';

class ScratchpadEditor extends StatefulWidget {
  const ScratchpadEditor({
    required this.viewModel,
    required this.profileName,
    required this.onClose,
    super.key,
  });
  final ScratchpadViewModel viewModel;
  final String profileName;
  final VoidCallback onClose;
  @override
  State<ScratchpadEditor> createState() => _ScratchpadEditorState();
}

class _ScratchpadEditorState extends State<ScratchpadEditor> {
  ScratchpadViewModel get vm => widget.viewModel;
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    unawaited(vm.load());
  }

  Future<bool> _confirm(String title) async {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(title),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(strings.homeCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(strings.homeSave),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _deleteNote() async {
    if (!vm.canDelete || vm.saving) return;
    final strings = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.noteDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.homeCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.noteDelete),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted && await vm.deleteNote() && mounted) {
      widget.onClose();
    }
  }

  Future<void> _retry() async {
    if (vm.deleteFailed) {
      if (await vm.deleteNote() && mounted) widget.onClose();
    } else if (vm.loaded) {
      await vm.save();
    } else {
      await vm.load();
    }
  }

  Future<void> _close() async {
    if (vm.saving) return;
    if (!vm.dirty) {
      widget.onClose();
      return;
    }
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final String? action = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(strings.drawingUnsaved),
        content: Text(strings.drawingLeaveConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.homeCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: Text(strings.drawingDiscard),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: Text(strings.homeSave),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (action == 'discard' || (action == 'save' && await vm.save())) {
      if (mounted) widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: vm,
    builder: (BuildContext context, Widget? child) {
      final AppLocalizations strings = AppLocalizations.of(context)!;
      if (vm.title != null && _titleController.text != vm.title) {
        _titleController.value = TextEditingValue(
          text: vm.title!,
          selection: TextSelection.collapsed(offset: vm.title!.length),
        );
      }
      final String status = vm.saving
          ? strings.drawingSaving
          : vm.dirty
          ? strings.drawingUnsaved
          : strings.drawingSaved;
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (!didPop) unawaited(_close());
        },
        child: Scaffold(
          backgroundColor: AppColors.surface,
          appBar: NotebookHeader(
            backgroundColor: AppColors.surface,
            leading: IconButton(
              onPressed: vm.saving ? null : _close,
              icon: const Icon(Icons.arrow_back),
            ),
            title: Text(strings.homeBoard),
            actions: [
              if (vm.canDelete)
                IconButton(
                  tooltip: strings.noteDelete,
                  onPressed: vm.saving || !vm.loaded ? null : _deleteNote,
                  icon: const Icon(Icons.delete_outline, size: 20),
                ),
              if (vm.canEdit)
                IconButton(
                  tooltip: strings.homeSave,
                  onPressed: vm.saving || !vm.loaded || vm.conflict != null
                      ? null
                      : vm.save,
                  icon: const Icon(Icons.save_outlined),
                ),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) =>
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.medium),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 880),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (vm.loading) const LinearProgressIndicator(),
                            if (vm.loaded && vm.title != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: TextField(
                                  key: const ValueKey('note-title'),
                                  controller: _titleController,
                                  enabled: vm.editable,
                                  maxLength: 120,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  style: AppTypography.notebookCaption,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  decoration: InputDecoration(
                                    hintText: strings.homeNoteTitleOptional,
                                    contentPadding: const EdgeInsets.only(
                                      top: 8,
                                      bottom: 4,
                                    ),
                                    isDense: true,
                                    counterText: '',
                                    filled: false,
                                    border: const UnderlineInputBorder(),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColors.paperBorder,
                                      ),
                                    ),
                                  ),
                                  onChanged: vm.setTitle,
                                ),
                              ),
                            if (vm.loaded)
                              Semantics(
                                liveRegion: true,
                                child: Text(
                                  status,
                                  textAlign: TextAlign.end,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium,
                                ),
                              ),
                            if (vm.error != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      vm.deleteFailed
                                          ? strings.noteDeleteError
                                          : vm.error!.status == 413
                                          ? strings.drawingLimit
                                          : vm.error!.status == 403
                                          ? strings.homeDenied
                                          : vm.loaded
                                          ? strings.drawingSaveError
                                          : strings.homeError,
                                    ),
                                    TextButton(
                                      onPressed: vm.saving ? null : _retry,
                                      child: Text(strings.retry),
                                    ),
                                  ],
                                ),
                              ),
                            if (vm.conflict != null)
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Text(strings.drawingConflict),
                                      AspectRatio(
                                        aspectRatio: DrawingCanvas.aspectRatio,
                                        child: ColoredBox(
                                          color: AppColors.notebook,
                                          child: DrawingCanvas(
                                            strokes: vm.conflict!.strokes,
                                          ),
                                        ),
                                      ),
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          TextButton(
                                            onPressed: () async {
                                              if (await _confirm(
                                                    strings
                                                        .drawingReplaceConfirm,
                                                  ) &&
                                                  mounted) {
                                                vm.useRemote();
                                              }
                                            },
                                            child: Text(
                                              strings.drawingUseRemote,
                                            ),
                                          ),
                                          FilledButton(
                                            onPressed: () async {
                                              if (await _confirm(
                                                    strings
                                                        .drawingReplaceConfirm,
                                                  ) &&
                                                  mounted) {
                                                await vm.keepLocal();
                                              }
                                            },
                                            child: Text(
                                              strings.drawingKeepLocal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (vm.canEdit)
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  IconButton(
                                    tooltip: strings.drawingPen,
                                    isSelected: vm.tool == DrawingTool.pen,
                                    onPressed: vm.editable
                                        ? () => vm.selectTool(DrawingTool.pen)
                                        : null,
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    tooltip: strings.drawingErase,
                                    isSelected: vm.tool == DrawingTool.erase,
                                    onPressed: vm.editable
                                        ? () => vm.selectTool(DrawingTool.erase)
                                        : null,
                                    icon: const Icon(Icons.auto_fix_normal),
                                  ),
                                  IconButton(
                                    tooltip: strings.drawingUndo,
                                    onPressed: vm.canUndo && vm.editable
                                        ? vm.undo
                                        : null,
                                    icon: const Icon(Icons.undo),
                                  ),
                                  IconButton(
                                    tooltip: strings.drawingRedo,
                                    onPressed: vm.canRedo && vm.editable
                                        ? vm.redo
                                        : null,
                                    icon: const Icon(Icons.redo),
                                  ),
                                  IconButton(
                                    tooltip: strings.drawingClear,
                                    onPressed: vm.editable
                                        ? () async {
                                            if (await _confirm(
                                                  strings.drawingClearConfirm,
                                                ) &&
                                                mounted) {
                                              vm.clear();
                                            }
                                          }
                                        : null,
                                    icon: const Icon(
                                      Icons.cleaning_services_outlined,
                                    ),
                                  ),
                                  for (final String color in [
                                    '#2B2B2B',
                                    '#A24C43',
                                    '#456B9B',
                                    '#477558',
                                    '#805899',
                                  ])
                                    Semantics(
                                      label: color,
                                      selected: vm.color == color,
                                      button: true,
                                      child: IconButton(
                                        tooltip: color,
                                        onPressed: vm.editable
                                            ? () => vm.selectColor(color)
                                            : null,
                                        icon: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: drawingColor(color),
                                            shape: BoxShape.circle,
                                            border: vm.color == color
                                                ? Border.all(
                                                    color: AppColors.honey,
                                                    width: 3,
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                  SizedBox(
                                    width: 180,
                                    child: Slider(
                                      label: strings.drawingWidth,
                                      value: vm.width,
                                      min: 1,
                                      max: 10,
                                      divisions: 9,
                                      onChanged: vm.editable
                                          ? vm.selectWidth
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 12),
                            if (vm.loaded)
                              AspectRatio(
                                aspectRatio: DrawingCanvas.aspectRatio,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: AppColors.notebook,
                                    border: Border.all(
                                      color: AppColors.paperBorder,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppShape.fieldRadius,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppShape.fieldRadius,
                                    ),
                                    child: LayoutBuilder(
                                      builder:
                                          (
                                            BuildContext context,
                                            BoxConstraints surface,
                                          ) {
                                            double? pressure(
                                              PointerEvent event,
                                            ) =>
                                                (event.kind ==
                                                            PointerDeviceKind
                                                                .stylus ||
                                                        event.kind ==
                                                            PointerDeviceKind
                                                                .invertedStylus) &&
                                                    event.pressureMax >
                                                        event.pressureMin
                                                ? ((event.pressure -
                                                              event
                                                                  .pressureMin) /
                                                          (event.pressureMax -
                                                              event
                                                                  .pressureMin))
                                                      .clamp(0, 1)
                                                : null;
                                            return Semantics(
                                              label: strings.drawingSurface,
                                              child: Listener(
                                                behavior:
                                                    HitTestBehavior.opaque,
                                                onPointerDown:
                                                    (
                                                      PointerDownEvent event,
                                                    ) => vm.begin(
                                                      event.pointer,
                                                      event.localPosition.dx /
                                                          surface.maxWidth,
                                                      event.localPosition.dy /
                                                          surface.maxHeight,
                                                      pressure: pressure(event),
                                                    ),
                                                onPointerMove:
                                                    (
                                                      PointerMoveEvent event,
                                                    ) => vm.move(
                                                      event.pointer,
                                                      event.localPosition.dx /
                                                          surface.maxWidth,
                                                      event.localPosition.dy /
                                                          surface.maxHeight,
                                                      pressure: pressure(event),
                                                    ),
                                                onPointerUp:
                                                    (PointerUpEvent event) =>
                                                        vm.end(event.pointer),
                                                onPointerCancel:
                                                    (
                                                      PointerCancelEvent event,
                                                    ) => vm.cancel(
                                                      event.pointer,
                                                    ),
                                                child: GestureDetector(
                                                  onPanStart: vm.editable
                                                      ? (_) {}
                                                      : null,
                                                  onPanUpdate: vm.editable
                                                      ? (_) {}
                                                      : null,
                                                  child: DrawingCanvas(
                                                    strokes: vm.strokes,
                                                    pending: vm.pending,
                                                    penColor: vm.color,
                                                    penWidth: vm.width,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                ),
                              ),
                          ],
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
