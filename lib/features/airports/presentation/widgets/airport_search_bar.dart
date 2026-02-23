import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/presentation/shared/widgets/picker_search_bar.dart';

/// Public API documentation.
class AirportSearchBar extends StatelessWidget {
  /// Public API documentation.
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
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final TextEditingController controller;
  /// Public API documentation.
  final String label;
  /// Public API documentation.
  final ValueChanged<String> onChanged;
  /// Public API documentation.
  final VoidCallback onFilterPressed;
  /// Public API documentation.
  final bool autofocus;
  /// Public API documentation.
  final FocusNode? focusNode;
  /// Public API documentation.
  final ValueChanged<String>? onSubmitted;
  /// Public API documentation.
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
