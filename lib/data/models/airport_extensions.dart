import 'package:simplelog/data/database/app_database.dart';

extension AirportExtensions on Airport {
  String get shortCode {
    final trimmedIata = iata?.trim();
    if (trimmedIata != null && trimmedIata.isNotEmpty) {
      return trimmedIata;
    }
    return icao;
  }

  String get displayCode {
    final trimmedIata = iata?.trim();
    if (trimmedIata == null || trimmedIata.isEmpty) {
      return icao;
    }
    return '$icao • $trimmedIata';
  }
}
