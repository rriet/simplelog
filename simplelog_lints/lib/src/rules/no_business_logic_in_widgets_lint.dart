import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Lint that blocks obvious business-logic patterns inside UI widgets.
class NoBusinessLogicInWidgetsLint extends DartLintRule {
  /// Creates the lint rule.
  const NoBusinessLogicInWidgetsLint()
    : super(
        code: const LintCode(
          name: 'no_business_logic_in_widgets',
          problemMessage:
              'Avoid business logic in widgets. Do not instantiate '
              'use-cases directly and keep async branching out of build().',
          correctionMessage:
              'Move logic to notifiers/use-cases and inject dependencies.',
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
    if (!_isUiFile(path)) return;

    context.registry.addInstanceCreationExpression((node) {
      final typeName = node.constructorName.type.name.lexeme;
      if (!typeName.endsWith('UseCases')) return;
      reporter.atNode(node.constructorName.type, code);
    });

    context.registry.addMethodDeclaration((node) {
      if (node.name.lexeme != 'build') return;
      for (final statement in _IfWithAwaitVisitor().findIfWithAwait(node)) {
        reporter.atNode(statement, code);
      }
    });
  }

  bool _isUiFile(String path) {
    return path.contains('/lib/presentation/') ||
        path.contains('/lib/ui/') ||
        (path.contains('/lib/features/') && path.contains('/presentation/'));
  }
}

class _IfWithAwaitVisitor extends RecursiveAstVisitor<void> {
  final List<IfStatement> _matches = <IfStatement>[];

  List<IfStatement> findIfWithAwait(MethodDeclaration node) {
    _matches.clear();
    node.accept(this);
    return List<IfStatement>.from(_matches);
  }

  @override
  void visitIfStatement(IfStatement node) {
    final containsAwait = _AwaitExpressionFinder().containsAwait(node);
    if (containsAwait) {
      _matches.add(node);
    }
    super.visitIfStatement(node);
  }
}

class _AwaitExpressionFinder extends RecursiveAstVisitor<void> {
  bool _found = false;

  bool containsAwait(AstNode node) {
    _found = false;
    node.accept(this);
    return _found;
  }

  @override
  void visitAwaitExpression(AwaitExpression node) {
    _found = true;
  }
}
