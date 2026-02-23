import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Enforces file and class naming conventions across app layers.
class FileNamingConventionsLint extends DartLintRule {
  /// Creates the lint rule.
  const FileNamingConventionsLint()
    : super(
        code: const LintCode(
          name: 'file_naming_conventions',
          problemMessage:
              'File naming/layer convention violation. Keep *_screen.dart in presentation, *_repository.dart in data, and *_use_case.dart in application. Keep class and file suffixes aligned.',
          correctionMessage:
              'Move/rename file or class to match layer conventions.',
          errorSeverity: DiagnosticSeverity.WARNING,
        ),
      );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    final path = resolver.source.fullName.replaceAll(r'\', '/');
    if (!path.contains('/lib/')) return;
    final fileName = path.split('/').last;

    context.registry.addCompilationUnit((unit) {
      final classes = unit.declarations.whereType<ClassDeclaration>().toList();
      final publicClasses = classes
          .where((decl) => !decl.name.lexeme.startsWith('_'))
          .toList();
      final anchor = publicClasses.isNotEmpty
          ? publicClasses.first
          : (classes.isNotEmpty ? classes.first : unit);

      if (!_isFileInExpectedLayer(path, fileName)) {
        reporter.atNode(anchor, code);
      }

      for (final classDecl in publicClasses) {
        if (!_isClassAlignedWithFile(classDecl.name.lexeme, fileName)) {
          reporter.atNode(classDecl, code);
        }
      }
    });
  }

  bool _isFileInExpectedLayer(String path, String fileName) {
    if (fileName.endsWith('_screen.dart')) {
      return _isPresentationPath(path);
    }
    if (fileName.endsWith('_repository.dart')) {
      return path.contains('/data/');
    }
    if (fileName.endsWith('_use_case.dart')) {
      return path.contains('/application/');
    }
    return true;
  }

  bool _isClassAlignedWithFile(String className, String fileName) {
    final isScreenClass = className.endsWith('Screen');
    final isRepositoryClass = className.endsWith('Repository');
    final isUseCaseClass = className.endsWith('UseCase');

    if (fileName.endsWith('_screen.dart') && !isScreenClass) return false;
    if (fileName.endsWith('_repository.dart') && !isRepositoryClass) {
      return false;
    }
    if (fileName.endsWith('_use_case.dart') && !isUseCaseClass) return false;

    if (isScreenClass && !fileName.endsWith('_screen.dart')) return false;
    if (isRepositoryClass && !fileName.endsWith('_repository.dart')) {
      return false;
    }
    if (isUseCaseClass && !fileName.endsWith('_use_case.dart')) return false;

    return true;
  }

  bool _isPresentationPath(String path) {
    return path.contains('/presentation/') ||
        path.contains('/ui/') ||
        (path.contains('/features/') && path.contains('/presentation/'));
  }
}
