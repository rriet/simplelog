class ReportsQuery {
  const ReportsQuery({
    required this.from,
    required this.to,
    required this.includePreviousExperience,
    required this.filterMatchMode,
    required this.filters,
  });

  final DateTime from;
  final DateTime to;
  final bool includePreviousExperience;
  final ReportsFilterMatchMode filterMatchMode;
  final List<ReportsFilterCondition> filters;
}

enum ReportsFilterMatchMode { all, any }

enum ReportsFilterValueType { text, number, time, boolean }

enum ReportsFilterField {
  departureIcao,
  departureIata,
  departureName,
  departureCity,
  departureCountry,
  arrivalIcao,
  arrivalIata,
  arrivalName,
  arrivalCity,
  arrivalCountry,
  aircraftTail,
  aircraftTypeCode,
  aircraftTypeFamily,
  aircraftTypeName,
  pilotName,
  approachType,
  remarks,
  notes,
  blockTime,
  flightTime,
  totalTime,
  nightTime,
  ifrTime,
  instrumentTime,
  simulatedInstrumentTime,
  picTime,
  picusTime,
  sicTime,
  dualTime,
  instructorTime,
  crossCountryTime,
  custom1Time,
  custom2Time,
  custom3Time,
  custom4Time,
  distanceNm,
  takeoffs,
  takeoffsDay,
  takeoffsNight,
  landings,
  landingsDay,
  landingsNight,
  ifrApproaches,
  isMultiPilot,
  isSimulator,
}

enum ReportsFilterOperator {
  contains,
  startsWith,
  doesNotStartWith,
  endsWith,
  doesNotEndWith,
  isExactly,
  isNot,
  greaterThan,
  lessThan,
  equals,
  isTrue,
  isFalse,
}

extension ReportsFilterFieldMeta on ReportsFilterField {
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
      case ReportsFilterField.aircraftTypeName:
        return 'Aircraft Type Name';
      case ReportsFilterField.pilotName:
        return 'Pilot Name';
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
      case ReportsFilterField.simulatedInstrumentTime:
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
        return 'Landings Day';
      case ReportsFilterField.landingsNight:
        return 'Landings Night';
      case ReportsFilterField.ifrApproaches:
        return 'IFR Approaches';
      case ReportsFilterField.isMultiPilot:
        return 'Multi Pilot';
      case ReportsFilterField.isSimulator:
        return 'Simulator';
    }
  }
}

extension ReportsFilterOperators on ReportsFilterValueType {
  List<ReportsFilterOperator> get supportedOperators {
    switch (this) {
      case ReportsFilterValueType.text:
        return const [
          ReportsFilterOperator.contains,
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

extension ReportsFilterOperatorLabel on ReportsFilterOperator {
  String get label {
    switch (this) {
      case ReportsFilterOperator.contains:
        return 'Contains';
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
        return 'Is False';
    }
  }
}

class ReportsFilterCondition {
  const ReportsFilterCondition({
    required this.field,
    required this.operator,
    this.textValue,
    this.numberValue,
  });

  final ReportsFilterField field;
  final ReportsFilterOperator operator;
  final String? textValue;
  final int? numberValue;

  String get displayValue {
    final text = textValue?.trim() ?? '';
    if (text.isNotEmpty) return text;
    if (numberValue != null) return numberValue.toString();
    return '';
  }
}

class ReportsTotals {
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
    required this.custom1Minutes,
    required this.custom2Minutes,
    required this.custom3Minutes,
    required this.custom4Minutes,
    required this.multiPilotMinutes,
  });

  final int sectors;
  final int takeoffsDay;
  final int takeoffsNight;
  final int landingsDay;
  final int landingsNight;
  final int ifrApproaches;
  final int distanceNM;
  final int totalMinutes;
  final int nightMinutes;
  final int ifrMinutes;
  final int simulatedInstrumentMinutes;
  final int picMinutes;
  final int picusMinutes;
  final int sicMinutes;
  final int dualMinutes;
  final int instructorMinutes;
  final int crossCountryMinutes;
  final int simulatorMinutes;
  final int dutyMinutes;
  final int custom1Minutes;
  final int custom2Minutes;
  final int custom3Minutes;
  final int custom4Minutes;
  final int multiPilotMinutes;

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
        simulatorMinutes = 0,
        dutyMinutes = 0,
        custom1Minutes = 0,
        custom2Minutes = 0,
        custom3Minutes = 0,
        custom4Minutes = 0,
        multiPilotMinutes = 0;

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

class ReportsFlightRow {
  const ReportsFlightRow({
    required this.flightId,
    required this.departureDateTime,
    required this.registration,
    required this.modelCode,
    required this.modelFamily,
    required this.fromIcao,
    required this.toIcao,
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
    required this.landings,
  });

  final int flightId;
  final DateTime departureDateTime;
  final String registration;
  final String modelCode;
  final String modelFamily;
  final String fromIcao;
  final String toIcao;
  final double? fromLatitude;
  final double? fromLongitude;
  final double? toLatitude;
  final double? toLongitude;
  final int totalMinutes;
  final int picMinutes;
  final int picusMinutes;
  final int sicMinutes;
  final int dualMinutes;
  final int ifrMinutes;
  final int instrumentMinutes;
  final int nightMinutes;
  final int landings;
}

class ReportsData {
  const ReportsData({
    required this.totals,
    required this.flights,
  });

  final ReportsTotals totals;
  final List<ReportsFlightRow> flights;
}
