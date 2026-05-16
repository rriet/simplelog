// Value object with many straightforward fields; per-field docs add noise.
// ignore_for_file: public_member_api_docs

import 'package:simplelog/data/import/import_source_dispatcher.dart';

/// Shared pre-import options shown for all non-database imports.
class UnifiedImportOptions {
  /// Creates shared options.
  const UnifiedImportOptions({
    required this.recalculateTotalTime,
    required this.recalculateNightTime,
    required this.recalculateTakeoffLanding,
    required this.recalculateCrossCountry,
    required this.recalculateIfrTime,
    required this.overrideAirportOnConflict,
    required this.overrideAircraftOnConflict,
    required this.overrideTypeOnConflict,
  });

  /// Build default options per detected source kind.
  factory UnifiedImportOptions.defaultsFor(ImportSourceKind kind) {
    final recalcDefault = kind == ImportSourceKind.southwestCsv;
    return UnifiedImportOptions(
      recalculateTotalTime: recalcDefault,
      recalculateNightTime: recalcDefault,
      recalculateTakeoffLanding: recalcDefault,
      recalculateCrossCountry: recalcDefault,
      recalculateIfrTime: recalcDefault,
      overrideAirportOnConflict: false,
      overrideAircraftOnConflict: false,
      overrideTypeOnConflict: false,
    );
  }

  final bool recalculateTotalTime;
  final bool recalculateNightTime;
  final bool recalculateTakeoffLanding;
  final bool recalculateCrossCountry;
  final bool recalculateIfrTime;

  final bool overrideAirportOnConflict;
  final bool overrideAircraftOnConflict;
  final bool overrideTypeOnConflict;

  UnifiedImportOptions copyWith({
    bool? recalculateTotalTime,
    bool? recalculateNightTime,
    bool? recalculateTakeoffLanding,
    bool? recalculateCrossCountry,
    bool? recalculateIfrTime,
    bool? overrideAirportOnConflict,
    bool? overrideAircraftOnConflict,
    bool? overrideTypeOnConflict,
  }) {
    return UnifiedImportOptions(
      recalculateTotalTime: recalculateTotalTime ?? this.recalculateTotalTime,
      recalculateNightTime: recalculateNightTime ?? this.recalculateNightTime,
      recalculateTakeoffLanding:
          recalculateTakeoffLanding ?? this.recalculateTakeoffLanding,
      recalculateCrossCountry:
          recalculateCrossCountry ?? this.recalculateCrossCountry,
      recalculateIfrTime: recalculateIfrTime ?? this.recalculateIfrTime,
      overrideAirportOnConflict:
          overrideAirportOnConflict ?? this.overrideAirportOnConflict,
      overrideAircraftOnConflict:
          overrideAircraftOnConflict ?? this.overrideAircraftOnConflict,
      overrideTypeOnConflict:
          overrideTypeOnConflict ?? this.overrideTypeOnConflict,
    );
  }
}
