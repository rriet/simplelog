import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/dialog_adaptive_presenter.dart'
    show isCompactDialogScreen;
import 'package:simplelog/data/models/aircraft_type_row.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/domain/usecases/logbook_use_cases.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entries_lazy_panel.dart';

/// Shows aircraft-type details and related logbook entries.
Future<void> showAircraftTypeDetailsDialog(
  BuildContext context, {
  required AircraftTypeRow row,
  required LogbookUseCases logbookUseCases,
  required ValueChanged<LogbookEntry> onEntryTap,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final navigator = Navigator.of(context, rootNavigator: true);

  Future<void> present(WidgetBuilder builder) async {
    if (isCompactDialogScreen(context)) {
      await navigator.push(MaterialPageRoute<void>(builder: builder));
      return;
    }
    await showDialog<void>(context: context, builder: builder);
  }

  await present(
    (dialogContext) {
      final title = row.type.longName.trim().isEmpty
          ? row.code
          : row.type.longName.trim();
      final content = Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.screenLogbook,
              style: Theme.of(dialogContext).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LogbookEntriesLazyPanel(
                pageLoader: (limit, offset) =>
                    logbookUseCases.fetchEntriesForAircraftTypePage(
                      row.type.id,
                      limit: limit,
                      offset: offset,
                    ),
                summaryLoader: () =>
                    logbookUseCases.fetchFlightSummaryForAircraftType(
                      row.type.id,
                    ),
                onEntryTap: onEntryTap,
              ),
            ),
          ],
        ),
      );
      final contentView = isCompactDialogScreen(dialogContext)
          ? content
          : SizedBox(
              height: MediaQuery.of(dialogContext).size.height * 0.8,
              child: content,
            );
      return AdaptiveFormShell(
        onClose: () => AppNavigator.pop(dialogContext),
        title: title,
        popupMaxWidth: 500,
        contentView: contentView,
      );
    },
  );
}
