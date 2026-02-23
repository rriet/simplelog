import 'package:drift/drift.dart';

import 'package:simplelog/data/database/tables/limit_rules_table.dart';

/// Public API documentation.
class RuleSnapshots extends Table {
  /// Public API documentation.
  IntColumn get snapshotId => integer().autoIncrement()();
  /// Public API documentation.
  IntColumn get ruleId => integer().references(LimitRules, #ruleId)();
  /// Public API documentation.
  DateTimeColumn get computedAt => dateTime().withDefault(currentDateAndTime)();
  /// Public API documentation.
  RealColumn get currentValue => real()();
  /// Public API documentation.
  TextColumn get status => text()();
}
