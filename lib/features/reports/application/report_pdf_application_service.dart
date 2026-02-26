import 'dart:math' as math;
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/data/models/report_pdf_models.dart';

/// Flattened data for a single row in a logbook report.
class ReportTemplateRow {
  /// Creates a row from already formatted cell values and time totals.
  const ReportTemplateRow({
    required this.date,
    required this.aircraftModel,
    required this.aircraftRegistration,
    required this.fromIcao,
    required this.toIcao,
    required this.remarks,
    required this.isSimulatorEntry,
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
    required this.picMinutes,
    required this.picusMinutes,
    required this.picPicusMinutes,
    required this.sicMinutes,
    required this.instructorMinutes,
    required this.totalMinutes,
    this.extra = const <String, String>{},
    this.extraImages = const <String, Uint8List>{},
  });

  /// Date string displayed in the report (already formatted).
  final String date;

  /// Aircraft model used for the entry.
  final String aircraftModel;

  /// Aircraft registration for the entry.
  final String aircraftRegistration;

  /// Departure aerodrome ICAO code.
  final String fromIcao;

  /// Destination aerodrome ICAO code.
  final String toIcao;

  /// Free‑form remarks shown in the report.
  final String remarks;

  /// Public API documentation.
  final bool isSimulatorEntry;

  /// Number of instrument approaches flown on this row.
  final int ifrApproaches;

  /// Total landings (day + night).
  final int landingsTotal;

  /// Total take‑offs (day + night).
  final int takeoffsTotal;

  /// Day take‑offs.
  final int takeoffsDay;

  /// Night take‑offs.
  final int takeoffsNight;

  /// Day landings.
  final int landingsDay;

  /// Night landings.
  final int landingsNight;

  /// Single‑engine land (SEL) time in minutes.
  final int selMinutes;

  /// Multi‑engine land (MEL) time in minutes.
  final int melMinutes;

  /// Cross‑country time in minutes.
  final int xcMinutes;

  /// Day flying time in minutes.
  final int dayMinutes;

  /// Night flying time in minutes.
  final int nightMinutes;

  /// IFR time in minutes.
  final int ifrMinutes;

  /// Simulated instrument time in minutes.
  final int simInstMinutes;

  /// Flight simulator or FSTD time in minutes.
  final int fstdMinutes;

  /// Dual instruction time in minutes.
  final int dualMinutes;

  /// Public API documentation.
  final int picMinutes;

  /// Public API documentation.
  final int picusMinutes;

  /// PIC + PICUS time in minutes.
  final int picPicusMinutes;

  /// SIC time in minutes.
  final int sicMinutes;

  /// Time logged as instructor in minutes.
  final int instructorMinutes;

  /// Total block or flight time in minutes.
  final int totalMinutes;

  /// Additional dynamic values used by template‑specific columns.
  final Map<String, String> extra;

  /// Optional per-key image payloads for template cells.
  final Map<String, Uint8List> extraImages;
}

/// Simple value object containing PIC and SIC names for a row.
class ReportEntryCrewNames {
  /// Creates a new pair of crew names.
  const ReportEntryCrewNames({
    this.pic = '',
    this.sic = '',
  });

  /// Name of the pilot‑in‑command.
  final String pic;

  /// Name of the second‑in‑command.
  final String sic;
}

/// Aggregate totals used when rendering report summaries.
class ReportTemplateTotals {
  /// Creates a new totals object with optional initial values.
  const ReportTemplateTotals({
    /// Number of instrument approaches.
    this.ifrApproaches = 0,

    /// Total landings (day + night).
    this.landingsTotal = 0,
    this.takeoffsTotal = 0,
    this.takeoffsDay = 0,
    this.takeoffsNight = 0,
    this.landingsDay = 0,
    this.landingsNight = 0,

    /// Single‑engine land minutes.
    this.selMinutes = 0,

    /// Multi‑engine land minutes.
    this.melMinutes = 0,

    /// Cross‑country minutes.
    this.xcMinutes = 0,

    /// Day minutes.
    this.dayMinutes = 0,

    /// Night minutes.
    this.nightMinutes = 0,
    this.ifrMinutes = 0,

    /// Simulated instrument minutes.
    this.simInstMinutes = 0,
    this.fstdMinutes = 0,
    this.dualMinutes = 0,
    this.picMinutes = 0,
    this.picusMinutes = 0,
    this.picPicusMinutes = 0,
    this.sicMinutes = 0,
    this.instructorMinutes = 0,
    this.totalMinutes = 0,
  });

  /// Number of instrument approaches.
  final int ifrApproaches;

  /// Total landings (day + night).
  final int landingsTotal;

  /// Total take‑offs (day + night).
  final int takeoffsTotal;

  /// Day take‑offs.
  final int takeoffsDay;

  /// Night take‑offs.
  final int takeoffsNight;

  /// Day landings.
  final int landingsDay;

  /// Night landings.
  final int landingsNight;

  /// Single‑engine land minutes.
  final int selMinutes;

  /// Multi‑engine land minutes.
  final int melMinutes;

  /// Cross‑country minutes.
  final int xcMinutes;

  /// Day minutes.
  final int dayMinutes;

  /// Night minutes.
  final int nightMinutes;

  /// IFR minutes.
  final int ifrMinutes;

  /// Simulated instrument minutes.
  final int simInstMinutes;

  /// Flight simulator or FSTD minutes.
  final int fstdMinutes;

  /// Dual instruction minutes.
  final int dualMinutes;

  /// Public API documentation.
  final int picMinutes;

  /// Public API documentation.
  final int picusMinutes;

  /// PIC + PICUS minutes.
  final int picPicusMinutes;

  /// SIC minutes.
  final int sicMinutes;

  /// Instructor minutes.
  final int instructorMinutes;

  /// Total minutes across all categories.
  final int totalMinutes;

  /// Returns new totals with values from [row] added.
  ReportTemplateTotals addRow(ReportTemplateRow row) {
    return ReportTemplateTotals(
      ifrApproaches: ifrApproaches + row.ifrApproaches,
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
      picMinutes: picMinutes + row.picMinutes,
      picusMinutes: picusMinutes + row.picusMinutes,
      picPicusMinutes: picPicusMinutes + row.picPicusMinutes,
      sicMinutes: sicMinutes + row.sicMinutes,
      instructorMinutes: instructorMinutes + row.instructorMinutes,
      totalMinutes: totalMinutes + row.totalMinutes,
    );
  }

  /// Returns new totals that are the sum of `this` and [other].
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
      picMinutes: picMinutes + other.picMinutes,
      picusMinutes: picusMinutes + other.picusMinutes,
      picPicusMinutes: picPicusMinutes + other.picPicusMinutes,
      sicMinutes: sicMinutes + other.sicMinutes,
      instructorMinutes: instructorMinutes + other.instructorMinutes,
      totalMinutes: totalMinutes + other.totalMinutes,
    );
  }
}

/// Application‑level service responsible for building logbook PDF reports.
class ReportPdfApplicationService {
  /// Creates a new instance of the service.
  const ReportPdfApplicationService();

  static const String _datePatternDdMmYyyy = 'dd-MM-yyyy';
  static const String _datePatternDdMmmYy = 'dd/MMM/yy';
  static const String _datePatternYyyyMmDd = 'yyyy-MM-dd';
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
    'pic',
    'picus',
    'picPicus',
    'sic',
    'instructor',
    'total',
  };

  /// Generates a PDF document based on the
  /// given [template] and logbook [entries].
  Future<Uint8List> generateFromTemplate({
    required ReportPdfTemplate template,
    required List<LogbookEntry> entries,
    required ReportTemplateTotals startingTotals,
    Map<String, String> coverValues = const <String, String>{},
    Map<String, Uint8List> coverImages = const <String, Uint8List>{},
    Map<int, ReportEntryCrewNames> flightCrewById = const {},
    Map<int, ReportEntryCrewNames> simulatorCrewById = const {},
  }) async {
    final pageFormat = _resolvePageFormat(template);
    final requiredRowKeys = _collectRequiredRowKeys(template);
    final rows = buildRows(
      entries,
      flightCrewById: flightCrewById,
      simulatorCrewById: simulatorCrewById,
      dateFormat: template.dateFormat,
      timeFormat: template.timeFormat,
      requiredExtraKeys: requiredRowKeys
          .where((key) => !_baseRowKeys.contains(key))
          .toSet(),
    );
    return _generatePdf(
      template: template,
      rows: rows,
      startingTotals: startingTotals,
      coverValues: coverValues,
      coverImages: coverImages,
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
    required Map<String, Uint8List> coverImages,
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
            coverImages: coverImages,
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

    final useDecimalTimeTotals =
        template.timeFormat == ReportPdfTimeFormat.decimalHours;
    var carry = _normalizeTotalsForTimeFormat(
      startingTotals,
      template.timeFormat,
    );
    for (var index = 0; index < pages.length; index++) {
      final pageRows = List<ReportTemplateRow>.from(pages[index]);
      final pageTotals = _sumRowsForTimeFormat(pageRows, template.timeFormat);
      while (pageRows.length < rowsPerPage) {
        pageRows.add(
          const ReportTemplateRow(
            date: '',
            aircraftModel: '',
            aircraftRegistration: '',
            fromIcao: '',
            toIcao: '',
            remarks: '',
            isSimulatorEntry: false,
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
            picMinutes: 0,
            picusMinutes: 0,
            picPicusMinutes: 0,
            sicMinutes: 0,
            instructorMinutes: 0,
            totalMinutes: 0,
          ),
        );
      }
      final after = carry.addTotals(pageTotals);

      final pageTotalsMap = _totalsToMap(
        pageTotals,
        template.timeFormat,
        useDecimalTimeTotals,
      );
      final carryMap = _totalsToMap(
        carry,
        template.timeFormat,
        useDecimalTimeTotals,
      );
      final afterMap = _totalsToMap(
        after,
        template.timeFormat,
        useDecimalTimeTotals,
      );

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
    required Map<String, Uint8List> coverImages,
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
        case ReportPdfCoverBlockType.signature:
          children.add(
            _buildCoverSignature(
              block: block,
              coverImages: coverImages,
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

  pw.Widget _buildCoverSignature({
    required ReportPdfCoverBlockConfig block,
    required Map<String, Uint8List> coverImages,
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
    final key = (block.valueKey ?? '').trim();
    final bytes = key.isEmpty ? null : coverImages[key];
    final width = block.width ?? 170;
    final height = block.height ?? 70;
    children.add(
      pw.Container(
        width: width,
        height: height,
        decoration: block.showBorder
            ? pw.BoxDecoration(border: pw.Border.all())
            : null,
        alignment: pw.Alignment.center,
        child: (bytes == null || bytes.isEmpty)
            ? pw.Text('-', style: const pw.TextStyle(fontSize: 10))
            : pw.Image(
                pw.MemoryImage(bytes),
              ),
      ),
    );
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: children,
    );
  }

  /// Builds flattened rows from raw [entries] for use by report templates.
  List<ReportTemplateRow> buildRows(
    List<LogbookEntry> entries, {
    Map<int, ReportEntryCrewNames> flightCrewById = const {},
    Map<int, ReportEntryCrewNames> simulatorCrewById = const {},
    ReportPdfDateFormat dateFormat = ReportPdfDateFormat.ddMmYyyy,
    ReportPdfTimeFormat timeFormat = ReportPdfTimeFormat.hMm,
    Set<String> requiredExtraKeys = const <String>{},
  }) {
    final sortedEntries = [...entries]
      ..sort(
        (a, b) => a.timeLine.eventDateTime.compareTo(b.timeLine.eventDateTime),
      );
    return sortedEntries
        .where(
          (entry) =>
              entry.type == LogbookEventType.flight ||
              entry.type == LogbookEventType.simulatorTraining,
        )
        .map((entry) {
          final flight = entry.flight;
          final sim = entry.simulatorTraining;
          final type = entry.aircraftType;
          final isFlight = entry.type == LogbookEventType.flight;
          final isSimulator = entry.type == LogbookEventType.simulatorTraining;
          final rowDate = _formatDate(
            entry.timeLine.eventDateTime.toUtc(),
            dateFormat,
          );
          final flightRemarks = (flight?.remarks ?? '').trim();
          final simulatorRemarks = (sim?.remarks ?? '').trim();
          final sharedRemarks = (flight?.remarks ?? sim?.remarks ?? '').trim();
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

          final totalMinutes = flight?.timeBlockMinutes ?? sim?.timeTotal ?? 0;

          /// Night portion of the total block time.
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
            date: isFlight ? rowDate : '',
            aircraftModel: isFlight ? (type?.code ?? '') : '',
            aircraftRegistration: entry.aircraft?.registration ?? '',
            fromIcao: entry.departureAirport?.icao ?? '',
            toIcao: entry.arrivalAirport?.icao ?? '',
            remarks: isFlight ? flightRemarks : '',
            isSimulatorEntry: isSimulator,
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
            picMinutes: flight?.timePICMinutes ?? 0,
            picusMinutes: flight?.timePICUSMinutes ?? 0,
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
              rowDate: rowDate,
              flightDate: isFlight ? rowDate : '',
              simDate: isSimulator ? rowDate : '',
              flightType: isFlight ? (type?.code ?? '') : '',
              simType: type?.code ?? '',
              isSimulator: isSimulator,
              dateFormat: dateFormat,
              timeFormat: timeFormat,
              sharedRemarks: sharedRemarks,
              simulatorRemarks: simulatorRemarks,
            ),
            extraImages: _buildExtraRowImages(
              entry: entry,
              requiredExtraKeys: requiredExtraKeys,
              isFlight: isFlight,
              isSimulator: isSimulator,
            ),
          );
        })
        .toList(growable: false);
  }

  Map<String, Uint8List> _buildExtraRowImages({
    required LogbookEntry entry,
    required Set<String> requiredExtraKeys,
    required bool isFlight,
    required bool isSimulator,
  }) {
    final map = <String, Uint8List>{};
    void put(String key, Uint8List? value) {
      if (!requiredExtraKeys.contains(key)) {
        return;
      }
      if (value == null || value.isEmpty) {
        return;
      }
      map[key] = value;
    }

    final flightSignature = isFlight ? entry.flight?.signatureImage : null;
    final simSignature = isSimulator
        ? entry.simulatorTraining?.signatureImage
        : null;
    final anySignature = flightSignature ?? simSignature;
    put('anySignature', anySignature);
    put('flightSignature', flightSignature);
    put('simSignature', simSignature);
    return map;
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
    required String rowDate,
    required String flightDate,
    required String simDate,
    required String flightType,
    required String simType,
    required bool isSimulator,
    required ReportPdfDateFormat dateFormat,
    required ReportPdfTimeFormat timeFormat,
    required String sharedRemarks,
    required String simulatorRemarks,
  }) {
    final flight = entry.flight;
    final sim = entry.simulatorTraining;
    final isFlight = flight != null;
    final type = entry.aircraftType;
    final timeline = entry.timeLine.eventDateTime.toUtc();
    final depTime = isFlight ? timeline : null;
    final arrTime = flight?.arrivalDateTime?.toUtc();
    final takeoffTime = flight?.takeOffDateTime?.toUtc();
    final landingTime = flight?.landingDateTime?.toUtc();
    final simEndTime = sim?.endDateTime?.toUtc();
    final anyEndTime = arrTime ?? simEndTime;
    final anyRemarks = (flight?.remarks ?? sim?.remarks ?? '').trim();
    final anyNotes = (flight?.notes ?? sim?.notes ?? '').trim();
    final typeCode = type?.code ?? '';
    final typeFamily = type?.family ?? '';
    final typeLongName = type?.longName ?? '';
    final typeManufacturer = type?.manufacturer ?? '';
    final typeCategory = type?.category.name ?? '';
    final typeEngineType = type?.engineType.name ?? '';
    final typeMtow = type == null ? '' : type.mtow.toString();
    final aircraftRegistration = entry.aircraft?.registration ?? '';
    final aircraftMtow = entry.aircraft?.mtow?.toString() ?? '';
    final departureAirport = entry.departureAirport;
    final arrivalAirport = entry.arrivalAirport;
    final map = <String, String>{};
    void put(String key, String value) {
      if (requiredExtraKeys.contains(key)) {
        map[key] = value;
      }
    }

    put('eventType', entry.type.name);
    put('anyDate', _formatDate(timeline, dateFormat));
    put(
      'anyDateEnd',
      anyEndTime == null ? '' : _formatDate(anyEndTime, dateFormat),
    );
    put('anyStartTime', _formatHm(timeline, timeFormat));
    put('anyEndTime', _formatHm(anyEndTime, timeFormat));
    put('anyTypeCode', typeCode);
    put('anyTypeFamily', typeFamily);
    put('anyTypeLongName', typeLongName);
    put('anyTypeManufacturer', typeManufacturer);
    put('anyTypeCategory', typeCategory);
    put('anyTypeEngineType', typeEngineType);
    put('anyTypeMtow', typeMtow);
    put('anyAircraftRegistration', aircraftRegistration);
    put('anyAircraftMtow', aircraftMtow);
    put('anyPIC', crew.pic);
    put('anySIC', crew.sic);
    put('anySignature', '');
    put('anyRemarks', anyRemarks);
    put('anyNotes', anyNotes);

    put(
      'flightDateChocksOff',
      isFlight ? _formatDate(timeline, dateFormat) : '',
    );
    put(
      'flightDateTakeOff',
      isFlight && takeoffTime != null
          ? _formatDate(takeoffTime, dateFormat)
          : '',
    );
    put(
      'flightDateLanding',
      isFlight && landingTime != null
          ? _formatDate(landingTime, dateFormat)
          : '',
    );
    put(
      'flightDateChocksOn',
      isFlight && arrTime != null ? _formatDate(arrTime, dateFormat) : '',
    );
    put('flightTimeChocksOff', _formatHm24(depTime));
    put('flightTimeTakeOff', _formatHm24(takeoffTime));
    put('flightTimeLanding', _formatHm24(landingTime));
    put('flightTimeChocksOn', _formatHm24(arrTime));
    put('flightTypeCode', isFlight ? typeCode : '');
    put('flightTypeFamily', isFlight ? typeFamily : '');
    put('flightTypeLongName', isFlight ? typeLongName : '');
    put('flightTypeManufacturer', isFlight ? typeManufacturer : '');
    put('flightTypeCategory', isFlight ? typeCategory : '');
    put('flightTypeEngineType', isFlight ? typeEngineType : '');
    put('flightTypeMtow', isFlight ? typeMtow : '');
    put('flightAircraftRegistration', isFlight ? aircraftRegistration : '');
    put('flightAircraftMtow', isFlight ? aircraftMtow : '');
    put('flightPIC', isFlight ? crew.pic : '');
    put('flightSIC', isFlight ? crew.sic : '');
    put('flightSignature', '');
    put('flightRemarks', isFlight ? flight.remarks.trim() : '');
    put('flightNotes', isFlight ? flight.notes.trim() : '');
    put('fromIcao', isFlight ? (departureAirport?.icao ?? '') : '');
    put('fromIata', isFlight ? (departureAirport?.iata ?? '') : '');
    put('fromName', isFlight ? (departureAirport?.name ?? '') : '');
    put('fromCity', isFlight ? (departureAirport?.city ?? '') : '');
    put('fromCountry', isFlight ? (departureAirport?.country ?? '') : '');
    put('toIcao', isFlight ? (arrivalAirport?.icao ?? '') : '');
    put('toIata', isFlight ? (arrivalAirport?.iata ?? '') : '');
    put('toName', isFlight ? (arrivalAirport?.name ?? '') : '');
    put('toCity', isFlight ? (arrivalAirport?.city ?? '') : '');
    put('toCountry', isFlight ? (arrivalAirport?.country ?? '') : '');
    put('timePIC', _emptyIfZeroTime(flight?.timePICMinutes ?? 0, timeFormat));
    put(
      'timePICUS',
      _emptyIfZeroTime(flight?.timePICUSMinutes ?? 0, timeFormat),
    );
    put('timeSIC', _emptyIfZeroTime(flight?.timeSICMinutes ?? 0, timeFormat));
    put('timeDual', _emptyIfZeroTime(flight?.timeDualMinutes ?? 0, timeFormat));
    put(
      'timeInstructor',
      _emptyIfZeroTime(flight?.timeInstructorMinutes ?? 0, timeFormat),
    );
    put('timeIFR', _emptyIfZeroTime(flight?.timeIFRMinutes ?? 0, timeFormat));
    put(
      'timeInstrument',
      _emptyIfZeroTime(flight?.timeInstrumentMinutes ?? 0, timeFormat),
    );
    put(
      'timeSimulatedInstrument',
      _emptyIfZeroTime(flight?.timeSimulatedInstrumentMinutes ?? 0, timeFormat),
    );
    put(
      'timeNight',
      _emptyIfZeroTime(flight?.timeNightMinutes ?? 0, timeFormat),
    );
    put(
      'timeCrossCountry',
      _emptyIfZeroTime(flight?.timeCrossCountryMinutes ?? 0, timeFormat),
    );
    put(
      'timeCustom1',
      _emptyIfZeroTime(flight?.timeCustom1Minutes ?? 0, timeFormat),
    );
    put(
      'timeCustom2',
      _emptyIfZeroTime(flight?.timeCustom2Minutes ?? 0, timeFormat),
    );
    put(
      'timeCustom3',
      _emptyIfZeroTime(flight?.timeCustom3Minutes ?? 0, timeFormat),
    );
    put(
      'timeCustom4',
      _emptyIfZeroTime(flight?.timeCustom4Minutes ?? 0, timeFormat),
    );
    put(
      'timeFlight',
      _emptyIfZeroTime(flight?.timeFlightMinutes ?? 0, timeFormat),
    );
    put(
      'timeBlock',
      _emptyIfZeroTime(flight?.timeBlockMinutes ?? 0, timeFormat),
    );
    put(
      'timeTotalBlock',
      _emptyIfZeroTime(flight?.timeTotalBlockMinutes ?? 0, timeFormat),
    );
    put('distanceNM', _emptyIfZeroInt(flight?.distanceNM ?? 0));
    put('takeOffsDays', _emptyIfZeroInt(flight?.takeOffsDays ?? 0));
    put('takeOffsNight', _emptyIfZeroInt(flight?.takeOffsNight ?? 0));
    put('landingsDay', _emptyIfZeroInt(flight?.landingsDay ?? 0));
    put('landingsNight', _emptyIfZeroInt(flight?.landingsNight ?? 0));
    put('pilotFunction', flight?.pilotFunction ?? '');
    put('approachType', flight?.approachType ?? '');

    put('simDate', isSimulator ? _formatDate(timeline, dateFormat) : '');
    put(
      'simDateEnd',
      isSimulator && simEndTime != null
          ? _formatDate(simEndTime, dateFormat)
          : '',
    );
    put('simStartTime', _formatHm(isSimulator ? timeline : null, timeFormat));
    put('simEndTime', _formatHm(simEndTime, timeFormat));
    put('SimEndTime', _formatHm(simEndTime, timeFormat));
    put('simTypeCode', isSimulator ? typeCode : '');
    put('simTypeFamily', isSimulator ? typeFamily : '');
    put('simTypeLongName', isSimulator ? typeLongName : '');
    put('simTypeManufacturer', isSimulator ? typeManufacturer : '');
    put('simTypeCategory', isSimulator ? typeCategory : '');
    put('simTypeEngineType', isSimulator ? typeEngineType : '');
    put('simTypeMtow', isSimulator ? typeMtow : '');
    put('simAircraftRegistration', isSimulator ? aircraftRegistration : '');
    put('simAircraftMtow', isSimulator ? aircraftMtow : '');
    put('simPIC', isSimulator ? crew.pic : '');
    put('simSIC', isSimulator ? crew.sic : '');
    put('simSignature', '');
    put('simRemarks', isSimulator ? simulatorRemarks : '');
    put('simNotes', isSimulator ? (sim?.notes ?? '').trim() : '');
    put(
      'simSessionTime',
      isSimulator ? _emptyIfZeroTime(sim?.timeTotal ?? 0, timeFormat) : '',
    );
    put('entryDate', rowDate);
    put('entryType', isSimulator ? simType : flightType);
    put('entryRegistration', entry.aircraft?.registration ?? '');
    put('entryRemarks', sharedRemarks);
    put('flightDate', flightDate);
    put('simDate', simDate);
    put('flightType', flightType);
    put('simType', isSimulator ? simType : '');
    final simRegistration = isSimulator
        ? (entry.aircraft?.registration ?? '')
        : '';
    put(
      'simRegistration',
      simRegistration,
    );
    put(
      'simTypeRegistration',
      isSimulator
          ? [
              simType.trim(),
              simRegistration.trim(),
            ].where((part) => part.isNotEmpty).join(' - ')
          : '',
    );
    put(
      'simSessionTotal',
      isSimulator ? _emptyIfZeroTime(sim?.timeTotal ?? 0, timeFormat) : '',
    );
    put('simRemarks', isSimulator ? simulatorRemarks : '');
    put('simRemarksPage2', simulatorRemarks);
    put('departureTime', _formatHm(depTime, timeFormat));
    put('arrivalTime', _formatHm(arrTime, timeFormat));
    put('depTime', _formatHm(depTime, timeFormat));
    put('arrTime', _formatHm(arrTime, timeFormat));
    put('takeoffTime', _formatHm(takeoffTime, timeFormat));
    put('landingTime', _formatHm(landingTime, timeFormat));
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
    put('singlePilotSel', _emptyIfZeroTime(singlePilotSelMinutes, timeFormat));
    put('singlePilotMel', _emptyIfZeroTime(singlePilotMelMinutes, timeFormat));
    put('multiPilotTime', _emptyIfZeroTime(multiPilotMinutes, timeFormat));
    put('complexTime', _emptyIfZeroTime(complexMinutes, timeFormat));
    put('efisTime', _emptyIfZeroTime(efisMinutes, timeFormat));
    put(
      'highPerformanceTime',
      _emptyIfZeroTime(highPerformanceMinutes, timeFormat),
    );
    put(
      'picPlusPicus',
      _emptyIfZeroTime(
        (flight?.timePICMinutes ?? 0) + (flight?.timePICUSMinutes ?? 0),
        timeFormat,
      ),
    );
    put(
      'picWithoutPicus',
      _emptyIfZeroTime(flight?.timePICMinutes ?? 0, timeFormat),
    );
    put('picus', _emptyIfZeroTime(flight?.timePICUSMinutes ?? 0, timeFormat));
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

  String _formatDate(DateTime value, ReportPdfDateFormat dateFormat) {
    final pattern = switch (dateFormat) {
      ReportPdfDateFormat.ddMmYyyy => _datePatternDdMmYyyy,
      ReportPdfDateFormat.ddMmmYy => _datePatternDdMmmYy,
      ReportPdfDateFormat.yyyyMmDd => _datePatternYyyyMmDd,
    };
    return DateFormat(pattern).format(value.toUtc());
  }

  String _formatHm(DateTime? value, ReportPdfTimeFormat timeFormat) {
    if (value == null) return '';
    final utc = value.toUtc();
    if (timeFormat == ReportPdfTimeFormat.decimalHours) {
      return _formatDecimalHundredths(
        _minutesToDecimalHundredths(utc.hour * 60 + utc.minute),
      );
    }
    final pattern = timeFormat == ReportPdfTimeFormat.hhMm ? 'HH:mm' : 'H:mm';
    return DateFormat(pattern).format(utc);
  }

  String _formatHm24(DateTime? value) {
    if (value == null) return '';
    return DateFormat('HH:mm').format(value.toUtc());
  }

  int _minutesToDecimalHundredths(int minutes) {
    if (minutes <= 0) {
      return 0;
    }
    return ((minutes / 60) * 100).round();
  }

  String _formatDecimalHundredths(int hundredths) {
    return (hundredths / 100).toStringAsFixed(2);
  }

  /// Sums [rows] into a single [ReportTemplateTotals] instance.
  ReportTemplateTotals sumTotals(List<ReportTemplateRow> rows) {
    var totals = const ReportTemplateTotals();
    for (final row in rows) {
      totals = totals.addRow(row);
    }
    return totals;
  }

  ReportTemplateTotals _sumRowsForTimeFormat(
    List<ReportTemplateRow> rows,
    ReportPdfTimeFormat timeFormat,
  ) {
    if (timeFormat != ReportPdfTimeFormat.decimalHours) {
      return sumTotals(rows);
    }
    var totals = const ReportTemplateTotals();
    for (final row in rows) {
      totals = totals.addRow(
        ReportTemplateRow(
          date: row.date,
          aircraftModel: row.aircraftModel,
          aircraftRegistration: row.aircraftRegistration,
          fromIcao: row.fromIcao,
          toIcao: row.toIcao,
          remarks: row.remarks,
          isSimulatorEntry: row.isSimulatorEntry,
          ifrApproaches: row.ifrApproaches,
          landingsTotal: row.landingsTotal,
          takeoffsTotal: row.takeoffsTotal,
          takeoffsDay: row.takeoffsDay,
          takeoffsNight: row.takeoffsNight,
          landingsDay: row.landingsDay,
          landingsNight: row.landingsNight,
          selMinutes: _minutesToDecimalHundredths(row.selMinutes),
          melMinutes: _minutesToDecimalHundredths(row.melMinutes),
          xcMinutes: _minutesToDecimalHundredths(row.xcMinutes),
          dayMinutes: _minutesToDecimalHundredths(row.dayMinutes),
          nightMinutes: _minutesToDecimalHundredths(row.nightMinutes),
          ifrMinutes: _minutesToDecimalHundredths(row.ifrMinutes),
          simInstMinutes: _minutesToDecimalHundredths(row.simInstMinutes),
          fstdMinutes: _minutesToDecimalHundredths(row.fstdMinutes),
          dualMinutes: _minutesToDecimalHundredths(row.dualMinutes),
          picMinutes: _minutesToDecimalHundredths(row.picMinutes),
          picusMinutes: _minutesToDecimalHundredths(row.picusMinutes),
          picPicusMinutes: _minutesToDecimalHundredths(row.picPicusMinutes),
          sicMinutes: _minutesToDecimalHundredths(row.sicMinutes),
          instructorMinutes: _minutesToDecimalHundredths(row.instructorMinutes),
          totalMinutes: _minutesToDecimalHundredths(row.totalMinutes),
          extra: row.extra,
        ),
      );
    }
    return totals;
  }

  ReportTemplateTotals _normalizeTotalsForTimeFormat(
    ReportTemplateTotals totals,
    ReportPdfTimeFormat timeFormat,
  ) {
    if (timeFormat != ReportPdfTimeFormat.decimalHours) {
      return totals;
    }
    return ReportTemplateTotals(
      ifrApproaches: totals.ifrApproaches,
      landingsTotal: totals.landingsTotal,
      takeoffsTotal: totals.takeoffsTotal,
      takeoffsDay: totals.takeoffsDay,
      takeoffsNight: totals.takeoffsNight,
      landingsDay: totals.landingsDay,
      landingsNight: totals.landingsNight,
      selMinutes: _minutesToDecimalHundredths(totals.selMinutes),
      melMinutes: _minutesToDecimalHundredths(totals.melMinutes),
      xcMinutes: _minutesToDecimalHundredths(totals.xcMinutes),
      dayMinutes: _minutesToDecimalHundredths(totals.dayMinutes),
      nightMinutes: _minutesToDecimalHundredths(totals.nightMinutes),
      ifrMinutes: _minutesToDecimalHundredths(totals.ifrMinutes),
      simInstMinutes: _minutesToDecimalHundredths(totals.simInstMinutes),
      fstdMinutes: _minutesToDecimalHundredths(totals.fstdMinutes),
      dualMinutes: _minutesToDecimalHundredths(totals.dualMinutes),
      picMinutes: _minutesToDecimalHundredths(totals.picMinutes),
      picusMinutes: _minutesToDecimalHundredths(totals.picusMinutes),
      picPicusMinutes: _minutesToDecimalHundredths(totals.picPicusMinutes),
      sicMinutes: _minutesToDecimalHundredths(totals.sicMinutes),
      instructorMinutes: _minutesToDecimalHundredths(totals.instructorMinutes),
      totalMinutes: _minutesToDecimalHundredths(totals.totalMinutes),
    );
  }

  /// Computes totals directly from logbook [entries] without building rows.
  ReportTemplateTotals sumTotalsFromEntries(
    List<LogbookEntry> entries, {
    ReportPdfTimeFormat timeFormat = ReportPdfTimeFormat.hMm,
  }) {
    final useDecimalUnits = timeFormat == ReportPdfTimeFormat.decimalHours;
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
    var picMinutes = 0;
    var picusMinutes = 0;
    var picPicusMinutes = 0;
    var sicMinutes = 0;
    var instructorMinutes = 0;
    var totalMinutes = 0;

    for (final entry in entries) {
      final isSupportedType =
          entry.type == LogbookEventType.flight ||
          entry.type == LogbookEventType.simulatorTraining;
      if (!isSupportedType) {
        continue;
      }
      final flight = entry.flight;
      final sim = entry.simulatorTraining;
      final type = entry.aircraftType;

      final rowTotalMinutes = flight?.timeBlockMinutes ?? sim?.timeTotal ?? 0;
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
      selMinutes += useDecimalUnits
          ? _minutesToDecimalHundredths(rowSelMinutes)
          : rowSelMinutes;
      melMinutes += useDecimalUnits
          ? _minutesToDecimalHundredths(rowMelMinutes)
          : rowMelMinutes;
      xcMinutes += useDecimalUnits
          ? _minutesToDecimalHundredths(flight?.timeCrossCountryMinutes ?? 0)
          : (flight?.timeCrossCountryMinutes ?? 0);
      dayMinutes += useDecimalUnits
          ? _minutesToDecimalHundredths(rowDayMinutes)
          : rowDayMinutes;
      nightMinutes += useDecimalUnits
          ? _minutesToDecimalHundredths(rowNightMinutes)
          : rowNightMinutes;
      ifrMinutes += useDecimalUnits
          ? _minutesToDecimalHundredths(flight?.timeIFRMinutes ?? 0)
          : (flight?.timeIFRMinutes ?? 0);
      simInstMinutes += useDecimalUnits
          ? _minutesToDecimalHundredths(
              (flight?.timeInstrumentMinutes ?? 0) +
                  (flight?.timeSimulatedInstrumentMinutes ?? 0),
            )
          : (flight?.timeInstrumentMinutes ?? 0) +
                (flight?.timeSimulatedInstrumentMinutes ?? 0);
      fstdMinutes += useDecimalUnits
          ? _minutesToDecimalHundredths(sim?.timeTotal ?? 0)
          : (sim?.timeTotal ?? 0);
      dualMinutes += useDecimalUnits
          ? _minutesToDecimalHundredths(flight?.timeDualMinutes ?? 0)
          : (flight?.timeDualMinutes ?? 0);
      picMinutes += useDecimalUnits
          ? _minutesToDecimalHundredths(flight?.timePICMinutes ?? 0)
          : (flight?.timePICMinutes ?? 0);
      picusMinutes += useDecimalUnits
          ? _minutesToDecimalHundredths(flight?.timePICUSMinutes ?? 0)
          : (flight?.timePICUSMinutes ?? 0);
      picPicusMinutes += useDecimalUnits
          ? _minutesToDecimalHundredths(
              (flight?.timePICMinutes ?? 0) + (flight?.timePICUSMinutes ?? 0),
            )
          : (flight?.timePICMinutes ?? 0) + (flight?.timePICUSMinutes ?? 0);
      sicMinutes += useDecimalUnits
          ? _minutesToDecimalHundredths(flight?.timeSICMinutes ?? 0)
          : (flight?.timeSICMinutes ?? 0);
      instructorMinutes += useDecimalUnits
          ? _minutesToDecimalHundredths(flight?.timeInstructorMinutes ?? 0)
          : (flight?.timeInstructorMinutes ?? 0);
      totalMinutes += useDecimalUnits
          ? _minutesToDecimalHundredths(rowTotalMinutes)
          : rowTotalMinutes;
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
      picMinutes: picMinutes,
      picusMinutes: picusMinutes,
      picPicusMinutes: picPicusMinutes,
      sicMinutes: sicMinutes,
      instructorMinutes: instructorMinutes,
      totalMinutes: totalMinutes,
    );
  }

  String _rowValueForKey(
    ReportTemplateRow row,
    String key,
    ReportPdfTimeFormat timeFormat,
  ) {
    if (row.isSimulatorEntry) {
      if (key == 'fstd') {
        return _emptyIfZeroTime(row.fstdMinutes, timeFormat);
      }
      return row.extra[key] ?? '';
    }

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
        return _emptyIfZeroTime(row.selMinutes, timeFormat);
      case 'mel':
        return _emptyIfZeroTime(row.melMinutes, timeFormat);
      case 'xc':
        return _emptyIfZeroTime(row.xcMinutes, timeFormat);
      case 'day':
        return _emptyIfZeroTime(row.dayMinutes, timeFormat);
      case 'night':
        return _emptyIfZeroTime(row.nightMinutes, timeFormat);
      case 'ifr':
        return _emptyIfZeroTime(row.ifrMinutes, timeFormat);
      case 'simInst':
        return _emptyIfZeroTime(row.simInstMinutes, timeFormat);
      case 'fstd':
        return _emptyIfZeroTime(row.fstdMinutes, timeFormat);
      case 'dual':
        return _emptyIfZeroTime(row.dualMinutes, timeFormat);
      case 'pic':
        return _emptyIfZeroTime(row.picMinutes, timeFormat);
      case 'picus':
        return _emptyIfZeroTime(row.picusMinutes, timeFormat);
      case 'picPicus':
        return _emptyIfZeroTime(row.picPicusMinutes, timeFormat);
      case 'sic':
        return _emptyIfZeroTime(row.sicMinutes, timeFormat);
      case 'instructor':
        return _emptyIfZeroTime(row.instructorMinutes, timeFormat);
      case 'total':
        return _emptyIfZeroTime(row.totalMinutes, timeFormat);
      default:
        return row.extra[key] ?? '';
    }
  }

  Map<String, String> _totalsToMap(
    ReportTemplateTotals totals,
    ReportPdfTimeFormat timeFormat,
    bool valuesAreDecimalHundredths,
  ) {
    return {
      'ifrApproaches': _emptyIfZeroInt(totals.ifrApproaches),
      'landings': _emptyIfZeroInt(totals.landingsTotal),
      'takeoffs': _emptyIfZeroInt(totals.takeoffsTotal),
      'landingDay': _emptyIfZeroInt(totals.landingsDay),
      'landingNight': _emptyIfZeroInt(totals.landingsNight),
      'takeoffDay': _emptyIfZeroInt(totals.takeoffsDay),
      'takeoffNight': _emptyIfZeroInt(totals.takeoffsNight),
      'sel': _emptyIfZeroTime(
        totals.selMinutes,
        timeFormat,
        valueIsDecimalHundredths: valuesAreDecimalHundredths,
      ),
      'mel': _emptyIfZeroTime(
        totals.melMinutes,
        timeFormat,
        valueIsDecimalHundredths: valuesAreDecimalHundredths,
      ),
      'xc': _emptyIfZeroTime(
        totals.xcMinutes,
        timeFormat,
        valueIsDecimalHundredths: valuesAreDecimalHundredths,
      ),
      'day': _emptyIfZeroTime(
        totals.dayMinutes,
        timeFormat,
        valueIsDecimalHundredths: valuesAreDecimalHundredths,
      ),
      'night': _emptyIfZeroTime(
        totals.nightMinutes,
        timeFormat,
        valueIsDecimalHundredths: valuesAreDecimalHundredths,
      ),
      'ifr': _emptyIfZeroTime(
        totals.ifrMinutes,
        timeFormat,
        valueIsDecimalHundredths: valuesAreDecimalHundredths,
      ),
      'simInst': _emptyIfZeroTime(
        totals.simInstMinutes,
        timeFormat,
        valueIsDecimalHundredths: valuesAreDecimalHundredths,
      ),
      'fstd': _emptyIfZeroTime(
        totals.fstdMinutes,
        timeFormat,
        valueIsDecimalHundredths: valuesAreDecimalHundredths,
      ),
      'simSessionTotal': _emptyIfZeroTime(
        totals.fstdMinutes,
        timeFormat,
        valueIsDecimalHundredths: valuesAreDecimalHundredths,
      ),
      'dual': _emptyIfZeroTime(
        totals.dualMinutes,
        timeFormat,
        valueIsDecimalHundredths: valuesAreDecimalHundredths,
      ),
      'pic': _emptyIfZeroTime(
        totals.picMinutes,
        timeFormat,
        valueIsDecimalHundredths: valuesAreDecimalHundredths,
      ),
      'picus': _emptyIfZeroTime(
        totals.picusMinutes,
        timeFormat,
        valueIsDecimalHundredths: valuesAreDecimalHundredths,
      ),
      'picPicus': _emptyIfZeroTime(
        totals.picPicusMinutes,
        timeFormat,
        valueIsDecimalHundredths: valuesAreDecimalHundredths,
      ),
      'picPlusPicus': _emptyIfZeroTime(
        totals.picPicusMinutes,
        timeFormat,
        valueIsDecimalHundredths: valuesAreDecimalHundredths,
      ),
      'sic': _emptyIfZeroTime(
        totals.sicMinutes,
        timeFormat,
        valueIsDecimalHundredths: valuesAreDecimalHundredths,
      ),
      'instructor': _emptyIfZeroTime(
        totals.instructorMinutes,
        timeFormat,
        valueIsDecimalHundredths: valuesAreDecimalHundredths,
      ),
      'total': _emptyIfZeroTime(
        totals.totalMinutes,
        timeFormat,
        valueIsDecimalHundredths: valuesAreDecimalHundredths,
      ),
    };
  }

  String _emptyIfZeroTime(
    int timeValue,
    ReportPdfTimeFormat timeFormat, {
    bool valueIsDecimalHundredths = false,
  }) {
    if (timeValue <= 0) return '';
    if (timeFormat == ReportPdfTimeFormat.decimalHours) {
      final hundredths = valueIsDecimalHundredths
          ? timeValue
          : _minutesToDecimalHundredths(timeValue);
      return _formatDecimalHundredths(hundredths);
    }
    final hours = timeValue ~/ 60;
    final mins = (timeValue % 60).toString().padLeft(2, '0');
    if (timeFormat == ReportPdfTimeFormat.hhMm) {
      return '${hours.toString().padLeft(2, '0')}:$mins';
    }
    return '$hours:$mins';
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
        final alternateRowColor = _parsePdfColor(
          template.alternateRowBackgroundColorHex,
        );
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
          final fillColor =
              (alternateRowColor != null &&
                  cell.dataRowIndex != null &&
                  cell.dataRowIndex!.isOdd)
              ? alternateRowColor
              : null;
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
                  decoration: pw.BoxDecoration(
                    color: fillColor,
                    border: const pw.Border(
                      left: pw.BorderSide(),
                      right: pw.BorderSide(),
                      top: pw.BorderSide(),
                      bottom: pw.BorderSide(),
                    ),
                  ),
                  child: _buildCellContent(cell),
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
    var dataRowIndex = 0;

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
        dataRowIndex: null,
      );
    }

    for (final row in pageRows) {
      final rowCells = table.columns
          .map(
            (column) {
              final key = column.key;
              final imageBytes = _isSignatureKey(key)
                  ? row.extraImages[key]
                  : null;
              final textValue = imageBytes == null
                  ? _rowValueForKey(row, key, template.timeFormat)
                  : '';
              return ReportPdfCellConfig(
                text: textValue,
                alignment: column.alignment,
                verticalAlignment: column.verticalAlignment,
                textStyle: column.textStyle,
                imageBytes: imageBytes,
                imageWidth: column.signatureWidth,
                imageHeight: column.signatureHeight,
                imageShowBorder: column.signatureShowBorder,
              );
            },
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
        dataRowIndex: dataRowIndex,
      );
      dataRowIndex++;
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
        dataRowIndex: null,
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
          dataRowIndex: null,
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
        dataRowIndex: null,
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
    required int? dataRowIndex,
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
          imageBytes: cell.imageBytes,
          imageWidth: cell.imageWidth,
          imageHeight: cell.imageHeight,
          imageShowBorder: cell.imageShowBorder,
          dataRowIndex: dataRowIndex,
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

  bool _isSignatureKey(String key) {
    return key == 'anySignature' ||
        key == 'flightSignature' ||
        key == 'simSignature';
  }

  pw.Widget _buildCellContent(_PlacedPdfCell cell) {
    final imageBytes = cell.imageBytes;
    if (imageBytes == null || imageBytes.isEmpty) {
      return pw.Text(cell.text, style: cell.style);
    }
    final image = pw.Image(
      pw.MemoryImage(imageBytes),
      width: cell.imageWidth,
      height: cell.imageHeight,
    );
    if (!cell.imageShowBorder) {
      return image;
    }
    return pw.Container(
      padding: const pw.EdgeInsets.all(1),
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
      child: image,
    );
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
    required this.imageBytes,
    required this.imageWidth,
    required this.imageHeight,
    required this.imageShowBorder,
    required this.dataRowIndex,
  });

  final int startRow;
  final int startCol;
  final int rowSpan;
  final int colSpan;
  final String text;
  final ReportPdfColumnAlignment alignment;
  final ReportPdfVerticalAlignment verticalAlignment;
  final pw.TextStyle style;
  final Uint8List? imageBytes;
  final double? imageWidth;
  final double? imageHeight;
  final bool imageShowBorder;
  final int? dataRowIndex;
}
