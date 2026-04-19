import 'package:flutter/material.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/info_help_button.dart';

/// Reusable trailing controls for expandable settings sections.
///
/// Shows the expand/collapse chevron on the left and an info help button on
/// the right.
class SettingsExpandableInfoTrailing extends StatelessWidget {
  /// Creates trailing controls for an expandable settings section.
  const SettingsExpandableInfoTrailing({
    required this.controller,
    required this.isExpanded,
    required this.helpTitle,
    required this.helpMessage,
    super.key,
  });

  /// Controller used to expand/collapse the target [ExpansionTile].
  final ExpansibleController controller;

  /// Current expansion state of the target tile.
  final bool isExpanded;

  /// Title shown in the info help dialog.
  final String helpTitle;

  /// Body text shown in the info help dialog.
  final String helpMessage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExpandIcon(
          isExpanded: isExpanded,
          onPressed: (expanded) {
            if (expanded) {
              controller.collapse();
            } else {
              controller.expand();
            }
          },
        ),
        InfoHelpButton(
          title: helpTitle,
          message: helpMessage,
        ),
      ],
    );
  }
}
