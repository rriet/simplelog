import 'package:drift/drift.dart';

class LimitRules extends Table {
  IntColumn get ruleId => integer().autoIncrement()();
  TextColumn get ruleName => text()();
  TextColumn get metric => text()();
  TextColumn get ruleType => text()();
  TextColumn get windowType => text()();
  IntColumn get windowValue => integer()();
  RealColumn get limitValue => real()();
  TextColumn get limitUnit => text()();
  RealColumn get warnYellowBefore => real().withDefault(const Constant(0))();
  RealColumn get warnRedBefore => real().withDefault(const Constant(0))();
  TextColumn get warnYellowColor =>
      text().withDefault(const Constant('#FFC107'))();
  TextColumn get warnRedColor =>
      text().withDefault(const Constant('#DC3545'))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();
}
