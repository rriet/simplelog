import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/state/providers/aircraft_type_repository_provider.dart';

class AircraftTypesController extends Notifier<void> {
  @override
  void build() {}

  Future<void> toggleLock(AircraftType item) async {
    final repo = ref.read(aircraftTypeRepositoryProvider);
    await repo.toggleLock(item);
  }

  Future<int> countAircraftForType(int typeId) async {
    final repo = ref.read(aircraftTypeRepositoryProvider);
    return repo.countAircraftForType(typeId);
  }

  Future<void> delete(AircraftType item) async {
    final repo = ref.read(aircraftTypeRepositoryProvider);
    await repo.delete(item);
  }
}
