import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/theme/theme_mode_controller.dart';
import 'features/tracking/application/tracking_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  // Crash recovery — PRD US-TRK-05.
  // Bila ada session active/paused yang belum ditutup, controller akan
  // resume lifecycle-nya supaya data tidak hilang.
  await container.read(trackingControllerProvider.notifier).recoverActiveTrip();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const HikeIdApp(),
    ),
  );
}
