import 'package:flutter/material.dart';

/// Shared expandable card used by import wizard dialogs.
class ImportWizardSectionCard extends StatelessWidget {
  /// Creates an import wizard section card.
  const ImportWizardSectionCard({
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    this.childrenPadding = const EdgeInsets.fromLTRB(16, 0, 16, 8),
    super.key,
  });

  /// Section title.
  final String title;

  /// Expanded card content.
  final List<Widget> children;

  /// Whether the section starts expanded.
  final bool initiallyExpanded;

  /// Called when expansion state changes.
  final ValueChanged<bool>? onExpansionChanged;

  /// Padding applied to section content.
  final EdgeInsetsGeometry childrenPadding;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        onExpansionChanged: onExpansionChanged,
        title: Text(title),
        childrenPadding: childrenPadding,
        children: children,
      ),
    );
  }
}
