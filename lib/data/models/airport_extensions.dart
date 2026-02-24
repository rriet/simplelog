import 'package:simplelog/data/database/app_database.dart';

/// Convenience extensions for formatting airport information.
extension AirportExtensions on Airport {
  /// Returns IATA code when available, otherwise falls back to ICAO.
  String get shortCode {
    final trimmedIata = iata?.trim();
    if (trimmedIata != null && trimmedIata.isNotEmpty) {
      return trimmedIata;
    }
    return icao;
  }

  /// Returns a combined ICAO / IATA representation suitable for UI labels.
  String get displayCode {
    final trimmedIata = iata?.trim();
    if (trimmedIata == null || trimmedIata.isEmpty) {
      return icao;
    }
    return '$icao • $trimmedIata';
  }
}
