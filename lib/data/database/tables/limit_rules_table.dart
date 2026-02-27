import 'package:drift/drift.dart';

/// Dashboard/limits rule definitions.
class LimitRules extends Table {
  /// Surrogate primary key.
  IntColumn get ruleId => integer().autoIncrement()();
  /// User-facing rule name.
  TextColumn get ruleName => text()();
  /// Metric key (e.g. block, landings).
  TextColumn get metric => text()();
  /// Rule semantics (`minimum` or `maximum`).
  TextColumn get ruleType => text()();
  /// Window calculation mode descriptor.
  TextColumn get windowType => text()();
  /// Window size in units implied by [windowType].
  IntColumn get windowValue => integer()();
  /// Threshold value in [limitUnit].
  RealColumn get limitValue => real()();
  /// Unit label for [limitValue].
  TextColumn get limitUnit => text()();
  /// Yellow warning threshold before limit.
  RealColumn get warnYellowBefore => real().withDefault(const Constant(0))();
  /// Red warning threshold before/after limit.
  RealColumn get warnRedBefore => real().withDefault(const Constant(0))();
  /// UI color for yellow state.
  TextColumn get warnYellowColor =>
      text().withDefault(const Constant('#FFC107'))();
  /// UI color for red state.
  TextColumn get warnRedColor =>
      text().withDefault(const Constant('#DC3545'))();
  /// Whether rule participates in calculations.
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  /// Optional free-form notes.
  TextColumn get notes => text().nullable()();
}
