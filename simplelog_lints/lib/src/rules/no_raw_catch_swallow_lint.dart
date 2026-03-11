import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Lint that flags catch blocks that silently swallow exceptions.
///
/// AI codegen frequently generates `catch (e) {}` or `catch (e) { print(e); }`
/// which hides errors and makes debugging in production impossible.
///
/// Allowed patterns:
///   - `rethrow`
///   - Calling a method/function (assumed to be a proper logger)
///   - Assigning to a variable (for later use)
///
/// Flagged patterns:
///   - Empty catch body
///   - Body containing only `print()` / `debugPrint()` calls
class NoRawCatchSwallowLint extends DartLintRule {
  /// Creates the lint rule.
  const NoRawCatchSwallowLint()
    : super(
        code: const LintCode(
          name: 'no_raw_catch_swallow',
          problemMessage:
              'Do not silently swallow exceptions. '
              'An empty catch block or one with only print() hides errors.',
          correctionMessage:
              'Either rethrow, log via your logger, or handle the error '
              'explicitly. Never leave a catch block empty.',
          errorSeverity: DiagnosticSeverity.ERROR,
        ),
      );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCatchClause((node) {
      final body = node.body;
      final statements = body.statements;

      // Empty catch body.
      if (statements.isEmpty) {
        reporter.atNode(body, code);
        return;
      }

      // Body contains only print/debugPrint calls — still a swallow.
      if (_containsOnlyPrintStatements(statements)) {
        reporter.atNode(body, code);
      }
    });
  }

  bool _containsOnlyPrintStatements(List<Statement> statements) {
    return statements.every((stmt) {
      if (stmt is! ExpressionStatement) return false;
      final expr = stmt.expression;
      if (expr is! MethodInvocation) return false;
      final name = expr.methodName.name;
      return name == 'print' || name == 'debugPrint';
    });
  }
}
