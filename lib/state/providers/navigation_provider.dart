import 'package:flutter_riverpod/legacy.dart';

import 'package:simplelog/state/aircraft_state.dart';

/// Holds the currently selected primary app screen.
final selectedScreenProvider = StateProvider<AppScreen>(
  (ref) => AppScreen.logbook,
);
