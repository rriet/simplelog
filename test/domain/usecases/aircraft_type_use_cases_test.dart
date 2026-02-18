import 'package:flutter_test/flutter_test.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/aircraft_category.dart';
import 'package:simplelog/data/database/enums/engine_type.dart';
import 'package:simplelog/data/models/aircraft_type_row.dart';
import 'package:simplelog/domain/repositories/aircraft_type_repository_contract.dart';
import 'package:simplelog/domain/usecases/aircraft_type_use_cases.dart';

void main() {
  test('normalizeCompanion uses code as default family and longName', () {
    final useCases = AircraftTypeUseCases(_FakeAircraftTypeRepository());
    final normalized = useCases.normalizeCompanion(
      AircraftTypesCompanion.insert(
        code: ' B738 ',
        family: '',
        longName: '',
        category: AircraftCategory.landplane,
        engineType: EngineType.jet,
        mtow: 79000,
        engineCount: 2,
        multiPilot: true,
        complex: true,
        efis: true,
        highPerformance: true,
        isLocked: false,
      ),
    );

    expect(normalized.code.value, 'B738');
    expect(normalized.family.value, 'B738');
    expect(normalized.longName.value, 'B738');
  });
}

class _FakeAircraftTypeRepository implements AircraftTypeRepositoryContract {
  @override
  Future<int> countAircraftForType(int typeId) async => 0;

  @override
  Future<int> countDuplicateCodes(String code, int currentId) async => 0;

  @override
  Future<int> create(AircraftTypesCompanion companion) async => 1;

  @override
  Future<void> delete(AircraftType item) async {}

  @override
  Future<void> toggleLock(AircraftType item) async {}

  @override
  Future<void> update(AircraftType item) async {}

  @override
  Stream<List<AircraftTypeRow>> watchAircraftTypes(String query) {
    return const Stream.empty();
  }

  @override
  Stream<List<String>> watchFamilies() {
    return const Stream.empty();
  }
}
