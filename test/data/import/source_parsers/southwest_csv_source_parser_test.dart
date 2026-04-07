import 'package:flutter_test/flutter_test.dart';
import 'package:simplelog/data/import/normalized_import_models.dart';
import 'package:simplelog/data/import/source_parsers/southwest_csv_source_parser.dart';
import 'package:simplelog/data/import/southwest_import_options.dart';

void main() {
  const parser = SouthwestCsvSourceParser();
  const header = <String>[
    'DATE',
    'Flight',
    'dhd',
    'From',
    'Depart',
    'To',
    'Arrive',
    'Block',
    'Tail_Number',
    'A_C_Type',
    'TakeOff',
    'Landing',
    'CoPilot',
  ];

  String csv(List<List<String>> rows) {
    return rows.map((row) => row.join(',')).join('\n');
  }

  test('inspect reports required-field missing lines', () {
    final content = csv([
      header,
      [
        '2026-03-01',
        '123',
        '',
        '',
        '08:00',
        'KDAL',
        '',
        '0100',
        'N123SW',
        'B737-700',
        '1',
        '1',
        '',
      ],
    ]);

    final report = parser.inspect(content);

    expect(report.missingRequiredIssues, hasLength(1));
    expect(report.missingRequiredIssues.single.sourceLineNumber, 2);
    expect(
      report.missingRequiredIssues.single.missingFields,
      containsAll(<SouthwestMissingRequiredField>[
        SouthwestMissingRequiredField.departureAirport,
        SouthwestMissingRequiredField.arrivalTime,
      ]),
    );
  });

  test('inspect reports missing type and tail for flight rows', () {
    final content = csv([
      header,
      [
        '2026-03-01',
        '123',
        '',
        'KHOU',
        '08:00',
        'KDAL',
        '09:00',
        '0100',
        '',
        '',
        '1',
        '1',
        '',
      ],
      [
        '2026-03-02',
        '124',
        'DH',
        'KHOU',
        '08:00',
        'KDAL',
        '09:00',
        '0100',
        '',
        '',
        '0',
        '0',
        '',
      ],
    ]);

    final report = parser.inspect(content);

    expect(report.missingAircraftTypeIssues, hasLength(1));
    expect(report.missingAircraftTypeIssues.single.sourceLineNumber, 2);
    expect(report.missingAircraftTailIssues, hasLength(1));
    expect(report.missingAircraftTailIssues.single.sourceLineNumber, 2);
  });

  test('parse imports missing type as UNKNOWN when configured', () {
    final content = csv([
      header,
      [
        '2026-03-01',
        '123',
        '',
        'KHOU',
        '08:00',
        'KDAL',
        '09:00',
        '0100',
        'N123SW',
        '',
        '1',
        '1',
        '',
      ],
    ]);

    final batch = parser.parse(content);
    final flight = batch.records.single as NormalizedFlightRecord;

    expect(flight.aircraftType.code, 'UNKNOWN');
    expect(flight.aircraft.registration, 'N123SW');
  });

  test('parse skips missing type rows when configured', () {
    final content = csv([
      header,
      [
        '2026-03-01',
        '123',
        '',
        'KHOU',
        '08:00',
        'KDAL',
        '09:00',
        '0100',
        'N123SW',
        '',
        '1',
        '1',
        '',
      ],
    ]);

    final batch = parser.parse(
      content,
      options: const SouthwestImportOptions(
        missingAircraftTypePolicy: SouthwestMissingAircraftTypePolicy.skipLines,
      ),
    );

    expect(batch.records, isEmpty);
    expect(batch.skippedRows, 1);
  });

  test('parse uses type as tail when tail is missing', () {
    final content = csv([
      header,
      [
        '2026-03-01',
        '123',
        '',
        'KHOU',
        '08:00',
        'KDAL',
        '09:00',
        '0100',
        '',
        'B737-700',
        '1',
        '1',
        '',
      ],
    ]);

    final batch = parser.parse(content);
    final flight = batch.records.single as NormalizedFlightRecord;

    expect(flight.aircraft.registration, 'B737-700');
    expect(flight.aircraftType.code, 'B737-700');
  });

  test('parse skips source lines from options', () {
    final content = csv([
      header,
      [
        '2026-03-01',
        '123',
        '',
        'KHOU',
        '08:00',
        'KDAL',
        '09:00',
        '0100',
        'N123SW',
        'B737-700',
        '1',
        '1',
        '',
      ],
    ]);

    final batch = parser.parse(
      content,
      options: const SouthwestImportOptions(
        skippedSourceLineNumbers: <int>{2},
      ),
    );

    expect(batch.records, isEmpty);
    expect(batch.skippedRows, 1);
  });

  test('parse sets positioning overwrite flags from options', () {
    final content = csv([
      header,
      [
        '2026-03-01',
        '124',
        'DH',
        'KHOU',
        '08:00',
        'KDAL',
        '09:00',
        '0100',
        '',
        '',
        '0',
        '0',
        '',
      ],
    ]);

    final batch = parser.parse(
      content,
      options: const SouthwestImportOptions(overrideExistingData: true),
    );
    final record = batch.records.single as NormalizedPositioningRecord;

    expect(record.matchExistingByPositioningDateKey, isTrue);
    expect(record.overrideMatchedPositioning, isTrue);
  });
}
