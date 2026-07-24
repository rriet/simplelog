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

  test('inspect applies airport overrides before required-field checks', () {
    final content = csv([
      header,
      [
        '2026-03-01',
        '123',
        '',
        '',
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

    final report = parser.inspect(
      content,
      options: const SouthwestImportOptions(
        airportCodeOverrides: <int, Map<String, String>>{
          2: <String, String>{'from': 'KHOU'},
        },
      ),
    );

    expect(report.missingRequiredIssues, isEmpty);
  });

  test('inspect ignores skipped source lines', () {
    final content = csv([
      header,
      [
        '2026-03-01',
        '123',
        '',
        '',
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
    ]);

    final report = parser.inspect(
      content,
      options: const SouthwestImportOptions(
        skippedSourceLineNumbers: <int>{2},
      ),
    );

    expect(report.missingRequiredIssues, isEmpty);
    expect(report.missingAircraftTailIssues, isEmpty);
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

  test('parse applies IFR minus before percent and enforces minimum', () {
    final content = csv([
      header,
      [
        '2026-03-01',
        '125',
        '',
        'KHOU',
        '08:00',
        'KDAL',
        '10:00',
        '0200',
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
        ifrPercent: 50,
        ifrSubtractMinutes: 30,
        ifrMinimumMinutes: 40,
      ),
    );
    final record = batch.records.single as NormalizedFlightRecord;

    expect(record.timeBlockMinutes, 120);
    expect(record.timeIfrMinutes, 45);
  });

  test('extractUniqueRawTypeCodes returns unique raw types with empty', () {
    final content = csv([
      header,
      [
        '2026-03-01',
        '125',
        '',
        'KHOU',
        '08:00',
        'KDAL',
        '10:00',
        '0200',
        'N123SW',
        '73w',
        '1',
        '1',
        '',
      ],
      [
        '2026-03-02',
        '126',
        '',
        'KHOU',
        '08:00',
        'KDAL',
        '10:00',
        '0200',
        'N124SW',
        '',
        '1',
        '1',
        '',
      ],
      [
        '2026-03-03',
        '127',
        'DH',
        'KHOU',
        '08:00',
        'KDAL',
        '10:00',
        '0200',
        '',
        'DH-TYPE',
        '0',
        '0',
        '',
      ],
    ]);

    final uniqueTypes = parser.extractUniqueRawTypeCodes(content);

    expect(uniqueTypes, containsAll(<String>{'73W', ''}));
    expect(uniqueTypes, hasLength(2));
  });

  test('parse applies configured aircraft type mappings', () {
    final content = csv([
      header,
      [
        '2026-03-01',
        '125',
        '',
        'KHOU',
        '08:00',
        'KDAL',
        '10:00',
        '0200',
        'N123SW',
        '73W',
        '1',
        '1',
        '',
      ],
    ]);

    final batch = parser.parse(
      content,
      options: const SouthwestImportOptions(
        aircraftTypeMappings: <String, String>{'73W': 'B737-700'},
      ),
    );
    final record = batch.records.single as NormalizedFlightRecord;

    expect(record.aircraftType.code, 'B737-700');
  });

  test('parse honors empty-type mapping before skip-lines policy', () {
    final content = csv([
      header,
      [
        '2026-03-01',
        '125',
        '',
        'KHOU',
        '08:00',
        'KDAL',
        '10:00',
        '0200',
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
        aircraftTypeMappings: <String, String>{'': 'UNKNOWN'},
      ),
    );
    final record = batch.records.single as NormalizedFlightRecord;

    expect(record.aircraftType.code, 'UNKNOWN');
  });

  test('extractUniqueRawTypeCodes excludes rows for existing aircraft', () {
    final content = csv([
      header,
      [
        '2026-03-01',
        '125',
        '',
        'KHOU',
        '08:00',
        'KDAL',
        '10:00',
        '0200',
        'N123SW',
        '73W',
        '1',
        '1',
        '',
      ],
      [
        '2026-03-02',
        '126',
        '',
        'KHOU',
        '08:00',
        'KDAL',
        '10:00',
        '0200',
        'N124SW',
        '73H',
        '1',
        '1',
        '',
      ],
    ]);

    final uniqueTypes = parser.extractUniqueRawTypeCodes(
      content,
      existingAircraftRegistrations: const <String>{'n123sw'},
    );

    expect(uniqueTypes, equals(const <String>{'73H'}));
  });

  test('inferTypeMappingsFromExistingAircraft infers unambiguous mappings', () {
    final content = csv([
      header,
      [
        '2026-03-01',
        '125',
        '',
        'KHOU',
        '08:00',
        'KDAL',
        '10:00',
        '0200',
        'N123SW',
        '73W',
        '1',
        '1',
        '',
      ],
      [
        '2026-03-02',
        '126',
        '',
        'KHOU',
        '08:00',
        'KDAL',
        '10:00',
        '0200',
        'N124SW',
        '73W',
        '1',
        '1',
        '',
      ],
      [
        '2026-03-03',
        '127',
        '',
        'KHOU',
        '08:00',
        'KDAL',
        '10:00',
        '0200',
        'N125SW',
        '73G',
        '1',
        '1',
        '',
      ],
    ]);

    final inferred = parser.inferTypeMappingsFromExistingAircraft(
      content,
      existingAircraftTypeCodesByRegistration: const <String, String>{
        'N123SW': 'B737-700',
        'N124SW': 'B737-700',
        'N125SW': 'B737-800',
      },
    );

    expect(
      inferred,
      equals(const <String, String>{'73W': 'B737-700', '73G': 'B737-800'}),
    );
  });

  test(
    'collectAircraftRegistrationsByRawType returns new-aircraft usage groups',
    () {
      final content = csv([
        header,
        [
          '2026-03-01',
          '125',
          '',
          'KHOU',
          '08:00',
          'KDAL',
          '10:00',
          '0200',
          'N123SW',
          '73W',
          '1',
          '1',
          '',
        ],
        [
          '2026-03-02',
          '126',
          '',
          'KHOU',
          '08:00',
          'KDAL',
          '10:00',
          '0200',
          'N124SW',
          '73W',
          '1',
          '1',
          '',
        ],
        [
          '2026-03-03',
          '127',
          '',
          'KHOU',
          '08:00',
          'KDAL',
          '10:00',
          '0200',
          'N125SW',
          '73G',
          '1',
          '1',
          '',
        ],
      ]);

      final grouped = parser.collectAircraftRegistrationsByRawType(
        content,
        existingAircraftRegistrations: const <String>{'N123SW'},
      );

      expect(grouped['73W'], equals(const <String>['N124SW']));
      expect(grouped['73G'], equals(const <String>['N125SW']));
    },
  );

  test('parse converts overnight DST-transition row from Central to UTC', () {
    final content = csv([
      header,
      [
        '2026-03-08',
        'WN302',
        '',
        'KDEN',
        '20:24',
        'KMCO',
        '0:01',
        '337',
        'N8307K',
        '737-7R8',
        '',
        '',
        'CA  DEAN TOM [55856]',
      ],
    ]);

    final batch = parser.parse(content);
    final flight = batch.records.single as NormalizedFlightRecord;

    expect(flight.departureDateTime, DateTime.utc(2026, 3, 9, 1, 24));
    expect(flight.arrivalDateTime, DateTime.utc(2026, 3, 9, 5, 1));
    expect(flight.timeBlockMinutes, 217);
    expect(flight.timeTotalBlockMinutes, 217);
  });
}
