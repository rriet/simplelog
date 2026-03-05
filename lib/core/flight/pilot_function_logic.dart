/// Canonical pilot-function labels used by the app.
abstract final class PilotFunctionLogic {
  /// Pilot flying.
  static const String pf = 'PF';

  /// Pilot monitoring / not flying.
  static const String pnf = 'PNF';

  /// PF on takeoff and PNF on landing.
  static const String pfPnf = 'PF/PNF';

  /// PNF on takeoff and PF on landing.
  static const String pnfPf = 'PNF/PF';

  /// In-flight relief pilot 3.
  static const String irp3 = 'IRP 3';

  /// In-flight relief pilot 4.
  static const String irp4 = 'IRP 4';

  /// Derives pilot function from takeoff/landing counts.
  ///
  /// Rules:
  /// - takeoff > 0 and landing > 0 -> PF
  /// - takeoff == 0 and landing == 0 -> PNF
  /// - takeoff > 0 and landing == 0 -> PF/PNF
  /// - takeoff == 0 and landing > 0 -> PNF/PF
  static String fromTakeoffLanding({
    required int takeoffCount,
    required int landingCount,
  }) {
    final takeoffs = takeoffCount < 0 ? 0 : takeoffCount;
    final landings = landingCount < 0 ? 0 : landingCount;
    if (takeoffs > 0 && landings > 0) return pf;
    if (takeoffs > 0 && landings == 0) return pfPnf;
    if (takeoffs == 0 && landings > 0) return pnfPf;
    return pnf;
  }

  /// Normalizes raw labels and falls back to [fromTakeoffLanding] when unknown.
  static String canonicalize(
    String raw, {
    required int takeoffCount,
    required int landingCount,
  }) {
    final normalized = raw.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
    switch (normalized) {
      case 'PF':
        return pf;
      case 'PNF':
      case 'PM':
        return pnf;
      case 'PF/PNF':
        return pfPnf;
      case 'PNF/PF':
      case 'PM/PF':
        return pnfPf;
      case 'IRP3':
        return irp3;
      case 'IRP4':
        return irp4;
    }
    return fromTakeoffLanding(
      takeoffCount: takeoffCount,
      landingCount: landingCount,
    );
  }

  /// Returns whether [pilotFunction] matches expected takeoff/landing pattern.
  ///
  /// IRP functions are considered valid regardless of counts.
  static bool matchesTakeoffLandingPattern(
    String pilotFunction, {
    required int takeoffCount,
    required int landingCount,
  }) {
    final canonical = canonicalize(
      pilotFunction,
      takeoffCount: takeoffCount,
      landingCount: landingCount,
    );
    switch (canonical) {
      case pf:
        return takeoffCount > 0 && landingCount > 0;
      case pnf:
        return takeoffCount == 0 && landingCount == 0;
      case pfPnf:
        return takeoffCount > 0 && landingCount == 0;
      case pnfPf:
        return takeoffCount == 0 && landingCount > 0;
      case irp3:
      case irp4:
        return true;
      default:
        return false;
    }
  }

  /// Human-readable rule text for validation messages.
  static String takeoffLandingRule(String pilotFunction) {
    final normalized = pilotFunction.trim().toUpperCase().replaceAll(' ', '');
    switch (normalized) {
      case 'PF':
        return 'takeoffs/landings must be > 0';
      case 'PNF':
      case 'PM':
        return 'takeoffs/landings must be 0';
      case 'PF/PNF':
        return 'takeoffs must be > 0 and landings must be 0';
      case 'PNF/PF':
      case 'PM/PF':
        return 'takeoffs must be 0 and landings must be > 0';
      case 'IRP3':
      case 'IRP4':
        return 'IRP rules';
      default:
        return 'pattern must match takeoff/landing counts';
    }
  }
}
