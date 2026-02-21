import 'package:flutter/material.dart';
import 'package:simplelog/data/models/crew_row.dart';
import 'package:simplelog/features/crew/application/providers/crew_feature_providers.dart';
import 'package:simplelog/presentation/shared/widgets/entity_picker_dialog.dart';

class CrewPickerDialog extends StatelessWidget {
  const CrewPickerDialog({
    super.key,
    required this.title,
  });

  final String title;

  static Future<CrewRow?> show(
    BuildContext context, {
    required String title,
  }) {
    return showDialog<CrewRow>(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(
          width: 640,
          height: 700,
          child: CrewPickerDialog(title: title),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EntityPickerDialog<CrewRow>(
      title: title,
      searchLabel: 'Search crew',
      itemsBuilder: (ref, query) => ref.watch(crewProvider(query)),
      itemKey: (row) => row.id,
      itemTitle: (row) => row.name,
      itemSubtitle: (row) => [
        if ((row.crew.phone ?? '').trim().isNotEmpty) row.crew.phone!,
        if ((row.crew.email ?? '').trim().isNotEmpty) row.crew.email!,
      ].join(' • '),
      isFavorite: (row) => row.crew.isFavorite,
      onToggleFavorite: (ref, row) async {
        await ref.read(crewControllerProvider.notifier).toggleFavorite(row.crew);
      },
      emptyText: 'No crew found',
      errorBuilder: (_, _) => const Center(child: Text('Error loading crew')),
    );
  }
}
