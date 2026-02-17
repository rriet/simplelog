import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/state/providers/airport_repository_provider.dart';

class AirportController extends Notifier<void> {
  @override
  void build() {}

  Future<void> toggleLock(Airport item) async {
    final repo = ref.read(airportRepositoryProvider);
    await repo.toggleLock(item);
  }

  Future<void> toggleFavorite(Airport item) async {
    final repo = ref.read(airportRepositoryProvider);
    await repo.toggleFavorite(item);
  }

  Future<void> delete(Airport item) async {
    final repo = ref.read(airportRepositoryProvider);
    await repo.delete(item);
  }
}
