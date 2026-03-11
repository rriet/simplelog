import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Lint that flags `setState()` calls after `await` expressions that are
/// not guarded by a `mounted` check.
///
/// AI codegen almost always forgets the `if (mounted)` guard, which causes
/// a crash when the widget is disposed before the async operation completes.
///
/// Correct pattern:
/// ```dart
/// await someOperation();
/// if (mounted) setState(() { ... });
/// ```
///
/// Flagged pattern:
/// ```dart
/// await someOperation();
/// setState(() { ... });   // <-- no mounted guard
/// ```
class NoSetStateAfterAsyncLint extends DartLintRule {
  /// Creates the lint rule.
  const NoSetStateAfterAsyncLint()
    : super(
        code: const LintCode(
          name: 'no_set_state_after_async',
          problemMessage:
              'setState() called after await without a mounted guard. '
              'This will crash if the widget is disposed first.',
          correctionMessage:
              "Wrap setState() with 'if (mounted) { setState(() {...}); }'",
          errorSeverity: DiagnosticSeverity.ERROR,
        ),
      );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodDeclaration((node) {
      // Only inspect async methods.
      if (node.body is! BlockFunctionBody) return;
      final body = node.body as BlockFunctionBody;
      if (!body.isAsynchronous) return;

      final visitor = _AsyncSetStateVisitor();
      node.accept(visitor);

      for (final unguardedSetState in visitor.unguardedSetStateCalls) {
        reporter.atNode(unguardedSetState, code);
      }
    });
  }
}

/// Walks an async method body and collects every `setState()` call that
/// appears after an `await` and is NOT inside an `if (mounted)` guard.
class _AsyncSetStateVisitor extends RecursiveAstVisitor<void> {
  final List<MethodInvocation> unguardedSetStateCalls = [];

  bool _seenAwait = false;

  @override
  void visitAwaitExpression(AwaitExpression node) {
    _seenAwait = true;
    super.visitAwaitExpression(node);
  }

  @override
  void visitIfStatement(IfStatement node) {
    // Check if condition references `mounted`.
    if (_conditionChecksMounted(node.expression)) {
      // Inside a mounted guard — do not flag setState calls within.
      return;
    }
    super.visitIfStatement(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (_seenAwait && node.methodName.name == 'setState') {
      // Only flag if not inside a mounted check (handled by skipping above).
      unguardedSetStateCalls.add(node);
    }
    super.visitMethodInvocation(node);
  }

  bool _conditionChecksMounted(Expression condition) {
    if (condition is SimpleIdentifier) {
      return condition.name == 'mounted';
    }
    if (condition is PrefixExpression) {
      final operand = condition.operand;
      if (operand is SimpleIdentifier) return operand.name == 'mounted';
    }
    return false;
  }
}
