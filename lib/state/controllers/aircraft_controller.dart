import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/state/providers/aircraft_repository_provider.dart';

class AircraftController extends Notifier<void> {
  @override
  void build() {}

  Future<void> toggleLock(Aircraft item) async {
    final repo = ref.read(aircraftRepositoryProvider);
    await repo.toggleLock(item);
  }

  Future<void> toggleFavorite(Aircraft item) async {
    final repo = ref.read(aircraftRepositoryProvider);
    await repo.toggleFavorite(item);
  }

  Future<void> delete(Aircraft item) async {
    final repo = ref.read(aircraftRepositoryProvider);
    await repo.delete(item);
  }
}
