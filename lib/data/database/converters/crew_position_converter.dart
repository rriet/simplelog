import 'package:drift/drift.dart';

import '../enums/crew_position.dart';

class CrewPositionConverter extends TypeConverter<CrewPosition, String> {
  const CrewPositionConverter();

  @override
  CrewPosition fromSql(String fromDb) {
    return switch (fromDb) {
      'pic' => CrewPosition.pic,
      'sic' => CrewPosition.sic,
      'instructor' => CrewPosition.instructor,
      'observer' => CrewPosition.observer,
      'relief' => CrewPosition.relief,
      'relief_captain' => CrewPosition.reliefCaptain,
      'relief_first_officer' => CrewPosition.reliefFirstOfficer,
      'cabin_senior' => CrewPosition.cabinSenior,
      'cabin_crew' => CrewPosition.cabinCrew,
      'other' => CrewPosition.other,
      _ => CrewPosition.unknown,
    };
  }

  @override
  String toSql(CrewPosition value) {
    return switch (value) {
      CrewPosition.pic => 'pic',
      CrewPosition.sic => 'sic',
      CrewPosition.instructor => 'instructor',
      CrewPosition.observer => 'observer',
      CrewPosition.relief => 'relief',
      CrewPosition.reliefCaptain => 'relief_captain',
      CrewPosition.reliefFirstOfficer => 'relief_first_officer',
      CrewPosition.cabinSenior => 'cabin_senior',
      CrewPosition.cabinCrew => 'cabin_crew',
      CrewPosition.other => 'other',
      CrewPosition.unknown => throw ArgumentError(
          'Cannot save unknown CrewPosition to database',
        ),
    };
  }
}
