import 'package:simplelog/data/database/app_database.dart';

/// Crew row wrapper used by list UIs.
class CrewRow {
  /// Creates a crew row wrapper.
  const CrewRow(this.crew);

  /// Backing crew entity.
  final CrewData crew;

  /// Convenience id getter.
  int get id => crew.id;
  /// Convenience name getter.
  String get name => crew.name;
  /// Convenience favorite getter.
  bool get isFavorite => crew.isFavorite;
  /// Convenience lock getter.
  bool get isLocked => crew.isLocked;
}
