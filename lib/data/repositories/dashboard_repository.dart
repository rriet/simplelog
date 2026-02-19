import 'package:drift/drift.dart';
import 'dart:math' as math;
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/features/dashboard/domain/dashboard_models.dart';

class DashboardRepository {
  DashboardRepository(this._db);

  final AppDatabase _db;
  String? _cachedFlightsIfrColumnName;

  Stream<List<LimitRule>> watchRules() {
    return (_db.select(_db.limitRules)
          ..orderBy([
            (t) => OrderingTerm.asc(t.ruleName),
          ]))
        .watch();
  }

  Future<int> createRule(LimitRulesCompanion companion) {
    return _db.into(_db.limitRules).insert(companion);
  }

  Future<void> updateRule(LimitRule rule) async {
    await _db.update(_db.limitRules).replace(rule);
  }

  Future<void> deleteRule(int ruleId) async {
    await (_db.delete(_db.limitRules)..where((t) => t.ruleId.equals(ruleId))).go();
  }

  Future<DashboardRuleDetails> loadRuleDetails(LimitRule rule) async {
    final now = DateTime.now();
    final window = _resolveWindow(now, rule.windowType, rule.windowValue);
    final start = Variable.withDateTime(window.$1);
    final end = Variable.withDateTime(window.$2);
    final vars = <Variable>[start, end];
    final ifrColumn = await _resolveFlightsIfrColumnName();

    final flightsTotalsRow = await _db.customSelect(
      '''
SELECT
  COUNT(*) AS flights_count,
  COALESCE(SUM(f.time_block_minutes), 0) AS block_minutes,
  COALESCE(SUM(f.time_flight_minutes), 0) AS flight_minutes,
  COALESCE(SUM(f.time_night_minutes), 0) AS night_minutes,
  COALESCE(SUM(f.$ifrColumn), 0) AS ifr_minutes,
  COALESCE(SUM(f.time_instrument_minutes + f.time_simulated_instrument_minutes), 0) AS instrument_minutes,
  COALESCE(SUM(f.landings_day + f.landings_night), 0) AS landings
FROM flights f
INNER JOIN time_lines tl ON tl.id = f.departure_date_time_id
WHERE tl.event_date_time >= ? AND tl.event_date_time <= ?
''',
      variables: vars,
      readsFrom: {_db.flights, _db.timeLines},
    ).getSingle();

    final dutyTotalsRow = await _db.customSelect(
      '''
SELECT COALESCE(SUM(d.time_duty_minutes), 0) AS duty_minutes
FROM duty_periods d
INNER JOIN time_lines tl ON tl.id = d.duty_start_time_line_id
WHERE tl.event_date_time >= ? AND tl.event_date_time <= ?
''',
      variables: vars,
      readsFrom: {_db.dutyPeriods, _db.timeLines},
    ).getSingle();

    return DashboardRuleDetails(
      windowStart: window.$1,
      windowEnd: window.$2,
      totals: DashboardTotals(
        flightsCount: _readInteger(flightsTotalsRow, 'flights_count'),
        blockMinutes: _readInteger(flightsTotalsRow, 'block_minutes'),
        flightMinutes: _readInteger(flightsTotalsRow, 'flight_minutes'),
        nightMinutes: _readInteger(flightsTotalsRow, 'night_minutes'),
        ifrMinutes: _readInteger(flightsTotalsRow, 'ifr_minutes'),
        instrumentMinutes: _readInteger(flightsTotalsRow, 'instrument_minutes'),
        dutyMinutes: _readInteger(dutyTotalsRow, 'duty_minutes'),
        landings: _readInteger(flightsTotalsRow, 'landings'),
      ),
    );
  }

  Stream<List<DashboardRuleCard>> watchDashboardCards() {
    return _db
        .customSelect(
          'SELECT 1',
          readsFrom: {
            _db.limitRules,
            _db.flights,
            _db.dutyPeriods,
            _db.timeLines,
          },
        )
        .watch()
        .asyncMap((_) => _computeCards());
  }

  Future<List<DashboardRuleCard>> _computeCards() async {
    final rulesQuery = _db.select(_db.limitRules)
      ..where((t) => t.active.equals(true));
    rulesQuery.orderBy([(t) => OrderingTerm.asc(t.ruleName)]);

    final rules = await rulesQuery.get();
    if (rules.isEmpty) return const [];

    final now = DateTime.now();
    final cards = <DashboardRuleCard>[];
    for (final rule in rules) {
      final window = _resolveWindow(now, rule.windowType, rule.windowValue);
      final current = await _metricValue(
        rule: rule,
        windowStart: window.$1,
        windowEnd: window.$2,
      );
      final status = _statusFor(rule, current);
      cards.add(
        DashboardRuleCard(
          rule: rule,
          currentValue: current,
          limitValue: rule.limitValue,
          remainingValue: rule.ruleType == 'maximum'
              ? (rule.limitValue - current)
              : (current - rule.limitValue),
          windowStart: window.$1,
          windowEnd: window.$2,
          status: status,
        ),
      );
    }
    return cards;
  }

  Future<double> _metricValue({
    required LimitRule rule,
    required DateTime windowStart,
    required DateTime windowEnd,
  }) async {
    final start = Variable.withDateTime(windowStart);
    final end = Variable.withDateTime(windowEnd);
    final vars = <Variable>[start, end];

    final metric = rule.metric.toLowerCase();
    if (metric == 'duty' || metric == 'duty_time') {
      final row = await _db.customSelect(
        '''
SELECT COALESCE(SUM(d.time_duty_minutes), 0) AS value
FROM duty_periods d
INNER JOIN time_lines tl ON tl.id = d.duty_start_time_line_id
WHERE tl.event_date_time >= ? AND tl.event_date_time <= ?
''',
        variables: vars,
        readsFrom: {_db.dutyPeriods, _db.timeLines},
      ).getSingle();
      final value = _readNumeric(row, 'value');
      return _convertByUnit(value, rule.limitUnit);
    }

    if (metric == 'ifr') {
      final ifrColumn = await _resolveFlightsIfrColumnName();
      final row = await _db.customSelect(
        '''
SELECT COALESCE(SUM(f.$ifrColumn), 0) AS value
FROM flights f
INNER JOIN time_lines tl ON tl.id = f.departure_date_time_id
WHERE tl.event_date_time >= ? AND tl.event_date_time <= ?
''',
        variables: vars,
        readsFrom: {_db.flights, _db.timeLines},
      ).getSingle();
      final value = _readNumeric(row, 'value');
      return _convertByUnit(value, rule.limitUnit);
    }

    final field = _flightMetricExpression(metric);
    if (field != null) {
      final row = await _db.customSelect(
        '''
SELECT COALESCE(SUM($field), 0) AS value
FROM flights f
INNER JOIN time_lines tl ON tl.id = f.departure_date_time_id
WHERE tl.event_date_time >= ? AND tl.event_date_time <= ?
''',
        variables: vars,
        readsFrom: {_db.flights, _db.timeLines},
      ).getSingle();
      final value = _readNumeric(row, 'value');
      return _convertByUnit(value, rule.limitUnit);
    }

    return 0;
  }

  String? _flightMetricExpression(String metric) {
    return switch (metric) {
      'block' || 'block_time' => 'f.time_block_minutes',
      'flight' || 'flight_time' => 'f.time_flight_minutes',
      'night' || 'night_time' => 'f.time_night_minutes',
      'instrument' || 'time_instrument' =>
        '(f.time_instrument_minutes + f.time_simulated_instrument_minutes)',
      'pic' || 'pic_time' => 'f.time_pic_minutes',
      'picus' || 'picus_time' => 'f.time_picus_minutes',
      'sic' || 'sic_time' => 'f.time_sic_minutes',
      'dual' || 'dual_time' => 'f.time_dual_minutes',
      'instructor' || 'instructor_time' => 'f.time_instructor_minutes',
      'cross_country' || 'crosscountry' => 'f.time_cross_country_minutes',
      'takeoff' || 'takeoffs' => '(f.take_offs_days + f.take_offs_night)',
      'takeoff_day' || 'takeoffs_day' => 'f.take_offs_days',
      'takeoff_night' || 'takeoffs_night' => 'f.take_offs_night',
      'landing' || 'landings' => '(f.landings_day + f.landings_night)',
      'landing_day' || 'landings_day' => 'f.landings_day',
      'landing_night' || 'landings_night' => 'f.landings_night',
      'instrument_approaches' || 'ifr_approaches' => 'f.ifr_approaches',
      _ => null,
    };
  }

  (DateTime, DateTime) _resolveWindow(DateTime now, String type, int value) {
    final parsed = _parseWindowType(type);
    final cleanType = parsed.$1;
    final reference = parsed.$2;
    final v = value <= 0 ? 1 : value;
    final endOfToday = DateTime(now.year, now.month, now.day + 1).subtract(
      const Duration(milliseconds: 1),
    );
    final anchor = switch (reference) {
      'same_time' => now,
      'midnight_local' => DateTime(now.year, now.month, now.day),
      'midnight_utc' => DateTime.utc(
          now.toUtc().year,
          now.toUtc().month,
          now.toUtc().day,
        ),
      _ => now,
    };

    switch (cleanType) {
      case 'hours':
        return (anchor.subtract(Duration(hours: v)), anchor);
      case 'days':
      case 'rolling_days':
      case 'consecutive_days':
        return (anchor.subtract(Duration(days: v)), anchor);
      case 'weeks':
        return (anchor.subtract(Duration(days: v * 7)), anchor);
      case 'months':
        return (_subtractMonths(anchor, v), anchor);
      case 'years':
        return (_subtractYears(anchor, v), anchor);
      case 'calendar_day':
      case 'calendar_days':
        return (
          DateTime(now.year, now.month, now.day).subtract(
            Duration(days: v - 1),
          ),
          endOfToday,
        );
      case 'calendar_month':
      case 'calendar_months':
        return (
          DateTime(now.year, now.month - (v - 1), 1),
          DateTime(now.year, now.month + 1, 1).subtract(
            const Duration(milliseconds: 1),
          ),
        );
      case 'calendar_year':
      case 'calendar_years':
        return (
          DateTime(now.year - (v - 1), 1, 1),
          DateTime(now.year + 1, 1, 1).subtract(
            const Duration(milliseconds: 1),
          ),
        );
      case 'calendar_quarter':
        final quarterStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        final quarterStart = DateTime(now.year, quarterStartMonth, 1);
        return (
          DateTime(
            quarterStart.year,
            quarterStart.month - (3 * (v - 1)),
            1,
          ),
          DateTime(now.year, quarterStartMonth + 3, 1).subtract(
            const Duration(milliseconds: 1),
          ),
        );
      default:
        return (anchor.subtract(Duration(days: v)), anchor);
    }
  }

  LimitCardStatus _statusFor(LimitRule rule, double currentValue) {
    final limit = rule.limitValue;
    final yellowBefore = rule.warnYellowBefore;
    final redBefore = rule.warnRedBefore;
    final maxRule = rule.ruleType.toLowerCase() == 'maximum';

    if (maxRule) {
      final remaining = limit - currentValue;
      if (remaining <= redBefore) return LimitCardStatus.red;
      if (remaining <= yellowBefore) return LimitCardStatus.yellow;
      return LimitCardStatus.green;
    }

    if (currentValue >= limit) return LimitCardStatus.green;
    final missing = limit - currentValue;
    if (missing <= redBefore) return LimitCardStatus.red;
    if (missing <= yellowBefore) return LimitCardStatus.yellow;
    return LimitCardStatus.red;
  }

  double _convertByUnit(double rawMinutes, String unit) {
    final normalized = unit.toLowerCase();
    if (normalized == 'hours') return rawMinutes / 60.0;
    if (normalized == 'days') return rawMinutes / (60.0 * 24.0);
    return rawMinutes;
  }

  double _readNumeric(QueryRow row, String columnName) {
    final dynamicValue = row.data[columnName];
    if (dynamicValue is num) return dynamicValue.toDouble();
    if (dynamicValue is String) {
      final parsed = double.tryParse(dynamicValue);
      if (parsed != null) return parsed;
    }
    return 0;
  }

  int _readInteger(QueryRow row, String columnName) {
    return _readNumeric(row, columnName).round();
  }

  String _readString(QueryRow row, String columnName) {
    final dynamicValue = row.data[columnName];
    if (dynamicValue == null) return '';
    return dynamicValue.toString();
  }

  Future<String> _resolveFlightsIfrColumnName() async {
    final cached = _cachedFlightsIfrColumnName;
    if (cached != null) return cached;

    final rows = await _db.customSelect('PRAGMA table_info(flights);').get();
    final names = rows
        .map((row) => _readString(row, 'name').toLowerCase())
        .toSet();
    if (names.contains('time_i_f_r_minutes')) {
      _cachedFlightsIfrColumnName = 'time_i_f_r_minutes';
      return _cachedFlightsIfrColumnName!;
    }
    if (names.contains('time_ifr_minutes')) {
      _cachedFlightsIfrColumnName = 'time_ifr_minutes';
      return _cachedFlightsIfrColumnName!;
    }

    _cachedFlightsIfrColumnName = 'time_i_f_r_minutes';
    return _cachedFlightsIfrColumnName!;
  }

  (String, String) _parseWindowType(String raw) {
    final clean = raw.trim().toLowerCase();
    if (clean.contains('|')) {
      final parts = clean.split('|');
      if (parts.length == 2) {
        return (parts[0], parts[1]);
      }
    }
    return (clean, 'same_time');
  }

  DateTime _subtractMonths(DateTime value, int months) {
    final totalMonths = value.year * 12 + (value.month - 1) - months;
    final targetYear = totalMonths ~/ 12;
    final targetMonth = (totalMonths % 12) + 1;
    final targetDay = math.min(value.day, _daysInMonth(targetYear, targetMonth));
    if (value.isUtc) {
      return DateTime.utc(
        targetYear,
        targetMonth,
        targetDay,
        value.hour,
        value.minute,
        value.second,
        value.millisecond,
        value.microsecond,
      );
    }
    return DateTime(
      targetYear,
      targetMonth,
      targetDay,
      value.hour,
      value.minute,
      value.second,
      value.millisecond,
      value.microsecond,
    );
  }

  DateTime _subtractYears(DateTime value, int years) {
    final targetYear = value.year - years;
    final targetDay = math.min(value.day, _daysInMonth(targetYear, value.month));
    if (value.isUtc) {
      return DateTime.utc(
        targetYear,
        value.month,
        targetDay,
        value.hour,
        value.minute,
        value.second,
        value.millisecond,
        value.microsecond,
      );
    }
    return DateTime(
      targetYear,
      value.month,
      targetDay,
      value.hour,
      value.minute,
      value.second,
      value.millisecond,
      value.microsecond,
    );
  }

  int _daysInMonth(int year, int month) {
    final firstDayThisMonth = DateTime(year, month, 1);
    final firstDayNextMonth = DateTime(firstDayThisMonth.year, firstDayThisMonth.month + 1, 1);
    return firstDayNextMonth.subtract(const Duration(days: 1)).day;
  }
}
