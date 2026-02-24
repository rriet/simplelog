import 'dart:math' as math;
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/data/models/report_pdf_models.dart';

/// Public API documentation.
class ReportTemplateRow {
  /// Public API documentation.
  const ReportTemplateRow({
    required this.date,
    required this.aircraftModel,
    required this.aircraftRegistration,
    required this.fromIcao,
    required this.toIcao,
    required this.remarks,
    required this.ifrApproaches,
    required this.landingsTotal,
    required this.takeoffsTotal,
    required this.takeoffsDay,
    required this.takeoffsNight,
    required this.landingsDay,
    required this.landingsNight,
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
    this.extra = const <String, String>{},

    /// Public API documentation.
  });

  /// Public API documentation.

  /// Public API documentation.
  final String date;

  /// Public API documentation.
  final String aircraftModel;

  /// Public API documentation.
  final String aircraftRegistration;

  /// Public API documentation.
  final String fromIcao;

  /// Public API documentation.
  final String toIcao;

  /// Public API documentation.
  final String remarks;

  /// Public API documentation.
  final int ifrApproaches;

  /// Public API documentation.
  final int landingsTotal;

  /// Public API documentation.
  final int takeoffsTotal;

  /// Public API documentation.
  final int takeoffsDay;

  /// Public API documentation.
  final int takeoffsNight;

  /// Public API documentation.
  final int landingsDay;

  /// Public API documentation.
  final int landingsNight;

  /// Public API documentation.
  final int selMinutes;

  /// Public API documentation.
  final int melMinutes;

  /// Public API documentation.
  final int xcMinutes;

  /// Public API documentation.
  final int dayMinutes;

  /// Public API documentation.
  final int nightMinutes;

  /// Public API documentation.
  final int ifrMinutes;

  /// Public API documentation.
  final int simInstMinutes;

  /// Public API documentation.
  final int fstdMinutes;

  /// Public API documentation.
  final int dualMinutes;

  /// Public API documentation.
  final int picPicusMinutes;

  /// Public API documentation.
  final int sicMinutes;

  /// Public API documentation.
  final int instructorMinutes;

  /// Public API documentation.
  final int totalMinutes;

  /// Public API documentation.
  final Map<String, String> extra;

  /// Public API documentation.
}

/// Public API documentation.
class ReportEntryCrewNames {
  /// Public API documentation.
  const ReportEntryCrewNames({
    this.pic = '',
    this.sic = '',
  });

  /// Public API documentation.
  final String pic;

  /// Public API documentation.
  final String sic;
}

/// Public API documentation.

/// Public API documentation.
class ReportTemplateTotals {
  /// Public API documentation.
  const ReportTemplateTotals({
    /// Public API documentation.
    this.ifrApproaches = 0,

    /// Public API documentation.
    this.landingsTotal = 0,
    this.takeoffsTotal = 0,
    this.takeoffsDay = 0,
    this.takeoffsNight = 0,
    this.landingsDay = 0,
    this.landingsNight = 0,

    /// Public API documentation.
    this.selMinutes = 0,

    /// Public API documentation.
    this.melMinutes = 0,

    /// Public API documentation.
    this.xcMinutes = 0,

    /// Public API documentation.
    this.dayMinutes = 0,

    /// Public API documentation.
    this.nightMinutes = 0,
    this.ifrMinutes = 0,

    /// Public API documentation.
    this.simInstMinutes = 0,
    this.fstdMinutes = 0,
    this.dualMinutes = 0,
    this.picPicusMinutes = 0,
    this.sicMinutes = 0,
    this.instructorMinutes = 0,
    this.totalMinutes = 0,
  });

  /// Public API documentation.
  final int ifrApproaches;

  /// Public API documentation.
  final int landingsTotal;

  /// Public API documentation.
  final int takeoffsTotal;

  /// Public API documentation.
  final int takeoffsDay;

  /// Public API documentation.
  final int takeoffsNight;

  /// Public API documentation.
  final int landingsDay;

  /// Public API documentation.
  final int landingsNight;

  /// Public API documentation.
  final int selMinutes;

  /// Public API documentation.
  final int melMinutes;

  /// Public API documentation.
  final int xcMinutes;

  /// Public API documentation.
  final int dayMinutes;

  /// Public API documentation.
  final int nightMinutes;

  /// Public API documentation.
  final int ifrMinutes;

  /// Public API documentation.
  final int simInstMinutes;

  /// Public API documentation.
  final int fstdMinutes;

  /// Public API documentation.
  final int dualMinutes;

  /// Public API documentation.
  final int picPicusMinutes;

  /// Public API documentation.
  final int sicMinutes;

  /// Public API documentation.
  final int instructorMinutes;

  /// Public API documentation.
  final int totalMinutes;

  /// Public API documentation.
  ReportTemplateTotals addRow(ReportTemplateRow row) {
    /// Public API documentation.
    return ReportTemplateTotals(
      ifrApproaches: ifrApproaches + row.ifrApproaches,

      /// Public API documentation.
      landingsTotal: landingsTotal + row.landingsTotal,
      takeoffsTotal: takeoffsTotal + row.takeoffsTotal,
      takeoffsDay: takeoffsDay + row.takeoffsDay,
      takeoffsNight: takeoffsNight + row.takeoffsNight,
      landingsDay: landingsDay + row.landingsDay,
      landingsNight: landingsNight + row.landingsNight,
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

  /// Public API documentation.
  ReportTemplateTotals addTotals(ReportTemplateTotals other) {
    return ReportTemplateTotals(
      ifrApproaches: ifrApproaches + other.ifrApproaches,
      landingsTotal: landingsTotal + other.landingsTotal,
      takeoffsTotal: takeoffsTotal + other.takeoffsTotal,
      takeoffsDay: takeoffsDay + other.takeoffsDay,
      takeoffsNight: takeoffsNight + other.takeoffsNight,
      landingsDay: landingsDay + other.landingsDay,
      landingsNight: landingsNight + other.landingsNight,
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

/// Public API documentation.
class ReportPdfApplicationService {
  /// Public API documentation.
  const ReportPdfApplicationService();

  static final DateFormat _dateCellFormat = DateFormat('dd-MM-yyyy');
  static final DateFormat _hmTimeFormat = DateFormat('HH:mm');
  static const Set<String> _baseRowKeys = <String>{
    'date',
    'aircraftModel',
    'aircraftRegistration',
    'fromIcao',
    'toIcao',
    'remarks',
    'ifrApproaches',
    'landingsTotal',
    'takeoffs',
    'takeoffDay',
    'takeoffNight',
    'landingDay',
    'landingNight',
    'sel',
    'mel',
    'xc',
    'day',
    'night',
    'ifr',
    'simInst',
    'fstd',
    'dual',
    'picPicus',
    'sic',
    'instructor',
    'total',
  };

  /// Public API documentation.
  Future<Uint8List> generateFromTemplate({
    required ReportPdfTemplate template,
    required List<LogbookEntry> entries,
    required ReportTemplateTotals startingTotals,
    Map<String, String> coverValues = const <String, String>{},
    Map<int, ReportEntryCrewNames> flightCrewById = const {},
    Map<int, ReportEntryCrewNames> simulatorCrewById = const {},
  }) async {
    final pageFormat = _resolvePageFormat(template);
    final requiredRowKeys = _collectRequiredRowKeys(template);
    final rows = buildRows(
      entries,
      flightCrewById: flightCrewById,
      simulatorCrewById: simulatorCrewById,
      requiredExtraKeys: requiredRowKeys
          .where((key) => !_baseRowKeys.contains(key))
          .toSet(),
    );
    return _generatePdf(
      template: template,
      rows: rows,
      startingTotals: startingTotals,
      coverValues: coverValues,
      pageFormat: pageFormat,
    );
  }

  Set<String> _collectRequiredRowKeys(ReportPdfTemplate template) {
    final keys = <String>{};
    for (final table in template.tables) {
      for (final column in table.columns) {
        final key = column.key.trim();
        if (key.isNotEmpty) {
          keys.add(key);
        }
      }
    }
    return keys;
  }

  Future<Uint8List> _generatePdf({
    required ReportPdfTemplate template,
    required List<ReportTemplateRow> rows,
    required ReportTemplateTotals startingTotals,
    required Map<String, String> coverValues,
    required PdfPageFormat pageFormat,
  }) async {
    final document = pw.Document();
    final coverPage = template.coverPage;
    if (coverPage != null && coverPage.enabled) {
      document.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(20),
          build: (context) => _buildCoverPage(
            coverPage: coverPage,
            coverValues: coverValues,
          ),
        ),
      );
    }
    final rowsPerPage = template.rowsPerPage <= 0 ? 26 : template.rowsPerPage;
    final pages = <List<ReportTemplateRow>>[];
    for (var i = 0; i < rows.length; i += rowsPerPage) {
      final end = (i + rowsPerPage > rows.length)
          ? rows.length
          : i + rowsPerPage;
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
            takeoffsTotal: 0,
            takeoffsDay: 0,
            takeoffsNight: 0,
            landingsDay: 0,
            landingsNight: 0,
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

          /// Public API documentation.
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

  pw.Widget _buildCoverPage({
    required ReportPdfCoverPageConfig coverPage,
    required Map<String, String> coverValues,
  }) {
    final children = <pw.Widget>[];
    final title = coverPage.title.trim();
    if (title.isNotEmpty) {
      children
        ..add(
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
        )
        ..add(pw.SizedBox(height: 14));
    }

    for (final block in coverPage.blocks) {
      switch (block.type) {
        case ReportPdfCoverBlockType.kvGrid:
          children.add(
            _buildCoverKvGrid(
              block: block,
              coverValues: coverValues,
            ),
          );
        case ReportPdfCoverBlockType.multiline:
          children.add(
            _buildCoverMultiline(
              block: block,
              coverValues: coverValues,
            ),
          );
      }
      children.add(pw.SizedBox(height: 10));
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: children,
    );
  }

  pw.Widget _buildCoverKvGrid({
    required ReportPdfCoverBlockConfig block,
    required Map<String, String> coverValues,
  }) {
    final children = <pw.Widget>[];
    final title = block.title.trim();
    if (title.isNotEmpty) {
      children
        ..add(
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
        )
        ..add(pw.SizedBox(height: 6));
    }
    final absoluteItems = block.items
        .where((item) => item.hasAbsolutePosition)
        .toList(growable: false);
    final relativeItems = block.items
        .where((item) => !item.hasAbsolutePosition)
        .toList(growable: false);

    if (relativeItems.isNotEmpty) {
      final columns = block.columns < 1 ? 1 : block.columns;
      children.add(
        pw.LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints?.maxWidth;
            final width = (maxWidth == null || maxWidth.isInfinite)
                ? 500.0
                : maxWidth;
            final itemWidth = (width - (columns - 1) * 10) / columns;
            final labelWidth = _estimateCoverLabelWidth(
              items: block.items,
              maxWidth: itemWidth,
            );
            return pw.Wrap(
              spacing: 10,
              runSpacing: 6,
              children: relativeItems
                  .map(
                    (item) => pw.SizedBox(
                      width: itemWidth,
                      child: _buildCoverKeyValueLine(
                        item: item,
                        coverValues: coverValues,
                        labelWidth: labelWidth,
                      ),
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),
      );
    }

    if (absoluteItems.isNotEmpty) {
      if (relativeItems.isNotEmpty) {
        children.add(pw.SizedBox(height: 8));
      }
      children.add(
        pw.LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints?.maxWidth;
            final width = (maxWidth == null || maxWidth.isInfinite)
                ? 500.0
                : maxWidth;
            var maxBottom = 0.0;
            for (final item in absoluteItems) {
              final itemTop = item.y ?? 0;
              final itemHeight = item.height ?? 24;
              final bottom = itemTop + itemHeight;
              if (bottom > maxBottom) {
                maxBottom = bottom;
              }
            }
            final stackHeight = maxBottom + 2;
            final labelWidth = _estimateCoverLabelWidth(
              items: block.items,
              maxWidth: width,
            );
            final widgets = absoluteItems
                .map((item) {
                  final x = item.x ?? 0;
                  final y = item.y ?? 0;
                  final itemWidth = item.width ?? (width - x).clamp(40, width);
                  final itemHeight = item.height ?? 24;
                  return pw.Positioned(
                    left: x,
                    top: y,
                    child: pw.SizedBox(
                      width: itemWidth,
                      height: itemHeight,
                      child: _buildCoverKeyValueLine(
                        item: item,
                        coverValues: coverValues,
                        labelWidth: labelWidth,
                      ),
                    ),
                  );
                })
                .toList(growable: false);
            return pw.SizedBox(
              width: width,
              height: stackHeight,
              child: pw.Stack(children: widgets),
            );
          },
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: children,
    );
  }

  pw.Widget _buildCoverKeyValueLine({
    required ReportPdfCoverItemConfig item,
    required Map<String, String> coverValues,
    required double labelWidth,
  }) {
    final value = coverValues[item.valueKey] ?? '';
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: labelWidth,
          child: pw.Text(
            '${item.label}:',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
        pw.SizedBox(width: 4),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }

  double _estimateCoverLabelWidth({
    required List<ReportPdfCoverItemConfig> items,
    required double maxWidth,
  }) {
    var maxChars = 0;
    for (final item in items) {
      if (item.label.length > maxChars) {
        maxChars = item.label.length;
      }
    }
    final estimated = maxChars * 5.2 + 10;
    final upperBound = maxWidth * 0.42;
    return estimated.clamp(60, upperBound);
  }

  pw.Widget _buildCoverMultiline({
    required ReportPdfCoverBlockConfig block,
    required Map<String, String> coverValues,
  }) {
    final children = <pw.Widget>[];
    final title = block.title.trim();
    if (title.isNotEmpty) {
      children
        ..add(
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
        )
        ..add(pw.SizedBox(height: 6));
    }
    final value = (block.valueKey == null || block.valueKey!.isEmpty)
        ? ''
        : (coverValues[block.valueKey!] ?? '');
    children.add(
      pw.Container(
        width: double.infinity,
        constraints: const pw.BoxConstraints(minHeight: 70),
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(border: pw.Border.all()),
        child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
      ),
    );
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: children,
    );
  }

  /// Public API documentation.
  List<ReportTemplateRow> buildRows(
    List<LogbookEntry> entries, {
    Map<int, ReportEntryCrewNames> flightCrewById = const {},
    Map<int, ReportEntryCrewNames> simulatorCrewById = const {},
    Set<String> requiredExtraKeys = const <String>{},
  }) {
    final sortedEntries = [...entries]
      ..sort(
        (a, b) => a.timeLine.eventDateTime.compareTo(b.timeLine.eventDateTime),
      );
    return sortedEntries
        .map((entry) {
          final flight = entry.flight;
          final sim = entry.simulatorTraining;
          final pos = entry.positioning;
          final type = entry.aircraftType;
          final crew = switch (entry.type) {
            LogbookEventType.flight =>
              flight == null
                  ? const ReportEntryCrewNames()
                  : (flightCrewById[flight.id] ?? const ReportEntryCrewNames()),
            LogbookEventType.simulatorTraining =>
              sim == null
                  ? const ReportEntryCrewNames()
                  : (simulatorCrewById[sim.id] ?? const ReportEntryCrewNames()),
            _ => const ReportEntryCrewNames(),
          };

          final totalMinutes =
              flight?.timeBlockMinutes ??
              pos?.timeTotalMinutes ??
              sim?.timeTotal ??
              0;

          /// Public API documentation.
          final nightMinutes = flight?.timeNightMinutes ?? 0;
          final dayMinutes = math.max(0, totalMinutes - nightMinutes);
          final isSeaplane = type?.category.name == 'seaplane';
          final isMultiEngine = (type?.engineCount ?? 0) > 1;
          final selMinutes = (!isSeaplane && !isMultiEngine) ? totalMinutes : 0;
          final melMinutes = (!isSeaplane && isMultiEngine) ? totalMinutes : 0;

          final takeoffDay = flight?.takeOffsDays ?? 0;
          final takeoffNight = flight?.takeOffsNight ?? 0;
          final landingDay = flight?.landingsDay ?? 0;
          final landingNight = flight?.landingsNight ?? 0;
          final takeoffsTotal = takeoffDay + takeoffNight;
          final landingsTotal = landingDay + landingNight;
          final blockMinutes = flight?.timeBlockMinutes ?? 0;
          final singlePilotSelMinutes =
              type != null &&
                  type.engineCount == 1 &&
                  !type.multiPilot &&
                  type.category.name == 'landplane'
              ? blockMinutes
              : 0;
          final singlePilotMelMinutes =
              type != null &&
                  type.engineCount > 1 &&
                  !type.multiPilot &&
                  type.category.name == 'landplane'
              ? blockMinutes
              : 0;
          final complexMinutes = (type?.complex ?? false) ? blockMinutes : 0;
          final efisMinutes = (type?.efis ?? false) ? blockMinutes : 0;
          final highPerformanceMinutes = (type?.highPerformance ?? false)
              ? blockMinutes
              : 0;
          final multiPilotMinutes = (type?.multiPilot ?? false)
              ? blockMinutes
              : 0;

          return ReportTemplateRow(
            date: _dateCellFormat.format(entry.timeLine.eventDateTime.toUtc()),
            aircraftModel: type?.code ?? '',
            aircraftRegistration: entry.aircraft?.registration ?? '',
            fromIcao:
                entry.departureAirport?.icao ??
                entry.positioningDepartureAirport?.icao ??
                '',
            toIcao:
                entry.arrivalAirport?.icao ??
                entry.positioningArrivalAirport?.icao ??
                '',
            remarks: (flight?.remarks ?? sim?.remarks ?? '').trim(),
            ifrApproaches: flight?.ifrApproaches ?? 0,
            landingsTotal: landingsTotal,
            takeoffsTotal: takeoffsTotal,
            takeoffsDay: takeoffDay,
            takeoffsNight: takeoffNight,
            landingsDay: landingDay,
            landingsNight: landingNight,
            selMinutes: selMinutes,
            melMinutes: melMinutes,
            xcMinutes: flight?.timeCrossCountryMinutes ?? 0,
            dayMinutes: dayMinutes,
            nightMinutes: nightMinutes,
            ifrMinutes: flight?.timeIFRMinutes ?? 0,
            simInstMinutes:
                (flight?.timeInstrumentMinutes ?? 0) +
                (flight?.timeSimulatedInstrumentMinutes ?? 0),
            fstdMinutes: sim?.timeTotal ?? 0,
            dualMinutes: flight?.timeDualMinutes ?? 0,
            picPicusMinutes:
                (flight?.timePICMinutes ?? 0) + (flight?.timePICUSMinutes ?? 0),
            sicMinutes: flight?.timeSICMinutes ?? 0,
            instructorMinutes: flight?.timeInstructorMinutes ?? 0,
            totalMinutes: totalMinutes,
            extra: _buildExtraRowValues(
              entry: entry,
              crew: crew,
              takeoffDay: takeoffDay,
              takeoffNight: takeoffNight,
              takeoffsTotal: takeoffsTotal,
              landingDay: landingDay,
              landingNight: landingNight,
              landingsTotal: landingsTotal,
              singlePilotSelMinutes: singlePilotSelMinutes,
              singlePilotMelMinutes: singlePilotMelMinutes,
              multiPilotMinutes: multiPilotMinutes,
              complexMinutes: complexMinutes,
              efisMinutes: efisMinutes,
              highPerformanceMinutes: highPerformanceMinutes,
              requiredExtraKeys: requiredExtraKeys,
            ),
          );
        })
        .toList(growable: false);
  }

  Map<String, String> _buildExtraRowValues({
    required LogbookEntry entry,
    required ReportEntryCrewNames crew,
    required int takeoffDay,
    required int takeoffNight,
    required int takeoffsTotal,
    required int landingDay,
    required int landingNight,
    required int landingsTotal,
    required int singlePilotSelMinutes,
    required int singlePilotMelMinutes,
    required int multiPilotMinutes,
    required int complexMinutes,
    required int efisMinutes,
    required int highPerformanceMinutes,
    required Set<String> requiredExtraKeys,
  }) {
    final flight = entry.flight;
    final sim = entry.simulatorTraining;
    final type = entry.aircraftType;
    final timeline = entry.timeLine.eventDateTime.toUtc();
    final depTime = timeline;
    final arrTime = flight?.arrivalDateTime?.toUtc();
    final takeoffTime = flight?.takeOffDateTime?.toUtc();
    final landingTime = flight?.landingDateTime?.toUtc();
    final map = <String, String>{};
    void put(String key, String value) {
      if (requiredExtraKeys.contains(key)) {
        map[key] = value;
      }
    }

    put('eventType', entry.type.name);
    put('departureTime', _formatHm(depTime));
    put('arrivalTime', _formatHm(arrTime));
    put('depTime', _formatHm(depTime));
    put('arrTime', _formatHm(arrTime));
    put('takeoffTime', _formatHm(takeoffTime));
    put('landingTime', _formatHm(landingTime));
    put('picCrewName', crew.pic);
    put('sicCrewName', crew.sic);
    put('pilotPicName', crew.pic);
    put('pilotSicName', crew.sic);
    put('takeoffDay', _emptyIfZeroInt(takeoffDay));
    put('takeoffNight', _emptyIfZeroInt(takeoffNight));
    put('takeoffs', _emptyIfZeroInt(takeoffsTotal));
    put('landingDay', _emptyIfZeroInt(landingDay));
    put('landingNight', _emptyIfZeroInt(landingNight));
    put('landings', _emptyIfZeroInt(landingsTotal));
    put('singlePilotSel', _emptyIfZeroTime(singlePilotSelMinutes));
    put('singlePilotMel', _emptyIfZeroTime(singlePilotMelMinutes));
    put('multiPilotTime', _emptyIfZeroTime(multiPilotMinutes));
    put('complexTime', _emptyIfZeroTime(complexMinutes));
    put('efisTime', _emptyIfZeroTime(efisMinutes));
    put('highPerformanceTime', _emptyIfZeroTime(highPerformanceMinutes));
    put(
      'picPlusPicus',
      _emptyIfZeroTime(
        (flight?.timePICMinutes ?? 0) + (flight?.timePICUSMinutes ?? 0),
      ),
    );
    put('picWithoutPicus', _emptyIfZeroTime(flight?.timePICMinutes ?? 0));
    put('picus', _emptyIfZeroTime(flight?.timePICUSMinutes ?? 0));
    put('isMultiPilot', (type?.multiPilot ?? false).toString());
    put('isComplex', (type?.complex ?? false).toString());
    put('isEfis', (type?.efis ?? false).toString());
    put('isHighPerformance', (type?.highPerformance ?? false).toString());
    put('engineCount', (type?.engineCount ?? 0).toString());
    put('aircraftCategory', type?.category.name ?? '');
    put('aircraftEngineType', type?.engineType.name ?? '');
    put('flightId', (flight?.id ?? '').toString());
    put('simulatorId', (sim?.id ?? '').toString());
    put('flight.timePICMinutes', (flight?.timePICMinutes ?? 0).toString());
    put('flight.timePICUSMinutes', (flight?.timePICUSMinutes ?? 0).toString());
    put('flight.timeSICMinutes', (flight?.timeSICMinutes ?? 0).toString());
    put('flight.timeDualMinutes', (flight?.timeDualMinutes ?? 0).toString());
    put(
      'flight.timeInstructorMinutes',
      (flight?.timeInstructorMinutes ?? 0).toString(),
    );
    put('flight.timeIFRMinutes', (flight?.timeIFRMinutes ?? 0).toString());
    put(
      'flight.timeInstrumentMinutes',
      (flight?.timeInstrumentMinutes ?? 0).toString(),
    );
    put(
      'flight.timeSimulatedInstrumentMinutes',
      (flight?.timeSimulatedInstrumentMinutes ?? 0).toString(),
    );
    put('flight.timeNightMinutes', (flight?.timeNightMinutes ?? 0).toString());
    put(
      'flight.timeCrossCountryMinutes',
      (flight?.timeCrossCountryMinutes ?? 0).toString(),
    );
    put(
      'flight.timeCustom1Minutes',
      (flight?.timeCustom1Minutes ?? 0).toString(),
    );
    put(
      'flight.timeCustom2Minutes',
      (flight?.timeCustom2Minutes ?? 0).toString(),
    );
    put(
      'flight.timeCustom3Minutes',
      (flight?.timeCustom3Minutes ?? 0).toString(),
    );
    put(
      'flight.timeCustom4Minutes',
      (flight?.timeCustom4Minutes ?? 0).toString(),
    );
    put(
      'flight.timeFlightMinutes',
      (flight?.timeFlightMinutes ?? 0).toString(),
    );
    put('flight.timeBlockMinutes', (flight?.timeBlockMinutes ?? 0).toString());
    put(
      'flight.timeTotalBlockMinutes',
      (flight?.timeTotalBlockMinutes ?? 0).toString(),
    );
    put('flight.distanceNM', (flight?.distanceNM ?? 0).toString());
    put('flight.ifrApproaches', (flight?.ifrApproaches ?? 0).toString());
    put('flight.takeOffsDays', (flight?.takeOffsDays ?? 0).toString());
    put('flight.takeOffsNight', (flight?.takeOffsNight ?? 0).toString());
    put('flight.landingsDay', (flight?.landingsDay ?? 0).toString());
    put('flight.landingsNight', (flight?.landingsNight ?? 0).toString());
    put('flight.pilotFunction', flight?.pilotFunction ?? '');
    put('flight.approachType', flight?.approachType ?? '');
    put('flight.remarks', flight?.remarks ?? '');
    put('flight.notes', flight?.notes ?? '');
    put('flight.isLocked', (flight?.isLocked ?? false).toString());
    put('simulator.timeTotal', (sim?.timeTotal ?? 0).toString());
    put('simulator.remarks', sim?.remarks ?? '');
    put('simulator.notes', sim?.notes ?? '');
    put('simulator.isLocked', (sim?.isLocked ?? false).toString());
    return map;
  }

  String _formatHm(DateTime? value) {
    if (value == null) return '';
    return _hmTimeFormat.format(value.toUtc());
  }

  /// Public API documentation.
  ReportTemplateTotals sumTotals(List<ReportTemplateRow> rows) {
    var totals = const ReportTemplateTotals();
    for (final row in rows) {
      totals = totals.addRow(row);
    }
    return totals;
  }

  /// Public API documentation.
  ReportTemplateTotals sumTotalsFromEntries(List<LogbookEntry> entries) {
    var ifrApproaches = 0;
    var landingsTotal = 0;
    var takeoffsTotal = 0;
    var takeoffsDay = 0;
    var takeoffsNight = 0;
    var landingsDay = 0;
    var landingsNight = 0;
    var selMinutes = 0;
    var melMinutes = 0;
    var xcMinutes = 0;
    var dayMinutes = 0;
    var nightMinutes = 0;
    var ifrMinutes = 0;
    var simInstMinutes = 0;
    var fstdMinutes = 0;
    var dualMinutes = 0;
    var picPicusMinutes = 0;
    var sicMinutes = 0;
    var instructorMinutes = 0;
    var totalMinutes = 0;

    for (final entry in entries) {
      final flight = entry.flight;
      final sim = entry.simulatorTraining;
      final pos = entry.positioning;
      final type = entry.aircraftType;

      final rowTotalMinutes =
          flight?.timeBlockMinutes ??
          pos?.timeTotalMinutes ??
          sim?.timeTotal ??
          0;
      final rowNightMinutes = flight?.timeNightMinutes ?? 0;
      final rowDayMinutes = math.max(0, rowTotalMinutes - rowNightMinutes);
      final isSeaplane = type?.category.name == 'seaplane';
      final isMultiEngine = (type?.engineCount ?? 0) > 1;
      final rowSelMinutes = (!isSeaplane && !isMultiEngine)
          ? rowTotalMinutes
          : 0;
      final rowMelMinutes = (!isSeaplane && isMultiEngine)
          ? rowTotalMinutes
          : 0;
      final rowTakeoffDay = flight?.takeOffsDays ?? 0;
      final rowTakeoffNight = flight?.takeOffsNight ?? 0;
      final rowLandingDay = flight?.landingsDay ?? 0;
      final rowLandingNight = flight?.landingsNight ?? 0;

      ifrApproaches += flight?.ifrApproaches ?? 0;
      landingsTotal += rowLandingDay + rowLandingNight;
      takeoffsTotal += rowTakeoffDay + rowTakeoffNight;
      takeoffsDay += rowTakeoffDay;
      takeoffsNight += rowTakeoffNight;
      landingsDay += rowLandingDay;
      landingsNight += rowLandingNight;
      selMinutes += rowSelMinutes;
      melMinutes += rowMelMinutes;
      xcMinutes += flight?.timeCrossCountryMinutes ?? 0;
      dayMinutes += rowDayMinutes;
      nightMinutes += rowNightMinutes;
      ifrMinutes += flight?.timeIFRMinutes ?? 0;
      simInstMinutes +=
          (flight?.timeInstrumentMinutes ?? 0) +
          (flight?.timeSimulatedInstrumentMinutes ?? 0);
      fstdMinutes += sim?.timeTotal ?? 0;
      dualMinutes += flight?.timeDualMinutes ?? 0;
      picPicusMinutes +=
          (flight?.timePICMinutes ?? 0) + (flight?.timePICUSMinutes ?? 0);
      sicMinutes += flight?.timeSICMinutes ?? 0;
      instructorMinutes += flight?.timeInstructorMinutes ?? 0;
      totalMinutes += rowTotalMinutes;
    }

    return ReportTemplateTotals(
      ifrApproaches: ifrApproaches,
      landingsTotal: landingsTotal,
      takeoffsTotal: takeoffsTotal,
      takeoffsDay: takeoffsDay,
      takeoffsNight: takeoffsNight,
      landingsDay: landingsDay,
      landingsNight: landingsNight,
      selMinutes: selMinutes,
      melMinutes: melMinutes,
      xcMinutes: xcMinutes,
      dayMinutes: dayMinutes,
      nightMinutes: nightMinutes,
      ifrMinutes: ifrMinutes,
      simInstMinutes: simInstMinutes,
      fstdMinutes: fstdMinutes,
      dualMinutes: dualMinutes,
      picPicusMinutes: picPicusMinutes,
      sicMinutes: sicMinutes,
      instructorMinutes: instructorMinutes,
      totalMinutes: totalMinutes,
    );
  }

  String _rowValueForKey(ReportTemplateRow row, String key) {
    switch (key) {
      case 'date':
        return row.date;
      case 'aircraftModel':
        return row.aircraftModel;
      case 'aircraftRegistration':
        return row.aircraftRegistration;
      case 'fromIcao':
        return row.fromIcao;
      case 'toIcao':
        return row.toIcao;
      case 'remarks':
        return row.remarks;
      case 'ifrApproaches':
        return _emptyIfZeroInt(row.ifrApproaches);
      case 'landings':
      case 'landingsTotal':
        return _emptyIfZeroInt(row.landingsTotal);
      case 'takeoffs':
        return _emptyIfZeroInt(row.takeoffsTotal);
      case 'takeoffDay':
        return _emptyIfZeroInt(row.takeoffsDay);
      case 'takeoffNight':
        return _emptyIfZeroInt(row.takeoffsNight);
      case 'landingDay':
        return _emptyIfZeroInt(row.landingsDay);
      case 'landingNight':
        return _emptyIfZeroInt(row.landingsNight);
      case 'sel':
        return _emptyIfZeroTime(row.selMinutes);
      case 'mel':
        return _emptyIfZeroTime(row.melMinutes);
      case 'xc':
        return _emptyIfZeroTime(row.xcMinutes);
      case 'day':
        return _emptyIfZeroTime(row.dayMinutes);
      case 'night':
        return _emptyIfZeroTime(row.nightMinutes);
      case 'ifr':
        return _emptyIfZeroTime(row.ifrMinutes);
      case 'simInst':
        return _emptyIfZeroTime(row.simInstMinutes);
      case 'fstd':
        return _emptyIfZeroTime(row.fstdMinutes);
      case 'dual':
        return _emptyIfZeroTime(row.dualMinutes);
      case 'picPicus':
        return _emptyIfZeroTime(row.picPicusMinutes);
      case 'sic':
        return _emptyIfZeroTime(row.sicMinutes);
      case 'instructor':
        return _emptyIfZeroTime(row.instructorMinutes);
      case 'total':
        return _emptyIfZeroTime(row.totalMinutes);
      default:
        return row.extra[key] ?? '';
    }
  }

  Map<String, String> _totalsToMap(ReportTemplateTotals totals) {
    return {
      'ifrApproaches': _emptyIfZeroInt(totals.ifrApproaches),
      'landings': _emptyIfZeroInt(totals.landingsTotal),
      'takeoffs': _emptyIfZeroInt(totals.takeoffsTotal),
      'landingDay': _emptyIfZeroInt(totals.landingsDay),
      'landingNight': _emptyIfZeroInt(totals.landingsNight),
      'takeoffDay': _emptyIfZeroInt(totals.takeoffsDay),
      'takeoffNight': _emptyIfZeroInt(totals.takeoffsNight),
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
      'picPlusPicus': _emptyIfZeroTime(totals.picPicusMinutes),
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
    final layout = _buildTableLayout(
      table: table,
      template: template,
      pageRows: pageRows,
      pageTotals: pageTotals,
      totalsBefore: totalsBefore,
      totalsAfter: totalsAfter,
    );
    return pw.LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints?.maxWidth;
        final baseWidth = (maxWidth == null || maxWidth.isInfinite)
            ? 500.0
            : maxWidth;
        final totalWeight = layout.columnWeights.fold<double>(
          0,
          (sum, value) => sum + value,
        );
        final safeTotalWeight = totalWeight <= 0 ? 1.0 : totalWeight;
        final columnWidths = layout.columnWeights
            .map((weight) => baseWidth * (weight / safeTotalWeight))
            .toList(growable: false);
        final columnOffsets = <double>[];
        var x = 0.0;
        for (final width in columnWidths) {
          columnOffsets.add(x);
          x += width;
        }

        final children = <pw.Widget>[];
        for (final cell in layout.cells) {
          final left = columnOffsets[cell.startCol];
          final width = _columnSpanWidth(
            widths: columnWidths,
            start: cell.startCol,
            span: cell.colSpan,
          );
          final top = _rowOffset(
            rowHeights: layout.rowHeights,
            start: 0,
            span: cell.startRow,
          );
          final height = _rowOffset(
            rowHeights: layout.rowHeights,
            start: cell.startRow,
            span: cell.rowSpan,
          );
          children.add(
            pw.Positioned(
              left: left,
              top: top,
              child: pw.SizedBox(
                width: width,
                height: height,
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 1,
                  ),
                  alignment: _alignmentFor(
                    horizontal: cell.alignment,
                    vertical: cell.verticalAlignment,
                  ),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(),
                      right: pw.BorderSide(),
                      top: pw.BorderSide(),
                      bottom: pw.BorderSide(),
                    ),
                  ),
                  child: pw.Text(cell.text, style: cell.style),
                ),
              ),
            ),
          );
        }

        return pw.Container(
          height: _rowOffset(
            rowHeights: layout.rowHeights,
            start: 0,
            span: layout.rowHeights.length,
          ),
          child: pw.Stack(children: children),
        );
      },
    );
  }

  _BuiltTableLayout _buildTableLayout({
    required ReportPdfTableConfig table,
    required ReportPdfTemplate template,
    required List<ReportTemplateRow> pageRows,
    required Map<String, String> pageTotals,
    required Map<String, String> totalsBefore,
    required Map<String, String> totalsAfter,
  }) {
    final cells = <_PlacedPdfCell>[];
    final columnCount = table.columns.length;
    final carry = List<int>.filled(columnCount, 0);
    final rowHeights = <double>[];
    var rowIndex = 0;

    final headerRows = table.header.isEmpty
        ? [
            ReportPdfHeaderRowConfig(
              cells: table.columns
                  .map(
                    (column) => ReportPdfCellConfig(
                      text: column.header ?? column.key,
                      textStyle: const ReportPdfCellTextStyle(
                        bold: true,
                        fontSize: 6.2,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ]
        : table.header;

    for (final header in headerRows) {
      rowIndex = _placeSpanRow(
        rowIndex: rowIndex,
        rowCells: header.cells,
        columns: table.columns,
        carry: carry,
        sourceMap: const {},
        out: cells,
        outRowHeights: rowHeights,
        rowHeight: _normalizeRowHeight(
          rowHeight: header.rowHeight,
          fallback: template.rowHeight,
        ),
      );
    }

    for (final row in pageRows) {
      final rowCells = table.columns
          .map(
            (column) => ReportPdfCellConfig(
              text: _rowValueForKey(row, column.key),
              alignment: column.alignment,
              verticalAlignment: column.verticalAlignment,
              textStyle: column.textStyle,
            ),
          )
          .toList(growable: false);
      rowIndex = _placeSpanRow(
        rowIndex: rowIndex,
        rowCells: rowCells,
        columns: table.columns,
        carry: carry,
        sourceMap: const {},
        out: cells,
        outRowHeights: rowHeights,
        rowHeight: template.rowHeight,
      );
    }

    final columnIndexByKey = <String, int>{};
    for (var i = 0; i < table.columns.length; i++) {
      columnIndexByKey[table.columns[i].key] = i;
    }
    final footerTokenMap = _buildFooterTokenMap(
      template: template,
      pageTotals: pageTotals,
      totalsBefore: totalsBefore,
      totalsAfter: totalsAfter,
    );
    for (final footer in table.footer) {
      rowIndex = _placeSpanRow(
        rowIndex: rowIndex,
        rowCells: footer.cells,
        columns: table.columns,
        carry: carry,
        sourceMap: footerTokenMap,
        out: cells,
        outRowHeights: rowHeights,
        rowHeight: _normalizeRowHeight(
          rowHeight: footer.rowHeight,
          fallback: template.rowHeight,
        ),
      );
    }

    for (final footerRow in table.footerRows) {
      final sourceMap = switch (footerRow.source) {
        ReportPdfSummarySource.pageTotals => pageTotals,
        ReportPdfSummarySource.totalsBefore => totalsBefore,
        ReportPdfSummarySource.totalsAfter => totalsAfter,
      };
      if (footerRow.cells.isNotEmpty) {
        rowIndex = _placeSpanRow(
          rowIndex: rowIndex,
          rowCells: footerRow.cells,
          columns: table.columns,
          carry: carry,
          sourceMap: sourceMap,
          out: cells,
          outRowHeights: rowHeights,
          rowHeight: _normalizeRowHeight(
            rowHeight: footerRow.rowHeight,
            fallback: template.rowHeight,
          ),
        );
        continue;
      }

      final rowCells = List<ReportPdfCellConfig>.generate(
        table.columns.length,
        (index) => ReportPdfCellConfig(
          text: '',
          alignment: table.columns[index].alignment,
          verticalAlignment: table.columns[index].verticalAlignment,
          textStyle: table.columns[index].textStyle,
        ),
      );
      final label =
          footerRow.literalLabel ??
          (footerRow.labelToken == null
              ? ''
              : template.labels.resolveToken(footerRow.labelToken!));
      if (label.isNotEmpty && rowCells.isNotEmpty) {
        rowCells[0] = ReportPdfCellConfig(
          text: label,
          alignment: ReportPdfColumnAlignment.left,
          verticalAlignment: ReportPdfVerticalAlignment.middle,
          textStyle: const ReportPdfCellTextStyle(bold: true, fontSize: 6.2),
        );
      }
      for (final entry in footerRow.values.entries) {
        final columnIndex = columnIndexByKey[entry.key];
        if (columnIndex == null) continue;
        rowCells[columnIndex] = ReportPdfCellConfig(
          text: sourceMap[entry.value] ?? '',
          alignment: table.columns[columnIndex].alignment,
          verticalAlignment: table.columns[columnIndex].verticalAlignment,
          textStyle: const ReportPdfCellTextStyle(bold: true, fontSize: 6.2),
        );
      }
      rowIndex = _placeSpanRow(
        rowIndex: rowIndex,
        rowCells: rowCells,
        columns: table.columns,
        carry: carry,
        sourceMap: sourceMap,
        out: cells,
        outRowHeights: rowHeights,
        rowHeight: _normalizeRowHeight(
          rowHeight: footerRow.rowHeight,
          fallback: template.rowHeight,
        ),
      );
    }

    return _BuiltTableLayout(
      cells: cells,
      rowHeights: rowHeights,
      columnWeights: table.columns
          .map((column) => column.width <= 0 ? 1.0 : column.width)
          .toList(growable: false),
    );
  }

  Map<String, String> _buildFooterTokenMap({
    required ReportPdfTemplate template,
    required Map<String, String> pageTotals,
    required Map<String, String> totalsBefore,
    required Map<String, String> totalsAfter,
  }) {
    final map = <String, String>{
      'pageTotalLabel': template.labels.pageTotal,
      'amountForwardLabel': template.labels.amountForward,
      'totalToDateLabel': template.labels.totalToDate,
    };
    for (final entry in pageTotals.entries) {
      map['${entry.key}PageTotal'] = entry.value;
    }
    for (final entry in totalsBefore.entries) {
      map['${entry.key}PreviousTotal'] = entry.value;
    }
    for (final entry in totalsAfter.entries) {
      map['${entry.key}NewTotal'] = entry.value;
      map['${entry.key}TotalToDate'] = entry.value;
    }
    return map;
  }

  int _placeSpanRow({
    required int rowIndex,
    required List<ReportPdfCellConfig> rowCells,
    required List<ReportPdfColumnConfig> columns,
    required List<int> carry,
    required Map<String, String> sourceMap,
    required List<_PlacedPdfCell> out,
    required List<double> outRowHeights,
    required double rowHeight,
  }) {
    final totalColumns = columns.length;
    var cursor = 0;
    for (final cell in rowCells) {
      while (cursor < totalColumns && carry[cursor] > 0) {
        cursor++;
      }
      if (cursor >= totalColumns) break;

      final maxSpan = _contiguousFreeColumns(carry, cursor);
      if (maxSpan <= 0) break;
      final hspan = math.min(math.max(1, cell.hspan), maxSpan);
      final vspan = math.max(1, cell.vspan);
      final text = cell.valueToken == null
          ? (cell.text ?? '')
          : (sourceMap[cell.valueToken!] ?? '');
      final alignment = cell.alignment ?? columns[cursor].alignment;
      final verticalAlignment =
          cell.verticalAlignment ?? columns[cursor].verticalAlignment;
      out.add(
        _PlacedPdfCell(
          startRow: rowIndex,
          startCol: cursor,
          rowSpan: vspan,
          colSpan: hspan,
          text: text,
          alignment: alignment,
          verticalAlignment: verticalAlignment,
          style: _textStyleFrom(cell.textStyle, fallbackSize: 6.2),
        ),
      );
      for (var index = cursor; index < cursor + hspan; index++) {
        carry[index] = math.max(carry[index], vspan);
      }
      cursor += hspan;
    }

    for (var index = 0; index < totalColumns; index++) {
      if (carry[index] > 0) {
        carry[index]--;
      }
    }
    outRowHeights.add(rowHeight);
    return rowIndex + 1;
  }

  int _contiguousFreeColumns(List<int> carry, int start) {
    var count = 0;
    for (var index = start; index < carry.length; index++) {
      if (carry[index] > 0) {
        break;
      }
      count++;
    }
    return count;
  }

  double _columnSpanWidth({
    required List<double> widths,
    required int start,
    required int span,
  }) {
    var sum = 0.0;
    final end = math.min(widths.length, start + span);
    for (var index = start; index < end; index++) {
      sum += widths[index];
    }
    return sum;
  }

  double _normalizeRowHeight({
    required double? rowHeight,
    required double fallback,
  }) {
    final value = rowHeight ?? fallback;
    if (value <= 0) {
      return fallback > 0 ? fallback : 11;
    }
    return value;
  }

  double _rowOffset({
    required List<double> rowHeights,
    required int start,
    required int span,
  }) {
    var sum = 0.0;
    final safeStart = math.max(0, start);
    final end = math.min(rowHeights.length, safeStart + math.max(0, span));
    for (var index = safeStart; index < end; index++) {
      sum += rowHeights[index];
    }
    return sum;
  }

  pw.TextStyle _textStyleFrom(
    ReportPdfCellTextStyle style, {
    required double fallbackSize,
  }) {
    return pw.TextStyle(
      fontSize: style.fontSize ?? fallbackSize,
      fontWeight: style.bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      fontStyle: style.italic ? pw.FontStyle.italic : pw.FontStyle.normal,
      color: _parsePdfColor(style.colorHex),
    );
  }

  PdfColor? _parsePdfColor(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      return PdfColor.fromHex(raw.trim());
    } on Object {
      return null;
    }
  }

  pw.Alignment _alignmentFor({
    required ReportPdfColumnAlignment horizontal,
    required ReportPdfVerticalAlignment vertical,
  }) {
    final x = switch (horizontal) {
      ReportPdfColumnAlignment.left => -1.0,
      ReportPdfColumnAlignment.center => 0.0,
      ReportPdfColumnAlignment.right => 1.0,
    };
    final y = switch (vertical) {
      ReportPdfVerticalAlignment.top => 1.0,
      ReportPdfVerticalAlignment.middle => 0.0,
      ReportPdfVerticalAlignment.bottom => -1.0,
    };
    return pw.Alignment(x, y);
  }

  PdfPageFormat _resolvePageFormat(
    ReportPdfTemplate template,
  ) {
    final base = _pageFormatFor(template.defaultPageSize);
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

class _BuiltTableLayout {
  const _BuiltTableLayout({
    required this.cells,
    required this.rowHeights,
    required this.columnWeights,
  });

  final List<_PlacedPdfCell> cells;
  final List<double> rowHeights;
  final List<double> columnWeights;
}

class _PlacedPdfCell {
  const _PlacedPdfCell({
    required this.startRow,
    required this.startCol,
    required this.rowSpan,
    required this.colSpan,
    required this.text,
    required this.alignment,
    required this.verticalAlignment,
    required this.style,
  });

  final int startRow;
  final int startCol;
  final int rowSpan;
  final int colSpan;
  final String text;
  final ReportPdfColumnAlignment alignment;
  final ReportPdfVerticalAlignment verticalAlignment;
  final pw.TextStyle style;
}
