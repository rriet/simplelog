import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:simplelog/data/models/report_pdf_models.dart';

class ReportPdfTemplateLoader {
  static const _indexAssetPath = 'assets/reports/templates/index.json';

  Future<List<ReportPdfTemplate>> load() async {
    final indexRaw = await rootBundle.loadString(_indexAssetPath);
    final indexJson = jsonDecode(indexRaw);
    if (indexJson is! Map<String, dynamic>) {
      throw const FormatException('Invalid templates index format.');
    }
    final templateRefs = indexJson['templates'];
    if (templateRefs is! List) {
      throw const FormatException('Missing templates list.');
    }

    final templates = <ReportPdfTemplate>[];
    for (final item in templateRefs) {
      if (item is! Map) continue;
      final fileName = (item['fileName'] ?? '').toString().trim();
      if (fileName.isEmpty) continue;
      templates.add(await _loadTemplate(fileName));
    }
    return templates;
  }

  Future<ReportPdfTemplate> _loadTemplate(String fileName) async {
    final raw = await rootBundle.loadString('assets/reports/templates/$fileName.json');
    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic>) {
      throw FormatException('Template $fileName is invalid.');
    }

    final rowsPerPage = (json['rowsPerPage'] as num?)?.toInt() ?? 26;
    final defaultPageSize = _parsePageSize(json['defaultPageSize']?.toString());
    final tablesJson = json['tables'];
    if (tablesJson is! List) {
      throw FormatException('Template $fileName has no tables.');
    }

    return ReportPdfTemplate(
      fileName: fileName,
      displayName: (json['displayName'] ?? fileName).toString(),
      rowsPerPage: rowsPerPage <= 0 ? 26 : rowsPerPage,
      forceLandscape: json['forceLandscape'] == true,
      defaultPageSize: defaultPageSize,
      labels: _parseLabels(json['labels']),
      tables: tablesJson
          .whereType<Map>()
          .map((item) => _parseTable(Map<String, dynamic>.from(item)))
          .toList(growable: false),
    );
  }

  ReportPdfLabels _parseLabels(Object? raw) {
    if (raw is! Map) return const ReportPdfLabels();
    final json = Map<String, dynamic>.from(raw);
    return ReportPdfLabels(
      pageTotal: (json['pageTotal'] ?? 'PAGE TOTAL').toString(),
      amountForward: (json['amountForward'] ?? 'AMT. FORWARD').toString(),
      totalToDate: (json['totalToDate'] ?? 'TOTAL TO DATE').toString(),
    );
  }

  ReportPdfTableConfig _parseTable(Map<String, dynamic> json) {
    final columnsRaw = json['columns'];
    if (columnsRaw is! List || columnsRaw.isEmpty) {
      throw const FormatException('Template table requires columns.');
    }

    final footerRaw = json['footerRows'];
    return ReportPdfTableConfig(
      pageSuffix: (json['pageSuffix'] ?? '').toString(),
      columns: columnsRaw
          .whereType<Map>()
          .map((item) => _parseColumn(Map<String, dynamic>.from(item)))
          .toList(growable: false),
      footerRows: footerRaw is List
          ? footerRaw
              .whereType<Map>()
              .map((item) => _parseFooterRow(Map<String, dynamic>.from(item)))
              .toList(growable: false)
          : const [],
    );
  }

  ReportPdfColumnConfig _parseColumn(Map<String, dynamic> json) {
    final key = (json['key'] ?? '').toString().trim();
    if (key.isEmpty) {
      throw const FormatException('Template column key is required.');
    }
    return ReportPdfColumnConfig(
      key: key,
      header: (json['header'] ?? key).toString(),
      width: (json['width'] as num?)?.toDouble() ?? 1,
      alignment: _parseAlignment(json['alignment']?.toString()),
    );
  }

  ReportPdfFooterRowConfig _parseFooterRow(Map<String, dynamic> json) {
    final sourceRaw = (json['source'] ?? '').toString();
    final source = _parseSummarySource(sourceRaw);
    final valuesRaw = json['values'];
    final values = <String, String>{};
    if (valuesRaw is Map) {
      for (final entry in valuesRaw.entries) {
        values[entry.key.toString()] = entry.value.toString();
      }
    }
    return ReportPdfFooterRowConfig(
      source: source,
      labelToken: json['labelToken']?.toString(),
      literalLabel: json['literalLabel']?.toString(),
      showTopBorder: json['showTopBorder'] == true,
      values: values,
    );
  }

  ReportPdfSummarySource _parseSummarySource(String raw) {
    switch (raw) {
      case 'pageTotals':
        return ReportPdfSummarySource.pageTotals;
      case 'totalsBefore':
        return ReportPdfSummarySource.totalsBefore;
      case 'totalsAfter':
        return ReportPdfSummarySource.totalsAfter;
      default:
        throw FormatException('Unsupported footer source: $raw');
    }
  }

  ReportPdfColumnAlignment _parseAlignment(String? raw) {
    switch (raw) {
      case 'left':
        return ReportPdfColumnAlignment.left;
      case 'right':
        return ReportPdfColumnAlignment.right;
      default:
        return ReportPdfColumnAlignment.center;
    }
  }

  ReportPdfPageSize _parsePageSize(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'a4':
        return ReportPdfPageSize.a4;
      case 'legal':
        return ReportPdfPageSize.legal;
      case 'a5':
        return ReportPdfPageSize.a5;
      default:
        return ReportPdfPageSize.letter;
    }
  }
}

class ReportXslTemplateLoader extends ReportPdfTemplateLoader {}
