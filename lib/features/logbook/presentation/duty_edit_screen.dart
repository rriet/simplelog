import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simplelog/core/date/db_date_time.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/features/logbook/application/providers/logbook_feature_providers.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/presentation/shared/widgets/time_input_field.dart';

class DutyEditScreen extends ConsumerStatefulWidget {
  const DutyEditScreen({
    super.key,
    this.dutyId,
    this.initialStart,
    this.initialEnd,
  });

  final int? dutyId;
  final DateTime? initialStart;
  final DateTime? initialEnd;

  bool get isCreate => dutyId == null;

  @override
  ConsumerState<DutyEditScreen> createState() => _DutyEditScreenState();
}

class _DutyEditScreenState extends ConsumerState<DutyEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _factoredController = TextEditingController();
  bool _factoredEdited = false;
  bool _loading = true;

  late DateTime _start;
  late DateTime _end;
  DutyPeriod? _duty;
  int? _startTimelineId;
  int? _endTimelineId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _start = widget.initialStart ?? now;
    _end = widget.initialEnd ?? now.add(const Duration(hours: 2));
    _startTimeController.text = TimeInputField.formatMinutes(
      _start.hour * 60 + _start.minute,
    );
    _endTimeController.text = TimeInputField.formatMinutes(
      _end.hour * 60 + _end.minute,
    );
    _factoredController.text = TimeInputField.formatMinutes(_dutyMinutes);
    _loadExisting();
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    _factoredController.dispose();
    super.dispose();
  }

  int get _dutyMinutes => _end.difference(_start).inMinutes;

  Future<void> _loadExisting() async {
    if (widget.isCreate) {
      setState(() => _loading = false);
      return;
    }

    final useCases = ref.read(logbookUseCasesProvider);
    final loaded = await useCases.loadDutyEditData(widget.dutyId!);
    if (!mounted) return;
    if (loaded == null) {
      setState(() => _loading = false);
      return;
    }
    final startLine = loaded.startLine;
    final endLine = loaded.endLine;
    if (startLine != null) {
      _start = DbDateTime.dbToUtc(startLine.eventDateTime);
      _startTimelineId = startLine.id;
    }
    if (endLine != null) {
      _end = DbDateTime.dbToUtc(endLine.eventDateTime);
      _endTimelineId = endLine.id;
    }
    _startTimeController.text = TimeInputField.formatMinutes(
      _start.hour * 60 + _start.minute,
    );
    _endTimeController.text = TimeInputField.formatMinutes(
      _end.hour * 60 + _end.minute,
    );
    _duty = loaded.duty;
    _factoredController.text = TimeInputField.formatMinutes(
      loaded.duty.timeFactoredDutyMinutes,
    );
    _loading = false;
    setState(() {});
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2000),
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
      _end = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _end.hour,
        _end.minute,
      );
      if (!_end.isAfter(_start)) {
        _end = _end.add(const Duration(days: 1));
      }
      _updateFactoredIfNeeded();
    });
  }

  void _onStartTimeChanged(int minutes) {
    final hour = (minutes ~/ 60) % 24;
    final minute = minutes % 60;
    final dayStart = DateTime(_start.year, _start.month, _start.day);
    final endMinutes = _end.hour * 60 + _end.minute;
    final endDayOffset = _end.difference(dayStart).inDays;
    final adjustedEndOffset = endDayOffset == 0 && endMinutes < minutes
        ? 1
        : endDayOffset;
    setState(() {
      _start = DateTime(_start.year, _start.month, _start.day, hour, minute);
      _end = DateTime(
        dayStart.add(Duration(days: adjustedEndOffset)).year,
        dayStart.add(Duration(days: adjustedEndOffset)).month,
        dayStart.add(Duration(days: adjustedEndOffset)).day,
        _end.hour,
        _end.minute,
      );
      if (!_end.isAfter(_start)) {
        _end = _end.add(const Duration(days: 1));
      }
      _updateFactoredIfNeeded();
    });
  }

  void _onEndTimeChanged(int minutes) {
    final hour = (minutes ~/ 60) % 24;
    final minute = minutes % 60;
    final startMinutes = _start.hour * 60 + _start.minute;
    final isNextDay = minutes < startMinutes;
    final startDate = DateTime(_start.year, _start.month, _start.day);
    final endDate = startDate.add(Duration(days: isNextDay ? 1 : 0));
    setState(() {
      _end = DateTime(endDate.year, endDate.month, endDate.day, hour, minute);
      _updateFactoredIfNeeded();
    });
  }

  void _updateFactoredIfNeeded() {
    if (_factoredEdited) return;
    _factoredController.text = TimeInputField.formatMinutes(_dutyMinutes);
  }

  String _dateLabel(DateTime value) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat('dd/MMM yyyy', locale).format(value);
  }

  String _endResolvedLabel() {
    final locale = Localizations.localeOf(context).toString();
    final time = DateFormat('HH:mm', locale).format(_end);
    final startDate = DateTime(_start.year, _start.month, _start.day);
    final endDate = DateTime(_end.year, _end.month, _end.day);
    if (endDate == startDate) return time;
    return '$time (+1)';
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

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_end.isAfter(_start)) {
      await _showError('Duty end time is before duty start.');
      return;
    }

    final dutyMinutes = _dutyMinutes;
    final factoredMinutes =
        TimeInputField.parseMinutes(_factoredController.text) ?? dutyMinutes;
    if (factoredMinutes > dutyMinutes) {
      await _showError('Factored duty time is greater than total duty time.');
      return;
    }

    final useCases = ref.read(logbookUseCasesProvider);
    if (widget.isCreate) {
      await useCases.createDuty(
        start: DbDateTime.wallClockToDbUtc(_start),
        end: DbDateTime.wallClockToDbUtc(_end),
        dutyMinutes: dutyMinutes,
        factoredMinutes: factoredMinutes,
      );
    } else {
      final duty = _duty;
      if (duty == null || _startTimelineId == null || _endTimelineId == null) {
        return;
      }
      await useCases.updateDuty(
        duty: duty,
        start: DbDateTime.wallClockToDbUtc(_start),
        end: DbDateTime.wallClockToDbUtc(_end),
        dutyMinutes: dutyMinutes,
        factoredMinutes: factoredMinutes,
      );
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final title = widget.isCreate ? 'New Duty' : 'Edit Duty';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TimeInputField(
                    controller: _startTimeController,
                    label: 'Duty Start',
                    onChangedMinutes: _onStartTimeChanged,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TimeInputField(
                    controller: _endTimeController,
                    label: 'Duty End',
                    onChangedMinutes: _onEndTimeChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Resolved End: ${_endResolvedLabel()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Duty Time: ${TimeInputField.formatMinutes(_dutyMinutes)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TimeInputField(
              controller: _factoredController,
              label: 'Factored Duty Time',
              fallbackMinutes: _dutyMinutes,
              onChangedMinutes: (_) => _factoredEdited = true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.codeRequired;
                }
                final parsed = TimeInputField.parseMinutes(value);
                if (parsed == null || parsed <= 0) {
                  return l10n.validationErrorGeneric;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
