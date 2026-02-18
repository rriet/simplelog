import 'package:simplelog/data/database/app_database.dart';

class PositioningEditData {
  const PositioningEditData({
    required this.positioning,
    required this.departureLine,
  });

  final Positioning positioning;
  final TimeLine? departureLine;
}
