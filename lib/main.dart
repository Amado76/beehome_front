import 'package:flutter/material.dart';

import 'app/views/beehome_app.dart';
import 'app/bootstrap.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    runApp(createProductionApp());
  } on FormatException {
    runApp(const ConfigurationFailureApp());
  }
}
