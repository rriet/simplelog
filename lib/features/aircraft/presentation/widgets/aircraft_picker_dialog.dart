import 'package:flutter/material.dart';
import 'package:simplelog/data/models/aircraft_row.dart';
import 'package:simplelog/features/aircraft/application/providers/aircraft_feature_providers.dart';
import 'package:simplelog/presentation/shared/widgets/entity_picker_dialog.dart';

class AircraftPickerDialog extends StatelessWidget {
  const AircraftPickerDialog({
    super.key,
    required this.title,
    this.onlySimulators = false,
  });

  final String title;
  final bool onlySimulators;

  static Future<AircraftRow?> show(
    BuildContext context, {
    required String title,
    bool onlySimulators = false,
  }) {
    return showDialog<AircraftRow>(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(
          width: 640,
          height: 700,
          child: AircraftPickerDialog(
            title: title,
            onlySimulators: onlySimulators,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EntityPickerDialog<AircraftRow>(
      title: title,
      searchLabel: 'Search aircraft',
      itemsBuilder: (ref, query) => ref.watch(aircraftProvider(query)),
      itemFilter: (row) => onlySimulators
          ? row.aircraft.isSimulator
          : !row.aircraft.isSimulator,
      itemKey: (row) => row.id,
      itemTitle: (row) => row.registration,
      itemSubtitle: (row) => row.type?.code ?? row.type?.longName ?? '-',
      itemTrailingBuilder: (_, row) => Icon(
        row.aircraft.isSimulator
            ? Icons.videogame_asset_outlined
            : Icons.airplanemode_active_outlined,
        size: 18,
      ),
      isFavorite: (row) => row.aircraft.isFavorite,
      onToggleFavorite: (ref, row) async {
        await ref.read(aircraftControllerProvider.notifier).toggleFavorite(
              row.aircraft,
            );
      },
      emptyText: 'No aircraft found',
    );
  }
}
