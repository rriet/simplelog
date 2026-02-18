import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/domain/usecases/logbook_use_cases.dart';

class LogbookEntryDialogs {
  const LogbookEntryDialogs._();

  static Future<void> show(
    BuildContext context, {
    required LogbookEntry entry,
    required LogbookUseCases useCases,
  }) async {
    switch (entry.type) {
      case LogbookEventType.flight:
        await _showFlightInfo(context, entry, useCases);
        return;
      case LogbookEventType.simulatorTraining:
        await _showSimulatorInfo(context, entry, useCases);
        return;
      case LogbookEventType.positioning:
        await _showPositioningInfo(context, entry);
        return;
      case LogbookEventType.dutyPeriod:
      case LogbookEventType.unknown:
        await _showGenericInfo(context, entry);
        return;
    }
  }

  static Future<void> _showGenericInfo(
    BuildContext context,
    LogbookEntry entry,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final date = entry.timeLine.eventDateTime;
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat('dd/MMM yyyy', locale).format(date);
    final timeLabel = DateFormat('HH:mm', locale).format(date);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Event Info',
                        style: Theme.of(dialogContext).textTheme.titleSmall,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Done'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${_eventLabel(l10n, entry)}\n$dateLabel $timeLabel'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> _showPositioningInfo(
    BuildContext context,
    LogbookEntry entry,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final date = entry.timeLine.eventDateTime;
    final pos = entry.positioning;
    final depDateTime = date;
    final arrDateTime = pos?.arrivalDateTime;
    final depCode = entry.positioningDepartureAirport?.icao ?? '-';
    final arrCode = entry.positioningArrivalAirport?.icao ?? '-';
    final depTime = _formatTime(depDateTime, null);
    final arrTime = _formatTime(arrDateTime, null);
    final totalTime = _formatMinutes(pos?.timeTotalMinutes ?? 0);
    final notes = (pos?.notes ?? '').trim();
    final dateLabel = DateFormat('dd/MMM/yyyy', locale).format(depDateTime);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colorScheme = theme.colorScheme;
        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.airplane_ticket_outlined,
                          size: 12,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.logbookEventPositioning,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _PositioningInfoCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: _PositioningInfoValue(
                            label: 'Date',
                            value: dateLabel,
                          ),
                        ),
                        Expanded(
                          child: _PositioningInfoValue(
                            label: 'Total',
                            value: '${totalTime}h',
                            alignEnd: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _PositioningInfoCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _PositioningInfoValue(
                                label: 'From',
                                value: depCode,
                              ),
                            ),
                            Text(
                              '→',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                            Expanded(
                              child: _PositioningInfoValue(
                                label: 'To',
                                value: arrCode,
                                alignEnd: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _PositioningInfoValue(
                                label: 'Departure',
                                value: depTime,
                              ),
                            ),
                            Expanded(
                              child: _PositioningInfoValue(
                                label: 'Arrival',
                                value: arrTime,
                                alignEnd: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _PositioningInfoCard(
                      child: _PositioningInfoValue(
                        label: 'Notes',
                        value: notes,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> _showFlightInfo(
    BuildContext context,
    LogbookEntry entry,
    LogbookUseCases useCases,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final flight = entry.flight!;

    final crewList = await useCases.fetchFlightCrewLabels(flight.id);

    final date = entry.timeLine.eventDateTime;
    final dateLabel = DateFormat('dd/MMM yyyy', locale).format(date);
    final depTime = _formatTime(entry.flight?.takeOffDateTime, date);
    final arrTime = _formatTime(entry.flight?.arrivalDateTime, null);

    final typeName = entry.aircraftType?.longName ??
        entry.aircraftType?.code ??
        '-';
    final tail = entry.aircraft?.registration ?? '-';
    final dep = entry.departureAirport?.icao ?? '-';
    final arr = entry.arrivalAirport?.icao ?? '-';
    final remarks = flight.remarks.trim();
    final notes = flight.notes.trim();
    final hasCrew = crewList.isNotEmpty;
    final takeOffs = flight.takeOffsDays + flight.takeOffsNight;
    final landings = flight.landingsDay + flight.landingsNight;
    final pfpm = _pilotFunctionLabel(
      takeOffs: takeOffs,
      landings: landings,
    );
    final timeMetrics = <(String, int)>[
      ('CrossCountry', flight.timeCrossCountryMinutes),
      ('PIC', flight.timePICMinutes),
      ('SIC', flight.timeSICMinutes),
      ('Dual', flight.timeDualMinutes),
      ('Instructor', flight.timeInstructorMinutes),
      ('IFR', flight.timeIFRMinutes),
      ('Night', flight.timeNightMinutes),
    ].where((item) => item.$2 > 0).toList();

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colorScheme = theme.colorScheme;
        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620, maxHeight: 760),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.flight_takeoff,
                          size: 12,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.logbookEventFlight,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _PositioningInfoCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _PositioningInfoValue(
                                label: 'Date',
                                value: dateLabel,
                              ),
                            ),
                            Expanded(
                              child: _PositioningInfoValue(
                                label: 'Aircraft',
                                value: typeName,
                                alignEnd: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _PositioningInfoValue(
                                label: 'Tail',
                                value: tail,
                              ),
                            ),
                            Expanded(
                              child: _PositioningInfoValue(
                                label: 'Block',
                                value: '${_formatMinutes(flight.timeBlockMinutes)}h',
                                alignEnd: true,
                              ),
                            ),
                          ],
                        ),
                        if (pfpm != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _PositioningInfoValue(
                                  label: 'Function',
                                  value: pfpm,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _PositioningInfoCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _PositioningInfoValue(
                                label: 'From',
                                value: dep,
                              ),
                            ),
                            Text(
                              '→',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                            Expanded(
                              child: _PositioningInfoValue(
                                label: 'To',
                                value: arr,
                                alignEnd: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _PositioningInfoValue(
                                label: 'Departure',
                                value: depTime,
                              ),
                            ),
                            Expanded(
                              child: _PositioningInfoValue(
                                label: 'Arrival',
                                value: arrTime,
                                alignEnd: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (timeMetrics.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _PositioningInfoCard(
                      child: Wrap(
                        spacing: 14,
                        runSpacing: 8,
                        children: timeMetrics
                            .map(
                              (item) => _MetricPill(
                                label: item.$1,
                                value: '${_formatMinutes(item.$2)}h',
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                  if (hasCrew) ...[
                    const SizedBox(height: 10),
                    _PositioningInfoCard(
                      child: _CrewInfoList(
                        title: 'Crew',
                        crewList: crewList,
                        titleStyle: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                  if (remarks.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _PositioningInfoCard(
                      child: _PositioningInfoValue(
                        label: 'Remarks',
                        value: remarks,
                      ),
                    ),
                  ],
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _PositioningInfoCard(
                      child: _PositioningInfoValue(
                        label: 'Notes',
                        value: notes,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> _showSimulatorInfo(
    BuildContext context,
    LogbookEntry entry,
    LogbookUseCases useCases,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final sim = entry.simulatorTraining!;

    final crewList = await useCases.fetchSimulatorCrewLabels(sim.id);

    final date = entry.timeLine.eventDateTime;
    final dateLabel = DateFormat('dd/MMM yyyy', locale).format(date);
    final typeName = entry.aircraftType?.longName ??
        entry.aircraftType?.code ??
        '-';
    final tail = entry.aircraft?.registration ?? '-';
    final remarks = sim.remarks.trim();
    final notes = sim.notes.trim();
    final hasCrew = crewList.isNotEmpty;

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colorScheme = theme.colorScheme;
        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.monitor,
                          size: 12,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.logbookEventSimulator,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _PositioningInfoCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: _PositioningInfoValue(
                            label: 'Date',
                            value: dateLabel,
                          ),
                        ),
                        Expanded(
                          child: _PositioningInfoValue(
                            label: 'Session',
                            value: '${_formatMinutes(sim.timeTotal)}h',
                            alignEnd: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _PositioningInfoCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: _PositioningInfoValue(
                            label: 'Aircraft',
                            value: typeName,
                          ),
                        ),
                        Expanded(
                          child: _PositioningInfoValue(
                            label: 'Tail',
                            value: tail,
                            alignEnd: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasCrew) ...[
                    const SizedBox(height: 10),
                    _PositioningInfoCard(
                      child: _CrewInfoList(
                        title: 'Crew',
                        crewList: crewList,
                        titleStyle: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                  if (remarks.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _PositioningInfoCard(
                      child: _PositioningInfoValue(
                        label: 'Remarks',
                        value: remarks,
                      ),
                    ),
                  ],
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _PositioningInfoCard(
                      child: _PositioningInfoValue(
                        label: 'Notes',
                        value: notes,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PositioningInfoCard extends StatelessWidget {
  const _PositioningInfoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _PositioningInfoValue extends StatelessWidget {
  const _PositioningInfoValue({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: theme.textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(
        '$label: $value',
        style: theme.textTheme.bodySmall,
      ),
    );
  }
}

class _CrewInfoList extends StatefulWidget {
  const _CrewInfoList({
    required this.title,
    required this.crewList,
    required this.titleStyle,
  });

  final String title;
  final List<String> crewList;
  final TextStyle? titleStyle;

  @override
  State<_CrewInfoList> createState() => _CrewInfoListState();
}

class _CrewInfoListState extends State<_CrewInfoList> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: widget.titleStyle),
        const SizedBox(height: 6),
        SizedBox(
          height: 140,
          child: Scrollbar(
            controller: _controller,
            thumbVisibility: widget.crewList.length > 4,
            child: ListView.builder(
              controller: _controller,
              primary: false,
              itemCount: widget.crewList.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(widget.crewList[index]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _formatMinutes(int minutes) {
  if (minutes <= 0) return '0:00';
  final hours = minutes ~/ 60;
  final mins = minutes % 60;
  return '$hours:${mins.toString().padLeft(2, '0')}';
}

String _formatTime(DateTime? explicit, DateTime? fallback) {
  final value = explicit ?? fallback;
  if (value == null) return '--:--';
  if (value.hour == 0 && value.minute == 0) return '--:--';
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _eventLabel(AppLocalizations l10n, LogbookEntry entry) {
  switch (entry.type) {
    case LogbookEventType.flight:
      return l10n.logbookEventFlight;
    case LogbookEventType.simulatorTraining:
      return l10n.logbookEventSimulator;
    case LogbookEventType.positioning:
      return l10n.logbookEventPositioning;
    case LogbookEventType.dutyPeriod:
      return l10n.logbookEventDuty;
    case LogbookEventType.unknown:
      return l10n.logbookEventUnknown;
  }
}

String? _pilotFunctionLabel({
  required int takeOffs,
  required int landings,
}) {
  if (takeOffs > 0 && landings > 0) return 'PF';
  if (takeOffs == 0 && landings == 0) return 'PM';
  if (takeOffs > 0 && landings == 0) return 'PF/PM';
  if (takeOffs == 0 && landings > 0) return 'PM/PF';
  return 'PM';
}
