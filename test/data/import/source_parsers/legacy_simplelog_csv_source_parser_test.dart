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
    'Departure Icao',
    'Arrival Icao',
    'Aircraft Registration',
    'Model Make & Model',
    'Aircraft Simulator',
    'IFR Minutes',
    'Total Minutes',
  ];

  String csv(List<List<String>> rows) {
    return rows.map((row) => row.join(',')).join('\n');
  }

  test('parse applies IFR minus before percent and enforces minimum', () {
    final content = csv([
      header,
      [
        '01/03/2026',
        '08:00',
        '10:00',
        'KHOU',
        'KDAL',
        'N123SW',
        'B737-700',
        '0',
        '0',
        '120',
      ],
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
        [
          '01/03/2026',
          '08:00',
          '10:00',
          'KHOU',
          'KDAL',
          'N123SW',
          'B737-700',
          '0',
          '0',
          '0',
        ],
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
}
