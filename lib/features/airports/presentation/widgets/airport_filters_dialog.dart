import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/airport_filters.dart';

/// Modal dialog that edits airport list ordering and search filters.
class AirportFiltersDialog extends StatefulWidget {
  /// Creates a dialog initialized with existing filter values.
  const AirportFiltersDialog({
    required this.initial,
    super.key,
  });

  /// Initial filter state shown when the dialog opens.
  final AirportFilters initial;

  /// Opens the dialog and returns the updated filters when applied.
  static Future<AirportFilters?> show(
    BuildContext context, {
    required AirportFilters initial,
  }) {
    return showDialog<AirportFilters>(
      context: context,
      builder: (context) => AirportFiltersDialog(initial: initial),
    );
  }

  @override
  State<AirportFiltersDialog> createState() => _AirportFiltersDialogState();
}

class _AirportFiltersDialogState extends State<AirportFiltersDialog> {
  late AirportOrderBy _orderBy;
  late AirportSearchField _searchField;
  late bool _showOnlyVisited;

  @override
  void initState() {
    super.initState();
    _orderBy = widget.initial.orderBy;
    _searchField = widget.initial.searchField;
    _showOnlyVisited = widget.initial.showOnlyVisited;
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
                        l10n.airportFiltersTitle,
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
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.orderByLabel,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<AirportOrderBy>(
                      initialValue: _orderBy,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: AirportOrderBy.values
                          .map(
                            (option) => DropdownMenuItem(
                              value: option,
                              child: Text(_orderByLabel(l10n, option)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _orderBy = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.airportShowOnlyVisited),
                      value: _showOnlyVisited,
                      onChanged: (value) =>
                          setState(() => _showOnlyVisited = value),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.searchByLabel,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<AirportSearchField>(
                      initialValue: _searchField,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: AirportSearchField.values
                          .map(
                            (option) => DropdownMenuItem(
                              value: option,
                              child: Text(_searchFieldLabel(l10n, option)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _searchField = value);
                      },
                    ),
                  ],
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
                      onPressed: () => Navigator.of(context).pop(
                        AirportFilters(
                          orderBy: _orderBy,
                          searchField: _searchField,
                          showOnlyVisited: _showOnlyVisited,
                        ),
                      ),
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

  String _orderByLabel(AppLocalizations l10n, AirportOrderBy orderBy) {
    switch (orderBy) {
      case AirportOrderBy.icao:
        return l10n.fieldIcao;
      case AirportOrderBy.iata:
        return l10n.fieldIata;
      case AirportOrderBy.name:
        return l10n.fieldName;
      case AirportOrderBy.city:
        return l10n.fieldCity;
      case AirportOrderBy.country:
        return l10n.fieldCountry;
      case AirportOrderBy.landings:
        return l10n.fieldLandings;
      case AirportOrderBy.takeoffs:
        return l10n.fieldTakeoffs;
      case AirportOrderBy.visits:
        return l10n.fieldVisits;
    }
  }

  String _searchFieldLabel(AppLocalizations l10n, AirportSearchField field) {
    switch (field) {
      case AirportSearchField.all:
        return l10n.optionAll;
      case AirportSearchField.icao:
        return l10n.fieldIcao;
      case AirportSearchField.iata:
        return l10n.fieldIata;
      case AirportSearchField.icaoOrIata:
        return l10n.airportSearchIcaoOrIata;
      case AirportSearchField.name:
        return l10n.fieldName;
      case AirportSearchField.city:
        return l10n.fieldCity;
      case AirportSearchField.country:
        return l10n.fieldCountry;
    }
  }
}
