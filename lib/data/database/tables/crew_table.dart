import 'package:drift/drift.dart';

class Crew extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get email => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get phone => text().nullable()();
  BlobColumn get picture => blob().nullable()();
  BoolColumn get isSelf => boolean()();
  BoolColumn get isFavorite => boolean()();
  BoolColumn get isLocked => boolean()();
}
