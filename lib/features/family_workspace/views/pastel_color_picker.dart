import 'package:flutter/material.dart';
import '../../../design_system/theme/app_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Suggestions are conveniences, not API restrictions. Custom colors always
/// use a light HSL range and are serialized as the backend's #RRGGBB format.
class PastelColorPicker extends StatelessWidget {
  const PastelColorPicker({
    required this.selected,
    required this.onChanged,
    super.key,
  });
  final String? selected;
  final ValueChanged<String?>? onChanged;
  static const suggestions = [
    '#FDE68A',
    '#E9D5FF',
    '#FBCFE8',
    '#BFDBFE',
    '#BBF7D0',
  ];
  static Color decode(String? value) => value == null
      ? AppColors.paperWarm
      : Color(int.parse('FF${value.substring(1)}', radix: 16));
  static String encode(Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  Future<void> _custom(BuildContext context) async {
    final strings = AppLocalizations.of(context)!;
    final initial = HSLColor.fromColor(decode(selected ?? '#BFDBFE'));
    double hue = initial.hue;
    double lightness = initial.lightness.clamp(.78, .92);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final color = HSLColor.fromAHSL(1, hue, .65, lightness).toColor();
          return AlertDialog(
            title: Text(strings.familySetupCustomColor),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 72,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(AppShape.fieldRadius),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(encode(color), style: AppTypography.notebookCaption),
                  const SizedBox(height: 8),
                  Text(strings.familySetupHue),
                  const SizedBox(height: 4),
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppShape.fieldRadius),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFF2B6B6),
                          Color(0xFFF2F2B6),
                          Color(0xFFB6F2B6),
                          Color(0xFFB6F2F2),
                          Color(0xFFB6B6F2),
                          Color(0xFFF2B6F2),
                          Color(0xFFF2B6B6),
                        ],
                      ),
                    ),
                    child: Slider(
                      value: hue,
                      min: 0,
                      max: 360,
                      semanticFormatterCallback: (v) => '${v.round()}°',
                      onChanged: (v) => setState(() => hue = v),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(strings.familySetupSoftness),
                  Slider(
                    value: lightness,
                    min: .78,
                    max: .92,
                    semanticFormatterCallback: (v) => '${(v * 100).round()}%',
                    onChanged: (v) => setState(() => lightness = v),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(strings.homeCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, encode(color)),
                child: Text(strings.familySetupDone),
              ),
            ],
          );
        },
      ),
    );
    if (result != null) onChanged?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 0,
      children: [
        for (final value in <String?>[
          null,
          ...suggestions,
          if (selected != null && !suggestions.contains(selected)) selected,
        ])
          Semantics(
            selected: selected == value,
            child: IconButton(
              tooltip: value ?? strings.homeDefault,
              onPressed: onChanged == null ? null : () => onChanged!(value),
              icon: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: decode(value),
                  border: Border.all(
                    color: selected == value
                        ? AppColors.onHoney
                        : AppColors.paperBorder,
                    width: selected == value ? 3 : 1,
                  ),
                ),
                child: selected == value
                    ? const Icon(Icons.check, size: 14, color: AppColors.ink)
                    : null,
              ),
            ),
          ),
        IconButton(
          tooltip: strings.familySetupCustomColor,
          onPressed: onChanged == null ? null : () => _custom(context),
          icon: const Icon(Icons.palette_outlined, color: AppColors.onHoney),
        ),
      ],
    );
  }
}
