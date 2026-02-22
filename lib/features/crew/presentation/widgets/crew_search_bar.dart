import 'package:flutter/material.dart';
import 'package:simplelog/presentation/shared/widgets/picker_search_bar.dart';

class CrewSearchBar extends StatelessWidget {
  const CrewSearchBar({
    super.key,
    required this.controller,
    required this.label,
    required this.onChanged,
    this.trailing,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
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
