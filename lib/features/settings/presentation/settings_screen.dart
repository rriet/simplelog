import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/theme/app_tab_bar_styles.dart';
import 'package:simplelog/features/database/presentation/database_screen.dart';
import 'package:simplelog/features/settings/presentation/widgets/duty_rules_settings_card.dart';
import 'package:simplelog/features/settings/presentation/widgets/flight_factoring_settings_card.dart';
import 'package:simplelog/features/settings/presentation/widgets/pilot_profile_settings_card.dart';
import 'package:simplelog/features/settings/presentation/widgets/previous_experience_settings_tab.dart';
import 'package:simplelog/features/settings/presentation/widgets/simulator_default_position_selector.dart';
import 'package:simplelog/features/settings/presentation/widgets/theme_mode_selector.dart';
import 'package:simplelog/features/settings/presentation/widgets/time_fields_settings_tab.dart';

/// Root settings screen with tabs for general, database and time-field options.
class SettingsScreen extends ConsumerWidget {
  /// Creates the settings screen widget.
  const SettingsScreen({super.key});

  static const _calculationPilotProfileTitle = 'Calculation & Pilot Profile';

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
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const _SettingsSectionCard(
                          title: 'Appearance',
                          subtitle: 'Theme and display preferences.',
                          children: [
                            ThemeModeSelector(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _SettingsSectionCard(
                          title: _calculationPilotProfileTitle,
                          subtitle: l10n.
                            settingsCalculationPilotProfileSubtitle,
                          children: const [
                            SimulatorDefaultPositionSelector(),
                            SizedBox(height: 8),
                            PilotProfileSettingsCard(),
                            FlightFactoringSettingsCard(),
                            SizedBox(height: 8),
                            DutyRulesSettingsCard(),
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
    required this.children,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
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
            if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}
