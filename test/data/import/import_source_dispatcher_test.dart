import 'package:flutter_test/flutter_test.dart';
import 'package:simplelog/data/import/import_source_dispatcher.dart';
import 'package:simplelog/data/import/simplelog_csv_support.dart';

void main() {
  const dispatcher = ImportSourceDispatcher();

  String quotedCsvHeader(List<String> fields) {
    return fields.map((field) => '"$field"').join(',');
  }

  test('detectCsv identifies legacy SimpleLog header', () {
    const content = '${SimpleLogCsvSupport.simpleLogOldHeader}\n';

    final result = dispatcher.detectCsv(content);

    expect(result, ImportSourceKind.legacySimpleLogCsv);
  });

  test('detectCsv accepts legacy SimpleLog header with extra columns', () {
    final legacyHeaderFields = SimpleLogCsvSupport.parseCsv(
      SimpleLogCsvSupport.simpleLogOldHeader,
    ).single;
    final headerWithExtraColumn = List<String>.from(legacyHeaderFields);
    final nightMinutesIndex = headerWithExtraColumn.indexOf('Night Minutes');
    headerWithExtraColumn.insert(
      nightMinutesIndex + 1,
      'Simulated Instrument Minutes',
    );
    final content = '${quotedCsvHeader(headerWithExtraColumn)}\n';

    final result = dispatcher.detectCsv(content);

    expect(result, ImportSourceKind.legacySimpleLogCsv);
  });

  test('detectCsv returns unknown for non-legacy csv', () {
    const content = '"A","B","C"\n"1","2","3"\n';

    final result = dispatcher.detectCsv(content);

    expect(result, ImportSourceKind.unknown);
  });

  test('detect returns unknown for sqlite extension without known content', () {
    final result = dispatcher.detect(fileName: 'backup.sqlite');

    expect(result, ImportSourceKind.unknown);
  });

  test('detectCsv identifies Wader CSV header', () {
    const content =
        'isPreviousExperience,isSimulator,flightDate,startTime,'
        'depAirport,arrAirport,aircraftTailnumber,aircraftType,totalTime\n'
        'false,false,2024-01-01,10:00,KJFK,KLAX,N12345,B738,320\n';

    final result = dispatcher.detectCsv(content);

    expect(result, ImportSourceKind.waderLogbookCsv);
  });

  test('detectCsv identifies Pro Flight Logbook CSV header', () {
    const content =
        'DATE,AIRCRAFT MAKE & MODEL, AIRCRAFT IDENT, ROUTE OF FLIGHT, '
        'DURATION,REMARKS\n'
        '9/15/1987,PA-38,N91392,EDAR EDAR,1.1,Training\n';

    expect(dispatcher.detectCsv(content), ImportSourceKind.proFlightLogbookCsv);
  });
}
