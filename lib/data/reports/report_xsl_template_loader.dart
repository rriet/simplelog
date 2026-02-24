import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:simplelog/data/models/report_pdf_models.dart';

/// Public API documentation.
class ReportPdfTemplateLoader {
  static const _indexAssetPath = 'assets/reports/templates/index.json';

  /// Public API documentation.

  /// Public API documentation.
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
      if (item is! Map<String, dynamic>) continue;
      final fileName = (item['fileName'] ?? '').toString().trim();
      if (fileName.isEmpty) continue;
      templates.add(await _loadTemplate(fileName));
    }
    return templates;
  }

  Future<ReportPdfTemplate> _loadTemplate(String fileName) async {
    final raw = await rootBundle.loadString(
      'assets/reports/templates/$fileName.json',
    );
    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic>) {
      throw FormatException('Template $fileName is invalid.');
    }

    final rowsPerPage = (json['rowsPerPage'] as num?)?.toInt() ?? 26;
    final defaultPageSize = _parsePageSize(json['defaultPageSize']?.toString());
    final rowHeight = (json['rowHeight'] as num?)?.toDouble() ?? 11;
    final tablesJson = json['tables'];
    if (tablesJson is! List) {
      throw FormatException('Template $fileName has no tables.');
    }

    return ReportPdfTemplate(
      fileName: fileName,
      displayName: (json['displayName'] ?? fileName).toString(),
      rowsPerPage: rowsPerPage <= 0 ? 26 : rowsPerPage,
      coverPage: _parseCoverPage(json['coverPage']),
      forceLandscape: json['forceLandscape'] == true,
      defaultPageSize: defaultPageSize,
      rowHeight: rowHeight <= 0 ? 11 : rowHeight,
      labels: _parseLabels(json['labels']),
      tables: tablesJson
          .whereType<Map<String, dynamic>>()
          .map(_parseTable)
          .toList(growable: false),
    );
  }

  ReportPdfCoverPageConfig? _parseCoverPage(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      return null;
    }
    final blocksRaw = raw['blocks'];
    final blocks = blocksRaw is List
        ? blocksRaw
              .whereType<Map<String, dynamic>>()
              .map(_parseCoverBlock)
              .toList(growable: false)
        : const <ReportPdfCoverBlockConfig>[];
    return ReportPdfCoverPageConfig(
      enabled: raw['enabled'] == true,
      title: (raw['title'] ?? '').toString(),
      blocks: blocks,
    );
  }

  ReportPdfCoverBlockConfig _parseCoverBlock(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    final items = itemsRaw is List
        ? itemsRaw
              .whereType<Map<String, dynamic>>()
              .map(
                (item) => ReportPdfCoverItemConfig(
                  label: (item['label'] ?? '').toString(),
                  valueKey: (item['valueKey'] ?? '').toString(),
                  x: (item['x'] as num?)?.toDouble(),
                  y: (item['y'] as num?)?.toDouble(),
                  width: (item['width'] as num?)?.toDouble(),
                  height: (item['height'] as num?)?.toDouble(),
                ),
              )
              .toList(growable: false)
        : const <ReportPdfCoverItemConfig>[];
    return ReportPdfCoverBlockConfig(
      type: _parseCoverBlockType(json['type']?.toString()),
      title: (json['title'] ?? '').toString(),
      columns: (json['columns'] as num?)?.toInt() ?? 1,
      items: items,
      valueKey: json['valueKey']?.toString(),
    );
  }

  ReportPdfCoverBlockType _parseCoverBlockType(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'multiline':
        return ReportPdfCoverBlockType.multiline;
      case 'kvgrid':
      default:
        return ReportPdfCoverBlockType.kvGrid;
    }
  }

  ReportPdfLabels _parseLabels(Object? raw) {
    if (raw is! Map<String, dynamic>) return const ReportPdfLabels();
    final json = raw;
    return ReportPdfLabels(
      pageTotal: (json['pageTotal'] ?? 'PAGE TOTAL').toString(),
      amountForward: (json['amountForward'] ?? 'AMT. FORWARD').toString(),
      totalToDate: (json['totalToDate'] ?? 'TOTAL TO DATE').toString(),
    );
  }

  ReportPdfTableConfig _parseTable(Map<String, dynamic> json) {
    final headerRows = _parseHeaderRows(json['header']);
    final columnsRaw = json['columns'];
    if (columnsRaw is! List || columnsRaw.isEmpty) {
      throw const FormatException('Template table requires columns.');
    }

    final footerRaw = json['footerRows'];
    return ReportPdfTableConfig(
      pageSuffix: (json['pageSuffix'] ?? '').toString(),
      header: headerRows,
      footer: _parseHeaderRows(json['footer']),
      columns: columnsRaw
          .whereType<Map<String, dynamic>>()
          .map(_parseColumn)
          .toList(growable: false),
      footerRows: footerRaw is List
          ? footerRaw
                .whereType<Map<String, dynamic>>()
                .map(_parseFooterRow)
                .toList(growable: false)
          : const [],
    );
  }

  ReportPdfColumnConfig _parseColumn(Map<String, dynamic> json) {
    final key = (json['key'] ?? '').toString().trim();
    if (key.isEmpty) {
      throw const FormatException('Template column key is required.');
    }
    final alignment = _parseCellAlignment(
      single: json['align']?.toString() ?? json['alignment']?.toString(),
      horizontal: json['halign']?.toString(),
    );
    final verticalAlignment = _parseVerticalAlignment(
      single: json['align']?.toString(),
      vertical: json['valign']?.toString(),
    );
    return ReportPdfColumnConfig(
      key: key,
      header: json['header']?.toString(),
      width: (json['width'] as num?)?.toDouble() ?? 1,
      alignment: alignment,
      verticalAlignment: verticalAlignment,
      textStyle: _parseTextStyle(json),
    );
  }

  ReportPdfFooterRowConfig _parseFooterRow(Map<String, dynamic> json) {
    final sourceRaw = (json['source'] ?? '').toString();
    final source = _parseSummarySource(sourceRaw);
    final valuesRaw = json['values'];
    final values = <String, String>{};
    if (valuesRaw is Map<String, dynamic>) {
      for (final entry in valuesRaw.entries) {
        values[entry.key] = entry.value.toString();
      }
    }
    return ReportPdfFooterRowConfig(
      source: source,
      labelToken: json['labelToken']?.toString(),
      literalLabel: json['literalLabel']?.toString(),
      showTopBorder: json['showTopBorder'] == true,
      values: values,
      cells: _parseCells(json['cells']),
      rowHeight: (json['rowHeight'] as num?)?.toDouble(),
    );
  }

  List<ReportPdfHeaderRowConfig> _parseHeaderRows(Object? raw) {
    if (raw is! List) {
      return const [];
    }
    final rows = <ReportPdfHeaderRowConfig>[];
    for (final entry in raw) {
      if (entry is List) {
        rows.add(
          ReportPdfHeaderRowConfig(cells: _parseCells(entry)),
        );
        continue;
      }
      if (entry is Map<String, dynamic>) {
        final cellsRaw = entry['cells'];
        final rowHeight = (entry['rowHeight'] as num?)?.toDouble();
        rows.add(
          ReportPdfHeaderRowConfig(
            cells: cellsRaw is List
                ? _parseCells(cellsRaw)
                : _parseCells([entry]),
            rowHeight: rowHeight,
          ),
        );
      }
    }
    return rows;
  }

  List<ReportPdfCellConfig> _parseCells(Object? raw) {
    if (raw is! List) {
      return const [];
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map(_parseCell)
        .toList(growable: false);
  }

  ReportPdfCellConfig _parseCell(Map<String, dynamic> json) {
    final alignment = _parseCellAlignment(
      single: json['align']?.toString() ?? json['alignment']?.toString(),
      horizontal: json['halign']?.toString(),
    );
    final verticalAlignment = _parseVerticalAlignment(
      single: json['align']?.toString(),
      vertical: json['valign']?.toString(),
    );
    return ReportPdfCellConfig(
      text: json['text']?.toString(),
      valueToken: json['valueToken']?.toString() ?? json['key']?.toString(),
      hspan: (json['hspan'] as num?)?.toInt() ?? 1,
      vspan: (json['vspan'] as num?)?.toInt() ?? 1,
      alignment: alignment,
      verticalAlignment: verticalAlignment,
      textStyle: _parseTextStyle(json),
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
        return ReportPdfSummarySource.pageTotals;
    }
  }

  ReportPdfColumnAlignment _parseCellAlignment({
    required String? single,
    required String? horizontal,
  }) {
    final normalizedSingle = (single ?? '').toLowerCase();
    if (normalizedSingle.contains('left')) {
      return ReportPdfColumnAlignment.left;
    }
    if (normalizedSingle.contains('right')) {
      return ReportPdfColumnAlignment.right;
    }
    switch ((horizontal ?? '').toLowerCase()) {
      case 'left':
        return ReportPdfColumnAlignment.left;
      case 'right':
        return ReportPdfColumnAlignment.right;
      default:
        return ReportPdfColumnAlignment.center;
    }
  }

  ReportPdfVerticalAlignment _parseVerticalAlignment({
    required String? single,
    required String? vertical,
  }) {
    final normalizedSingle = (single ?? '').toLowerCase();
    if (normalizedSingle.contains('top')) {
      return ReportPdfVerticalAlignment.top;
    }
    if (normalizedSingle.contains('bottom')) {
      return ReportPdfVerticalAlignment.bottom;
    }
    switch ((vertical ?? '').toLowerCase()) {
      case 'top':
        return ReportPdfVerticalAlignment.top;
      case 'bottom':
        return ReportPdfVerticalAlignment.bottom;
      default:
        return ReportPdfVerticalAlignment.middle;
    }
  }

  ReportPdfCellTextStyle _parseTextStyle(Map<String, dynamic> json) {
    final fontSize = (json['fontSize'] as num?)?.toDouble();
    final weightRaw = json['weight']?.toString().toLowerCase();
    return ReportPdfCellTextStyle(
      fontSize: fontSize,
      bold: weightRaw == 'bold' || json['bold'] == true,
      italic: weightRaw == 'italic' || json['italic'] == true,
      colorHex: json['color']?.toString(),
    );
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

  /// Public API documentation.
}

/// Public API documentation.
class ReportXslTemplateLoader extends ReportPdfTemplateLoader {}
