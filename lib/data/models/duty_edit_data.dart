import 'package:simplelog/data/database/app_database.dart';

/// Public API documentation.
class DutyEditData {
  /// Public API documentation.
  const DutyEditData({
    required this.duty,
    required this.startLine,
    required this.endLine,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final DutyPeriod duty;
  /// Public API documentation.
  final TimeLine? startLine;
  /// Public API documentation.
  final TimeLine? endLine;
}
