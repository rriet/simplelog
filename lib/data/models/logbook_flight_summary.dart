import 'package:flutter/foundation.dart';

@immutable
/// High‑level summary information about flights in the logbook.
class LogbookFlightSummary {
  /// Creates a summary for a set of flights.
  const LogbookFlightSummary({
    required this.totalBlockMinutes,
    required this.totalPicMinutes,
    required this.firstFlight,
    required this.lastFlight,
  });

  /// Empty summary used when there are no flights.
  const LogbookFlightSummary.empty()
    : totalBlockMinutes = 0,
      totalPicMinutes = 0,
      firstFlight = null,
      lastFlight = null;

  /// Total block time for all flights in minutes.
  final int totalBlockMinutes;

  /// Total PIC time for all flights in minutes.
  final int totalPicMinutes;

  /// Date of the first flight included in the summary, if any.
  final DateTime? firstFlight;

  /// Date of the last flight included in the summary, if any.
  final DateTime? lastFlight;
}
