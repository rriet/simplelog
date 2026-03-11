import 'package:flutter_test/flutter_test.dart';
import 'package:simplelog/data/import/logten_pro_import_models.dart';
import 'package:simplelog/data/import/normalized_import_models.dart';
import 'package:simplelog/data/import/source_parsers/logten_pro_tsv_source_parser.dart';

void main() {
  const parser = LogTenProTsvSourceParser();
  const header = <String>[
    'flight_flightDate',
    'flight_from',
    'flight_to',
    'flight_totalTime',
    'aircraft_aircraftID',
    'aircraftType_type',
  ];

  LogTenImportOptions optionsForHeader(List<String> columns) {
    return LogTenImportOptions(
      assignments: buildDefaultLogTenAssignments(columns),
    );
  }

  String tsv(List<List<String>> rows) {
    return rows.map((row) => row.join('\t')).join('\n');
  }

  NormalizedFlightRecord firstFlightRecord(String content) {
    final result = parser.parse(
      content,
      options: optionsForHeader(header),
      existingAirportsByIcao: const {},
      existingAirportsByIata: const {},
    );
    expect(result.issues, isEmpty);
    expect(result.batch.records, hasLength(1));
    return result.batch.records.first as NormalizedFlightRecord;
  }

  test('parses HH:MM durations from LogTen TSV', () {
    final content = tsv([
      header,
      ['2026-03-01', 'KMIA', 'KFLL', '1:30', 'N123AB', 'B738'],
    ]);

    final record = firstFlightRecord(content);

    expect(record.timeBlockMinutes, 90);
    expect(record.timeTotalBlockMinutes, 90);
    expect(record.departureAirport.icao, 'KMIA');
    expect(record.arrivalAirport.icao, 'KFLL');
  });

  test('parses decimal durations from LogTen TSV', () {
    final content = tsv([
      header,
      ['2026-03-01', 'KMIA', 'KFLL', '1.5', 'N123AB', 'B738'],
    ]);

    final record = firstFlightRecord(content);

    expect(record.timeBlockMinutes, 90);
    expect(record.timeTotalBlockMinutes, 90);
  });

  test('accepts mixed HH:MM and decimal durations in same file', () {
    final content = tsv([
      header,
      ['2026-03-01', 'KMIA', 'KFLL', '1:15', 'N123AB', 'B738'],
      ['2026-03-02', 'KFLL', 'KMIA', '1.5', 'N123AB', 'B738'],
    ]);

    final result = parser.parse(
      content,
      options: optionsForHeader(header),
      existingAirportsByIcao: const {},
      existingAirportsByIata: const {},
    );

    expect(result.issues, isEmpty);
    expect(result.batch.records, hasLength(2));
    expect(
      (result.batch.records[0] as NormalizedFlightRecord).timeBlockMinutes,
      75,
    );
    expect(
      (result.batch.records[1] as NormalizedFlightRecord).timeBlockMinutes,
      90,
    );
  });
}
