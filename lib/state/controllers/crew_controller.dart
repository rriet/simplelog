import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/state/providers/crew_repository_provider.dart';

class CrewController extends Notifier<void> {
  @override
  void build() {}

  Future<void> toggleLock(CrewData item) async {
    final repo = ref.read(crewRepositoryProvider);
    await repo.toggleLock(item);
  }

  Future<void> toggleFavorite(CrewData item) async {
    final repo = ref.read(crewRepositoryProvider);
    await repo.toggleFavorite(item);
  }

  Future<void> delete(CrewData item) async {
    final repo = ref.read(crewRepositoryProvider);
    await repo.delete(item);
  }
}
