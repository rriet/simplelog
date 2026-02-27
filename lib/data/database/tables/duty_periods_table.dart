import 'package:drift/drift.dart';

import 'package:simplelog/data/database/tables/timeline_table.dart';

/// Duty periods table.
class DutyPeriods extends Table {
  /// Surrogate primary key.
  IntColumn get id => integer().autoIncrement()();
  /// Timeline id for duty start.
  IntColumn get dutyStartTimeLineId => integer().references(TimeLines, #id)();
  /// Timeline id for duty end.
  IntColumn get dutyEndTimeLineId => integer().references(TimeLines, #id)();
  /// Total duty minutes.
  IntColumn get timeDutyMinutes => integer()();
  /// Rest before duty in minutes.
  IntColumn get restBeforeMinutes => integer().withDefault(const Constant(0))();
  /// Factored duty minutes.
  IntColumn get timeFactoredDutyMinutes => integer()();
  /// Lock flag preventing edits.
  BoolColumn get isLocked => boolean()();

  @override
  List<String> get customConstraints => const [
    'UNIQUE(duty_start_time_line_id)',
    'UNIQUE(duty_end_time_line_id)',
  ];
}
