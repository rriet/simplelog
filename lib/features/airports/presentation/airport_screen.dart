import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/maps/map_tile_caching.dart';
import 'package:simplelog/features/logbook/application/providers/logbook_feature_providers.dart';
import 'package:simplelog/features/airports/application/providers/airports_feature_providers.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/airport_filters.dart';
import 'package:simplelog/data/models/airport_row.dart';
import 'package:simplelog/data/models/airport_extensions.dart';
import 'package:simplelog/core/constants/app_constants.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entries_lazy_panel.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entry_dialogs.dart';
import 'package:simplelog/presentation/shared/widgets/app_message_dialog.dart';
import 'package:simplelog/state/controllers/validation_result.dart';
import 'airport_edit_screen.dart';
import 'widgets/airport_search_bar.dart';
import 'widgets/airport_list.dart';
import 'widgets/airport_filters_dialog.dart';

class AirportsScreen extends ConsumerStatefulWidget {
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
    final l10n = AppLocalizations.of(context)!;
    final airport = row.airport;
    final logbookUseCases = ref.read(logbookUseCasesProvider);

    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 480,
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              ListTile(
                title: const Text('Airport'),
                trailing: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _AirportHeader(
                        airport: airport,
                        onOpenMap: () => _showAirportExpandedMapDialog(
                          context,
                          LatLng(airport.latitude, airport.longitude),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.screenLogbook,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: LogbookEntriesLazyPanel(
                          pageLoader: (limit, offset) =>
                              logbookUseCases.fetchEntriesForAirportPage(
                            airport.id,
                            limit: limit,
                            offset: offset,
                          ),
                          onEntryTap: (entry) => LogbookEntryDialogs.show(
                            context,
                            entry: entry,
                            useCases: logbookUseCases,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createAirport() async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    final placeholder = Airport(
      id: kPlaceholderId,
      icao: '',
      iata: null,
      name: null,
      city: null,
      country: null,
      latitude: 0,
      longitude: 0,
      isFavorite: false,
      isLocked: false,
    );

    if (isCompact) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AirportEditScreen(item: placeholder, isCreate: true),
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
            child: AirportEditScreen(item: placeholder, isCreate: true),
          ),
        );
      },
    );
  }

  Future<void> _editAirport(AirportRow row) async {
    final isCompact = MediaQuery.of(context).size.width < 600;

    if (isCompact) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AirportEditScreen(item: row.airport)),
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
        return 'Search ICAO';
      case AirportSearchField.iata:
        return 'Search IATA';
      case AirportSearchField.icaoOrIata:
        return 'Search ICAO/IATA';
      case AirportSearchField.name:
        return 'Search Name';
      case AirportSearchField.city:
        return 'Search City';
      case AirportSearchField.country:
        return 'Search Country';
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

class _AirportHeader extends StatelessWidget {
  const _AirportHeader({required this.airport, required this.onOpenMap});

  final Airport airport;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (airport.name != null && airport.name!.trim().isNotEmpty)
        airport.name!,
      if (airport.city != null && airport.city!.trim().isNotEmpty)
        airport.city!,
      if (airport.country != null && airport.country!.trim().isNotEmpty)
        airport.country!,
    ].join(' • ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          airport.displayCode,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (subtitle.isNotEmpty)
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        TextButton.icon(
          onPressed: (airport.latitude == 0 && airport.longitude == 0)
              ? null
              : onOpenMap,
          icon: const Icon(Icons.map_outlined, size: 16),
          label: Text(
            '${_formatLat(airport.latitude)} ${_formatLon(airport.longitude)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

Future<void> _showAirportExpandedMapDialog(
  BuildContext context,
  LatLng center,
) async {
  final controller = MapController();
  await showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      child: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          children: [
            ListTile(
              title: const Text('Map'),
              trailing: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: controller,
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: 11,
                      interactionOptions: const InteractionOptions(
                        flags:
                            InteractiveFlag.drag |
                            InteractiveFlag.pinchZoom |
                            InteractiveFlag.doubleTapZoom |
                            InteractiveFlag.scrollWheelZoom,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'simplelog',
                        tileProvider: NetworkTileProvider(
                          cachingProvider: appMapCachingProvider(),
                        ),
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: center,
                            width: 36,
                            height: 36,
                            child: Icon(
                              Icons.location_on,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Column(
                      children: [
                        _MapZoomButton(
                          icon: Icons.add,
                          onPressed: () {
                            final zoom = controller.camera.zoom + 1;
                            controller.move(controller.camera.center, zoom);
                          },
                        ),
                        const SizedBox(height: 8),
                        _MapZoomButton(
                          icon: Icons.remove,
                          onPressed: () {
                            final zoom = controller.camera.zoom - 1;
                            controller.move(controller.camera.center, zoom);
                          },
                        ),
                      ],
                    ),
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

class _MapZoomButton extends StatelessWidget {
  const _MapZoomButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      shape: const CircleBorder(),
      child: IconButton(icon: Icon(icon), onPressed: onPressed),
    );
  }
}

String _formatLat(double value) => _formatDms(value, isLat: true);

String _formatLon(double value) => _formatDms(value, isLat: false);

String _formatDms(double value, {required bool isLat}) {
  final abs = value.abs();
  final degrees = abs.floor();
  final minutesFull = (abs - degrees) * 60;
  final minutes = minutesFull.floor();
  final seconds = ((minutesFull - minutes) * 60).round();
  final direction = isLat ? (value >= 0 ? 'N' : 'S') : (value >= 0 ? 'E' : 'W');
  final degSymbol = '\u00B0';
  final minSymbol = '\u2032';
  final secSymbol = '\u2033';
  final degText = degrees.toString().padLeft(isLat ? 2 : 3, '0');
  final minText = minutes.toString().padLeft(2, '0');
  final secText = seconds.toString().padLeft(2, '0');
  return '$direction$degText$degSymbol$minText$minSymbol$secText$secSymbol';
}
