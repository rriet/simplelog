import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/logbook_entry.dart';

class LogbookEntryDialogs {
  const LogbookEntryDialogs._();

  static Future<void> show(
    BuildContext context, {
    required LogbookEntry entry,
    required AppDatabase db,
  }) async {
    switch (entry.type) {
      case LogbookEventType.flight:
        await _showFlightInfo(context, entry, db);
        return;
      case LogbookEventType.simulatorTraining:
        await _showSimulatorInfo(context, entry, db);
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
      builder: (context) => AlertDialog(
        title: const Text('Event Info'),
        content: Text(
          '${_eventLabel(l10n, entry)}\n$dateLabel $timeLabel',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.okAction),
          ),
        ],
      ),
    );
  }

  static Future<void> _showPositioningInfo(
    BuildContext context,
    LogbookEntry entry,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final date = entry.timeLine.eventDateTime;
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat('dd/MMM yyyy', locale).format(date);
    final timeLabel = DateFormat('HH:mm', locale).format(date);
    final pos = entry.positioning;
    final dep = entry.positioningDepartureAirport?.icao ?? '-';
    final arr = entry.positioningArrivalAirport?.icao ?? '-';
    final time = pos == null ? '0:00' : _formatMinutes(pos.timeTotalMinutes);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Positioning'),
        content: Text(
          '$dateLabel $timeLabel\n'
          'Route: $dep → $arr\n'
          'Time: $time',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.okAction),
          ),
        ],
      ),
    );
  }

  static Future<void> _showFlightInfo(
    BuildContext context,
    LogbookEntry entry,
    AppDatabase db,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final flight = entry.flight!;

    final crewRows = await (db.select(db.flightCrewAssignments).join([
      drift.innerJoin(
        db.crew,
        db.crew.id.equalsExp(db.flightCrewAssignments.crewId),
      ),
    ])..where(db.flightCrewAssignments.flightId.equals(flight.id))).get();

    final crewList = crewRows
        .map((row) {
          final crew = row.readTable(db.crew);
          final assignment = row.readTable(db.flightCrewAssignments);
          return '${assignment.position.name.toUpperCase()}: ${crew.name}';
        })
        .toList();

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

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Flight'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$dateLabel | $typeName | $tail'),
              const SizedBox(height: 8),
              Text('From: $dep'),
              Text('To: $arr'),
              const SizedBox(height: 8),
              Text('Dep Time: $depTime'),
              Text('Arrival Time: $arrTime'),
              const SizedBox(height: 8),
              Text('Crew:'),
              ...crewList.map(Text.new),
              const SizedBox(height: 8),
              Text('Total Time: ${_formatMinutes(flight.timeFlightMinutes)}'),
              Text('CrossCountry: '
                  '${_formatMinutes(flight.timeCrossCountryMinutes)}'),
              Text('PIC: ${_formatMinutes(flight.timePICMinutes)}'),
              Text('SIC: ${_formatMinutes(flight.timeSICMinutes)}'),
              Text('DUAL: ${_formatMinutes(flight.timeDualMinutes)}'),
              Text('Instructor: '
                  '${_formatMinutes(flight.timeInstructorMinutes)}'),
              Text('IFR: ${_formatMinutes(flight.timeIFRMinutes)}'),
              Text('Night: ${_formatMinutes(flight.timeNightMinutes)}'),
              const SizedBox(height: 8),
              Text('Remarks: ${flight.remarks}'),
              Text('Notes: ${flight.notes}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.okAction),
          ),
        ],
      ),
    );
  }

  static Future<void> _showSimulatorInfo(
    BuildContext context,
    LogbookEntry entry,
    AppDatabase db,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final sim = entry.simulatorTraining!;

    final crewRows = await (db.select(db.simulatorCrewAssignments).join([
      drift.innerJoin(
        db.crew,
        db.crew.id.equalsExp(db.simulatorCrewAssignments.crewId),
      ),
    ])..where(db.simulatorCrewAssignments.simulatorId.equals(sim.id))).get();

    final crewList = crewRows
        .map((row) {
          final crew = row.readTable(db.crew);
          final assignment = row.readTable(db.simulatorCrewAssignments);
          return '${assignment.position.name.toUpperCase()}: ${crew.name}';
        })
        .toList();

    final date = entry.timeLine.eventDateTime;
    final dateLabel = DateFormat('dd/MMM yyyy', locale).format(date);
    final typeName = entry.aircraftType?.longName ??
        entry.aircraftType?.code ??
        '-';
    final tail = entry.aircraft?.registration ?? '-';

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simulator'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$dateLabel | $typeName | $tail'),
              const SizedBox(height: 8),
              Text('Session Time: ${_formatMinutes(sim.timeTotal)}'),
              const SizedBox(height: 8),
              Text('Crew:'),
              ...crewList.map(Text.new),
              const SizedBox(height: 8),
              Text('Remarks: ${sim.remarks}'),
              Text('Notes: ${sim.notes}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.okAction),
          ),
        ],
      ),
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
