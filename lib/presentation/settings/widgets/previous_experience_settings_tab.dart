import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:intl/intl.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/previous_experience_row.dart';
import 'package:simplelog/features/aircraft_types/application/providers/aircraft_type_repository_provider.dart';
import 'package:simplelog/presentation/settings/providers/previous_experience_providers.dart';
import 'package:simplelog/presentation/shared/widgets/time_input_field.dart';

class PreviousExperienceSettingsTab extends ConsumerWidget {
  const PreviousExperienceSettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rowsAsync = ref.watch(previousExperiencesProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text(
              'Previous Experience',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => _openEditor(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        rowsAsync.when(
          data: (rows) {
            if (rows.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('No previous experience entries yet.'),
              );
            }
            return Column(
              children: rows
                  .map(
                    (row) => Card(
                      child: ListTile(
                        title: Text(
                          '${row.aircraftType.code} • ${row.aircraftType.longName}',
                        ),
                        subtitle: Text(
                          'Block ${_formatMinutes(row.previousExperience.timeBlockMinutes)}  '
                          'PIC ${_formatMinutes(row.previousExperience.timePICMinutes)}  '
                          'SIM ${_formatMinutes(row.previousExperience.timeSimulatorMinutes)}',
                        ),
                        onTap: () => _openEditor(
                          context,
                          ref,
                          initial: row.previousExperience,
                        ),
                        trailing: IconButton(
                          tooltip: 'Delete',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteEntry(context, ref, row),
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text(error.toString()),
        ),
      ],
    );
  }

  Future<void> _deleteEntry(
    BuildContext context,
    WidgetRef ref,
    PreviousExperienceRow row,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Previous Experience'),
        content: Text('Delete entry for ${row.aircraftType.code}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(previousExperienceRepositoryProvider)
        .delete(row.previousExperience.id);
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    PreviousExperience? initial,
  }) async {
    final typesAsync = await ref.read(aircraftTypesProvider('').future);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => _PreviousExperienceEditDialog(
        aircraftTypes: typesAsync.map((e) => e.type).toList(),
        initial: initial,
      ),
    );
  }

  static String _formatMinutes(int minutes) {
    return TimeInputField.formatMinutes(minutes);
  }
}

class _PreviousExperienceEditDialog extends ConsumerStatefulWidget {
  const _PreviousExperienceEditDialog({
    required this.aircraftTypes,
    this.initial,
  });

  final List<AircraftType> aircraftTypes;
  final PreviousExperience? initial;

  @override
  ConsumerState<_PreviousExperienceEditDialog> createState() =>
      _PreviousExperienceEditDialogState();
}

class _PreviousExperienceEditDialogState
    extends ConsumerState<_PreviousExperienceEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late int? _aircraftTypeId;
  DateTime? _firstFlight;
  DateTime? _lastFlight;

  final _timeControllers = <String, TextEditingController>{};
  final _intControllers = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _aircraftTypeId = initial?.aircraftTypeId;
    _firstFlight = initial?.dateTimeFirstFlight;
    _lastFlight = initial?.dateTimeLastFlight;

    _setTime('pic', initial?.timePICMinutes ?? 0);
    _setTime('picus', initial?.timePICUSMinutes ?? 0);
    _setTime('sic', initial?.timeSICMinutes ?? 0);
    _setTime('dual', initial?.timeDualMinutes ?? 0);
    _setTime('instructor', initial?.timeInstructorMinutes ?? 0);
    _setTime('ifr', initial?.timeIFRMinutes ?? 0);
    _setTime('instrument', initial?.timeInstrumentMinutes ?? 0);
    _setTime('simInstrument', initial?.timeSimulatedInstrumentMinutes ?? 0);
    _setTime('night', initial?.timeNightMinutes ?? 0);
    _setTime('xc', initial?.timeCrossCountryMinutes ?? 0);
    _setTime('custom1', initial?.timeCustom1Minutes ?? 0);
    _setTime('custom2', initial?.timeCustom2Minutes ?? 0);
    _setTime('custom3', initial?.timeCustom3Minutes ?? 0);
    _setTime('custom4', initial?.timeCustom4Minutes ?? 0);
    _setTime('flight', initial?.timeFlightMinutes ?? 0);
    _setTime('block', initial?.timeBlockMinutes ?? 0);
    _setTime('sim', initial?.timeSimulatorMinutes ?? 0);

    _setInt('distance', initial?.distanceNM ?? 0);
    _setInt('ifrApproaches', initial?.ifrApproaches ?? 0);
    _setInt('takeoffDay', initial?.takeOffsDays ?? 0);
    _setInt('takeoffNight', initial?.takeOffsNight ?? 0);
    _setInt('landingDay', initial?.landingsDay ?? 0);
    _setInt('landingNight', initial?.landingsNight ?? 0);
  }

  void _setTime(String key, int minutes) {
    _timeControllers[key] = TextEditingController(
      text: TimeInputField.formatMinutes(minutes),
    );
  }

  void _setInt(String key, int value) {
    _intControllers[key] = TextEditingController(text: value.toString());
  }

  @override
  void dispose() {
    for (final controller in _timeControllers.values) {
      controller.dispose();
    }
    for (final controller in _intControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDateTime({required bool first}) async {
    final current = first ? _firstFlight : _lastFlight;
    final nowUtc = DateTime.now().toUtc();
    final base = current ?? nowUtc;
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.utc(base.year, base.month, base.day),
      firstDate: DateTime.utc(1970),
      lastDate: DateTime.utc(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: base.hour, minute: base.minute),
    );
    if (time == null || !mounted) return;
    final value = DateTime.utc(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (first) {
        _firstFlight = value;
      } else {
        _lastFlight = value;
      }
    });
  }

  int _minutes(String key) =>
      TimeInputField.parseMinutes(_timeControllers[key]!.text) ?? 0;

  int _intValue(String key) => int.tryParse(_intControllers[key]!.text) ?? 0;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_aircraftTypeId == null) return;

    if (_firstFlight != null &&
        _lastFlight != null &&
        !_firstFlight!.isBefore(_lastFlight!)) {
      await _showError('First flight must be earlier than last flight.');
      return;
    }

    final blockMinutes = _minutes('block');
    final pic = _minutes('pic');
    final picus = _minutes('picus');
    final sic = _minutes('sic');
    final dual = _minutes('dual');
    final sumPilotFunctions = pic + picus + sic + dual;
    if (sumPilotFunctions != blockMinutes) {
      await _showError('PIC + PICUS + SIC + Dual must equal Total Block time.');
      return;
    }

    final allTimes = <String, int>{
      'PIC': pic,
      'PICUS': picus,
      'SIC': sic,
      'Dual': dual,
      'Instructor': _minutes('instructor'),
      'IFR': _minutes('ifr'),
      'Instrument': _minutes('instrument'),
      'Sim Instrument': _minutes('simInstrument'),
      'Night': _minutes('night'),
      'Cross Country': _minutes('xc'),
      'Custom 1': _minutes('custom1'),
      'Custom 2': _minutes('custom2'),
      'Custom 3': _minutes('custom3'),
      'Custom 4': _minutes('custom4'),
      'Flight': _minutes('flight'),
      'Simulator': _minutes('sim'),
    };
    final biggerThanBlock = allTimes.entries
        .where((entry) => entry.value > blockMinutes)
        .map((entry) => entry.key)
        .toList(growable: false);
    if (biggerThanBlock.isNotEmpty) {
      await _showError(
        'These times are greater than Total Block: ${biggerThanBlock.join(', ')}.',
      );
      return;
    }

    final companion = PreviousExperiencesCompanion(
      aircraftTypeId: Value(_aircraftTypeId!),
      dateTimeFirstFlight: Value(_firstFlight),
      dateTimeLastFlight: Value(_lastFlight),
      timePICMinutes: Value(_minutes('pic')),
      timePICUSMinutes: Value(_minutes('picus')),
      timeSICMinutes: Value(_minutes('sic')),
      timeDualMinutes: Value(_minutes('dual')),
      timeInstructorMinutes: Value(_minutes('instructor')),
      timeIFRMinutes: Value(_minutes('ifr')),
      timeInstrumentMinutes: Value(_minutes('instrument')),
      timeSimulatedInstrumentMinutes: Value(_minutes('simInstrument')),
      timeNightMinutes: Value(_minutes('night')),
      timeCrossCountryMinutes: Value(_minutes('xc')),
      timeCustom1Minutes: Value(_minutes('custom1')),
      timeCustom2Minutes: Value(_minutes('custom2')),
      timeCustom3Minutes: Value(_minutes('custom3')),
      timeCustom4Minutes: Value(_minutes('custom4')),
      timeFlightMinutes: Value(_minutes('flight')),
      timeBlockMinutes: Value(_minutes('block')),
      timeSimulatorMinutes: Value(_minutes('sim')),
      distanceNM: Value(_intValue('distance')),
      ifrApproaches: Value(_intValue('ifrApproaches')),
      takeOffsDays: Value(_intValue('takeoffDay')),
      takeOffsNight: Value(_intValue('takeoffNight')),
      landingsDay: Value(_intValue('landingDay')),
      landingsNight: Value(_intValue('landingNight')),
    );

    final repo = ref.read(previousExperienceRepositoryProvider);
    if (widget.initial == null) {
      await repo.create(companion);
    } else {
      await repo.update(
        widget.initial!.copyWith(
          aircraftTypeId: _aircraftTypeId!,
          dateTimeFirstFlight: Value(_firstFlight),
          dateTimeLastFlight: Value(_lastFlight),
          timePICMinutes: _minutes('pic'),
          timePICUSMinutes: _minutes('picus'),
          timeSICMinutes: _minutes('sic'),
          timeDualMinutes: _minutes('dual'),
          timeInstructorMinutes: _minutes('instructor'),
          timeIFRMinutes: _minutes('ifr'),
          timeInstrumentMinutes: _minutes('instrument'),
          timeSimulatedInstrumentMinutes: _minutes('simInstrument'),
          timeNightMinutes: _minutes('night'),
          timeCrossCountryMinutes: _minutes('xc'),
          timeCustom1Minutes: _minutes('custom1'),
          timeCustom2Minutes: _minutes('custom2'),
          timeCustom3Minutes: _minutes('custom3'),
          timeCustom4Minutes: _minutes('custom4'),
          timeFlightMinutes: _minutes('flight'),
          timeBlockMinutes: _minutes('block'),
          timeSimulatorMinutes: _minutes('sim'),
          distanceNM: _intValue('distance'),
          ifrApproaches: _intValue('ifrApproaches'),
          takeOffsDays: _intValue('takeoffDay'),
          takeOffsNight: _intValue('takeoffNight'),
          landingsDay: _intValue('landingDay'),
          landingsNight: _intValue('landingNight'),
        ),
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _showError(String message) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validation error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.initial == null
        ? 'Add Previous Experience'
        : 'Edit Previous Experience';
    return Dialog(
      child: SizedBox(
        width: 760,
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            ListTile(
              title: Text(title),
              trailing: TextButton(onPressed: _save, child: const Text('Save')),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<int>(
                        initialValue: _aircraftTypeId,
                        decoration: const InputDecoration(
                          labelText: 'Aircraft Type',
                          border: OutlineInputBorder(),
                        ),
                        items: widget.aircraftTypes
                            .map(
                              (type) => DropdownMenuItem<int>(
                                value: type.id,
                                child: Text('${type.code} - ${type.longName}'),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) =>
                            setState(() => _aircraftTypeId = value),
                        validator: (value) =>
                            value == null ? 'Select aircraft type.' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _DateField(
                              label: 'First Flight (UTC)',
                              value: _firstFlight,
                              onPick: () => _pickDateTime(first: true),
                              onClear: () =>
                                  setState(() => _firstFlight = null),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DateField(
                              label: 'Last Flight (UTC)',
                              value: _lastFlight,
                              onPick: () => _pickDateTime(first: false),
                              onClear: () => setState(() => _lastFlight = null),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _TimeGrid(controllers: _timeControllers),
                      const SizedBox(height: 12),
                      _IntGrid(controllers: _intControllers),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onPick,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? '-'
        : DateFormat('dd/MM/yyyy HH:mm').format(value!.toUtc());
    return OutlinedButton(
      onPressed: onPick,
      child: Row(
        children: [
          Expanded(child: Text('$label: $text')),
          IconButton(onPressed: onClear, icon: const Icon(Icons.clear)),
        ],
      ),
    );
  }
}

class _TimeGrid extends StatelessWidget {
  const _TimeGrid({required this.controllers});

  final Map<String, TextEditingController> controllers;

  @override
  Widget build(BuildContext context) {
    final fields = <(String, String)>[
      ('PIC', 'pic'),
      ('PICUS', 'picus'),
      ('SIC', 'sic'),
      ('Dual', 'dual'),
      ('Instructor', 'instructor'),
      ('IFR', 'ifr'),
      ('Instrument', 'instrument'),
      ('Sim Instrument', 'simInstrument'),
      ('Night', 'night'),
      ('Cross Country', 'xc'),
      ('Custom 1', 'custom1'),
      ('Custom 2', 'custom2'),
      ('Custom 3', 'custom3'),
      ('Custom 4', 'custom4'),
      ('Flight', 'flight'),
      ('Block', 'block'),
      ('Simulator', 'sim'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Times', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: fields
              .map(
                (field) => SizedBox(
                  width: 220,
                  child: TimeInputField(
                    controller: controllers[field.$2]!,
                    label: field.$1,
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _IntGrid extends StatelessWidget {
  const _IntGrid({required this.controllers});

  final Map<String, TextEditingController> controllers;

  @override
  Widget build(BuildContext context) {
    final fields = <(String, String)>[
      ('Distance NM', 'distance'),
      ('IFR Approaches', 'ifrApproaches'),
      ('Takeoffs Day', 'takeoffDay'),
      ('Takeoffs Night', 'takeoffNight'),
      ('Landings Day', 'landingDay'),
      ('Landings Night', 'landingNight'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Counters', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: fields
              .map(
                (field) => SizedBox(
                  width: 220,
                  child: TextFormField(
                    controller: controllers[field.$2],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: field.$1,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}
