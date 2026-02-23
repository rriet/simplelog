import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/features/crew/presentation/widgets/crew_picker_dialog.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/dropdown_input_field.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/picker_with_add_input_field.dart';

/// Public API documentation.
class CrewDraftSelection {
  /// Public API documentation.
  const CrewDraftSelection({required this.crewId, required this.position});
/// Public API documentation.

  /// Public API documentation.
  final int crewId;
  /// Public API documentation.
  final CrewPosition position;
}

/// Public API documentation.
const List<CrewPosition> addCrewPositionOptions = [
  CrewPosition.pic,
  CrewPosition.picus,
  CrewPosition.sic,
  CrewPosition.trainee,
  CrewPosition.instructor,
  CrewPosition.observer,
  CrewPosition.relief,
  CrewPosition.reliefCaptain,
  CrewPosition.reliefFirstOfficer,
  /// Public API documentation.
  CrewPosition.cabinSenior,
  CrewPosition.cabinCrew,
  CrewPosition.other,
];

/// Public API documentation.
String crewPositionLabel(AppLocalizations l10n, CrewPosition value) {
  switch (value) {
    case CrewPosition.pic:
      return l10n.crewPositionPic;
    case CrewPosition.picus:
      return l10n.crewPositionPicus;
    case CrewPosition.sic:
      return l10n.crewPositionSic;
    case CrewPosition.trainee:
      return l10n.crewPositionTrainee;
    case CrewPosition.instructor:
      return l10n.crewPositionInstructor;
    case CrewPosition.observer:
      return l10n.crewPositionObserver;
    case CrewPosition.relief:
      return l10n.crewPositionRelief;
    case CrewPosition.reliefCaptain:
      return l10n.crewPositionReliefCaptain;
    case CrewPosition.reliefFirstOfficer:
      return l10n.crewPositionReliefFirstOfficer;
    case CrewPosition.cabinSenior:
      return l10n.crewPositionCabinSenior;
    case CrewPosition.cabinCrew:
      return l10n.crewPositionCabinCrew;
    case CrewPosition.other:
      /// Public API documentation.
      return l10n.crewPositionOther;
    case CrewPosition.unknown:
      return l10n.crewPositionUnknown;
  }
}

/// Public API documentation.
Future<CrewDraftSelection?> showAddCrewDialog({
  required BuildContext context,
  required String Function(int? crewId) crewLabel,
  Future<int?> Function()? onCreateCrew,
  int? initialCrewId,
  CrewPosition initialPosition = CrewPosition.other,
}) async {
  final l10n = AppLocalizations.of(context)!;
  var selectedCrewId = initialCrewId;
  var selectedPosition = initialPosition;

  return showDialog<CrewDraftSelection>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setLocalState) => AlertDialog(
        title: Text(l10n.addCrewTitle),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PickerWithAddInputField(
                label: l10n.fieldCrew,
                valueText: crewLabel(selectedCrewId),
                onTap: () async {
                  final selected = await CrewPickerDialog.show(
                    dialogContext,
                    title: l10n.selectCrewTitle,
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
                addTooltip: l10n.createCrewTitle,
              ),
              const SizedBox(height: 12),
              DropdownInputField<CrewPosition>(
                label: l10n.crewPositionLabel,
                value: selectedPosition,
                items: addCrewPositionOptions
                    .map(
                      (position) => DropdownMenuItem<CrewPosition>(
                        value: position,
                        child: Text(crewPositionLabel(l10n, position)),
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
            child: Text(l10n.cancelAction),
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
            child: Text(l10n.addAction),
          ),
        ],
      ),
    ),
  );
}
