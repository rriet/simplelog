/// High-level category describing how an aircraft operates.
enum AircraftCategory {
  /// Can operate on both land and water.
  amphibian,

  /// Gyrocopter / autogyro.
  gyrocopter,

  /// Helicopter or rotorcraft.
  helicopter,

  /// Conventional landplane.
  landplane,

  /// Pure seaplane (water only).
  seaplane,

  /// Tilt‑wing or VTOL type.
  tiltwing,

  /// Unknown or uncategorized.
  unknown,
}
