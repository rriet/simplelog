import 'package:simplelog/data/database/enums/crew_position.dart';

/// Public API documentation.
class SouthwestImportOptions {
  /// Public API documentation.
  const SouthwestImportOptions({
    this.defaultSelfPosition = CrewPosition.sic,
    this.recalculateBlockTime = true,
    this.recalculateNightTime = true,
    this.recalculateIfrTime = true,
    this.recalculateCrossCountry = true,
    this.crossCountryThresholdNm = 50,
    this.recalculateInstrumentTime = false,
    this.overrideExistingData = false,
    this.addCopilotStaffNumberToNotes = true,
    this.addFlightNumberToNotes = true,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final CrewPosition defaultSelfPosition;
  /// Public API documentation.
  final bool recalculateBlockTime;
  /// Public API documentation.
  final bool recalculateNightTime;
  /// Public API documentation.
  final bool recalculateIfrTime;
  /// Public API documentation.
  final bool recalculateCrossCountry;
  /// Public API documentation.
  final int crossCountryThresholdNm;
  /// Public API documentation.
  final bool recalculateInstrumentTime;
  /// Public API documentation.
  final bool overrideExistingData;
  /// Public API documentation.
  final bool addCopilotStaffNumberToNotes;
  /// Public API documentation.
  final bool addFlightNumberToNotes;

  /// Public API documentation.
  SouthwestImportOptions copyWith({
    CrewPosition? defaultSelfPosition,
    bool? recalculateBlockTime,
    bool? recalculateNightTime,
    bool? recalculateIfrTime,
    bool? recalculateCrossCountry,
    int? crossCountryThresholdNm,
    bool? recalculateInstrumentTime,
    bool? overrideExistingData,
    bool? addCopilotStaffNumberToNotes,
    bool? addFlightNumberToNotes,
  }) {
    return SouthwestImportOptions(
      defaultSelfPosition: defaultSelfPosition ?? this.defaultSelfPosition,
      recalculateBlockTime: recalculateBlockTime ?? this.recalculateBlockTime,
      recalculateNightTime: recalculateNightTime ?? this.recalculateNightTime,
      recalculateIfrTime: recalculateIfrTime ?? this.recalculateIfrTime,
      recalculateCrossCountry:
          recalculateCrossCountry ?? this.recalculateCrossCountry,
      crossCountryThresholdNm:
          crossCountryThresholdNm ?? this.crossCountryThresholdNm,
      recalculateInstrumentTime:
          recalculateInstrumentTime ?? this.recalculateInstrumentTime,
      overrideExistingData: overrideExistingData ?? this.overrideExistingData,
      addCopilotStaffNumberToNotes:
          addCopilotStaffNumberToNotes ?? this.addCopilotStaffNumberToNotes,
      addFlightNumberToNotes:
          addFlightNumberToNotes ?? this.addFlightNumberToNotes,
    );
  }
}
