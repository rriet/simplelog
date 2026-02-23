import 'package:drift/drift.dart';

import 'package:simplelog/data/database/tables/timeline_table.dart';

/// Public API documentation.
class DutyPeriods extends Table {
  /// Public API documentation.
  IntColumn get id => integer().autoIncrement()();
  /// Public API documentation.
  IntColumn get dutyStartTimeLineId => integer().references(TimeLines, #id)();
  /// Public API documentation.
  IntColumn get dutyEndTimeLineId => integer().references(TimeLines, #id)();
  /// Public API documentation.
  IntColumn get timeDutyMinutes => integer()();
  /// Public API documentation.
  IntColumn get restBeforeMinutes => integer().withDefault(const Constant(0))();
  /// Public API documentation.
  IntColumn get timeFactoredDutyMinutes => integer()();
  /// Public API documentation.
  BoolColumn get isLocked => boolean()();

  @override
  List<String> get customConstraints => const [
    'UNIQUE(duty_start_time_line_id)',
    'UNIQUE(duty_end_time_line_id)',
  ];
}
