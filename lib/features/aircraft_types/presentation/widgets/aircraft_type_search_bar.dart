import 'package:flutter/material.dart';

/// Public API documentation.
class AircraftTypeSearchBar extends StatelessWidget {
  /// Public API documentation.
  const AircraftTypeSearchBar({
    required this.controller,
    required this.label,
    required this.onChanged,
    super.key,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final TextEditingController controller;
  /// Public API documentation.
  final String label;
  /// Public API documentation.
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
