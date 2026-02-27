import 'package:simplelog/data/database/app_database.dart';

/// Aggregates positioning and timeline data required by the edit screen.
class PositioningEditData {
  /// Creates edit data containing the positioning row and optional
  /// departure line.
  const PositioningEditData({
    required this.positioning,
    required this.departureLine,
  });

  /// Persisted positioning entry to edit.
  final Positioning positioning;

  /// Linked departure timeline record when available.
  final TimeLine? departureLine;
}
