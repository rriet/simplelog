import 'dart:convert';
import 'dart:typed_data';

import 'package:simplelog/data/import/import_source_dispatcher.dart';
import 'package:simplelog/data/import/pipeline/import_pipeline_models.dart';
import 'package:simplelog/data/import/simplelog_database_source_detector.dart';

/// Coordinates the common detect-and-route flow for import operations.
class ImportPipelineCoordinator {
  /// Creates an import pipeline coordinator.
  const ImportPipelineCoordinator({
    ImportSourceDispatcher sourceDispatcher = const ImportSourceDispatcher(),
    SimpleLogDatabaseSourceDetector databaseSourceDetector =
        const SimpleLogDatabaseSourceDetector(),
  }) : _sourceDispatcher = sourceDispatcher,
       _databaseSourceDetector = databaseSourceDetector;

  final ImportSourceDispatcher _sourceDispatcher;
  final SimpleLogDatabaseSourceDetector _databaseSourceDetector;

  /// Detects import route by inspecting file bytes and optional text content.
  Future<ImportPipelineDetection> detect({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final dbInspection = await _databaseSourceDetector.inspectBytes(bytes);
    if (dbInspection.kind == SimpleLogDatabaseSourceKind.currentSimpleLog) {
      return ImportPipelineDetection(
        kind: ImportPipelineDetectionKind.currentSimpleLogDatabase,
        fileName: fileName,
        bytes: bytes,
        databaseKind: dbInspection.kind,
      );
    }
    if (dbInspection.kind == SimpleLogDatabaseSourceKind.legacySimpleLog) {
      return ImportPipelineDetection(
        kind: ImportPipelineDetectionKind.legacySimpleLogDatabase,
        fileName: fileName,
        bytes: bytes,
        databaseKind: dbInspection.kind,
      );
    }
    if (dbInspection.isSqlite) {
      return ImportPipelineDetection(
        kind: ImportPipelineDetectionKind.unsupportedSqliteDatabase,
        fileName: fileName,
        bytes: bytes,
        databaseKind: dbInspection.kind,
      );
    }

    final lowerName = fileName.toLowerCase();
    final shouldDecodeText = !lowerName.endsWith('.xlsx');
    final decodedContent = shouldDecodeText ? _decodeTextBytes(bytes) : null;
    final sourceKind = _sourceDispatcher.detect(
      fileName: fileName,
      content: decodedContent,
      bytes: bytes,
    );

    if (sourceKind == ImportSourceKind.unknown) {
      return ImportPipelineDetection(
        kind: ImportPipelineDetectionKind.unknown,
        fileName: fileName,
        bytes: bytes,
        sourceKind: sourceKind,
        decodedContent: decodedContent,
      );
    }

    return ImportPipelineDetection(
      kind: ImportPipelineDetectionKind.sourceImport,
      fileName: fileName,
      bytes: bytes,
      sourceKind: sourceKind,
      decodedContent: decodedContent,
    );
  }

  String _decodeTextBytes(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xEF &&
        bytes[1] == 0xBB &&
        bytes[2] == 0xBF) {
      return utf8.decode(bytes.sublist(3));
    }
    try {
      return utf8.decode(bytes);
    } on FormatException {
      return utf8.decode(bytes, allowMalformed: true);
    }
  }
}
