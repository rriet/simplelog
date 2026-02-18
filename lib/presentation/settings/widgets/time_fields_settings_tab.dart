import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/state/providers/custom_time_labels_provider.dart';
import 'package:simplelog/state/providers/flight_time_fields_visibility_provider.dart';

class TimeFieldsSettingsTab extends ConsumerStatefulWidget {
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

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    _c3.dispose();
    _c4.dispose();
    super.dispose();
  }

  Future<void> _saveLabels() async {
    final value = CustomTimeLabels(
      custom1: _c1.text.trim().isEmpty ? 'Custom 1' : _c1.text.trim(),
      custom2: _c2.text.trim().isEmpty ? 'Custom 2' : _c2.text.trim(),
      custom3: _c3.text.trim().isEmpty ? 'Custom 3' : _c3.text.trim(),
      custom4: _c4.text.trim().isEmpty ? 'Custom 4' : _c4.text.trim(),
    );
    await ref.read(customTimeLabelsProvider.notifier).setLabels(value);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Time field labels saved')),
    );
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
    return ref.read(flightTimeFieldsVisibilityProvider.notifier).setValue(
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Visible Time Fields', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
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
          onChanged: (v) => _updateVisibility(visibility, instructor: v),
        ),
        SwitchListTile(
          value: visibility.ifr,
          title: const Text('IFR'),
          onChanged: (v) => _updateVisibility(visibility, ifr: v),
        ),
        SwitchListTile(
          value: visibility.instrument,
          title: const Text('Instrument'),
          onChanged: (v) => _updateVisibility(visibility, instrument: v),
        ),
        SwitchListTile(
          value: visibility.simInstrument,
          title: const Text('Sim Instrument'),
          onChanged: (v) => _updateVisibility(visibility, simInstrument: v),
        ),
        SwitchListTile(
          value: visibility.night,
          title: const Text('Night'),
          onChanged: (v) => _updateVisibility(visibility, night: v),
        ),
        SwitchListTile(
          value: visibility.crossCountry,
          title: const Text('CrossCountry'),
          onChanged: (v) => _updateVisibility(visibility, crossCountry: v),
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
        const Divider(height: 24),
        Text('Custom Time Labels', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _c1,
          decoration: const InputDecoration(labelText: 'Custom 1'),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _c2,
          decoration: const InputDecoration(labelText: 'Custom 2'),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _c3,
          decoration: const InputDecoration(labelText: 'Custom 3'),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _c4,
          decoration: const InputDecoration(labelText: 'Custom 4'),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: labelsAsync.isLoading ? null : _saveLabels,
            child: const Text('Save Labels'),
          ),
        ),
      ],
    );
  }
}
