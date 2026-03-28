import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/maps/map_tile_caching.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/dialog_adaptive_presenter.dart'
    show isCompactDialogScreen;
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/airport_extensions.dart';
import 'package:simplelog/domain/usecases/logbook_use_cases.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entries_lazy_panel.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entry_dialogs.dart';

/// Shows airport details dialog used by airport and logbook flows.
Future<void> showAirportDetailsDialog(
  BuildContext context, {
  required Airport airport,
  required LogbookUseCases logbookUseCases,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final navigator = Navigator.of(context, rootNavigator: true);
  Future<void> present(WidgetBuilder builder) async {
    if (isCompactDialogScreen(context)) {
      await navigator.push(MaterialPageRoute<void>(builder: builder));
      return;
    }
    await showDialog<void>(context: context, builder: builder);
  }

  await present(
    (dialogContext) {
      final content = Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _AirportHeader(
              airport: airport,
              onOpenMap: () => _showAirportExpandedMapDialog(
                dialogContext,
                LatLng(airport.latitude, airport.longitude),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.screenLogbook,
                style: Theme.of(dialogContext).textTheme.titleSmall,
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
                summaryLoader: () =>
                    logbookUseCases.fetchFlightSummaryForAirport(airport.id),
                onEntryTap: (entry) => LogbookEntryDialogs.show(
                  context,
                  entry: entry,
                  useCases: logbookUseCases,
                ),
              ),
            ),
          ],
        ),
      );
      final contentView = isCompactDialogScreen(dialogContext)
          ? content
          : SizedBox(
              height: MediaQuery.of(dialogContext).size.height * 0.75,
              child: content,
            );
      return AdaptiveFormShell(
        onClose: () => AppNavigator.pop(dialogContext),
        title: l10n.screenAirports,
        popupMaxWidth: 480,
        contentView: contentView,
      );
    },
  );
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
  final l10n = AppLocalizations.of(context)!;
  final controller = MapController();
  await showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      child: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          children: [
            _buildDialogHeaderTile(
              title: l10n.mapTitle,
              buttonLabel: l10n.okAction,
              onPressed: () => AppNavigator.pop(context),
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

Widget _buildDialogHeaderTile({
  required String title,
  required String buttonLabel,
  required VoidCallback onPressed,
}) {
  return ListTile(
    title: Text(title),
    trailing: TextButton(
      onPressed: onPressed,
      child: Text(buttonLabel),
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
  const degSymbol = '\u00B0';
  const minSymbol = '\u2032';
  const secSymbol = '\u2033';
  final degText = degrees.toString().padLeft(isLat ? 2 : 3, '0');
  final minText = minutes.toString().padLeft(2, '0');
  final secText = seconds.toString().padLeft(2, '0');
  return '$direction$degText$degSymbol$minText$minSymbol$secText$secSymbol';
}
