import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/features/crew/application/providers/crew_repository_provider.dart';

/// Public API documentation.
class CrewController extends Notifier<void> {
  @override
  void build() {}
/// Public API documentation.

  /// Public API documentation.
  Future<void> toggleLock(CrewData item) async {
    final useCases = ref.read(crewUseCasesProvider);
    await useCases.toggleLock(item);
  /// Public API documentation.
  }

  /// Public API documentation.
  Future<void> toggleFavorite(CrewData item) async {
    final useCases = ref.read(crewUseCasesProvider);
    /// Public API documentation.
    await useCases.toggleFavorite(item);
  }

  /// Public API documentation.
  Future<void> delete(CrewData item) async {
    final useCases = ref.read(crewUseCasesProvider);
    await useCases.delete(item);
  }
}
