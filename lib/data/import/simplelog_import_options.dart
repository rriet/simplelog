class SimpleLogImportOptions {
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

  final bool recalculateNightTime;
  final bool recalculateTotalTime;
  final bool recalculateTakeoffLanding;
  final bool recalculateCrossCountry;
  final int crossCountryThresholdNm;
  final bool recalculateInstrument;
  final int instrumentPercent;
  final int instrumentMinimumMinutes;
  final int instrumentSubtractMinutes;
  final bool recalculateIfrTime;
  final int ifrPercent;
  final int ifrMinimumMinutes;
  final int ifrSubtractMinutes;
  final int irp3Percent;
  final int irp3SubtractMinutes;
  final int irp4Percent;
  final int irp4SubtractMinutes;
  final bool overrideAirportValues;
  final bool overrideAircraftValues;
  final bool overrideAircraftTypeValues;

  bool get overrideExistingValues =>
      overrideAirportValues ||
      overrideAircraftValues ||
      overrideAircraftTypeValues;

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
