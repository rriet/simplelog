import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/data/models/logbook_filters.dart';
import 'package:simplelog/data/models/reports_models.dart';
import 'package:simplelog/features/logbook/application/providers/logbook_feature_providers.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entries_year_list.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entry_dialogs.dart';
import 'package:simplelog/presentation/reports/providers/reports_preferences_provider.dart';
import 'package:simplelog/presentation/reports/providers/reports_repository_provider.dart';
import 'package:simplelog/presentation/shared/widgets/time_input_field.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTime _from = DateTime.utc(1990, 1, 1);
  DateTime _to = DateTime.now().toUtc();
  ReportsFilterMatchMode _filterMatchMode = ReportsFilterMatchMode.all;
  final List<ReportsFilterCondition> _filters = [];
  bool _loading = false;
  String? _error;
  ReportsData _data = const ReportsData(
    totals: ReportsTotals.zero(),
    flights: [],
  );
  List<LogbookEntry> _entries = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_from.isAfter(_to)) {
      setState(() => _error = 'Start date must be before end date.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(reportsRepositoryProvider);
      final result = await repo.load(
        ReportsQuery(
          from: _from,
          to: _to,
          includePreviousExperience:
              ref.read(includePreviousExperienceProvider),
          filterMatchMode: _filterMatchMode,
          filters: _filters,
        ),
      );
      final logbookUseCases = ref.read(logbookUseCasesProvider);
      final logbookEntries = await logbookUseCases.fetchLogbookPage(
        LogbookFilters(
          from: _from,
          to: _to,
          types: const {
            LogbookEventType.flight,
            LogbookEventType.simulatorTraining,
          },
        ),
        limit: 10000,
        offset: 0,
      );
      final flightIds = result.flights.map((e) => e.flightId).toSet();
      final filteredEntries = logbookEntries.where((entry) {
        if (entry.flight != null) {
          return flightIds.contains(entry.flight!.id);
        }
        return entry.simulatorTraining != null;
      }).toList(growable: false);
      if (!mounted) return;
      setState(() {
        _data = result;
        _entries = filteredEntries;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final current = isStart ? _from : _to;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: current.toLocal(),
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null || !mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current.toLocal()),
    );
    if (!mounted || pickedTime == null) return;
    final local = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    setState(() {
      if (isStart) {
        _from = local.toUtc();
      } else {
        _to = local.toUtc();
      }
    });
    await _load();
  }

  Future<void> _addFilter() async {
    final added = await showDialog<ReportsFilterCondition>(
      context: context,
      builder: (context) => const _AddFilterDialog(),
    );
    if (added == null || !mounted) return;
    setState(() => _filters.add(added));
    await _load();
  }

  Future<void> _removeFilter(int index) async {
    if (index < 0 || index >= _filters.length) return;
    setState(() => _filters.removeAt(index));
    await _load();
  }

  Future<void> _setMatchMode(ReportsFilterMatchMode mode) async {
    if (_filterMatchMode == mode) return;
    setState(() => _filterMatchMode = mode);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final logbookUseCases = ref.read(logbookUseCasesProvider);
    final includePreviousExperience =
        ref.watch(includePreviousExperienceProvider);
    final compact = MediaQuery.of(context).size.width < 900;
    final lateral = MediaQuery.of(context).size.width >= 1000;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _FiltersCard(
            from: _from,
            to: _to,
            includePreviousExperience: includePreviousExperience,
            onPickStart: () => _pickDateTime(isStart: true),
            onPickEnd: () => _pickDateTime(isStart: false),
            onIncludePreviousExperienceChanged: (value) async {
              await ref
                  .read(includePreviousExperienceProvider.notifier)
                  .setValue(value);
              if (!mounted) return;
              await _load();
            },
            filters: _filters,
            matchMode: _filterMatchMode,
            onAddFilter: _addFilter,
            onRemoveFilter: _removeFilter,
            onMatchModeChanged: _setMatchMode,
          ),
          const SizedBox(height: 14),
          if (_loading) const LinearProgressIndicator(),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: lateral
                ? Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.36,
                        child: _ScrollableTotalsCard(
                          totals: _data.totals,
                          compact: compact,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _EntriesPanel(
                          entries: _entries,
                          onEntryTap: (entry) => LogbookEntryDialogs.show(
                            context,
                            entry: entry,
                            useCases: logbookUseCases,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Flexible(
                        flex: 3,
                        child: _ScrollableTotalsCard(
                          totals: _data.totals,
                          compact: compact,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        flex: 5,
                        child: _EntriesPanel(
                          entries: _entries,
                          onEntryTap: (entry) => LogbookEntryDialogs.show(
                            context,
                            entry: entry,
                            useCases: logbookUseCases,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ScrollableTotalsCard extends StatelessWidget {
  const _ScrollableTotalsCard({
    required this.totals,
    required this.compact,
  });

  final ReportsTotals totals;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            primary: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: _TotalsCard(
                totals: totals,
                compact: compact,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FiltersCard extends StatelessWidget {
  const _FiltersCard({
    required this.from,
    required this.to,
    required this.includePreviousExperience,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onIncludePreviousExperienceChanged,
    required this.filters,
    required this.matchMode,
    required this.onAddFilter,
    required this.onRemoveFilter,
    required this.onMatchModeChanged,
  });

  final DateTime from;
  final DateTime to;
  final bool includePreviousExperience;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final ValueChanged<bool> onIncludePreviousExperienceChanged;
  final List<ReportsFilterCondition> filters;
  final ReportsFilterMatchMode matchMode;
  final Future<void> Function() onAddFilter;
  final Future<void> Function(int index) onRemoveFilter;
  final Future<void> Function(ReportsFilterMatchMode mode) onMatchModeChanged;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleSmall;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Report Filters', style: titleStyle),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _DateTimeButton(
                  label: 'Start',
                  value: from,
                  onTap: onPickStart,
                ),
                _DateTimeButton(
                  label: 'End',
                  value: to,
                  onTap: onPickEnd,
                ),
                SizedBox(
                  width: 250,
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: const Text('Include Previous Experience'),
                    value: includePreviousExperience,
                    onChanged: (value) =>
                        onIncludePreviousExperienceChanged(value ?? false),
                  ),
                ),
                SizedBox(
                  width: 130,
                  child: DropdownButtonFormField<ReportsFilterMatchMode>(
                    initialValue: matchMode,
                    decoration: const InputDecoration(
                      labelText: 'Match',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: ReportsFilterMatchMode.all,
                        child: Text('All'),
                      ),
                      DropdownMenuItem(
                        value: ReportsFilterMatchMode.any,
                        child: Text('Any'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        onMatchModeChanged(value);
                      }
                    },
                  ),
                ),
                FilledButton.icon(
                  onPressed: onAddFilter,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Filter'),
                ),
              ],
            ),
            if (filters.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var index = 0; index < filters.length; index++)
                      InputChip(
                        label: Text(
                          '${filters[index].field.label} · ${filters[index].operator.label} · ${filters[index].displayValue}',
                        ),
                        onDeleted: () => onRemoveFilter(index),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddFilterDialog extends StatefulWidget {
  const _AddFilterDialog();

  @override
  State<_AddFilterDialog> createState() => _AddFilterDialogState();
}

class _AddFilterDialogState extends State<_AddFilterDialog> {
  ReportsFilterField _field = ReportsFilterField.departureIcao;
  late ReportsFilterOperator _operator;
  final _textController = TextEditingController();
  final _numberController = TextEditingController();
  final _timeController = TextEditingController(text: '0:00');

  @override
  void initState() {
    super.initState();
    _operator = _field.valueType.supportedOperators.first;
  }

  @override
  void dispose() {
    _textController.dispose();
    _numberController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _onFieldChanged(ReportsFilterField value) {
    setState(() {
      _field = value;
      _operator = value.valueType.supportedOperators.first;
      _textController.clear();
      _numberController.clear();
      _timeController.text = '0:00';
    });
  }

  void _save() {
    final type = _field.valueType;
    String? text;
    int? number;
    if (type == ReportsFilterValueType.text) {
      text = _textController.text.trim();
      if (text.isEmpty) return;
    } else if (type == ReportsFilterValueType.number) {
      number = int.tryParse(_numberController.text.trim());
      if (number == null) return;
    } else if (type == ReportsFilterValueType.time) {
      number = TimeInputField.parseMinutes(_timeController.text.trim());
      if (number == null) return;
    }
    Navigator.of(context).pop(
      ReportsFilterCondition(
        field: _field,
        operator: _operator,
        textValue: text,
        numberValue: number,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final operators = _field.valueType.supportedOperators;
    final maxHeight = MediaQuery.of(context).size.height * 0.85;
    return Dialog(
      child: SizedBox(
        width: 520,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Add Filter',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ReportsFilterField>(
                    initialValue: _field,
                    decoration: const InputDecoration(
                      labelText: 'Field name',
                      border: OutlineInputBorder(),
                    ),
                    items: ReportsFilterField.values
                        .map(
                          (field) => DropdownMenuItem(
                            value: field,
                            child: Text(field.label),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) {
                        _onFieldChanged(value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ReportsFilterOperator>(
                    initialValue: _operator,
                    decoration: const InputDecoration(
                      labelText: 'Condition',
                      border: OutlineInputBorder(),
                    ),
                    items: operators
                        .map(
                          (operator) => DropdownMenuItem(
                            value: operator,
                            child: Text(operator.label),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _operator = value);
                      }
                    },
                  ),
                  if (_field.valueType != ReportsFilterValueType.boolean) ...[
                    const SizedBox(height: 12),
                    _buildValueField(),
                  ],
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: _save,
                      child: const Text('Add'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValueField() {
    switch (_field.valueType) {
      case ReportsFilterValueType.text:
        return TextFormField(
          controller: _textController,
          decoration: const InputDecoration(
            labelText: 'Value',
            border: OutlineInputBorder(),
          ),
        );
      case ReportsFilterValueType.number:
        return TextFormField(
          controller: _numberController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Value',
            border: OutlineInputBorder(),
          ),
        );
      case ReportsFilterValueType.time:
        return TimeInputField(
          controller: _timeController,
          label: 'Value',
        );
      case ReportsFilterValueType.boolean:
        return const SizedBox.shrink();
    }
  }
}

class _DateTimeButton extends StatelessWidget {
  const _DateTimeButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            DateFormat('dd/MM/yyyy HH:mm').format(value.toLocal()),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({
    required this.totals,
    required this.compact,
  });

  final ReportsTotals totals;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final counters = <(String, String)>[
      ('Sectors', totals.sectors.toString()),
      ('Takeoff Day', totals.takeoffsDay.toString()),
      ('Takeoff Night', totals.takeoffsNight.toString()),
      ('Landing Day', totals.landingsDay.toString()),
      ('Landing Night', totals.landingsNight.toString()),
      ('IFR Approaches', totals.ifrApproaches.toString()),
    ];
    final timesAndDistance = <(String, String)>[
      ('Distance NM', totals.distanceNM.toString()),
      ('Total', _formatMinutes(totals.totalMinutes)),
      ('Night', _formatMinutes(totals.nightMinutes)),
      ('IFR', _formatMinutes(totals.ifrMinutes)),
      ('Sim Inst', _formatMinutes(totals.simulatedInstrumentMinutes)),
      ('PIC', _formatMinutes(totals.picMinutes)),
      ('PICUS', _formatMinutes(totals.picusMinutes)),
      ('SIC', _formatMinutes(totals.sicMinutes)),
      ('Dual', _formatMinutes(totals.dualMinutes)),
      ('Instr', _formatMinutes(totals.instructorMinutes)),
      ('XC', _formatMinutes(totals.crossCountryMinutes)),
      ('Simulator', _formatMinutes(totals.simulatorMinutes)),
      ('Custom 1', _formatMinutes(totals.custom1Minutes)),
      ('Custom 2', _formatMinutes(totals.custom2Minutes)),
      ('Custom 3', _formatMinutes(totals.custom3Minutes)),
      ('Custom 4', _formatMinutes(totals.custom4Minutes)),
      ('Multi Pilot', _formatMinutes(totals.multiPilotMinutes)),
    ];
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: SelectionArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Totals', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 10),
              _MetricsGrid(metrics: counters, compact: compact),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _MetricsGrid(metrics: timesAndDistance, compact: compact),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMinutes(int minutes) {
    final safe = minutes < 0 ? 0 : minutes;
    final hour = safe ~/ 60;
    final min = safe % 60;
    return '$hour:${min.toString().padLeft(2, '0')}';
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({
    required this.metrics,
    required this.compact,
  });

  final List<(String, String)> metrics;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final minTileWidth = compact ? 150.0 : 170.0;
        final maxColumns = compact ? 2 : 4;
        final calculatedColumns =
            (constraints.maxWidth / minTileWidth).floor().clamp(1, maxColumns);
        final tileWidth = (constraints.maxWidth -
                (calculatedColumns - 1) * spacing) /
            calculatedColumns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: tileWidth,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        metric.$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: SelectableText(
                          metric.$2,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _EntriesPanel extends StatelessWidget {
  const _EntriesPanel({
    required this.entries,
    required this.onEntryTap,
  });

  final List<LogbookEntry> entries;
  final ValueChanged<LogbookEntry> onEntryTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Text('Flights & Simulator', style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                Text('${entries.length} entries'),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Expanded(
              child: entries.isEmpty
                  ? const Center(child: Text('No flights/sim in selected period.'))
                  : LogbookEntriesYearList(
                      entries: entries,
                      onEntryTap: onEntryTap,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
