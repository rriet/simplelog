enum ReportPdfPageSize {
  a4,
  letter,
  legal,
  a5,
}

extension ReportPdfPageSizeMeta on ReportPdfPageSize {
  String get label {
    switch (this) {
      case ReportPdfPageSize.a4:
        return 'A4';
      case ReportPdfPageSize.letter:
        return 'Letter';
      case ReportPdfPageSize.legal:
        return 'Legal';
      case ReportPdfPageSize.a5:
        return 'A5';
    }
  }
}

enum ReportPdfColumnAlignment {
  left,
  center,
  right,
}

enum ReportPdfSummarySource {
  pageTotals,
  totalsBefore,
  totalsAfter,
}

class ReportPdfColumnConfig {
  const ReportPdfColumnConfig({
    required this.key,
    required this.header,
    this.width = 1,
    this.alignment = ReportPdfColumnAlignment.center,
  });

  final String key;
  final String header;
  final double width;
  final ReportPdfColumnAlignment alignment;
}

class ReportPdfFooterRowConfig {
  const ReportPdfFooterRowConfig({
    required this.source,
    required this.values,
    this.labelToken,
    this.literalLabel,
    this.showTopBorder = false,
  });

  final ReportPdfSummarySource source;
  final String? labelToken;
  final String? literalLabel;
  final Map<String, String> values;
  final bool showTopBorder;
}

class ReportPdfTableConfig {
  const ReportPdfTableConfig({
    required this.pageSuffix,
    required this.columns,
    this.footerRows = const [],
  });

  final String pageSuffix;
  final List<ReportPdfColumnConfig> columns;
  final List<ReportPdfFooterRowConfig> footerRows;
}

class ReportPdfLabels {
  const ReportPdfLabels({
    this.pageTotal = 'PAGE TOTAL',
    this.amountForward = 'AMT. FORWARD',
    this.totalToDate = 'TOTAL TO DATE',
  });

  final String pageTotal;
  final String amountForward;
  final String totalToDate;

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

class ReportPdfTemplate {
  const ReportPdfTemplate({
    required this.fileName,
    required this.displayName,
    required this.rowsPerPage,
    required this.tables,
    this.forceLandscape = false,
    this.defaultPageSize = ReportPdfPageSize.letter,
    this.labels = const ReportPdfLabels(),
  });

  final String fileName;
  final String displayName;
  final int rowsPerPage;
  final bool forceLandscape;
  final ReportPdfPageSize defaultPageSize;
  final ReportPdfLabels labels;
  final List<ReportPdfTableConfig> tables;
}
