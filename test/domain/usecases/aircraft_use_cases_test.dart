import 'package:flutter_test/flutter_test.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/aircraft_row.dart';
import 'package:simplelog/domain/repositories/aircraft_repository_contract.dart';
import 'package:simplelog/domain/usecases/aircraft_use_cases.dart';

void main() {
  group('AircraftUseCases', () {
    test('validateDelete returns locked message for locked aircraft', () async {
      final repo = _FakeAircraftRepository();
      final useCases = AircraftUseCases(repo);
      final item = Aircraft(
        id: 1,
        aircraftTypeId: 1,
        registration: 'N123',
        mtow: 1000,
        isSimulator: false,
        isFavorite: false,
        isLocked: true,
      );

      final result = await useCases.validateDelete(item);

      expect(result.isValid, isFalse);
      expect(result.message, 'This aircraft is locked.');
    });

    test('validateDelete returns usage message for simulator', () async {
      final repo = _FakeAircraftRepository(
        flightCount: 0,
        simCount: 3,
      );
      final useCases = AircraftUseCases(repo);
      final item = Aircraft(
        id: 1,
        aircraftTypeId: 1,
        registration: 'SIM',
        mtow: 1000,
        isSimulator: true,
        isFavorite: false,
        isLocked: false,
      );

      final result = await useCases.validateDelete(item);

      expect(result.isValid, isFalse);
      expect(result.message, 'Simulator used in 3 training sessions.');
    });
  });
}

class _FakeAircraftRepository implements AircraftRepositoryContract {
  _FakeAircraftRepository({
    this.flightCount = 0,
    this.simCount = 0,
  });

  final int flightCount;
  final int simCount;

  @override
  Future<int> countDuplicateRegistration(String registration, int currentId) async =>
      0;

  @override
  Future<int> countFlightsForAircraft(int aircraftId) async => flightCount;

  @override
  Future<int> countSimSessionsForAircraft(int aircraftId) async => simCount;

  @override
  Future<int> create(AircraftsCompanion companion) async => 1;

  @override
  Future<void> delete(Aircraft item) async {}

  @override
  Future<void> toggleFavorite(Aircraft item) async {}

  @override
  Future<void> toggleLock(Aircraft item) async {}

  @override
  Future<void> update(Aircraft item) async {}

  @override
  Stream<List<AircraftRow>> watchAircraft(String query) {
    return const Stream.empty();
  }

  @override
  Future<List<AircraftRow>> fetchAircraftByType(int aircraftTypeId) async {
    return const [];
  }
}
