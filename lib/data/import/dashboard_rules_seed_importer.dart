import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplelog/data/database/app_database.dart';

/// Public API documentation.
class DashboardRulesSeedImporter {
  /// Public API documentation.
  const DashboardRulesSeedImporter();

  /// Public API documentation.
  static const _prefsKey = 'dashboard_rules_seeded_v1';

  /// Public API documentation.
  static Future<void> clearSeedFlag() async {
    final prefs = await SharedPreferences.getInstance();
    /// Public API documentation.
    await prefs.remove(_prefsKey);
  }

  /// Public API documentation.
  Future<int> importOnFirstOpen(AppDatabase db) async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySeeded = prefs.getBool(_prefsKey) ?? false;
    if (alreadySeeded) {
      return 0;
    }

    final countExpr = db.limitRules.ruleId.count();
    final query = db.selectOnly(db.limitRules)..addColumns([countExpr]);
    final row = await query.getSingle();
    final count = row.read(countExpr) ?? 0;
    if (count > 0) {
      await prefs.setBool(_prefsKey, true);
      return 0;
    }

    final defaults = <LimitRulesCompanion>[
      // FAA Part 121 style limits (editable by user in Dashboard Setup)
      LimitRulesCompanion.insert(
        ruleName: 'FAA 121 Max Block (365 days)',
        metric: 'block',
        ruleType: 'maximum',
        windowType: 'days|same_time',
        windowValue: 365,
        limitValue: 1000,
        limitUnit: 'hours',
        warnYellowBefore: const Value(100),
        warnRedBefore: const Value(25),
      ),
      LimitRulesCompanion.insert(
        ruleName: 'FAA 121 Max Block (28 days)',
        metric: 'block',
        ruleType: 'maximum',
        windowType: 'days|same_time',
        windowValue: 28,
        limitValue: 100,
        limitUnit: 'hours',
        warnYellowBefore: const Value(10),
        warnRedBefore: const Value(3),
      ),
      LimitRulesCompanion.insert(
        ruleName: 'FAA 121 Max Block (7 days)',
        metric: 'block',
        ruleType: 'maximum',
        windowType: 'days|same_time',
        windowValue: 7,
        limitValue: 30,
        limitUnit: 'hours',
        warnYellowBefore: const Value(4),
        warnRedBefore: const Value(1.5),
      ),
      // Common currency defaults
      LimitRulesCompanion.insert(
        ruleName: 'Currency Min Block (90 days)',
        metric: 'block',
        ruleType: 'minimum',
        windowType: 'days|same_time',
        windowValue: 90,
        limitValue: 60,
        limitUnit: 'hours',
        warnYellowBefore: const Value(10),
        warnRedBefore: const Value(0),
      ),
      LimitRulesCompanion.insert(
        ruleName: 'Currency Min Landings (90 days)',
        metric: 'landings',
        ruleType: 'minimum',
        windowType: 'days|same_time',
        windowValue: 90,
        limitValue: 3,
        limitUnit: 'count',
        warnYellowBefore: const Value(1),
        warnRedBefore: const Value(0),
      ),
      LimitRulesCompanion.insert(
        ruleName: 'Currency Min Instrument Approaches (180 days)',
        metric: 'instrument_approaches',
        ruleType: 'minimum',
        windowType: 'days|same_time',
        windowValue: 180,
        limitValue: 6,
        limitUnit: 'count',
        warnYellowBefore: const Value(2),
        warnRedBefore: const Value(0),
      ),
    ];

    await db.batch((batch) {
      batch.insertAll(db.limitRules, defaults, mode: InsertMode.insertOrAbort);
    });

    await prefs.setBool(_prefsKey, true);
    return defaults.length;
  }
}
