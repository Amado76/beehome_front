import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/views/beehome_app.dart';
import 'app/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom],
  );
  try {
    runApp(createProductionApp());
  } on FormatException {
    runApp(const ConfigurationFailureApp());
  }
}
