import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';

import 'package:simplelog/state/providers/settings_controller_provider.dart';

class SeedDataButton extends ConsumerWidget {
  const SeedDataButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return FilledButton.icon(
      onPressed: () async {
        await ref.read(settingsControllerProvider.notifier).seedTestData();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.seedDataDone)),
          );
        }
      },
      icon: const Icon(Icons.auto_awesome),
      label: Text(l10n.seedTestData),
    );
  }
}
