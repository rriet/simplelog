import 'package:simplelog/data/database/app_database.dart';

enum LimitCardStatus { green, yellow, red }

class DashboardRuleCard {
  const DashboardRuleCard({
    required this.rule,
    required this.currentValue,
    required this.limitValue,
    required this.remainingValue,
    required this.windowStart,
    required this.windowEnd,
    required this.status,
  });

  final LimitRule rule;
  final double currentValue;
  final double limitValue;
  final double remainingValue;
  final DateTime windowStart;
  final DateTime windowEnd;
  final LimitCardStatus status;
}

class DashboardRuleDetails {
  const DashboardRuleDetails({
    required this.windowStart,
    required this.windowEnd,
    required this.totals,
  });

  final DateTime windowStart;
  final DateTime windowEnd;
  final DashboardTotals totals;
}

class DashboardTotals {
  const DashboardTotals({
    required this.flightsCount,
    required this.blockMinutes,
    required this.flightMinutes,
    required this.nightMinutes,
    required this.ifrMinutes,
    required this.instrumentMinutes,
    required this.dutyMinutes,
    required this.landings,
  });

  final int flightsCount;
  final int blockMinutes;
  final int flightMinutes;
  final int nightMinutes;
  final int ifrMinutes;
  final int instrumentMinutes;
  final int dutyMinutes;
  final int landings;
}
