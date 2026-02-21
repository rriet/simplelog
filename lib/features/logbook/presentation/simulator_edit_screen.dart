import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import 'package:simplelog/core/constants/app_constants.dart';
import 'package:simplelog/core/date/db_date_time.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/riverpod/async_value_compat_extensions.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/aircraft_row.dart';
import 'package:simplelog/data/models/crew_row.dart';
import 'package:simplelog/data/models/simulator_crew_assignment_input.dart';
import 'package:simplelog/features/aircraft/application/providers/aircraft_feature_providers.dart';
import 'package:simplelog/features/aircraft/presentation/aircraft_edit_screen.dart';
import 'package:simplelog/features/aircraft/presentation/widgets/aircraft_picker_dialog.dart';
import 'package:simplelog/features/crew/application/providers/crew_feature_providers.dart';
import 'package:simplelog/features/crew/presentation/crew_edit_screen.dart';
import 'package:simplelog/features/crew/presentation/widgets/crew_picker_dialog.dart';
import 'package:simplelog/features/logbook/application/providers/logbook_feature_providers.dart';
import 'package:simplelog/presentation/shared/widgets/time_input_field.dart';
import 'package:simplelog/state/providers/database_provider.dart';
import 'package:simplelog/state/providers/simulator_default_crew_position_provider.dart';

class SimulatorEditScreen extends ConsumerStatefulWidget {
  const SimulatorEditScreen({super.key, this.simulatorId});

  final int? simulatorId;

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
  final List<_CrewDraftRow> _crewRows = [];
  final Map<int, String> _crewLabelCache = {};

  @override
  void initState() {
    super.initState();
    _startTimeController.text = TimeInputField.formatMinutes(
      _start.hour * 60 + _start.minute,
    );
    _endTimeController.text = '';
    _timeController.text = TimeInputField.formatMinutes(0);
    _loadExisting();
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
    _start = loaded.startLine == null
        ? DateTime.now()
        : DbDateTime.dbToUtc(loaded.startLine!.eventDateTime);
    _end = DbDateTime.dbToUtcOrNull(loaded.simulatorTraining.endDateTime);
    _startTimeController.text = TimeInputField.formatMinutes(
      _start.hour * 60 + _start.minute,
    );
    _endTimeController.text = _end == null
        ? ''
        : TimeInputField.formatMinutes(_end!.hour * 60 + _end!.minute);
    _aircraftId = loaded.simulatorTraining.aircraftId;
    _remarksController.text = loaded.simulatorTraining.remarks;
    _notesController.text = loaded.simulatorTraining.notes;
    _timeController.text = TimeInputField.formatMinutes(
      loaded.simulatorTraining.timeTotal,
    );
    _crewRows
      ..clear()
      ..addAll(
        loaded.crewAssignments.map(
          (item) => _CrewDraftRow(crewId: item.crewId, position: item.position),
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
        _CrewDraftRow(crewId: selfCrew.id, position: defaultPosition),
      );
    });
  }

  int _calculatedMinutes() {
    if (_end == null) return 0;
    return _end!.difference(_start).inMinutes.clamp(0, 24 * 60);
  }

  void _updateTimeIfAuto() {
    if (_timeEdited) return;
    _timeController.text = TimeInputField.formatMinutes(_calculatedMinutes());
  }

  Future<void> _pickSimulator() async {
    final selected = await AircraftPickerDialog.show(
      context,
      title: 'Select simulator',
      onlySimulators: true,
    );
    if (selected == null || !mounted) return;
    setState(() => _aircraftId = selected.aircraft.id);
  }

  Future<void> _createSimulatorAndSelect() async {
    final placeholder = Aircraft(
      id: kPlaceholderId,
      aircraftTypeId: 0,
      registration: '',
      mtow: null,
      isSimulator: true,
      isFavorite: false,
      isLocked: false,
      notes: null,
    );
    final result = await _showStandardFormDialog<dynamic>(
      context,
      AircraftEditScreen(
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
    setState(() => _aircraftId = created.id);
  }

  Future<int?> _createCrewAndReturnId() async {
    final placeholder = CrewData(
      id: kPlaceholderId,
      name: '',
      email: null,
      notes: null,
      phone: null,
      picture: null,
      isSelf: false,
      isFavorite: false,
      isLocked: false,
    );

    final result = await _showStandardFormDialog<dynamic>(
      context,
      CrewEditScreen(item: placeholder, isCreate: true),
    );
    if (!mounted || result != true) return null;
    final db = ref.read(databaseProvider);
    final created =
        await (db.select(db.crew)
              ..orderBy([(t) => OrderingTerm.desc(t.id)])
              ..limit(1))
            .getSingleOrNull();
    if (!mounted || created == null) return null;
    _crewLabelCache[created.id] = created.name;
    return created.id;
  }

  Future<T?> _showStandardFormDialog<T>(BuildContext context, Widget child) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;
    return showDialog<T>(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 520, maxHeight: maxHeight),
          child: SizedBox(width: 520, child: child),
        ),
      ),
    );
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
      _updateTimeIfAuto();
    });
  }

  void _clearEndTime() {
    setState(() {
      _end = null;
      _endTimeController.text = '';
      _updateTimeIfAuto();
    });
  }

  String _dateLabel(DateTime value) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat('dd/MMM yyyy', locale).format(value);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_aircraftId == null) {
      await _showError('Select a simulator.');
      return;
    }
    final end = _end;
    if (end != null && !end.isAfter(_start)) {
      await _showError('End time must be after start time.');
      return;
    }
    if (end != null && end.difference(_start) > const Duration(hours: 24)) {
      await _showError('End time cannot be more than 24 hours after start.');
      return;
    }
    final parsed = TimeInputField.parseMinutes(_timeController.text);
    if (parsed == null || parsed <= 0) {
      await _showError('Enter a valid simulator session time.');
      return;
    }
    if (!_validateCrewRows()) {
      await _showError(
        'Crew rows must have crew and position, without duplicates.',
      );
      return;
    }
    final crewAssignments = _crewRows
        .map(
          (row) => SimulatorCrewAssignmentInput(
            crewId: row.crewId!,
            position: row.position!,
          ),
        )
        .toList(growable: false);

    final useCases = ref.read(logbookUseCasesProvider);
    if (widget.isCreate) {
      await useCases.createSimulatorTraining(
        aircraftId: _aircraftId!,
        startDateTime: DbDateTime.wallClockToDbUtc(_start),
        endDateTime: DbDateTime.wallClockToDbUtcOrNull(end),
        totalMinutes: parsed,
        remarks: _remarksController.text.trim(),
        notes: _notesController.text.trim(),
        crewAssignments: crewAssignments,
      );
    } else {
      final item = _simulatorTraining;
      if (item == null) return;
      await useCases.updateSimulatorTraining(
        simulatorTraining: item,
        aircraftId: _aircraftId!,
        startDateTime: DbDateTime.wallClockToDbUtc(_start),
        endDateTime: DbDateTime.wallClockToDbUtcOrNull(end),
        totalMinutes: parsed,
        remarks: _remarksController.text.trim(),
        notes: _notesController.text.trim(),
        crewAssignments: crewAssignments,
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _showError(String message) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.validationErrorTitle),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.okAction),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final aircraftAsync = ref.watch(aircraftProvider(''));
    final crewAsync = ref.watch(crewProvider(''));

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isCreate
              ? 'New Simulator Training'
              : 'Edit Simulator Training',
        ),
        actions: [TextButton(onPressed: _save, child: Text(l10n.saveAction))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(_dateLabel(_start)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickStartDate,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TimeInputField(
                    controller: _startTimeController,
                    label: 'Start Time',
                    maxHours: 23,
                    onChangedMinutes: _onStartTimeChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TimeInputField(
                    controller: _endTimeController,
                    label: 'End Time',
                    maxHours: 23,
                    onChangedMinutes: _onEndTimeChanged,
                    onCleared: _clearEndTime,
                    allowEmpty: true,
                  ),
                ),
                IconButton(
                  tooltip: 'Clear',
                  onPressed: _end == null ? null : _clearEndTime,
                  icon: const Icon(Icons.clear),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TimeInputField(
                    controller: _timeController,
                    label: 'Session Time',
                    fallbackMinutes: _calculatedMinutes(),
                    onChangedMinutes: (_) => _timeEdited = true,
                    validator: (value) {
                      final parsed = TimeInputField.parseMinutes(value ?? '');
                      if (parsed == null || parsed <= 0) {
                        return l10n.validationErrorGeneric;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Use calculated time',
                  onPressed: _end == null
                      ? null
                      : () {
                          final calculated = _calculatedMinutes();
                          setState(() {
                            _timeController.text = TimeInputField.formatMinutes(
                              calculated,
                            );
                            _timeEdited = false;
                          });
                        },
                  icon: const Icon(Icons.calculate_outlined),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Simulator'),
                    subtitle: Text(_simulatorLabel(_aircraftId, aircraftAsync)),
                    trailing: const Icon(Icons.search),
                    onTap: _pickSimulator,
                  ),
                ),
                IconButton(
                  tooltip: 'Add simulator',
                  onPressed: _createSimulatorAndSelect,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCrewList(crewAsync),
            const SizedBox(height: 12),
            TextFormField(
              controller: _remarksController,
              minLines: 1,
              maxLines: 1,
              decoration: const InputDecoration(
                labelText: 'Remarks',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              minLines: 3,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
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
              onPressed: () async {
                final draft = await _showAddCrewDialog(crewItems);
                if (draft == null || !mounted) return;
                final duplicate = _crewRows.any(
                  (row) => row.crewId == draft.crewId,
                );
                if (duplicate) return;
                setState(() => _crewRows.add(draft));
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
                                  _positionLabel(row.position!),
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Remove',
                                visualDensity: VisualDensity.compact,
                                onPressed: () =>
                                    setState(() => _crewRows.removeAt(index)),
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
      if (row.crewId == null || row.position == null) return false;
      if (!ids.add(row.crewId!)) return false;
    }
    return true;
  }

  static const List<CrewPosition> _positionOptions = [
    CrewPosition.pic,
    CrewPosition.sic,
    CrewPosition.instructor,
    CrewPosition.observer,
    CrewPosition.relief,
    CrewPosition.reliefCaptain,
    CrewPosition.reliefFirstOfficer,
    CrewPosition.cabinSenior,
    CrewPosition.cabinCrew,
    CrewPosition.other,
  ];

  String _positionLabel(CrewPosition value) {
    switch (value) {
      case CrewPosition.pic:
        return 'PIC';
      case CrewPosition.sic:
        return 'SIC';
      case CrewPosition.instructor:
        return 'Instructor';
      case CrewPosition.observer:
        return 'Observer';
      case CrewPosition.relief:
        return 'Relief';
      case CrewPosition.reliefCaptain:
        return 'Relief Captain';
      case CrewPosition.reliefFirstOfficer:
        return 'Relief First Officer';
      case CrewPosition.cabinSenior:
        return 'Cabin Senior';
      case CrewPosition.cabinCrew:
        return 'Cabin Crew';
      case CrewPosition.other:
        return 'Other';
      case CrewPosition.unknown:
        return 'Unknown';
    }
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

  Future<_CrewDraftRow?> _showAddCrewDialog(List<CrewRow> initialItems) async {
    var selectedCrewId = initialItems.isNotEmpty ? initialItems.first.id : null;
    var selectedPosition = CrewPosition.other;

    return showDialog<_CrewDraftRow>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: const Text('Add Crew'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Crew'),
                        subtitle: Text(
                          _crewLabel(selectedCrewId, initialItems),
                        ),
                        trailing: const Icon(Icons.search),
                        onTap: () async {
                          final selected = await CrewPickerDialog.show(
                            dialogContext,
                            title: 'Select crew',
                          );
                          if (selected == null) return;
                          setLocalState(() => selectedCrewId = selected.id);
                        },
                      ),
                    ),
                    IconButton(
                      tooltip: 'Create crew',
                      onPressed: () async {
                        final createdId = await _createCrewAndReturnId();
                        if (createdId == null) return;
                        setLocalState(() => selectedCrewId = createdId);
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<CrewPosition>(
                  initialValue: selectedPosition,
                  isExpanded: true,
                  items: _positionOptions
                      .map(
                        (position) => DropdownMenuItem<CrewPosition>(
                          value: position,
                          child: Text(_positionLabel(position)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) return;
                    setLocalState(() => selectedPosition = value);
                  },
                  decoration: const InputDecoration(labelText: 'Position'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selectedCrewId == null
                  ? null
                  : () => Navigator.of(dialogContext).pop(
                      _CrewDraftRow(
                        crewId: selectedCrewId,
                        position: selectedPosition,
                      ),
                    ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CrewDraftRow {
  _CrewDraftRow({this.crewId, this.position});

  int? crewId;
  CrewPosition? position;
}
