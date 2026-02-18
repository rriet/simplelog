import 'package:flutter_test/flutter_test.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/airport_filters.dart';
import 'package:simplelog/data/models/airport_row.dart';
import 'package:simplelog/domain/repositories/airport_repository_contract.dart';
import 'package:simplelog/domain/usecases/airport_use_cases.dart';

void main() {
  group('AirportUseCases', () {
    test('validateCreate rejects ICAO with invalid length', () async {
      final useCases = AirportUseCases(_FakeAirportRepository());
      final result = await useCases.validateCreate(
        AirportsCompanion.insert(
          icao: 'ABC',
          latitude: 0,
          longitude: 0,
          isFavorite: false,
          isLocked: false,
        ),
      );

      expect(result.isValid, isFalse);
      expect(result.message, 'ICAO code must be 4 characters.');
    });

    test('validateDelete reports combined usage', () async {
      final useCases = AirportUseCases(
        _FakeAirportRepository(flightCount: 2, positioningCount: 1),
      );
      final item = Airport(
        id: 1,
        icao: 'KJFK',
        iata: null,
        name: null,
        city: null,
        country: null,
        latitude: 0,
        longitude: 0,
        isFavorite: false,
        isLocked: false,
      );

      final result = await useCases.validateDelete(item);

      expect(result.isValid, isFalse);
      expect(result.message, 'Cannot delete. Airport used in 3 logbook entries.');
    });
  });
}

class _FakeAirportRepository implements AirportRepositoryContract {
  _FakeAirportRepository({
    this.flightCount = 0,
    this.positioningCount = 0,
  });

  final int flightCount;
  final int positioningCount;

  @override
  Future<int> countDuplicateIcao(String icao, int currentId) async =>
      0;

  @override
  Future<int> countFlightsUsingAirport(int airportId) async => flightCount;

  @override
  Future<int> countPositioningsUsingAirport(int airportId) async =>
      positioningCount;

  @override
  Future<int> create(AirportsCompanion companion) async => 1;

  @override
  Future<void> delete(Airport item) async {}

  @override
  Future<void> toggleFavorite(Airport item) async {}

  @override
  Future<void> toggleLock(Airport item) async {}

  @override
  Future<void> update(Airport item) async {}

  @override
  Stream<List<AirportRow>> watchAirports(String query, AirportFilters filters) {
    return const Stream.empty();
  }
}
