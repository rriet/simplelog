import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/models/previous_experience_row.dart';
import 'package:simplelog/data/repositories/previous_experience_repository.dart';
import 'package:simplelog/state/providers/database_provider.dart';

/// Public API documentation.
final previousExperienceRepositoryProvider =
    Provider<PreviousExperienceRepository>((ref) {
      final db = ref.watch(databaseProvider);
      return PreviousExperienceRepository(db);
    });
/// Public API documentation.

/// Public API documentation.
final StreamProvider<List<PreviousExperienceRow>> previousExperiencesProvider =
    StreamProvider.autoDispose<List<PreviousExperienceRow>>((ref) {
      final repo = ref.watch(previousExperienceRepositoryProvider);
      return repo.watchRows();
    });
