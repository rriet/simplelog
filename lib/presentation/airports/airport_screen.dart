import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/airport_filters.dart';
import 'package:simplelog/data/models/airport_row.dart';
import 'package:simplelog/data/models/airport_extensions.dart';
import 'package:simplelog/core/constants/app_constants.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/presentation/logbook/widgets/logbook_entries_year_list.dart';
import 'package:simplelog/presentation/logbook/widgets/logbook_entry_dialogs.dart';
import 'package:simplelog/state/providers/airport_controller_provider.dart';
import 'package:simplelog/state/providers/airport_data_controller_provider.dart';
import 'package:simplelog/state/controllers/validation_result.dart';
import 'package:simplelog/state/providers/airport_repository_provider.dart';
import 'package:simplelog/state/providers/database_provider.dart';
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
  AirportFilters _filters = const AirportFilters();

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
    final updated = await AirportFiltersDialog.show(
      context,
      initial: _filters,
    );
    if (!mounted || updated == null) return;
    setState(() => _filters = updated);
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
        content: Text(
          l10n.confirmDeleteAirport(row.icao),
        ),
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
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.validationErrorTitle),
        content: Text(validation.message ?? l10n.validationErrorGeneric),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.okAction),
          ),
        ],
      ),
    );
  }

  Future<void> _showAirportDetails(AirportRow row) async {
    final l10n = AppLocalizations.of(context)!;
    final airport = row.airport;
    final entriesFuture = _loadAirportLogEntries(airport.id);
    final db = ref.read(databaseProvider);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Airport'),
        content: SizedBox(
          width: 480,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              _AirportHeader(airport: airport),
              const SizedBox(height: 8),
              _AirportMap(airport: airport),
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
                child: FutureBuilder<List<LogbookEntry>>(
                  future: entriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final entries = snapshot.data ?? [];
                    if (entries.isEmpty) {
                      return Center(
                        child: Text(l10n.emptyResults),
                      );
                    }
                    return LogbookEntriesYearList(
                      entries: entries,
                      onEntryTap: (entry) => LogbookEntryDialogs.show(
                        context,
                        entry: entry,
                        db: db,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.okAction),
          ),
        ],
      ),
    );
  }

  Future<List<LogbookEntry>> _loadAirportLogEntries(int airportId) async {
    final db = ref.read(databaseProvider);
    final dep = db.alias(db.airports, 'dep');
    final arr = db.alias(db.airports, 'arr');
    final posDep = db.alias(db.airports, 'pos_dep');
    final posArr = db.alias(db.airports, 'pos_arr');

    final flightQuery = db.select(db.flights).join([
      innerJoin(
        db.timeLines,
        db.timeLines.id.equalsExp(db.flights.departureDateTimeId),
      ),
      leftOuterJoin(
        db.aircrafts,
        db.aircrafts.id.equalsExp(db.flights.aircraftId),
      ),
      leftOuterJoin(
        db.aircraftTypes,
        db.aircraftTypes.id.equalsExp(db.aircrafts.aircraftTypeId),
      ),
      leftOuterJoin(
        dep,
        dep.id.equalsExp(db.flights.departureAirportId),
      ),
      leftOuterJoin(
        arr,
        arr.id.equalsExp(db.flights.arrivalAirportId),
      ),
    ])
      ..where(
        db.flights.departureAirportId.equals(airportId) |
            db.flights.arrivalAirportId.equals(airportId),
      );

    final positioningQuery = db.select(db.positionings).join([
      innerJoin(
        db.timeLines,
        db.timeLines.id.equalsExp(db.positionings.departureDateTimeId),
      ),
      leftOuterJoin(
        posDep,
        posDep.id.equalsExp(db.positionings.departurePlaceId),
      ),
      leftOuterJoin(
        posArr,
        posArr.id.equalsExp(db.positionings.arrivalPlaceId),
      ),
    ])
      ..where(
        db.positionings.departurePlaceId.equals(airportId) |
            db.positionings.arrivalPlaceId.equals(airportId),
      );

    final flightRows = await flightQuery.get();
    final positioningRows = await positioningQuery.get();

    final entries = <LogbookEntry>[];

    for (final row in flightRows) {
      entries.add(
        LogbookEntry(
          timeLine: row.readTable(db.timeLines),
          flight: row.readTable(db.flights),
          aircraft: row.readTableOrNull(db.aircrafts),
          aircraftType: row.readTableOrNull(db.aircraftTypes),
          departureAirport: row.readTableOrNull(dep),
          arrivalAirport: row.readTableOrNull(arr),
        ),
      );
    }

    for (final row in positioningRows) {
      entries.add(
        LogbookEntry(
          timeLine: row.readTable(db.timeLines),
          positioning: row.readTable(db.positionings),
          positioningDepartureAirport: row.readTableOrNull(posDep),
          positioningArrivalAirport: row.readTableOrNull(posArr),
        ),
      );
    }

    entries.sort(
      (a, b) => b.timeLine.eventDateTime.compareTo(
        a.timeLine.eventDateTime,
      ),
    );
    return entries;
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
          builder: (_) => AirportEditScreen(
            item: placeholder,
            isCreate: true,
          ),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 520,
          height: 640,
          child: AirportEditScreen(
            item: placeholder,
            isCreate: true,
          ),
        ),
      ),
    );
  }

  Future<void> _editAirport(AirportRow row) async {
    final isCompact = MediaQuery.of(context).size.width < 600;

    if (isCompact) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AirportEditScreen(
            item: row.airport,
          ),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 520,
          height: 640,
          child: AirportEditScreen(
            item: row.airport,
          ),
        ),
      ),
    );
  }

  String _searchLabel(AppLocalizations l10n) {
    switch (_filters.searchField) {
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
    final airports = ref.watch(
      airportsProvider(
        AirportSearchParams(query: _query, filters: _filters),
      ),
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
            error: (error, stackTrace) => Center(
              child: Text(error.toString()),
            ),
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
  const _AirportHeader({required this.airport});

  final Airport airport;

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
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        const SizedBox(height: 6),
        Text(
          '${_formatLat(airport.latitude)} '
          '${_formatLon(airport.longitude)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _AirportMap extends StatelessWidget {
  const _AirportMap({required this.airport});

  final Airport airport;

  @override
  Widget build(BuildContext context) {
    final hasCoords =
        airport.latitude != 0 || airport.longitude != 0;
    final borderRadius = BorderRadius.circular(12);
    if (!hasCoords) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: borderRadius,
        ),
        alignment: Alignment.center,
        child: Text(
          'No map location available',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    final center = LatLng(airport.latitude, airport.longitude);
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        height: 160,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 9,
                interactionOptions:
                    const InteractionOptions(flags: InteractiveFlag.drag),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'simplelog',
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
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showExpandedMap(context, center),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showExpandedMap(
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
              const SizedBox(height: 8),
              Text(
                'Map',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: controller,
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: 11,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.drag |
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
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: center,
                              width: 36,
                              height: 36,
                              child: Icon(
                                Icons.location_on,
                                color:
                                    Theme.of(context).colorScheme.primary,
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
                              controller.move(
                                controller.camera.center,
                                zoom,
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          _MapZoomButton(
                            icon: Icons.remove,
                            onPressed: () {
                              final zoom = controller.camera.zoom - 1;
                              controller.move(
                                controller.camera.center,
                                zoom,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapZoomButton extends StatelessWidget {
  const _MapZoomButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
      ),
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
  final direction = isLat
      ? (value >= 0 ? 'N' : 'S')
      : (value >= 0 ? 'E' : 'W');
  final degSymbol = '\u00B0';
  final minSymbol = '\u2032';
  final secSymbol = '\u2033';
  final degText = degrees.toString().padLeft(isLat ? 2 : 3, '0');
  final minText = minutes.toString().padLeft(2, '0');
  final secText = seconds.toString().padLeft(2, '0');
  return '$direction$degText$degSymbol$minText$minSymbol$secText$secSymbol';
}
