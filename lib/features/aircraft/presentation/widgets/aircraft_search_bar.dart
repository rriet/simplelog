import 'package:flutter/material.dart';
import 'package:simplelog/presentation/shared/widgets/picker_search_bar.dart';

/// Public API documentation.
class AircraftSearchBar extends StatelessWidget {
  /// Public API documentation.
  const AircraftSearchBar({
    required this.controller,
    required this.label,
    required this.onChanged,
    super.key,
    this.trailing,
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
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return PickerSearchBar(
      controller: controller,
      label: label,
      onChanged: onChanged,
      trailing: trailing,
    );
  }
}
