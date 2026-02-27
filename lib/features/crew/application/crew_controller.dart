import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/features/crew/application/providers/crew_repository_provider.dart';

/// Thin controller that forwards crew UI actions to use-cases.
class CrewController extends Notifier<void> {
  @override
  void build() {}

  /// Toggles lock state for [item].
  Future<void> toggleLock(CrewData item) async {
    final useCases = ref.read(crewUseCasesProvider);
    await useCases.toggleLock(item);
  }

  /// Toggles favorite state for [item].
  Future<void> toggleFavorite(CrewData item) async {
    final useCases = ref.read(crewUseCasesProvider);
    await useCases.toggleFavorite(item);
  }

  /// Deletes [item].
  Future<void> delete(CrewData item) async {
    final useCases = ref.read(crewUseCasesProvider);
    await useCases.delete(item);
  }
}
