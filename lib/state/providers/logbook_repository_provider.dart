import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/data/models/logbook_filters.dart';
import 'package:simplelog/data/repositories/logbook_repository.dart';
import 'package:simplelog/state/providers/database_provider.dart';

final logbookRepositoryProvider = Provider<LogbookRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LogbookRepository(db);
});

final logbookFiltersProvider = StateProvider<LogbookFilters>(
  (ref) => LogbookFilters.initial(),
);

final logbookProvider =
    StreamProvider.autoDispose.family<List<LogbookEntry>, LogbookFilters>(
  (ref, filters) {
    final repo = ref.watch(logbookRepositoryProvider);
    return repo.watchLogbook(filters);
  },
);
