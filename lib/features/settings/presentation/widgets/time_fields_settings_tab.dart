import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/info_help_button.dart';
import 'package:simplelog/core/riverpod/async_value_compat_extensions.dart';
import 'package:simplelog/features/settings/presentation/widgets/flight_takeoff_landing_switch.dart';
import 'package:simplelog/state/providers/custom_time_labels_provider.dart';
import 'package:simplelog/state/providers/flight_time_fields_visibility_provider.dart';

/// Settings tab for flight time-field visibility and custom labels.
///
/// Inputs: provider-backed visibility flags and label values.
/// Output: persisted settings updates as users toggle switches or edit labels.
class TimeFieldsSettingsTab extends ConsumerStatefulWidget {
  /// Creates the time-fields settings tab.
  const TimeFieldsSettingsTab({super.key});

  @override
  ConsumerState<TimeFieldsSettingsTab> createState() =>
      _TimeFieldsSettingsTabState();
}

class _TimeFieldsSettingsTabState extends ConsumerState<TimeFieldsSettingsTab> {
  final _c1 = TextEditingController();
  final _c2 = TextEditingController();
  final _c3 = TextEditingController();
  final _c4 = TextEditingController();
  bool _loadedLabels = false;
  Timer? _labelsSaveDebounce;

  @override
  void dispose() {
    _labelsSaveDebounce?.cancel();
    _c1.dispose();
    _c2.dispose();
    _c3.dispose();
    _c4.dispose();
    super.dispose();
  }

  CustomTimeLabels _labelsFromControllers() {
    return CustomTimeLabels(
      custom1: _c1.text.trim().isEmpty ? 'Custom 1' : _c1.text.trim(),
      custom2: _c2.text.trim().isEmpty ? 'Custom 2' : _c2.text.trim(),
      custom3: _c3.text.trim().isEmpty ? 'Custom 3' : _c3.text.trim(),
      custom4: _c4.text.trim().isEmpty ? 'Custom 4' : _c4.text.trim(),
    );
  }

  Future<void> _saveLabelsNow() async {
    final value = _labelsFromControllers();
    final current = ref.read(customTimeLabelsProvider).valueOrNull;
    if (current != null &&
        current.custom1 == value.custom1 &&
        current.custom2 == value.custom2 &&
        current.custom3 == value.custom3 &&
        current.custom4 == value.custom4) {
      return;
    }
    await ref.read(customTimeLabelsProvider.notifier).setLabels(value);
  }

  void _scheduleLabelsSave() {
    _labelsSaveDebounce?.cancel();
    _labelsSaveDebounce = Timer(const Duration(milliseconds: 500), () {
      unawaited(_saveLabelsNow());
    });
  }

  Future<void> _updateVisibility(
    FlightTimeFieldsVisibility current, {
    bool? pic,
    bool? picus,
    bool? sic,
    bool? dual,
    bool? instructor,
    bool? ifr,
    bool? night,
    bool? crossCountry,
    bool? custom1,
    bool? custom2,
    bool? custom3,
    bool? custom4,
    bool? flight,
  }) {
    return ref
        .read(flightTimeFieldsVisibilityProvider.notifier)
        .setValue(
          current.copyWith(
            pic: pic,
            picus: picus,
            sic: sic,
            dual: dual,
            instructor: instructor,
            ifr: ifr,
            night: night,
            crossCountry: crossCountry,
            custom1: custom1,
            custom2: custom2,
            custom3: custom3,
            custom4: custom4,
            flight: flight,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labelsAsync = ref.watch(customTimeLabelsProvider);
    final visibilityAsync = ref.watch(flightTimeFieldsVisibilityProvider);
    final labels = labelsAsync.valueOrNull ?? const CustomTimeLabels();
    final visibility =
        visibilityAsync.valueOrNull ?? const FlightTimeFieldsVisibility();
    if (!_loadedLabels && labelsAsync.valueOrNull != null) {
      _c1.text = labels.custom1;
      _c2.text = labels.custom2;
      _c3.text = labels.custom3;
      _c4.text = labels.custom4;
      _loadedLabels = true;
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Text(
              AppLocalizations.of(context)!.settingsTabTimeFields,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.timeFieldsIntro,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _SettingsSectionCard(
              title: AppLocalizations.of(context)!.autoUi067,
              subtitle: l10n.timeFieldsVisibleSubtitle,
              headerTrailing: InfoHelpButton(
                title: l10n.settingsTimeFieldsHelpTitle,
                message: l10n.settingsTimeFieldsHelpBody,
              ),
              children: [
                const FlightTakeoffLandingSwitch(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: visibility.pic,
                  title: const Text('PIC'),
                  onChanged: (v) => _updateVisibility(visibility, pic: v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: visibility.picus,
                  title: const Text('PICUS'),
                  onChanged: (v) => _updateVisibility(visibility, picus: v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: visibility.sic,
                  title: const Text('SIC'),
                  onChanged: (v) => _updateVisibility(visibility, sic: v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: visibility.dual,
                  title: Text(AppLocalizations.of(context)!.reportsMetricDual),
                  onChanged: (v) => _updateVisibility(visibility, dual: v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: visibility.instructor,
                  title: Text(
                    AppLocalizations.of(context)!.reportsMetricInstructor,
                  ),
                  onChanged: (v) =>
                      _updateVisibility(visibility, instructor: v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: visibility.ifr,
                  title: const Text('IFR'),
                  onChanged: (v) => _updateVisibility(visibility, ifr: v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: visibility.night,
                  title: Text(AppLocalizations.of(context)!.reportsMetricNight),
                  onChanged: (v) => _updateVisibility(visibility, night: v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: visibility.crossCountry,
                  title: Text(AppLocalizations.of(context)!.autoUi017),
                  onChanged: (v) =>
                      _updateVisibility(visibility, crossCountry: v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: visibility.custom1,
                  title: Text(labels.custom1),
                  onChanged: (v) => _updateVisibility(visibility, custom1: v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: visibility.custom2,
                  title: Text(labels.custom2),
                  onChanged: (v) => _updateVisibility(visibility, custom2: v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: visibility.custom3,
                  title: Text(labels.custom3),
                  onChanged: (v) => _updateVisibility(visibility, custom3: v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: visibility.custom4,
                  title: Text(labels.custom4),
                  onChanged: (v) => _updateVisibility(visibility, custom4: v),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SettingsSectionCard(
              title: AppLocalizations.of(context)!.autoUi018,
              subtitle: l10n.timeFieldsCustomLabelsSubtitle,
              children: [
                TextFormField(
                  controller: _c1,
                  decoration: const InputDecoration(labelText: 'Custom 1'),
                  onChanged: (_) => _scheduleLabelsSave(),
                  onEditingComplete: () => unawaited(_saveLabelsNow()),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _c2,
                  decoration: const InputDecoration(labelText: 'Custom 2'),
                  onChanged: (_) => _scheduleLabelsSave(),
                  onEditingComplete: () => unawaited(_saveLabelsNow()),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _c3,
                  decoration: const InputDecoration(labelText: 'Custom 3'),
                  onChanged: (_) => _scheduleLabelsSave(),
                  onEditingComplete: () => unawaited(_saveLabelsNow()),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _c4,
                  decoration: const InputDecoration(labelText: 'Custom 4'),
                  onChanged: (_) => _scheduleLabelsSave(),
                  onEditingComplete: () => unawaited(_saveLabelsNow()),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSectionCard extends StatelessWidget {
  const _SettingsSectionCard({
    required this.title,
    required this.subtitle,
    required this.children,
    this.headerTrailing,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? headerTrailing;

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
            Row(
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (headerTrailing != null) ...<Widget>[
                  const Spacer(),
                  headerTrailing!,
                ],
              ],
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
