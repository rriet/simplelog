import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/state/providers/settings_controller_provider.dart';
import 'package:simplelog/state/providers/theme_mode_provider.dart';

/// Public API documentation.
class ThemeModeSelector extends ConsumerWidget {
  /// Public API documentation.
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final useWrap = constraints.maxWidth < 320;
        final options = [
          (AppThemeMode.system, l10n.themeSystem),
          (AppThemeMode.light, l10n.themeLight),
          (AppThemeMode.dark, l10n.themeDark),
        ];

        if (useWrap) {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in options)
                ChoiceChip(
                  label: Text(option.$2),
                  selected: themeMode == option.$1,
                  onSelected: (_) {
                    ref
                        .read(settingsControllerProvider.notifier)
                        .themeMode = option.$1;
                  },
                ),
            ],
          );
        }

        return SegmentedButton<AppThemeMode>(
          segments: [
            for (final option in options)
              ButtonSegment(
                value: option.$1,
                label: Text(option.$2),
              ),
          ],
          selected: {themeMode},
          showSelectedIcon: false,
          onSelectionChanged: (selection) {
            if (selection.isNotEmpty) {
              ref
                  .read(settingsControllerProvider.notifier)
                  .themeMode = selection.first;
            }
          },
        );
      },
    );
  }
}
