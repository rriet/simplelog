import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';

import 'widgets/theme_mode_selector.dart';
import 'widgets/seed_data_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.settingsAppearance,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        const ThemeModeSelector(),
        const SizedBox(height: 24),
        Text(
          l10n.settingsDeveloper,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        const SeedDataButton(),
      ],
    );
  }
}
