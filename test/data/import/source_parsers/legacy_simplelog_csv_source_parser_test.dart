import 'package:flutter_test/flutter_test.dart';
import 'package:simplelog/data/import/normalized_import_models.dart';
import 'package:simplelog/data/import/simplelog_import_options.dart';
import 'package:simplelog/data/import/source_parsers/legacy_simplelog_csv_source_parser.dart';

void main() {
  const parser = LegacySimpleLogCsvSourceParser();
  const header = <String>[
    'Date (DD/MM/YYYY)',
    'Departure Time (HH:MM)',
    'Arrival Time (HH:MM)',
    'Takeoff Time (HH:MM)',
    'Landing Time (HH:MM)',
    'Departure Epoch',
    'Arrival Epoch',
    'Departure Icao',
    'Arrival Icao',
    'Aircraft Registration',
    'Model Make & Model',
    'Aircraft Simulator',
    'IFR Minutes',
    'Simulator Minutes',
    'Private notes',
    'Duty Minutes',
    'Duty Factored Minutes',
    'Positioning Minutes',
    'Event Type',
    'Total Minutes',
  ];

  String csv(List<List<String>> rows) {
    return rows.map((row) => row.join(',')).join('\n');
  }

  List<String> row(Map<String, String> values) {
    return header.map((column) => values[column] ?? '').toList(growable: false);
  }

  test('parse applies IFR minus before percent and enforces minimum', () {
    final content = csv([
      header,
      row({
        'Date (DD/MM/YYYY)': '01/03/2026',
        'Departure Time (HH:MM)': '08:00',
        'Arrival Time (HH:MM)': '10:00',
        'Departure Icao': 'KHOU',
        'Arrival Icao': 'KDAL',
        'Aircraft Registration': 'N123SW',
        'Model Make & Model': 'B737-700',
        'Aircraft Simulator': '0',
        'IFR Minutes': '0',
        'Simulator Minutes': '0',
        'Total Minutes': '120',
      }),
    ]);

    final batch = parser.parse(
      content,
      options: const SimpleLogImportOptions(
        recalculateIfrTime: true,
        ifrPercent: 50,
        ifrSubtractMinutes: 30,
        ifrMinimumMinutes: 40,
      ),
    );
    final record = batch.records.single as NormalizedFlightRecord;

    expect(record.timeBlockMinutes, 120);
    expect(record.timeIfrMinutes, 45);
  });

  test(
    'parse does not derive block from dep/arr when total recalc is off',
    () {
      final content = csv([
        header,
        row({
          'Date (DD/MM/YYYY)': '01/03/2026',
          'Departure Time (HH:MM)': '08:00',
          'Arrival Time (HH:MM)': '10:00',
          'Departure Icao': 'KHOU',
          'Arrival Icao': 'KDAL',
          'Aircraft Registration': 'N123SW',
          'Model Make & Model': 'B737-700',
          'Aircraft Simulator': '0',
          'IFR Minutes': '0',
          'Simulator Minutes': '0',
          'Total Minutes': '0',
        }),
      ]);

      final batch = parser.parse(
        content,
        options: const SimpleLogImportOptions(
          recalculateCrossCountry: true,
        ),
      );
      final record = batch.records.single as NormalizedFlightRecord;

      expect(record.timeBlockMinutes, 0);
      expect(record.timeCrossCountryMinutes, 0);
    },
  );

  test('parse reads takeoff and landing times when provided', () {
    final content = csv([
      header,
      row({
        'Date (DD/MM/YYYY)': '05/03/2026',
        'Departure Time (HH:MM)': '08:00',
        'Arrival Time (HH:MM)': '10:00',
        'Takeoff Time (HH:MM)': '08:12',
        'Landing Time (HH:MM)': '09:48',
        'Departure Icao': 'KDAL',
        'Arrival Icao': 'KHOU',
        'Aircraft Registration': 'N777SW',
        'Model Make & Model': 'B737-700',
        'Aircraft Simulator': '0',
        'IFR Minutes': '0',
        'Simulator Minutes': '0',
        'Total Minutes': '120',
      }),
    ]);

    final batch = parser.parse(content);
    final record = batch.records.single as NormalizedFlightRecord;
    expect(record.takeOffDateTime, DateTime.utc(2026, 3, 5, 8, 12));
    expect(record.landingDateTime, DateTime.utc(2026, 3, 5, 9, 48));
  });

  test('parse imports simulator rows from event type marker', () {
    final content = csv([
      header,
      row({
        'Date (DD/MM/YYYY)': '02/03/2026',
        'Departure Time (HH:MM)': '09:00',
        'Arrival Time (HH:MM)': '11:00',
        'Aircraft Registration': 'SIM-01',
        'Model Make & Model': 'A320',
        'Aircraft Simulator': 'true',
        'IFR Minutes': '0',
        'Simulator Minutes': '120',
        'Private notes': 'sim notes',
        'Positioning Minutes': '0',
        'Event Type': 'simulator',
        'Total Minutes': '120',
      }),
    ]);

    final batch = parser.parse(content);
    final record = batch.records.single as NormalizedSimulatorRecord;
    expect(record.aircraft.registration, 'SIM-01');
    expect(record.timeTotal, 120);
    expect(record.notes, 'sim notes');
  });

  test('parse imports positioning rows from event type marker', () {
    final content = csv([
      header,
      row({
        'Date (DD/MM/YYYY)': '03/03/2026',
        'Departure Time (HH:MM)': '10:15',
        'Arrival Time (HH:MM)': '12:45',
        'Departure Icao': 'KJFK',
        'Arrival Icao': 'KBOS',
        'Aircraft Simulator': 'false',
        'IFR Minutes': '0',
        'Simulator Minutes': '0',
        'Private notes': 'positioning notes',
        'Positioning Minutes': '150',
        'Event Type': 'positioning',
        'Total Minutes': '150',
      }),
    ]);

    final batch = parser.parse(content);
    final record = batch.records.single as NormalizedPositioningRecord;
    expect(record.departureAirport.icao, 'KJFK');
    expect(record.arrivalAirport.icao, 'KBOS');
    expect(record.timeTotalMinutes, 150);
    expect(record.notes, 'positioning notes');
  });

  test('parse imports duty rows from event type marker', () {
    final content = csv([
      header,
      row({
        'Date (DD/MM/YYYY)': '04/03/2026',
        'Departure Time (HH:MM)': '05:00',
        'Arrival Time (HH:MM)': '13:00',
        'Aircraft Simulator': 'false',
        'IFR Minutes': '0',
        'Simulator Minutes': '0',
        'Private notes': '',
        'Duty Minutes': '480',
        'Duty Factored Minutes': '450',
        'Positioning Minutes': '0',
        'Event Type': 'duty',
        'Total Minutes': '480',
      }),
    ]);

    final batch = parser.parse(content);
    final record = batch.records.single as NormalizedDutyRecord;
    expect(record.startDateTime, DateTime.utc(2026, 3, 4, 5));
    expect(record.endDateTime, DateTime.utc(2026, 3, 4, 13));
    expect(record.timeDutyMinutes, 480);
    expect(record.timeFactoredDutyMinutes, 450);
  });
}
