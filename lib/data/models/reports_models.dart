/// Public API documentation.
class ReportsQuery {
  /// Public API documentation.
  const ReportsQuery({
    required this.from,
    required this.to,
    required this.includePreviousExperience,
    required this.filterMatchMode,
    required this.filters,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final DateTime from;
  /// Public API documentation.
  final DateTime to;
  /// Public API documentation.
  final bool includePreviousExperience;
  /// Public API documentation.
  final ReportsFilterMatchMode filterMatchMode;
  /// Public API documentation.
  final List<ReportsFilterCondition> filters;
/// Public API documentation.
}
/// Public API documentation.

/// Public API documentation.
enum ReportsFilterMatchMode {
  /// Public API documentation.
  all,

  /// Public API documentation.
  any,
}
/// Public API documentation.

/// Public API documentation.
enum ReportsFilterValueType {
  /// Public API documentation.
  text,

  /// Public API documentation.
  number,

  /// Public API documentation.
  time,

  /// Public API documentation.
  boolean,
}
/// Public API documentation.

/// Public API documentation.
enum ReportsFilterField {
  /// Public API documentation.
  departureIcao,
  /// Public API documentation.
  departureIata,
  /// Public API documentation.
  departureName,
  /// Public API documentation.
  departureCity,
  /// Public API documentation.
  departureCountry,
  /// Public API documentation.
  arrivalIcao,
  /// Public API documentation.
  arrivalIata,
  /// Public API documentation.
  arrivalName,
  /// Public API documentation.
  arrivalCity,
  /// Public API documentation.
  arrivalCountry,
  /// Public API documentation.
  aircraftTail,
  /// Public API documentation.
  aircraftTypeCode,
  /// Public API documentation.
  aircraftTypeFamily,
  /// Public API documentation.
  aircraftTypeName,
  /// Public API documentation.
  pilotName,
  /// Public API documentation.
  pilotOnBoard,
  /// Public API documentation.
  pilotPic,
  /// Public API documentation.
  pilotSic,
  /// Public API documentation.
  pilotTrainee,
  /// Public API documentation.
  approachType,
  /// Public API documentation.
  remarks,
  /// Public API documentation.
  notes,
  /// Public API documentation.
  blockTime,
  /// Public API documentation.
  flightTime,
  /// Public API documentation.
  totalTime,
  /// Public API documentation.
  nightTime,
  /// Public API documentation.
  ifrTime,
  /// Public API documentation.
  instrumentTime,
  /// Public API documentation.
  simulatedInstrumentTime,
  /// Public API documentation.
  picTime,
  /// Public API documentation.
  picusTime,
  /// Public API documentation.
  sicTime,
  /// Public API documentation.
  dualTime,
  /// Public API documentation.
  instructorTime,
  /// Public API documentation.
  crossCountryTime,
  /// Public API documentation.
  custom1Time,
  /// Public API documentation.
  custom2Time,
  /// Public API documentation.
  custom3Time,
  /// Public API documentation.
  custom4Time,
  /// Public API documentation.
  distanceNm,
  /// Public API documentation.
  takeoffs,
  /// Public API documentation.
  takeoffsDay,
  /// Public API documentation.
  takeoffsNight,
  /// Public API documentation.
  landings,
  /// Public API documentation.
  landingsDay,
  /// Public API documentation.
  landingsNight,
  /// Public API documentation.
  ifrApproaches,
  /// Public API documentation.
  isMultiPilot,
  /// Public API documentation.
  isSimulator,
}

/// Public API documentation.
enum ReportsFilterOperator {
  /// Public API documentation.
  contains,
  /// Public API documentation.
  doesNotContain,
  /// Public API documentation.
  startsWith,
  /// Public API documentation.
  doesNotStartWith,
  /// Public API documentation.
  endsWith,
  /// Public API documentation.
  doesNotEndWith,
  /// Public API documentation.
  isExactly,
  /// Public API documentation.
  isNot,
  /// Public API documentation.
  greaterThan,
  /// Public API documentation.
  lessThan,
  /// Public API documentation.
  equals,
  /// Public API documentation.
  isTrue,
  /// Public API documentation.
  isFalse,
}

/// Public API documentation.
extension ReportsFilterFieldMeta on ReportsFilterField {
  /// Public API documentation.
  ReportsFilterValueType get valueType {
    switch (this) {
      case ReportsFilterField.departureIcao:
      case ReportsFilterField.departureIata:
      case ReportsFilterField.departureName:
      case ReportsFilterField.departureCity:
      case ReportsFilterField.departureCountry:
      case ReportsFilterField.arrivalIcao:
      case ReportsFilterField.arrivalIata:
      case ReportsFilterField.arrivalName:
      case ReportsFilterField.arrivalCity:
      case ReportsFilterField.arrivalCountry:
      case ReportsFilterField.aircraftTail:
      case ReportsFilterField.aircraftTypeCode:
      case ReportsFilterField.aircraftTypeFamily:
      case ReportsFilterField.aircraftTypeName:
      case ReportsFilterField.pilotName:
      case ReportsFilterField.pilotOnBoard:
      case ReportsFilterField.pilotPic:
      case ReportsFilterField.pilotSic:
      case ReportsFilterField.pilotTrainee:
      case ReportsFilterField.approachType:
      case ReportsFilterField.remarks:
      case ReportsFilterField.notes:
        return ReportsFilterValueType.text;
      case ReportsFilterField.blockTime:
      case ReportsFilterField.flightTime:
      case ReportsFilterField.totalTime:
      case ReportsFilterField.nightTime:
      case ReportsFilterField.ifrTime:
      case ReportsFilterField.instrumentTime:
      case ReportsFilterField.simulatedInstrumentTime:
      case ReportsFilterField.picTime:
      case ReportsFilterField.picusTime:
      case ReportsFilterField.sicTime:
      case ReportsFilterField.dualTime:
      case ReportsFilterField.instructorTime:
      case ReportsFilterField.crossCountryTime:
      case ReportsFilterField.custom1Time:
      case ReportsFilterField.custom2Time:
      case ReportsFilterField.custom3Time:
      case ReportsFilterField.custom4Time:
        return ReportsFilterValueType.time;
      case ReportsFilterField.distanceNm:
      case ReportsFilterField.takeoffs:
      case ReportsFilterField.takeoffsDay:
      case ReportsFilterField.takeoffsNight:
      case ReportsFilterField.landings:
      case ReportsFilterField.landingsDay:
      case ReportsFilterField.landingsNight:
      case ReportsFilterField.ifrApproaches:
        return ReportsFilterValueType.number;
      case ReportsFilterField.isMultiPilot:
      case ReportsFilterField.isSimulator:
        return ReportsFilterValueType.boolean;
    }
  }

  /// Public API documentation.
  String get label {
    switch (this) {
      case ReportsFilterField.departureIcao:
        return 'Departure ICAO';
      case ReportsFilterField.departureIata:
        return 'Departure IATA';
      case ReportsFilterField.departureName:
        return 'Departure Name';
      case ReportsFilterField.departureCity:
        return 'Departure City';
      case ReportsFilterField.departureCountry:
        return 'Departure Country';
      case ReportsFilterField.arrivalIcao:
        return 'Arrival ICAO';
      case ReportsFilterField.arrivalIata:
        return 'Arrival IATA';
      case ReportsFilterField.arrivalName:
        return 'Arrival Name';
      case ReportsFilterField.arrivalCity:
        return 'Arrival City';
      case ReportsFilterField.arrivalCountry:
        return 'Arrival Country';
      case ReportsFilterField.aircraftTail:
        return 'Aircraft Registration';
      case ReportsFilterField.aircraftTypeCode:
        return 'Aircraft Type Code';
      case ReportsFilterField.aircraftTypeFamily:
        return 'Aircraft Type Family';
      /// Public API documentation.
      case ReportsFilterField.aircraftTypeName:
        /// Public API documentation.
        return 'Aircraft Type Name';
      case ReportsFilterField.pilotName:
        return 'Pilot Name';
      case ReportsFilterField.pilotOnBoard:
        return 'Pilot On Board';
      case ReportsFilterField.pilotPic:
        return 'Pilot PIC';
      case ReportsFilterField.pilotSic:
        return 'Pilot SIC';
      case ReportsFilterField.pilotTrainee:
        return 'Pilot Trainee';
      case ReportsFilterField.approachType:
        return 'Approach Type';
      case ReportsFilterField.remarks:
        return 'Remarks';
      case ReportsFilterField.notes:
        return 'Notes';
      case ReportsFilterField.blockTime:
        return 'Block Time';
      case ReportsFilterField.flightTime:
        return 'Flight Time';
      case ReportsFilterField.totalTime:
        return 'Total Time';
      case ReportsFilterField.nightTime:
        return 'Night Time';
      case ReportsFilterField.ifrTime:
        return 'IFR Time';
      case ReportsFilterField.instrumentTime:
        return 'Instrument Time';
      /// Public API documentation.
      case ReportsFilterField.simulatedInstrumentTime:
        /// Public API documentation.
        return 'Sim Instrument Time';
      case ReportsFilterField.picTime:
        return 'PIC Time';
      case ReportsFilterField.picusTime:
        return 'PICUS Time';
      case ReportsFilterField.sicTime:
        return 'SIC Time';
      case ReportsFilterField.dualTime:
        return 'Dual Time';
      case ReportsFilterField.instructorTime:
        return 'Instructor Time';
      case ReportsFilterField.crossCountryTime:
        return 'Cross-Country Time';
      case ReportsFilterField.custom1Time:
        return 'Custom 1 Time';
      case ReportsFilterField.custom2Time:
        return 'Custom 2 Time';
      case ReportsFilterField.custom3Time:
        return 'Custom 3 Time';
      case ReportsFilterField.custom4Time:
        return 'Custom 4 Time';
      case ReportsFilterField.distanceNm:
        return 'Distance NM';
      case ReportsFilterField.takeoffs:
        return 'Takeoffs';
      case ReportsFilterField.takeoffsDay:
        return 'Takeoffs Day';
      case ReportsFilterField.takeoffsNight:
        return 'Takeoffs Night';
      case ReportsFilterField.landings:
        return 'Landings';
      case ReportsFilterField.landingsDay:
        /// Public API documentation.
        return 'Landings Day';
      /// Public API documentation.
      case ReportsFilterField.landingsNight:
        return 'Landings Night';
      case ReportsFilterField.ifrApproaches:
        return 'IFR Approaches';
      case ReportsFilterField.isMultiPilot:
        return 'Multi Pilot';
      case ReportsFilterField.isSimulator:
        /// Public API documentation.
        return 'Simulator';
    /// Public API documentation.
    }
  /// Public API documentation.
  }
/// Public API documentation.
}

/// Public API documentation.
extension ReportsFilterOperators on ReportsFilterValueType {
  /// Public API documentation.
  List<ReportsFilterOperator> get supportedOperators {
    switch (this) {
      case ReportsFilterValueType.text:
        return const [
          ReportsFilterOperator.contains,
          /// Public API documentation.
          ReportsFilterOperator.doesNotContain,
          /// Public API documentation.
          ReportsFilterOperator.startsWith,
          ReportsFilterOperator.doesNotStartWith,
          ReportsFilterOperator.endsWith,
          ReportsFilterOperator.doesNotEndWith,
          ReportsFilterOperator.isExactly,
          ReportsFilterOperator.isNot,
        ];
      case ReportsFilterValueType.number:
      case ReportsFilterValueType.time:
        return const [
          ReportsFilterOperator.greaterThan,
          ReportsFilterOperator.lessThan,
          ReportsFilterOperator.equals,
        ];
      case ReportsFilterValueType.boolean:
        return const [
          ReportsFilterOperator.isTrue,
          ReportsFilterOperator.isFalse,
        ];
    }
  }
}

/// Public API documentation.
extension ReportsFilterOperatorLabel on ReportsFilterOperator {
  /// Public API documentation.
  String get label {
    /// Public API documentation.
    switch (this) {
      case ReportsFilterOperator.contains:
        return 'Contains';
      case ReportsFilterOperator.doesNotContain:
        return 'Does not contain';
      case ReportsFilterOperator.startsWith:
        return 'Starts With';
      case ReportsFilterOperator.doesNotStartWith:
        return 'Does not start with';
      case ReportsFilterOperator.endsWith:
        return 'Ends With';
      case ReportsFilterOperator.doesNotEndWith:
        return 'Does not end with';
      case ReportsFilterOperator.isExactly:
        return 'Is';
      case ReportsFilterOperator.isNot:
        return 'Is not';
      case ReportsFilterOperator.greaterThan:
        return 'Greater than';
      case ReportsFilterOperator.lessThan:
        return 'Less than';
      case ReportsFilterOperator.equals:
        return 'Equals';
      case ReportsFilterOperator.isTrue:
        return 'Is True';
      case ReportsFilterOperator.isFalse:
        /// Public API documentation.
        return 'Is False';
    /// Public API documentation.
    }
  /// Public API documentation.
  }
/// Public API documentation.
}
/// Public API documentation.

/// Public API documentation.
class ReportsFilterCondition {
  /// Public API documentation.
  const ReportsFilterCondition({
    /// Public API documentation.
    required this.field,
    /// Public API documentation.
    required this.operator,
    /// Public API documentation.
    this.textValue,
    /// Public API documentation.
    this.numberValue,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final ReportsFilterField field;
  /// Public API documentation.
  final ReportsFilterOperator operator;
  /// Public API documentation.
  final String? textValue;
  /// Public API documentation.
  final int? numberValue;
/// Public API documentation.

  /// Public API documentation.
  String get displayValue {
    final text = textValue?.trim() ?? '';
    if (text.isNotEmpty) return text;
    if (numberValue != null) return numberValue.toString();
    return '';
  }
}

/// Public API documentation.
class ReportsTotals {
  /// Public API documentation.
  const ReportsTotals({
    required this.sectors,
    required this.takeoffsDay,
    required this.takeoffsNight,
    required this.landingsDay,
    required this.landingsNight,
    required this.ifrApproaches,
    required this.distanceNM,
    required this.totalMinutes,
    required this.nightMinutes,
    required this.ifrMinutes,
    required this.simulatedInstrumentMinutes,
    required this.picMinutes,
    required this.picusMinutes,
    required this.sicMinutes,
    required this.dualMinutes,
    required this.instructorMinutes,
    required this.crossCountryMinutes,
    required this.simulatorMinutes,
    required this.dutyMinutes,
    /// Public API documentation.
    required this.custom1Minutes,
    /// Public API documentation.
    required this.custom2Minutes,
    required this.custom3Minutes,
    required this.custom4Minutes,
    required this.multiPilotMinutes,
  });

  /// Public API documentation.
  const ReportsTotals.zero()
    : sectors = 0,
      takeoffsDay = 0,
      takeoffsNight = 0,
      landingsDay = 0,
      landingsNight = 0,
      ifrApproaches = 0,
      distanceNM = 0,
      totalMinutes = 0,
      nightMinutes = 0,
      ifrMinutes = 0,
      simulatedInstrumentMinutes = 0,
      picMinutes = 0,
      picusMinutes = 0,
      sicMinutes = 0,
      dualMinutes = 0,
      instructorMinutes = 0,
      crossCountryMinutes = 0,
      /// Public API documentation.
      simulatorMinutes = 0,
      /// Public API documentation.
      dutyMinutes = 0,
      /// Public API documentation.
      custom1Minutes = 0,
      /// Public API documentation.
      custom2Minutes = 0,
      /// Public API documentation.
      custom3Minutes = 0,
      /// Public API documentation.
      custom4Minutes = 0,
      /// Public API documentation.
      multiPilotMinutes = 0;
/// Public API documentation.

  /// Public API documentation.
  final int sectors;
  /// Public API documentation.
  final int takeoffsDay;
  /// Public API documentation.
  final int takeoffsNight;
  /// Public API documentation.
  final int landingsDay;
  /// Public API documentation.
  final int landingsNight;
  /// Public API documentation.
  final int ifrApproaches;
  /// Public API documentation.
  final int distanceNM;
  /// Public API documentation.
  final int totalMinutes;
  /// Public API documentation.
  final int nightMinutes;
  /// Public API documentation.
  final int ifrMinutes;
  /// Public API documentation.
  final int simulatedInstrumentMinutes;
  /// Public API documentation.
  final int picMinutes;
  /// Public API documentation.
  final int picusMinutes;
  /// Public API documentation.
  final int sicMinutes;
  /// Public API documentation.
  final int dualMinutes;
  /// Public API documentation.
  final int instructorMinutes;
  /// Public API documentation.
  final int crossCountryMinutes;
  /// Public API documentation.
  final int simulatorMinutes;
  /// Public API documentation.
  final int dutyMinutes;
  /// Public API documentation.
  final int custom1Minutes;
  /// Public API documentation.
  final int custom2Minutes;
  /// Public API documentation.
  final int custom3Minutes;
  /// Public API documentation.
  final int custom4Minutes;
  /// Public API documentation.
  final int multiPilotMinutes;

  /// Public API documentation.
  ReportsTotals operator +(ReportsTotals other) {
    return ReportsTotals(
      sectors: sectors + other.sectors,
      takeoffsDay: takeoffsDay + other.takeoffsDay,
      takeoffsNight: takeoffsNight + other.takeoffsNight,
      landingsDay: landingsDay + other.landingsDay,
      landingsNight: landingsNight + other.landingsNight,
      ifrApproaches: ifrApproaches + other.ifrApproaches,
      distanceNM: distanceNM + other.distanceNM,
      totalMinutes: totalMinutes + other.totalMinutes,
      nightMinutes: nightMinutes + other.nightMinutes,
      ifrMinutes: ifrMinutes + other.ifrMinutes,
      simulatedInstrumentMinutes:
          simulatedInstrumentMinutes + other.simulatedInstrumentMinutes,
      picMinutes: picMinutes + other.picMinutes,
      picusMinutes: picusMinutes + other.picusMinutes,
      sicMinutes: sicMinutes + other.sicMinutes,
      dualMinutes: dualMinutes + other.dualMinutes,
      instructorMinutes: instructorMinutes + other.instructorMinutes,
      crossCountryMinutes: crossCountryMinutes + other.crossCountryMinutes,
      simulatorMinutes: simulatorMinutes + other.simulatorMinutes,
      dutyMinutes: dutyMinutes + other.dutyMinutes,
      custom1Minutes: custom1Minutes + other.custom1Minutes,
      custom2Minutes: custom2Minutes + other.custom2Minutes,
      custom3Minutes: custom3Minutes + other.custom3Minutes,
      custom4Minutes: custom4Minutes + other.custom4Minutes,
      multiPilotMinutes: multiPilotMinutes + other.multiPilotMinutes,
    );
  }
}

/// Public API documentation.
class ReportsFlightRow {
  /// Public API documentation.
  const ReportsFlightRow({
    required this.flightId,
    required this.departureDateTime,
    required this.registration,
    required this.modelCode,
    required this.modelFamily,
    required this.fromIcao,
    required this.toIcao,
    required this.pilotNames,
    required this.fromLatitude,
    required this.fromLongitude,
    required this.toLatitude,
    required this.toLongitude,
    required this.totalMinutes,
    required this.picMinutes,
    required this.picusMinutes,
    required this.sicMinutes,
    required this.dualMinutes,
    required this.ifrMinutes,
    required this.instrumentMinutes,
    required this.nightMinutes,
    required this.takeoffs,
    required this.landings,
  });

  /// Public API documentation.
  final int flightId;
  /// Public API documentation.
  final DateTime departureDateTime;
  /// Public API documentation.
  final String registration;
  /// Public API documentation.
  final String modelCode;
  /// Public API documentation.
  final String modelFamily;
  /// Public API documentation.
  final String fromIcao;
  /// Public API documentation.
  final String toIcao;
  /// Public API documentation.
  final String pilotNames;
  /// Public API documentation.
  final double? fromLatitude;
  /// Public API documentation.
  final double? fromLongitude;
  /// Public API documentation.
  final double? toLatitude;
  /// Public API documentation.
  final double? toLongitude;
  /// Public API documentation.
  final int totalMinutes;
  /// Public API documentation.
  final int picMinutes;
  /// Public API documentation.
  final int picusMinutes;
  /// Public API documentation.
  final int sicMinutes;
  /// Public API documentation.
  final int dualMinutes;
  /// Public API documentation.
  final int ifrMinutes;
  /// Public API documentation.
  final int instrumentMinutes;
  /// Public API documentation.
  final int nightMinutes;
  /// Public API documentation.
  final int takeoffs;
  /// Public API documentation.
  final int landings;
}

/// Public API documentation.
class ReportsData {
  /// Public API documentation.
  const ReportsData({required this.totals, required this.flights});

  /// Public API documentation.
  final ReportsTotals totals;
  /// Public API documentation.
  final List<ReportsFlightRow> flights;
}
