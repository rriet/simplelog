import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/theme/app_tab_bar_styles.dart';

import 'widgets/theme_mode_selector.dart';
import 'widgets/seed_data_button.dart';
import 'widgets/simulator_default_position_selector.dart';
import 'widgets/flight_factoring_settings_card.dart';
import 'widgets/time_fields_settings_tab.dart';
import 'widgets/previous_experience_settings_tab.dart';
import '../database/database_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _tabLabels = [
    'General',
    'Database',
    'Experience',
    'Time Fields',
    'Developer',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              const minTabWidth = 120.0;
              final targetWidth = (constraints.maxWidth / _tabLabels.length)
                  .clamp(minTabWidth, double.infinity);
              return TabBar(
                isScrollable: AppTabBarStyles.isScrollable,
                tabAlignment: AppTabBarStyles.tabAlignment,
                labelPadding: AppTabBarStyles.labelPadding,
                tabs: [
                  for (final label in _tabLabels)
                    Tab(
                      child: SizedBox(
                        width: targetWidth,
                        child: Center(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Expanded(
            child: TabBarView(
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      l10n.settingsAppearance,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    const ThemeModeSelector(),
                    const SizedBox(height: 12),
                    const SimulatorDefaultPositionSelector(),
                    const SizedBox(height: 12),
                    const FlightFactoringSettingsCard(),
                  ],
                ),
                const DatabaseScreen(),
                const PreviousExperienceSettingsTab(),
                const TimeFieldsSettingsTab(),
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      l10n.settingsDeveloper,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const SeedDataButton(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
