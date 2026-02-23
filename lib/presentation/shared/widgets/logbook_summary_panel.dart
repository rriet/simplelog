import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/logbook_flight_summary.dart';

/// Summary card showing first/last flight and key time totals.
class LogbookSummaryPanel extends StatelessWidget {
  /// Creates the summary panel.
  const LogbookSummaryPanel({
    required this.summary,
    super.key,
  });

  /// Source summary data displayed in the panel.
  final LogbookFlightSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryItem(
                    label: l10n.summaryFirstFlight,
                    value: summary.firstFlight == null
                        ? l10n.notAvailableShort
                        : dateFormat.format(summary.firstFlight!),
                    alignRight: false,
                  ),
                  const SizedBox(height: 6),
                  _SummaryItem(
                    label: l10n.summaryLastFlight,
                    value: summary.lastFlight == null
                        ? l10n.notAvailableShort
                        : dateFormat.format(summary.lastFlight!),
                    alignRight: false,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _SummaryItem(
                    label: l10n.summaryTotalTime,
                    value: _formatMinutes(summary.totalBlockMinutes),
                    alignRight: true,
                  ),
                  const SizedBox(height: 6),
                  _SummaryItem(
                    label: l10n.summaryTotalPic,
                    value: _formatMinutes(summary.totalPicMinutes),
                    alignRight: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatMinutes(int minutes) {
    final safe = minutes < 0 ? -minutes : minutes;
    final hours = safe ~/ 60;
    final mins = safe % 60;
    return '$hours:${mins.toString().padLeft(2, '0')}h';
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.alignRight,
  });

  final String label;
  final String value;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
