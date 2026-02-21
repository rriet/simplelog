import 'package:flutter_riverpod/legacy.dart';

import 'package:simplelog/state/aircraft_state.dart';

final selectedScreenProvider =
    StateProvider<AppScreen>((ref) => AppScreen.logbook);
