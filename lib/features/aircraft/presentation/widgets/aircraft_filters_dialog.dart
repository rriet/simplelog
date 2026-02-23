import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/dropdown_input_field.dart';

/// Public API documentation.
enum AircraftSearchBy {
  /// Public API documentation.
  all,
  /// Public API documentation.
  registration,
  /// Public API documentation.
  type,
  /// Public API documentation.
  family,
  /// Public API documentation.
  notes,
}

/// Public API documentation.
class AircraftFiltersDialog extends StatefulWidget {
  /// Public API documentation.
  const AircraftFiltersDialog({
    required this.initialSearchBy,
    super.key,
  });

  /// Public API documentation.
  final AircraftSearchBy initialSearchBy;

  /// Public API documentation.
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
    final l10n = AppLocalizations.of(context)!;
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
                    Expanded(
                      child: Text(
                        l10n.aircraftFiltersTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: DropdownInputField<AircraftSearchBy>(
                  label: l10n.searchByLabel,
                  value: _searchBy,
                  items: [
                    DropdownMenuItem(
                      value: AircraftSearchBy.all,
                      child: Text(l10n.optionAll),
                    ),
                    DropdownMenuItem(
                      value: AircraftSearchBy.registration,
                      child: Text(l10n.fieldRegistration),
                    ),
                    DropdownMenuItem(
                      value: AircraftSearchBy.type,
                      child: Text(l10n.searchFieldType),
                    ),
                    DropdownMenuItem(
                      value: AircraftSearchBy.family,
                      child: Text(l10n.fieldFamily),
                    ),
                    DropdownMenuItem(
                      value: AircraftSearchBy.notes,
                      child: Text(l10n.fieldNotes),
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
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.cancelAction),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(_searchBy),
                      child: Text(l10n.applyAction),
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
