import 'package:flutter/material.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/dropdown_input_field.dart';

enum AircraftSearchBy {
  all,
  registration,
  type,
  family,
  notes,
}

class AircraftFiltersDialog extends StatefulWidget {
  const AircraftFiltersDialog({
    super.key,
    required this.initialSearchBy,
  });

  final AircraftSearchBy initialSearchBy;

  static Future<AircraftSearchBy?> show(
    BuildContext context, {
    required AircraftSearchBy initialSearchBy,
  }) {
    return showDialog<AircraftSearchBy>(
      context: context,
      builder: (context) => AircraftFiltersDialog(
        initialSearchBy: initialSearchBy,
      ),
    );
  }

  @override
  State<AircraftFiltersDialog> createState() => _AircraftFiltersDialogState();
}

class _AircraftFiltersDialogState extends State<AircraftFiltersDialog> {
  late AircraftSearchBy _searchBy;

  @override
  void initState() {
    super.initState();
    _searchBy = widget.initialSearchBy;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 520,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Aircraft Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: DropdownInputField<AircraftSearchBy>(
                  label: 'Search By',
                  value: _searchBy,
                  items: const [
                    DropdownMenuItem(
                      value: AircraftSearchBy.all,
                      child: Text('All'),
                    ),
                    DropdownMenuItem(
                      value: AircraftSearchBy.registration,
                      child: Text('Registration'),
                    ),
                    DropdownMenuItem(
                      value: AircraftSearchBy.type,
                      child: Text('Type'),
                    ),
                    DropdownMenuItem(
                      value: AircraftSearchBy.family,
                      child: Text('Family'),
                    ),
                    DropdownMenuItem(
                      value: AircraftSearchBy.notes,
                      child: Text('Notes'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _searchBy = value);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(_searchBy),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
