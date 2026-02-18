import 'package:flutter/material.dart';
import 'package:simplelog/presentation/shared/widgets/picker_search_bar.dart';

class AircraftSearchBar extends StatelessWidget {
  const AircraftSearchBar({
    super.key,
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return PickerSearchBar(
      controller: controller,
      label: label,
      onChanged: onChanged,
    );
  }
}
