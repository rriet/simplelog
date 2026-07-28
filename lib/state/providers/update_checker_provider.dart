import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/services/update_service.dart';
import 'package:simplelog/state/providers/update_check_preferences_provider.dart';

/// Provider that exposes the [UpdateService] singleton.
final updateServiceProvider = Provider<UpdateService>(
  (ref) => UpdateService(),
);

/// Raw result from GitHub. Non-null whenever a newer version exists,
/// even if the user previously skipped it. Use this in the drawer
/// to highlight the version.
final rawUpdateProvider = FutureProvider<UpdateResult?>((ref) async {
  final service = ref.watch(updateServiceProvider);
  final shouldCheck = await ref.watch(checkForUpdatesProvider.future);

  return service.checkForUpdate(checkForUpdates: shouldCheck);
});

/// Filtered result for the startup dialog. Returns `null` when the
/// user has already skipped this version (but [rawUpdateProvider]
/// still returns data so the drawer stays highlighted).
final latestUpdateProvider = FutureProvider<UpdateResult?>((ref) async {
  final update = await ref.watch(rawUpdateProvider.future);
  if (update == null) return null;

  final skipped = await ref.watch(skippedVersionProvider.future);
  if (skipped == update.latestVersion) return null;

  return update;
});
