import 'dart:math' as math;
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/data/models/report_pdf_models.dart';

class ReportTemplateRow {
  const ReportTemplateRow({
    required this.date,
    required this.aircraftModel,
    required this.aircraftRegistration,
    required this.fromIcao,
    required this.toIcao,
    required this.remarks,
    required this.ifrApproaches,
    required this.landingsTotal,
    required this.selMinutes,
    required this.melMinutes,
    required this.xcMinutes,
    required this.dayMinutes,
    required this.nightMinutes,
    required this.ifrMinutes,
    required this.simInstMinutes,
    required this.fstdMinutes,
    required this.dualMinutes,
    required this.picPicusMinutes,
    required this.sicMinutes,
    required this.instructorMinutes,
    required this.totalMinutes,
  });

  final String date;
  final String aircraftModel;
  final String aircraftRegistration;
  final String fromIcao;
  final String toIcao;
  final String remarks;
  final int ifrApproaches;
  final int landingsTotal;
  final int selMinutes;
  final int melMinutes;
  final int xcMinutes;
  final int dayMinutes;
  final int nightMinutes;
  final int ifrMinutes;
  final int simInstMinutes;
  final int fstdMinutes;
  final int dualMinutes;
  final int picPicusMinutes;
  final int sicMinutes;
  final int instructorMinutes;
  final int totalMinutes;
}

class ReportTemplateTotals {
  const ReportTemplateTotals({
    this.ifrApproaches = 0,
    this.landingsTotal = 0,
    this.selMinutes = 0,
    this.melMinutes = 0,
    this.xcMinutes = 0,
    this.dayMinutes = 0,
    this.nightMinutes = 0,
    this.ifrMinutes = 0,
    this.simInstMinutes = 0,
    this.fstdMinutes = 0,
    this.dualMinutes = 0,
    this.picPicusMinutes = 0,
    this.sicMinutes = 0,
    this.instructorMinutes = 0,
    this.totalMinutes = 0,
  });

  final int ifrApproaches;
  final int landingsTotal;
  final int selMinutes;
  final int melMinutes;
  final int xcMinutes;
  final int dayMinutes;
  final int nightMinutes;
  final int ifrMinutes;
  final int simInstMinutes;
  final int fstdMinutes;
  final int dualMinutes;
  final int picPicusMinutes;
  final int sicMinutes;
  final int instructorMinutes;
  final int totalMinutes;

  ReportTemplateTotals addRow(ReportTemplateRow row) {
    return ReportTemplateTotals(
      ifrApproaches: ifrApproaches + row.ifrApproaches,
      landingsTotal: landingsTotal + row.landingsTotal,
      selMinutes: selMinutes + row.selMinutes,
      melMinutes: melMinutes + row.melMinutes,
      xcMinutes: xcMinutes + row.xcMinutes,
      dayMinutes: dayMinutes + row.dayMinutes,
      nightMinutes: nightMinutes + row.nightMinutes,
      ifrMinutes: ifrMinutes + row.ifrMinutes,
      simInstMinutes: simInstMinutes + row.simInstMinutes,
      fstdMinutes: fstdMinutes + row.fstdMinutes,
      dualMinutes: dualMinutes + row.dualMinutes,
      picPicusMinutes: picPicusMinutes + row.picPicusMinutes,
      sicMinutes: sicMinutes + row.sicMinutes,
      instructorMinutes: instructorMinutes + row.instructorMinutes,
      totalMinutes: totalMinutes + row.totalMinutes,
    );
  }

  ReportTemplateTotals addTotals(ReportTemplateTotals other) {
    return ReportTemplateTotals(
      ifrApproaches: ifrApproaches + other.ifrApproaches,
      landingsTotal: landingsTotal + other.landingsTotal,
      selMinutes: selMinutes + other.selMinutes,
      melMinutes: melMinutes + other.melMinutes,
      xcMinutes: xcMinutes + other.xcMinutes,
      dayMinutes: dayMinutes + other.dayMinutes,
      nightMinutes: nightMinutes + other.nightMinutes,
      ifrMinutes: ifrMinutes + other.ifrMinutes,
      simInstMinutes: simInstMinutes + other.simInstMinutes,
      fstdMinutes: fstdMinutes + other.fstdMinutes,
      dualMinutes: dualMinutes + other.dualMinutes,
      picPicusMinutes: picPicusMinutes + other.picPicusMinutes,
      sicMinutes: sicMinutes + other.sicMinutes,
      instructorMinutes: instructorMinutes + other.instructorMinutes,
      totalMinutes: totalMinutes + other.totalMinutes,
    );
  }
}

class ReportPdfApplicationService {
  const ReportPdfApplicationService();

  Future<Uint8List> generateFromTemplate({
    required ReportPdfTemplate template,
    required List<LogbookEntry> entries,
    required ReportPdfPageSize selectedPageSize,
    required ReportTemplateTotals startingTotals,
  }) async {
    final pageFormat = _resolvePageFormat(template, selectedPageSize);
    final rows = buildRows(entries);
    return _generatePdf(
      template: template,
      rows: rows,
      startingTotals: startingTotals,
      pageFormat: pageFormat,
    );
  }

  Future<Uint8List> _generatePdf({
    required ReportPdfTemplate template,
    required List<ReportTemplateRow> rows,
    required ReportTemplateTotals startingTotals,
    required PdfPageFormat pageFormat,
  }) async {
    final document = pw.Document();
    final rowsPerPage = template.rowsPerPage <= 0 ? 26 : template.rowsPerPage;
    final pages = <List<ReportTemplateRow>>[];
    for (var i = 0; i < rows.length; i += rowsPerPage) {
      final end = (i + rowsPerPage > rows.length) ? rows.length : i + rowsPerPage;
      pages.add(rows.sublist(i, end));
    }
    if (pages.isEmpty) {
      pages.add(const []);
    }

    var carry = startingTotals;
    for (var index = 0; index < pages.length; index++) {
      final pageRows = List<ReportTemplateRow>.from(pages[index]);
      var pageTotals = const ReportTemplateTotals();
      for (final row in pageRows) {
        pageTotals = pageTotals.addRow(row);
      }
      while (pageRows.length < rowsPerPage) {
        pageRows.add(
          const ReportTemplateRow(
            date: '',
            aircraftModel: '',
            aircraftRegistration: '',
            fromIcao: '',
            toIcao: '',
            remarks: '',
            ifrApproaches: 0,
            landingsTotal: 0,
            selMinutes: 0,
            melMinutes: 0,
            xcMinutes: 0,
            dayMinutes: 0,
            nightMinutes: 0,
            ifrMinutes: 0,
            simInstMinutes: 0,
            fstdMinutes: 0,
            dualMinutes: 0,
            picPicusMinutes: 0,
            sicMinutes: 0,
            instructorMinutes: 0,
            totalMinutes: 0,
          ),
        );
      }
      final after = carry.addTotals(pageTotals);

      final pageTotalsMap = _totalsToMap(pageTotals);
      final carryMap = _totalsToMap(carry);
      final afterMap = _totalsToMap(after);

      for (final table in template.tables) {
        document.addPage(
          pw.Page(
            pageFormat: pageFormat,
            margin: const pw.EdgeInsets.all(14),
            build: (context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      'PAGE ${index + 1} ${table.pageSuffix}'.trim(),
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  _buildTemplateTable(
                    table: table,
                    pageRows: pageRows,
                    template: template,
                    pageTotals: pageTotalsMap,
                    totalsBefore: carryMap,
                    totalsAfter: afterMap,
                  ),
                ],
              );
            },
          ),
        );
      }
      carry = after;
    }

    return document.save();
  }

  List<ReportTemplateRow> buildRows(List<LogbookEntry> entries) {
    final sortedEntries = [...entries]
      ..sort((a, b) => a.timeLine.eventDateTime.compareTo(b.timeLine.eventDateTime));
    return sortedEntries.map((entry) {
      final flight = entry.flight;
      final sim = entry.simulatorTraining;
      final pos = entry.positioning;
      final type = entry.aircraftType;

      final totalMinutes = flight?.timeBlockMinutes ?? pos?.timeTotalMinutes ?? sim?.timeTotal ?? 0;
      final nightMinutes = flight?.timeNightMinutes ?? 0;
      final dayMinutes = math.max(0, totalMinutes - nightMinutes);
      final isSeaplane = type?.category.name == 'seaplane';
      final isMultiEngine = (type?.engineCount ?? 0) > 1;
      final selMinutes = (!isSeaplane && !isMultiEngine) ? totalMinutes : 0;
      final melMinutes = (!isSeaplane && isMultiEngine) ? totalMinutes : 0;

      return ReportTemplateRow(
        date: DateFormat('dd-MM-yyyy').format(entry.timeLine.eventDateTime.toUtc()),
        aircraftModel: type?.code ?? '',
        aircraftRegistration: entry.aircraft?.registration ?? '',
        fromIcao: entry.departureAirport?.icao ?? entry.positioningDepartureAirport?.icao ?? '',
        toIcao: entry.arrivalAirport?.icao ?? entry.positioningArrivalAirport?.icao ?? '',
        remarks: (flight?.remarks ?? sim?.remarks ?? '').trim(),
        ifrApproaches: flight?.ifrApproaches ?? 0,
        landingsTotal: (flight?.landingsDay ?? 0) + (flight?.landingsNight ?? 0),
        selMinutes: selMinutes,
        melMinutes: melMinutes,
        xcMinutes: flight?.timeCrossCountryMinutes ?? 0,
        dayMinutes: dayMinutes,
        nightMinutes: nightMinutes,
        ifrMinutes: flight?.timeIFRMinutes ?? 0,
        simInstMinutes:
            (flight?.timeInstrumentMinutes ?? 0) + (flight?.timeSimulatedInstrumentMinutes ?? 0),
        fstdMinutes: sim?.timeTotal ?? 0,
        dualMinutes: flight?.timeDualMinutes ?? 0,
        picPicusMinutes: (flight?.timePICMinutes ?? 0) + (flight?.timePICUSMinutes ?? 0),
        sicMinutes: flight?.timeSICMinutes ?? 0,
        instructorMinutes: flight?.timeInstructorMinutes ?? 0,
        totalMinutes: totalMinutes,
      );
    }).toList(growable: false);
  }

  ReportTemplateTotals sumTotals(List<ReportTemplateRow> rows) {
    var totals = const ReportTemplateTotals();
    for (final row in rows) {
      totals = totals.addRow(row);
    }
    return totals;
  }


  Map<String, dynamic> _rowToMap(ReportTemplateRow row) {
    return {
      'date': row.date,
      'aircraftModel': row.aircraftModel,
      'aircraftRegistration': row.aircraftRegistration,
      'fromIcao': row.fromIcao,
      'toIcao': row.toIcao,
      'remarks': row.remarks,
      'ifrApproaches': _emptyIfZeroInt(row.ifrApproaches),
      'landingsTotal': _emptyIfZeroInt(row.landingsTotal),
      'sel': _emptyIfZeroTime(row.selMinutes),
      'mel': _emptyIfZeroTime(row.melMinutes),
      'xc': _emptyIfZeroTime(row.xcMinutes),
      'day': _emptyIfZeroTime(row.dayMinutes),
      'night': _emptyIfZeroTime(row.nightMinutes),
      'ifr': _emptyIfZeroTime(row.ifrMinutes),
      'simInst': _emptyIfZeroTime(row.simInstMinutes),
      'fstd': _emptyIfZeroTime(row.fstdMinutes),
      'dual': _emptyIfZeroTime(row.dualMinutes),
      'picPicus': _emptyIfZeroTime(row.picPicusMinutes),
      'sic': _emptyIfZeroTime(row.sicMinutes),
      'instructor': _emptyIfZeroTime(row.instructorMinutes),
      'total': _emptyIfZeroTime(row.totalMinutes),
    };
  }

  Map<String, String> _totalsToMap(ReportTemplateTotals totals) {
    return {
      'ifrApproaches': _emptyIfZeroInt(totals.ifrApproaches),
      'landings': _emptyIfZeroInt(totals.landingsTotal),
      'sel': _emptyIfZeroTime(totals.selMinutes),
      'mel': _emptyIfZeroTime(totals.melMinutes),
      'xc': _emptyIfZeroTime(totals.xcMinutes),
      'day': _emptyIfZeroTime(totals.dayMinutes),
      'night': _emptyIfZeroTime(totals.nightMinutes),
      'ifr': _emptyIfZeroTime(totals.ifrMinutes),
      'simInst': _emptyIfZeroTime(totals.simInstMinutes),
      'fstd': _emptyIfZeroTime(totals.fstdMinutes),
      'dual': _emptyIfZeroTime(totals.dualMinutes),
      'picPicus': _emptyIfZeroTime(totals.picPicusMinutes),
      'sic': _emptyIfZeroTime(totals.sicMinutes),
      'instructor': _emptyIfZeroTime(totals.instructorMinutes),
      'total': _emptyIfZeroTime(totals.totalMinutes),
    };
  }

  String _emptyIfZeroTime(int minutes) {
    if (minutes <= 0) return '';
    return '${minutes ~/ 60}:${(minutes % 60).toString().padLeft(2, '0')}';
  }

  String _emptyIfZeroInt(int value) {
    if (value <= 0) return '';
    return value.toString();
  }

  pw.Widget _buildTemplateTable({
    required ReportPdfTableConfig table,
    required List<ReportTemplateRow> pageRows,
    required ReportPdfTemplate template,
    required Map<String, String> pageTotals,
    required Map<String, String> totalsBefore,
    required Map<String, String> totalsAfter,
  }) {
    final columnIndexByKey = <String, int>{};
    for (var i = 0; i < table.columns.length; i++) {
      columnIndexByKey[table.columns[i].key] = i;
    }

    final headers = table.columns.map((column) => column.header).toList(growable: false);
    final data = <List<String>>[
      ...pageRows.map(
        (row) {
          final rowMap = _rowToMap(row);
          return table.columns
              .map((column) => (rowMap[column.key] ?? '').toString())
              .toList(growable: false);
        },
      ),
    ];

    for (final footerRow in table.footerRows) {
      final row = List<String>.filled(table.columns.length, '');
      final label = footerRow.literalLabel ??
          (footerRow.labelToken == null ? '' : template.labels.resolveToken(footerRow.labelToken!));
      if (label.isNotEmpty && row.isNotEmpty) {
        row[0] = label;
      }
      final sourceMap = switch (footerRow.source) {
        ReportPdfSummarySource.pageTotals => pageTotals,
        ReportPdfSummarySource.totalsBefore => totalsBefore,
        ReportPdfSummarySource.totalsAfter => totalsAfter,
      };
      for (final entry in footerRow.values.entries) {
        final columnIndex = columnIndexByKey[entry.key];
        if (columnIndex == null) continue;
        row[columnIndex] = sourceMap[entry.value] ?? '';
      }
      data.add(row);
    }

    final columnWidths = <int, pw.TableColumnWidth>{};
    final cellAlignments = <int, pw.Alignment>{};
    for (var index = 0; index < table.columns.length; index++) {
      final column = table.columns[index];
      columnWidths[index] = pw.FlexColumnWidth(column.width <= 0 ? 1 : column.width);
      cellAlignments[index] = _alignmentFor(column.alignment);
    }

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      columnWidths: columnWidths,
      cellAlignments: cellAlignments,
      headerStyle: pw.TextStyle(fontSize: 6.2, fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 6.2),
    );
  }

  pw.Alignment _alignmentFor(ReportPdfColumnAlignment alignment) {
    switch (alignment) {
      case ReportPdfColumnAlignment.left:
        return pw.Alignment.centerLeft;
      case ReportPdfColumnAlignment.right:
        return pw.Alignment.centerRight;
      case ReportPdfColumnAlignment.center:
        return pw.Alignment.center;
    }
  }

  PdfPageFormat _resolvePageFormat(
    ReportPdfTemplate template,
    ReportPdfPageSize selectedPageSize,
  ) {
    final base = _pageFormatFor(selectedPageSize);
    return template.forceLandscape ? base.landscape : base;
  }

  PdfPageFormat _pageFormatFor(ReportPdfPageSize pageSize) {
    switch (pageSize) {
      case ReportPdfPageSize.a4:
        return PdfPageFormat.a4;
      case ReportPdfPageSize.letter:
        return PdfPageFormat.letter;
      case ReportPdfPageSize.legal:
        return PdfPageFormat.legal;
      case ReportPdfPageSize.a5:
        return PdfPageFormat.a5;
    }
  }

}
