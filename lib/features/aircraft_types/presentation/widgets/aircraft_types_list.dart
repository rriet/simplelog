import 'package:flutter/material.dart';
import 'package:simplelog/data/models/aircraft_type_row.dart';

import 'family_group.dart';
import 'family_section.dart';

class AircraftTypesList extends StatelessWidget {
  const AircraftTypesList({
    super.key,
    required this.groups,
    required this.isCompact,
    required this.onToggleLock,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenDetails,
    required this.onOpenFamilyDetails,
  });

  final List<FamilyGroup> groups;
  final bool isCompact;
  final ValueChanged<AircraftTypeRow> onToggleLock;
  final ValueChanged<AircraftTypeRow> onEdit;
  final ValueChanged<AircraftTypeRow> onDelete;
  final ValueChanged<AircraftTypeRow> onOpenDetails;
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
