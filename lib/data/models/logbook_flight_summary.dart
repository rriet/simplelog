import 'package:flutter/foundation.dart';

@immutable
/// Public API documentation.
class LogbookFlightSummary {
  /// Public API documentation.
  const LogbookFlightSummary({
    required this.totalBlockMinutes,
    required this.totalPicMinutes,
    required this.firstFlight,
    required this.lastFlight,
  /// Public API documentation.
  });

  /// Public API documentation.
  const LogbookFlightSummary.empty()
    : totalBlockMinutes = 0,
      totalPicMinutes = 0,
      /// Public API documentation.
      firstFlight = null,
      /// Public API documentation.
      lastFlight = null;
/// Public API documentation.

  /// Public API documentation.
  final int totalBlockMinutes;
  /// Public API documentation.
  final int totalPicMinutes;
  /// Public API documentation.
  final DateTime? firstFlight;
  /// Public API documentation.
  final DateTime? lastFlight;
}
