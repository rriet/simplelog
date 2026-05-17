import 'package:flutter/material.dart';
import 'package:simplelog/core/presentation/widgets/inputs/text_input_field.dart';

/// Search input used by picker dialogs.
class PickerSearchBar extends StatefulWidget {
  /// Creates a picker search bar.
  const PickerSearchBar({
    required this.controller,
    required this.label,
    required this.onChanged,
    super.key,
    this.autofocus = false,
    this.focusNode,
    this.onSubmitted,
    this.onKeyEvent,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 0),
  });

  /// Text controller for the search text.
  final TextEditingController controller;

  /// Input label.
  final String label;

  /// Called when search text changes.
  final ValueChanged<String> onChanged;

  /// Whether the field should autofocus.
  final bool autofocus;

  /// Optional external focus node.
  final FocusNode? focusNode;

  /// Called when submit/enter is triggered.
  final ValueChanged<String>? onSubmitted;

  /// Optional keyboard event handler.
  final KeyEventResult Function(FocusNode, KeyEvent)? onKeyEvent;

  /// Optional trailing widget displayed at the right side.
  final Widget? trailing;

  /// External padding around the search row.
  final EdgeInsetsGeometry padding;

  @override
  State<PickerSearchBar> createState() => _PickerSearchBarState();
}

class _PickerSearchBarState extends State<PickerSearchBar> {
  late final FocusNode _internalFocusNode;
  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _internalFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Row(
        children: [
          Expanded(
            child: Focus(
              onKeyEvent: widget.onKeyEvent,
              child: TextInputField(
                controller: widget.controller,
                label: widget.label,
                focusNode: _effectiveFocusNode,
                autofocus: widget.autofocus,
                textCapitalization: TextCapitalization.characters,
                prefixIcon: const Icon(Icons.search),
                onTap: () => _effectiveFocusNode.requestFocus(),
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
              ),
            ),
          ),
          if (widget.trailing != null) ...[
            const SizedBox(width: 8),
            widget.trailing!,
          ],
        ],
      ),
    );
  }
}
