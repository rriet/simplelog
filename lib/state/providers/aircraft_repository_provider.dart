import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/models/aircraft_row.dart';
import 'package:simplelog/data/repositories/aircraft_repository.dart';
import 'package:simplelog/state/providers/database_provider.dart';

final aircraftRepositoryProvider = Provider<AircraftRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return AircraftRepository(db);
});

final aircraftProvider =
    StreamProvider.autoDispose.family<List<AircraftRow>, String>(
  (ref, query) {
    final repo = ref.watch(aircraftRepositoryProvider);
    return repo.watchAircraft(query);
  },
);
