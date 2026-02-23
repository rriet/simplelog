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
    required this.header,
    this.width = 1,
    this.alignment = ReportPdfColumnAlignment.center,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final String key;
  /// Public API documentation.
  final String header;
  /// Public API documentation.
  final double width;
  /// Public API documentation.
  final ReportPdfColumnAlignment alignment;
}

/// Public API documentation.
class ReportPdfFooterRowConfig {
  /// Public API documentation.
  const ReportPdfFooterRowConfig({
    /// Public API documentation.
    required this.source,
    required this.values,
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
  final bool showTopBorder;
}

/// Public API documentation.
class ReportPdfTableConfig {
  /// Public API documentation.
  const ReportPdfTableConfig({
    required this.pageSuffix,
    required this.columns,
    this.footerRows = const [],
  });

  /// Public API documentation.
  final String pageSuffix;
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
    this.forceLandscape = false,
    this.defaultPageSize = ReportPdfPageSize.letter,
    this.labels = const ReportPdfLabels(),
  });

  /// Public API documentation.
  final String fileName;
  /// Public API documentation.
  final String displayName;
  /// Public API documentation.
  final int rowsPerPage;
  /// Public API documentation.
  final bool forceLandscape;
  /// Public API documentation.
  final ReportPdfPageSize defaultPageSize;
  /// Public API documentation.
  final ReportPdfLabels labels;
  /// Public API documentation.
  final List<ReportPdfTableConfig> tables;
}
