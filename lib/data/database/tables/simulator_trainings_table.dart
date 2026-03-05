import 'package:drift/drift.dart';

import 'package:simplelog/data/database/tables/aircrafts_table.dart';
import 'package:simplelog/data/database/tables/timeline_table.dart';

/// Simulator training sessions table.
class SimulatorTrainings extends Table {
  /// Surrogate primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Linked aircraft id (simulator-capable aircraft row).
  IntColumn get aircraftId => integer().references(
    Aircrafts,
    #id,
    onDelete: KeyAction.restrict,
    onUpdate: KeyAction.restrict,
  )();

  /// Start timeline reference.
  IntColumn get startTimeLineId => integer().references(
    TimeLines,
    #id,
    onDelete: KeyAction.restrict,
    onUpdate: KeyAction.restrict,
  )();

  /// Optional end datetime.
  DateTimeColumn get endDateTime => dateTime().nullable()();

  /// Session total in minutes.
  IntColumn get timeTotal => integer()();

  /// User remarks.
  TextColumn get remarks => text()();

  /// Private notes.
  TextColumn get notes => text()();

  /// Lock flag preventing edits.
  BoolColumn get isLocked => boolean()();

  /// Optional endorsement signature image.
  BlobColumn get signatureImage => blob().nullable()();

  /// Optional serialized endorsement metadata.
  TextColumn get endorsementData => text().nullable()();

  /// Hash used to verify endorsement integrity.
  TextColumn get endorsementHash => text().nullable()();
}
