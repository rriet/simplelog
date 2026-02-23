import 'package:simplelog/data/database/app_database.dart';

/// Public API documentation.
class CrewRow {
  /// Public API documentation.
  const CrewRow(this.crew);

  /// Public API documentation.
  final CrewData crew;
/// Public API documentation.

  /// Public API documentation.
  int get id => crew.id;
  /// Public API documentation.
  String get name => crew.name;
  /// Public API documentation.
  bool get isFavorite => crew.isFavorite;
  /// Public API documentation.
  bool get isLocked => crew.isLocked;
}
