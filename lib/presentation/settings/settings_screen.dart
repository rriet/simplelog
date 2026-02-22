import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/theme/app_tab_bar_styles.dart';

import 'widgets/theme_mode_selector.dart';
import 'widgets/simulator_default_position_selector.dart';
import 'widgets/flight_factoring_settings_card.dart';
import 'widgets/time_fields_settings_tab.dart';
import 'widgets/previous_experience_settings_tab.dart';
import '../database/database_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            isScrollable: AppTabBarStyles.isScrollable,
            tabAlignment: AppTabBarStyles.tabAlignment,
            labelPadding: AppTabBarStyles.labelPadding,
            tabs: [
              Tab(text: 'General'),
              Tab(text: 'Database'),
              Tab(text: 'Experience'),
              Tab(text: 'Time Fields'),
            ],
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
