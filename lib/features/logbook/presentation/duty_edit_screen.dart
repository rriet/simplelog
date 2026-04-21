import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simplelog/core/date/db_date_time.dart';
import 'package:simplelog/core/debug/edit_screen_lifecycle_logger.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/inputs/clock_time_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/date_selector_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/hour_input_field.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/domain/usecases/logbook_use_cases.dart';
import 'package:simplelog/features/logbook/application/providers/logbook_feature_providers.dart';
import 'package:simplelog/state/providers/duty_rules_settings_provider.dart';

/// Screen for creating or editing a duty period entry.
class DutyEditScreen extends ConsumerStatefulWidget {
  /// Creates a duty edit screen for an existing [dutyId] or a new duty.
  const DutyEditScreen({
    super.key,
    this.dutyId,
    this.initialStart,
    this.initialEnd,
  });

  /// Identifier of the duty period being edited, if any.
  final int? dutyId;

  /// Initial start date/time used to seed the form when creating.
  final DateTime? initialStart;

  /// Initial end date/time used to seed the form when creating.
  final DateTime? initialEnd;

  /// Whether this instance represents a create operation.
  bool get isCreate => dutyId == null;

  @override
  ConsumerState<DutyEditScreen> createState() => _DutyEditScreenState();
}

class _DutyEditScreenState extends ConsumerState<DutyEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _dutyTimeController = TextEditingController();
  final _factoredController = TextEditingController();
  bool _factoredEdited = false;
  bool _loading = true;

  late DateTime _start;
  late DateTime _end;
  DutyPeriod? _duty;
  int? _startTimelineId;
  int? _endTimelineId;
  String? _dutyEndErrorText;
  String? _factoredDutyErrorText;

  void _setLoadingFalse() {
    setState(() => _loading = false);
  }

  void _refreshLoadedState() {
    setState(() {});
  }

  void _applyPickedDate(DateTime picked) {
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

  @override
  void initState() {
    super.initState();
    EditScreenLifecycleLogger.onInit(
      screen: 'DutyEditScreen',
      state: this,
      details: <String, Object?>{
        'isCreate': widget.isCreate,
        'id': widget.dutyId,
      },
    );
    final now = DateTime.now();
    _start = widget.initialStart ?? now;
    _end = widget.initialEnd ?? now.add(const Duration(hours: 2));
    _startTimeController.text = ClockTimeInputField.formatMinutesOfDay(
      _start.hour * 60 + _start.minute,
    );
    _endTimeController.text = ClockTimeInputField.formatMinutesOfDay(
      _end.hour * 60 + _end.minute,
    );
    _dutyTimeController.text = HourInputField.formatHours(_dutyMinutes);
    _factoredController.text = HourInputField.formatHours(_dutyMinutes);
    unawaited(_loadExisting());
  }

  @override
  void dispose() {
    EditScreenLifecycleLogger.onDispose(
      screen: 'DutyEditScreen',
      state: this,
      details: <String, Object?>{
        'isCreate': widget.isCreate,
        'id': widget.dutyId,
      },
    );
    _startTimeController.dispose();
    _endTimeController.dispose();
    _dutyTimeController.dispose();
    _factoredController.dispose();
    super.dispose();
  }

  int get _dutyMinutes => _end.difference(_start).inMinutes;

  Future<void> _loadExisting() async {
    if (widget.isCreate) {
      final useCases = ref.read(logbookUseCasesProvider);
      final rulesSettings = await ref.read(dutyRulesSettingsProvider.future);
      final suggestion = await useCases.suggestDutyForLatestEvent(
        rules: DutyCalculationRules(
          crewHomeBaseAirportId: rulesSettings.crewHomeBaseAirportId,
          reportingTimeOnBaseMinutes: rulesSettings.reportingTimeOnBaseMinutes,
          reportingTimeOffBaseMinutes:
              rulesSettings.reportingTimeOffBaseMinutes,
          dutyEndTimeAllowanceMinutes:
              rulesSettings.dutyEndTimeAllowanceMinutes,
          minimumRestTimeMinutes: rulesSettings.minimumRestTimeMinutes,
        ),
      );
      if (!mounted) return;
      if (suggestion != null) {
        _start = suggestion.startUtc;
        _end = suggestion.endUtc;
        _startTimeController.text = ClockTimeInputField.formatMinutesOfDay(
          _start.hour * 60 + _start.minute,
        );
        _endTimeController.text = ClockTimeInputField.formatMinutesOfDay(
          _end.hour * 60 + _end.minute,
        );
        _dutyTimeController.text = HourInputField.formatHours(_dutyMinutes);
        _factoredController.text = HourInputField.formatHours(
          suggestion.factoredMinutes,
        );
      }
      if (!mounted) return;
      _setLoadingFalse();
      return;
    }

    final useCases = ref.read(logbookUseCasesProvider);
    final loaded = await useCases.loadDutyEditData(widget.dutyId!);
    if (!mounted) return;
    if (loaded == null) {
      if (!mounted) return;
      _setLoadingFalse();
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
    _startTimeController.text = ClockTimeInputField.formatMinutesOfDay(
      _start.hour * 60 + _start.minute,
    );
    _endTimeController.text = ClockTimeInputField.formatMinutesOfDay(
      _end.hour * 60 + _end.minute,
    );
    _duty = loaded.duty;
    _factoredController.text = HourInputField.formatHours(
      loaded.duty.timeFactoredDutyMinutes,
    );
    _dutyTimeController.text = HourInputField.formatHours(_dutyMinutes);
    _loading = false;
    if (!mounted) return;
    _refreshLoadedState();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    if (!mounted) return;
    _applyPickedDate(picked);
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
      _dutyEndErrorText = null;
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
      _dutyEndErrorText = null;
      _updateFactoredIfNeeded();
    });
  }

  void _updateFactoredIfNeeded() {
    _dutyTimeController.text = HourInputField.formatHours(_dutyMinutes);
    if (!_factoredEdited) {
      _factoredController.text = HourInputField.formatHours(_dutyMinutes);
    }
  }

  String _dateLabel(DateTime value) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat('dd/MMM yyyy', locale).format(value);
  }

  Future<void> _save() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    String? dutyEndErrorText;
    String? factoredDutyErrorText;

    if (!_end.isAfter(_start)) {
      dutyEndErrorText = 'Duty end time is before duty start.';
    }

    final dutyMinutes = _dutyMinutes;
    final factoredMinutes =
        HourInputField.parseHours(_factoredController.text) ?? dutyMinutes;
    if (factoredMinutes > dutyMinutes) {
      factoredDutyErrorText =
          'Factored duty time is greater than total duty time.';
    }

    setState(() {
      _dutyEndErrorText = dutyEndErrorText;
      _factoredDutyErrorText = factoredDutyErrorText;
    });

    if (!formValid ||
        dutyEndErrorText != null ||
        factoredDutyErrorText != null) {
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
      AppNavigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final title = widget.isCreate ? l10n.newDutyTitle : l10n.editDutyTitle;
    final form = Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DateSelectorInputField(
              label: AppLocalizations.of(context)!.fieldDate,
              valueText: _dateLabel(_start),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClockTimeInputField(
                    controller: _startTimeController,
                    label: AppLocalizations.of(context)!.autoUi024,
                    onChangedMinutes: _onStartTimeChanged,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClockTimeInputField(
                    controller: _endTimeController,
                    label: AppLocalizations.of(context)!.autoUi022,
                    onChangedMinutes: _onEndTimeChanged,
                    errorText: _dutyEndErrorText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: HourInputField(
                    controller: _dutyTimeController,
                    readOnly: true,
                    label: AppLocalizations.of(context)!.reportsMetricDuty,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: HourInputField(
                    controller: _factoredController,
                    label: AppLocalizations.of(context)!.autoUi031,
                    fallbackMinutes: _dutyMinutes,
                    onChangedMinutes: (_) {
                      _factoredEdited = true;
                      if (_factoredDutyErrorText != null) {
                        setState(() => _factoredDutyErrorText = null);
                      }
                    },
                    errorText: _factoredDutyErrorText,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.codeRequired;
                      }
                      final parsed = HourInputField.parseHours(value);
                      if (parsed == null || parsed <= 0) {
                        return l10n.validationErrorGeneric;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return AdaptiveFormShell(
      onClose: () => unawaited(AppNavigator.maybePop(context)),
      title: title,
      actions: [TextButton(onPressed: _save, child: Text(l10n.saveAction))],
      contentView: form,
    );
  }
}
