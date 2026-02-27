import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/features/aircraft_types/application/providers/aircraft_type_repository_provider.dart';

/// Thin controller that forwards aircraft-type UI actions to use-cases.
class AircraftTypesController extends Notifier<void> {
  @override
  void build() {}

  /// Toggles lock state for [item].
  Future<void> toggleLock(AircraftType item) async {
    final useCases = ref.read(aircraftTypeUseCasesProvider);
    await useCases.toggleLock(item);
  }

  /// Counts aircraft referencing [typeId].
  Future<int> countAircraftForType(int typeId) async {
    final useCases = ref.read(aircraftTypeUseCasesProvider);
    return useCases.countAircraftForType(typeId);
  }

  /// Deletes [item].
  Future<void> delete(AircraftType item) async {
    final useCases = ref.read(aircraftTypeUseCasesProvider);
    await useCases.delete(item);
  }
}
