import 'package:flutter/material.dart';
import 'package:simplelog/data/models/aircraft_type_row.dart';

import 'family_group.dart';
import 'aircraft_type_row.dart';

class FamilySection extends StatelessWidget {
  const FamilySection({
    super.key,
    required this.group,
    required this.isCompact,
    required this.onToggleLock,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenDetails,
    required this.onOpenFamilyDetails,
  });

  final FamilyGroup group;
  final bool isCompact;
  final ValueChanged<AircraftTypeRow> onToggleLock;
  final ValueChanged<AircraftTypeRow> onEdit;
  final ValueChanged<AircraftTypeRow> onDelete;
  final ValueChanged<AircraftTypeRow> onOpenDetails;
  final ValueChanged<FamilyGroup> onOpenFamilyDetails;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => onOpenFamilyDetails(group),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
            child: Text(
              'Family: ${group.family}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ),
        Card(
          elevation: 2,
          shadowColor:
              Theme.of(context).colorScheme.shadow.withValues(alpha: 0.15),
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (var i = 0; i < group.rows.length; i++) ...[
                AircraftTypeRowTile(
                  row: group.rows[i],
                  isCompact: isCompact,
                  onToggleLock: onToggleLock,
                  onEdit: onEdit,
                  onDelete: onDelete,
                  onOpenDetails: onOpenDetails,
                ),
                if (i != group.rows.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
