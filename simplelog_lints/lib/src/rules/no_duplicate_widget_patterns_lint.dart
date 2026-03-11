import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Lint that flags structurally duplicate widget subtrees within the same file.
///
/// This catches the most common AI refactor failure: the model creates a new
/// reusable widget but leaves the original inline code in place, so the same
/// widget tree appears two or more times instead of being replaced.
///
/// ## What counts as a duplicate
///
/// Two widget constructions are considered duplicates when they share the
/// same **structural fingerprint**: the ordered sequence of widget type names
/// in the subtree (e.g. `[Row, Icon, SizedBox, Text]`).  Named argument
/// labels are included in the fingerprint so `Column(children:[...])` and
/// `Row(children:[...])` are distinct.  Literal values are intentionally
/// ignored — only structure matters — which avoids false positives when the
/// same layout is used with different data.
///
/// A minimum subtree depth of [_minDepth] widgets is required before a
/// fingerprint is considered worth flagging, keeping the rule focused on
/// meaningful patterns rather than trivial single-widget uses.
///
/// ## Example — flagged
///
/// ```dart
/// // In widget A
/// Row(children: [Icon(Icons.clock), SizedBox(width: 8), Text('...')])
///
/// // In widget B — identical structure, different label
/// Row(children: [Icon(Icons.clock), SizedBox(width: 8), Text('...')])
/// ```
///
/// ## Example — not flagged
///
/// ```dart
/// // Uses the extracted reusable widget — no duplication
/// TimeInputField(label: 'Departure'),
/// TimeInputField(label: 'Arrival'),
/// ```
class NoDuplicateWidgetPatternsLint extends DartLintRule {
  /// Creates the lint rule.
  const NoDuplicateWidgetPatternsLint()
    : super(
        code: const LintCode(
          name: 'no_duplicate_widget_patterns',
          problemMessage:
              'This widget subtree is structurally identical to another '
              'one in the same file. Extract it into a reusable widget.',
          correctionMessage:
              'Create a new StatelessWidget or StatefulWidget that '
              'encapsulates this subtree and replace both occurrences.',
          errorSeverity: DiagnosticSeverity.WARNING,
        ),
      );

  /// Minimum number of nested widget nodes before a pattern is considered
  /// worth flagging.  Keeps the rule focused on meaningful subtrees.
  static const int _minDepth = 3;

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    final path = resolver.source.fullName.replaceAll(r'\', '/');
    if (!_isUiFile(path)) return;

    // Collect all widget construction fingerprints across the whole file once
    // the compilation unit is available.
    context.registry.addCompilationUnit((unit) {
      final collector = _WidgetFingerprintCollector();
      unit.accept(collector);

      // Group nodes by fingerprint.
      final seen = <String, List<InstanceCreationExpression>>{};
      for (final entry in collector.entries) {
        seen.putIfAbsent(entry.fingerprint, () => []).add(entry.node);
      }

      // Report every occurrence of fingerprints that appear more than once.
      for (final group in seen.values) {
        if (group.length < 2) continue;
        for (final node in group) {
          reporter.atNode(node.constructorName, code);
        }
      }
    });
  }

  bool _isUiFile(String path) {
    return path.contains('/lib/presentation/') ||
        path.contains('/lib/ui/') ||
        (path.contains('/lib/features/') &&
            (path.contains('/presentation/') || path.contains('/ui/')));
  }
}

/// A single collected result: the root AST node and its structural fingerprint.
class _FingerprintEntry {
  const _FingerprintEntry({required this.node, required this.fingerprint});

  final InstanceCreationExpression node;
  final String fingerprint;
}

/// Walks the AST and builds a [_FingerprintEntry] for every widget
/// construction whose subtree depth meets the minimum threshold.
class _WidgetFingerprintCollector extends RecursiveAstVisitor<void> {
  final List<_FingerprintEntry> entries = [];

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final fingerprint = _FingerprintBuilder().build(node);
    if (fingerprint != null) {
      entries.add(_FingerprintEntry(node: node, fingerprint: fingerprint));
    }
    // Continue descent so nested widgets are also checked independently.
    super.visitInstanceCreationExpression(node);
  }
}

/// Builds a structural fingerprint string for a widget subtree.
///
/// The fingerprint is the depth-first sequence of widget constructor tokens
/// separated by `>`.  Named argument labels are included as `:<label>` so
/// that positionally-different layouts remain distinct.
///
/// Returns `null` when the subtree is shallower than [_minDepth].
class _FingerprintBuilder {
  static const int _minDepth = NoDuplicateWidgetPatternsLint._minDepth;

  final StringBuffer _buffer = StringBuffer();
  int _nodeCount = 0;

  String? build(InstanceCreationExpression root) {
    _visit(root);
    if (_nodeCount < _minDepth) return null;
    return _buffer.toString();
  }

  void _visit(InstanceCreationExpression node) {
    _nodeCount++;
    // Record the widget type name.
    final typeName = node.constructorName.type.name.lexeme;
    _buffer.write(typeName);

    // Record named argument labels so structure is captured more precisely.
    for (final arg in node.argumentList.arguments) {
      if (arg is NamedExpression) {
        _buffer.write(':${arg.name.label.name}');
      }
    }

    // Descend into child widget constructions.
    for (final arg in node.argumentList.arguments) {
      final expr = arg is NamedExpression ? arg.expression : arg;
      _visitExpression(expr);
    }
  }

  void _visitExpression(Expression expr) {
    if (expr is InstanceCreationExpression) {
      _buffer.write('>');
      _visit(expr);
    } else if (expr is ListLiteral) {
      for (final element in expr.elements) {
        if (element is Expression) {
          _visitExpression(element);
        }
      }
    } else if (expr is ConditionalExpression) {
      _visitExpression(expr.thenExpression);
      _visitExpression(expr.elseExpression);
    }
  }
}
