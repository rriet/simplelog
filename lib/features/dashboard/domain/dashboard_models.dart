import 'package:simplelog/data/database/app_database.dart';

/// Public API documentation.
enum LimitCardStatus {
  /// Public API documentation.
  green,

  /// Public API documentation.
  yellow,

  /// Public API documentation.
  red,
}
/// Public API documentation.

/// Public API documentation.
class DashboardRuleCard {
  /// Public API documentation.
  const DashboardRuleCard({
    required this.rule,
    required this.currentValue,
    required this.limitValue,
    required this.remainingValue,
    required this.windowStart,
    required this.windowEnd,
    /// Public API documentation.
    required this.status,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final LimitRule rule;
  /// Public API documentation.
  final double currentValue;
  /// Public API documentation.
  final double limitValue;
  /// Public API documentation.
  final double remainingValue;
  /// Public API documentation.
  final DateTime windowStart;
  /// Public API documentation.
  final DateTime windowEnd;
  /// Public API documentation.
  final LimitCardStatus status;
/// Public API documentation.
}
/// Public API documentation.

/// Public API documentation.
class DashboardRuleDetails {
  /// Public API documentation.
  const DashboardRuleDetails({
    required this.windowStart,
    required this.windowEnd,
    required this.totals,
  });

  /// Public API documentation.
  final DateTime windowStart;
  /// Public API documentation.
  final DateTime windowEnd;
  /// Public API documentation.
  final DashboardTotals totals;
/// Public API documentation.
}
/// Public API documentation.

/// Public API documentation.
class DashboardTotals {
  /// Public API documentation.
  const DashboardTotals({
    /// Public API documentation.
    required this.flightsCount,
    required this.blockMinutes,
    required this.flightMinutes,
    required this.nightMinutes,
    required this.ifrMinutes,
    required this.instrumentMinutes,
    required this.dutyMinutes,
    required this.landings,
  });

  /// Public API documentation.
  final int flightsCount;
  /// Public API documentation.
  final int blockMinutes;
  /// Public API documentation.
  final int flightMinutes;
  /// Public API documentation.
  final int nightMinutes;
  /// Public API documentation.
  final int ifrMinutes;
  /// Public API documentation.
  final int instrumentMinutes;
  /// Public API documentation.
  final int dutyMinutes;
  /// Public API documentation.
  final int landings;
}
