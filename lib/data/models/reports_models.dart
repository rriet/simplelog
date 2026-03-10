/// Parameters used when querying report data from the repository.
class ReportsQuery {
  /// Creates a new reports query for a date range and filters.
  const ReportsQuery({
    required this.from,
    required this.to,
    required this.includePreviousExperience,
    required this.filterMatchMode,
    required this.filters,
  });

  /// Start of the date range (inclusive, in UTC).
  final DateTime from;

  /// End of the date range (inclusive, in UTC).
  final DateTime to;

  /// Whether to include previous experience in computed totals.
  final bool includePreviousExperience;

  /// How filter conditions should be combined.
  final ReportsFilterMatchMode filterMatchMode;

  /// Individual filter conditions that further restrict the query.
  final List<ReportsFilterCondition> filters;
}

/// How multiple filter conditions are combined.
enum ReportsFilterMatchMode {
  /// All conditions must be satisfied.
  all,

  /// At least one condition must be satisfied.
  any,
}

/// Type of value associated with a filter (text, number, time or boolean).
enum ReportsFilterValueType {
  /// Free‑form text value.
  text,

  /// Numeric value.
  number,

  /// Duration or time value.
  time,

  /// Boolean value.
  boolean,
}

/// Fields that a report filter can target.
enum ReportsFilterField {
  /// Departure aerodrome ICAO.
  departureIcao,

  /// Departure aerodrome IATA.
  departureIata,

  /// Departure aerodrome name.
  departureName,

  /// Departure city name.
  departureCity,

  /// Departure country name.
  departureCountry,

  /// Arrival aerodrome ICAO.
  arrivalIcao,

  /// Arrival aerodrome IATA.
  arrivalIata,

  /// Arrival aerodrome name.
  arrivalName,

  /// Arrival city name.
  arrivalCity,

  /// Arrival country name.
  arrivalCountry,

  /// Aircraft registration/tail number.
  aircraftTail,

  /// Aircraft type short code.
  aircraftTypeCode,

  /// Aircraft type family/group.
  aircraftTypeFamily,

  /// Full aircraft type name.
  aircraftTypeName,

  /// Approach type string.
  approachType,

  /// Remarks text.
  remarks,

  /// Private notes text.
  notes,

  /// Block time.
  blockTime,

  /// Airborne flight time.
  flightTime,

  /// Total time (e.g. block).
  totalTime,

  /// Night time.
  nightTime,

  /// IFR time.
  ifrTime,

  /// Instrument time.
  instrumentTime,

  /// Simulated instrument time.
  simulatedInstrumentTime,

  /// PIC time.
  picTime,

  /// PICUS time.
  picusTime,

  /// SIC time.
  sicTime,

  /// Dual instruction time.
  dualTime,

  /// Instructor time.
  instructorTime,

  /// Cross‑country time.
  crossCountryTime,

  /// Custom time field 1.
  custom1Time,

  /// Custom time field 2.
  custom2Time,

  /// Custom time field 3.
  custom3Time,

  /// Custom time field 4.
  custom4Time,

  /// Distance flown in nautical miles.
  distanceNm,

  /// Total takeoffs.
  takeoffs,

  /// Day takeoffs.
  takeoffsDay,

  /// Night takeoffs.
  takeoffsNight,

  /// Total landings.
  landings,

  /// Day landings.
  landingsDay,

  /// Night landings.
  landingsNight,

  /// Number of IFR approaches.
  ifrApproaches,

  /// Whether the aircraft type is multi‑pilot.
  isMultiPilot,

  /// Whether the operation is a simulator event.
  isSimulator,
}

/// Operators that can be applied to filter values.
enum ReportsFilterOperator {
  /// Text contains the value.
  contains,

  /// Text does not contain the value.
  doesNotContain,

  /// Text starts with the value.
  startsWith,

  /// Text does not start with the value.
  doesNotStartWith,

  /// Text ends with the value.
  endsWith,

  /// Text does not end with the value.
  doesNotEndWith,

  /// Text is exactly equal to the value.
  isExactly,

  /// Text is not equal to the value.
  isNot,

  /// Numeric value is greater than the filter value.
  greaterThan,

  /// Numeric value is less than the filter value.
  lessThan,

  /// Numeric value is equal to the filter value.
  equals,

  /// Boolean value must be true.
  isTrue,

  /// Boolean value must be false.
  isFalse,
}

/// Convenience helpers for [ReportsFilterField].
extension ReportsFilterFieldMeta on ReportsFilterField {
  /// Returns the [ReportsFilterValueType] associated with this field.
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

  /// Human‑readable label used in the UI for this field.
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

/// Supported operators for each [ReportsFilterValueType].
extension ReportsFilterOperators on ReportsFilterValueType {
  /// List of operators that make sense for this value type.
  List<ReportsFilterOperator> get supportedOperators {
    switch (this) {
      case ReportsFilterValueType.text:
        return const [
          ReportsFilterOperator.contains,
          ReportsFilterOperator.doesNotContain,
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

/// Human‑readable labels for [ReportsFilterOperator].
extension ReportsFilterOperatorLabel on ReportsFilterOperator {
  /// Label shown in the UI for the operator.
  String get label {
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
        return 'Is False';
    }
  }
}

/// Single condition used when filtering reports.
class ReportsFilterCondition {
  /// Creates a new filter on [field] with the given [operator] and value.
  const ReportsFilterCondition({
    /// Field being filtered.
    required this.field,

    /// Operator used to compare the value.
    required this.operator,

    /// Optional text value (for text fields).
    this.textValue,

    /// Optional numeric value (for numeric/time fields).
    this.numberValue,
  });

  /// Target field for this condition.
  final ReportsFilterField field;

  /// Comparison operator for the condition.
  final ReportsFilterOperator operator;

  /// Text value to compare against when [field] is text‑like.
  final String? textValue;

  /// Numeric value to compare against when [field] is numeric or time‑like.
  final int? numberValue;

  /// Returns the best display string for the current value.
  String get displayValue {
    final text = textValue?.trim() ?? '';
    if (text.isNotEmpty) return text;
    if (numberValue != null) return numberValue.toString();
    return '';
  }
}

/// Aggregate totals over a set of report rows.
class ReportsTotals {
  /// Creates a totals object with explicit values for each metric.
  const ReportsTotals({
    required this.sectors,
    required this.takeoffsDay,
    required this.takeoffsNight,
    required this.landingsDay,
    required this.landingsNight,
    required this.ifrApproaches,
    required this.distanceNM,
    required this.totalMinutes,
    required this.flightMinutes,
    required this.nightMinutes,
    required this.ifrMinutes,
    required this.instrumentMinutes,
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

  /// All‑zero totals.
  const ReportsTotals.zero()
    : sectors = 0,
      takeoffsDay = 0,
      takeoffsNight = 0,
      landingsDay = 0,
      landingsNight = 0,
      ifrApproaches = 0,
      distanceNM = 0,
      totalMinutes = 0,
      flightMinutes = 0,
      nightMinutes = 0,
      ifrMinutes = 0,
      instrumentMinutes = 0,
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

  /// Number of sectors in the result.
  final int sectors;

  /// Day takeoffs.
  final int takeoffsDay;

  /// Night takeoffs.
  final int takeoffsNight;

  /// Day landings.
  final int landingsDay;

  /// Night landings.
  final int landingsNight;

  /// IFR approaches.
  final int ifrApproaches;

  /// Distance flown in nautical miles.
  final int distanceNM;

  /// Total block or flight minutes.
  final int totalMinutes;

  /// Flight minutes.
  final int flightMinutes;

  /// Night minutes.
  final int nightMinutes;

  /// IFR minutes.
  final int ifrMinutes;

  /// Instrument minutes.
  final int instrumentMinutes;

  /// Simulated instrument minutes.
  final int simulatedInstrumentMinutes;

  /// PIC minutes.
  final int picMinutes;

  /// PICUS minutes.
  final int picusMinutes;

  /// SIC minutes.
  final int sicMinutes;

  /// Dual instruction minutes.
  final int dualMinutes;

  /// Instructor minutes.
  final int instructorMinutes;

  /// Cross‑country minutes.
  final int crossCountryMinutes;

  /// Simulator minutes.
  final int simulatorMinutes;

  /// Duty minutes.
  final int dutyMinutes;

  /// Custom time field 1 minutes.
  final int custom1Minutes;

  /// Custom time field 2 minutes.
  final int custom2Minutes;

  /// Custom time field 3 minutes.
  final int custom3Minutes;

  /// Custom time field 4 minutes.
  final int custom4Minutes;

  /// Multi‑pilot time minutes.
  final int multiPilotMinutes;

  /// Adds [other] to this totals object and returns the sum.
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
      flightMinutes: flightMinutes + other.flightMinutes,
      nightMinutes: nightMinutes + other.nightMinutes,
      ifrMinutes: ifrMinutes + other.ifrMinutes,
      instrumentMinutes: instrumentMinutes + other.instrumentMinutes,
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

/// Flattened row used when exporting or summarizing individual flights.
class ReportsFlightRow {
  /// Creates a new summary row for a single flight.
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

  /// Identifier of the flight.
  final int flightId;

  /// Departure date/time in UTC.
  final DateTime departureDateTime;

  /// Aircraft registration/tail.
  final String registration;

  /// Aircraft model code.
  final String modelCode;

  /// Aircraft model family.
  final String modelFamily;

  /// Departure aerodrome ICAO.
  final String fromIcao;

  /// Arrival aerodrome ICAO.
  final String toIcao;

  /// Human‑readable list of crew names.
  final String pilotNames;

  /// Departure latitude, if known.
  final double? fromLatitude;

  /// Departure longitude, if known.
  final double? fromLongitude;

  /// Arrival latitude, if known.
  final double? toLatitude;

  /// Arrival longitude, if known.
  final double? toLongitude;

  /// Total minutes credited for the flight.
  final int totalMinutes;

  /// PIC minutes.
  final int picMinutes;

  /// PICUS minutes.
  final int picusMinutes;

  /// SIC minutes.
  final int sicMinutes;

  /// Dual instruction minutes.
  final int dualMinutes;

  /// IFR minutes.
  final int ifrMinutes;

  /// Instrument minutes.
  final int instrumentMinutes;

  /// Night minutes.
  final int nightMinutes;

  /// Total takeoffs for the flight.
  final int takeoffs;

  /// Total landings for the flight.
  final int landings;
}

/// Single airport point used by map visualizations.
class ReportsMapAirportPoint {
  /// Creates one airport map point.
  const ReportsMapAirportPoint({
    required this.airportId,
    required this.icao,
    required this.latitude,
    required this.longitude,
  });

  /// Internal airport id.
  final int airportId;

  /// ICAO code shown on map.
  final String icao;

  /// Latitude in decimal degrees.
  final double latitude;

  /// Longitude in decimal degrees.
  final double longitude;
}

/// Aggregated bidirectional route used by map visualizations.
class ReportsMapRoute {
  /// Creates one route aggregate row.
  const ReportsMapRoute({
    required this.airportAId,
    required this.airportBId,
    required this.airportAIcao,
    required this.airportBIcao,
    required this.airportALatitude,
    required this.airportALongitude,
    required this.airportBLatitude,
    required this.airportBLongitude,
    required this.flightsTotal,
    required this.flightsAToB,
    required this.flightsBToA,
  });

  /// First airport id in normalized pair.
  final int airportAId;

  /// Second airport id in normalized pair.
  final int airportBId;

  /// First airport ICAO in normalized pair.
  final String airportAIcao;

  /// Second airport ICAO in normalized pair.
  final String airportBIcao;

  /// First airport latitude.
  final double airportALatitude;

  /// First airport longitude.
  final double airportALongitude;

  /// Second airport latitude.
  final double airportBLatitude;

  /// Second airport longitude.
  final double airportBLongitude;

  /// Number of flights in both directions combined.
  final int flightsTotal;

  /// Number of flights from A to B.
  final int flightsAToB;

  /// Number of flights from B to A.
  final int flightsBToA;
}

/// Aggregated map payload with unique airports and route pairs.
class ReportsMapData {
  /// Creates map payload.
  const ReportsMapData({
    required this.airports,
    required this.routes,
  });

  /// Unique airport points used for markers.
  final List<ReportsMapAirportPoint> airports;

  /// Unique bidirectional routes used for lines.
  final List<ReportsMapRoute> routes;
}

/// Aggregated row representing previous experience totals per model.
class ReportsPreviousExperienceRow {
  /// Creates a row of previous experience for a given model.
  const ReportsPreviousExperienceRow({
    required this.modelCode,
    required this.modelFamily,
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
    required this.operations,
    required this.firstFlightUtc,
    required this.lastFlightUtc,
  });

  /// Aircraft model code.
  final String modelCode;

  /// Aircraft model family.
  final String modelFamily;

  /// Total minutes flown.
  final int totalMinutes;

  /// PIC minutes.
  final int picMinutes;

  /// PICUS minutes.
  final int picusMinutes;

  /// SIC minutes.
  final int sicMinutes;

  /// Dual instruction minutes.
  final int dualMinutes;

  /// IFR minutes.
  final int ifrMinutes;

  /// Instrument minutes.
  final int instrumentMinutes;

  /// Night minutes.
  final int nightMinutes;

  /// Total takeoffs.
  final int takeoffs;

  /// Total landings.
  final int landings;

  /// Number of operations (flights).
  final int operations;

  /// UTC timestamp of the first flight in the history, if known.
  final DateTime? firstFlightUtc;

  /// UTC timestamp of the most recent flight in the history, if known.
  final DateTime? lastFlightUtc;
}

/// Grouping modes for SQL-backed analysis aggregation.
enum ReportsAnalysisGroupBy {
  /// Group by aircraft registration.
  aircraft,

  /// Group by aircraft type code.
  type,

  /// Group by aircraft family.
  family,

  /// Group by airport ICAO.
  airport,

  /// Group by departure year.
  year,

  /// Group by departure month (YYYY-MM).
  month,
}

/// Aggregated analysis totals for a single group key.
class ReportsAnalysisAggregateRow {
  /// Creates a grouped analysis row.
  const ReportsAnalysisAggregateRow({
    required this.groupKey,
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
    required this.operations,
    required this.firstFlightUtc,
    required this.lastFlightUtc,
  });

  /// Group identifier shown as title in Analyses.
  final String groupKey;

  /// Total block minutes.
  final int totalMinutes;

  /// PIC minutes.
  final int picMinutes;

  /// PICUS minutes.
  final int picusMinutes;

  /// SIC minutes.
  final int sicMinutes;

  /// Dual minutes.
  final int dualMinutes;

  /// IFR minutes.
  final int ifrMinutes;

  /// Instrument minutes (actual + simulated).
  final int instrumentMinutes;

  /// Night minutes.
  final int nightMinutes;

  /// Total takeoffs in bucket.
  final int takeoffs;

  /// Total landings in bucket.
  final int landings;

  /// Number of operations in bucket.
  final int operations;

  /// First flight UTC in bucket.
  final DateTime? firstFlightUtc;

  /// Last flight UTC in bucket.
  final DateTime? lastFlightUtc;
}

/// Container for report totals and the underlying flight rows.
class ReportsData {
  /// Creates a bundle of [totals] and [flights].
  const ReportsData({required this.totals, required this.flights});

  /// Aggregate totals over all [flights].
  final ReportsTotals totals;

  /// Individual flight rows included in the report.
  final List<ReportsFlightRow> flights;
}
