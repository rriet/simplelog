import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/models/previous_experience_row.dart';
import 'package:simplelog/data/repositories/previous_experience_repository.dart';
import 'package:simplelog/state/providers/database_provider.dart';

/// Provides the concrete previous-experience repository backed by Drift.
final previousExperienceRepositoryProvider =
    Provider<PreviousExperienceRepository>((ref) {
      final db = ref.watch(databaseProvider);
      return PreviousExperienceRepository(db);
    });
/// Streams all previous-experience rows joined with aircraft type data.
final StreamProvider<List<PreviousExperienceRow>> previousExperiencesProvider =
    StreamProvider.autoDispose<List<PreviousExperienceRow>>((ref) {
      final repo = ref.watch(previousExperienceRepositoryProvider);
      return repo.watchRows();
    });
