/// Supported paper sizes for generated PDF reports.
enum ReportPdfPageSize {
  /// ISO A4 size.
  a4,

  /// North‑American Letter size.
  letter,

  /// North‑American Legal size.
  legal,

  /// ISO A5 size.
  a5,
}

/// Convenience helpers for working with [ReportPdfPageSize] values.
extension ReportPdfPageSizeMeta on ReportPdfPageSize {
  /// Human‑readable label used in the UI.
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

/// Horizontal alignment for text inside a report column or cell.
enum ReportPdfColumnAlignment {
  /// Align content to the left.
  left,

  /// Align content in the center.
  center,

  /// Align content to the right.
  right,
}

/// Vertical alignment for text inside a report cell.
enum ReportPdfVerticalAlignment {
  /// Align content to the top of the cell.
  top,

  /// Center content vertically.
  middle,

  /// Align content to the bottom of the cell.
  bottom,
}

/// Text styling options for a single cell.
class ReportPdfCellTextStyle {
  /// Creates a new cell text style.
  const ReportPdfCellTextStyle({
    this.fontSize,
    this.bold = false,
    this.italic = false,
    this.colorHex,
  });

  /// Optional font size override for the cell.
  final double? fontSize;

  /// Whether the text should be rendered bold.
  final bool bold;

  /// Whether the text should be rendered italic.
  final bool italic;

  /// Optional text color specified as a hex string.
  final String? colorHex;
}

/// Indicates where a summary row derives its values from.
enum ReportPdfSummarySource {
  /// Values are calculated from the current page totals.
  pageTotals,

  /// Values represent totals before the current page.
  totalsBefore,

  /// Values represent totals after the current page.
  totalsAfter,
}

/// Configuration of a single column within a report table.
class ReportPdfColumnConfig {
  /// Creates a new column configuration.
  const ReportPdfColumnConfig({
    required this.key,
    this.header,
    this.width = 1,
    this.alignment = ReportPdfColumnAlignment.center,
    this.verticalAlignment = ReportPdfVerticalAlignment.middle,
    this.textStyle = const ReportPdfCellTextStyle(),
  });

  /// Unique key used to identify the column and map values.
  final String key;

  /// Optional header text shown for this column.
  final String? header;

  /// Relative width factor for the column.
  final double width;

  /// Horizontal alignment used for cells in this column.
  final ReportPdfColumnAlignment alignment;

  /// Vertical alignment used for cells in this column.
  final ReportPdfVerticalAlignment verticalAlignment;

  /// Default text style applied to cells in this column.
  final ReportPdfCellTextStyle textStyle;
}

/// Configuration for a single data cell within a table row.
class ReportPdfCellConfig {
  /// Creates a new cell configuration.
  const ReportPdfCellConfig({
    this.text,
    this.valueToken,
    this.hspan = 1,
    this.vspan = 1,
    this.alignment,
    this.verticalAlignment,
    this.textStyle = const ReportPdfCellTextStyle(),
  });

  /// Literal text to display in the cell, if any.
  final String? text;

  /// Token used to look up a value from the row data.
  final String? valueToken;

  /// Number of columns this cell should span.
  final int hspan;

  /// Number of rows this cell should span.
  final int vspan;

  /// Horizontal alignment override for this cell.
  final ReportPdfColumnAlignment? alignment;

  /// Vertical alignment override for this cell.
  final ReportPdfVerticalAlignment? verticalAlignment;

  /// Text style override for this cell.
  final ReportPdfCellTextStyle textStyle;
}

/// Configuration for a header row shown above table data.
class ReportPdfHeaderRowConfig {
  /// Creates a header row with a list of cells.
  const ReportPdfHeaderRowConfig({
    required this.cells,
    this.rowHeight,
  });

  /// Cells that make up the header row.
  final List<ReportPdfCellConfig> cells;

  /// Optional explicit row height.
  final double? rowHeight;
}

/// Configuration for a footer row that summarizes totals.
class ReportPdfFooterRowConfig {
  /// Creates a footer row bound to a [source] and [values].
  const ReportPdfFooterRowConfig({
    /// Where summary values should be taken from.
    required this.source,
    required this.values,
    this.cells = const [],
    this.rowHeight,
    this.labelToken,

    /// Literal label to display instead of a token.
    this.literalLabel,

    /// Whether to draw a line above the footer row.
    this.showTopBorder = false,
  });

  /// Source used when computing summary values.
  final ReportPdfSummarySource source;

  /// Optional localization token for the footer label.
  final String? labelToken;

  /// Optional literal label text, used when [labelToken] is not.
  final String? literalLabel;

  /// Map of value keys to formatted strings for this footer.
  final Map<String, String> values;

  /// Additional cells displayed in the footer row.
  final List<ReportPdfCellConfig> cells;

  /// Optional explicit row height.
  final double? rowHeight;

  /// Whether a border should be drawn at the top of the row.
  final bool showTopBorder;
}

/// High‑level configuration for a single report table.
class ReportPdfTableConfig {
  /// Creates a table definition for a specific report section.
  const ReportPdfTableConfig({
    required this.pageSuffix,
    required this.columns,
    this.header = const [],
    this.footer = const [],
    this.footerRows = const [],
  });

  /// Suffix used to distinguish pages created for this table.
  final String pageSuffix;

  /// Header rows displayed at the top of each page.
  final List<ReportPdfHeaderRowConfig> header;

  /// Rows displayed at the bottom of each page.
  final List<ReportPdfHeaderRowConfig> footer;

  /// Column definitions used by this table.
  final List<ReportPdfColumnConfig> columns;

  /// Additional summary rows shown below the main table.
  final List<ReportPdfFooterRowConfig> footerRows;
}

/// Labels and tokens used across all PDF report templates.
class ReportPdfLabels {
  /// Creates the set of default labels.
  const ReportPdfLabels({
    /// Label used for per‑page totals.
    this.pageTotal = 'PAGE TOTAL',

    /// Label used when carrying forward amounts.
    this.amountForward = 'AMT. FORWARD',

    /// Label used for totals across the whole logbook.
    this.totalToDate = 'TOTAL TO DATE',
  });

  /// Label used for per‑page totals.
  final String pageTotal;

  /// Label used when carrying forward amounts.
  final String amountForward;

  /// Label used for totals across the whole logbook.
  final String totalToDate;

  /// Resolves a token name into the corresponding label text.
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

/// Complete configuration for a logbook PDF template.
class ReportPdfTemplate {
  /// Creates a new report template.
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

  /// Base file name (without extension) used when exporting.
  final String fileName;

  /// Human‑readable name shown in the UI.
  final String displayName;

  /// Maximum number of data rows per page.
  final int rowsPerPage;

  /// Optional configuration for a cover page.
  final ReportPdfCoverPageConfig? coverPage;

  /// Forces landscape orientation when `true`.
  final bool forceLandscape;

  /// Default paper size for the report.
  final ReportPdfPageSize defaultPageSize;

  /// Default row height used in tables.
  final double rowHeight;

  /// Labels used when rendering this template.
  final ReportPdfLabels labels;

  /// Tables that make up the body of the report.
  final List<ReportPdfTableConfig> tables;
}

/// Types of content blocks that can appear on a cover page.
enum ReportPdfCoverBlockType {
  /// Key‑value grid block.
  kvGrid,

  /// Multiline text block.
  multiline,
}

/// Configuration for a single item within a cover block.
class ReportPdfCoverItemConfig {
  /// Creates an item with label and value key.
  const ReportPdfCoverItemConfig({
    required this.label,
    required this.valueKey,
    this.x,
    this.y,
    this.width,
    this.height,
  });

  /// Label shown next to the value.
  final String label;

  /// Key used to resolve the value from the data set.
  final String valueKey;

  /// Optional absolute X coordinate on the page.
  final double? x;

  /// Optional absolute Y coordinate on the page.
  final double? y;

  /// Optional explicit width of the item area.
  final double? width;

  /// Optional explicit height of the item area.
  final double? height;

  /// Whether both [x] and [y] are set for absolute positioning.
  bool get hasAbsolutePosition => x != null && y != null;
}

/// Configuration for a logical block on the cover page.
class ReportPdfCoverBlockConfig {
  /// Creates a cover block of a given [type].
  const ReportPdfCoverBlockConfig({
    required this.type,
    this.title = '',
    this.columns = 1,
    this.items = const [],
    this.valueKey,
  });

  /// Type of cover block (layout and behavior).
  final ReportPdfCoverBlockType type;

  /// Block title shown above its contents.
  final String title;

  /// Number of columns used when laying out items.
  final int columns;

  /// Items contained within this block.
  final List<ReportPdfCoverItemConfig> items;

  /// Optional key used to resolve a multiline value.
  final String? valueKey;
}

/// Configuration for an optional cover page shown before the tables.
class ReportPdfCoverPageConfig {
  /// Creates a cover page configuration.
  const ReportPdfCoverPageConfig({
    this.enabled = false,
    this.title = '',
    this.blocks = const [],
  });

  /// Whether the cover page should be generated.
  final bool enabled;

  /// Title shown on the cover page.
  final String title;

  /// Blocks that make up the content of the cover page.
  final List<ReportPdfCoverBlockConfig> blocks;
}
