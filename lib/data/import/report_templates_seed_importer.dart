import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:simplelog/data/database/app_database.dart';

/// Seeds default report templates from bundled assets into the local database.
class ReportTemplatesSeedImporter {
  /// Creates a templates seed importer.
  const ReportTemplatesSeedImporter();

  static const _indexAssetPath = 'assets/reports/templates/index.json';

  /// Imports default templates when the templates table is empty.
  Future<int> importIfEmpty(AppDatabase db) async {
    await _ensureCompatibleTable(db);
    final existing = await _count(db);
    if (existing > 0) {
      return 0;
    }

    final indexRaw = await rootBundle.loadString(_indexAssetPath);
    final indexJson = jsonDecode(indexRaw);
    if (indexJson is! Map<String, dynamic>) {
      return 0;
    }
    final refs = indexJson['templates'];
    if (refs is! List) {
      return 0;
    }

    var inserted = 0;
    for (final item in refs) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      final templateKey = (item['fileName'] ?? '').toString().trim();
      if (templateKey.isEmpty) {
        continue;
      }
      final templateName = _initialTemplateNameFromKey(templateKey);
      final jsonAssetPath = 'assets/reports/templates/$templateKey.json';
      final templateJson = await rootBundle.loadString(jsonAssetPath);
      final normalizedJson = _normalizeTemplateJson(
        templateJson: templateJson,
        templateName: templateName,
      );
      await db
          .into(db.reportTemplates)
          .insertOnConflictUpdate(
            ReportTemplatesCompanion.insert(
              templateName: templateName,
              templateJson: normalizedJson,
            ),
          );
      inserted++;
    }
    return inserted;
  }

  Future<int> _count(AppDatabase db) async {
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM report_templates',
        )
        .getSingle();
    return row.read<int>('c');
  }

  Future<void> _ensureCompatibleTable(AppDatabase db) async {
    final columns = await db
        .customSelect(
          'PRAGMA table_info(report_templates)',
        )
        .get();
    if (columns.isEmpty) {
      await db.customStatement('''
        CREATE TABLE IF NOT EXISTS report_templates (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          template_name TEXT NOT NULL UNIQUE,
          template_json TEXT NOT NULL
        )
      ''');
      return;
    }

    final columnNames = columns.map((row) => row.read<String>('name')).toSet();
    if (columnNames.contains('template_name')) {
      return;
    }

    final sourceNameColumn = columnNames.contains('report_name')
        ? 'report_name'
        : 'file_name';
    final legacyRows = await db
        .customSelect(
          'SELECT $sourceNameColumn, template_json FROM report_templates',
        )
        .get();
    await db.customStatement('DROP TABLE report_templates');
    await db.customStatement('''
      CREATE TABLE report_templates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        template_name TEXT NOT NULL UNIQUE,
        template_json TEXT NOT NULL
      )
    ''');
    for (final row in legacyRows) {
      final templateName = row.read<String>(sourceNameColumn).trim();
      final templateJson = row.read<String>('template_json');
      if (templateName.isEmpty || templateJson.trim().isEmpty) {
        continue;
      }
      final normalizedJson = _normalizeTemplateJson(
        templateJson: templateJson,
        templateName: templateName,
      );
      await db.customStatement(
        '''
        INSERT OR IGNORE INTO report_templates (template_name, template_json)
        VALUES (?, ?)
        ''',
        [templateName, normalizedJson],
      );
    }
  }

  String _normalizeTemplateJson({
    required String templateJson,
    required String templateName,
  }) {
    try {
      final decoded = jsonDecode(templateJson);
      if (decoded is! Map<String, dynamic>) {
        return templateJson;
      }
      decoded['templateName'] = templateName;
      decoded
        ..putIfAbsent('dateFormat', () => 'dd-MM-yyyy')
        ..putIfAbsent('timeFormat', () => 'H:mm')
        ..remove('reportName')
        ..remove('displayName');
      return jsonEncode(decoded);
    } on Object {
      return templateJson;
    }
  }

  String _initialTemplateNameFromKey(String key) {
    final lower = key.toLowerCase();
    if (lower == 'easa') {
      return 'EASA';
    }
    if (lower == 'standard') {
      return 'Standard';
    }
    if (key.isEmpty) {
      return key;
    }
    return key[0].toUpperCase() + key.substring(1);
  }
}
