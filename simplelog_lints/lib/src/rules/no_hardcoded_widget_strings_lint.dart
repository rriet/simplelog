import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

const _widgetChecker = TypeChecker.fromName('Widget', packageName: 'flutter');

/// Lint that flags hardcoded user-facing strings inside widget constructors.
class NoHardcodedWidgetStringsLint extends DartLintRule {
  /// Creates the lint rule.
  const NoHardcodedWidgetStringsLint()
    : super(
        code: const LintCode(
          name: 'no_hardcoded_widget_strings',
          problemMessage:
              'Do not pass hardcoded strings to widget constructors. '
              'Use l10n keys.',
          correctionMessage:
              'Replace the string literal with '
              'AppLocalizations.of(context) access.',
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
    context.registry.addInstanceCreationExpression((node) {
      if (!_isWidgetConstruction(node)) return;

      for (final argument in node.argumentList.arguments) {
        final expression = argument is NamedExpression
            ? argument.expression
            : argument;
        final stringLiteral = _extractHardcodedLiteral(expression);
        if (stringLiteral == null) continue;
        final value = stringLiteral.stringValue ?? '';
        if (value.trim().isEmpty) continue;
        if (_isLowRiskLiteral(value)) continue;
        reporter.atNode(stringLiteral, code);
      }
    });
  }

  bool _isUiFile(String path) {
    return path.contains('/lib/presentation/') ||
        path.contains('/lib/ui/') ||
        (path.contains('/lib/features/') && path.contains('/presentation/'));
  }

  bool _isWidgetConstruction(InstanceCreationExpression node) {
    final type = node.staticType;
    if (type == null) return false;
    return _widgetChecker.isAssignableFromType(type);
  }

  StringLiteral? _extractHardcodedLiteral(Expression expression) {
    if (expression is StringLiteral) {
      return expression;
    }
    if (expression is SimpleIdentifier) {
      final target = expression.element;
      if (target == null) return null;
      final unit = expression.thisOrAncestorOfType<CompilationUnit>();
      if (unit == null) return null;
      for (final declaration in unit.declarations) {
        final literal = _findLiteralInDeclaration(declaration, target);
        if (literal != null) {
          return literal;
        }
      }
    }
    return null;
  }

  StringLiteral? _findLiteralInDeclaration(
    CompilationUnitMember member,
    Element target,
  ) {
    StringLiteral? result;
    member.visitChildren(
      _VariableLiteralVisitor(
        onVariable: (variable, literal) {
          final element = variable.declaredFragment?.element;
          if (element == target) {
            result = literal;
          }
        },
      ),
    );
    return result;
  }

  bool _isLowRiskLiteral(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return true;
    // Ignore short tokens/acronyms (e.g. PF, IFR, ICAO, OK, MM/DD).
    if (RegExp(r'^[A-Z0-9_./:+\- ]{1,18}$').hasMatch(trimmed)) return true;
    // Ignore simple single-token labels;
    // keep lint focused on sentence-like UI text.
    if (!trimmed.contains(' ') && trimmed.length <= 18) return true;
    final words = trimmed
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty);
    // Keep this lint focused on long sentence-like UI content.
    if (words.length < 3) return true;
    if (trimmed.length < 40) return true;
    return false;
  }
}

class _VariableLiteralVisitor extends RecursiveAstVisitor<void> {
  _VariableLiteralVisitor({
    required this.onVariable,
  });

  final void Function(VariableDeclaration variable, StringLiteral literal)
  onVariable;

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    final initializer = node.initializer;
    if (initializer is StringLiteral) {
      onVariable(node, initializer);
    }
    super.visitVariableDeclaration(node);
  }
}
