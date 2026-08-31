import 'package:flutter/material.dart';
import 'package:simplelog/core/date/db_date_time.dart';

/// Formatting helpers for flight chocks times (chocks-off/on).
///
/// Rules:
/// - `null` => '--:--'
/// - If both chocks-off AND chocks-on are `00:00` UTC => both '--:--'.
///   Otherwise `00:00` is valid and renders as '00:00'.
/// - Take-off / landing `null` => '--:--', but `00:00` is always valid.
class FlightTimeFormatter {
  const FlightTimeFormatter._();

  static bool _isMidnightUtc(DateTime dt) {
    final utc = DbDateTime.dbToUtc(dt);
    return utc.hour == 0 && utc.minute == 0;
  }

  /// Returns true when both chocks times are exactly 00:00 UTC.
  static bool isPairedMidnightMissing(
    DateTime? chocksOff,
    DateTime? chocksOn,
  ) {
    if (chocksOff == null || chocksOn == null) return false;
    return _isMidnightUtc(chocksOff) && _isMidnightUtc(chocksOn);
  }

  /// Mirrors `FlightEditScreen.unknownTimes` (`lib/features/logbook/presentation/flight_edit_screen.dart:348`):
  /// `chocksOff==00:00 && chocksOn==null` is shown as blank in edit, so display as `--:--`.
  static bool isEditBlankMimic(
    DateTime? chocksOff,
    DateTime? chocksOn,
  ) {
    if (chocksOff == null || chocksOn != null) return false;
    return _isMidnightUtc(chocksOff);
  }

  static String _formatUtc(DateTime value) {
    final utc = DbDateTime.dbToUtc(value);
    return '${utc.hour.toString().padLeft(2, '0')}:${utc.minute.toString().padLeft(2, '0')}';
  }

  /// Formats a chocks time respecting paired-midnight rule.
  static String formatChocksTime(
    DateTime? time, {
    required bool pairedMidnightMissing,
  }) {
    if (time == null) return '--:--';
    if (pairedMidnightMissing) return '--:--';
    return _formatUtc(time);
  }

  /// Convenience for flight departure/arrival pair.
  /// Copies edit blank behaviour: `chocksOff==00:00 && chocksOn==null` => dep `--:--`.
  static (String dep, String arr) formatChocksPair({
    required DateTime? chocksOff,
    required DateTime? chocksOn,
  }) {
    final paired = isPairedMidnightMissing(chocksOff, chocksOn);
    final editBlank = isEditBlankMimic(chocksOff, chocksOn);
    return (
      formatChocksTime(chocksOff, pairedMidnightMissing: paired || editBlank),
      formatChocksTime(chocksOn, pairedMidnightMissing: paired),
    );
  }

  /// Formats an optional flight time (take-off, landing) where null=>missing
  /// but 00:00 is always valid.
  static String formatOptionalFlightTime(DateTime? time) {
    if (time == null) return '--:--';
    return _formatUtc(time);
  }

  /// Legacy helper for positioning: treats midnight as missing if requested.
  /// Kept for positioning only.
  static String formatFlightTimeLegacy({
    required DateTime? fallback,
    required DateTime? explicit,
    required bool treatMidnightAsMissing,
  }) {
    final timeSource = explicit ?? fallback;
    if (timeSource == null) return '--:--';
    final utcTime = DbDateTime.dbToUtc(timeSource);
    if (treatMidnightAsMissing && utcTime.hour == 0 && utcTime.minute == 0) {
      return '--:--';
    }
    final hour = utcTime.hour.toString().padLeft(2, '0');
    final minute = utcTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
