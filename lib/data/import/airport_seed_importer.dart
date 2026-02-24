import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:simplelog/data/database/app_database.dart';

/// Loads an initial list of airports from an embedded JSON asset when empty.
class AirportSeedImporter {
  /// Creates an importer instance.
  const AirportSeedImporter();

  /// Asset path for the bundled airports JSON data.
  static const _assetPath = 'assets/data/airports.json';

  /// Imports seed airports into [db] when the airports table is empty.
  Future<int> importIfEmpty(AppDatabase db) async {
    final countExpr = db.airports.id.count();
    final query = db.selectOnly(db.airports)..addColumns([countExpr]);
    final row = await query.getSingle();
    final count = row.read(countExpr) ?? 0;
    if (count > 0) {
      return 0;
    }

    final payload = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(payload);
    if (decoded is! List) {
      return 0;
    }

    final rows = <AirportsCompanion>[];
    for (final entry in decoded) {
      if (entry is! Map) {
        continue;
      }
      final icao = _string(entry['Icao']).toUpperCase();
      if (icao.isEmpty) {
        continue;
      }
      final iata = _string(entry['Iata']).toUpperCase();
      final name = _string(entry['Name']);
      final city = _string(entry['City']);
      final country = _string(entry['Country']);
      final latitude = _double(entry['Latitude']);
      final longitude = _double(entry['Longitude']);

      rows.add(
        AirportsCompanion.insert(
          icao: icao,
          iata: iata.isEmpty ? const Value(null) : Value(iata),
          name: name.isEmpty ? const Value(null) : Value(name),
          city: city.isEmpty ? const Value(null) : Value(city),
          country: country.isEmpty ? const Value(null) : Value(country),
          latitude: latitude,
          longitude: longitude,
          isFavorite: false,
          isLocked: false,
        ),
      );
    }

    if (rows.isEmpty) {
      return 0;
    }

    await db.batch((batch) {
      batch.insertAll(
        db.airports,
        rows,
        mode: InsertMode.insertOrIgnore,
      );
    });

    return rows.length;
  }

  String _string(Object? value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  double _double(Object? value) {
    if (value == null) return 0;
    final parsed = double.tryParse(value.toString().trim());
    return parsed ?? 0;
  }
}
