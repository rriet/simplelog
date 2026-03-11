import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:simplelog_lints/src/rules/file_naming_conventions_lint.dart';
import 'package:simplelog_lints/src/rules/layer_boundary_lint.dart';
import 'package:simplelog_lints/src/rules/no_business_logic_in_widgets_lint.dart';
import 'package:simplelog_lints/src/rules/no_db_access_from_ui_lint.dart';
import 'package:simplelog_lints/src/rules/no_direct_navigator_push_lint.dart';
import 'package:simplelog_lints/src/rules/no_duplicate_widget_patterns_lint.dart';
import 'package:simplelog_lints/src/rules/no_hardcoded_widget_strings_lint.dart';
import 'package:simplelog_lints/src/rules/no_raw_catch_swallow_lint.dart';
import 'package:simplelog_lints/src/rules/no_set_state_after_async_lint.dart';

/// Entry point used by `custom_lint` to load this plugin.
PluginBase createPlugin() => _SimpleLogLintsPlugin();

class _SimpleLogLintsPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) {
    return [
      // --- Existing rules ---
      const NoHardcodedWidgetStringsLint(),
      const NoDirectDbAccessFromUiLint(),
      const LayerBoundaryLint(),
      const NoBusinessLogicInWidgetsLint(),
      const FileNamingConventionsLint(),

      // --- New rules ---
      // ERROR: silent exception swallowing
      const NoRawCatchSwallowLint(),       
      // ERROR: setState after await without mounted
      const NoSetStateAfterAsyncLint(),    
      // ERROR: Navigator.push bypassing router
      const NoDirectNavigatorPushLint(),   
      // WARNING: duplicate widget subtrees
      const NoDuplicateWidgetPatternsLint(), 
    ];
  }
}
