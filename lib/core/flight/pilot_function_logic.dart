import 'package:simplelog/data/database/enums/pilot_function.dart';

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
    final parsed = parse(raw);
    if (parsed != PilotFunction.other) {
      return toLabel(parsed);
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
    switch (parse(pilotFunction)) {
      case PilotFunction.pf:
        return 'takeoffs/landings must be > 0';
      case PilotFunction.pnf:
        return 'takeoffs/landings must be 0';
      case PilotFunction.pfPnf:
        return 'takeoffs must be > 0 and landings must be 0';
      case PilotFunction.pnfPf:
        return 'takeoffs must be 0 and landings must be > 0';
      case PilotFunction.irp3:
      case PilotFunction.irp4:
        return 'IRP rules';
      case PilotFunction.other:
        return 'pattern must match takeoff/landing counts';
    }
  }

  /// Parses raw text (including legacy aliases) into [PilotFunction].
  static PilotFunction parse(String raw) {
    final normalized = raw.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
    return switch (normalized) {
      'PF' => PilotFunction.pf,
      'PNF' => PilotFunction.pnf,
      'PM' => PilotFunction.pnf,
      'PF/PNF' => PilotFunction.pfPnf,
      'PNF/PF' => PilotFunction.pnfPf,
      'PM/PF' => PilotFunction.pnfPf,
      'IRP3' => PilotFunction.irp3,
      'IRP4' => PilotFunction.irp4,
      'OTHER' => PilotFunction.other,
      _ => PilotFunction.other,
    };
  }

  /// Converts [value] to the display/storage text used by UI/import checks.
  static String toLabel(PilotFunction value) {
    return switch (value) {
      PilotFunction.pf => pf,
      PilotFunction.pnf => pnf,
      PilotFunction.pfPnf => pfPnf,
      PilotFunction.pnfPf => pnfPf,
      PilotFunction.irp3 => irp3,
      PilotFunction.irp4 => irp4,
      PilotFunction.other => 'OTHER',
    };
  }

  /// Converts an enum to canonical text used by check/pattern logic.
  static String fromEnum(PilotFunction value) => toLabel(value);
}
