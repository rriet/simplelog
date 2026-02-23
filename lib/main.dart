import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/app/my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dispatcher = WidgetsBinding.instance.platformDispatcher;
  final view = dispatcher.views.isNotEmpty ? dispatcher.views.first : null;
  final shortestLogicalSide = view == null
      ? 0.0
      : view.physicalSize.shortestSide / view.devicePixelRatio;
  final isIphoneSized =
      defaultTargetPlatform == TargetPlatform.iOS &&
      shortestLogicalSide > 0 &&
      shortestLogicalSide < 600;

  if (isIphoneSized) {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } else {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  runApp(const ProviderScope(child: MyApp()));
}
