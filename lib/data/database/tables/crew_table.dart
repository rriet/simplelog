import 'package:drift/drift.dart';

/// Crew master-data table.
class Crew extends Table {
  /// Surrogate primary key.
  IntColumn get id => integer().autoIncrement()();
  /// Crew display name.
  TextColumn get name => text()();
  /// Optional email address.
  TextColumn get email => text().nullable()();
  /// Optional notes/comments.
  TextColumn get notes => text().nullable()();
  /// Optional phone number.
  TextColumn get phone => text().nullable()();
  /// Optional crew photo.
  BlobColumn get picture => blob().nullable()();
  /// Marks the profile representing the user.
  BoolColumn get isSelf => boolean()();
  /// Favorite/pinned flag.
  BoolColumn get isFavorite => boolean()();
  /// Lock flag preventing edits.
  BoolColumn get isLocked => boolean()();
}
