import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class FoundationPanel extends StatelessWidget {
  const FoundationPanel({
    required this.title,
    required this.message,
    this.action,
    super.key,
  });

  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.medium),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.large),
            action!,
          ],
        ],
      ),
    ),
  );
}
