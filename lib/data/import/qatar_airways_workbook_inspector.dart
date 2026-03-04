import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

/// One worksheet row extracted from the Qatar Airways workbook.
class QatarAirwaysWorkbookRow {
  /// Creates a workbook row.
  const QatarAirwaysWorkbookRow({
    required this.rowNumber,
    required this.valuesByColumn,
  });

  /// Original 1-based worksheet row number.
  final int rowNumber;

  /// Cell values keyed by flattened column name.
  final Map<String, String> valuesByColumn;

  /// Reads a value from a flattened column name.
  String read(String column) => valuesByColumn[column] ?? '';
}

/// Flattened workbook metadata extracted from a Qatar Airways logbook export.
class QatarAirwaysWorkbookInspection {
  /// Creates an inspection result for a recognized workbook.
  const QatarAirwaysWorkbookInspection({
    required this.sheetName,
    required this.columns,
    required this.rows,
  });

  /// Worksheet name used by the imported workbook.
  final String sheetName;

  /// Flattened column names in sheet order.
  final List<String> columns;

  /// Worksheet data rows after the two-line header.
  final List<QatarAirwaysWorkbookRow> rows;
}

/// Reads the first worksheet of a Qatar Airways workbook and extracts headers.
class QatarAirwaysWorkbookInspector {
  /// Creates a workbook inspector.
  const QatarAirwaysWorkbookInspector();

  static const _sheetNs =
      'http://schemas.openxmlformats.org/spreadsheetml/2006/main';
  static const _relNs =
      'http://schemas.openxmlformats.org/officeDocument/2006/relationships';
  static const _pkgRelNs =
      'http://schemas.openxmlformats.org/package/2006/relationships';

  /// Returns workbook metadata when [bytes] match the Qatar Airways template.
  ///
  /// Returns `null` when the workbook is not recognized or cannot be parsed.
  QatarAirwaysWorkbookInspection? inspect(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes, verify: true);
      final files = <String, ArchiveFile>{
        for (final file in archive)
          if (file.isFile) file.name: file,
      };
      final workbookFile = files['xl/workbook.xml'];
      final relsFile = files['xl/_rels/workbook.xml.rels'];
      if (workbookFile == null || relsFile == null) return null;

      final workbook = XmlDocument.parse(_readUtf8(workbookFile));
      final relationships = XmlDocument.parse(_readUtf8(relsFile));
      final sheet = workbook
          .findAllElements('sheet', namespace: _sheetNs)
          .firstOrNull;
      if (sheet == null) return null;

      final relationshipId = sheet.getAttribute('id', namespace: _relNs);
      if (relationshipId == null || relationshipId.isEmpty) return null;

      final relationship = relationships
          .findAllElements('Relationship', namespace: _pkgRelNs)
          .where((element) => element.getAttribute('Id') == relationshipId)
          .firstOrNull;
      if (relationship == null) return null;

      final target = relationship.getAttribute('Target');
      if (target == null || target.isEmpty) return null;

      final normalizedTarget = target.startsWith('/')
          ? target.substring(1)
          : 'xl/$target';
      final worksheetFile = files[normalizedTarget];
      if (worksheetFile == null) return null;

      final sharedStrings = _readSharedStrings(files['xl/sharedStrings.xml']);
      final worksheet = XmlDocument.parse(_readUtf8(worksheetFile));
      final rowsByIndex = _readRows(worksheet, sharedStrings);
      final columns = _flattenColumns(
        primaryHeader: rowsByIndex[3] ?? const {},
        secondaryHeader: rowsByIndex[4] ?? const {},
      );
      if (!_matchesQatarHeaders(columns)) return null;

      final rows = _buildWorkbookRows(rowsByIndex, columns);
      return QatarAirwaysWorkbookInspection(
        sheetName: sheet.getAttribute('name') ?? 'Sheet1',
        columns: columns,
        rows: rows,
      );
    } on ArchiveException {
      return null;
    } on XmlException {
      return null;
    } on FormatException {
      return null;
    }
  }

  String _readUtf8(ArchiveFile file) {
    final bytes = file.readBytes();
    if (bytes == null) {
      throw const FormatException('Archive file is empty.');
    }
    return utf8.decode(bytes);
  }

  List<String> _readSharedStrings(ArchiveFile? file) {
    if (file == null) return const [];
    final document = XmlDocument.parse(_readUtf8(file));
    return document
        .findAllElements('si', namespace: _sheetNs)
        .map(_sharedStringValue)
        .toList(growable: false);
  }

  Map<int, Map<int, String>> _readRows(
    XmlDocument worksheet,
    List<String> sharedStrings,
  ) {
    final rows = <int, Map<int, String>>{};
    for (final row in worksheet.findAllElements('row', namespace: _sheetNs)) {
      final rowNumber = int.tryParse(row.getAttribute('r') ?? '');
      if (rowNumber == null) continue;
      final values = <int, String>{};
      for (final cell in row.findElements('c', namespace: _sheetNs)) {
        final reference = cell.getAttribute('r');
        if (reference == null || reference.isEmpty) continue;
        final columnIndex = _columnIndexFromReference(reference);
        if (columnIndex == null) continue;
        values[columnIndex] = _cellValue(cell, sharedStrings);
      }
      rows[rowNumber] = values;
    }
    return rows;
  }

  List<QatarAirwaysWorkbookRow> _buildWorkbookRows(
    Map<int, Map<int, String>> rowsByIndex,
    List<String> columns,
  ) {
    final rows = <QatarAirwaysWorkbookRow>[];
    final dataRows = rowsByIndex.entries.toList()
      ..sort((left, right) => left.key.compareTo(right.key));

    for (final entry in dataRows) {
      if (entry.key <= 4) continue;
      final valuesByColumn = <String, String>{};
      for (var index = 0; index < columns.length; index++) {
        valuesByColumn[columns[index]] = entry.value[index] ?? '';
      }
      final hasData = valuesByColumn.values.any(
        (value) => value.trim().isNotEmpty,
      );
      if (!hasData) continue;
      rows.add(
        QatarAirwaysWorkbookRow(
          rowNumber: entry.key,
          valuesByColumn: valuesByColumn,
        ),
      );
    }
    return rows;
  }

  List<String> _flattenColumns({
    required Map<int, String> primaryHeader,
    required Map<int, String> secondaryHeader,
  }) {
    final maxIndex = [
      ...primaryHeader.keys,
      ...secondaryHeader.keys,
    ].fold<int>(-1, (current, value) => value > current ? value : current);
    if (maxIndex < 0) return const [];

    final columns = <String>[];
    var currentPrimaryGroup = '';
    for (var index = 0; index <= maxIndex; index++) {
      final primary = _normalizeHeaderLabel(primaryHeader[index] ?? '');
      final secondary = _normalizeHeaderLabel(secondaryHeader[index] ?? '');
      if (primary.isNotEmpty) {
        currentPrimaryGroup = primary;
      }
      if (primary.isEmpty && secondary.isEmpty) {
        continue;
      }
      if (primary.isEmpty) {
        if (currentPrimaryGroup.isEmpty) {
          columns.add(secondary);
          continue;
        }
        columns.add('$currentPrimaryGroup $secondary');
        continue;
      }
      if (secondary.isEmpty || secondary == primary) {
        columns.add(primary);
        continue;
      }
      columns.add('$primary $secondary');
    }
    return columns;
  }

  String _sharedStringValue(XmlElement element) {
    return element
        .findAllElements('t', namespace: _sheetNs)
        .map((text) => text.innerText)
        .join();
  }

  String _cellValue(XmlElement cell, List<String> sharedStrings) {
    final type = cell.getAttribute('t');
    if (type == 'inlineStr') {
      final inline = cell.findElements('is', namespace: _sheetNs).firstOrNull;
      if (inline == null) return '';
      return _normalizeCellValue(
        inline
            .findAllElements('t', namespace: _sheetNs)
            .map((text) => text.innerText)
            .join(),
      );
    }

    final rawValue = cell.findElements('v', namespace: _sheetNs).firstOrNull;
    if (rawValue == null) return '';
    final text = rawValue.innerText;
    if (type == 's') {
      final sharedIndex = int.tryParse(text);
      if (sharedIndex == null ||
          sharedIndex < 0 ||
          sharedIndex >= sharedStrings.length) {
        return '';
      }
      return _normalizeCellValue(sharedStrings[sharedIndex]);
    }
    return _normalizeCellValue(text);
  }

  int? _columnIndexFromReference(String reference) {
    final letters = reference.replaceAll(RegExp('[^A-Z]'), '');
    if (letters.isEmpty) return null;
    var value = 0;
    for (final codeUnit in letters.codeUnits) {
      value = (value * 26) + (codeUnit - 64);
    }
    return value - 1;
  }

  String _normalizeHeaderLabel(String value) {
    return value.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _normalizeCellValue(String value) {
    return value.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
  }

  bool _matchesQatarHeaders(List<String> columns) {
    const requiredColumns = <String>{
      'DATE (dd/mm/yy)',
      'DEPARTURE PLACE',
      'ARRIVAL PLACE',
      'AIRCRAFT TYPE',
      'AIRCRAFT REG',
      'TOTAL TIME OF FLIGHT',
      'NAME(S) PIC',
      'REMARKS AND ENDORSEMENTS',
      'FSTD SESSION TYPE',
      'FSTD SESSION TOTAL TIME',
    };
    final available = columns.toSet();
    return requiredColumns.every(available.contains);
  }
}
