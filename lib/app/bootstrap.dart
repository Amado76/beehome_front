import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'di/dependencies.dart';
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

class _AppRootState extends State<_AppRoot> {
  late final AppViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.container<AppViewModel>();
    unawaited(_viewModel.initialize());
  }

  @override
  Widget build(BuildContext context) => BeeHomeApp(viewModel: _viewModel);

  @override
  void dispose() {
    _viewModel.dispose();
    unawaited(widget.container.reset());
    super.dispose();
  }
}
