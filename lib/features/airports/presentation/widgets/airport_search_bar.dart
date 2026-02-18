import 'package:flutter/material.dart';
import 'package:simplelog/presentation/shared/widgets/picker_search_bar.dart';

class AirportSearchBar extends StatelessWidget {
  const AirportSearchBar({
    super.key,
    required this.controller,
    required this.label,
    required this.onChanged,
    required this.onFilterPressed,
    this.autofocus = false,
    this.focusNode,
    this.onSubmitted,
    this.onKeyEvent,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterPressed;
  final bool autofocus;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final KeyEventResult Function(FocusNode, KeyEvent)? onKeyEvent;

  @override
  Widget build(BuildContext context) {
    return PickerSearchBar(
      controller: controller,
      label: label,
      onChanged: onChanged,
      autofocus: autofocus,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      onKeyEvent: onKeyEvent,
      trailing: IconButton(
        tooltip: 'Filters',
        onPressed: onFilterPressed,
        icon: const Icon(Icons.filter_list),
      ),
    );
  }
}
