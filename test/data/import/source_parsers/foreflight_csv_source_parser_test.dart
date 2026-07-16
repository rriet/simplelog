import 'package:flutter_test/flutter_test.dart';
import 'package:simplelog/data/import/foreflight_import_options.dart';
import 'package:simplelog/data/import/import_source_dispatcher.dart';
import 'package:simplelog/data/import/normalized_import_models.dart';
import 'package:simplelog/data/import/source_parsers/foreflight_csv_source_parser.dart';
import 'package:simplelog/data/import/unified_import_options.dart';

void main() {
  const parser = ForeFlightCsvSourceParser();
  const options = ForeFlightImportOptions(
    unified: UnifiedImportOptions(
      recalculateTotalTime: false,
      recalculateNightTime: false,
      recalculateTakeoffLanding: false,
      recalculateCrossCountry: false,
      recalculateIfrTime: false,
      overrideAirportOnConflict: false,
      overrideAircraftOnConflict: false,
      overrideTypeOnConflict: false,
    ),
  );

  test('dispatcher recognizes ForeFlight two-table CSV', () {
    expect(
      const ImportSourceDispatcher().detectCsv(_decimalCsv),
      ImportSourceKind.foreFlightCsv,
    );
  });

  test('parses aircraft metadata and decimal flight durations', () {
    final batch = parser.parse(_decimalCsv, options: options);
    final flight = batch.records.single as NormalizedFlightRecord;

    expect(flight.aircraft.registration, 'N12345');
    expect(flight.aircraftType.code, 'C172');
    expect(flight.aircraftType.manufacturer, 'Cessna');
    expect(flight.aircraftType.longName, '172S');
    expect(flight.timeBlockMinutes, 90);
    expect(flight.timePicMinutes, 90);
    expect(flight.departureDateTime, DateTime.utc(2026, 7, 15, 23, 30));
    expect(flight.arrivalDateTime, DateTime.utc(2026, 7, 16, 1));
  });

  test('accepts HH:MM duration values', () {
    final batch = parser.parse(
      _decimalCsv.replaceFirst(',1.5,1.5,', ',01:30,01:30,'),
      options: options,
    );
    final flight = batch.records.single as NormalizedFlightRecord;
    expect(flight.timeBlockMinutes, 90);
    expect(flight.timePicMinutes, 90);
  });

  test('reports missing airport through shared conflict model', () {
    final issues = parser.validate(
      _decimalCsv.replaceFirst('KJFK,KBOS', ',KBOS'),
      options: options,
      existingAirportCodes: const {'KJFK', 'KBOS'},
    );
    expect(issues, hasLength(1));
    expect(issues.single.currentValue, isEmpty);
  });
}

const _decimalCsv = '''
ForeFlight Logbook Import,This row is required for importing into ForeFlight.

Aircraft Table
AircraftID,TypeCode,Year,Make,Model,GearType,EngineType,equipType (FAA),aircraftClass (FAA),complexAircraft (FAA),taa (FAA),highPerformance (FAA),pressurized (FAA)
N12345,C172,2020,Cessna,172S,fixed_tricycle,Piston,aircraft,airplane_single_engine_land,FALSE,TRUE,TRUE,FALSE

Flights Table
Date,AircraftID,From,To,TimeOut,TimeOff,TimeOn,TimeIn,TotalTime,PIC,SIC,Night,CrossCountry,PICUS,IFR,Distance,ActualInstrument,SimulatedInstrument,DualGiven,DualReceived,SimulatedFlight,PilotComments,InstructorComments,Route,DayTakeoffs,DayLandingsFullStop,NightTakeoffs,NightLandingsFullStop,Approach1,Approach2,Approach3,Approach4,Approach5,Approach6
2026-07-15,N12345,KJFK,KBOS,23:30,23:36,00:54,01:00,1.5,1.5,0,0.5,1.5,0,0.2,187,0.2,0,0,0,0,PF,,DCT,1,1,0,0,1;ILS RWY 04R;;;;;
''';
