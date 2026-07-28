import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/state/providers/update_check_preferences_provider.dart';

/// Switch for enabling/disabling automatic update checks on startup.
///
/// Hidden and forced to `false` on iOS builds.
class UpdateCheckToggle extends ConsumerWidget {
  /// Creates an update check toggle widget.
  const UpdateCheckToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.iOS) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final asyncEnabled = ref.watch(checkForUpdatesProvider);

    return asyncEnabled.when(
      data: (enabled) => SwitchListTile(
        title: Text(l10n.settingsCheckForUpdates),
        value: enabled,
        onChanged: (value) {
          unawaited(
            ref
                .read(checkForUpdatesProvider.notifier)
                .toggle(value: value),
          );
        },
        contentPadding: EdgeInsets.zero,
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
