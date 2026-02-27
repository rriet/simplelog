import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/theme/app_tab_bar_styles.dart';
import 'package:simplelog/presentation/database/database_screen.dart';
import 'package:simplelog/presentation/settings/widgets/flight_factoring_settings_card.dart';
import 'package:simplelog/presentation/settings/widgets/flight_takeoff_landing_switch.dart';
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
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                          'General Settings',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Appearance, defaults, and profile preferences.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 16),
                        const _SettingsSectionCard(
                          title: 'Appearance',
                          subtitle: 'Theme and display preferences.',
                          children: [
                            ThemeModeSelector(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const _SettingsSectionCard(
                          title: 'Defaults',
                          subtitle:
                              'Default values used when creating entries.',
                          children: [
                            FlightTakeoffLandingSwitch(),
                            SizedBox(height: 8),
                            SimulatorDefaultPositionSelector(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const _SettingsSectionCard(
                          title: 'Calculation Rules',
                          subtitle: 'Automatic time and threshold rules.',
                          children: [
                            FlightFactoringSettingsCard(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const _SettingsSectionCard(
                          title: 'Pilot Profile',
                          subtitle: 'Pilot identity and signature preferences.',
                          children: [
                            PilotProfileSettingsCard(),
                          ],
                        ),
                      ],
                    ),
                  ),
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

class _SettingsSectionCard extends StatelessWidget {
  const _SettingsSectionCard({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}
