import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/dialog_adaptive_presenter.dart'
    show isCompactDialogScreen;
import 'package:simplelog/data/models/aircraft_row.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/domain/usecases/logbook_use_cases.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entries_lazy_panel.dart';

/// Shows aircraft details and related logbook entries.
Future<void> showAircraftDetailsDialog(
  BuildContext context, {
  required AircraftRow row,
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
      final content = Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _AircraftHeader(row: row),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.screenLogbook,
                style: Theme.of(dialogContext).textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LogbookEntriesLazyPanel(
                pageLoader: (limit, offset) =>
                    logbookUseCases.fetchEntriesForAircraftPage(
                      row.aircraft.id,
                      limit: limit,
                      offset: offset,
                    ),
                summaryLoader: () =>
                    logbookUseCases.fetchFlightSummaryForAircraft(
                      row.aircraft.id,
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
              height: MediaQuery.of(dialogContext).size.height * 0.75,
              child: content,
            );
      return AdaptiveFormShell(
        onClose: () => AppNavigator.pop(dialogContext),
        title: l10n.screenAircraft,
        popupMaxWidth: 480,
        contentView: contentView,
      );
    },
  );
}

class _AircraftHeader extends StatelessWidget {
  const _AircraftHeader({required this.row});

  final AircraftRow row;

  @override
  Widget build(BuildContext context) {
    final typeLabel = [
      if (row.type?.code != null && row.type!.code.trim().isNotEmpty)
        row.type!.code,
      if (row.type?.longName != null && row.type!.longName.trim().isNotEmpty)
        row.type!.longName,
    ].join(' • ');
    final subtitle = [
      if (typeLabel.isNotEmpty) typeLabel,
      if (row.aircraft.isSimulator)
        AppLocalizations.of(context)!.fieldIsSimulator,
    ].join(' • ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              row.aircraft.isSimulator
                  ? Icons.videogame_asset_outlined
                  : Icons.airplanemode_active_outlined,
              size: 18,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                row.registration,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}
