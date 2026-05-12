import 'package:simplelog/data/import/pipeline/import_critical_issue_models.dart';
import 'package:simplelog/data/import/source_parsers/southwest_csv_source_parser.dart';

/// Shared helpers to resolve critical import issues across source types.
class ImportCriticalIssueResolver {
  /// Creates a resolver.
  const ImportCriticalIssueResolver();

  /// Re-runs an issue source until no pending issues remain or user cancels.
  Future<bool> resolveUntilClear<T>({
    required Future<List<T>> Function() loadPending,
    required Future<bool> Function(List<T> pending) presentPending,
  }) async {
    while (true) {
      final pending = await loadPending();
      if (pending.isEmpty) {
        return true;
      }
      final shouldContinue = await presentPending(pending);
      if (!shouldContinue) {
        return false;
      }
    }
  }

  /// Returns unique source lines referenced by a list of issues.
  Set<int> sourceLinesOf(List<ImportCriticalIssue> issues) {
    return <int>{
      for (final issue in issues)
        if (issue.sourceLineNumber != null) issue.sourceLineNumber!,
    };
  }

  /// Maps Southwest "missing required fields" preflight issues.
  List<ImportCriticalIssue> mapSouthwestMissingRequiredIssues(
    List<SouthwestMissingRequiredIssue> issues, {
    required String Function(SouthwestMissingRequiredField field)
    fieldLabelBuilder,
    required String Function(String fieldsLabel) reasonBuilder,
  }) {
    final ordered = issues.toList()
      ..sort(
        (left, right) =>
            left.sourceLineNumber.compareTo(right.sourceLineNumber),
      );
    return ordered
        .map((issue) {
          final missingFields = issue.missingFields.toList()
            ..sort((left, right) => left.index.compareTo(right.index));
          final fields = missingFields.map(fieldLabelBuilder).join(', ');
          return ImportCriticalIssue(
            kind: ImportCriticalIssueKind.missingRequiredField,
            sourceLineNumber: issue.sourceLineNumber,
            message: reasonBuilder(fields),
          );
        })
        .toList(growable: false);
  }

  /// Maps Southwest "missing aircraft tail" preflight issues.
  List<ImportCriticalIssue> mapSouthwestMissingTailIssues(
    List<SouthwestMissingAircraftTailIssue> issues, {
    required String unknownTypeLabel,
  }) {
    final ordered = issues.toList()
      ..sort(
        (left, right) =>
            left.sourceLineNumber.compareTo(right.sourceLineNumber),
      );
    return ordered
        .map((issue) {
          final typeLabel = issue.aircraftTypeCode.isEmpty
              ? unknownTypeLabel
              : issue.aircraftTypeCode;
          return ImportCriticalIssue(
            kind: ImportCriticalIssueKind.missingAircraftTail,
            sourceLineNumber: issue.sourceLineNumber,
            message:
                '${issue.date}, ${issue.fromCode}, ${issue.toCode}, $typeLabel',
          );
        })
        .toList(growable: false);
  }
}
