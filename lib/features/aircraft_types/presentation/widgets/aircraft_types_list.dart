import 'package:flutter/material.dart';
import 'package:simplelog/data/models/aircraft_type_row.dart';

import 'package:simplelog/features/aircraft_types/presentation/widgets/family_group.dart';
import 'package:simplelog/features/aircraft_types/presentation/widgets/family_section.dart';

/// Scrollable list of aircraft types grouped by family.
class AircraftTypesList extends StatelessWidget {
  /// Creates a list from [groups] with callbacks for type actions.
  const AircraftTypesList({
    required this.groups,
    required this.isCompact,
    required this.onToggleLock,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenDetails,
    required this.onOpenFamilyDetails,
    super.key,
  });

  /// Families and their associated aircraft types.
  final List<FamilyGroup> groups;

  /// Whether to render a more compact layout.
  final bool isCompact;

  /// Called when lock is toggled for a specific type.
  final ValueChanged<AircraftTypeRow> onToggleLock;

  /// Called when the user chooses to edit a type.
  final ValueChanged<AircraftTypeRow> onEdit;

  /// Called when the user chooses to delete a type.
  final ValueChanged<AircraftTypeRow> onDelete;

  /// Opens detailed info for a specific type.
  final ValueChanged<AircraftTypeRow> onOpenDetails;

  /// Opens detailed info for an entire family.
  final ValueChanged<FamilyGroup> onOpenFamilyDetails;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return FamilySection(
          group: group,
          isCompact: isCompact,
          onToggleLock: onToggleLock,
          onEdit: onEdit,
          onDelete: onDelete,
          onOpenDetails: onOpenDetails,
          onOpenFamilyDetails: onOpenFamilyDetails,
        );
      },
    );
  }
}
