import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/data/models/logbook_filters.dart';

/// Preset ranges available in the logbook filters dialog.
enum LogbookDatePreset {
  /// User-selected custom dates.
  custom,
  /// Since first recorded flight.
  sinceFirstFlight,
  /// Last 7 days.
  last7Days,
  /// Last 14 days.
  last14Days,
  /// Last 21 days.
  last21Days,
  /// Last 28 days.
  last28Days,
  /// Last 365 days.
  last365Days,
  /// Previous calendar month.
  lastMonth,
  /// Previous calendar year.
  lastYear,
  /// Current calendar month.
  currentMonth,
  /// Current calendar year.
  currentYear,
}

/// Dialog used to edit [LogbookFilters] with date/type controls.
class LogbookFiltersDialog extends StatefulWidget {
  /// Creates the filters dialog.
  const LogbookFiltersDialog({
    required this.initial,
    required this.loadFirstEventDate,
    super.key,
  });

  /// Initial filter state.
  final LogbookFilters initial;
  /// Async loader used by "since first flight" preset.
  final Future<DateTime?> Function() loadFirstEventDate;

  @override
  State<LogbookFiltersDialog> createState() => _LogbookFiltersDialogState();

  /// Shows the dialog and returns selected filters on apply.
  static Future<LogbookFilters?> show(
    BuildContext context, {
    required LogbookFilters initial,
    required Future<DateTime?> Function() loadFirstEventDate,
  }) {
    final screen = LogbookFiltersDialog(
      initial: initial,
      loadFirstEventDate: loadFirstEventDate,
    );
    final isCompact = MediaQuery.sizeOf(context).width < 600;
    if (isCompact) {
      return AppNavigator.pushMaterial<LogbookFilters>(
        context,
        (_) => screen,
        rootNavigator: true,
      );
    }
    return showDialog<LogbookFilters>(
      context: context,
      builder: (_) => screen,
    );
  }
}

class _LogbookFiltersDialogState extends State<LogbookFiltersDialog> {
  DateTime? _fromDate;
  DateTime? _toDate;
  LogbookDatePreset _preset = LogbookDatePreset.custom;
  late Set<LogbookEventType> _types;
  bool _loadingPreset = false;

  @override
  void initState() {
    super.initState();
    _fromDate = widget.initial.from;
    _toDate = widget.initial.to;
    _types = Set<LogbookEventType>.from(widget.initial.types);
  }

  DateTime _startOfDay(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  DateTime _endOfDay(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  Future<void> _selectPreset(LogbookDatePreset preset) async {
    final now = DateTime.now().toUtc();
    setState(() {
      _preset = preset;
    });

    switch (preset) {
      case LogbookDatePreset.custom:
        return;
      case LogbookDatePreset.sinceFirstFlight:
        setState(() => _loadingPreset = true);
        final first = await widget.loadFirstEventDate();
        if (!mounted) return;
        if (mounted) {
          setState(() {
            _loadingPreset = false;
            if (first != null) {
              _fromDate = _startOfDay(first);
              _toDate = _endOfDay(now);
            } else {
              _fromDate = null;
              _toDate = null;
            }
          });
        }
        return;
      case LogbookDatePreset.last7Days:
        _setRangeDays(now, 7);
        return;
      case LogbookDatePreset.last14Days:
        _setRangeDays(now, 14);
        return;
      case LogbookDatePreset.last21Days:
        _setRangeDays(now, 21);
        return;
      case LogbookDatePreset.last28Days:
        _setRangeDays(now, 28);
        return;
      case LogbookDatePreset.last365Days:
        _setRangeDays(now, 365);
        return;
      case LogbookDatePreset.lastMonth:
        final lastMonth = DateTime.utc(now.year, now.month - 1);
        _fromDate = DateTime.utc(lastMonth.year, lastMonth.month);
        _toDate = _endOfDay(DateTime.utc(now.year, now.month, 0));
        if (mounted) {
          setState(() {});
        }
        return;
      case LogbookDatePreset.lastYear:
        _fromDate = DateTime.utc(now.year - 1);
        _toDate = _endOfDay(DateTime.utc(now.year - 1, 12, 31));
        if (mounted) {
          setState(() {});
        }
        return;
      case LogbookDatePreset.currentMonth:
        _fromDate = DateTime.utc(now.year, now.month);
        _toDate = _endOfDay(DateTime.utc(now.year, now.month + 1, 0));
        if (mounted) {
          setState(() {});
        }
        return;
      case LogbookDatePreset.currentYear:
        _fromDate = DateTime.utc(now.year);
        _toDate = _endOfDay(DateTime.utc(now.year, 12, 31));
        if (mounted) {
          setState(() {});
        }
        return;
    }
  }

  void _setRangeDays(DateTime now, int days) {
    final start = now.subtract(Duration(days: days - 1));
    _fromDate = _startOfDay(start);
    _toDate = _endOfDay(now);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom ? _fromDate : _toDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now().toUtc(),
      firstDate: DateTime.utc(1970),
      lastDate: DateTime.utc(2100),
    );
    if (!mounted || picked == null) return;
    if (mounted) {
      setState(() {
        if (isFrom) {
          _fromDate = _startOfDay(picked);
        } else {
          _toDate = _endOfDay(picked);
        }
        _preset = LogbookDatePreset.custom;
      });
    }
  }

  void _clearDate(bool isFrom) {
    setState(() {
      if (isFrom) {
        _fromDate = null;
      } else {
        _toDate = null;
      }
      _preset = LogbookDatePreset.custom;
    });
  }

  void _toggleType(LogbookEventType type, bool value) {
    setState(() {
      if (value) {
        _types.add(type);
      } else {
        _types.remove(type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AdaptiveFormShell(
      onClose: () => AppNavigator.pop(context),
      title: l10n.logbookFilterTitle,
      popupMaxWidth: 520,
      actions: [
        TextButton(
          onPressed: () {
            AppNavigator.pop(
              context,
              LogbookFilters(
                from: _fromDate,
                to: _toDate,
                types: Set<LogbookEventType>.from(_types),
              ),
            );
          },
          child: Text(l10n.logbookFilterApply),
        ),
      ],
      contentView: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<LogbookDatePreset>(
              key: ValueKey(_preset),
              initialValue: _preset,
              decoration: InputDecoration(
                labelText: l10n.logbookFilterRange,
                border: const OutlineInputBorder(),
              ),
              items: _buildPresetItems(l10n),
              onChanged: _loadingPreset
                  ? null
                  : (value) {
                      if (value != null) {
                        unawaited(_selectPreset(value));
                      }
                    },
            ),
            const SizedBox(height: 12),
            _DateField(
              label: l10n.logbookFilterFromDate,
              value: _fromDate,
              onPick: () => _pickDate(isFrom: true),
              onClear: _fromDate == null ? null : () => _clearDate(true),
            ),
            const SizedBox(height: 12),
            _DateField(
              label: l10n.logbookFilterToDate,
              value: _toDate,
              onPick: () => _pickDate(isFrom: false),
              onClear: _toDate == null ? null : () => _clearDate(false),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.logbookFilterEventTypes,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _types.contains(LogbookEventType.flight),
              onChanged: (value) => _toggleType(
                LogbookEventType.flight,
                value ?? false,
              ),
              title: Text(l10n.logbookEventFlight),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              value: _types.contains(LogbookEventType.simulatorTraining),
              onChanged: (value) => _toggleType(
                LogbookEventType.simulatorTraining,
                value ?? false,
              ),
              title: Text(l10n.logbookEventSimulator),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              value: _types.contains(LogbookEventType.dutyPeriod),
              onChanged: (value) => _toggleType(
                LogbookEventType.dutyPeriod,
                value ?? false,
              ),
              title: Text(l10n.logbookEventDuty),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              value: _types.contains(LogbookEventType.positioning),
              onChanged: (value) => _toggleType(
                LogbookEventType.positioning,
                value ?? false,
              ),
              title: Text(l10n.logbookEventPositioning),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.logbookFilterAdvanced,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<LogbookDatePreset>> _buildPresetItems(
    AppLocalizations l10n,
  ) {
    return [
      DropdownMenuItem(
        value: LogbookDatePreset.custom,
        child: Text(l10n.logbookFilterPresetCustom),
      ),
      DropdownMenuItem(
        value: LogbookDatePreset.sinceFirstFlight,
        child: Text(l10n.logbookFilterPresetSinceFirstFlight),
      ),
      DropdownMenuItem(
        value: LogbookDatePreset.last7Days,
        child: Text(l10n.logbookFilterPresetLast7Days),
      ),
      DropdownMenuItem(
        value: LogbookDatePreset.last14Days,
        child: Text(l10n.logbookFilterPresetLast14Days),
      ),
      DropdownMenuItem(
        value: LogbookDatePreset.last21Days,
        child: Text(l10n.logbookFilterPresetLast21Days),
      ),
      DropdownMenuItem(
        value: LogbookDatePreset.last28Days,
        child: Text(l10n.logbookFilterPresetLast28Days),
      ),
      DropdownMenuItem(
        value: LogbookDatePreset.last365Days,
        child: Text(l10n.logbookFilterPresetLast365Days),
      ),
      DropdownMenuItem(
        value: LogbookDatePreset.lastMonth,
        child: Text(l10n.logbookFilterPresetLastMonth),
      ),
      DropdownMenuItem(
        value: LogbookDatePreset.lastYear,
        child: Text(l10n.logbookFilterPresetLastYear),
      ),
      DropdownMenuItem(
        value: LogbookDatePreset.currentMonth,
        child: Text(l10n.logbookFilterPresetCurrentMonth),
      ),
      DropdownMenuItem(
        value: LogbookDatePreset.currentYear,
        child: Text(l10n.logbookFilterPresetCurrentYear),
      ),
    ];
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onPick,
    this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final locale = MaterialLocalizations.of(context);
    final text = value == null ? '-' : locale.formatShortDate(value!);

    return InkWell(
      onTap: onPick,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: onClear == null
              ? null
              : IconButton(onPressed: onClear, icon: const Icon(Icons.clear)),
        ),
        child: Text(text),
      ),
    );
  }
}
