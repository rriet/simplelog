import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/features/airports/application/providers/airport_repository_provider.dart';

/// Riverpod controller that exposes airport mutation operations to the UI.
class AirportController extends Notifier<void> {
  @override
  void build() {}

  /// Toggles the `isLocked` flag for the given [item].
  Future<void> toggleLock(Airport item) async {
    final useCases = ref.read(airportUseCasesProvider);
    await useCases.toggleLock(item);
  }

  /// Toggles the `isFavorite` flag for the given [item].
  Future<void> toggleFavorite(Airport item) async {
    final useCases = ref.read(airportUseCasesProvider);
    await useCases.toggleFavorite(item);
  }

  /// Deletes [item] from the logbook.
  Future<void> delete(Airport item) async {
    final useCases = ref.read(airportUseCasesProvider);
    await useCases.delete(item);
  }
}
