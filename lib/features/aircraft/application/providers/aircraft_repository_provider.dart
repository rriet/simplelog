import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/models/aircraft_row.dart';
import 'package:simplelog/data/repositories/aircraft_repository.dart';
import 'package:simplelog/domain/repositories/aircraft_repository_contract.dart';
import 'package:simplelog/domain/usecases/aircraft_use_cases.dart';
import 'package:simplelog/state/providers/database_provider.dart';

/// Public API documentation.
final aircraftRepositoryProvider = Provider<AircraftRepositoryContract>((ref) {
  final db = ref.watch(databaseProvider);
  return AircraftRepository(db);
});
/// Public API documentation.

/// Public API documentation.
final aircraftUseCasesProvider = Provider<AircraftUseCases>((ref) {
  final repo = ref.watch(aircraftRepositoryProvider);
  return AircraftUseCases(repo);
/// Public API documentation.
});

/// Public API documentation.
final StreamProvider<List<AircraftRow>> Function(String) aircraftProvider =
    StreamProvider.autoDispose
        .family<List<AircraftRow>, String>(
  (ref, query) {
    final useCases = ref.watch(aircraftUseCasesProvider);
    return useCases.watchAircraft(query);
  },
);
