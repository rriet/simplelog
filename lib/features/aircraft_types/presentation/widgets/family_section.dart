import 'package:flutter/material.dart';
import 'package:simplelog/data/models/aircraft_type_row.dart';
import 'package:simplelog/features/aircraft_types/presentation/widgets/aircraft_type_row.dart';
import 'package:simplelog/features/aircraft_types/presentation/widgets/family_group.dart';

/// Public API documentation.
class FamilySection extends StatelessWidget {
  /// Public API documentation.
  const FamilySection({
    required this.group,
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
  final FamilyGroup group;
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
          shadowColor: Theme.of(
            context,
          ).colorScheme.shadow.withValues(alpha: 0.15),
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
