import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/data/models/logbook_filters.dart';
import 'package:simplelog/data/repositories/logbook_repository.dart';
import 'package:simplelog/domain/repositories/logbook_repository_contract.dart';
import 'package:simplelog/domain/usecases/logbook_use_cases.dart';
import 'package:simplelog/state/providers/database_provider.dart';

/// Provides the concrete logbook repository implementation.
final logbookRepositoryProvider = Provider<LogbookRepositoryContract>((ref) {
  final db = ref.watch(databaseProvider);
  return LogbookRepository(db);
});

/// Provides logbook use-cases built on top of repository provider.
final logbookUseCasesProvider = Provider<LogbookUseCases>((ref) {
  final repo = ref.watch(logbookRepositoryProvider);
  return LogbookUseCases(repo);
});

/// Current in-memory logbook filter selection.
final logbookFiltersProvider = StateProvider<LogbookFilters>(
  (ref) => LogbookFilters.initial(),
);

/// Selected top-tab index in logbook UI.
final logbookTopTabIndexProvider = StateProvider<int>((ref) => 0);

/// Family provider that streams entries for a specific [LogbookFilters].
final StreamProvider<List<LogbookEntry>> Function(LogbookFilters)
    logbookProvider = StreamProvider.autoDispose
    .family<List<LogbookEntry>, LogbookFilters>((ref, filters) {
      final useCases = ref.watch(logbookUseCasesProvider);
      return useCases.watchLogbook(filters);
    });
