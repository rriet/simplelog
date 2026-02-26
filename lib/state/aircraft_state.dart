import 'package:flutter/material.dart';
import 'package:simplelog/features/aircraft/presentation/aircraft_screen.dart';
import 'package:simplelog/features/aircraft_types/presentation/aircraft_types_screen.dart';
import 'package:simplelog/features/airports/presentation/airport_screen.dart';
import 'package:simplelog/features/crew/presentation/crew_screen.dart';
import 'package:simplelog/features/dashboard/presentation/dashboard_screen.dart';
import 'package:simplelog/features/logbook/presentation/logbook_screen.dart';
import 'package:simplelog/presentation/about/about_screen.dart';
import 'package:simplelog/presentation/database/database_screen.dart';
import 'package:simplelog/presentation/settings/settings_screen.dart';

/// Primary navigation destinations shown in the app shell.
enum AppScreen {
  /// Dashboard overview.
  dashboard,

  /// Logbook and edit flows.
  logbook,

  /// Aircraft list and editor.
  aircraft,

  /// Aircraft types list and editor.
  aircraftTypes,

  /// Airports list and editor.
  airports,

  /// Crew list and editor.
  crew,

  /// Database import/export and sync actions.
  database,

  /// App settings.
  settings,

  /// About and licensing information.
  about,
}

/// Builds the root screen widget for each [AppScreen] entry.
extension AppScreenWidget on AppScreen {
  /// Returns the screen widget for this navigation target.
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
      AppScreen.about => const AboutScreen(),
    };
  }
}
