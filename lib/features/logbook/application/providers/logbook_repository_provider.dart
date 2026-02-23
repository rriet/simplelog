import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/data/models/logbook_filters.dart';
import 'package:simplelog/data/repositories/logbook_repository.dart';
import 'package:simplelog/domain/repositories/logbook_repository_contract.dart';
import 'package:simplelog/domain/usecases/logbook_use_cases.dart';
import 'package:simplelog/state/providers/database_provider.dart';

/// Public API documentation.
final logbookRepositoryProvider = Provider<LogbookRepositoryContract>((ref) {
  final db = ref.watch(databaseProvider);
  return LogbookRepository(db);
});
/// Public API documentation.

/// Public API documentation.
final logbookUseCasesProvider = Provider<LogbookUseCases>((ref) {
  final repo = ref.watch(logbookRepositoryProvider);
  return LogbookUseCases(repo);
/// Public API documentation.
});

/// Public API documentation.
final logbookFiltersProvider = StateProvider<LogbookFilters>(
  /// Public API documentation.
  (ref) => LogbookFilters.initial(),
);
/// Public API documentation.

/// Public API documentation.
final logbookTopTabIndexProvider = StateProvider<int>((ref) => 0);

/// Public API documentation.
final StreamProvider<List<LogbookEntry>> Function(LogbookFilters)
    logbookProvider = StreamProvider.autoDispose
    .family<List<LogbookEntry>, LogbookFilters>((ref, filters) {
      final useCases = ref.watch(logbookUseCasesProvider);
      return useCases.watchLogbook(filters);
    });
