import 'package:drift/drift.dart';

/// Public API documentation.
class Crew extends Table {
  /// Public API documentation.
  IntColumn get id => integer().autoIncrement()();
  /// Public API documentation.
  TextColumn get name => text()();
  /// Public API documentation.
  TextColumn get email => text().nullable()();
  /// Public API documentation.
  TextColumn get notes => text().nullable()();
  /// Public API documentation.
  TextColumn get phone => text().nullable()();
  /// Public API documentation.
  BlobColumn get picture => blob().nullable()();
  /// Public API documentation.
  BoolColumn get isSelf => boolean()();
  /// Public API documentation.
  BoolColumn get isFavorite => boolean()();
  /// Public API documentation.
  BoolColumn get isLocked => boolean()();
}
