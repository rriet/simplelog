import 'package:flutter/material.dart';
import 'package:simplelog/data/models/airport_filters.dart';

class AirportFiltersDialog extends StatefulWidget {
  const AirportFiltersDialog({
    super.key,
    required this.initial,
  });

  final AirportFilters initial;

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
    return AlertDialog(
      title: const Text('Airport Filters'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order by',
              style: TextStyle(fontWeight: FontWeight.w600),
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
                      child: Text(_orderByLabel(option)),
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
              title: const Text('Show only visited'),
              value: _showOnlyVisited,
              onChanged: (value) => setState(() => _showOnlyVisited = value),
            ),
            const SizedBox(height: 12),
            const Text(
              'Search by',
              style: TextStyle(fontWeight: FontWeight.w600),
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
                      child: Text(_searchFieldLabel(option)),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            AirportFilters(
              orderBy: _orderBy,
              searchField: _searchField,
              showOnlyVisited: _showOnlyVisited,
            ),
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  String _orderByLabel(AirportOrderBy orderBy) {
    switch (orderBy) {
      case AirportOrderBy.icao:
        return 'ICAO';
      case AirportOrderBy.iata:
        return 'IATA';
      case AirportOrderBy.name:
        return 'Name';
      case AirportOrderBy.city:
        return 'City';
      case AirportOrderBy.country:
        return 'Country';
      case AirportOrderBy.landings:
        return 'Landings';
      case AirportOrderBy.takeoffs:
        return 'TakeOffs';
      case AirportOrderBy.visits:
        return 'Visits';
    }
  }

  String _searchFieldLabel(AirportSearchField field) {
    switch (field) {
      case AirportSearchField.all:
        return 'All';
      case AirportSearchField.icao:
        return 'ICAO';
      case AirportSearchField.iata:
        return 'IATA';
      case AirportSearchField.icaoOrIata:
        return 'ICAO or IATA';
      case AirportSearchField.name:
        return 'Name';
      case AirportSearchField.city:
        return 'City';
      case AirportSearchField.country:
        return 'Country';
    }
  }
}
