import 'package:simplelog/data/database/app_database.dart';

class DutyEditData {
  const DutyEditData({
    required this.duty,
    required this.startLine,
    required this.endLine,
  });

  final DutyPeriod duty;
  final TimeLine? startLine;
  final TimeLine? endLine;
}
