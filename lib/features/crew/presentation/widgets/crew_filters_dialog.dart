import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/dropdown_input_field.dart';

/// Search fields available in crew filter dialog.
enum CrewSearchBy {
  /// Search across all supported fields.
  all,
  /// Search by crew name.
  name,
  /// Search by email.
  email,
  /// Search by phone.
  phone,
  /// Search by notes.
  notes,
}

/// Dialog to configure crew search mode.
class CrewFiltersDialog extends StatefulWidget {
  /// Creates the crew filters dialog.
  const CrewFiltersDialog({
    required this.initialSearchBy,
    super.key,
  });

  /// Initial selected search field.
  final CrewSearchBy initialSearchBy;

  /// Opens the dialog and returns selected search mode.
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
                        l10n.crewFiltersTitle,
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
                child: DropdownInputField<CrewSearchBy>(
                  label: l10n.searchByLabel,
                  value: _searchBy,
                  items: [
                    DropdownMenuItem(
                      value: CrewSearchBy.all,
                      child: Text(l10n.optionAll),
                    ),
                    DropdownMenuItem(
                      value: CrewSearchBy.name,
                      child: Text(l10n.fieldName),
                    ),
                    DropdownMenuItem(
                      value: CrewSearchBy.email,
                      child: Text(l10n.fieldEmail),
                    ),
                    DropdownMenuItem(
                      value: CrewSearchBy.phone,
                      child: Text(l10n.fieldPhone),
                    ),
                    DropdownMenuItem(
                      value: CrewSearchBy.notes,
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
