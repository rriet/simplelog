import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/crew_row.dart';
import 'package:simplelog/features/crew/application/providers/crew_feature_providers.dart';
import 'package:simplelog/presentation/shared/widgets/entity_picker_dialog.dart';

/// Public API documentation.
class CrewPickerDialog extends StatelessWidget {
  /// Public API documentation.
  const CrewPickerDialog({
    required this.title,
    super.key,
  /// Public API documentation.
  });

  /// Public API documentation.
  final String title;

  /// Public API documentation.
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
    final l10n = AppLocalizations.of(context)!;
    return EntityPickerDialog<CrewRow>(
      title: title,
      searchLabel: l10n.searchCrew,
      itemsBuilder: (ref, query) => ref.watch(crewProvider(query)),
      itemKey: (row) => row.id,
      itemTitle: (row) => row.name,
      itemSubtitle: (row) => [
        if ((row.crew.phone ?? '').trim().isNotEmpty) row.crew.phone!,
        if ((row.crew.email ?? '').trim().isNotEmpty) row.crew.email!,
      ].join(' • '),
      isFavorite: (row) => row.crew.isFavorite,
      onToggleFavorite: (ref, row) async {
        await ref
            .read(crewControllerProvider.notifier)
            .toggleFavorite(row.crew);
      },
      emptyText: l10n.crewEmptyResults,
      errorBuilder: (_, _) => Center(child: Text(l10n.crewLoadError)),
    );
  }
}
