import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/crew_info_item.dart';
import 'package:simplelog/data/models/crew_row.dart';
import 'package:simplelog/data/models/endorsement_data.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/domain/usecases/logbook_use_cases.dart';
import 'package:simplelog/features/airports/presentation/widgets/airport_details_dialog.dart';
import 'package:simplelog/features/crew/presentation/widgets/crew_info_dialog.dart';

/// Helper entry-point for displaying event detail dialogs from the logbook.
class LogbookEntryDialogs {
  const LogbookEntryDialogs._();

  /// Opens the appropriate info dialog for the provided [entry].
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
        await _showPositioningInfo(context, entry, useCases);
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
    final dateLabel = DateFormat('dd/MMM yyyy', locale).format(_asUtc(date));
    final timeLabel = DateFormat('HH:mm', locale).format(_asUtc(date));
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
                        l10n.eventInfoTitle,
                        style: Theme.of(dialogContext).textTheme.titleSmall,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(l10n.okAction),
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
    LogbookUseCases useCases,
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
    final dateLabel = DateFormat('dd/MMM/yyyy', locale).format(
      _asUtc(depDateTime),
    );

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
                        child: Text(l10n.okAction),
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

    final crewList = await useCases.fetchFlightCrewInfo(flight.id);

    final date = entry.timeLine.eventDateTime;
    final dateLabel = DateFormat('dd/MMM yyyy', locale).format(_asUtc(date));
    final depTime = _formatTime(entry.flight?.takeOffDateTime, date);
    final arrTime = _formatTime(entry.flight?.arrivalDateTime, null);

    final typeName =
        entry.aircraftType?.longName ?? entry.aircraftType?.code ?? '-';
    final tail = entry.aircraft?.registration ?? '-';
    final depAirport = entry.departureAirport;
    final arrAirport = entry.arrivalAirport;
    final dep = depAirport?.icao ?? '-';
    final arr = arrAirport?.icao ?? '-';
    final blockTime = '${_formatMinutes(flight.timeBlockMinutes)}h';
    final remarks = flight.remarks.trim();
    final notes = flight.notes.trim();
    final endorsement = EndorsementData.fromJsonString(
      flight.endorsementData,
      signatureImage: flight.signatureImage,
    );
    final hasEndorsement = _hasEndorsement(endorsement);
    final isHashValid =
        !hasEndorsement ||
        await useCases.verifyFlightEndorsementHash(flight.id);
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
                      if (hasEndorsement)
                        IconButton(
                          tooltip: 'Show endorsement',
                          onPressed: () => _showEndorsementInfo(
                            dialogContext,
                            endorsement!,
                            isHashValid: isHashValid,
                          ),
                          icon: _EndorsementStatusIcon(
                            isValid: isHashValid,
                            colorScheme: colorScheme,
                          ),
                        ),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(l10n.okAction),
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
                                label: 'Function',
                                value: pfpm ?? '-',
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
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _PositioningInfoValue(
                                label: 'From',
                                value: dep,
                                onTap: depAirport == null
                                    ? null
                                    : () => _showAirportInfo(
                                        dialogContext,
                                        depAirport,
                                        useCases,
                                      ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  '→',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: _PositioningInfoValue(
                                label: 'To',
                                value: arr,
                                alignEnd: true,
                                onTap: arrAirport == null
                                    ? null
                                    : () => _showAirportInfo(
                                        dialogContext,
                                        arrAirport,
                                        useCases,
                                      ),
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
                              child: Column(
                                children: [
                                  Text(
                                    'Block',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    blockTime,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
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

                        if (timeMetrics.isNotEmpty) ...[
                          Divider(
                            color: colorScheme.outlineVariant,
                            height: 21,
                            thickness: 1,
                          ),
                          Wrap(
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
                        ],
                        if (hasCrew) ...[
                          Divider(
                            color: colorScheme.outlineVariant,
                            height: 21,
                            thickness: 1,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Crew',
                              textAlign: TextAlign.left,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...crewList.map(
                            (crew) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: InkWell(
                                  onTap: () =>
                                      _showCrewInfo(context, crew, useCases),
                                  child: Text(
                                    '${crew.positionLabel}: ${crew.name}',
                                    textAlign: TextAlign.left,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (remarks.isNotEmpty) ...[
                          Divider(
                            color: colorScheme.outlineVariant,
                            height: 21,
                            thickness: 1,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Remarks',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              remarks,
                              textAlign: TextAlign.left,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                        if (notes.isNotEmpty) ...[
                          Divider(
                            color: colorScheme.outlineVariant,
                            height: 21,
                            thickness: 1,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Notes',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              notes,
                              textAlign: TextAlign.left,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
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

    final crewList = await useCases.fetchSimulatorCrewInfo(sim.id);

    final date = entry.timeLine.eventDateTime;
    final dateLabel = DateFormat('dd/MMM yyyy', locale).format(_asUtc(date));
    final typeName =
        entry.aircraftType?.longName ?? entry.aircraftType?.code ?? '-';
    final tail = entry.aircraft?.registration ?? '-';
    final remarks = sim.remarks.trim();
    final notes = sim.notes.trim();
    final endorsement = EndorsementData.fromJsonString(
      sim.endorsementData,
      signatureImage: sim.signatureImage,
    );
    final hasEndorsement = _hasEndorsement(endorsement);
    final isHashValid =
        !hasEndorsement ||
        await useCases.verifySimulatorEndorsementHash(sim.id);
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
                      if (hasEndorsement)
                        IconButton(
                          tooltip: 'Show endorsement',
                          onPressed: () => _showEndorsementInfo(
                            dialogContext,
                            endorsement!,
                            isHashValid: isHashValid,
                          ),
                          icon: _EndorsementStatusIcon(
                            isValid: isHashValid,
                            colorScheme: colorScheme,
                          ),
                        ),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(l10n.okAction),
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
                        onTap: (crew) => _showCrewInfo(context, crew, useCases),
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

  static Future<void> _showCrewInfo(
    BuildContext context,
    CrewInfoItem crew,
    LogbookUseCases useCases,
  ) async {
    if (crew.crewId <= 0) return;
    await CrewInfoDialog.show(
      context,
      row: CrewRow(
        CrewData(
          id: crew.crewId,
          name: crew.name,
          email: crew.email,
          notes: crew.notes,
          phone: crew.phone,
          picture: crew.picture,
          isSelf: false,
          isFavorite: false,
          isLocked: false,
        ),
      ),
      useCases: useCases,
    );
  }

  static Future<void> _showAirportInfo(
    BuildContext context,
    Airport airport,
    LogbookUseCases useCases,
  ) async {
    await showAirportDetailsDialog(
      context,
      airport: airport,
      logbookUseCases: useCases,
    );
  }

  static bool _hasEndorsement(EndorsementData? endorsement) {
    if (endorsement == null) return false;
    return !endorsement.isEmpty;
  }

  static Future<void> _showEndorsementInfo(
    BuildContext context,
    EndorsementData endorsement, {
    bool isHashValid = true,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Endorsement',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (!isHashValid) ...[
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        dialogContext,
                      ).colorScheme.errorContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Warning: flight information does not match the '
                      'original endorsed flight record.',
                      style: Theme.of(dialogContext).textTheme.bodyMedium
                          ?.copyWith(
                            color: Theme.of(dialogContext).colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
                _PositioningInfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PositioningInfoValue(
                        label: 'Name',
                        value: endorsement.name.isEmpty
                            ? '-'
                            : endorsement.name,
                      ),
                      const SizedBox(height: 8),
                      _PositioningInfoValue(
                        label: 'Certificate',
                        value: endorsement.certificate.isEmpty
                            ? '-'
                            : endorsement.certificate,
                      ),
                      const SizedBox(height: 8),
                      _PositioningInfoValue(
                        label: 'Expiry',
                        value: endorsement.expiry.isEmpty
                            ? '-'
                            : endorsement.expiry,
                      ),
                      const SizedBox(height: 8),
                      _PositioningInfoValue(
                        label: 'Type',
                        value: endorsement.type.isEmpty
                            ? '-'
                            : endorsement.type,
                      ),
                      if (endorsement.hasSignature) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(
                                dialogContext,
                              ).colorScheme.outlineVariant,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Image.memory(
                              endorsement.signatureImage!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EndorsementStatusIcon extends StatelessWidget {
  const _EndorsementStatusIcon({
    required this.isValid,
    required this.colorScheme,
  });

  final bool isValid;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    if (isValid) {
      return Icon(Icons.verified_outlined, color: colorScheme.primary);
    }
    return SizedBox(
      width: 22,
      height: 22,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.verified_outlined, color: colorScheme.error),
          Transform.rotate(
            angle: -0.8,
            child: Container(
              width: 18,
              height: 2,
              color: colorScheme.error,
            ),
          ),
        ],
      ),
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
    this.onTap,
  });

  final String label;
  final String value;
  final bool alignEnd;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
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
          style: theme.textTheme.titleMedium?.copyWith(
            color: onTap == null ? null : theme.colorScheme.primary,
          ),
        ),
      ],
    );
    if (onTap == null) {
      return content;
    }
    return InkWell(
      onTap: onTap,
      child: content,
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
    required this.onTap,
    required this.titleStyle,
  });

  final String title;
  final List<CrewInfoItem> crewList;
  final ValueChanged<CrewInfoItem> onTap;
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
                child: InkWell(
                  onTap: () => widget.onTap(widget.crewList[index]),
                  child: Text(
                    '${widget.crewList[index].positionLabel}: '
                    '${widget.crewList[index].name}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
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
  final utc = _asUtc(value);
  if (utc.hour == 0 && utc.minute == 0) return '--:--';
  final hour = utc.hour.toString().padLeft(2, '0');
  final minute = utc.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

DateTime _asUtc(DateTime value) {
  if (value.isUtc) return value;
  return DateTime.fromMillisecondsSinceEpoch(
    value.millisecondsSinceEpoch,
    isUtc: true,
  );
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
