import 'package:flutter/material.dart';

import 'package:simplelog/features/aircraft/presentation/aircraft_screen.dart';
import 'package:simplelog/features/aircraft_types/presentation/aircraft_types_screen.dart';
import 'package:simplelog/features/airports/presentation/airport_screen.dart';
import 'package:simplelog/features/crew/presentation/crew_screen.dart';
import 'package:simplelog/features/dashboard/presentation/dashboard_screen.dart';
import 'package:simplelog/presentation/database/database_screen.dart';
import 'package:simplelog/features/logbook/presentation/logbook_screen.dart';
import 'package:simplelog/presentation/settings/settings_screen.dart';

enum AppScreen {
  dashboard,
  logbook,
  aircraft,
  aircraftTypes,
  airports,
  crew,
  database,
  settings,
}

extension AppScreenWidget on AppScreen {
  Widget build() {
    return switch (this) {
      AppScreen.dashboard => const DashboardScreen(),
      AppScreen.logbook => const LogbookScreen(),
      AppScreen.aircraft => const AircraftScreen(),
      AppScreen.aircraftTypes => const AircraftTypesScreen(),
      AppScreen.airports => const AirportsScreen(),
      AppScreen.crew => const CrewScreen(),
      AppScreen.database => const DatabaseScreen(),
      AppScreen.settings => const SettingsScreen(),
    };
  }
}
