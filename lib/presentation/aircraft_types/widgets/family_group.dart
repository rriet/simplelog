import 'package:simplelog/data/models/aircraft_type_row.dart';

class FamilyGroup {
  const FamilyGroup({
    required this.family,
    required this.rows,
  });

  final String family;
  final List<AircraftTypeRow> rows;
}
