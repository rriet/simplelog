import 'package:simplelog/data/database/app_database.dart';

class PreviousExperienceRow {
  const PreviousExperienceRow({
    required this.previousExperience,
    required this.aircraftType,
  });

  final PreviousExperience previousExperience;
  final AircraftType aircraftType;
}
