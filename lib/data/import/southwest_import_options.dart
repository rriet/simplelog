import 'package:simplelog/data/database/enums/crew_position.dart';

/// Strategy for rows that are missing aircraft type.
enum SouthwestMissingAircraftTypePolicy {
  /// Import and force aircraft type to `UNKNOWN`.
  useUnknown,

  /// Skip rows with missing aircraft type.
  skipLines,
}

/// Strategy for rows that are missing aircraft tail.
enum SouthwestMissingAircraftTailPolicy {
  /// Import and set tail number to the row aircraft type.
  useTypeAsTail,

  /// Skip rows with missing aircraft tail.
  skipLines,
}

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
    this.missingAircraftTypePolicy =
        SouthwestMissingAircraftTypePolicy.useUnknown,
    this.missingAircraftTailPolicy =
        SouthwestMissingAircraftTailPolicy.useTypeAsTail,
    this.skippedSourceLineNumbers = const <int>{},
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

  /// Policy used when a non-positioning row has missing aircraft type.
  final SouthwestMissingAircraftTypePolicy missingAircraftTypePolicy;

  /// Policy used when a non-positioning row has missing aircraft tail.
  final SouthwestMissingAircraftTailPolicy missingAircraftTailPolicy;

  /// Source line numbers that must be skipped for this import run.
  final Set<int> skippedSourceLineNumbers;

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
    SouthwestMissingAircraftTypePolicy? missingAircraftTypePolicy,
    SouthwestMissingAircraftTailPolicy? missingAircraftTailPolicy,
    Set<int>? skippedSourceLineNumbers,
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
      missingAircraftTypePolicy:
          missingAircraftTypePolicy ?? this.missingAircraftTypePolicy,
      missingAircraftTailPolicy:
          missingAircraftTailPolicy ?? this.missingAircraftTailPolicy,
      skippedSourceLineNumbers:
          skippedSourceLineNumbers ?? this.skippedSourceLineNumbers,
    );
  }
}
