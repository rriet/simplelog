import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/dialog_adaptive_presenter.dart'
    show isCompactDialogScreen;
import 'package:simplelog/core/presentation/widgets/maps/flight_routes_map_view.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/aircraft_row.dart';
import 'package:simplelog/data/models/aircraft_type_row.dart';
import 'package:simplelog/data/models/crew_info_item.dart';
import 'package:simplelog/data/models/crew_row.dart';
import 'package:simplelog/data/models/endorsement_data.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/domain/usecases/logbook_use_cases.dart';
import 'package:simplelog/features/aircraft/presentation/widgets/aircraft_details_dialog.dart';
import 'package:simplelog/features/aircraft_types/presentation/widgets/aircraft_type_details_dialog.dart';
import 'package:simplelog/features/airports/presentation/widgets/airport_details_dialog.dart';
import 'package:simplelog/features/crew/presentation/widgets/crew_info_dialog.dart';

/// Helper entry-point for displaying event detail dialogs from the logbook.
class LogbookEntryDialogs {
  const LogbookEntryDialogs._();

  static Future<void> _showEntryInfoShell(
    BuildContext context, {
    required WidgetBuilder builder,
  }) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (isCompactDialogScreen(context)) {
      await navigator.push(MaterialPageRoute<void>(builder: builder));
      return;
    }
    await showDialog<void>(
      context: context,
      builder: builder,
    );
  }

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
                      onPressed: () => AppNavigator.pop(dialogContext),
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

    await _showEntryInfoShell(
      context,
      builder: (dialogContext) {
        return _EntryInfoDialogShell(
          title: l10n.logbookEventPositioning,
          maxWidth: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PositioningInfoCard(
                child: _LabeledTwoColumnInfoCard(
                  leftLabel: 'Date',
                  leftValue: dateLabel,
                  rightLabel: 'Total',
                  rightValue: '${totalTime}h',
                ),
              ),
              const SizedBox(height: 10),
              _PositioningInfoCard(
                child: Column(
                  children: [
                    _FromToInfoRow(
                      leftValue: depCode,
                      rightValue: arrCode,
                    ),
                    const SizedBox(height: 10),
                    _LabeledTwoColumnInfoCard(
                      leftLabel: 'Departure',
                      leftValue: depTime,
                      rightLabel: 'Arrival',
                      rightValue: arrTime,
                    ),
                  ],
                ),
              ),
              if (notes.isNotEmpty) ...[
                const SizedBox(height: 10),
                _PositioningInfoCard(
                  child: _PositioningInfoValue(
                    label: AppLocalizations.of(context)!.fieldNotes,
                    value: notes,
                  ),
                ),
              ],
            ],
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
    await _showEntryInfoShell(
      context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colorScheme = theme.colorScheme;
        return _EntryInfoDialogShell(
          title: l10n.logbookEventFlight,
          maxWidth: 620,
          maxHeight: 760,
          scrollable: true,
          actions: hasEndorsement
              ? [
                  IconButton(
                    tooltip: AppLocalizations.of(context)!.autoUi053,
                    onPressed: () => _showEndorsementInfo(
                      context,
                      endorsement!,
                      isHashValid: isHashValid,
                    ),
                    icon: _EndorsementStatusIcon(
                      isValid: isHashValid,
                      colorScheme: colorScheme,
                    ),
                  ),
                ]
              : const <Widget>[],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LabeledTwoColumnInfoCard(
                leftLabel: 'Date',
                leftValue: dateLabel,
                rightLabel: AppLocalizations.of(context)!.searchFieldType,
                rightValue: typeName,
                rightOnTap: entry.aircraftType == null
                    ? null
                    : () => _showAircraftTypeInfo(
                        dialogContext,
                        entry.aircraftType!,
                        useCases,
                      ),
              ),
              const SizedBox(height: 10),
              _LabeledTwoColumnInfoCard(
                leftLabel: 'Function',
                leftValue: pfpm ?? '-',
                rightLabel: 'Tail',
                rightValue: tail,
                rightOnTap: entry.aircraft == null
                    ? null
                    : () => _showAircraftInfo(
                        dialogContext,
                        entry.aircraft!,
                        entry.aircraftType,
                        useCases,
                      ),
              ),
              const SizedBox(height: 10),
              _FromToInfoRow(
                leftValue: dep,
                rightValue: arr,
                leftOnTap: depAirport == null
                    ? null
                    : () => _showAirportInfo(
                        dialogContext,
                        depAirport,
                        useCases,
                      ),
                rightOnTap: arrAirport == null
                    ? null
                    : () => _showAirportInfo(
                        dialogContext,
                        arrAirport,
                        useCases,
                      ),
                onMapTap: depAirport == null || arrAirport == null
                    ? null
                    : () => _showSingleFlightMap(
                        dialogContext,
                        departure: depAirport,
                        arrival: arrAirport,
                      ),
              ),
              const SizedBox(height: 10),
              _DepartureBlockArrivalRow(
                departure: depTime,
                block: blockTime,
                arrival: arrTime,
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
                    AppLocalizations.of(context)!.screenCrew,
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
                        onTap: () => _showCrewInfo(context, crew, useCases),
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
                _SectionDivider(color: colorScheme.outlineVariant),
                _SectionLabelAndText(
                  label: AppLocalizations.of(
                    context,
                  )!.reportsFilterFieldRemarks,
                  value: remarks,
                ),
              ],
              if (notes.isNotEmpty) ...[
                _SectionDivider(color: colorScheme.outlineVariant),
                _SectionLabelAndText(
                  label: AppLocalizations.of(context)!.fieldNotes,
                  value: notes,
                ),
              ],
            ],
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
    await _showEntryInfoShell(
      context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colorScheme = theme.colorScheme;
        return _EntryInfoDialogShell(
          title: l10n.logbookEventSimulator,
          maxWidth: 560,
          maxHeight: 720,
          scrollable: true,
          actions: hasEndorsement
              ? [
                  IconButton(
                    tooltip: AppLocalizations.of(context)!.autoUi053,
                    onPressed: () => _showEndorsementInfo(
                      context,
                      endorsement!,
                      isHashValid: isHashValid,
                    ),
                    icon: _EndorsementStatusIcon(
                      isValid: isHashValid,
                      colorScheme: colorScheme,
                    ),
                  ),
                ]
              : const <Widget>[],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PositioningInfoCard(
                child: _LabeledTwoColumnInfoCard(
                  leftLabel: 'Date',
                  leftValue: dateLabel,
                  rightLabel: 'Session',
                  rightValue: '${_formatMinutes(sim.timeTotal)}h',
                ),
              ),
              const SizedBox(height: 10),
              _PositioningInfoCard(
                child: _LabeledTwoColumnInfoCard(
                  leftLabel: 'Aircraft',
                  leftValue: typeName,
                  rightLabel: 'Tail',
                  rightValue: tail,
                ),
              ),
              if (hasCrew) ...[
                const SizedBox(height: 10),
                _PositioningInfoCard(
                  child: _CrewInfoList(
                    title: AppLocalizations.of(context)!.screenCrew,
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
                  child: _SectionLabelAndText(
                    label: AppLocalizations.of(
                      context,
                    )!.reportsFilterFieldRemarks,
                    value: remarks,
                  ),
                ),
              ],
              if (notes.isNotEmpty) ...[
                const SizedBox(height: 10),
                _PositioningInfoCard(
                  child: _SectionLabelAndText(
                    label: AppLocalizations.of(context)!.fieldNotes,
                    value: notes,
                  ),
                ),
              ],
            ],
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

  static Future<void> _showAircraftInfo(
    BuildContext context,
    Aircraft aircraft,
    AircraftType? type,
    LogbookUseCases useCases,
  ) async {
    await showAircraftDetailsDialog(
      context,
      row: AircraftRow(aircraft, type),
      logbookUseCases: useCases,
      onEntryTap: (entry) => show(context, entry: entry, useCases: useCases),
    );
  }

  static Future<void> _showAircraftTypeInfo(
    BuildContext context,
    AircraftType type,
    LogbookUseCases useCases,
  ) async {
    await showAircraftTypeDetailsDialog(
      context,
      row: AircraftTypeRow(type),
      logbookUseCases: useCases,
      onEntryTap: (entry) => show(context, entry: entry, useCases: useCases),
    );
  }

  static Future<void> _showSingleFlightMap(
    BuildContext context, {
    required Airport departure,
    required Airport arrival,
  }) async {
    await _showEntryInfoShell(
      context,
      builder: (_) => _SingleFlightMapDialog(
        departure: departure,
        arrival: arrival,
      ),
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
    final l10n = AppLocalizations.of(context)!;
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
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.autoUi028,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => AppNavigator.pop(dialogContext),
                      child: Text(AppLocalizations.of(context)!.autoUi013),
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
                      l10n.endorsementMismatchWarning,
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
                        label: AppLocalizations.of(context)!.fieldName,
                        value: endorsement.name.isEmpty
                            ? '-'
                            : endorsement.name,
                      ),
                      const SizedBox(height: 8),
                      _PositioningInfoValue(
                        label: AppLocalizations.of(context)!.autoUi009,
                        value: endorsement.certificate.isEmpty
                            ? '-'
                            : endorsement.certificate,
                      ),
                      const SizedBox(height: 8),
                      _PositioningInfoValue(
                        label: AppLocalizations.of(context)!.autoUi030,
                        value: endorsement.expiry.isEmpty
                            ? '-'
                            : endorsement.expiry,
                      ),
                      const SizedBox(height: 8),
                      _PositioningInfoValue(
                        label: AppLocalizations.of(context)!.searchFieldType,
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

class _EntryInfoDialogShell extends StatelessWidget {
  const _EntryInfoDialogShell({
    required this.title,
    required this.maxWidth,
    required this.child,
    this.maxHeight,
    this.scrollable = false,
    this.actions = const <Widget>[],
  });

  final String title;
  final double maxWidth;
  final double? maxHeight;
  final bool scrollable;
  final List<Widget> actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(20),
      child: scrollable ? SingleChildScrollView(child: child) : child,
    );
    return AdaptiveFormShell(
      onClose: () => AppNavigator.pop(context),
      title: title,
      popupMaxWidth: maxWidth,
      actions: actions,
      contentView: maxHeight == null
          ? content
          : ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight!),
              child: content,
            ),
    );
  }
}

class _FromToInfoRow extends StatelessWidget {
  const _FromToInfoRow({
    required this.leftValue,
    required this.rightValue,
    this.leftOnTap,
    this.rightOnTap,
    this.onMapTap,
  });

  final String leftValue;
  final String rightValue;
  final VoidCallback? leftOnTap;
  final VoidCallback? rightOnTap;
  final VoidCallback? onMapTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: _PositioningInfoValue(
            label: AppLocalizations.of(context)!.autoUi034,
            value: leftValue,
            onTap: leftOnTap,
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onMapTap != null) ...[
                  IconButton(
                    tooltip: AppLocalizations.of(context)!.mapTitle,
                    onPressed: onMapTap,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.map_outlined,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  AppLocalizations.of(context)!.autoUi068,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _PositioningInfoValue(
            label: AppLocalizations.of(context)!.autoUi061,
            value: rightValue,
            alignEnd: true,
            onTap: rightOnTap,
          ),
        ),
      ],
    );
  }
}

class _SingleFlightMapDialog extends StatefulWidget {
  const _SingleFlightMapDialog({
    required this.departure,
    required this.arrival,
  });

  final Airport departure;
  final Airport arrival;

  @override
  State<_SingleFlightMapDialog> createState() => _SingleFlightMapDialogState();
}

class _SingleFlightMapDialogState extends State<_SingleFlightMapDialog> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AdaptiveFormShell(
      onClose: () => AppNavigator.pop(context),
      title: l10n.reportsFlightMapTitle,
      popupMaxWidth: 1100,
      contentView: FlightRoutesMapView(
        pairs: [
          FlightRoutePair(
            from: LatLng(
              widget.departure.latitude,
              widget.departure.longitude,
            ),
            to: LatLng(widget.arrival.latitude, widget.arrival.longitude),
          ),
        ],
        airportCountLabel: l10n.reportsAirportsCount(2),
      ),
    );
  }
}

class _DepartureBlockArrivalRow extends StatelessWidget {
  const _DepartureBlockArrivalRow({
    required this.departure,
    required this.block,
    required this.arrival,
  });

  final String departure;
  final String block;
  final String arrival;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: _PositioningInfoValue(
            label: AppLocalizations.of(context)!.autoUi019,
            value: departure,
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.dashboardBlockLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                block,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
        Expanded(
          child: _PositioningInfoValue(
            label: AppLocalizations.of(context)!.autoUi005,
            value: arrival,
            alignEnd: true,
          ),
        ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: color,
      height: 21,
      thickness: 1,
    );
  }
}

class _SectionLabelAndText extends StatelessWidget {
  const _SectionLabelAndText({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _LabeledValueText(
      label: label,
      value: value,
      spacing: 4,
      labelStyleBuilder: (theme) => theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      valueStyleBuilder: (theme) => theme.textTheme.bodyMedium,
    );
  }
}

class _LabeledTwoColumnInfoCard extends StatelessWidget {
  const _LabeledTwoColumnInfoCard({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
    this.rightOnTap,
  });

  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;
  final VoidCallback? rightOnTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PositioningInfoValue(label: leftLabel, value: leftValue),
        ),
        Expanded(
          child: _PositioningInfoValue(
            label: rightLabel,
            value: rightValue,
            alignEnd: true,
            onTap: rightOnTap,
          ),
        ),
      ],
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
    return _LabeledValueText(
      label: label,
      value: value,
      alignEnd: alignEnd,
      onTap: onTap,
      labelStyleBuilder: (theme) => theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      valueStyleBuilder: (theme) => theme.textTheme.titleMedium?.copyWith(
        color: onTap == null ? null : theme.colorScheme.primary,
      ),
    );
  }
}

class _LabeledValueText extends StatelessWidget {
  const _LabeledValueText({
    required this.label,
    required this.value,
    required this.labelStyleBuilder,
    required this.valueStyleBuilder,
    this.alignEnd = false,
    this.spacing = 2,
    this.onTap,
  });

  final String label;
  final String value;
  final bool alignEnd;
  final double spacing;
  final TextStyle? Function(ThemeData theme) labelStyleBuilder;
  final TextStyle? Function(ThemeData theme) valueStyleBuilder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyleBuilder(theme)),
        SizedBox(height: spacing),
        Text(
          value,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: valueStyleBuilder(theme),
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
