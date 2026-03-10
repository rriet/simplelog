import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/models/reports_models.dart';
import 'package:simplelog/features/reports/presentation/providers/reports_preferences_provider.dart';
import 'package:simplelog/features/reports/presentation/providers/reports_repository_provider.dart';

/// App-start prewarm for reports/batch query paths to reduce first-action lag.
final reportsBatchPrewarmProvider = FutureProvider<void>((ref) async {
  final repo = ref.read(reportsRepositoryProvider);
  final runtimeQuery = ref.read(reportsRuntimeQueryProvider);
  final eventTypes = ref.read(reportsEventTypesProvider);
  final includePreviousExperience = ref.read(includePreviousExperienceProvider);
  if (!eventTypes.flights) return;
  if (runtimeQuery.filters.isEmpty) {
    await repo.loadFlightsForAnalysis(
      from: runtimeQuery.from,
      to: runtimeQuery.to,
    );
    return;
  }
  await repo.load(
    ReportsQuery(
      from: runtimeQuery.from,
      to: runtimeQuery.to,
      includePreviousExperience: includePreviousExperience,
      filterMatchMode: runtimeQuery.matchMode,
      filters: runtimeQuery.filters,
    ),
  );
});
