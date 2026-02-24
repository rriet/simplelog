/// Categorization of aircraft engine types used for reporting and filtering.
enum EngineType {
  /// Rocket-powered engines.
  rocket,

  /// Piston engines.
  piston,

  /// Turboprop engines.
  turboprop,

  /// Turbojet or turbofan engines.
  jet,

  /// Electric motors.
  electric,

  /// Ultralight aircraft powerplant.
  ultraLightAircraft,

  /// Uncrewed aerial vehicles (drones).
  drone,

  /// Unpowered gliders.
  glider,

  /// Lighter‑than‑air airships.
  airship,

  /// Free balloons.
  balloon,

  /// Powered paraglider / paraplane.
  paraplane,

  /// Unknown or unspecified type.
  unknown,
}
