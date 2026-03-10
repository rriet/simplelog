import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/crew_row.dart';
import 'package:simplelog/features/crew/application/providers/crew_feature_providers.dart';
import 'package:simplelog/presentation/shared/widgets/adaptive_form_shell.dart';
import 'package:simplelog/presentation/shared/widgets/dialog_adaptive_presenter.dart';
import 'package:simplelog/presentation/shared/widgets/entity_picker_dialog.dart';

/// Dialog used to search and select a crew member.
class CrewPickerDialog extends StatelessWidget {
  /// Creates a crew picker dialog with the provided [title].
  const CrewPickerDialog({
    required this.title,
    super.key,
  });

  /// Dialog title shown in the header.
  final String title;

  /// Opens the picker as a modal dialog and returns the selected crew row.
  static Future<CrewRow?> show(
    BuildContext context, {
    required String title,
  }) {
    return showLargeDialogScreen<CrewRow>(
      context: context,
      maxWidth: 640,
      builder: (_) => CrewPickerDialog(title: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AdaptiveFormShell(
      onClose: () => Navigator.of(context).pop(),
      longTitle: title,
      shortTitle: title,
      contentView: EntityPickerDialog<CrewRow>(
        title: title,
        showHeader: false,
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
      ),
    );
  }
}
