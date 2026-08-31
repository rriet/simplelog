import 'package:flutter_test/flutter_test.dart';
import 'package:simplelog/core/date/flight_time_formatter.dart';

void main() {
  group('FlightTimeFormatter', () {
    group('isPairedMidnightMissing', () {
      test('both 00:00 UTC => true', () {
        final off = DateTime.utc(2026, 1, 1, 0, 0);
        final on = DateTime.utc(2026, 1, 1, 0, 0);
        expect(FlightTimeFormatter.isPairedMidnightMissing(off, on), isTrue);
      });

      test('only chocks-off 00:00 => false', () {
        final off = DateTime.utc(2026, 1, 1, 0, 0);
        final on = DateTime.utc(2026, 1, 1, 1, 0);
        expect(FlightTimeFormatter.isPairedMidnightMissing(off, on), isFalse);
      });

      test('only chocks-on 00:00 => false', () {
        final off = DateTime.utc(2026, 1, 1, 23, 0);
        final on = DateTime.utc(2026, 1, 1, 0, 0);
        expect(FlightTimeFormatter.isPairedMidnightMissing(off, on), isFalse);
      });

      test('null chocks-off => false', () {
        final on = DateTime.utc(2026, 1, 1, 0, 0);
        expect(FlightTimeFormatter.isPairedMidnightMissing(null, on), isFalse);
      });

      test('null chocks-on => false', () {
        final off = DateTime.utc(2026, 1, 1, 0, 0);
        expect(FlightTimeFormatter.isPairedMidnightMissing(off, null), isFalse);
      });

      test('both null => false', () {
        expect(FlightTimeFormatter.isPairedMidnightMissing(null, null), isFalse);
      });

      test('both non-midnight => false', () {
        final off = DateTime.utc(2026, 1, 1, 23, 45);
        final on = DateTime.utc(2026, 1, 1, 1, 10);
        expect(FlightTimeFormatter.isPairedMidnightMissing(off, on), isFalse);
      });
    });

    group('formatChocksTime', () {
      test('null => --:--', () {
        expect(
          FlightTimeFormatter.formatChocksTime(null, pairedMidnightMissing: false),
          '--:--',
        );
        expect(
          FlightTimeFormatter.formatChocksTime(null, pairedMidnightMissing: true),
          '--:--',
        );
      });

      test('pairedMissing true => --:-- even if valid time', () {
        final t = DateTime.utc(2026, 1, 1, 23, 45);
        expect(
          FlightTimeFormatter.formatChocksTime(t, pairedMidnightMissing: true),
          '--:--',
        );
      });

      test('valid time 23:45 => 23:45', () {
        final t = DateTime.utc(2026, 1, 1, 23, 45);
        expect(
          FlightTimeFormatter.formatChocksTime(t, pairedMidnightMissing: false),
          '23:45',
        );
      });

      test('00:00 valid when not pairedMissing => 00:00', () {
        final t = DateTime.utc(2026, 1, 1, 0, 0);
        expect(
          FlightTimeFormatter.formatChocksTime(t, pairedMidnightMissing: false),
          '00:00',
        );
      });

      test('00:00 with pairedMissing => --:--', () {
        final t = DateTime.utc(2026, 1, 1, 0, 0);
        expect(
          FlightTimeFormatter.formatChocksTime(t, pairedMidnightMissing: true),
          '--:--',
        );
      });
    });

    group('formatChocksPair', () {
      test('chocks-off 23:45, take-off 23:58 context => departure shown 23:45', () {
        // Simulates bug: previously showed takeOff, now must show chocksOff.
        final chocksOff = DateTime.utc(2026, 1, 1, 23, 45);
        final chocksOn = DateTime.utc(2026, 1, 2, 1, 10);
        final (dep, arr) = FlightTimeFormatter.formatChocksPair(
          chocksOff: chocksOff,
          chocksOn: chocksOn,
        );
        expect(dep, '23:45');
        expect(arr, '01:10');
        // Ensure take-off time 23:58 would not be used (not part of API).
      });

      test('chocks-off AND chocks-on = 00:00 => both --:--', () {
        final off = DateTime.utc(2026, 1, 1, 0, 0);
        final on = DateTime.utc(2026, 1, 1, 0, 0);
        final (dep, arr) = FlightTimeFormatter.formatChocksPair(
          chocksOff: off,
          chocksOn: on,
        );
        expect(dep, '--:--');
        expect(arr, '--:--');
      });

      test('chocks-off == 00:00 chocks-on != 00:00 => chocks-off shown 00:00', () {
        final off = DateTime.utc(2026, 1, 1, 0, 0);
        final on = DateTime.utc(2026, 1, 1, 1, 0);
        final (dep, arr) = FlightTimeFormatter.formatChocksPair(
          chocksOff: off,
          chocksOn: on,
        );
        expect(dep, '00:00');
        expect(arr, '01:00');
      });

      test('chocks-off != 00:00 chocks-on == 00:00 => chocks-on shown 00:00', () {
        final off = DateTime.utc(2026, 1, 1, 23, 0);
        final on = DateTime.utc(2026, 1, 1, 0, 0);
        final (dep, arr) = FlightTimeFormatter.formatChocksPair(
          chocksOff: off,
          chocksOn: on,
        );
        expect(dep, '23:00');
        expect(arr, '00:00');
      });

      test('null chocks-off treated as missing => dep --:--', () {
        final on = DateTime.utc(2026, 1, 1, 12, 0);
        final (dep, arr) = FlightTimeFormatter.formatChocksPair(
          chocksOff: null,
          chocksOn: on,
        );
        expect(dep, '--:--');
        expect(arr, '12:00');
      });

      test('null chocks-on treated as missing => arr --:--', () {
        final off = DateTime.utc(2026, 1, 1, 12, 0);
        final (dep, arr) = FlightTimeFormatter.formatChocksPair(
          chocksOff: off,
          chocksOn: null,
        );
        expect(dep, '12:00');
        expect(arr, '--:--');
      });
    });

    group('formatOptionalFlightTime (take-off/landing)', () {
      test('null => --:--', () {
        expect(FlightTimeFormatter.formatOptionalFlightTime(null), '--:--');
      });

      test('00:00 valid => 00:00', () {
        expect(
          FlightTimeFormatter.formatOptionalFlightTime(DateTime.utc(2026, 1, 1, 0, 0)),
          '00:00',
        );
      });

      test('23:58 => 23:58', () {
        expect(
          FlightTimeFormatter.formatOptionalFlightTime(DateTime.utc(2026, 1, 1, 23, 58)),
          '23:58',
        );
      });
    });

    group('chocks-off null always --:-- (takeoff irrelevant)', () {
      test('chocks-off null + takeoff 00:01 => dep --:--', () {
        final (dep, arr) = FlightTimeFormatter.formatChocksPair(
          chocksOff: null,
          chocksOn: DateTime.utc(2026, 1, 1, 1, 0),
        );
        expect(dep, '--:--');
        expect(arr, '01:00');
      });

      test('chocks-off null + takeoff 00:01 and chocks-on null => both --:--', () {
        final (dep, arr) = FlightTimeFormatter.formatChocksPair(
          chocksOff: null,
          chocksOn: null,
        );
        expect(dep, '--:--');
        expect(arr, '--:--');
      });
    });
  });
}
