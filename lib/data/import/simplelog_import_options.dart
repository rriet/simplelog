/// Public API documentation.
class SimpleLogImportOptions {
  /// Public API documentation.
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
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final bool recalculateNightTime;
  /// Public API documentation.
  final bool recalculateTotalTime;
  /// Public API documentation.
  final bool recalculateTakeoffLanding;
  /// Public API documentation.
  final bool recalculateCrossCountry;
  /// Public API documentation.
  final int crossCountryThresholdNm;
  /// Public API documentation.
  final bool recalculateInstrument;
  /// Public API documentation.
  final int instrumentPercent;
  /// Public API documentation.
  final int instrumentMinimumMinutes;
  /// Public API documentation.
  final int instrumentSubtractMinutes;
  /// Public API documentation.
  final bool recalculateIfrTime;
  /// Public API documentation.
  final int ifrPercent;
  /// Public API documentation.
  final int ifrMinimumMinutes;
  /// Public API documentation.
  final int ifrSubtractMinutes;
  /// Public API documentation.
  final int irp3Percent;
  /// Public API documentation.
  final int irp3SubtractMinutes;
  /// Public API documentation.
  final int irp4Percent;
  /// Public API documentation.
  final int irp4SubtractMinutes;
  /// Public API documentation.
  final bool overrideAirportValues;
  /// Public API documentation.
  final bool overrideAircraftValues;
  /// Public API documentation.
  final bool overrideAircraftTypeValues;

  /// Public API documentation.
  bool get overrideExistingValues =>
      overrideAirportValues ||
      overrideAircraftValues ||
      overrideAircraftTypeValues;

  /// Public API documentation.
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
