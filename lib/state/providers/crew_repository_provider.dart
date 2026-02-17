import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/models/crew_row.dart';
import 'package:simplelog/data/repositories/crew_repository.dart';
import 'package:simplelog/state/providers/database_provider.dart';

final crewRepositoryProvider = Provider<CrewRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CrewRepository(db);
});

final crewProvider =
    StreamProvider.autoDispose.family<List<CrewRow>, String>(
  (ref, query) {
    final repo = ref.watch(crewRepositoryProvider);
    return repo.watchCrew(query);
  },
);
