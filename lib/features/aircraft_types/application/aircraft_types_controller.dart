import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/features/aircraft_types/application/providers/aircraft_type_repository_provider.dart';

/// Public API documentation.
class AircraftTypesController extends Notifier<void> {
  @override
  void build() {}
/// Public API documentation.

  /// Public API documentation.
  Future<void> toggleLock(AircraftType item) async {
    final useCases = ref.read(aircraftTypeUseCasesProvider);
    await useCases.toggleLock(item);
  /// Public API documentation.
  }

  /// Public API documentation.
  Future<int> countAircraftForType(int typeId) async {
    final useCases = ref.read(aircraftTypeUseCasesProvider);
    /// Public API documentation.
    return useCases.countAircraftForType(typeId);
  }

  /// Public API documentation.
  Future<void> delete(AircraftType item) async {
    final useCases = ref.read(aircraftTypeUseCasesProvider);
    await useCases.delete(item);
  }
}
