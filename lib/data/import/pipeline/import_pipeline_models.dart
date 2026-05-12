import 'dart:typed_data';

import 'package:simplelog/data/import/import_source_dispatcher.dart';
import 'package:simplelog/data/import/simplelog_database_source_detector.dart';

/// High-level import pipeline stage.
enum ImportPipelineStage {
  /// Detect file source and route.
  detectSource,

  /// Show and collect import options.
  collectOptions,

  /// Resolve data issues before import.
  preflight,

  /// Execute import.
  execute,

  /// Import finished.
  completed,
}

/// Severity for import pipeline issues.
enum ImportPipelineIssueSeverity {
  /// Informational entry.
  info,

  /// Warning that allows continuing.
  warning,

  /// Critical issue that blocks import.
  critical,
}

/// Normalized issue shape used by import flows.
class ImportPipelineIssue {
  /// Creates a pipeline issue.
  const ImportPipelineIssue({
    required this.code,
    required this.message,
    this.severity = ImportPipelineIssueSeverity.warning,
    this.sourceLineNumber,
  });

  /// Programmatic issue code.
  final String code;

  /// User-facing issue message.
  final String message;

  /// Issue severity.
  final ImportPipelineIssueSeverity severity;

  /// Optional 1-based source line number.
  final int? sourceLineNumber;
}

/// Supported decisions after inspecting picked file bytes.
enum ImportPipelineDetectionKind {
  /// Detected current SimpleLog database backup.
  currentSimpleLogDatabase,

  /// Detected legacy SimpleLog database.
  legacySimpleLogDatabase,

  /// Detected SQLite file that is not supported for import.
  unsupportedSqliteDatabase,

  /// Detected known text/workbook import source.
  sourceImport,

  /// Could not detect source type.
  unknown,
}

/// Data from the source detection stage.
class ImportPipelineDetection {
  /// Creates detection output.
  const ImportPipelineDetection({
    required this.kind,
    required this.fileName,
    required this.bytes,
    this.databaseKind,
    this.sourceKind,
    this.decodedContent,
  });

  /// High-level detected kind.
  final ImportPipelineDetectionKind kind;

  /// Picked file name.
  final String fileName;

  /// Full picked file bytes.
  final Uint8List bytes;

  /// Optional detected database kind.
  final SimpleLogDatabaseSourceKind? databaseKind;

  /// Optional detected import source kind.
  final ImportSourceKind? sourceKind;

  /// Decoded file content for text-based import sources.
  final String? decodedContent;
}

/// Progress payload exposed by the shared pipeline.
class ImportPipelineProgress {
  /// Creates progress payload.
  const ImportPipelineProgress({
    required this.stage,
    this.processed = 0,
    this.total = 0,
  });

  /// Current pipeline stage.
  final ImportPipelineStage stage;

  /// Processed count in execute stage.
  final int processed;

  /// Total count in execute stage.
  final int total;
}
