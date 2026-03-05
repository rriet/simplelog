import 'package:drift/drift.dart';

import 'package:simplelog/data/database/tables/airports_table.dart';
import 'package:simplelog/data/database/tables/timeline_table.dart';

/// Positioning legs table.
class Positionings extends Table {
  /// Surrogate primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Departure airport id.
  IntColumn get departurePlaceId => integer().references(
    Airports,
    #id,
    onDelete: KeyAction.restrict,
    onUpdate: KeyAction.restrict,
  )();

  /// Arrival airport id.
  IntColumn get arrivalPlaceId => integer().references(
    Airports,
    #id,
    onDelete: KeyAction.restrict,
    onUpdate: KeyAction.restrict,
  )();

  /// Timeline reference for departure datetime.
  IntColumn get departureDateTimeId => integer().references(
    TimeLines,
    #id,
    onDelete: KeyAction.restrict,
    onUpdate: KeyAction.restrict,
  )();

  /// Optional arrival datetime.
  DateTimeColumn get arrivalDateTime => dateTime().nullable()();

  /// Total positioning time in minutes.
  IntColumn get timeTotalMinutes => integer()();

  /// Optional notes.
  TextColumn get notes => text().withDefault(const Constant(''))();

  /// Lock flag preventing edits.
  BoolColumn get isLocked => boolean()();
}
