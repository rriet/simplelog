import 'package:simplelog/data/database/app_database.dart';

/// Visual state for a dashboard limit card.
enum LimitCardStatus {
  /// Limit is comfortably within threshold.
  green,

  /// Limit is approaching threshold.
  yellow,

  /// Limit has reached/violated threshold.
  red,
}

/// Summary data rendered in a single dashboard limit card.
class DashboardRuleCard {
  /// Creates a dashboard card model.
  const DashboardRuleCard({
    required this.rule,
    required this.currentValue,
    required this.limitValue,
    required this.remainingValue,
    required this.windowStart,
    required this.windowEnd,
    required this.status,
  });

  /// Backing rule definition.
  final LimitRule rule;

  /// Current metric value in rule units.
  final double currentValue;

  /// Rule limit value in rule units.
  final double limitValue;

  /// Remaining value before hitting limit.
  final double remainingValue;

  /// Start of the evaluation window (UTC).
  final DateTime windowStart;

  /// End of the evaluation window (UTC).
  final DateTime windowEnd;

  /// Computed card status used for color/alerts.
  final LimitCardStatus status;
}

/// Expanded totals for one dashboard rule window.
class DashboardRuleDetails {
  /// Creates details for a selected dashboard rule.
  const DashboardRuleDetails({
    required this.windowStart,
    required this.windowEnd,
    required this.totals,
  });

  /// Start of the analyzed window (UTC).
  final DateTime windowStart;

  /// End of the analyzed window (UTC).
  final DateTime windowEnd;

  /// Aggregated totals inside the window.
  final DashboardTotals totals;
}

/// Time/count aggregates used by dashboard details.
class DashboardTotals {
  /// Creates a totals value object.
  const DashboardTotals({
    required this.flightsCount,
    required this.blockMinutes,
    required this.flightMinutes,
    required this.nightMinutes,
    required this.ifrMinutes,
    required this.dutyMinutes,
    required this.landings,
  });

  /// Flights count.
  final int flightsCount;

  /// Block time in minutes.
  final int blockMinutes;

  /// Flight/airborne time in minutes.
  final int flightMinutes;

  /// Night time in minutes.
  final int nightMinutes;

  /// IFR time in minutes.
  final int ifrMinutes;

  /// Duty time in minutes.
  final int dutyMinutes;

  /// Landings count.
  final int landings;
}
