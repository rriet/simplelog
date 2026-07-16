import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simplelog/core/constants/app_constants.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/inputs/clock_time_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/date_selector_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/picker_with_add_input_field.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/import/wader_import_models.dart';
import 'package:simplelog/features/airports/presentation/airport_edit_screen.dart';
import 'package:simplelog/features/airports/presentation/widgets/airport_picker_dialog.dart';

/// Dialog used to review and correct Wader import issues before import.
class WaderImportReviewDialog extends StatefulWidget {
  /// Creates the dialog.
  const WaderImportReviewDialog({
    required this.db,
    required this.issues,
    required this.initialOptions,
    super.key,
  });

  /// App database used to fetch created airport records.
  final AppDatabase db;

  /// Pending issues to review.
  final List<WaderImportIssue> issues;

  /// Existing review options.
  final WaderImportReviewOptions initialOptions;

  /// Opens the review dialog and returns updated review options.
  static Future<WaderImportReviewOptions?> show(
    BuildContext context, {
    required AppDatabase db,
    required List<WaderImportIssue> issues,
    required WaderImportReviewOptions initialOptions,
  }) {
    final screen = WaderImportReviewDialog(
      db: db,
      issues: issues,
      initialOptions: initialOptions,
    );
    final isCompact = MediaQuery.sizeOf(context).width < 600;
    if (isCompact) {
      return AppNavigator.pushMaterial<WaderImportReviewOptions>(
        context,
        (_) => screen,
        rootNavigator: true,
      );
    }
    return showDialog<WaderImportReviewOptions>(
      context: context,
      barrierDismissible: false,
      builder: (_) => screen,
    );
  }

  @override
  State<WaderImportReviewDialog> createState() =>
      _WaderImportReviewDialogState();
}

class _WaderImportReviewDialogState extends State<WaderImportReviewDialog> {
  late final Map<int, Map<WaderFieldAssociation, TextEditingController>>
  _controllers;
  late final Set<int> _ignoredLines;
  late final Map<int, WaderTotalTimeResolution> _totalTimeResolutions;
  final Set<String> _knownAirportCodes = <String>{};

  @override
  void initState() {
    super.initState();
    _ignoredLines = {...widget.initialOptions.ignoredLines};
    _totalTimeResolutions = {...widget.initialOptions.totalTimeResolutions};
    _controllers = <int, Map<WaderFieldAssociation, TextEditingController>>{};
    for (final issue in widget.issues) {
      _controllers
          .putIfAbsent(
            issue.lineNumber,
            () => <WaderFieldAssociation, TextEditingController>{},
          )
          .putIfAbsent(
            issue.association,
            () => TextEditingController(
              text:
                  widget.initialOptions.valueOverrides[issue.lineNumber]?[issue
                      .association] ??
                  issue.currentValue,
            ),
          );
    }
    unawaited(_loadKnownAirportCodes());
  }

  @override
  void dispose() {
    for (final perLine in _controllers.values) {
      for (final controller in perLine.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _ignoreAll() {
    setState(() {
      _ignoredLines
        ..clear()
        ..addAll(widget.issues.map((issue) => issue.lineNumber));
    });
  }

  void _toggleLineIgnored(int lineNumber) {
    setState(() {
      if (_ignoredLines.contains(lineNumber)) {
        _ignoredLines.remove(lineNumber);
      } else {
        _ignoredLines.add(lineNumber);
      }
    });
  }

  void _submit() {
    final overrides = <int, Map<WaderFieldAssociation, String>>{
      for (final entry in widget.initialOptions.valueOverrides.entries)
        entry.key: Map<WaderFieldAssociation, String>.from(entry.value),
    };
    final originalByLine =
        <int, Map<WaderFieldAssociation, WaderImportIssue>>{};
    for (final issue in widget.issues) {
      originalByLine.putIfAbsent(
        issue.lineNumber,
        () => <WaderFieldAssociation, WaderImportIssue>{},
      )[issue.association] = issue;
    }
    for (final lineEntry in _controllers.entries) {
      final lineOverrides = overrides.putIfAbsent(
        lineEntry.key,
        () => <WaderFieldAssociation, String>{},
      );
      for (final fieldEntry in lineEntry.value.entries) {
        final value = fieldEntry.value.text.trim();
        final original =
            originalByLine[lineEntry.key]?[fieldEntry.key]?.currentValue
                .trim() ??
            '';
        if (value.isEmpty || value == original) {
          lineOverrides.remove(fieldEntry.key);
        } else {
          lineOverrides[fieldEntry.key] = value;
        }
      }
      if (lineOverrides.isEmpty) {
        overrides.remove(lineEntry.key);
      }
    }
    final resolutions = Map<int, WaderTotalTimeResolution>.from(
      _totalTimeResolutions,
    )..removeWhere((_, value) => value == WaderTotalTimeResolution.none);
    AppNavigator.pop(
      context,
      WaderImportReviewOptions(
        valueOverrides: overrides,
        ignoredLines: {..._ignoredLines},
        totalTimeResolutions: resolutions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visibleIssues = widget.issues
        .where((issue) => !_isIssueResolved(issue))
        .toList(growable: false);
    final lineNumbers =
        visibleIssues.map((issue) => issue.lineNumber).toSet().toList()..sort();
    final body = ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(child: Text(l10n.waderReviewHelpText)),
                TextButton(
                  onPressed: _ignoreAll,
                  child: Text(l10n.waderReviewIgnoreAllAction),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: lineNumbers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final lineNumber = lineNumbers[index];
                final lineIssues = widget.issues
                    .where((issue) => issue.lineNumber == lineNumber)
                    .where((issue) => !_isIssueResolved(issue))
                    .toList(growable: false);
                if (lineIssues.isEmpty) {
                  return const SizedBox.shrink();
                }
                return _buildLineCard(
                  l10n: l10n,
                  lineNumber: lineNumber,
                  lineIssues: lineIssues,
                );
              },
            ),
          ),
        ],
      ),
    );

    return AdaptiveFormShell(
      onClose: () => AppNavigator.pop(context),
      title: l10n.waderReviewTitle,
      popupMaxWidth: 760,
      actions: [
        TextButton(
          onPressed: _submit,
          child: Text(l10n.waderReviewApplyAction),
        ),
      ],
      contentView: body,
    );
  }

  Widget _buildLineCard({
    required AppLocalizations l10n,
    required int lineNumber,
    required List<WaderImportIssue> lineIssues,
  }) {
    final isIgnored =
        _ignoredLines.contains(lineNumber) ||
        _totalTimeResolutions[lineNumber] ==
            WaderTotalTimeResolution.ignoreLine;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.logtenLineLabel(lineNumber),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                TextButton(
                  onPressed: () => _toggleLineIgnored(lineNumber),
                  child: Text(
                    isIgnored
                        ? l10n.waderReviewIncludeLineAction
                        : l10n.waderReviewIgnoreLineAction,
                  ),
                ),
              ],
            ),
            if (isIgnored)
              Text(
                l10n.databaseSkippedLinesTitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (!isIgnored) ...[
              const SizedBox(height: 4),
              for (final issue in lineIssues) ...[
                Builder(
                  builder: (context) {
                    final controller =
                        _controllers[lineNumber]![issue.association];
                    if (controller == null) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          issue.reason,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        _buildCorrectionInput(
                          l10n: l10n,
                          issue: issue,
                          controller: controller,
                        ),
                        if (issue.association ==
                            WaderFieldAssociation.totalTime)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: _buildTotalTimeResolutionField(
                              l10n: l10n,
                              lineNumber: lineNumber,
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _labelForAssociation(
    AppLocalizations l10n,
    WaderFieldAssociation association,
  ) {
    return switch (association) {
      WaderFieldAssociation.date => l10n.waderFieldDate,
      WaderFieldAssociation.startTime => l10n.waderFieldStartTime,
      WaderFieldAssociation.parkingTime => l10n.waderFieldParkingTime,
      WaderFieldAssociation.departureAirport => l10n.waderFieldDepartureAirport,
      WaderFieldAssociation.arrivalAirport => l10n.waderFieldArrivalAirport,
      WaderFieldAssociation.aircraftTail => l10n.waderFieldAircraftTail,
      WaderFieldAssociation.aircraftType => l10n.waderFieldAircraftType,
      WaderFieldAssociation.totalTime => l10n.waderFieldTotalTime,
      WaderFieldAssociation.simTraineeTime => l10n.waderFieldSimTraineeTime,
      WaderFieldAssociation.simTrainerTime => l10n.waderFieldSimTrainerTime,
    };
  }

  Widget _buildCorrectionInput({
    required AppLocalizations l10n,
    required WaderImportIssue issue,
    required TextEditingController controller,
  }) {
    final label = _labelForAssociation(l10n, issue.association);
    if (_isAirportAssociation(issue.association)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PickerWithAddInputField(
            label: label,
            valueText: controller.text.trim().isEmpty
                ? l10n.logtenNotSelected
                : controller.text.trim(),
            onTap: () => _pickAirportForIssue(issue, controller),
            onAdd: () => _createAirportForIssue(issue, controller),
            addTooltip: l10n.logtenCreateAirportTooltip,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.waderReviewCorrectedValueLabel,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    }
    if (_isClockTimeAssociation(issue.association) &&
        issue.association != WaderFieldAssociation.totalTime &&
        issue.association != WaderFieldAssociation.simTraineeTime &&
        issue.association != WaderFieldAssociation.simTrainerTime) {
      return _buildCorrectedValueField(
        l10n: l10n,
        child: ClockTimeInputField(
          controller: controller,
          label: label,
          allowEmpty: true,
        ),
      );
    }
    if (issue.association == WaderFieldAssociation.date) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DateSelectorInputField(
            label: label,
            valueText: _dateValueText(l10n, controller.text),
            onTap: () => _pickDateForIssue(controller),
            onClear: controller.text.trim().isEmpty
                ? null
                : () => setState(() => controller.clear()),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.waderReviewCorrectedValueLabel,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    }
    if (_isClockTimeAssociation(issue.association)) {
      return _buildCorrectedValueField(
        l10n: l10n,
        child: ClockTimeInputField(
          controller: controller,
          label: label,
          allowEmpty: true,
        ),
      );
    }
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        helperText: l10n.waderReviewCorrectedValueLabel,
      ),
    );
  }

  Widget _buildCorrectedValueField({
    required AppLocalizations l10n,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        const SizedBox(height: 4),
        Text(
          l10n.waderReviewCorrectedValueLabel,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildTotalTimeResolutionField({
    required AppLocalizations l10n,
    required int lineNumber,
  }) {
    final value =
        _totalTimeResolutions[lineNumber] ?? WaderTotalTimeResolution.none;
    return DropdownButtonFormField<WaderTotalTimeResolution>(
      initialValue: value,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: l10n.waderTotalTimeResolutionLabel,
      ),
      items: <DropdownMenuItem<WaderTotalTimeResolution>>[
        DropdownMenuItem(
          value: WaderTotalTimeResolution.none,
          child: Text(l10n.waderTotalTimeResolutionNone),
        ),
        DropdownMenuItem(
          value: WaderTotalTimeResolution.calculateFromChocks,
          child: Text(l10n.waderTotalTimeResolutionCalculateFromChocks),
        ),
        DropdownMenuItem(
          value: WaderTotalTimeResolution.useBlockValue,
          child: Text(l10n.waderTotalTimeResolutionUseBlock),
        ),
        DropdownMenuItem(
          value: WaderTotalTimeResolution.ignoreLine,
          child: Text(l10n.waderTotalTimeResolutionIgnoreLine),
        ),
      ],
      onChanged: (selected) {
        if (selected == null) {
          return;
        }
        setState(() {
          _totalTimeResolutions[lineNumber] = selected;
          if (selected == WaderTotalTimeResolution.ignoreLine) {
            _ignoredLines.add(lineNumber);
          } else {
            _ignoredLines.remove(lineNumber);
          }
        });
      },
    );
  }

  Future<void> _pickDateForIssue(TextEditingController controller) async {
    final current =
        _tryParseWaderDate(controller.text) ?? DateTime.now().toUtc();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(current.year, current.month, current.day),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) {
      return;
    }
    final yyyy = picked.year.toString().padLeft(4, '0');
    final mm = picked.month.toString().padLeft(2, '0');
    final dd = picked.day.toString().padLeft(2, '0');
    if (mounted) {
      setState(() => controller.text = '$yyyy-$mm-$dd');
    }
  }

  DateTime? _tryParseWaderDate(String value) {
    final parts = value.trim().split('-');
    if (parts.length != 3) {
      return null;
    }
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      return null;
    }
    return DateTime.utc(year, month, day);
  }

  String _dateValueText(AppLocalizations l10n, String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    return l10n.waderReviewSelectDateHint;
  }

  bool _isAirportAssociation(WaderFieldAssociation association) {
    return association == WaderFieldAssociation.departureAirport ||
        association == WaderFieldAssociation.arrivalAirport;
  }

  bool _isClockTimeAssociation(WaderFieldAssociation association) {
    return association == WaderFieldAssociation.startTime ||
        association == WaderFieldAssociation.parkingTime ||
        association == WaderFieldAssociation.totalTime ||
        association == WaderFieldAssociation.simTraineeTime ||
        association == WaderFieldAssociation.simTrainerTime;
  }

  Future<void> _pickAirportForIssue(
    WaderImportIssue issue,
    TextEditingController controller,
  ) async {
    final selected = await AirportPickerDialog.show(
      context,
      title: issue.association == WaderFieldAssociation.departureAirport
          ? AppLocalizations.of(context)!.logtenSelectDepartureAirport
          : AppLocalizations.of(context)!.logtenSelectArrivalAirport,
    );
    if (selected == null || !mounted) {
      return;
    }
    controller.text = _airportReplacementCode(selected, issue.currentValue);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _createAirportForIssue(
    WaderImportIssue issue,
    TextEditingController controller,
  ) async {
    final raw = issue.currentValue.trim().toUpperCase();
    final result = await showDialog<dynamic>(
      context: context,
      builder: (_) => AirportEditScreen(
        item: const Airport(
          id: kPlaceholderId,
          icao: '',
          latitude: 0,
          longitude: 0,
          isFavorite: false,
          isLocked: false,
        ),
        isCreate: true,
        initialIcao: raw.length == 4 ? raw : '',
        initialIata: raw.length == 3 ? raw : '',
      ),
    );
    if (!mounted) return;
    final airportId = result is int ? result : null;
    if (airportId == null) return;
    final created = await (widget.db.select(
      widget.db.airports,
    )..where((t) => t.id.equals(airportId))).getSingleOrNull();
    if (!mounted || created == null) return;
    final replacement = _airportReplacementCode(created, issue.currentValue);
    controller.text = replacement;
    _registerKnownAirport(created);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadKnownAirportCodes() async {
    final airports = await widget.db.select(widget.db.airports).get();
    if (!mounted) return;
    if (mounted) {
      setState(() {
        for (final airport in airports) {
          _knownAirportCodes.add(airport.icao.trim().toUpperCase());
          final iata = (airport.iata ?? '').trim().toUpperCase();
          if (iata.isNotEmpty) {
            _knownAirportCodes.add(iata);
          }
        }
      });
    }
  }

  void _registerKnownAirport(Airport airport) {
    _knownAirportCodes.add(airport.icao.trim().toUpperCase());
    final iata = (airport.iata ?? '').trim().toUpperCase();
    if (iata.isNotEmpty) {
      _knownAirportCodes.add(iata);
    }
  }

  bool _isIssueResolved(WaderImportIssue issue) {
    if (!_isAirportAssociation(issue.association)) {
      return false;
    }
    final override =
        _controllers[issue.lineNumber]?[issue.association]?.text
            .trim()
            .toUpperCase() ??
        '';
    if (override.isNotEmpty && _knownAirportCodes.contains(override)) {
      return true;
    }
    final original = issue.currentValue.trim().toUpperCase();
    return original.isNotEmpty && _knownAirportCodes.contains(original);
  }

  String _airportReplacementCode(Airport airport, String originalValue) {
    final trimmedOriginal = originalValue.trim().toUpperCase();
    if (trimmedOriginal.length == 3 && (airport.iata ?? '').trim().isNotEmpty) {
      return airport.iata!.trim().toUpperCase();
    }
    return airport.icao.trim().toUpperCase();
  }
}
