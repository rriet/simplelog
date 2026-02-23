import 'package:flutter/material.dart';
import 'package:simplelog/data/models/aircraft_type_row.dart';

import 'package:simplelog/features/aircraft_types/presentation/widgets/family_group.dart';
import 'package:simplelog/features/aircraft_types/presentation/widgets/family_section.dart';

/// Public API documentation.
class AircraftTypesList extends StatelessWidget {
  /// Public API documentation.
  const AircraftTypesList({
    required this.groups,
    required this.isCompact,
    required this.onToggleLock,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenDetails,
    required this.onOpenFamilyDetails,
    super.key,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final List<FamilyGroup> groups;
  /// Public API documentation.
  final bool isCompact;
  /// Public API documentation.
  final ValueChanged<AircraftTypeRow> onToggleLock;
  /// Public API documentation.
  final ValueChanged<AircraftTypeRow> onEdit;
  /// Public API documentation.
  final ValueChanged<AircraftTypeRow> onDelete;
  /// Public API documentation.
  final ValueChanged<AircraftTypeRow> onOpenDetails;
  /// Public API documentation.
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
