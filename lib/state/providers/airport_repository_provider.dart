import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/models/airport_filters.dart';
import 'package:simplelog/data/models/airport_row.dart';
import 'package:simplelog/data/repositories/airport_repository.dart';
import 'package:simplelog/state/providers/database_provider.dart';

final airportRepositoryProvider = Provider<AirportRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return AirportRepository(db);
});

final airportsProvider = StreamProvider.autoDispose
    .family<List<AirportRow>, AirportSearchParams>(
  (ref, params) {
    final repo = ref.watch(airportRepositoryProvider);
    return repo.watchAirports(params.query, params.filters);
  },
);
