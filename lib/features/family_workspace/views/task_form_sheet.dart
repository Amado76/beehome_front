import 'package:flutter/material.dart';

import '../../../design_system/theme/app_tokens.dart';
import '../../family_profiles/models/family_profile.dart';

class TaskFormSheet extends StatelessWidget {
  const TaskFormSheet({required this.wide, required this.child, super.key});

  final bool wide;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!wide) return child;
    return CustomPaint(
      foregroundPainter: _PaperFold(),
      child: ClipPath(
        clipper: _PaperShape(),
        child: ColoredBox(
          color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 40, 40, 32),
            child: child,
          ),
        ),
      ),
    );
  }
}

class TaskFormBadge extends StatelessWidget {
  const TaskFormBadge({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.pastelHoney.withValues(alpha: .5),
      border: Border.all(color: AppColors.honey.withValues(alpha: .5)),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.circle, size: 5, color: AppColors.onHoney),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: AppTypography.smallCaption.copyWith(
              color: AppColors.onHoney,
            ),
          ),
        ),
      ],
    ),
  );
}

class TaskProfileOption extends StatelessWidget {
  const TaskProfileOption({
    required this.profile,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final FamilyProfile profile;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hex = profile.color?.replaceFirst('#', '');
    final value = hex == null ? null : int.tryParse(hex, radix: 16);
    final color = value == null
        ? profile.isAdult
              ? AppColors.pastelHoney
              : AppColors.pastelBlue
        : Color(0xFF000000 | value);
    return Semantics(
      button: true,
      selected: selected,
      enabled: onTap != null,
      label: profile.name,
      child: Tooltip(
        message: profile.name,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 76,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: selected ? color : AppColors.paperWarm,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: selected ? AppColors.honey : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppColors.honey.withValues(alpha: .15),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      profile.isAdult ? Icons.face_outlined : Icons.child_care,
                      size: 30,
                      color: selected
                          ? AppColors.notebookInk
                          : AppColors.pencil,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.smallCaption.copyWith(
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: selected ? AppColors.onHoney : AppColors.pencil,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaperShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(28, 0)
    ..lineTo(size.width - 28, 0)
    ..quadraticBezierTo(size.width, 0, size.width, 28)
    ..lineTo(size.width, size.height - 32)
    ..lineTo(size.width - 32, size.height)
    ..lineTo(0, size.height)
    ..lineTo(0, 28)
    ..quadraticBezierTo(0, 0, 28, 0)
    ..close();

  @override
  bool shouldReclip(_PaperShape oldClipper) => false;
}

class _PaperFold extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fold = Path()
      ..moveTo(size.width - 32, size.height)
      ..lineTo(size.width - 32, size.height - 24)
      ..quadraticBezierTo(
        size.width - 32,
        size.height - 32,
        size.width - 24,
        size.height - 32,
      )
      ..lineTo(size.width, size.height - 32)
      ..close();
    canvas.drawShadow(fold, Colors.black.withValues(alpha: .12), 3, false);
    canvas.drawPath(fold, Paint()..color = AppColors.paperBorder);
  }

  @override
  bool shouldRepaint(_PaperFold oldDelegate) => false;
}
