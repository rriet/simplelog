import 'package:flutter/material.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/dropdown_input_field.dart';

enum CrewSearchBy {
  all,
  name,
  email,
  phone,
  notes,
}

class CrewFiltersDialog extends StatefulWidget {
  const CrewFiltersDialog({
    super.key,
    required this.initialSearchBy,
  });

  final CrewSearchBy initialSearchBy;

  static Future<CrewSearchBy?> show(
    BuildContext context, {
    required CrewSearchBy initialSearchBy,
  }) {
    return showDialog<CrewSearchBy>(
      context: context,
      builder: (context) => CrewFiltersDialog(
        initialSearchBy: initialSearchBy,
      ),
    );
  }

  @override
  State<CrewFiltersDialog> createState() => _CrewFiltersDialogState();
}

class _CrewFiltersDialogState extends State<CrewFiltersDialog> {
  late CrewSearchBy _searchBy;

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
                        'Crew Filters',
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
                child: DropdownInputField<CrewSearchBy>(
                  label: 'Search By',
                  value: _searchBy,
                  items: const [
                    DropdownMenuItem(value: CrewSearchBy.all, child: Text('All')),
                    DropdownMenuItem(value: CrewSearchBy.name, child: Text('Name')),
                    DropdownMenuItem(value: CrewSearchBy.email, child: Text('Email')),
                    DropdownMenuItem(value: CrewSearchBy.phone, child: Text('Phone')),
                    DropdownMenuItem(value: CrewSearchBy.notes, child: Text('Notes')),
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
