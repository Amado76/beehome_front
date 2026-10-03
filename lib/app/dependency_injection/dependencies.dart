import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../core/config/models/app_config.dart';
import 'modules/app_module.dart';
import 'modules/core_module.dart';

void configureDependencies(
  GetIt container, {
  required List<Locale> Function() deviceLocales,
  bool previewSplash = false,
}) {
  // Validate configuration before registering any resources.
  final AppConfig config = AppConfig.fromEnvironment();
  registerCoreDependencies(container, config: config);
  registerAppDependencies(
    container,
    deviceLocales: deviceLocales,
    previewSplash: previewSplash,
  );
}
