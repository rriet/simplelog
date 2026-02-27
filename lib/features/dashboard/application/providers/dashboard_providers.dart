import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/repositories/dashboard_repository.dart';
import 'package:simplelog/features/dashboard/domain/dashboard_models.dart';
import 'package:simplelog/state/providers/database_provider.dart';

/// Provides the dashboard repository implementation.
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DashboardRepository(db);
});

/// Streams active limit rules shown in the dashboard.
final dashboardRulesProvider = StreamProvider<List<LimitRule>>((ref) {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.watchRules();
});

/// Streams prebuilt dashboard cards with status and summary information.
final dashboardCardsProvider = StreamProvider<List<DashboardRuleCard>>((ref) {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.watchDashboardCards();
});
