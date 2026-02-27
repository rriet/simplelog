import 'dart:async';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simplelog/core/constants/app_constants.dart';
import 'package:simplelog/core/date/db_date_time.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/riverpod/async_value_compat_extensions.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/aircraft_row.dart';
import 'package:simplelog/data/models/crew_row.dart';
import 'package:simplelog/data/models/endorsement_data.dart';
import 'package:simplelog/data/models/simulator_crew_assignment_input.dart';
import 'package:simplelog/features/aircraft/application/providers/aircraft_feature_providers.dart';
import 'package:simplelog/features/aircraft/presentation/aircraft_edit_screen.dart';
import 'package:simplelog/features/aircraft/presentation/widgets/aircraft_picker_dialog.dart';
import 'package:simplelog/features/crew/application/providers/crew_feature_providers.dart';
import 'package:simplelog/features/logbook/application/providers/logbook_feature_providers.dart';
import 'package:simplelog/features/logbook/presentation/widgets/add_crew_dialog.dart';
import 'package:simplelog/features/logbook/presentation/widgets/crew_creation_helper.dart';
import 'package:simplelog/features/logbook/presentation/widgets/edit_dialog_presenter.dart';
import 'package:simplelog/features/logbook/presentation/widgets/endorsement_dialog.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/clock_time_input_field.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/date_selector_input_field.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/hour_input_field.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/picker_with_add_input_field.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/text_input_field.dart';
import 'package:simplelog/state/providers/database_provider.dart';
import 'package:simplelog/state/providers/simulator_default_crew_position_provider.dart';

/// Public API documentation.
class SimulatorEditScreen extends ConsumerStatefulWidget {
  /// Public API documentation.
  const SimulatorEditScreen({super.key, this.simulatorId});

  /// Public API documentation.
  final int? simulatorId;

  /// Public API documentation.
  bool get isCreate => simulatorId == null;

  @override
  ConsumerState<SimulatorEditScreen> createState() =>
      _SimulatorEditScreenState();
}

class _SimulatorEditScreenState extends ConsumerState<SimulatorEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _timeController = TextEditingController();
  final _remarksController = TextEditingController();
  final _notesController = TextEditingController();
  final _crewListController = ScrollController();
  bool _timeEdited = false;
  bool _loading = true;

  SimulatorTraining? _simulatorTraining;
  DateTime _start = DateTime.now();
  DateTime? _end;
  int? _aircraftId;
  final List<CrewDraftSelection> _crewRows = [];
  final Map<int, String> _crewLabelCache = {};
  EndorsementData? _endorsement;
  String? _simulatorErrorText;
  String? _startEndErrorText;
  String? _sessionTimeErrorText;
  String? _crewErrorText;

  @override
  void initState() {
    super.initState();
    _startTimeController.text = ClockTimeInputField.formatMinutesOfDay(
      _start.hour * 60 + _start.minute,
    );
    _endTimeController.text = '';
    _timeController.text = HourInputField.formatHours(0);
    unawaited(_loadExisting());
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    _timeController.dispose();
    _remarksController.dispose();
    _notesController.dispose();
    _crewListController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    if (widget.isCreate) {
      _endorsement = null;
      setState(() => _loading = false);
      await _insertDefaultSelfCrewIfAny();
      return;
    }
    final useCases = ref.read(logbookUseCasesProvider);
    final loaded = await useCases.loadSimulatorEditData(widget.simulatorId!);
    if (!mounted) return;
    if (loaded == null) {
      setState(() => _loading = false);
      return;
    }
    _simulatorTraining = loaded.simulatorTraining;
    _endorsement = EndorsementData.fromJsonString(
      loaded.simulatorTraining.endorsementData,
      signatureImage: loaded.simulatorTraining.signatureImage,
    );
    _start = loaded.startLine == null
        ? DateTime.now()
        : DbDateTime.dbToUtc(loaded.startLine!.eventDateTime);
    _end = DbDateTime.dbToUtcOrNull(loaded.simulatorTraining.endDateTime);
    _startTimeController.text = ClockTimeInputField.formatMinutesOfDay(
      _start.hour * 60 + _start.minute,
    );
    _endTimeController.text = _end == null
        ? ''
        : ClockTimeInputField.formatMinutesOfDay(
            _end!.hour * 60 + _end!.minute,
          );
    _aircraftId = loaded.simulatorTraining.aircraftId;
    _remarksController.text = loaded.simulatorTraining.remarks;
    _notesController.text = loaded.simulatorTraining.notes;
    _timeController.text = HourInputField.formatHours(
      loaded.simulatorTraining.timeTotal,
    );
    _crewRows
      ..clear()
      ..addAll(
        loaded.crewAssignments.map(
          (item) =>
              CrewDraftSelection(crewId: item.crewId, position: item.position),
        ),
      );
    setState(() => _loading = false);
  }

  Future<void> _insertDefaultSelfCrewIfAny() async {
    if (!widget.isCreate || _crewRows.isNotEmpty) return;
    final db = ref.read(databaseProvider);
    final selfCrew =
        await (db.select(db.crew)
              ..where((t) => t.isSelf.equals(true))
              ..limit(1))
            .getSingleOrNull();
    if (!mounted || selfCrew == null) return;
    final defaultPosition = await ref.read(
      simulatorDefaultCrewPositionProvider.future,
    );
    if (!mounted) return;
    setState(() {
      _crewRows.add(
        CrewDraftSelection(crewId: selfCrew.id, position: defaultPosition),
      );
    });
  }

  int _calculatedMinutes() {
    if (_end == null) return 0;
    return _end!.difference(_start).inMinutes.clamp(0, 24 * 60);
  }

  void _updateTimeIfAuto() {
    if (_timeEdited) return;
    _timeController.text = HourInputField.formatHours(_calculatedMinutes());
  }

  Future<void> _pickSimulator() async {
    final selected = await AircraftPickerDialog.show(
      context,
      title: 'Select simulator',
      onlySimulators: true,
    );
    if (selected == null || !mounted) return;
    setState(() {
      _aircraftId = selected.aircraft.id;
      _simulatorErrorText = null;
    });
  }

  Future<void> _createSimulatorAndSelect() async {
    const placeholder = Aircraft(
      id: kPlaceholderId,
      aircraftTypeId: 0,
      registration: '',
      isSimulator: true,
      isFavorite: false,
      isLocked: false,
    );
    final result = await showConstrainedEditDialog<dynamic>(
      context: context,
      child: const AircraftEditScreen(
        item: placeholder,
        isCreate: true,
        initialIsSimulator: true,
      ),
    );
    if (!mounted || result != true) return;
    final db = ref.read(databaseProvider);
    final created =
        await (db.select(db.aircrafts)
              ..where((t) => t.isSimulator.equals(true))
              ..orderBy([(t) => OrderingTerm.desc(t.id)])
              ..limit(1))
            .getSingleOrNull();
    if (!mounted || created == null) return;
    setState(() {
      _aircraftId = created.id;
      _simulatorErrorText = null;
    });
  }

  Future<int?> _createCrewAndReturnId() async {
    final createdId = await createCrewAndReturnId(
      context: context,
      ref: ref,
      crewLabelCache: _crewLabelCache,
    );
    if (!mounted) return null;
    return createdId;
  }

  Future<void> _openEndorsementDialog() async {
    final value = await EndorsementDialog.show(
      context,
      initial: _endorsement,
    );
    if (!mounted || value == null) return;
    setState(() {
      _endorsement = value.isEmpty ? null : value;
    });
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _start = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _start.hour,
        _start.minute,
      );
      _updateTimeIfAuto();
    });
  }

  void _onStartTimeChanged(int minutes) {
    final hour = (minutes ~/ 60) % 24;
    final minute = minutes % 60;
    setState(() {
      _start = DateTime(_start.year, _start.month, _start.day, hour, minute);
      _startEndErrorText = null;
      _updateTimeIfAuto();
    });
  }

  void _onEndTimeChanged(int minutes) {
    final hour = (minutes ~/ 60) % 24;
    final minute = minutes % 60;
    final startDate = DateTime(_start.year, _start.month, _start.day);
    final startMinutes = _start.hour * 60 + _start.minute;
    final isNextDay = minutes < startMinutes;
    final endDate = startDate.add(Duration(days: isNextDay ? 1 : 0));
    setState(() {
      _end = DateTime(endDate.year, endDate.month, endDate.day, hour, minute);
      _startEndErrorText = null;
      _updateTimeIfAuto();
    });
  }

  void _clearEndTime() {
    setState(() {
      _end = null;
      _endTimeController.text = '';
      _startEndErrorText = null;
      _updateTimeIfAuto();
    });
  }

  String _dateLabel(DateTime value) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat('dd/MMM yyyy', locale).format(value);
  }

  Future<void> _save() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    String? simulatorErrorText;
    String? startEndErrorText;
    String? sessionTimeErrorText;
    String? crewErrorText;

    if (_aircraftId == null) {
      simulatorErrorText = 'Select a simulator.';
    }
    final end = _end;
    if (end != null && !end.isAfter(_start)) {
      startEndErrorText = 'End time must be after start time.';
    }
    if (end != null && end.difference(_start) > const Duration(hours: 24)) {
      startEndErrorText = 'End time cannot be more than 24 hours after start.';
    }
    final parsed = HourInputField.parseHours(_timeController.text);
    if (parsed == null || parsed <= 0) {
      sessionTimeErrorText = 'Enter a valid simulator session time.';
    }
    if (!_validateCrewRows()) {
      crewErrorText =
          'Crew rows must have crew and position, without duplicates.';
    }

    setState(() {
      _simulatorErrorText = simulatorErrorText;
      _startEndErrorText = startEndErrorText;
      _sessionTimeErrorText = sessionTimeErrorText;
      _crewErrorText = crewErrorText;
    });

    if (!formValid ||
        simulatorErrorText != null ||
        startEndErrorText != null ||
        sessionTimeErrorText != null ||
        crewErrorText != null) {
      return;
    }
    final crewAssignments = _crewRows
        .map(
          (row) => SimulatorCrewAssignmentInput(
            crewId: row.crewId,
            position: row.position,
          ),
        )
        .toList(growable: false);

    final useCases = ref.read(logbookUseCasesProvider);
    if (widget.isCreate) {
      await useCases.createSimulatorTraining(
        aircraftId: _aircraftId!,
        startDateTime: DbDateTime.wallClockToDbUtc(_start),
        endDateTime: DbDateTime.wallClockToDbUtcOrNull(end),
        totalMinutes: parsed!,
        remarks: _remarksController.text.trim(),
        notes: _notesController.text.trim(),
        crewAssignments: crewAssignments,
        endorsementData: _endorsement?.toJsonString(),
        endorsementSignatureImage: _endorsement?.signatureImage,
      );
    } else {
      final item = _simulatorTraining;
      if (item == null) return;
      await useCases.updateSimulatorTraining(
        simulatorTraining: item,
        aircraftId: _aircraftId!,
        startDateTime: DbDateTime.wallClockToDbUtc(_start),
        endDateTime: DbDateTime.wallClockToDbUtcOrNull(end),
        totalMinutes: parsed!,
        remarks: _remarksController.text.trim(),
        notes: _notesController.text.trim(),
        crewAssignments: crewAssignments,
        endorsementData: _endorsement?.toJsonString(),
        endorsementSignatureImage: _endorsement?.signatureImage,
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final aircraftAsync = ref.watch(aircraftProvider(''));
    final crewAsync = ref.watch(crewProvider(''));

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final form = Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DateSelectorInputField(
              label: 'Date',
              valueText: _dateLabel(_start),
              onTap: _pickStartDate,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClockTimeInputField(
                    controller: _startTimeController,
                    label: 'Start Time',
                    onChangedMinutes: _onStartTimeChanged,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClockTimeInputField(
                    controller: _endTimeController,
                    label: 'End Time',
                    onChangedMinutes: _onEndTimeChanged,
                    onCleared: _clearEndTime,
                    allowEmpty: true,
                    errorText: _startEndErrorText,
                    suffixIcon: IconButton(
                      tooltip: 'Clear',
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints.tightFor(
                        width: 24,
                        height: 24,
                      ),
                      onPressed: _end == null ? null : _clearEndTime,
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            HourInputField(
              controller: _timeController,
              label: 'Session Time',
              fallbackMinutes: _calculatedMinutes(),
              onChangedMinutes: (_) {
                _timeEdited = true;
                if (_sessionTimeErrorText != null) {
                  setState(() => _sessionTimeErrorText = null);
                }
              },
              errorText: _sessionTimeErrorText,
              suffixIcon: IconButton(
                tooltip: 'Use calculated time',
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(
                  width: 24,
                  height: 24,
                ),
                onPressed: _end == null
                    ? null
                    : () {
                        final calculated = _calculatedMinutes();
                        setState(() {
                          _timeController.text = HourInputField.formatHours(
                            calculated,
                          );
                          _timeEdited = false;
                        });
                      },
                icon: const Icon(Icons.calculate_outlined),
              ),
              validator: (value) {
                final parsed = HourInputField.parseHours(value ?? '');
                if (parsed == null || parsed <= 0) {
                  return l10n.validationErrorGeneric;
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            PickerWithAddInputField(
              label: 'Simulator',
              valueText: _simulatorLabel(_aircraftId, aircraftAsync),
              onTap: _pickSimulator,
              onAdd: _createSimulatorAndSelect,
              addTooltip: 'Add simulator',
              errorText: _simulatorErrorText,
            ),
            const SizedBox(height: 8),
            _buildCrewList(crewAsync),
            const SizedBox(height: 8),
            TextInputField(controller: _remarksController, label: 'Remarks'),
            const SizedBox(height: 8),
            TextInputField(
              controller: _notesController,
              label: 'Notes',
              minLines: 3,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );

    final title = widget.isCreate
        ? 'New Simulator Training'
        : 'Edit Simulator Training';
    final isInDialog = context.findAncestorWidgetOfExactType<Dialog>() != null;

    if (isInDialog) {
      return Material(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: Text(title),
              trailing: TextButton(
                onPressed: _save,
                child: Text(l10n.saveAction),
              ),
            ),
            const Divider(height: 1),
            Flexible(child: form),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [TextButton(onPressed: _save, child: Text(l10n.saveAction))],
      ),
      body: form,
    );
  }

  Widget _buildCrewList(AsyncValue<List<CrewRow>> crewAsync) {
    final crewItems = crewAsync.valueOrNull ?? const <CrewRow>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Crew',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _openEndorsementDialog,
              icon: Icon(
                _endorsement == null
                    ? Icons.draw_outlined
                    : Icons.verified_outlined,
              ),
              label: const Text('Endorsement'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final draft = await showAddCrewDialog(
                  context: context,
                  initialCrewId: crewItems.isNotEmpty
                      ? crewItems.first.id
                      : null,
                  crewLabel: (crewId) => _crewLabel(crewId, crewItems),
                  onCreateCrew: _createCrewAndReturnId,
                );
                if (draft == null || !mounted) return;
                final duplicate = _crewRows.any(
                  (row) => row.crewId == draft.crewId,
                );
                if (duplicate) return;
                setState(() {
                  _crewRows.add(draft);
                  _crewErrorText = null;
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Crew'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 132,
          child: Card(
            margin: EdgeInsets.zero,
            child: _crewRows.isEmpty
                ? const Center(child: Text('No crew assigned'))
                : Scrollbar(
                    controller: _crewListController,
                    thumbVisibility: true,
                    child: ListView.separated(
                      controller: _crewListController,
                      primary: false,
                      itemCount: _crewRows.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final row = _crewRows[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _crewLabel(row.crewId, crewItems),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 120,
                                child: Text(
                                  crewPositionLabel(
                                    AppLocalizations.of(context)!,
                                    row.position,
                                  ),
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Remove',
                                visualDensity: VisualDensity.compact,
                                onPressed: () => setState(() {
                                  _crewRows.removeAt(index);
                                  _crewErrorText = null;
                                }),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ),
        if (_crewErrorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              _crewErrorText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _simulatorLabel(
    int? aircraftId,
    AsyncValue<List<AircraftRow>> aircraftAsync,
  ) {
    if (aircraftId == null) return 'Not selected';
    final rows = aircraftAsync.valueOrNull;
    if (rows == null) return 'ID: $aircraftId';
    for (final row in rows) {
      if (row.aircraft.id != aircraftId) continue;
      final type = row.type?.code ?? row.type?.longName ?? '-';
      return '${row.registration} • $type';
    }
    return 'ID: $aircraftId';
  }

  bool _validateCrewRows() {
    final ids = <int>{};
    for (final row in _crewRows) {
      if (!ids.add(row.crewId)) return false;
    }
    return true;
  }

  String _crewLabel(int? crewId, List<CrewRow> crewItems) {
    if (crewId == null) return 'Select crew';
    final cached = _crewLabelCache[crewId];
    if (cached != null) return cached;
    for (final row in crewItems) {
      if (row.id == crewId) return row.name;
    }
    return 'Crew #$crewId';
  }
}
