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
}
