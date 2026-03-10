import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/presentation/widgets/pickers/picker_search_bar.dart';

/// Search bar used in airport screens/dialogs.
class AirportSearchBar extends StatelessWidget {
  /// Creates the airport search bar.
  const AirportSearchBar({
    required this.controller,
    required this.label,
    required this.onChanged,
    required this.onFilterPressed,
    super.key,
    this.autofocus = false,
    this.focusNode,
    this.onSubmitted,
    this.onKeyEvent,
  });

  /// Search text controller.
  final TextEditingController controller;
  /// Search field label.
  final String label;
  /// Called when query text changes.
  final ValueChanged<String> onChanged;
  /// Opens the filter dialog.
  final VoidCallback onFilterPressed;
  /// Whether field auto-focuses on open.
  final bool autofocus;
  /// Optional focus node override.
  final FocusNode? focusNode;
  /// Optional submit callback.
  final ValueChanged<String>? onSubmitted;
  /// Optional key event handler for keyboard navigation.
  final KeyEventResult Function(FocusNode, KeyEvent)? onKeyEvent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PickerSearchBar(
      controller: controller,
      label: label,
      onChanged: onChanged,
      autofocus: autofocus,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      onKeyEvent: onKeyEvent,
      trailing: IconButton(
        tooltip: l10n.logbookFilterAction,
        onPressed: onFilterPressed,
        icon: const Icon(Icons.filter_list),
      ),
    );
  }
}
