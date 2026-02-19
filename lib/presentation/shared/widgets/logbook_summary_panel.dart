import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simplelog/data/models/logbook_entry.dart';

class LogbookSummaryPanel extends StatelessWidget {
  const LogbookSummaryPanel({
    super.key,
    required this.entries,
  });

  final List<LogbookEntry> entries;

  @override
  Widget build(BuildContext context) {
    final summary = _LogbookSummary.fromEntries(entries);
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
                    label: 'First Flight',
                    value: summary.firstFlight == null
                        ? '-'
                        : dateFormat.format(summary.firstFlight!),
                    alignRight: false,
                  ),
                  const SizedBox(height: 6),
                  _SummaryItem(
                    label: 'Last Flight',
                    value: summary.lastFlight == null
                        ? '-'
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
                    label: 'Total Time',
                    value: _formatMinutes(summary.totalBlockMinutes),
                    alignRight: true,
                  ),
                  const SizedBox(height: 6),
                  _SummaryItem(
                    label: 'Total PIC',
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
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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

class _LogbookSummary {
  const _LogbookSummary({
    required this.totalBlockMinutes,
    required this.totalPicMinutes,
    required this.firstFlight,
    required this.lastFlight,
  });

  final int totalBlockMinutes;
  final int totalPicMinutes;
  final DateTime? firstFlight;
  final DateTime? lastFlight;

  factory _LogbookSummary.fromEntries(List<LogbookEntry> entries) {
    final flights = entries.where((entry) => entry.flight != null).toList();
    if (flights.isEmpty) {
      return const _LogbookSummary(
        totalBlockMinutes: 0,
        totalPicMinutes: 0,
        firstFlight: null,
        lastFlight: null,
      );
    }

    final totalBlock = flights.fold<int>(
      0,
      (sum, entry) => sum + (entry.flight?.timeBlockMinutes ?? 0),
    );
    final totalPic = flights.fold<int>(
      0,
      (sum, entry) => sum + (entry.flight?.timePICMinutes ?? 0),
    );
    final sorted = [...flights]
      ..sort((a, b) => a.timeLine.eventDateTime.compareTo(b.timeLine.eventDateTime));

    return _LogbookSummary(
      totalBlockMinutes: totalBlock,
      totalPicMinutes: totalPic,
      firstFlight: sorted.first.timeLine.eventDateTime,
      lastFlight: sorted.last.timeLine.eventDateTime,
    );
  }
}
