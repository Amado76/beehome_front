import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'dependency_injection/dependencies.dart';
import 'view_models/app_view_model.dart';
import 'views/beehome_app.dart';

Widget createProductionApp({bool previewSplash = false}) {
  final GetIt container = GetIt.instance;
  configureDependencies(
    container,
    deviceLocales: () => WidgetsBinding.instance.platformDispatcher.locales,
    previewSplash: previewSplash,
  );
  return _AppRoot(container: container);
}

class _AppRoot extends StatefulWidget {
  const _AppRoot({required this.container});

  final GetIt container;

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> with WidgetsBindingObserver {
  late final AppViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.container<AppViewModel>();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_viewModel.initialize());
  }

  @override
  Widget build(BuildContext context) => BeeHomeApp(viewModel: _viewModel);

  @override
  void didChangeLocales(List<Locale>? locales) {
    _viewModel.updateDeviceLocales();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.dispose();
    unawaited(widget.container.reset());
    super.dispose();
  }
}
