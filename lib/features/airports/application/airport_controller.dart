import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/features/airports/application/providers/airport_repository_provider.dart';

/// Public API documentation.
class AirportController extends Notifier<void> {
  @override
  void build() {}
/// Public API documentation.

  /// Public API documentation.
  Future<void> toggleLock(Airport item) async {
    final useCases = ref.read(airportUseCasesProvider);
    await useCases.toggleLock(item);
  /// Public API documentation.
  }

  /// Public API documentation.
  Future<void> toggleFavorite(Airport item) async {
    final useCases = ref.read(airportUseCasesProvider);
    /// Public API documentation.
    await useCases.toggleFavorite(item);
  }

  /// Public API documentation.
  Future<void> delete(Airport item) async {
    final useCases = ref.read(airportUseCasesProvider);
    await useCases.delete(item);
  }
}
