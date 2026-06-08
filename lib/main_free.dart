import 'package:flutter/material.dart';

import 'common/flavor_config.dart';
import 'common/flavor_type.dart';
import 'common/flavor_values.dart';
import 'main.dart' as app;

void main() {
  FlavorConfig(
    flavor: FlavorType.free,
    values: const FlavorValues(
      appName: 'Story App Free',
      canPickLocation: false,
    ),
  );

  WidgetsFlutterBinding.ensureInitialized();
  app.main();
}
