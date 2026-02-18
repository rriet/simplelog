import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/features/airports/application/providers/airport_repository_provider.dart';

class AirportController extends Notifier<void> {
  @override
  void build() {}

  Future<void> toggleLock(Airport item) async {
    final useCases = ref.read(airportUseCasesProvider);
    await useCases.toggleLock(item);
  }

  Future<void> toggleFavorite(Airport item) async {
    final useCases = ref.read(airportUseCasesProvider);
    await useCases.toggleFavorite(item);
  }

  Future<void> delete(Airport item) async {
    final useCases = ref.read(airportUseCasesProvider);
    await useCases.delete(item);
  }
}
