/// Immutable options controlling legacy SimpleLog CSV import behavior.
class SimpleLogImportOptions {
  /// Creates import options.
  ///
  /// Inputs are booleans/thresholds for recalculation and overwrite behavior.
  /// Output is a value object consumed by the CSV importer.
  const SimpleLogImportOptions({
    this.recalculateNightTime = false,
    this.recalculateTotalTime = false,
    this.recalculateTakeoffLanding = false,
    this.recalculateCrossCountry = false,
    this.crossCountryThresholdNm = 50,
    this.recalculateInstrument = false,
    this.instrumentPercent = 0,
    this.instrumentMinimumMinutes = 0,
    this.instrumentSubtractMinutes = 0,
    this.recalculateIfrTime = false,
    this.ifrPercent = 0,
    this.ifrMinimumMinutes = 0,
    this.ifrSubtractMinutes = 0,
    this.irp3Percent = 100,
    this.irp3SubtractMinutes = 0,
    this.irp4Percent = 100,
    this.irp4SubtractMinutes = 0,
    this.overrideAirportValues = false,
    this.overrideAircraftValues = false,
    this.overrideAircraftTypeValues = false,
  });

  /// Recompute night minutes from timeline values.
  final bool recalculateNightTime;
  /// Recompute total time and derived pilot-function splits.
  final bool recalculateTotalTime;
  /// Recompute takeoff/landing day-night counters.
  final bool recalculateTakeoffLanding;
  /// Recompute cross-country time.
  final bool recalculateCrossCountry;
  /// Cross-country threshold in nautical miles.
  final int crossCountryThresholdNm;
  /// Recompute instrument time.
  final bool recalculateInstrument;
  /// Instrument percentage applied to source totals.
  final int instrumentPercent;
  /// Minimum instrument time in minutes.
  final int instrumentMinimumMinutes;
  /// Minutes subtracted before applying instrument percentage.
  final int instrumentSubtractMinutes;
  /// Recompute IFR time.
  final bool recalculateIfrTime;
  /// IFR percentage applied to source totals.
  final int ifrPercent;
  /// Minimum IFR time in minutes.
  final int ifrMinimumMinutes;
  /// Minutes subtracted before IFR percentage.
  final int ifrSubtractMinutes;
  /// IRP3 percentage used by total-time recalculation.
  final int irp3Percent;
  /// IRP3 fixed minutes used by total-time recalculation.
  final int irp3SubtractMinutes;
  /// IRP4 percentage used by total-time recalculation.
  final int irp4Percent;
  /// IRP4 fixed minutes used by total-time recalculation.
  final int irp4SubtractMinutes;
  /// Whether airport master data should be overwritten when matched.
  final bool overrideAirportValues;
  /// Whether aircraft rows should be overwritten when matched.
  final bool overrideAircraftValues;
  /// Whether aircraft type rows should be overwritten when matched.
  final bool overrideAircraftTypeValues;

  /// Whether any overwrite option is enabled for existing reference data.
  bool get overrideExistingValues =>
      overrideAirportValues ||
      overrideAircraftValues ||
      overrideAircraftTypeValues;

  /// Returns a copy with selected fields replaced.
  SimpleLogImportOptions copyWith({
    bool? recalculateNightTime,
    bool? recalculateTotalTime,
    bool? recalculateTakeoffLanding,
    bool? recalculateCrossCountry,
    int? crossCountryThresholdNm,
    bool? recalculateInstrument,
    int? instrumentPercent,
    int? instrumentMinimumMinutes,
    int? instrumentSubtractMinutes,
    bool? recalculateIfrTime,
    int? ifrPercent,
    int? ifrMinimumMinutes,
    int? ifrSubtractMinutes,
    int? irp3Percent,
    int? irp3SubtractMinutes,
    int? irp4Percent,
    int? irp4SubtractMinutes,
    bool? overrideAirportValues,
    bool? overrideAircraftValues,
    bool? overrideAircraftTypeValues,
  }) {
    return SimpleLogImportOptions(
      recalculateNightTime: recalculateNightTime ?? this.recalculateNightTime,
      recalculateTotalTime: recalculateTotalTime ?? this.recalculateTotalTime,
      recalculateTakeoffLanding:
          recalculateTakeoffLanding ?? this.recalculateTakeoffLanding,
      recalculateCrossCountry:
          recalculateCrossCountry ?? this.recalculateCrossCountry,
      crossCountryThresholdNm:
          crossCountryThresholdNm ?? this.crossCountryThresholdNm,
      recalculateInstrument:
          recalculateInstrument ?? this.recalculateInstrument,
      instrumentPercent: instrumentPercent ?? this.instrumentPercent,
      instrumentMinimumMinutes:
          instrumentMinimumMinutes ?? this.instrumentMinimumMinutes,
      instrumentSubtractMinutes:
          instrumentSubtractMinutes ?? this.instrumentSubtractMinutes,
      recalculateIfrTime: recalculateIfrTime ?? this.recalculateIfrTime,
      ifrPercent: ifrPercent ?? this.ifrPercent,
      ifrMinimumMinutes: ifrMinimumMinutes ?? this.ifrMinimumMinutes,
      ifrSubtractMinutes: ifrSubtractMinutes ?? this.ifrSubtractMinutes,
      irp3Percent: irp3Percent ?? this.irp3Percent,
      irp3SubtractMinutes: irp3SubtractMinutes ?? this.irp3SubtractMinutes,
      irp4Percent: irp4Percent ?? this.irp4Percent,
      irp4SubtractMinutes: irp4SubtractMinutes ?? this.irp4SubtractMinutes,
      overrideAirportValues:
          overrideAirportValues ?? this.overrideAirportValues,
      overrideAircraftValues:
          overrideAircraftValues ?? this.overrideAircraftValues,
      overrideAircraftTypeValues:
          overrideAircraftTypeValues ?? this.overrideAircraftTypeValues,
    );
  }
}
