import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/models/crew_row.dart';
import 'package:simplelog/data/repositories/crew_repository.dart';
import 'package:simplelog/domain/repositories/crew_repository_contract.dart';
import 'package:simplelog/domain/usecases/crew_use_cases.dart';
import 'package:simplelog/state/providers/database_provider.dart';

final crewRepositoryProvider = Provider<CrewRepositoryContract>((ref) {
  final db = ref.watch(databaseProvider);
  return CrewRepository(db);
});

final crewUseCasesProvider = Provider<CrewUseCases>((ref) {
  final repo = ref.watch(crewRepositoryProvider);
  return CrewUseCases(repo);
});

final crewProvider =
    StreamProvider.autoDispose.family<List<CrewRow>, String>(
  (ref, query) {
    final useCases = ref.watch(crewUseCasesProvider);
    return useCases.watchCrew(query);
  },
);
