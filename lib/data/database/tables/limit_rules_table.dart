import 'package:drift/drift.dart';

/// Public API documentation.
class LimitRules extends Table {
  /// Public API documentation.
  IntColumn get ruleId => integer().autoIncrement()();
  /// Public API documentation.
  TextColumn get ruleName => text()();
  /// Public API documentation.
  TextColumn get metric => text()();
  /// Public API documentation.
  TextColumn get ruleType => text()();
  /// Public API documentation.
  TextColumn get windowType => text()();
  /// Public API documentation.
  IntColumn get windowValue => integer()();
  /// Public API documentation.
  RealColumn get limitValue => real()();
  /// Public API documentation.
  TextColumn get limitUnit => text()();
  /// Public API documentation.
  RealColumn get warnYellowBefore => real().withDefault(const Constant(0))();
  /// Public API documentation.
  RealColumn get warnRedBefore => real().withDefault(const Constant(0))();
  /// Public API documentation.
  TextColumn get warnYellowColor =>
      text().withDefault(const Constant('#FFC107'))();
  /// Public API documentation.
  TextColumn get warnRedColor =>
      text().withDefault(const Constant('#DC3545'))();
  /// Public API documentation.
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  /// Public API documentation.
  TextColumn get notes => text().nullable()();
}
