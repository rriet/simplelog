/// Field associations used by Wader import issue resolution.
enum WaderFieldAssociation {
  /// Flight date.
  date,

  /// Start time.
  startTime,

  /// Parking/arrival time.
  parkingTime,

  /// Departure airport.
  departureAirport,

  /// Arrival airport.
  arrivalAirport,

  /// Aircraft registration.
  aircraftTail,

  /// Aircraft type code.
  aircraftType,

  /// Flight total time.
  totalTime,

  /// Simulator trainee time.
  simTraineeTime,

  /// Simulator trainer time.
  simTrainerTime,
}

/// Resolution for rows with missing/invalid total time while recalculation is off.
enum WaderTotalTimeResolution {
  /// No explicit action selected.
  none,

  /// Ignore the source line.
  ignoreLine,

  /// Keep CSV block value as entered by the user.
  useBlockValue,

  /// Calculate total using start and parking times.
  calculateFromChocks,
}

/// Row issue detected while validating a Wader CSV import.
class WaderImportIssue {
  /// Creates an import issue.
  const WaderImportIssue({
    required this.lineNumber,
    required this.association,
    required this.currentValue,
    required this.reason,
  });

  /// Source line number in the CSV file.
  final int lineNumber;

  /// Failing field association.
  final WaderFieldAssociation association;

  /// Current source value for this field.
  final String currentValue;

  /// Human-readable issue reason.
  final String reason;
}

/// Review overrides selected by user before importing Wader CSV.
class WaderImportReviewOptions {
  /// Creates review options.
  const WaderImportReviewOptions({
    this.valueOverrides = const <int, Map<WaderFieldAssociation, String>>{},
    this.ignoredLines = const <int>{},
    this.totalTimeResolutions = const <int, WaderTotalTimeResolution>{},
  });

  /// Per-line field value overrides.
  final Map<int, Map<WaderFieldAssociation, String>> valueOverrides;

  /// Source lines explicitly ignored by user.
  final Set<int> ignoredLines;

  /// Per-line resolution action for total-time issues.
  final Map<int, WaderTotalTimeResolution> totalTimeResolutions;

  /// Returns a copy with selected values replaced.
  WaderImportReviewOptions copyWith({
    Map<int, Map<WaderFieldAssociation, String>>? valueOverrides,
    Set<int>? ignoredLines,
    Map<int, WaderTotalTimeResolution>? totalTimeResolutions,
  }) {
    return WaderImportReviewOptions(
      valueOverrides: valueOverrides ?? this.valueOverrides,
      ignoredLines: ignoredLines ?? this.ignoredLines,
      totalTimeResolutions: totalTimeResolutions ?? this.totalTimeResolutions,
    );
  }
}
