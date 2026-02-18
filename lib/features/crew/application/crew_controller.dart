import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/features/crew/application/providers/crew_repository_provider.dart';

class CrewController extends Notifier<void> {
  @override
  void build() {}

  Future<void> toggleLock(CrewData item) async {
    final useCases = ref.read(crewUseCasesProvider);
    await useCases.toggleLock(item);
  }

  Future<void> toggleFavorite(CrewData item) async {
    final useCases = ref.read(crewUseCasesProvider);
    await useCases.toggleFavorite(item);
  }

  Future<void> delete(CrewData item) async {
    final useCases = ref.read(crewUseCasesProvider);
    await useCases.delete(item);
  }
}
