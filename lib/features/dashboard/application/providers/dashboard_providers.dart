import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/repositories/dashboard_repository.dart';
import 'package:simplelog/features/dashboard/domain/dashboard_models.dart';
import 'package:simplelog/state/providers/database_provider.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DashboardRepository(db);
});

final dashboardRulesProvider = StreamProvider<List<LimitRule>>((ref) {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.watchRules();
});

final dashboardCardsProvider = StreamProvider<List<DashboardRuleCard>>((ref) {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.watchDashboardCards();
});
