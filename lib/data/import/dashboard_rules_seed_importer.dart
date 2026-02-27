import 'package:drift/drift.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/user_settings_json.dart';

/// Seeds default dashboard limit rules the first time the app is opened.
///
/// Uses a user-settings flag to avoid reseeding after first successful insert.
class DashboardRulesSeedImporter {
  /// Creates the dashboard rules seeder.
  const DashboardRulesSeedImporter();

  /// Internal user-settings key used to track seeding completion.
  static const _prefsKey = 'dashboard_rules_seeded_v1';

  /// Clears the seeding flag so defaults can be inserted again.
  static Future<void> clearSeedFlag(AppDatabase db) async {
    await UserSettingsJsonStore(db).patch((json) => json.remove(_prefsKey));
  }

  /// Inserts default limit rules if not seeded yet and table is empty.
  ///
  /// Returns the number of inserted rules.
  Future<int> importOnFirstOpen(AppDatabase db) async {
    final store = UserSettingsJsonStore(db);
    final settings = await store.load();
    final alreadySeeded = settings[_prefsKey] == true;
    if (alreadySeeded) {
      return 0;
    }

    final countExpr = db.limitRules.ruleId.count();
    final query = db.selectOnly(db.limitRules)..addColumns([countExpr]);
    final row = await query.getSingle();
    final count = row.read(countExpr) ?? 0;
    if (count > 0) {
      await store.patch((json) => json[_prefsKey] = true);
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

    await store.patch((json) => json[_prefsKey] = true);
    return defaults.length;
  }
}
