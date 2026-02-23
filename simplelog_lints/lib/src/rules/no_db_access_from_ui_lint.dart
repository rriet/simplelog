import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Lint that prevents direct database/infrastructure imports from UI files.
class NoDirectDbAccessFromUiLint extends DartLintRule {
  /// Creates the lint rule.
  const NoDirectDbAccessFromUiLint()
    : super(
        code: const LintCode(
          name: 'no_direct_db_access_from_ui',
          problemMessage:
              'UI/presentation files must not import database/infrastructure packages directly.',
          correctionMessage:
              'Move data access behind use-cases/repositories and inject through providers.',
          errorSeverity: DiagnosticSeverity.ERROR,
        ),
      );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    final path = resolver.source.fullName.replaceAll(r'\', '/');
    if (!_isUiFile(path)) return;

    context.registry.addImportDirective((node) {
      final uri = node.uri.stringValue ?? '';
      if (uri.isEmpty) return;
      if (_isDbImport(uri)) {
        reporter.atNode(node.uri, code);
      }
    });
  }

  bool _isUiFile(String path) {
    return path.contains('/lib/presentation/') ||
        path.contains('/lib/ui/') ||
        (path.contains('/lib/features/') &&
            (path.contains('/presentation/') || path.contains('/ui/')));
  }

  bool _isDbImport(String uri) {
    return uri.startsWith('package:sqflite/') ||
        uri.startsWith('package:isar/');
  }
}
