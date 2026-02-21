import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/state/providers/simulator_default_crew_position_provider.dart';

class SimulatorDefaultPositionSelector extends ConsumerWidget {
  const SimulatorDefaultPositionSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(simulatorDefaultCrewPositionProvider);
    return selected.when(
      data: (value) => DropdownButtonFormField<CrewPosition>(
        initialValue: value,
        decoration: const InputDecoration(
          labelText: 'Default self crew position',
          border: OutlineInputBorder(),
        ),
        items: _positions
            .map(
              (position) => DropdownMenuItem<CrewPosition>(
                value: position,
                child: Text(_labelFor(position)),
              ),
            )
            .toList(growable: false),
        onChanged: (position) async {
          if (position == null) return;
          await ref
              .read(simulatorDefaultCrewPositionProvider.notifier)
              .setPosition(position);
        },
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const Text('Unable to load default position'),
    );
  }

  static const List<CrewPosition> _positions = [
    CrewPosition.pic,
    CrewPosition.sic,
  ];

  static String _labelFor(CrewPosition value) {
    switch (value) {
      case CrewPosition.pic:
        return 'PIC';
      case CrewPosition.sic:
        return 'SIC';
      case CrewPosition.instructor:
        return 'Instructor';
      case CrewPosition.observer:
        return 'Observer';
      case CrewPosition.relief:
        return 'Relief';
      case CrewPosition.reliefCaptain:
        return 'Relief Captain';
      case CrewPosition.reliefFirstOfficer:
        return 'Relief First Officer';
      case CrewPosition.cabinSenior:
        return 'Cabin Senior';
      case CrewPosition.cabinCrew:
        return 'Cabin Crew';
      case CrewPosition.other:
        return 'Other';
      case CrewPosition.unknown:
        return 'Unknown';
    }
  }
}
