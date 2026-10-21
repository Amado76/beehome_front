import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// A notebook label shared by text fields across authentication and forms.
class AppField extends StatelessWidget {
  const AppField({required this.label, required this.child, super.key});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label.toUpperCase(),
        style: AppTypography.notebookCaption.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      child,
    ],
  );
}
