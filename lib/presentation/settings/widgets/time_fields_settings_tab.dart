import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/riverpod/async_value_compat_extensions.dart';
import 'package:simplelog/presentation/settings/widgets/flight_takeoff_landing_switch.dart';
import 'package:simplelog/state/providers/custom_time_labels_provider.dart';
import 'package:simplelog/state/providers/flight_time_fields_visibility_provider.dart';

/// Public API documentation.
class TimeFieldsSettingsTab extends ConsumerStatefulWidget {
  /// Public API documentation.
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
    bool? instrument,
    bool? simInstrument,
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
            instrument: instrument,
            simInstrument: simInstrument,
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
          children: [
            Text(
              'Time Fields',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Control visible time columns and custom labels.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            const _SettingsPlainCard(
              child: FlightTakeoffLandingSwitch(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: 12),
            _SettingsSectionCard(
              title: 'Visible Time Fields',
              subtitle: 'Choose which columns are shown in forms and lists.',
              children: [
                SwitchListTile(
                  value: visibility.pic,
                  title: const Text('PIC'),
                  onChanged: (v) => _updateVisibility(visibility, pic: v),
                ),
                SwitchListTile(
                  value: visibility.picus,
                  title: const Text('PICUS'),
                  onChanged: (v) => _updateVisibility(visibility, picus: v),
                ),
                SwitchListTile(
                  value: visibility.sic,
                  title: const Text('SIC'),
                  onChanged: (v) => _updateVisibility(visibility, sic: v),
                ),
                SwitchListTile(
                  value: visibility.dual,
                  title: const Text('Dual'),
                  onChanged: (v) => _updateVisibility(visibility, dual: v),
                ),
                SwitchListTile(
                  value: visibility.instructor,
                  title: const Text('Instructor'),
                  onChanged: (v) =>
                      _updateVisibility(visibility, instructor: v),
                ),
                SwitchListTile(
                  value: visibility.ifr,
                  title: const Text('IFR'),
                  onChanged: (v) => _updateVisibility(visibility, ifr: v),
                ),
                SwitchListTile(
                  value: visibility.instrument,
                  title: const Text('Instrument'),
                  onChanged: (v) =>
                      _updateVisibility(visibility, instrument: v),
                ),
                SwitchListTile(
                  value: visibility.simInstrument,
                  title: const Text('Sim Instrument'),
                  onChanged: (v) =>
                      _updateVisibility(visibility, simInstrument: v),
                ),
                SwitchListTile(
                  value: visibility.night,
                  title: const Text('Night'),
                  onChanged: (v) => _updateVisibility(visibility, night: v),
                ),
                SwitchListTile(
                  value: visibility.crossCountry,
                  title: const Text('CrossCountry'),
                  onChanged: (v) =>
                      _updateVisibility(visibility, crossCountry: v),
                ),
                SwitchListTile(
                  value: visibility.custom1,
                  title: Text(labels.custom1),
                  onChanged: (v) => _updateVisibility(visibility, custom1: v),
                ),
                SwitchListTile(
                  value: visibility.custom2,
                  title: Text(labels.custom2),
                  onChanged: (v) => _updateVisibility(visibility, custom2: v),
                ),
                SwitchListTile(
                  value: visibility.custom3,
                  title: Text(labels.custom3),
                  onChanged: (v) => _updateVisibility(visibility, custom3: v),
                ),
                SwitchListTile(
                  value: visibility.custom4,
                  title: Text(labels.custom4),
                  onChanged: (v) => _updateVisibility(visibility, custom4: v),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SettingsSectionCard(
              title: 'Custom Time Labels',
              subtitle: 'Rename custom fields used across the app.',
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

class _SettingsPlainCard extends StatelessWidget {
  const _SettingsPlainCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: child,
      ),
    );
  }
}
