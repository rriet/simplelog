import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/theme/app_tab_bar_styles.dart';
import 'package:simplelog/presentation/database/database_screen.dart';
import 'package:simplelog/presentation/settings/widgets/flight_factoring_settings_card.dart';
import 'package:simplelog/presentation/settings/widgets/pilot_profile_settings_card.dart';
import 'package:simplelog/presentation/settings/widgets/previous_experience_settings_tab.dart';
import 'package:simplelog/presentation/settings/widgets/simulator_default_position_selector.dart';
import 'package:simplelog/presentation/settings/widgets/theme_mode_selector.dart';
import 'package:simplelog/presentation/settings/widgets/time_fields_settings_tab.dart';

/// Root settings screen with tabs for general, database and time-field options.
class SettingsScreen extends ConsumerWidget {
  /// Creates the settings screen widget.
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
                    const SizedBox(height: 12),
                    const PilotProfileSettingsCard(),
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
