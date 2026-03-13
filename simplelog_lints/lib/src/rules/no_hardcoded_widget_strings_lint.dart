import 'package:analyzer/dart/ast/ast.dart';
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
        _checkExpression(expression, reporter);
      }
    });
  }

  void _checkExpression(Expression expression, DiagnosticReporter reporter) {
    // Recurse into list literals only — nested widgets get their own
    // addInstanceCreationExpression callback from the registry.
    if (expression is ListLiteral) {
      for (final element in expression.elements) {
        if (element is Expression) {
          _checkExpression(element, reporter);
        }
      }
      return;
    }

    // Skip nested widget constructions — the registry fires for them
    // independently, so we avoid double-reporting.
    if (expression is InstanceCreationExpression) {
      return;
    }

    final (stringValue, reportNode) = _resolveStringArgument(expression);
    if (stringValue == null || reportNode == null) return;
    if (stringValue.trim().isEmpty) return;
    if (_isLowRiskLiteral(stringValue)) return;
    reporter.atNode(reportNode, code);
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

  (String?, AstNode?) _resolveStringArgument(Expression expression) {
    if (expression is StringLiteral) {
      return (expression.stringValue, expression);
    }

    Element? target;
    if (expression is SimpleIdentifier) {
      target = expression.element;
    } else if (expression is PrefixedIdentifier) {
      target = expression.identifier.element;
    }
    if (target == null) return (null, null);

    if (target is GetterElement) {
      final variable = target.variable;
      if (!variable.isConst) return (null, null);
      final value = variable.computeConstantValue()?.toStringValue();
      return (value, expression);
    }

    if (target is VariableElement && target.isConst) {
      final value = target.computeConstantValue()?.toStringValue();
      return (value, expression);
    }

    return (null, null);
  }

  bool _isLowRiskLiteral(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return true;
    if (RegExp(r'^[A-Z0-9_./:+\- ]{1,18}$').hasMatch(trimmed)) return true;
    if (!trimmed.contains(' ') && trimmed.length <= 18) return true;
    final words = trimmed
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty);
    if (words.length < 3) return true;
    if (trimmed.length < 40) return true;
    return false;
  }
}
