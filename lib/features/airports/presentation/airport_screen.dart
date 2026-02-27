import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/constants/app_constants.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/airport_filters.dart';
import 'package:simplelog/data/models/airport_row.dart';
import 'package:simplelog/features/airports/application/providers/airports_feature_providers.dart';
import 'package:simplelog/features/airports/presentation/airport_edit_screen.dart';
import 'package:simplelog/features/airports/presentation/widgets/airport_details_dialog.dart';
import 'package:simplelog/features/airports/presentation/widgets/airport_filters_dialog.dart';
import 'package:simplelog/features/airports/presentation/widgets/airport_list.dart';
import 'package:simplelog/features/airports/presentation/widgets/airport_search_bar.dart';
import 'package:simplelog/features/logbook/application/providers/logbook_feature_providers.dart';
import 'package:simplelog/presentation/shared/widgets/app_message_dialog.dart';
import 'package:simplelog/state/controllers/validation_result.dart';

/// Main airport management screen.
class AirportsScreen extends ConsumerStatefulWidget {
  /// Creates the airport management screen.
  const AirportsScreen({super.key});

  @override
  ConsumerState<AirportsScreen> createState() => _AirportsScreenState();
}

class _AirportsScreenState extends ConsumerState<AirportsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleLock(AirportRow row) async {
    final controller = ref.read(airportControllerProvider.notifier);
    await controller.toggleLock(row.airport);
  }

  Future<void> _toggleFavorite(AirportRow row) async {
    final controller = ref.read(airportControllerProvider.notifier);
    await controller.toggleFavorite(row.airport);
  }

  Future<void> _openFilters() async {
    final current = ref.read(airportFiltersProvider);
    final updated = await AirportFiltersDialog.show(context, initial: current);
    if (!mounted || updated == null) return;
    await ref.read(airportFiltersProvider.notifier).setFilters(updated);
  }

  Future<void> _confirmDelete(AirportRow row) async {
    final dataController = ref.read(airportDataControllerProvider.notifier);
    final validation = await dataController.validateDelete(row.airport);
    if (!validation.isValid) {
      if (!mounted) return;
      await _showValidationError(validation);
      return;
    }
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteAirport(row.icao)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deleteAction),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await dataController.delete(row.airport);
    }
  }

  Future<void> _showValidationError(ValidationResult validation) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    await showAppMessageDialog(
      context,
      title: l10n.validationErrorTitle,
      message: validation.message ?? l10n.validationErrorGeneric,
      okLabel: l10n.okAction,
    );
  }

  Future<void> _showAirportDetails(AirportRow row) async {
    final logbookUseCases = ref.read(logbookUseCasesProvider);
    await showAirportDetailsDialog(
      context,
      airport: row.airport,
      logbookUseCases: logbookUseCases,
    );
  }

  Future<void> _createAirport() async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    const placeholder = Airport(
      id: kPlaceholderId,
      icao: '',
      latitude: 0,
      longitude: 0,
      isFavorite: false,
      isLocked: false,
    );

    if (isCompact) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              const AirportEditScreen(item: placeholder, isCreate: true),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        final size = MediaQuery.sizeOf(context);
        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 520,
              maxHeight: size.height * 0.9,
            ),
            child: const AirportEditScreen(item: placeholder, isCreate: true),
          ),
        );
      },
    );
  }

  Future<void> _editAirport(AirportRow row) async {
    final isCompact = MediaQuery.of(context).size.width < 600;

    if (isCompact) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AirportEditScreen(item: row.airport),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        final size = MediaQuery.sizeOf(context);
        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 520,
              maxHeight: size.height * 0.9,
            ),
            child: AirportEditScreen(item: row.airport),
          ),
        );
      },
    );
  }

  String _searchLabel(AppLocalizations l10n) {
    final filters = ref.read(airportFiltersProvider);
    switch (filters.searchField) {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filters = ref.watch(airportFiltersProvider);
    final airports = ref.watch(
      airportsProvider(AirportSearchParams(query: _query, filters: filters)),
    );
    final isCompact = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        AirportSearchBar(
          controller: _searchController,
          label: _searchLabel(l10n),
          onChanged: (value) => setState(() => _query = value),
          onFilterPressed: _openFilters,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: airports.when(
            data: (items) => AirportList(
              items: items,
              isCompact: isCompact,
              onToggleFavorite: _toggleFavorite,
              onToggleLock: _toggleLock,
              onEdit: _editAirport,
              onDelete: _confirmDelete,
              onOpenDetails: _showAirportDetails,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
          ),
        ),
        const SizedBox(height: 8),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.only(right: 16, bottom: 8),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: _createAirport,
              tooltip: l10n.createAirportTitle,
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}
