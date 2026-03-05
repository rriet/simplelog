/// Canonical pilot function values stored for flights.
enum PilotFunction {
  /// Pilot flying.
  pf,

  /// Pilot monitoring / not flying.
  pnf,

  /// Pilot flying on takeoff and PNF on landing.
  pfPnf,

  /// PNF on takeoff and PF on landing.
  pnfPf,

  /// In-flight relief pilot 3.
  irp3,

  /// In-flight relief pilot 4.
  irp4,

  /// Any non-standard value.
  other,
}

/// Helper labels for [PilotFunction] values.
extension PilotFunctionLabel on PilotFunction {
  /// Display/storage label used by the app.
  String get label {
    return switch (this) {
      PilotFunction.pf => 'PF',
      PilotFunction.pnf => 'PNF',
      PilotFunction.pfPnf => 'PF/PNF',
      PilotFunction.pnfPf => 'PNF/PF',
      PilotFunction.irp3 => 'IRP 3',
      PilotFunction.irp4 => 'IRP 4',
      PilotFunction.other => 'OTHER',
    };
  }
}
