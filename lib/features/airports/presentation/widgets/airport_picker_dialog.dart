import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/airport_filters.dart';
import 'package:simplelog/features/airports/application/providers/airports_feature_providers.dart';
import 'package:simplelog/presentation/shared/widgets/entity_picker_dialog.dart';

import 'airport_filters_dialog.dart';

class AirportPickerDialog extends StatelessWidget {
  const AirportPickerDialog({
    super.key,
    required this.title,
  });

  final String title;

  static Future<Airport?> show(
    BuildContext context, {
    required String title,
  }) {
    return showDialog<Airport>(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(
          width: 640,
          height: 700,
          child: AirportPickerDialog(title: title),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EntityPickerDialog<Airport>(
      title: title,
      searchLabelBuilder: (ref) {
        final filters = ref.watch(airportFiltersProvider);
        return _searchLabel(filters.searchField);
      },
      itemsBuilder: (ref, query) {
        final filters = ref.watch(airportFiltersProvider);
        return ref.watch(
          airportsProvider(AirportSearchParams(query: query, filters: filters)),
        ).whenData((rows) => rows.map((row) => row.airport).toList());
      },
      itemKey: (airport) => airport.id,
      itemTitle: (airport) =>
          '${airport.icao}${(airport.iata ?? '').isEmpty ? '' : ' / ${airport.iata}'}',
      itemSubtitle: (airport) => [
        if ((airport.name ?? '').trim().isNotEmpty) airport.name!,
        if ((airport.city ?? '').trim().isNotEmpty) airport.city!,
        if ((airport.country ?? '').trim().isNotEmpty) airport.country!,
      ].join(' • '),
      searchTrailingBuilder: (context, ref) => IconButton(
        tooltip: 'Filters',
        onPressed: () async {
          final current = ref.read(airportFiltersProvider);
          final updated = await AirportFiltersDialog.show(
            context,
            initial: current,
          );
          if (updated == null) return;
          await ref.read(airportFiltersProvider.notifier).setFilters(updated);
        },
        icon: const Icon(Icons.filter_list),
      ),
      isFavorite: (airport) => airport.isFavorite,
      onToggleFavorite: (ref, airport) async {
        await ref.read(airportControllerProvider.notifier).toggleFavorite(
              airport,
            );
      },
      emptyText: 'No airports found',
      errorBuilder: (_, __) => const Center(child: Text('Error loading airports')),
    );
  }

  String _searchLabel(AirportSearchField field) {
    switch (field) {
      case AirportSearchField.all:
        return 'Search airports';
      case AirportSearchField.icao:
        return 'Search ICAO';
      case AirportSearchField.iata:
        return 'Search IATA';
      case AirportSearchField.icaoOrIata:
        return 'Search ICAO/IATA';
      case AirportSearchField.name:
        return 'Search name';
      case AirportSearchField.city:
        return 'Search city';
      case AirportSearchField.country:
        return 'Search country';
    }
  }
}
