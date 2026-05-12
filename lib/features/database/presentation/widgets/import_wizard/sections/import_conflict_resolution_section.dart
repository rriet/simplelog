import 'package:flutter/material.dart';
import 'package:simplelog/features/database/presentation/widgets/import_wizard/import_wizard_section_card.dart';

/// Single conflict resolution toggle item.
class ImportConflictToggleConfig {
  /// Creates a conflict toggle descriptor.
  const ImportConflictToggleConfig({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  /// Toggle label.
  final String label;

  /// Current value.
  final bool value;

  /// Called when value changes.
  final ValueChanged<bool> onChanged;
}

/// Shared conflict resolution section used by import dialogs.
class ImportConflictResolutionSection extends StatelessWidget {
  /// Creates a conflict resolution section.
  const ImportConflictResolutionSection({
    required this.title,
    required this.toggles,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    super.key,
  });

  /// Section title.
  final String title;

  /// Conflict toggles.
  final List<ImportConflictToggleConfig> toggles;

  /// Whether the section starts expanded.
  final bool initiallyExpanded;

  /// Called when expansion state changes.
  final ValueChanged<bool>? onExpansionChanged;

  @override
  Widget build(BuildContext context) {
    return ImportWizardSectionCard(
      title: title,
      initiallyExpanded: initiallyExpanded,
      onExpansionChanged: onExpansionChanged,
      childrenPadding: EdgeInsets.zero,
      children: [
        for (final toggle in toggles)
          SwitchListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            title: Text(toggle.label),
            value: toggle.value,
            onChanged: toggle.onChanged,
          ),
      ],
    );
  }
}
