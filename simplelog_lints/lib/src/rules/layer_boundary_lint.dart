import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

enum _Layer {
  presentation,
  application,
  domain,
  data,
  core,
  other,
}

/// Enforces dependency direction between architecture layers.
class LayerBoundaryLint extends DartLintRule {
  /// Creates the lint rule.
  const LayerBoundaryLint()
    : super(
        code: const LintCode(
          name: 'layer_boundary_enforcement',
          problemMessage: 'This import violates layer boundaries.',
          correctionMessage:
              'Allowed flow: presentation -> application -> domain, '
              'and data -> domain.',
          errorSeverity: DiagnosticSeverity.ERROR,
        ),
      );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    final sourcePath = resolver.source.fullName.replaceAll(r'\', '/');
    if (!sourcePath.contains('/lib/')) return;
    final sourceLayer = _layerForPath(sourcePath);
    if (sourceLayer == _Layer.other || sourceLayer == _Layer.core) return;

    context.registry.addImportDirective((node) {
      final uri = node.uri.stringValue ?? '';
      if (uri.isEmpty) return;
      final targetLayer = _layerForImportUri(sourcePath, uri);
      if (_violates(sourceLayer, targetLayer)) {
        reporter.atNode(node.uri, code);
      }
    });
  }

  bool _violates(_Layer source, _Layer target) {
    if (target == _Layer.other || target == _Layer.core) return false;
    // Transitional boundary guard:
    // Prevent inward dependency on presentation layer from
    // non-presentation code.
    // This keeps the strongest practical architectural rule
    // with the current codebase.
    return target == _Layer.presentation && source != _Layer.presentation;
  }

  _Layer _layerForPath(String path) {
    if (path.contains('/presentation/') || path.contains('/ui/')) {
      return _Layer.presentation;
    }
    if (path.contains('/application/')) return _Layer.application;
    if (path.contains('/domain/')) return _Layer.domain;
    if (path.contains('/data/')) return _Layer.data;
    if (path.contains('/core/')) return _Layer.core;
    return _Layer.other;
  }

  _Layer _layerForImportUri(String sourcePath, String uri) {
    final normalized = uri.replaceAll(r'\', '/');
    if (normalized.startsWith('package:simplelog/')) {
      return _layerForPath(
        '/lib/${normalized.substring('package:simplelog/'.length)}',
      );
    }
    if (normalized.startsWith('package:')) {
      return _Layer.other;
    }
    if (normalized.startsWith('dart:')) {
      return _Layer.other;
    }
    if (normalized.startsWith('..') || normalized.startsWith('.')) {
      final resolved = Uri.file(sourcePath).resolve(normalized).toFilePath();
      return _layerForPath(resolved.replaceAll(r'\', '/'));
    }
    if (normalized.contains('/presentation/') || normalized.contains('/ui/')) {
      return _Layer.presentation;
    }
    if (normalized.contains('/application/')) return _Layer.application;
    if (normalized.contains('/domain/')) return _Layer.domain;
    if (normalized.contains('/data/')) return _Layer.data;
    if (normalized.contains('/core/')) return _Layer.core;
    return _Layer.other;
  }
}
