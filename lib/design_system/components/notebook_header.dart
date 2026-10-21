import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_tokens.dart';
import 'device_status_frame.dart';
import 'minute_clock.dart';

/// Shared page header: calendar on the left, clock beside page actions.
class NotebookHeader extends StatelessWidget implements PreferredSizeWidget {
  const NotebookHeader({
    required this.title,
    this.leading,
    this.actions = const [],
    this.backgroundColor = AppColors.notebook,
    super.key,
  });

  final Widget title;
  final Widget? leading;
  final List<Widget> actions;
  final Color backgroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final showCalendar = !DeviceStatusFrame.showsStatusBar(context);
    final locale = Localizations.localeOf(context).toString();
    final style = AppTypography.notebookCaption.copyWith(
      fontSize: 12,
      color: AppColors.notebookInk,
    );
    return Material(
      color: backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.paperBorder)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    ?leading,
                    if (showCalendar)
                      Flexible(
                        child: MinuteClock(
                          builder: (context, now) => Text(
                            '${DateFormat.yMd(locale).format(now)}\n'
                            '${DateFormat.EEEE(locale).format(now)}',
                            style: style,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(child: Center(child: title)),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (showCalendar)
                      Flexible(
                        child: MinuteClock(
                          builder: (context, now) => Text(
                            MaterialLocalizations.of(context).formatTimeOfDay(
                              TimeOfDay.fromDateTime(now),
                              alwaysUse24HourFormat:
                                  MediaQuery.alwaysUse24HourFormatOf(context),
                            ),
                            maxLines: 1,
                            style: style,
                          ),
                        ),
                      ),
                    if (showCalendar && actions.isNotEmpty)
                      const SizedBox(width: 8),
                    for (final action in actions) Flexible(child: action),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
