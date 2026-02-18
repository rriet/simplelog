import 'package:flutter/material.dart';

import 'package:simplelog/features/aircraft/presentation/aircraft_screen.dart';
import 'package:simplelog/features/aircraft_types/presentation/aircraft_types_screen.dart';
import 'package:simplelog/features/airports/presentation/airport_screen.dart';
import 'package:simplelog/features/crew/presentation/crew_screen.dart';
import 'package:simplelog/presentation/database/database_screen.dart';
import 'package:simplelog/features/logbook/presentation/logbook_screen.dart';
import 'package:simplelog/presentation/reports/reports_screen.dart';
import 'package:simplelog/presentation/settings/settings_screen.dart';

enum AppScreen {
  logbook,
  aircraft,
  aircraftTypes,
  airports,
  crew,
  reports,
  database,
  settings,
}

extension AppScreenWidget on AppScreen {
  Widget build() {
    return switch (this) {
      AppScreen.logbook => const LogbookScreen(),
      AppScreen.aircraft => const AircraftScreen(),
      AppScreen.aircraftTypes => const AircraftTypesScreen(),
      AppScreen.airports => const AirportsScreen(),
      AppScreen.crew => const CrewScreen(),
      AppScreen.reports => const ReportsScreen(),
      AppScreen.database => const DatabaseScreen(),
      AppScreen.settings => const SettingsScreen(),
    };
  }
}
