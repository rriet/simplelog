import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/models/aircraft_type_row.dart';
import 'package:simplelog/data/repositories/aircraft_type_repository.dart';
import 'package:simplelog/state/providers/database_provider.dart';

final aircraftTypeRepositoryProvider = Provider<AircraftTypeRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return AircraftTypeRepository(db);
});

final aircraftTypesProvider =
    StreamProvider.autoDispose.family<List<AircraftTypeRow>, String>(
  (ref, query) {
    final repo = ref.watch(aircraftTypeRepositoryProvider);
    return repo.watchAircraftTypes(query);
  },
);

final aircraftTypeFamiliesProvider =
    StreamProvider.autoDispose<List<String>>((ref) {
  final repo = ref.watch(aircraftTypeRepositoryProvider);
  return repo.watchFamilies();
});
