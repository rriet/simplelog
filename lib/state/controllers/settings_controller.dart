import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/seed/test_data.dart';
import 'package:simplelog/state/providers/database_provider.dart';
import 'package:simplelog/state/providers/theme_mode_provider.dart';

class SettingsController extends Notifier<void> {
  @override
  void build() {}

  void setThemeMode(AppThemeMode mode) {
    ref.read(themeModeProvider.notifier).state = mode;
  }

  Future<void> seedTestData() async {
    final db = ref.read(databaseProvider);
    await db.seedTestData();
  }
}
