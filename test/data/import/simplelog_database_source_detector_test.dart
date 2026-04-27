import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:simplelog/data/import/simplelog_database_source_detector.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  const detector = SimpleLogDatabaseSourceDetector();

  Future<Uint8List> buildSqliteBytes(List<String> statements) async {
    final tempDir = await Directory.systemTemp.createTemp(
      'simplelog_detector_test_',
    );
    final path = '${tempDir.path}${Platform.pathSeparator}source.sqlite';
    final db = sqlite.sqlite3.open(path);
    try {
      statements.forEach(db.execute);
    } finally {
      db.close();
    }

    final bytes = await File(path).readAsBytes();
    await tempDir.delete(recursive: true);
    return bytes;
  }

  test('detects current SimpleLog database schema', () async {
    const currentTables = <String>{
      'aircraft_types',
      'aircrafts',
      'airports',
      'crew',
      'duty_periods',
      'flight_crew_assignments',
      'flights',
      'limit_rules',
      'positionings',
      'previous_experiences',
      'report_templates',
      'rule_snapshots',
      'simulator_crew_assignments',
      'simulator_trainings',
      'time_lines',
      'user_profiles',
    };
    final bytes = await buildSqliteBytes(
      currentTables
          .map((table) => 'CREATE TABLE $table (id INTEGER PRIMARY KEY);')
          .toList(growable: false),
    );

    final result = await detector.inspectBytes(bytes);

    expect(result.kind, SimpleLogDatabaseSourceKind.currentSimpleLog);
    expect(result.isSqlite, isTrue);
  });

  test('detects legacy SimpleLog database schema', () async {
    const legacyTables = <String>{
      'model',
      'aircraft',
      'airport',
      'crew',
      'flight',
    };
    final bytes = await buildSqliteBytes(
      legacyTables
          .map((table) => 'CREATE TABLE $table (id INTEGER PRIMARY KEY);')
          .toList(growable: false),
    );

    final result = await detector.inspectBytes(bytes);

    expect(result.kind, SimpleLogDatabaseSourceKind.legacySimpleLog);
    expect(result.isSqlite, isTrue);
  });

  test('returns unknown for unrecognized sqlite schema', () async {
    final bytes = await buildSqliteBytes(
      const <String>['CREATE TABLE random_table (id INTEGER PRIMARY KEY);'],
    );

    final result = await detector.inspectBytes(bytes);

    expect(result.kind, SimpleLogDatabaseSourceKind.unknown);
    expect(result.isSqlite, isTrue);
  });

  test('returns unknown for non-sqlite bytes', () async {
    final result = await detector.inspectBytes(
      Uint8List.fromList(const <int>[1, 2, 3, 4]),
    );

    expect(result.kind, SimpleLogDatabaseSourceKind.unknown);
    expect(result.isSqlite, isFalse);
  });
}
