import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/models/aircraft_type_row.dart';
import 'package:simplelog/data/repositories/aircraft_type_repository.dart';
import 'package:simplelog/domain/repositories/aircraft_type_repository_contract.dart';
import 'package:simplelog/domain/usecases/aircraft_type_use_cases.dart';
import 'package:simplelog/state/providers/database_provider.dart';

final aircraftTypeRepositoryProvider =
    Provider<AircraftTypeRepositoryContract>((ref) {
  final db = ref.watch(databaseProvider);
  return AircraftTypeRepository(db);
});

final aircraftTypeUseCasesProvider = Provider<AircraftTypeUseCases>((ref) {
  final repo = ref.watch(aircraftTypeRepositoryProvider);
  return AircraftTypeUseCases(repo);
});

final aircraftTypesProvider =
    StreamProvider.family<List<AircraftTypeRow>, String>(
  (ref, query) {
    final useCases = ref.watch(aircraftTypeUseCasesProvider);
    return useCases.watchAircraftTypes(query);
  },
);

final aircraftTypeFamiliesProvider = StreamProvider<List<String>>((ref) {
  final useCases = ref.watch(aircraftTypeUseCasesProvider);
  return useCases.watchFamilies();
});
