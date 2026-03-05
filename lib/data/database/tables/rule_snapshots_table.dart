import 'package:drift/drift.dart';

import 'package:simplelog/data/database/tables/limit_rules_table.dart';

/// Stores precomputed snapshots of rule values and their evaluation status.
class RuleSnapshots extends Table {
  /// Primary key for a snapshot row.
  IntColumn get snapshotId => integer().autoIncrement()();

  /// Foreign key to the rule that produced this snapshot.
  IntColumn get ruleId => integer().references(
    LimitRules,
    #ruleId,
    onDelete: KeyAction.restrict,
    onUpdate: KeyAction.restrict,
  )();

  /// UTC timestamp when this snapshot was computed.
  DateTimeColumn get computedAt => dateTime().withDefault(currentDateAndTime)();

  /// Numeric value measured for the rule at [computedAt].
  RealColumn get currentValue => real()();

  /// Evaluation status persisted as text (for example pass or fail).
  TextColumn get status => text()();
}
