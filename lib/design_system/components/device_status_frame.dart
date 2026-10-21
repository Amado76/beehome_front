import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/device/repos/device_status_repository.dart';
import '../../core/device/view_models/device_status_view_model.dart';
import '../../l10n/generated/app_localizations.dart';
import '../theme/app_tokens.dart';
import 'minute_clock.dart';

/// Reserves the same status area above every page without duplicating safe insets.
class DeviceStatusFrame extends StatelessWidget {
  const DeviceStatusFrame({required this.child, this.repository, super.key});

  final Widget child;
  final DeviceStatusRepository? repository;

  static bool showsStatusBar(BuildContext context) =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android) &&
      MediaQuery.sizeOf(context).width < AppLayout.tablet;

  @override
  Widget build(BuildContext context) => showsStatusBar(context)
      ? _MobileDeviceStatusFrame(repository: repository, child: child)
      : child;
}

class _MobileDeviceStatusFrame extends StatefulWidget {
  const _MobileDeviceStatusFrame({required this.child, this.repository});

  final Widget child;
  final DeviceStatusRepository? repository;

  @override
  State<_MobileDeviceStatusFrame> createState() => _DeviceStatusFrameState();
}

class _DeviceStatusFrameState extends State<_MobileDeviceStatusFrame>
    with WidgetsBindingObserver {
  late final DeviceStatusViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DeviceStatusViewModel(
      repository: widget.repository ?? PlatformDeviceStatusRepository(),
    );
    WidgetsBinding.instance.addObserver(this);
    if (WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      _viewModel.resume();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _viewModel.resume();
    } else {
      _viewModel.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final minimum =
        !kIsWeb &&
            defaultTargetPlatform == TargetPlatform.iOS &&
            media.orientation == Orientation.portrait
        ? 54.0
        : 32.0;
    final height = math.max(media.viewPadding.top, minimum);
    return Material(
      color: AppColors.paperWarm,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: media.viewPadding.left,
              right: media.viewPadding.right,
            ),
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) => DeviceStatusBar(
                height: height,
                battery: _viewModel.battery,
                connection: _viewModel.connection,
              ),
            ),
          ),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

class DeviceStatusBar extends StatelessWidget {
  const DeviceStatusBar({
    required this.height,
    this.battery,
    this.connection,
    super.key,
  });
  final double height;
  final DeviceBattery? battery;
  final DeviceConnection? connection;

  IconData get _connectionIcon => switch (connection) {
    DeviceConnection.wifi => Icons.wifi_rounded,
    DeviceConnection.mobile => Icons.cell_tower_rounded,
    DeviceConnection.ethernet => Icons.settings_ethernet_rounded,
    DeviceConnection.other => Icons.public_rounded,
    DeviceConnection.offline => Icons.wifi_off_rounded,
    null => Icons.signal_wifi_statusbar_null_rounded,
  };

  String _connectionLabel(AppLocalizations strings) => switch (connection) {
    DeviceConnection.wifi => strings.deviceConnectionWifi,
    DeviceConnection.mobile => strings.deviceConnectionMobile,
    DeviceConnection.ethernet => strings.deviceConnectionEthernet,
    DeviceConnection.other => strings.deviceConnectionOther,
    DeviceConnection.offline => strings.deviceConnectionOffline,
    null => strings.deviceConnectionUnknown,
  };

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 0),
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: MinuteClock(
                builder: (BuildContext context, DateTime now) => Text(
                  MaterialLocalizations.of(context).formatTimeOfDay(
                    TimeOfDay.fromDateTime(now),
                    alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(
                      context,
                    ),
                  ),
                  style: AppTypography.notebookCaption.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    height: 1.5,
                    color: AppColors.honey,
                  ),
                ),
              ),
            ),
          ),
          // Keep the center clear for the camera cutout / Dynamic Island.
          SizedBox(
            width: math.min(164, MediaQuery.sizeOf(context).width * 0.42),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: IconTheme(
                data: const IconThemeData(color: AppColors.honey, size: 18),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      label: _connectionLabel(AppLocalizations.of(context)!),
                      child: Icon(_connectionIcon),
                    ),
                    const SizedBox(width: 8),
                    _BatteryIndicator(battery: battery),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _BatteryIndicator extends StatelessWidget {
  const _BatteryIndicator({required this.battery});

  final DeviceBattery? battery;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final level = battery?.level;
    final charging = battery?.charging == true;
    final label = [
      level == null
          ? strings.deviceBatteryUnknown
          : strings.deviceBatteryLevel(level),
      if (charging) strings.deviceBatteryCharging,
    ].join(', ');
    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 25,
              height: 13,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.honey),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Stack(
                children: [
                  if (level != null)
                    FractionallySizedBox(
                      widthFactor: level.clamp(0, 100) / 100,
                      heightFactor: 1,
                      child: ColoredBox(
                        color: AppColors.honey.withValues(alpha: .7),
                      ),
                    ),
                  if (charging || level == null)
                    Center(
                      child: Icon(
                        charging ? Icons.bolt_rounded : Icons.question_mark,
                        size: 9,
                        color: AppColors.notebookInk,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 1),
            Container(width: 2, height: 5, color: AppColors.honey),
          ],
        ),
      ),
    );
  }
}
