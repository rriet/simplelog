import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

const _widgetChecker = TypeChecker.fromName('Widget', packageName: 'flutter');
const _userFacingNamedParameters = <String>{
  'text',
  'label',
  'labelText',
  'title',
  'subtitle',
  'hint',
  'hintText',
  'helperText',
  'errorText',
  'tooltip',
  'semanticLabel',
  'message',
  'buttonLabel',
  'actionLabel',
};

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
        _checkArgument(node, argument, reporter);
      }
    });
  }

  void _checkArgument(
    InstanceCreationExpression constructor,
    Expression argument,
    DiagnosticReporter reporter,
  ) {
    final (parameterName, expression) = switch (argument) {
      NamedExpression named => (named.name.label.name, named.expression),
      _ => (null, argument),
    };

    if (!_isUserFacingParameter(constructor, parameterName)) {
      return;
    }

    _checkExpression(expression, reporter);
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

  bool _isUserFacingParameter(
    InstanceCreationExpression constructor,
    String? parameterName,
  ) {
    if (parameterName != null) {
      return _userFacingNamedParameters.contains(parameterName);
    }
    final typeName = constructor.staticType?.getDisplayString() ?? '';
    return typeName == 'Text' || typeName == 'SelectableText';
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
    if (expression is ParenthesizedExpression) {
      return _resolveStringArgument(expression.expression);
    }

    if (expression is ConditionalExpression) {
      final thenValue = _resolveStringArgument(expression.thenExpression);
      if (thenValue.$1 != null) return thenValue;
      return _resolveStringArgument(expression.elseExpression);
    }

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

    if (expression is SimpleIdentifier) {
      final localInitializer = _findLocalVariableInitializer(expression);
      if (localInitializer != null) {
        return _resolveStringArgument(localInitializer);
      }
    }

    return (null, null);
  }

  Expression? _findLocalVariableInitializer(SimpleIdentifier identifier) {
    final body = identifier.thisOrAncestorOfType<BlockFunctionBody>();
    if (body == null) return null;

    VariableDeclaration? lastMatch;
    for (final statement in body.block.statements) {
      if (statement.offset >= identifier.offset) break;
      if (statement is! VariableDeclarationStatement) continue;
      for (final declaration in statement.variables.variables) {
        if (declaration.name.lexeme != identifier.name) continue;
        lastMatch = declaration;
      }
    }
    return lastMatch?.initializer;
  }

  bool _isLowRiskLiteral(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return true;
    if (RegExp(r'^[A-Z0-9_./:+\- ]{1,18}$').hasMatch(trimmed)) return true;
    return false;
  }
}
