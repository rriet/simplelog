import 'package:simplelog/data/database/enums/crew_position.dart';

class SouthwestImportOptions {
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

  final CrewPosition defaultSelfPosition;
  final bool recalculateBlockTime;
  final bool recalculateNightTime;
  final bool recalculateIfrTime;
  final bool recalculateCrossCountry;
  final int crossCountryThresholdNm;
  final bool recalculateInstrumentTime;
  final bool overrideExistingData;
  final bool addCopilotStaffNumberToNotes;
  final bool addFlightNumberToNotes;

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
      addCopilotStaffNumberToNotes: addCopilotStaffNumberToNotes ??
          this.addCopilotStaffNumberToNotes,
      addFlightNumberToNotes:
          addFlightNumberToNotes ?? this.addFlightNumberToNotes,
    );
  }
}
