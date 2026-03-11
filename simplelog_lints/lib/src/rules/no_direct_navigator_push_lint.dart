import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Lint that prevents direct `Navigator.push/pop/pushNamed` calls from UI
/// files, enforcing that all navigation goes through your router abstraction
/// (e.g. GoRouter / AutoRoute).
///
/// AI almost always reaches for `Navigator.of(context).push(...)` because
/// that is the most common pattern in Flutter docs and Stack Overflow answers.
/// This bypasses your centralized routing, breaks deep-linking, and makes
/// navigation impossible to test.
///
/// Flagged calls:
///   - `Navigator.of(context).push(...)`
///   - `Navigator.of(context).pushNamed(...)`
///   - `Navigator.of(context).pushReplacement(...)`
///   - `Navigator.of(context).pushReplacementNamed(...)`
///   - `Navigator.of(context).pop(...)`
///   - `Navigator.push(context, ...)`  (static form)
///   - `Navigator.pushNamed(context, ...)`  (static form)
class NoDirectNavigatorPushLint extends DartLintRule {
  /// Creates the lint rule.
  const NoDirectNavigatorPushLint()
    : super(
        code: const LintCode(
          name: 'no_direct_navigator_push',
          problemMessage:
              'Do not use Navigator directly. '
              'All navigation must go through the app router.',
          correctionMessage:
              'Use your router (e.g. context.go(), context.push()) '
              'instead of Navigator.of(context).push().',
          errorSeverity: DiagnosticSeverity.ERROR,
        ),
      );

  static const _navigationMethods = {
    'push',
    'pushNamed',
    'pushReplacement',
    'pushReplacementNamed',
    'pushAndRemoveUntil',
    'pushNamedAndRemoveUntil',
    'pop',
    'popUntil',
    'popAndPushNamed',
    'maybePop',
  };

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    final path = resolver.source.fullName.replaceAll(r'\', '/');
    if (!_isUiFile(path)) return;

    context.registry.addMethodInvocation((node) {
      final methodName = node.methodName.name;
      if (!_navigationMethods.contains(methodName)) return;

      final target = node.realTarget;
      if (target == null) return;

      // Instance form: Navigator.of(context).push(...)
      // target will be a MethodInvocation of 'Navigator.of'
      if (target is MethodInvocation) {
        final innerTarget = target.realTarget;
        if (innerTarget != null &&
            _isNavigatorIdentifier(innerTarget) &&
            target.methodName.name == 'of') {
          reporter.atNode(node, code);
          return;
        }
      }

      // Static form: Navigator.push(context, ...)
      if (_isNavigatorIdentifier(target)) {
        reporter.atNode(node, code);
      }
    });
  }

  bool _isUiFile(String path) {
    return path.contains('/lib/presentation/') ||
        path.contains('/lib/ui/') ||
        (path.contains('/lib/features/') &&
            (path.contains('/presentation/') || path.contains('/ui/')));
  }

  bool _isNavigatorIdentifier(dynamic node) {
    if (node is SimpleIdentifier) return node.name == 'Navigator';
    return false;
  }
}
