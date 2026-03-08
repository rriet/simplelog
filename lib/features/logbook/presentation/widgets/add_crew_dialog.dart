import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/features/crew/presentation/widgets/crew_picker_dialog.dart';
import 'package:simplelog/presentation/shared/widgets/adaptive_form_shell.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/dropdown_input_field.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/picker_with_add_input_field.dart';

/// Result payload returned by add-crew dialog.
class CrewDraftSelection {
  /// Creates a crew draft selection.
  const CrewDraftSelection({required this.crewId, required this.position});

  /// Selected crew id.
  final int crewId;

  /// Selected crew position.
  final CrewPosition position;
}

/// Positions available when adding a crew member to an entry.
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
  CrewPosition.cabinSenior,
  CrewPosition.cabinCrew,
  CrewPosition.other,
];

/// Localized label for a [CrewPosition] value.
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
      return l10n.crewPositionOther;
    case CrewPosition.unknown:
      return l10n.crewPositionUnknown;
  }
}

/// Shows dialog to pick crew member and position for a logbook entry.
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
    builder: (dialogContext) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: StatefulBuilder(
          builder: (context, setLocalState) => AdaptiveFormShell(
            onClose: () => Navigator.of(dialogContext).pop(),
            longTitle: l10n.addCrewTitle,
            shortTitle: l10n.addCrewTitle,
            fullScreen: false,
            actions: [
              TextButton(
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
            contentView: Padding(
              padding: const EdgeInsets.all(16),
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
          ),
        ),
      ),
    ),
  );
}
