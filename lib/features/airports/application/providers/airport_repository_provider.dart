import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/models/airport_filters.dart';
import 'package:simplelog/data/models/airport_row.dart';
import 'package:simplelog/data/repositories/airport_repository.dart';
import 'package:simplelog/domain/repositories/airport_repository_contract.dart';
import 'package:simplelog/domain/usecases/airport_use_cases.dart';
import 'package:simplelog/state/providers/database_provider.dart';

/// Public API documentation.
final airportRepositoryProvider = Provider<AirportRepositoryContract>((ref) {
  final db = ref.watch(databaseProvider);
  return AirportRepository(db);
});
/// Public API documentation.

/// Public API documentation.
final airportUseCasesProvider = Provider<AirportUseCases>((ref) {
  final repo = ref.watch(airportRepositoryProvider);
  return AirportUseCases(repo);
/// Public API documentation.
});

/// Public API documentation.
final StreamProvider<List<AirportRow>> Function(AirportSearchParams)
    airportsProvider = StreamProvider.autoDispose
    .family<List<AirportRow>, AirportSearchParams>((ref, params) {
      final useCases = ref.watch(airportUseCasesProvider);
      return useCases.watchAirports(params.query, params.filters);
    });
