import 'package:flutter/material.dart';
import 'package:simplelog/presentation/shared/widgets/picker_search_bar.dart';

/// Search bar used in aircraft screens/dialogs.
class AircraftSearchBar extends StatelessWidget {
  /// Creates the aircraft search bar.
  const AircraftSearchBar({
    required this.controller,
    required this.label,
    required this.onChanged,
    super.key,
    this.trailing,
  });

  /// Search text controller.
  final TextEditingController controller;
  /// Field label.
  final String label;
  /// Called when query changes.
  final ValueChanged<String> onChanged;
  /// Optional trailing widget (e.g. filter/settings button).
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
