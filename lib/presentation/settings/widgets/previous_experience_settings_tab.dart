import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/aircraft_type_row.dart';
import 'package:simplelog/data/models/previous_experience_row.dart';
import 'package:simplelog/features/aircraft_types/application/providers/aircraft_type_repository_provider.dart';
import 'package:simplelog/presentation/settings/providers/previous_experience_providers.dart';
import 'package:simplelog/presentation/shared/widgets/app_message_dialog.dart';
import 'package:simplelog/presentation/shared/widgets/dialog_adaptive_presenter.dart';
import 'package:simplelog/presentation/shared/widgets/dialog_header_bar.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/dropdown_input_field.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/hour_input_field.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/number_input_field.dart';

/// Settings tab to manage imported/manual previous-experience totals.
///
/// Users can list, add, edit, and delete previous experience rows per aircraft
/// type. Changes are persisted through the previous-experience repository.
class PreviousExperienceSettingsTab extends ConsumerWidget {
  /// Creates the previous-experience tab.
  const PreviousExperienceSettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rowsAsync = ref.watch(previousExperiencesProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Previous Experience',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Manage prior totals by aircraft type.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _SettingsSectionCard(
              title: 'Entries',
              subtitle: 'Edit, add, or remove previous experience records.',
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () => _openEditor(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ),
                const SizedBox(height: 10),
                rowsAsync.when(
                  data: (rows) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (rows.isEmpty)
                          const Text('No previous experience entries yet.'),
                        ...rows.map<Widget>((row) {
                          final block = _formatMinutes(
                            row.previousExperience.timeBlockMinutes,
                          );
                          final pic = _formatMinutes(
                            row.previousExperience.timePICMinutes,
                          );
                          final sim = _formatMinutes(
                            row.previousExperience.timeSimulatorMinutes,
                          );
                          return Card(
                            child: ListTile(
                              title: Text(
                                '${row.aircraftType.code} • '
                                '${row.aircraftType.longName}',
                              ),
                              subtitle: Text(
                                'Block $block  PIC $pic  SIM $sim',
                              ),
                              onTap: () => _openEditor(
                                context,
                                ref,
                                initial: row.previousExperience,
                              ),
                              trailing: IconButton(
                                tooltip: 'Delete',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () =>
                                    _deleteEntry(context, ref, row),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => Text(error.toString()),
                ),
              ],
            ),
          ],
        ),
      ),
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
    List<AircraftTypeRow> typesAsync;
    try {
      final useCases = ref.read(aircraftTypeUseCasesProvider);
      typesAsync = await useCases.watchAircraftTypes('').first;
    } on Object catch (error) {
      if (context.mounted) {
        await showAppMessageDialog(
          context,
          message: 'Unable to load aircraft types: $error',
        );
      }
      return;
    }
    if (!context.mounted) return;
    await showLargeDialogScreen<void>(
      context: context,
      builder: (_) => _PreviousExperienceEditDialog(
        aircraftTypes: typesAsync.map((e) => e.type).toList(),
        initial: initial,
      ),
    );
  }

  static String _formatMinutes(int minutes) {
    return HourInputField.formatHours(minutes);
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
  bool _showRequiredErrors = false;

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
    _setInt('flightCount', initial?.flightCount ?? 0);
    _setInt('ifrApproaches', initial?.ifrApproaches ?? 0);
    _setInt('takeoffDay', initial?.takeOffsDays ?? 0);
    _setInt('takeoffNight', initial?.takeOffsNight ?? 0);
    _setInt('landingDay', initial?.landingsDay ?? 0);
    _setInt('landingNight', initial?.landingsNight ?? 0);
  }

  void _setTime(String key, int minutes) {
    _timeControllers[key] = TextEditingController(
      text: HourInputField.formatHours(minutes),
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
        _showRequiredErrors = false;
      } else {
        _lastFlight = value;
        _showRequiredErrors = false;
      }
    });
  }

  int _minutes(String key) =>
      HourInputField.parseHours(_timeControllers[key]!.text) ?? 0;

  int _intValue(String key) => int.tryParse(_intControllers[key]!.text) ?? 0;

  Future<void> _save() async {
    setState(() => _showRequiredErrors = true);
    final formValid = _formKey.currentState!.validate();
    if (!formValid) return;
    if (_aircraftTypeId == null) return;
    if (_firstFlight == null || _lastFlight == null) {
      return;
    }

    final warnings = <String>[];
    final nowUtc = DateTime.now().toUtc();
    if (_firstFlight!.isAfter(nowUtc) || _lastFlight!.isAfter(nowUtc)) {
      warnings.add('First/Last Flight contains a future date/time.');
    }
    if (!_firstFlight!.isBefore(_lastFlight!)) {
      warnings.add('First flight should be earlier than last flight.');
    }

    final repo = ref.read(previousExperienceRepositoryProvider);
    final existing = await repo.fetchAll();
    final currentId = widget.initial?.id;
    final hasDuplicateType = existing.any(
      (row) =>
          row.aircraftTypeId == _aircraftTypeId &&
          (currentId == null || row.id != currentId),
    );
    if (hasDuplicateType) {
      warnings.add(
        'This aircraft type already has a Previous Experience entry.',
      );
    }

    final blockMinutes = _minutes('block');
    final pic = _minutes('pic');
    final picus = _minutes('picus');
    final sic = _minutes('sic');
    final dual = _minutes('dual');
    final sumPilotFunctions = pic + picus + sic + dual;
    if (sumPilotFunctions != blockMinutes) {
      warnings.add('PIC + PICUS + SIC + Dual should equal Total Block time.');
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
      warnings.add(
        'These times are greater than Total Block: '
        '${biggerThanBlock.join(', ')}.',
      );
    }

    if (warnings.isNotEmpty) {
      final proceed = await _showWarningsAndConfirm(warnings);
      if (!proceed) return;
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
      flightCount: Value(_intValue('flightCount')),
      ifrApproaches: Value(_intValue('ifrApproaches')),
      takeOffsDays: Value(_intValue('takeoffDay')),
      takeOffsNight: Value(_intValue('takeoffNight')),
      landingsDay: Value(_intValue('landingDay')),
      landingsNight: Value(_intValue('landingNight')),
    );

    if (widget.initial == null) {
      await repo.create(companion);
    } else {
      await repo.update(
        widget.initial!.copyWith(
          aircraftTypeId: _aircraftTypeId,
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
          flightCount: _intValue('flightCount'),
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

  Future<bool> _showWarningsAndConfirm(List<String> warnings) async {
    if (!mounted) return false;
    final decision = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validation warnings'),
        content: Text('${warnings.join('\n')}\n\nSave anyway?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Review'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save anyway'),
          ),
        ],
      ),
    );
    return decision ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.initial == null
        ? 'Add Previous Experience'
        : 'Edit Previous Experience';
    final isCompact = isCompactDialogScreen(context);
    final displayTitle = isCompact ? 'Previous Experience' : title;
    final dateFields = isCompact
        ? Column(
            children: [
              _DateField(
                label: 'First Flight',
                value: _firstFlight,
                onPick: () => _pickDateTime(first: true),
                onClear: () => setState(() {
                  _firstFlight = null;
                  _showRequiredErrors = true;
                }),
                errorText: _showRequiredErrors && _firstFlight == null
                    ? 'First Flight is required.'
                    : null,
              ),
              const SizedBox(height: 12),
              _DateField(
                label: 'Last Flight',
                value: _lastFlight,
                onPick: () => _pickDateTime(first: false),
                onClear: () => setState(() {
                  _lastFlight = null;
                  _showRequiredErrors = true;
                }),
                errorText: _showRequiredErrors && _lastFlight == null
                    ? 'Last Flight is required.'
                    : null,
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'First Flight',
                  value: _firstFlight,
                  onPick: () => _pickDateTime(first: true),
                  onClear: () => setState(() {
                    _firstFlight = null;
                    _showRequiredErrors = true;
                  }),
                  errorText: _showRequiredErrors && _firstFlight == null
                      ? 'First Flight is required.'
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateField(
                  label: 'Last Flight',
                  value: _lastFlight,
                  onPick: () => _pickDateTime(first: false),
                  onClear: () => setState(() {
                    _lastFlight = null;
                    _showRequiredErrors = true;
                  }),
                  errorText: _showRequiredErrors && _lastFlight == null
                      ? 'Last Flight is required.'
                      : null,
                ),
              ),
            ],
          );
    final formBody = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownInputField<int>(
              value: _aircraftTypeId,
              label: 'Aircraft Type',
              items: widget.aircraftTypes
                  .map(
                    (type) => DropdownMenuItem<int>(
                      value: type.id,
                      child: Text('${type.code} - ${type.longName}'),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) => setState(() {
                _aircraftTypeId = value;
                _showRequiredErrors = false;
              }),
              errorText: _showRequiredErrors && _aircraftTypeId == null
                  ? 'Select aircraft type.'
                  : null,
            ),
            const SizedBox(height: 12),
            dateFields,
            const SizedBox(height: 12),
            _IntGrid(controllers: _intControllers),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _TimeGrid(controllers: _timeControllers),
          ],
        ),
      ),
    );

    final isInDialog = context.findAncestorWidgetOfExactType<Dialog>() != null;
    if (isInDialog) {
      return Material(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            DialogHeaderBar(
              title: displayTitle,
              onClose: () => Navigator.of(context).maybePop(),
              actions: [
                TextButton(onPressed: _save, child: const Text('Save')),
              ],
            ),
            const Divider(height: 1),
            Expanded(child: formBody),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(displayTitle),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: formBody,
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onPick,
    required this.onClear,
    this.errorText,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPick;
  final VoidCallback onClear;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final displayValue = value?.toUtc();
    final text = value == null
        ? '-'
        : DateFormat('dd/MM/yyyy HH:mm').format(displayValue!);
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          errorText: errorText,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.clear, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ],
        ),
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
      ('Flight', 'flight'),
      ('Block', 'block'),
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
      ('Simulator', 'sim'),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12) / 2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Times', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: fields
                  .map(
                    (field) => SizedBox(
                      width: width,
                      child: HourInputField(
                        controller: controllers[field.$2]!,
                        label: field.$1,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        );
      },
    );
  }
}

class _IntGrid extends StatelessWidget {
  const _IntGrid({required this.controllers});

  final Map<String, TextEditingController> controllers;

  @override
  Widget build(BuildContext context) {
    final fields = <(String, String)>[
      ('Takeoffs Day', 'takeoffDay'),
      ('Takeoffs Night', 'takeoffNight'),
      ('Landings Day', 'landingDay'),
      ('Landings Night', 'landingNight'),
      ('IFR Approaches', 'ifrApproaches'),
      ('Distance NM', 'distance'),
      ('Flight count', 'flightCount'),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 10,
          children: fields
              .map(
                (field) => SizedBox(
                  width: width,
                  child: NumberInputField(
                    controller: controllers[field.$2]!,
                    label: field.$1,
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}
