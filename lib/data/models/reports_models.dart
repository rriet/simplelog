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
  departureCountry,
  aircraftTail,
  aircraftType,
  pilotName,
  blockTime,
  nightTime,
  distanceNm,
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
      case ReportsFilterField.departureCountry:
      case ReportsFilterField.aircraftTail:
      case ReportsFilterField.aircraftType:
      case ReportsFilterField.pilotName:
        return ReportsFilterValueType.text;
      case ReportsFilterField.blockTime:
      case ReportsFilterField.nightTime:
        return ReportsFilterValueType.time;
      case ReportsFilterField.distanceNm:
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
      case ReportsFilterField.departureCountry:
        return 'Departure Country';
      case ReportsFilterField.aircraftTail:
        return 'Aircraft Tail';
      case ReportsFilterField.aircraftType:
        return 'Aircraft Type';
      case ReportsFilterField.pilotName:
        return 'Pilot Name';
      case ReportsFilterField.blockTime:
        return 'Block Time';
      case ReportsFilterField.nightTime:
        return 'Night Time';
      case ReportsFilterField.distanceNm:
        return 'Distance NM';
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
    required this.fromIcao,
    required this.toIcao,
    required this.totalMinutes,
  });

  final int flightId;
  final DateTime departureDateTime;
  final String registration;
  final String modelCode;
  final String fromIcao;
  final String toIcao;
  final int totalMinutes;
}

class ReportsData {
  const ReportsData({
    required this.totals,
    required this.flights,
  });

  final ReportsTotals totals;
  final List<ReportsFlightRow> flights;
}
