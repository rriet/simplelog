/// Public API documentation.
enum ReportPdfPageSize {
  /// Public API documentation.
  a4,

  /// Public API documentation.
  letter,

  /// Public API documentation.
  legal,

  /// Public API documentation.
  a5,
}

/// Public API documentation.
extension ReportPdfPageSizeMeta on ReportPdfPageSize {
  /// Public API documentation.
  String get label {
    switch (this) {
      case ReportPdfPageSize.a4:
        return 'A4';
      case ReportPdfPageSize.letter:
        return 'Letter';
      case ReportPdfPageSize.legal:

        /// Public API documentation.
        return 'Legal';

      /// Public API documentation.
      case ReportPdfPageSize.a5:

        /// Public API documentation.
        return 'A5';

      /// Public API documentation.
    }
  }
}

/// Public API documentation.

/// Public API documentation.
enum ReportPdfColumnAlignment {
  /// Public API documentation.
  left,

  /// Public API documentation.
  center,

  /// Public API documentation.
  right,
}

/// Public API documentation.
enum ReportPdfVerticalAlignment {
  /// Public API documentation.
  top,

  /// Public API documentation.
  middle,

  /// Public API documentation.
  bottom,
}

/// Public API documentation.
class ReportPdfCellTextStyle {
  /// Public API documentation.
  const ReportPdfCellTextStyle({
    this.fontSize,
    this.bold = false,
    this.italic = false,
    this.colorHex,
  });

  /// Public API documentation.
  final double? fontSize;

  /// Public API documentation.
  final bool bold;

  /// Public API documentation.
  final bool italic;

  /// Public API documentation.
  final String? colorHex;
}

/// Public API documentation.
enum ReportPdfSummarySource {
  /// Public API documentation.
  pageTotals,

  /// Public API documentation.
  totalsBefore,

  /// Public API documentation.
  totalsAfter,
}

/// Public API documentation.

/// Public API documentation.
class ReportPdfColumnConfig {
  /// Public API documentation.
  const ReportPdfColumnConfig({
    required this.key,
    this.header,
    this.width = 1,
    this.alignment = ReportPdfColumnAlignment.center,
    this.verticalAlignment = ReportPdfVerticalAlignment.middle,
    this.textStyle = const ReportPdfCellTextStyle(),

    /// Public API documentation.
  });

  /// Public API documentation.

  /// Public API documentation.
  final String key;

  /// Public API documentation.
  final String? header;

  /// Public API documentation.
  final double width;

  /// Public API documentation.
  final ReportPdfColumnAlignment alignment;

  /// Public API documentation.
  final ReportPdfVerticalAlignment verticalAlignment;

  /// Public API documentation.
  final ReportPdfCellTextStyle textStyle;
}

/// Public API documentation.
class ReportPdfCellConfig {
  /// Public API documentation.
  const ReportPdfCellConfig({
    this.text,
    this.valueToken,
    this.hspan = 1,
    this.vspan = 1,
    this.alignment,
    this.verticalAlignment,
    this.textStyle = const ReportPdfCellTextStyle(),
  });

  /// Public API documentation.
  final String? text;

  /// Public API documentation.
  final String? valueToken;

  /// Public API documentation.
  final int hspan;

  /// Public API documentation.
  final int vspan;

  /// Public API documentation.
  final ReportPdfColumnAlignment? alignment;

  /// Public API documentation.
  final ReportPdfVerticalAlignment? verticalAlignment;

  /// Public API documentation.
  final ReportPdfCellTextStyle textStyle;
}

/// Public API documentation.
class ReportPdfHeaderRowConfig {
  /// Public API documentation.
  const ReportPdfHeaderRowConfig({
    required this.cells,
    this.rowHeight,
  });

  /// Public API documentation.
  final List<ReportPdfCellConfig> cells;

  /// Public API documentation.
  final double? rowHeight;
}

/// Public API documentation.
class ReportPdfFooterRowConfig {
  /// Public API documentation.
  const ReportPdfFooterRowConfig({
    /// Public API documentation.
    required this.source,
    required this.values,
    this.cells = const [],
    this.rowHeight,
    this.labelToken,

    /// Public API documentation.
    this.literalLabel,

    /// Public API documentation.
    this.showTopBorder = false,
  });

  /// Public API documentation.
  final ReportPdfSummarySource source;

  /// Public API documentation.
  final String? labelToken;

  /// Public API documentation.
  final String? literalLabel;

  /// Public API documentation.
  final Map<String, String> values;

  /// Public API documentation.
  final List<ReportPdfCellConfig> cells;

  /// Public API documentation.
  final double? rowHeight;

  /// Public API documentation.
  final bool showTopBorder;
}

/// Public API documentation.
class ReportPdfTableConfig {
  /// Public API documentation.
  const ReportPdfTableConfig({
    required this.pageSuffix,
    required this.columns,
    this.header = const [],
    this.footer = const [],
    this.footerRows = const [],
  });

  /// Public API documentation.
  final String pageSuffix;

  /// Public API documentation.
  final List<ReportPdfHeaderRowConfig> header;

  /// Public API documentation.
  final List<ReportPdfHeaderRowConfig> footer;

  /// Public API documentation.
  final List<ReportPdfColumnConfig> columns;

  /// Public API documentation.
  final List<ReportPdfFooterRowConfig> footerRows;
}

/// Public API documentation.
class ReportPdfLabels {
  /// Public API documentation.
  const ReportPdfLabels({
    /// Public API documentation.
    this.pageTotal = 'PAGE TOTAL',

    /// Public API documentation.
    this.amountForward = 'AMT. FORWARD',

    /// Public API documentation.
    this.totalToDate = 'TOTAL TO DATE',

    /// Public API documentation.
  });

  /// Public API documentation.

  /// Public API documentation.
  final String pageTotal;

  /// Public API documentation.
  final String amountForward;

  /// Public API documentation.
  final String totalToDate;

  /// Public API documentation.
  String resolveToken(String token) {
    switch (token) {
      case 'pageTotal':
        return pageTotal;
      case 'amountForward':
        return amountForward;
      case 'totalToDate':
        return totalToDate;
      default:
        return token;
    }
  }
}

/// Public API documentation.
class ReportPdfTemplate {
  /// Public API documentation.
  const ReportPdfTemplate({
    required this.fileName,
    required this.displayName,
    required this.rowsPerPage,
    required this.tables,
    this.coverPage,
    this.forceLandscape = false,
    this.defaultPageSize = ReportPdfPageSize.letter,
    this.rowHeight = 11,
    this.labels = const ReportPdfLabels(),
  });

  /// Public API documentation.
  final String fileName;

  /// Public API documentation.
  final String displayName;

  /// Public API documentation.
  final int rowsPerPage;

  /// Public API documentation.
  final ReportPdfCoverPageConfig? coverPage;

  /// Public API documentation.
  final bool forceLandscape;

  /// Public API documentation.
  final ReportPdfPageSize defaultPageSize;

  /// Public API documentation.
  final double rowHeight;

  /// Public API documentation.
  final ReportPdfLabels labels;

  /// Public API documentation.
  final List<ReportPdfTableConfig> tables;
}

/// Public API documentation.
enum ReportPdfCoverBlockType {
  /// Public API documentation.
  kvGrid,

  /// Public API documentation.
  multiline,
}

/// Public API documentation.
class ReportPdfCoverItemConfig {
  /// Public API documentation.
  const ReportPdfCoverItemConfig({
    required this.label,
    required this.valueKey,
    this.x,
    this.y,
    this.width,
    this.height,
  });

  /// Public API documentation.
  final String label;

  /// Public API documentation.
  final String valueKey;

  /// Public API documentation.
  final double? x;

  /// Public API documentation.
  final double? y;

  /// Public API documentation.
  final double? width;

  /// Public API documentation.
  final double? height;

  /// Public API documentation.
  bool get hasAbsolutePosition => x != null && y != null;
}

/// Public API documentation.
class ReportPdfCoverBlockConfig {
  /// Public API documentation.
  const ReportPdfCoverBlockConfig({
    required this.type,
    this.title = '',
    this.columns = 1,
    this.items = const [],
    this.valueKey,
  });

  /// Public API documentation.
  final ReportPdfCoverBlockType type;

  /// Public API documentation.
  final String title;

  /// Public API documentation.
  final int columns;

  /// Public API documentation.
  final List<ReportPdfCoverItemConfig> items;

  /// Public API documentation.
  final String? valueKey;
}

/// Public API documentation.
class ReportPdfCoverPageConfig {
  /// Public API documentation.
  const ReportPdfCoverPageConfig({
    this.enabled = false,
    this.title = '',
    this.blocks = const [],
  });

  /// Public API documentation.
  final bool enabled;

  /// Public API documentation.
  final String title;

  /// Public API documentation.
  final List<ReportPdfCoverBlockConfig> blocks;
}
