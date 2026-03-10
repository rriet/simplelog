import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/dialog_adaptive_presenter.dart';
import 'package:simplelog/core/presentation/widgets/pickers/entity_picker_dialog.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/airport_filters.dart';
import 'package:simplelog/features/airports/application/providers/airports_feature_providers.dart';
import 'package:simplelog/features/airports/presentation/widgets/airport_filters_dialog.dart';

/// Generic dialog used to search and pick an airport from the database.
class AirportPickerDialog extends StatelessWidget {
  /// Creates a dialog with the given [title] text.
  const AirportPickerDialog({
    required this.title,
    super.key,
  });

  /// Title shown at the top of the dialog.
  final String title;

  /// Shows the picker and returns the selected [Airport], if any.
  static Future<Airport?> show(
    BuildContext context, {
    required String title,
  }) {
    final screen = AirportPickerDialog(title: title);
    if (isCompactDialogScreen(context)) {
      return Navigator.of(
        context,
        rootNavigator: true,
      ).push<Airport>(MaterialPageRoute(builder: (_) => screen));
    }
    return showDialog<Airport>(
      context: context,
      builder: (_) => screen,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AdaptiveFormShell(
      onClose: () => Navigator.of(context).pop(),
      longTitle: title,
      shortTitle: title,
      contentView: SizedBox(
        height: 700,
        child: EntityPickerDialog<Airport>(
          title: title,
          showHeader: false,
          searchLabelBuilder: (ref) {
            final filters = ref.watch(airportFiltersProvider);
            return _searchLabel(l10n, filters.searchField);
          },
          itemsBuilder: (ref, query) {
            final filters = ref.watch(airportFiltersProvider);
            final rowsAsync = ref.watch(
              airportsProvider(
                AirportSearchParams(query: query, filters: filters),
              ),
            );
            return rowsAsync.when(
              data: (rows) => AsyncValue<List<Airport>>.data(
                rows.map((row) => row.airport).toList(growable: false),
              ),
              loading: () => const AsyncValue<List<Airport>>.loading(),
              error: AsyncValue<List<Airport>>.error,
            );
          },
          itemKey: (airport) => airport.id,
          itemTitle: (airport) =>
              '${airport.icao}'
              '${(airport.iata ?? '').isEmpty ? '' : ' / ${airport.iata}'}',
          itemSubtitle: (airport) => [
            if ((airport.name ?? '').trim().isNotEmpty) airport.name!,
            if ((airport.city ?? '').trim().isNotEmpty) airport.city!,
            if ((airport.country ?? '').trim().isNotEmpty) airport.country!,
          ].join(' • '),
          searchTrailingBuilder: (context, ref) => IconButton(
            tooltip: l10n.logbookFilterAction,
            onPressed: () async {
              final current = ref.read(airportFiltersProvider);
              final updated = await AirportFiltersDialog.show(
                context,
                initial: current,
              );
              if (updated == null) return;
              await ref
                  .read(airportFiltersProvider.notifier)
                  .setFilters(updated);
            },
            icon: const Icon(Icons.filter_list),
          ),
          isFavorite: (airport) => airport.isFavorite,
          onToggleFavorite: (ref, airport) async {
            await ref
                .read(airportControllerProvider.notifier)
                .toggleFavorite(
                  airport,
                );
          },
          emptyText: l10n.airportEmptyResults,
          errorBuilder: (_, _) => Center(child: Text(l10n.airportLoadError)),
        ),
      ),
    );
  }

  String _searchLabel(AppLocalizations l10n, AirportSearchField field) {
    switch (field) {
      case AirportSearchField.all:
        return l10n.searchAirports;
      case AirportSearchField.icao:
        return l10n.searchIcao;
      case AirportSearchField.iata:
        return l10n.searchIata;
      case AirportSearchField.icaoOrIata:
        return l10n.searchIcaoIata;
      case AirportSearchField.name:
        return l10n.searchName;
      case AirportSearchField.city:
        return l10n.searchCity;
      case AirportSearchField.country:
        return l10n.searchCountry;
    }
  }
}
