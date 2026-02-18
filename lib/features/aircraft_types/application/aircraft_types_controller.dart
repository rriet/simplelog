import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/features/aircraft_types/application/providers/aircraft_type_repository_provider.dart';

class AircraftTypesController extends Notifier<void> {
  @override
  void build() {}

  Future<void> toggleLock(AircraftType item) async {
    final useCases = ref.read(aircraftTypeUseCasesProvider);
    await useCases.toggleLock(item);
  }

  Future<int> countAircraftForType(int typeId) async {
    final useCases = ref.read(aircraftTypeUseCasesProvider);
    return useCases.countAircraftForType(typeId);
  }

  Future<void> delete(AircraftType item) async {
    final useCases = ref.read(aircraftTypeUseCasesProvider);
    await useCases.delete(item);
  }
}
