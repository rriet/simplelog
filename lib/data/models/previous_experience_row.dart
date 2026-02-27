import 'package:simplelog/data/database/app_database.dart';

/// Previous-experience row joined with its aircraft type.
class PreviousExperienceRow {
  /// Creates the joined row model.
  const PreviousExperienceRow({
    required this.previousExperience,
    required this.aircraftType,
  });

  /// Previous-experience totals.
  final PreviousExperience previousExperience;
  /// Linked aircraft type metadata.
  final AircraftType aircraftType;
}
