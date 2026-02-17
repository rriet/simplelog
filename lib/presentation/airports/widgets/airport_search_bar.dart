import 'package:flutter/material.dart';

class AirportSearchBar extends StatelessWidget {
  const AirportSearchBar({
    super.key,
    required this.controller,
    required this.label,
    required this.onChanged,
    required this.onFilterPressed,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Filters',
            onPressed: onFilterPressed,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
    );
  }
}
