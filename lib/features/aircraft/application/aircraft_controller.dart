import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/features/aircraft/application/providers/aircraft_repository_provider.dart';

/// Thin controller that forwards aircraft UI actions to use-cases.
class AircraftController extends Notifier<void> {
  @override
  void build() {}

  /// Toggles lock state for [item].
  Future<void> toggleLock(Aircraft item) async {
    final useCases = ref.read(aircraftUseCasesProvider);
    await useCases.toggleLock(item);
  }

  /// Toggles favorite state for [item].
  Future<void> toggleFavorite(Aircraft item) async {
    final useCases = ref.read(aircraftUseCasesProvider);
    await useCases.toggleFavorite(item);
  }

  /// Deletes [item].
  Future<void> delete(Aircraft item) async {
    final useCases = ref.read(aircraftUseCasesProvider);
    await useCases.delete(item);
  }
}
