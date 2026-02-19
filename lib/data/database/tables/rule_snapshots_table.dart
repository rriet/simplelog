import 'package:drift/drift.dart';

import 'limit_rules_table.dart';

class RuleSnapshots extends Table {
  IntColumn get snapshotId => integer().autoIncrement()();
  IntColumn get ruleId => integer().references(LimitRules, #ruleId)();
  DateTimeColumn get computedAt =>
      dateTime().withDefault(currentDateAndTime)();
  RealColumn get currentValue => real()();
  TextColumn get status => text()();
}
