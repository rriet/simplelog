import 'package:drift/drift.dart';

class TimeLines extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get eventDateTime => dateTime()();
}
