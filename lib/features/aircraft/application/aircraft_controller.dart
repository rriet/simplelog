import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/features/aircraft/application/providers/aircraft_repository_provider.dart';

/// Public API documentation.
class AircraftController extends Notifier<void> {
  @override
  void build() {}
/// Public API documentation.

  /// Public API documentation.
  Future<void> toggleLock(Aircraft item) async {
    final useCases = ref.read(aircraftUseCasesProvider);
    await useCases.toggleLock(item);
  /// Public API documentation.
  }

  /// Public API documentation.
  Future<void> toggleFavorite(Aircraft item) async {
    final useCases = ref.read(aircraftUseCasesProvider);
    /// Public API documentation.
    await useCases.toggleFavorite(item);
  }

  /// Public API documentation.
  Future<void> delete(Aircraft item) async {
    final useCases = ref.read(aircraftUseCasesProvider);
    await useCases.delete(item);
  }
}
