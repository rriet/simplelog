import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/pilot_function.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_list_item.dart';

// Helpers to build minimal Flight/TimeLine without needing DB.
TimeLine _timeLine(DateTime eventDateTime) => TimeLine(
      id: 1,
      eventDateTime: eventDateTime,
    );

Flight _flight({
  required int id,
  DateTime? takeOff,
  DateTime? landing,
  DateTime? arrival,
}) {
  // Drift generates Flight with many required fields; we provide minimal.
  // Use Flight constructor from app_database.dart
  return Flight(
    id: id,
    aircraftId: 1,
    departureAirportId: 1,
    arrivalAirportId: 2,
    departureDateTimeId: 1,
    takeOffDateTime: takeOff,
    landingDateTime: landing,
    arrivalDateTime: arrival,
    timePICMinutes: 0,
    timePICUSMinutes: 0,
    timeSICMinutes: 0,
    timeDualMinutes: 0,
    timeInstructorMinutes: 0,
    timeIFRMinutes: 0,
    timeNightMinutes: 0,
    timeCrossCountryMinutes: 0,
    timeCustom1Minutes: 0,
    timeCustom2Minutes: 0,
    timeCustom3Minutes: 0,
    timeCustom4Minutes: 0,
    timeFlightMinutes: 0,
    timeBlockMinutes: 60,
    timeTotalBlockMinutes: 60,
    distanceNM: 0,
    ifrApproaches: 0,
    takeOffsDays: 0,
    takeOffsNight: 0,
    landingsDay: 0,
    landingsNight: 0,
    pilotFunction: PilotFunction.pf,
    approachType: '',
    remarks: '',
    notes: '',
    isLocked: false,
    signatureImage: null,
    endorsementData: null,
    endorsementHash: null,
  );
}

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SizedBox(width: 800, child: child)),
    );

void main() {
  group('LogbookListItem flight time display', () {
    testWidgets('shows chocks-off 23:45 not take-off 23:58', (tester) async {
      final chocksOff = DateTime.utc(2026, 1, 1, 23, 45);
      final takeOff = DateTime.utc(2026, 1, 1, 23, 58);
      final arrival = DateTime.utc(2026, 1, 2, 1, 10);
      final entry = LogbookEntry(
        timeLine: _timeLine(chocksOff),
        flight: _flight(id: 1, takeOff: takeOff, arrival: arrival),
        departureAirport: const Airport(
          id: 1,
          icao: 'EDDF',
          name: 'Frankfurt',
          latitude: 0,
          longitude: 0,
          isFavorite: false,
          isLocked: false,
        ),
        arrivalAirport: const Airport(
          id: 2,
          icao: 'EGLL',
          name: 'Heathrow',
          latitude: 0,
          longitude: 0,
          isFavorite: false,
          isLocked: false,
        ),
      );

      await tester.pumpWidget(_wrap(LogbookListItem(entry: entry, isCompact: false)));
      await tester.pumpAndSettle();

      expect(find.text('23:45'), findsOneWidget);
      expect(find.text('23:58'), findsNothing);
      expect(find.text('01:10'), findsOneWidget);
    });

    testWidgets('both 00:00 => both --:--', (tester) async {
      final chocksOff = DateTime.utc(2026, 1, 1, 0, 0);
      final arrival = DateTime.utc(2026, 1, 1, 0, 0);
      final entry = LogbookEntry(
        timeLine: _timeLine(chocksOff),
        flight: _flight(id: 2, arrival: arrival),
      );
      await tester.pumpWidget(_wrap(LogbookListItem(entry: entry, isCompact: false)));
      await tester.pumpAndSettle();
      // Two occurrences of --:-- (dep and arr) in _RouteTimesAndPathRow
      expect(find.text('--:--'), findsNWidgets(2));
    });

    testWidgets('chocks-off 00:00 chocks-on 01:00 => 00:00 and 01:00', (tester) async {
      final chocksOff = DateTime.utc(2026, 1, 1, 0, 0);
      final arrival = DateTime.utc(2026, 1, 1, 1, 0);
      final entry = LogbookEntry(
        timeLine: _timeLine(chocksOff),
        flight: _flight(id: 3, arrival: arrival),
      );
      await tester.pumpWidget(_wrap(LogbookListItem(entry: entry, isCompact: false)));
      await tester.pumpAndSettle();
      expect(find.text('00:00'), findsOneWidget);
      expect(find.text('01:00'), findsOneWidget);
      expect(find.text('--:--'), findsNothing);
    });

    testWidgets('chocks-off 23:00 chocks-on 00:00 => 00:00 shown', (tester) async {
      final chocksOff = DateTime.utc(2026, 1, 1, 23, 0);
      final arrival = DateTime.utc(2026, 1, 1, 0, 0);
      final entry = LogbookEntry(
        timeLine: _timeLine(chocksOff),
        flight: _flight(id: 4, arrival: arrival),
      );
      await tester.pumpWidget(_wrap(LogbookListItem(entry: entry, isCompact: false)));
      await tester.pumpAndSettle();
      expect(find.text('23:00'), findsOneWidget);
      expect(find.text('00:00'), findsOneWidget);
    });

    testWidgets('null chocks-on => arr --:-- dep valid', (tester) async {
      final chocksOff = DateTime.utc(2026, 1, 1, 12, 0);
      final entry = LogbookEntry(
        timeLine: _timeLine(chocksOff),
        flight: _flight(id: 5, arrival: null),
      );
      await tester.pumpWidget(_wrap(LogbookListItem(entry: entry, isCompact: false)));
      await tester.pumpAndSettle();
      expect(find.text('12:00'), findsOneWidget);
      expect(find.text('--:--'), findsOneWidget);
    });

    testWidgets('deleted all 4: chocks-off 00:00 + all null => both --:-- (edit blank mimic)', (tester) async {
      final chocksOff = DateTime.utc(2026, 1, 1, 0, 0);
      final entry = LogbookEntry(
        timeLine: _timeLine(chocksOff),
        flight: _flight(id: 6, takeOff: null, landing: null, arrival: null),
      );
      await tester.pumpWidget(_wrap(LogbookListItem(entry: entry, isCompact: false)));
      await tester.pumpAndSettle();
      expect(find.text('--:--'), findsNWidgets(2));
      expect(find.text('00:00'), findsNothing);
    });

    testWidgets('midnight chocks-off with takeoff present + null arrival => still --:-- (takeoff irrelevant, copy edit)', (tester) async {
      final chocksOff = DateTime.utc(2026, 1, 1, 0, 0);
      final entry = LogbookEntry(
        timeLine: _timeLine(chocksOff),
        flight: _flight(id: 7, takeOff: DateTime.utc(2026, 1, 1, 0, 5), arrival: null),
      );
      await tester.pumpWidget(_wrap(LogbookListItem(entry: entry, isCompact: false)));
      await tester.pumpAndSettle();
      expect(find.text('--:--'), findsNWidgets(2));
      expect(find.text('00:00'), findsNothing);
    });
  });
}
