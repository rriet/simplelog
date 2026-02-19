import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';

import 'widgets/theme_mode_selector.dart';
import 'widgets/seed_data_button.dart';
import 'widgets/simulator_default_position_selector.dart';
import 'widgets/flight_takeoff_landing_switch.dart';
import 'widgets/time_fields_settings_tab.dart';
import 'widgets/previous_experience_settings_tab.dart';

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
            tabs: [
              Tab(text: 'General'),
              Tab(text: 'Experience'),
              Tab(text: 'Time Fields'),
              Tab(text: 'Developer'),
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
                    const FlightTakeoffLandingSwitch(),
                  ],
                ),
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
