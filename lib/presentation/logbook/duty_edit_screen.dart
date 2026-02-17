import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/state/providers/database_provider.dart';
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
    _factoredController.text = TimeInputField.formatMinutes(_dutyMinutes);
    _loadExisting();
  }

  @override
  void dispose() {
    _factoredController.dispose();
    super.dispose();
  }

  int get _dutyMinutes => _end.difference(_start).inMinutes;

  Future<void> _loadExisting() async {
    if (widget.isCreate) {
      setState(() => _loading = false);
      return;
    }

    final db = ref.read(databaseProvider);
    final duty = await (db.select(db.dutyPeriods)
          ..where((tbl) => tbl.id.equals(widget.dutyId!)))
        .getSingleOrNull();
    if (!mounted) return;
    if (duty == null) {
      setState(() => _loading = false);
      return;
    }

    final startLine = await (db.select(db.timeLines)
          ..where((tbl) => tbl.id.equals(duty.dutyStartTimeLineId)))
        .getSingleOrNull();
    final endLine = await (db.select(db.timeLines)
          ..where((tbl) => tbl.id.equals(duty.dutyEndTimeLineId)))
        .getSingleOrNull();
    if (!mounted) return;

    if (startLine != null) {
      _start = startLine.eventDateTime;
      _startTimelineId = startLine.id;
    }
    if (endLine != null) {
      _end = endLine.eventDateTime;
      _endTimelineId = endLine.id;
    }
    _duty = duty;
    _factoredController.text =
        TimeInputField.formatMinutes(duty.timeFactoredDutyMinutes);
    _loading = false;
    setState(() {});
  }

  Future<void> _pickStart() async {
    final picked = await _pickDateTime(_start);
    if (picked == null || !mounted) return;
    setState(() {
      _start = picked;
      _updateFactoredIfNeeded();
    });
  }

  Future<void> _pickEnd() async {
    final picked = await _pickDateTime(_end);
    if (picked == null || !mounted) return;
    setState(() {
      _end = picked;
      _updateFactoredIfNeeded();
    });
  }

  void _updateFactoredIfNeeded() {
    if (_factoredEdited) return;
    _factoredController.text =
        TimeInputField.formatMinutes(_dutyMinutes);
  }

  Future<DateTime?> _pickDateTime(DateTime current) async {
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;
    if (!mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_end.isAfter(_start)) {
      await _showError('Duty end time is before duty start.');
      return;
    }

    final dutyMinutes = _dutyMinutes;
    final factoredMinutes =
        TimeInputField.parseMinutes(_factoredController.text) ??
            dutyMinutes;
    if (factoredMinutes > dutyMinutes) {
      await _showError('Factored duty time is greater than total duty time.');
      return;
    }

    final db = ref.read(databaseProvider);
    if (widget.isCreate) {
      final startId = await db.into(db.timeLines).insert(
            TimeLinesCompanion.insert(eventDateTime: _start),
          );
      final endId = await db.into(db.timeLines).insert(
            TimeLinesCompanion.insert(eventDateTime: _end),
          );
      await db.into(db.dutyPeriods).insert(
            DutyPeriodsCompanion.insert(
              dutyStartTimeLineId: startId,
              dutyEndTimeLineId: endId,
              timeDutyMinutes: dutyMinutes,
              timeFactoredDutyMinutes: factoredMinutes,
              isLocked: false,
            ),
          );
    } else {
      final duty = _duty;
      if (duty == null ||
          _startTimelineId == null ||
          _endTimelineId == null) {
        return;
      }
      final startLine = await (db.select(db.timeLines)
            ..where((tbl) => tbl.id.equals(_startTimelineId!)))
          .getSingle();
      final endLine = await (db.select(db.timeLines)
            ..where((tbl) => tbl.id.equals(_endTimelineId!)))
          .getSingle();
      await db.update(db.timeLines).replace(
            startLine.copyWith(eventDateTime: _start),
          );
      await db.update(db.timeLines).replace(
            endLine.copyWith(eventDateTime: _end),
          );
      await db.update(db.dutyPeriods).replace(
            duty.copyWith(
              timeDutyMinutes: dutyMinutes,
              timeFactoredDutyMinutes: factoredMinutes,
            ),
          );
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
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
    final locale = Localizations.localeOf(context).toString();
    final format = DateFormat('dd/MMM HH:mm', locale);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final title =
        widget.isCreate ? 'New Duty' : 'Edit Duty';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l10n.saveAction),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.logbookEventDutyStart),
              subtitle: Text(format.format(_start)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickStart,
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.logbookEventDutyEnd),
              subtitle: Text(format.format(_end)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickEnd,
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
