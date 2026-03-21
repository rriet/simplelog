import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simplelog/core/date/db_date_time.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/presentation/widgets/display/slidable_actions.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/airport_extensions.dart';
import 'package:simplelog/data/models/logbook_entry.dart';

/// Logbook entry tile with optional slide actions.
class LogbookListItem extends StatelessWidget {
  /// Creates a logbook list item.
  const LogbookListItem({
    required this.entry,
    required this.isCompact,
    super.key,
    this.enableSlideActions = true,
    this.onEdit,
    this.onOpen,
    this.onDelete,
    this.onToggleLock,
  });

  /// Entry rendered by this row.
  final LogbookEntry entry;

  /// Whether compact/mobile mode is active.
  final bool isCompact;

  /// Enables slidable actions when true.
  final bool enableSlideActions;

  /// Edit callback.
  final ValueChanged<LogbookEntry>? onEdit;

  /// Open/details callback.
  final ValueChanged<LogbookEntry>? onOpen;

  /// Delete callback.
  final ValueChanged<LogbookEntry>? onDelete;

  /// Lock toggle callback.
  final ValueChanged<LogbookEntry>? onToggleLock;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final l10n = AppLocalizations.of(context)!;
        final date = entry.timeLine.eventDateTime;
        final dateUtc = DbDateTime.dbToUtc(date);
        final locale = MaterialLocalizations.of(context);
        final dateText = locale.formatShortDate(
          DateTime(dateUtc.year, dateUtc.month, dateUtc.day),
        );
        final timeText = locale.formatTimeOfDay(
          TimeOfDay(hour: dateUtc.hour, minute: dateUtc.minute),
        );
        // Avoid right-column overflow in split view before parent breakpoints
        // kick in.
        final effectiveCompact = isCompact || constraints.maxWidth < 760;

        final eventLabel = _eventLabel(l10n, entry);
        final routeLabel = _routeLabel(entry);
        final subtitleParts = [
          eventLabel,
          routeLabel,
        ].whereType<String>().toList(growable: false);

        final isLocked = _isLocked(entry);
        final canLock = _canLock(entry);

        final tile = switch (entry.type) {
          LogbookEventType.flight => _buildFlightTile(
            context,
            l10n,
            date,
            isCompact: effectiveCompact,
          ),
          LogbookEventType.positioning => _buildPositioningTile(
            context,
            date,
            isCompact: effectiveCompact,
          ),
          LogbookEventType.simulatorTraining => _buildSimulatorTile(
            context,
            date,
            isCompact: effectiveCompact,
          ),
          _ => ListTile(
            leading: Icon(_iconFor(entry.type)),
            title: Text('$dateText • $timeText'),
            subtitle: Text(subtitleParts.join(' • ')),
            onTap: onEdit == null ? null : () => onEdit!(entry),
          ),
        };

        if (!enableSlideActions) {
          return tile;
        }

        return SlidableActions(
          isCompact: effectiveCompact,
          isLocked: isLocked,
          lockLabel: l10n.lockAction,
          editLabel: l10n.editAction,
          deleteLabel: l10n.deleteAction,
          onToggleLock: !canLock
              ? null
              : onToggleLock == null
              ? null
              : () => onToggleLock!(entry),
          onEdit: onEdit == null ? null : () => onEdit!(entry),
          onDelete: onDelete == null ? null : () => onDelete!(entry),
          inlineActions: SizedBox(
            width: 144,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canLock)
                  IconButton(
                    tooltip: l10n.lockAction,
                    icon: Icon(
                      isLocked ? Icons.lock : Icons.lock_open,
                      color: isLocked
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: onToggleLock == null
                        ? null
                        : () => onToggleLock!(entry),
                  ),
                if (!isLocked)
                  IconButton(
                    tooltip: l10n.editAction,
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEdit == null ? null : () => onEdit!(entry),
                  ),
                if (!isLocked)
                  IconButton(
                    tooltip: l10n.deleteAction,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete == null ? null : () => onDelete!(entry),
                  ),
              ],
            ),
          ),
          child: tile,
        );
      },
    );
  }

  Widget _buildPositioningTile(
    BuildContext context,
    DateTime date, {
    required bool isCompact,
  }) {
    final utcDate = DbDateTime.dbToUtc(date);
    final positioning = entry.positioning;
    final depCode = entry.positioningDepartureAirport?.icao ?? '-';
    final arrCode = entry.positioningArrivalAirport?.icao ?? '-';
    final duration = positioning?.timeTotalMinutes ?? 0;
    final durationText = '${_formatBlockMinutes(duration)}h';
    final depTime = _formatFlightTime(
      fallback: date,
      explicit: date,
      treatMidnightAsMissing: true,
    );
    final arrDate = positioning?.arrivalDateTime;
    final arrTime = _formatFlightTime(
      fallback: arrDate,
      explicit: arrDate,
      treatMidnightAsMissing: true,
    );
    final dateFormat = DateFormat(
      'MMM',
      Localizations.localeOf(context).toString(),
    );
    final dayText = utcDate.day.toString().padLeft(2, '0');
    final monthText = dateFormat.format(
      DateTime(utcDate.year, utcDate.month, utcDate.day),
    );
    final titleStyle = Theme.of(context).textTheme.titleSmall;
    final boostedTitleStyle = titleStyle?.copyWith(
      fontSize: (titleStyle.fontSize ?? 0) + 1,
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SimpleTopLine(
          icon: Icons.airplane_ticket_outlined,
          label: AppLocalizations.of(context)!.logbookEventPositioning,
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateBlock(day: dayText, month: monthText),
            const SizedBox(width: 10),
            _DateDivider(color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RouteCodesAndDurationRow(
                    depCode: depCode,
                    center: _ScaledText(
                      durationText,
                      style: titleStyle?.copyWith(
                        fontSize: (titleStyle.fontSize ?? 0) + 1,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    arrCode: arrCode,
                    titleStyle: boostedTitleStyle,
                  ),
                  const SizedBox(height: 4),
                  _RouteTimesAndPathRow(
                    depTime: depTime,
                    arrTime: arrTime,
                    icon: Icons.airline_seat_recline_extra_sharp,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );

    return _EventTileShell(
      entry: entry,
      isCompact: isCompact,
      onOpen: onOpen,
      onEdit: onEdit,
      content: content,
    );
  }

  Widget _buildSimulatorTile(
    BuildContext context,
    DateTime date, {
    required bool isCompact,
  }) {
    final utcDate = DbDateTime.dbToUtc(date);
    final simulator = entry.simulatorTraining;
    final totalMinutes = simulator?.timeTotal ?? 0;
    final totalText = '${_formatBlockMinutes(totalMinutes)}h';
    final tailNumber = entry.aircraft?.registration ?? '-';
    final typeLongName =
        entry.aircraftType?.longName ?? entry.aircraftType?.code ?? '-';
    final dateFormat = DateFormat(
      'MMM',
      Localizations.localeOf(context).toString(),
    );
    final dayText = utcDate.day.toString().padLeft(2, '0');
    final monthText = dateFormat.format(
      DateTime(utcDate.year, utcDate.month, utcDate.day),
    );
    final titleStyle = Theme.of(context).textTheme.titleSmall;
    final boostedTitleStyle = titleStyle?.copyWith(
      fontSize: (titleStyle.fontSize ?? 0) + 1,
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FlightTopLine(
          tailNumber: tailNumber,
          typeLongName: typeLongName,
          label: AppLocalizations.of(context)!.fieldIsSimulator,
          icon: Icons.monitor,
          hasEndorsement: _hasEndorsement(
            simulator?.endorsementData,
            simulator?.signatureImage,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _DateBlock(day: dayText, month: monthText),
            const SizedBox(width: 10),
            _DateDivider(color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(width: 10),
            _CenteredExpanded(
              child: _ScaledText(
                'Session Time: $totalText',
                style: boostedTitleStyle?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );

    return _EventTileShell(
      entry: entry,
      isCompact: isCompact,
      onOpen: onOpen,
      onEdit: onEdit,
      content: content,
    );
  }

  Widget _buildFlightTile(
    BuildContext context,
    AppLocalizations l10n,
    DateTime date, {
    required bool isCompact,
  }) {
    final utcDate = DbDateTime.dbToUtc(date);
    final titleStyle = Theme.of(context).textTheme.titleSmall;
    final boostedTitleStyle = titleStyle?.copyWith(
      fontSize: (titleStyle.fontSize ?? 0) + 1,
    );
    final flight = entry.flight;
    final aircraft = entry.aircraft;
    final type = entry.aircraftType;
    final tailNumber = aircraft?.registration ?? '-';
    final typeLongName = type?.longName ?? '-';
    final blockMinutes = flight?.timeBlockMinutes ?? 0;
    final totalBlockMinutes = flight?.timeTotalBlockMinutes ?? blockMinutes;
    final blockTime = '${_formatBlockMinutes(blockMinutes)}h';
    final totalBlockTime = _formatBlockMinutes(totalBlockMinutes);
    final depCode = entry.departureAirport?.icao ?? '-';
    final arrCode = entry.arrivalAirport?.icao ?? '-';

    final dateFormat = DateFormat(
      'MMM',
      Localizations.localeOf(context).toString(),
    );
    final dayText = utcDate.day.toString().padLeft(2, '0');
    final monthText = dateFormat.format(
      DateTime(utcDate.year, utcDate.month, utcDate.day),
    );
    final depTime = _formatFlightTime(
      fallback: date,
      explicit: flight?.takeOffDateTime,
      treatMidnightAsMissing: _isMissingFlightTime(flight),
    );
    final arrTime = _formatFlightTime(
      fallback: flight?.arrivalDateTime,
      explicit: flight?.arrivalDateTime,
      treatMidnightAsMissing: true,
    );

    final rightColumn = _buildFlightRightColumn(context, flight);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FlightTopLine(
          tailNumber: tailNumber,
          typeLongName: typeLongName,
          hasEndorsement: _hasEndorsement(
            flight?.endorsementData,
            flight?.signatureImage,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateBlock(day: dayText, month: monthText),
            const SizedBox(width: 10),
            _DateDivider(color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RouteCodesAndDurationRow(
                    depCode: depCode,
                    center: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontSize: (titleStyle?.fontSize ?? 0) + 1,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        children: [
                          TextSpan(text: blockTime),
                          if (totalBlockMinutes != blockMinutes)
                            TextSpan(
                              text:
                                  ' ($totalBlockTime'
                                  'h)',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    arrCode: arrCode,
                    titleStyle: boostedTitleStyle,
                  ),
                  const SizedBox(height: 4),
                  _RouteTimesAndPathRow(
                    depTime: depTime,
                    arrTime: arrTime,
                    icon: Icons.flight_takeoff,
                  ),
                ],
              ),
            ),
            if (!isCompact) ...[
              const SizedBox(width: 12),
              _DateDivider(color: Theme.of(context).colorScheme.outlineVariant),
              const SizedBox(width: 12),
              SizedBox(width: 170, child: rightColumn),
            ],
          ],
        ),
      ],
    );

    return _EventTileShell(
      entry: entry,
      isCompact: isCompact,
      onOpen: onOpen,
      onEdit: onEdit,
      content: content,
    );
  }

  String _formatBlockMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '$hours:${mins.toString().padLeft(2, '0')}';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildFlightRightColumn(BuildContext context, Flight? flight) {
    final textStyle = Theme.of(context).textTheme.bodySmall;
    final position = _flightPositionLabel(flight);
    final takeOffsDay = flight?.takeOffsDays ?? 0;
    final takeOffsNight = flight?.takeOffsNight ?? 0;
    final landingsDay = flight?.landingsDay ?? 0;
    final landingsNight = flight?.landingsNight ?? 0;
    final totalTakeOffs = takeOffsDay + takeOffsNight;
    final totalLandings = landingsDay + landingsNight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RightLine(
          label: AppLocalizations.of(context)!.crewPositionLabel,
          value: position,
          style: textStyle,
        ),
        _RightLine(
          label: AppLocalizations.of(context)!.reportsOrderByTakeoff,
          value: '$totalTakeOffs',
          style: textStyle,
        ),
        _RightLine(
          label: AppLocalizations.of(context)!.autoUi036,
          value: '$totalLandings',
          style: textStyle,
        ),
      ],
    );
  }

  String _flightPositionLabel(Flight? flight) {
    if (flight == null) return '-';
    if (flight.timePICMinutes > 0) return 'PIC';
    if (flight.timePICUSMinutes > 0) return 'PICUS';
    if (flight.timeSICMinutes > 0) return 'SIC';
    if (flight.timeDualMinutes > 0) return 'Dual';
    if (flight.timeInstructorMinutes > 0) return 'Instructor';
    return '-';
  }

  String _formatFlightTime({
    required DateTime? fallback,
    required DateTime? explicit,
    required bool treatMidnightAsMissing,
  }) {
    final timeSource = explicit ?? fallback;
    if (timeSource == null) return '--:--';
    final utcTime = DbDateTime.dbToUtc(timeSource);
    if (treatMidnightAsMissing && utcTime.hour == 0 && utcTime.minute == 0) {
      return '--:--';
    }
    return _formatTimeOfDay(
      TimeOfDay(hour: utcTime.hour, minute: utcTime.minute),
    );
  }

  bool _isMissingFlightTime(Flight? flight) {
    if (flight == null) return false;
    return flight.takeOffDateTime == null &&
        flight.landingDateTime == null &&
        flight.arrivalDateTime == null;
  }

  String _eventLabel(AppLocalizations l10n, LogbookEntry entry) {
    switch (entry.type) {
      case LogbookEventType.flight:
        return l10n.logbookEventFlight;
      case LogbookEventType.simulatorTraining:
        return l10n.logbookEventSimulator;
      case LogbookEventType.dutyPeriod:
        if (entry.isDutyStart) {
          return l10n.logbookEventDutyStart;
        }
        if (entry.isDutyEnd) {
          return l10n.logbookEventDutyEnd;
        }
        return l10n.logbookEventDuty;
      case LogbookEventType.positioning:
        return l10n.logbookEventPositioning;
      case LogbookEventType.unknown:
        return l10n.logbookEventUnknown;
    }
  }

  String? _routeLabel(LogbookEntry entry) {
    switch (entry.type) {
      case LogbookEventType.flight:
        return _routeText(entry.departureAirport, entry.arrivalAirport);
      case LogbookEventType.positioning:
        return _routeText(
          entry.positioningDepartureAirport,
          entry.positioningArrivalAirport,
        );
      case LogbookEventType.simulatorTraining:
      case LogbookEventType.dutyPeriod:
      case LogbookEventType.unknown:
        return null;
    }
  }

  String? _routeText(Airport? departure, Airport? arrival) {
    if (departure == null || arrival == null) return null;
    final depCode = departure.shortCode;
    final arrCode = arrival.shortCode;
    return '$depCode → $arrCode';
  }

  IconData _iconFor(LogbookEventType type) {
    switch (type) {
      case LogbookEventType.flight:
        return Icons.flight_takeoff;
      case LogbookEventType.simulatorTraining:
        return Icons.monitor;
      case LogbookEventType.dutyPeriod:
        return Icons.access_time;
      case LogbookEventType.positioning:
        return Icons.airplane_ticket_outlined;
      case LogbookEventType.unknown:
        return Icons.event_note;
    }
  }

  bool _canLock(LogbookEntry entry) {
    switch (entry.type) {
      case LogbookEventType.flight:
      case LogbookEventType.simulatorTraining:
      case LogbookEventType.dutyPeriod:
      case LogbookEventType.positioning:
        return true;
      case LogbookEventType.unknown:
        return false;
    }
  }

  bool _isLocked(LogbookEntry entry) {
    switch (entry.type) {
      case LogbookEventType.flight:
        return entry.flight?.isLocked ?? false;
      case LogbookEventType.simulatorTraining:
        return entry.simulatorTraining?.isLocked ?? false;
      case LogbookEventType.dutyPeriod:
        return entry.dutyStart?.isLocked ?? entry.dutyEnd?.isLocked ?? false;
      case LogbookEventType.positioning:
        return entry.positioning?.isLocked ?? false;
      case LogbookEventType.unknown:
        return false;
    }
  }

  bool _hasEndorsement(String? endorsementData, List<int>? signatureImage) {
    return (endorsementData?.trim().isNotEmpty ?? false) ||
        (signatureImage?.isNotEmpty ?? false);
  }
}

class _SimpleTopLine extends StatelessWidget {
  const _SimpleTopLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final baseStyle =
        Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ) ??
        const TextStyle();
    final style = _ScaledText.scaledStyle(baseStyle)!;
    return DefaultTextStyle(
      style: style,
      child: Row(
        children: [Icon(icon, size: 14), const SizedBox(width: 6), Text(label)],
      ),
    );
  }
}

class _RightLine extends StatelessWidget {
  const _RightLine({required this.label, required this.value, this.style});

  final String label;
  final String value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ', style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _FlightTopLine extends StatelessWidget {
  const _FlightTopLine({
    required this.tailNumber,
    required this.typeLongName,
    this.label,
    this.icon,
    this.hasEndorsement = false,
  });

  final String tailNumber;
  final String typeLongName;
  final String? label;
  final IconData? icon;
  final bool hasEndorsement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final baseStyle =
        Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ) ??
        const TextStyle();
    final style = _ScaledText.scaledStyle(baseStyle)!;
    return DefaultTextStyle(
      style: style,
      child: Row(
        children: [
          Icon(icon ?? Icons.flight_takeoff, size: 14),
          const SizedBox(width: 6),
          Text(label ?? l10n.logbookEventFlight),
          if (hasEndorsement) ...[
            const SizedBox(width: 6),
            Icon(
              Icons.verified_outlined,
              size: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    typeLongName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('-'),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    tailNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateBlock extends StatelessWidget {
  const _DateBlock({required this.day, required this.month});

  final String day;
  final String month;

  @override
  Widget build(BuildContext context) {
    final titleStyle =
        _ScaledText.scaledStyle(
          Theme.of(context).textTheme.headlineSmall,
        )?.copyWith(
          fontSize:
              (Theme.of(context).textTheme.headlineSmall?.fontSize ?? 0) + 2,
        );
    final labelStyle = _ScaledText.scaledStyle(
      Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(day, style: titleStyle),
        Text(month, style: labelStyle),
      ],
    );
  }
}

class _ScaledText extends StatelessWidget {
  const _ScaledText(this.text, {this.style});

  final String text;
  final TextStyle? style;

  static TextStyle? scaledStyle(TextStyle? style) {
    if (style == null) return null;
    final size = style.fontSize;
    if (size == null) return style;
    return style.copyWith(fontSize: size + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Text(text, style: scaledStyle(style));
  }
}

class _EventTileShell extends StatelessWidget {
  const _EventTileShell({
    required this.entry,
    required this.isCompact,
    required this.content,
    this.onOpen,
    this.onEdit,
  });

  final LogbookEntry entry;
  final bool isCompact;
  final ValueChanged<LogbookEntry>? onOpen;
  final ValueChanged<LogbookEntry>? onEdit;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onOpen != null
          ? () => onOpen!(entry)
          : onEdit == null
          ? null
          : () => onEdit!(entry),
      title: Padding(
        padding: isCompact
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 8),
        child: content,
      ),
    );
  }
}

class _RouteCodesAndDurationRow extends StatelessWidget {
  const _RouteCodesAndDurationRow({
    required this.depCode,
    required this.center,
    required this.arrCode,
    required this.titleStyle,
  });

  final String depCode;
  final Widget center;
  final String arrCode;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final cells = [
      _ScaledText(depCode, style: titleStyle),
      center,
      _ScaledText(arrCode, style: titleStyle),
    ];
    return Row(
      children: cells
          .map((cell) => _CenteredExpanded(child: cell))
          .toList(growable: false),
    );
  }
}

class _RouteTimesAndPathRow extends StatelessWidget {
  const _RouteTimesAndPathRow({
    required this.depTime,
    required this.arrTime,
    required this.icon,
  });

  final String depTime;
  final String arrTime;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cells = [
      _ScaledText(depTime),
      _PathWithIcon(icon: icon),
      _ScaledText(arrTime),
    ];
    return Row(
      children: cells
          .map((cell) => _CenteredExpanded(child: cell))
          .toList(growable: false),
    );
  }
}

class _CenteredExpanded extends StatelessWidget {
  const _CenteredExpanded({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Center(child: child));
  }
}

class _PathWithIcon extends StatelessWidget {
  const _PathWithIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 30) {
          return const SizedBox.shrink();
        }
        return SizedBox(
          height: 16,
          child: Row(
            children: [
              Expanded(child: Divider(color: color, thickness: 1, height: 1)),
              const SizedBox(width: 6),
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(child: Divider(color: color, thickness: 1, height: 1)),
            ],
          ),
        );
      },
    );
  }
}

class _DateDivider extends StatelessWidget {
  const _DateDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 46, color: color.withValues(alpha: 0.7));
  }
}
