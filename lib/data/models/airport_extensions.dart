import 'package:simplelog/data/database/app_database.dart';

/// Public API documentation.
extension AirportExtensions on Airport {
  /// Public API documentation.
  String get shortCode {
    final trimmedIata = iata?.trim();
    if (trimmedIata != null && trimmedIata.isNotEmpty) {
      return trimmedIata;
    }
    return icao;
  /// Public API documentation.
  }

  /// Public API documentation.
  String get displayCode {
    final trimmedIata = iata?.trim();
    if (trimmedIata == null || trimmedIata.isEmpty) {
      return icao;
    }
    return '$icao • $trimmedIata';
  }
}
