import 'package:flutter/material.dart';

/// Search bar used by aircraft type screens.
class AircraftTypeSearchBar extends StatelessWidget {
  /// Creates the aircraft type search bar.
  const AircraftTypeSearchBar({
    required this.controller,
    required this.label,
    required this.onChanged,
    super.key,
  });

  /// Search text controller.
  final TextEditingController controller;
  /// Field label.
  final String label;
  /// Called when query changes.
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
