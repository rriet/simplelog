import 'package:simplelog/data/database/app_database.dart';

/// Aggregated data needed by duty edit UI.
class DutyEditData {
  /// Creates duty edit payload.
  const DutyEditData({
    required this.duty,
    required this.startLine,
    required this.endLine,
  });

  /// Duty period row being edited.
  final DutyPeriod duty;
  /// Timeline row for duty start.
  final TimeLine? startLine;
  /// Timeline row for duty end.
  final TimeLine? endLine;
}
