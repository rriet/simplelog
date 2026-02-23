import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'package:simplelog_lints/src/rules/file_naming_conventions_lint.dart';
import 'package:simplelog_lints/src/rules/layer_boundary_lint.dart';
import 'package:simplelog_lints/src/rules/no_business_logic_in_widgets_lint.dart';
import 'package:simplelog_lints/src/rules/no_db_access_from_ui_lint.dart';
import 'package:simplelog_lints/src/rules/no_hardcoded_widget_strings_lint.dart';

/// Entry point used by `custom_lint` to load this plugin.
PluginBase createPlugin() => _SimpleLogLintsPlugin();

class _SimpleLogLintsPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) {
    return [
      const NoHardcodedWidgetStringsLint(),
      const NoDirectDbAccessFromUiLint(),
      const LayerBoundaryLint(),
      const NoBusinessLogicInWidgetsLint(),
      const FileNamingConventionsLint(),
    ];
  }
}
