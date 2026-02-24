/// Position or role held by a crew member for a given flight.
enum CrewPosition {
  /// Pilot in command.
  pic,

  /// Pilot in command under supervision.
  picus,

  /// Second in command.
  sic,

  /// Trainee pilot.
  trainee,

  /// Instructor pilot.
  instructor,

  /// Observer in the cockpit.
  observer,

  /// Generic relief crew member.
  relief,

  /// Relief captain.
  reliefCaptain,

  /// Relief first officer.
  reliefFirstOfficer,

  /// Lead cabin crew.
  cabinSenior,

  /// Cabin crew member.
  cabinCrew,

  /// Other role not covered above.
  other,

  /// Unknown position.
  unknown,
}
