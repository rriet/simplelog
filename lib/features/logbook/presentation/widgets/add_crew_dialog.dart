import 'package:flutter/material.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/features/crew/presentation/widgets/crew_picker_dialog.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/dropdown_input_field.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/picker_with_add_input_field.dart';

class CrewDraftSelection {
  const CrewDraftSelection({required this.crewId, required this.position});

  final int crewId;
  final CrewPosition position;
}

const List<CrewPosition> addCrewPositionOptions = [
  CrewPosition.pic,
  CrewPosition.sic,
  CrewPosition.instructor,
  CrewPosition.observer,
  CrewPosition.relief,
  CrewPosition.reliefCaptain,
  CrewPosition.reliefFirstOfficer,
  CrewPosition.cabinSenior,
  CrewPosition.cabinCrew,
  CrewPosition.other,
];

String crewPositionLabel(CrewPosition value) {
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

Future<CrewDraftSelection?> showAddCrewDialog({
  required BuildContext context,
  required String Function(int? crewId) crewLabel,
  Future<int?> Function()? onCreateCrew,
  int? initialCrewId,
  CrewPosition initialPosition = CrewPosition.other,
}) async {
  var selectedCrewId = initialCrewId;
  var selectedPosition = initialPosition;

  return showDialog<CrewDraftSelection>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setLocalState) => AlertDialog(
        title: const Text('Add Crew'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PickerWithAddInputField(
                label: 'Crew',
                valueText: crewLabel(selectedCrewId),
                onTap: () async {
                  final selected = await CrewPickerDialog.show(
                    dialogContext,
                    title: 'Select crew',
                  );
                  if (selected == null) return;
                  setLocalState(() => selectedCrewId = selected.id);
                },
                onAdd: onCreateCrew == null
                    ? null
                    : () async {
                        final createdId = await onCreateCrew();
                        if (createdId == null) return;
                        setLocalState(() => selectedCrewId = createdId);
                      },
                addTooltip: 'Create crew',
              ),
              const SizedBox(height: 12),
              DropdownInputField<CrewPosition>(
                label: 'Position',
                value: selectedPosition,
                items: addCrewPositionOptions
                    .map(
                      (position) => DropdownMenuItem<CrewPosition>(
                        value: position,
                        child: Text(crewPositionLabel(position)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) return;
                  setLocalState(() => selectedPosition = value);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: selectedCrewId == null
                ? null
                : () => Navigator.of(dialogContext).pop(
                    CrewDraftSelection(
                      crewId: selectedCrewId!,
                      position: selectedPosition,
                    ),
                  ),
            child: const Text('Add'),
          ),
        ],
      ),
    ),
  );
}
