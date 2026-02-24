import 'package:simplelog/data/database/enums/crew_position.dart';

/// Tuning options used when importing Southwest CSV exports.
class SouthwestImportOptions {
  /// Creates a new set of import options.
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
  });

  /// Default crew position used when deriving "self" crew.
  final CrewPosition defaultSelfPosition;

  /// Whether to recompute block time from departure/arrival instead of CSV.
  final bool recalculateBlockTime;

  /// Whether to recompute night time using sun position instead of CSV.
  final bool recalculateNightTime;

  /// Whether to recompute IFR time from block time.
  final bool recalculateIfrTime;

  /// Whether to recompute cross‑country time from leg distance.
  final bool recalculateCrossCountry;

  /// Minimum NM distance to consider a flight cross‑country.
  final int crossCountryThresholdNm;

  /// Whether to recompute instrument time from block time.
  final bool recalculateInstrumentTime;

  /// Whether to overwrite existing imported entities with new values.
  final bool overrideExistingData;

  /// Whether copilot staff number should be appended to notes.
  final bool addCopilotStaffNumberToNotes;

  /// Whether flight number should be appended to notes.
  final bool addFlightNumberToNotes;

  /// Returns a copy of this options object with some values changed.
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
