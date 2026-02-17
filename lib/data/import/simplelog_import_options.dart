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
    this.airportStrategy = MergeStrategy.keep,
    this.crewStrategy = MergeStrategy.keep,
    this.aircraftStrategy = MergeStrategy.keep,
    this.aircraftTypeStrategy = MergeStrategy.keep,
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
  final MergeStrategy airportStrategy;
  final MergeStrategy crewStrategy;
  final MergeStrategy aircraftStrategy;
  final MergeStrategy aircraftTypeStrategy;

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
    MergeStrategy? airportStrategy,
    MergeStrategy? crewStrategy,
    MergeStrategy? aircraftStrategy,
    MergeStrategy? aircraftTypeStrategy,
  }) {
    return SimpleLogImportOptions(
      recalculateNightTime:
          recalculateNightTime ?? this.recalculateNightTime,
      recalculateTotalTime:
          recalculateTotalTime ?? this.recalculateTotalTime,
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
      airportStrategy: airportStrategy ?? this.airportStrategy,
      crewStrategy: crewStrategy ?? this.crewStrategy,
      aircraftStrategy: aircraftStrategy ?? this.aircraftStrategy,
      aircraftTypeStrategy: aircraftTypeStrategy ?? this.aircraftTypeStrategy,
    );
  }
}

enum MergeStrategy { keep, override, mix }
