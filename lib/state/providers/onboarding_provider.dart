import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/user_settings_json.dart';
import 'package:simplelog/state/providers/database_provider.dart';

/// JSON key used to persist onboarding completion state.
const onboardingCompletedKey = 'onboarding_completed';

/// Persists and exposes whether onboarding has been completed.
class OnboardingNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final db = ref.read(databaseProvider);
    final store = UserSettingsJsonStore(db);
    return loadSettingWithLegacy<bool>(
      store: store,
      key: onboardingCompletedKey,
      fallback: false,
      parse: (raw) => raw is bool ? raw : null,
      encode: (value) => value,
    );
  }

  /// Marks onboarding as completed and persists it.
  Future<void> completeOnboarding() async {
    state = const AsyncLoading<bool>();
    final db = ref.read(databaseProvider);
    final store = UserSettingsJsonStore(db);
    state = await AsyncValue.guard(() async {
      await store.patch((settings) {
        settings[onboardingCompletedKey] = true;
      });
      return true;
    });
  }
}

/// Provider for onboarding completion state.
final onboardingCompletedProvider =
    AsyncNotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);
