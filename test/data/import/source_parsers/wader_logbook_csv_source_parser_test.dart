import 'package:flutter_test/flutter_test.dart';
import 'package:simplelog/data/import/normalized_import_models.dart';
import 'package:simplelog/data/import/source_parsers/wader_logbook_csv_source_parser.dart';
import 'package:simplelog/data/import/wader_import_models.dart';
import 'package:simplelog/data/import/wader_import_options.dart';

void main() {
  const parser = WaderLogbookCsvSourceParser();
  const header =
      'isPreviousExperience,isSimulator,flightDate,startTime,takeoffTime,'
      'landingTime,parkingTime,flightNumber,depAirport,arrAirport,'
      'aircraftTailnumber,aircraftType,simType,function,pilotName1,pilotName2,'
      'pilotName3,pilotName4,totalTime,picTime,sicTime,soloTime,dualTime,'
      'picusTime,spicTime,examinerTime,instructorTime,simTraineeTime,'
      'simTrainerTime,crossCountryTime,actualInstrumentTime,'
      'simulatedInstrumentTime,reliefTime,ifrTime,nightTime,dayTakeoffs,'
      'nightTakeoffs,dayLandings,nightLandings,approachType,remarks,'
      'multiEngine,multiPilot,depNotes,depRunway,depProcedure,depTransition,'
      'depThreats,arrNotes,arrRunway,arrProcedure,arrTransition,arrThreats';

  String csv(List<String> lines) => <String>[header, ...lines].join('\n');

  test('parse imports flight rows', () {
    final content = csv(<String>[
      <String>[
        'false,false,2024-12-11,02:53,03:04,05:48,05:53,WN302,KSJC,KDFW,',
        'N445FX,E545,,SIC,Ricardo Felse,SELF,,,180,0,180,0,0,0,0,0,0,0,0,',
        '180,0,0,,180,180,0,1,0,1,,"",,true,"",,,,"","",,,,"",',
      ].join(),
    ]);

    final batch = parser.parse(content);

    expect(batch.records.length, 1);
    expect(batch.errorRows, 0);
    final flight = batch.records.single as NormalizedFlightRecord;
    expect(flight.departureAirport.icao, 'KSJC');
    expect(flight.arrivalAirport.icao, 'KDFW');
    expect(flight.departureDateTime, DateTime.utc(2024, 12, 11, 2, 53));
    expect(flight.arrivalDateTime, DateTime.utc(2024, 12, 11, 5, 53));
    expect(flight.timeSicMinutes, 180);
    expect(flight.timeTotalBlockMinutes, 180);
    expect(flight.aircraft.registration, 'N445FX');
    expect(flight.aircraftType.code, 'E545');
  });

  test('parse imports simulator rows', () {
    final content = csv(<String>[
      <String>[
        'false,true,2022-08-27,00:00,,,04:00,,,,EU-A0255,B77W,,Trainee,,',
        'SELF,,,0,,,,,,,,,240,0,,,,,,,,,,,,"LPC/OPC Day 2",,true,"",,,,"",',
        '"",,,,"",',
      ].join(),
    ]);

    final batch = parser.parse(content);

    expect(batch.records.length, 1);
    final sim = batch.records.single as NormalizedSimulatorRecord;
    expect(sim.startDateTime, DateTime.utc(2022, 8, 27));
    expect(sim.endDateTime, DateTime.utc(2022, 8, 27, 4));
    expect(sim.timeTotal, 240);
    expect(sim.aircraft.isSimulator, isTrue);
    expect(sim.aircraft.registration, 'EU-A0255');
    expect(sim.aircraftType.code, 'B77W');
  });

  test('parse handles overnight arrivals', () {
    final content = csv(<String>[
      <String>[
        'false,false,2024-11-29,23:26,23:33,00:26,00:32,,KSAN,KSBA,N604FX,',
        'E550,,SIC,Kenneth Thering,SELF,,,66,0,66,0,0,0,0,0,0,0,0,66,0,0,',
        ',66,0,0,0,0,0,,"",,true,"",,,,"","",,,,"",',
      ].join(),
    ]);

    final batch = parser.parse(content);
    final flight = batch.records.single as NormalizedFlightRecord;
    expect(flight.departureDateTime, DateTime.utc(2024, 11, 29, 23, 26));
    expect(flight.arrivalDateTime, DateTime.utc(2024, 11, 30, 0, 32));
  });

  test('parse skips rows without airports for flights', () {
    final content = csv(<String>[
      <String>[
        'false,false,2024-01-01,10:00,,,12:00,,,,N12345,B738,,SIC,SELF,,,,',
        '120,0,120,0,0,0,0,0,0,0,0,120,0,0,,120,0,0,0,0,0,,"",,true,"",',
        ',,,,"","",,,,"",',
      ].join(),
    ]);

    final batch = parser.parse(content);

    expect(batch.records, isEmpty);
    expect(batch.skippedRows, 1);
  });

  test('validate returns fixable issues for skipped rows', () {
    final content = csv(<String>[
      <String>[
        'false,false,2024-01-01,10:00,,,12:00,,,,N12345,B738,,SIC,SELF,,,,',
        '120,0,120,0,0,0,0,0,0,0,0,120,0,0,,120,0,0,0,0,0,,"",,true,"",',
        ',,,,"","",,,,"",',
      ].join(),
    ]);

    final issues = parser.validate(content);

    expect(
      issues.map((issue) => issue.association),
      containsAll(<WaderFieldAssociation>[
        WaderFieldAssociation.departureAirport,
        WaderFieldAssociation.arrivalAirport,
      ]),
    );
  });

  test('parse applies review overrides before importing', () {
    final content = csv(<String>[
      <String>[
        'false,false,2024-01-01,10:00,,12:00,,,-,-,N12345,B738,,SIC,SELF,,,',
        ',120,0,120,0,0,0,0,0,0,0,0,120,0,0,,120,0,0,0,0,0,,"",,true,"",',
        ',,,,"","",,,,"",',
      ].join(),
    ]);

    final batch = parser.parse(
      content,
      reviewOptions: const WaderImportReviewOptions(
        valueOverrides: <int, Map<WaderFieldAssociation, String>>{
          2: <WaderFieldAssociation, String>{
            WaderFieldAssociation.departureAirport: 'ksfo',
            WaderFieldAssociation.arrivalAirport: 'klax',
          },
        },
      ),
    );

    expect(batch.records.length, 1);
    final flight = batch.records.single as NormalizedFlightRecord;
    expect(flight.departureAirport.icao, 'KSFO');
    expect(flight.arrivalAirport.icao, 'KLAX');
  });

  test('parse accepts HH:mm duration override for total time', () {
    final content = csv(<String>[
      <String>[
        'false,false,2024-01-01,10:00,,12:00,,,-,-,N12345,B738,,SIC,SELF,,,',
        ',0,0,0,0,0,0,0,0,0,0,0,0,0,0,,0,0,0,0,0,0,,"",,true,"",,,,,"",',
        '"",,,,"",',
      ].join(),
    ]);

    final batch = parser.parse(
      content,
      reviewOptions: const WaderImportReviewOptions(
        valueOverrides: <int, Map<WaderFieldAssociation, String>>{
          2: <WaderFieldAssociation, String>{
            WaderFieldAssociation.departureAirport: 'KSFO',
            WaderFieldAssociation.arrivalAirport: 'KLAX',
            WaderFieldAssociation.totalTime: '01:30',
          },
        },
      ),
    );

    expect(batch.records.length, 1);
    final flight = batch.records.single as NormalizedFlightRecord;
    expect(flight.timeTotalBlockMinutes, 90);
  });

  test('recalculate off keeps CSV total time', () {
    final content = csv(<String>[
      <String>[
        (StringBuffer()
              ..write('false,false,2024-01-01,10:00,,12:00,12:00,,KSFO,KLAX,')
              ..write('N12345,B738,,SIC,SELF,,,,'))
            .toString(),
        '90,0,90,0,0,0,0,0,0,0,0,90,0,0,,90,0,0,0,0,0,,"",,true,"",,,,,"",',
        '"",,,,"",',
      ].join(),
    ]);

    final batch = parser.parse(content);
    final flight = batch.records.single as NormalizedFlightRecord;
    expect(flight.timeTotalBlockMinutes, 90);
  });

  test('recalculate on uses chocks for total time', () {
    final content = csv(<String>[
      <String>[
        (StringBuffer()
              ..write('false,false,2024-01-01,10:00,,12:00,12:00,,KSFO,KLAX,')
              ..write('N12345,B738,,SIC,SELF,,,,'))
            .toString(),
        '90,0,90,0,0,0,0,0,0,0,0,90,0,0,,90,0,0,0,0,0,,"",,true,"",,,,,"",',
        '"",,,,"",',
      ].join(),
    ]);

    final batch = parser.parse(
      content,
      options: const WaderImportOptions(recalculateTotalTime: true),
    );
    final flight = batch.records.single as NormalizedFlightRecord;
    expect(flight.timeTotalBlockMinutes, 120);
  });
}
