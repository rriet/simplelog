/// Aggregate statistics returned after running an import.
class SimpleLogImportResult {
  /// Creates a result describing how many items were imported or skipped.
  const SimpleLogImportResult({
    required this.totalRows,
    required this.flights,
    required this.positionings,
    required this.simulators,
    required this.airports,
    required this.aircraftTypes,
    required this.aircrafts,
    required this.crew,
    required this.skipped,
    required this.errors,
  });

  /// Number of data rows processed in the input file.
  final int totalRows;

  /// Number of flights successfully imported.
  final int flights;

  /// Number of positioning legs successfully imported.
  final int positionings;

  /// Number of simulator sessions successfully imported.
  final int simulators;

  /// Number of new or updated airports.
  final int airports;

  /// Number of new or updated aircraft types.
  final int aircraftTypes;

  /// Number of new or updated aircraft.
  final int aircrafts;

  /// Number of new or updated crew records.
  final int crew;

  /// Rows that were skipped due to missing or invalid data.
  final int skipped;

  /// Rows that failed with an error.
  final int errors;
}

/// Callback used to report import progress to the UI.
typedef ImportProgressCallback = void Function(int processed, int total);
