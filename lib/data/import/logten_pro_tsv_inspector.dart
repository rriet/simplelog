/// Flattened metadata extracted from a LogTen Pro tab-separated export.
class LogTenProTsvInspection {
  /// Creates an inspection result for a recognized export.
  const LogTenProTsvInspection({required this.columns});

  /// Header columns in file order.
  final List<String> columns;
}

/// Reads and validates the header row of a LogTen Pro tab-separated export.
class LogTenProTsvInspector {
  /// Creates a TSV inspector.
  const LogTenProTsvInspector();

  /// Returns inspection metadata when [content] matches a LogTen Pro export.
  ///
  /// Returns `null` when the file does not match the expected header pattern.
  LogTenProTsvInspection? inspect(String content) {
    final lines = content
        .split(RegExp(r'\r\n|\n|\r'))
        .where((line) => line.trim().isNotEmpty)
        .toList(growable: false);
    if (lines.isEmpty) return null;
    final header = lines.first
        .split('\t')
        .map((value) => value.trim())
        .toList();
    if (!_matchesLogTenHeader(header)) {
      return null;
    }
    return LogTenProTsvInspection(columns: header);
  }

  bool _matchesLogTenHeader(List<String> columns) {
    const requiredColumns = <String>{
      'flight_flightDate',
      'flight_from',
      'flight_to',
      'flight_totalTime',
      'flight_remarks',
      'aircraft_aircraftID',
      'aircraftType_type',
      'aircraftType_model',
    };
    final available = columns.toSet();
    return requiredColumns.every(available.contains);
  }
}
