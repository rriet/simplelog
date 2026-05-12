import 'package:simplelog/data/import/logten_pro_import_models.dart';
import 'package:simplelog/data/import/pipeline/import_critical_issue_models.dart';

/// Adapts source-specific issues into shared import issue models.
class ImportIssueAdapter {
  /// Maps LogTen validation issues to shared critical issue objects.
  static List<ImportCriticalIssue> mapLogTenIssues(
    List<LogTenImportIssue> issues,
  ) {
    return issues
        .map(
          (issue) => ImportCriticalIssue(
            kind: _mapLogTenIssueKind(issue.association),
            sourceLineNumber: issue.lineNumber,
            message: issue.reason,
          ),
        )
        .toList(growable: false);
  }

  static ImportCriticalIssueKind _mapLogTenIssueKind(
    LogTenFieldAssociation association,
  ) {
    return switch (association) {
      LogTenFieldAssociation.fromAirport || LogTenFieldAssociation.toAirport =>
        ImportCriticalIssueKind.missingAirport,
      LogTenFieldAssociation.registration =>
        ImportCriticalIssueKind.missingAircraft,
      _ => ImportCriticalIssueKind.missingRequiredField,
    };
  }
}
