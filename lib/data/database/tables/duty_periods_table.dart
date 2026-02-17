import 'package:drift/drift.dart';

import 'timeline_table.dart';

class DutyPeriods extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get dutyStartTimeLineId => integer().references(TimeLines, #id)();
  IntColumn get dutyEndTimeLineId => integer().references(TimeLines, #id)();
  IntColumn get timeDutyMinutes => integer()();
  IntColumn get timeFactoredDutyMinutes => integer()();
  BoolColumn get isLocked => boolean()();

  @override
  List<String> get customConstraints => const [
        'UNIQUE(duty_start_time_line_id)',
        'UNIQUE(duty_end_time_line_id)',
      ];
}
