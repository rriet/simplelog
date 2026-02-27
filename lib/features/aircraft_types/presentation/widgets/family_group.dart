import 'package:simplelog/data/models/aircraft_type_row.dart';

/// Group model used to display aircraft types by family in the UI.
class FamilyGroup {
  /// Creates a grouped collection for one aircraft [family].
  const FamilyGroup({
    required this.family,
    required this.rows,
  });

  /// Aircraft family label used as section header.
  final String family;

  /// Rows that belong to this [family].
  final List<AircraftTypeRow> rows;
}
