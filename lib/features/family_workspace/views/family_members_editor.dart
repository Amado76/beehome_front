import 'package:flutter/material.dart';
import '../../../design_system/components/app_field.dart';
import '../../../core/network/models/api_error.dart';
import '../../../design_system/theme/app_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../family_profiles/models/family_profile.dart';
import '../view_models/family_home_view_model.dart';
import 'pastel_color_picker.dart';

class FamilyMembersEditor extends StatefulWidget {
  const FamilyMembersEditor({
    required this.viewModel,
    required this.ensureFamily,
    required this.creating,
    super.key,
  });
  final FamilyHomeViewModel viewModel;
  final Future<bool> Function() ensureFamily;
  final bool creating;
  @override
  State<FamilyMembersEditor> createState() => FamilyMembersEditorState();
}

class FamilyMembersEditorState extends State<FamilyMembersEditor> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _birthDate = TextEditingController();
  FamilyProfile? _editing;
  MemberType _type = MemberType.child;
  String? _color = '#BFDBFE';
  String? _completionColor = '#BBF7D0';
  bool _saving = false;
  FamilyHomeViewModel get vm => widget.viewModel;
  bool get busy => _saving || vm.busy || vm.formBusy;

  @override
  void dispose() {
    _name.dispose();
    _birthDate.dispose();
    super.dispose();
  }

  void _edit(FamilyProfile? profile) {
    vm.clearFormError();
    // Reset validation before loading the member: reset also restores field values.
    _key.currentState?.reset();
    setState(() {
      _editing = profile;
      _name.text = profile?.name ?? '';
      _birthDate.text = profile?.birthDate ?? '';
      _type = profile?.type ?? MemberType.child;
      _color = profile == null ? '#BFDBFE' : profile.color;
      _completionColor = profile == null
          ? '#BBF7D0'
          : profile.completedTaskColor;
    });
  }

  Future<bool> savePending() async {
    if (_editing == null &&
        _name.text.trim().isEmpty &&
        _birthDate.text.isEmpty) {
      return true;
    }
    return _save();
  }

  Future<bool> _save() async {
    if (!_key.currentState!.validate()) return false;
    setState(() => _saving = true);
    try {
      if (!await widget.ensureFamily() || !mounted) return false;
      final saved = await vm.saveProfile(
        _name.text.trim(),
        _type,
        profile: _editing,
        birthDate: _birthDate.text.isEmpty ? null : _birthDate.text,
        color: _color,
        completionColor: _completionColor,
      );
      if (!mounted) return false;
      if (saved) {
        _edit(null);
      } else if (_editing == null && vm.formSavedProfile != null) {
        // A creation followed by a failed preference PATCH must be retried as
        // an edit, never as another POST that would duplicate the person.
        setState(() => _editing = vm.formSavedProfile);
      }
      return saved;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now().toUtc();
    final today = DateTime(now.year, now.month, now.day);
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_birthDate.text) ?? today,
      firstDate: DateTime(1),
      lastDate: today,
    );
    if (selected != null && mounted) {
      setState(
        () => _birthDate.text =
            '${selected.year.toString().padLeft(4, '0')}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}',
      );
    }
  }

  Future<void> _remove(FamilyProfile profile) async {
    final strings = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${strings.familySetupRemoveMember}: ${profile.name}'),
        content: Text(strings.familySetupRemoveHint),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.homeCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.familySetupRemoveMember),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final removed = await vm.deactivateProfile(profile);
    if (removed && mounted && _editing?.id == profile.id) _edit(null);
  }

  Widget _label(String text) => Text(
    text.toUpperCase(),
    style: AppTypography.smallCaption.copyWith(
      color: AppColors.onHoney,
      fontWeight: FontWeight.bold,
    ),
  );

  Widget _member(FamilyProfile profile, AppLocalizations strings) {
    final birthDate = DateTime.tryParse(profile.birthDate ?? '');
    final today = DateTime.now();
    final age = birthDate == null
        ? null
        : today.year -
              birthDate.year -
              (today.month < birthDate.month ||
                      (today.month == birthDate.month &&
                          today.day < birthDate.day)
                  ? 1
                  : 0);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.paperBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: PastelColorPicker.decode(profile.color),
            foregroundColor: AppColors.ink,
            child: Text(
              profile.name.characters.first.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    if (age != null && age >= 0)
                      Text(
                        strings.familySetupAge(age),
                        style: AppTypography.smallCaption.copyWith(
                          color: AppColors.pencil,
                        ),
                      ),
                    Text(
                      profile.isAdult ? strings.homeAdult : strings.homeChild,
                      style: AppTypography.smallCaption.copyWith(
                        color: AppColors.pencil,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 10,
                  children: [
                    _swatch(profile.color, strings.familySetupProfile),
                    _swatch(
                      profile.completedTaskColor,
                      strings.familySetupCompletedTask,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: '${strings.familySetupEditMember}: ${profile.name}',
            onPressed: busy || vm.formUncertain ? null : () => _edit(profile),
            icon: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.pencil,
            ),
          ),
          IconButton(
            tooltip: '${strings.familySetupRemoveMember}: ${profile.name}',
            onPressed: busy || vm.formUncertain ? null : () => _remove(profile),
            icon: const Icon(Icons.close, size: 18, color: AppColors.pencil),
          ),
        ],
      ),
    );
  }

  Widget _swatch(String? color, String label) => Text.rich(
    TextSpan(
      children: [
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PastelColorPicker.decode(color),
                border: Border.all(color: AppColors.paperBorder),
              ),
            ),
          ),
        ),
        TextSpan(text: label),
      ],
    ),
    style: AppTypography.smallCaption.copyWith(color: AppColors.pencil),
  );

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final members = widget.creating
        ? <FamilyProfile>[]
        : vm.profiles.where((p) => p.active).toList();
    final ApiError? error = vm.formError;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label(
          '${strings.familySetupMembers} (${members.length}${vm.profilesHasNext ? '+' : ''})',
        ),
        const SizedBox(height: 12),
        if (vm.profilesLoading && !widget.creating)
          const LinearProgressIndicator(),
        for (final profile in members) _member(profile, strings),
        if (vm.profilesError != null && !widget.creating) ...[
          Text(strings.homeError),
          TextButton(
            onPressed: busy ? null : vm.loadProfiles,
            child: Text(strings.retry),
          ),
        ],
        if (vm.profilesHasNext && !widget.creating)
          TextButton(
            onPressed: busy || vm.profilesLoading
                ? null
                : () => vm.loadProfiles(more: true),
            child: Text(strings.homeMore),
          ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _label(
                _editing == null
                    ? strings.familySetupNewMember
                    : strings.familySetupEditMember,
              ),
            ),
            if (_editing != null)
              IconButton(
                tooltip: strings.homeCancel,
                onPressed: busy || vm.formUncertain ? null : () => _edit(null),
                icon: const Icon(Icons.close),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  for (final type in [MemberType.child, MemberType.adult])
                    ChoiceChip(
                      label: Text(
                        type == MemberType.child
                            ? strings.homeChild
                            : strings.homeAdult,
                      ),
                      selected: _type == type,
                      onSelected: busy || vm.formUncertain
                          ? null
                          : (_) => setState(() => _type = type),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              AppField(
                label: strings.homeProfileName,
                child: TextFormField(
                  controller: _name,
                  style: AppTypography.input,
                  enabled: !busy && !vm.formUncertain,
                  maxLength: 120,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: strings.homeFieldExample(strings.authNameHint),
                    counterText: '',
                  ),
                  validator: (value) => vm.validName(value ?? '')
                      ? null
                      : (value?.trim().isEmpty ?? true)
                      ? strings.authRequired
                      : strings.authNameLength,
                ),
              ),
              const SizedBox(height: 12),
              AppField(
                label: strings.familySetupBirthDate,
                child: TextFormField(
                  controller: _birthDate,
                  style: AppTypography.input,
                  enabled: !busy && !vm.formUncertain,
                  readOnly: true,
                  onTap: busy || vm.formUncertain ? null : _pickBirthDate,
                  decoration: InputDecoration(
                    hintText: strings.homeFieldExample('2018-05-12'),
                    suffixIcon: _birthDate.text.isEmpty
                        ? const Icon(Icons.calendar_today_outlined, size: 18)
                        : IconButton(
                            tooltip: strings.homeCancel,
                            onPressed: busy || vm.formUncertain
                                ? null
                                : () => setState(_birthDate.clear),
                            icon: const Icon(Icons.close, size: 18),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final profile = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(strings.homeProfileColor),
                      PastelColorPicker(
                        selected: _color,
                        onChanged: busy || vm.formUncertain
                            ? null
                            : (value) => setState(() => _color = value),
                      ),
                    ],
                  );
                  final completion = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(strings.homeCompletionColor),
                      PastelColorPicker(
                        selected: _completionColor,
                        onChanged: busy || vm.formUncertain
                            ? null
                            : (value) =>
                                  setState(() => _completionColor = value),
                      ),
                    ],
                  );
                  return constraints.maxWidth < 360
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            profile,
                            const SizedBox(height: 12),
                            completion,
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: profile),
                            const SizedBox(width: 16),
                            Expanded(child: completion),
                          ],
                        );
                },
              ),
              const SizedBox(height: 12),
              if (widget.creating)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    strings.familySetupCreateHint,
                    style: AppTypography.smallCaption.copyWith(
                      color: AppColors.pencil,
                    ),
                  ),
                ),
              if (error != null)
                Semantics(
                  liveRegion: true,
                  child: Text(
                    vm.formUncertain
                        ? strings.homeUncertain
                        : error.status == 403
                        ? strings.homeDenied
                        : error.detail ?? strings.homeError,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (vm.formUncertain) ...[
                TextButton(
                  onPressed: busy ? null : vm.reconcileForm,
                  child: Text(strings.retry),
                ),
                TextButton(
                  onPressed: busy || !vm.formReconciled
                      ? null
                      : vm.acknowledgeFormUncertain,
                  child: Text(strings.homeReviewed),
                ),
              ],
              OutlinedButton.icon(
                onPressed: busy || vm.formUncertain || vm.uncertain
                    ? null
                    : _save,
                icon: Icon(
                  _editing == null ? Icons.add : Icons.check,
                  size: 18,
                ),
                label: Text(
                  _editing == null ? strings.homeAddProfile : strings.homeSave,
                ),
              ),
              if (_editing != null)
                TextButton(
                  onPressed: busy || vm.formUncertain
                      ? null
                      : () => _edit(null),
                  child: Text(strings.homeCancel),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
