// ignore_for_file: public_member_api_docs, document_ignores
// This widget is a small import-specific dialog with simple data holders.

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/constants/app_constants.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/inputs/picker_with_add_input_field.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/import/logten_pro_import_models.dart';
import 'package:simplelog/features/aircraft/presentation/aircraft_edit_screen.dart';
import 'package:simplelog/features/aircraft/presentation/widgets/aircraft_picker_dialog.dart';
import 'package:simplelog/features/airports/presentation/airport_edit_screen.dart';
import 'package:simplelog/features/airports/presentation/widgets/airport_picker_dialog.dart';
import 'package:simplelog/state/providers/database_provider.dart';

class LogTenImportReviewResult {
  const LogTenImportReviewResult({
    required this.valueOverrides,
    required this.ignoredLines,
  });

  final Map<int, Map<LogTenFieldAssociation, String>> valueOverrides;
  final Set<int> ignoredLines;
}

class LogTenProImportReviewDialog extends ConsumerStatefulWidget {
  const LogTenProImportReviewDialog({
    required this.issues,
    required this.options,
    super.key,
  });

  final List<LogTenImportIssue> issues;
  final LogTenImportOptions options;

  static Future<LogTenImportReviewResult?> show(
    BuildContext context, {
    required List<LogTenImportIssue> issues,
    required LogTenImportOptions options,
  }) {
    final screen = LogTenProImportReviewDialog(
      issues: issues,
      options: options,
    );
    final isCompact = MediaQuery.sizeOf(context).width < 600;
    if (isCompact) {
      return AppNavigator.pushMaterial<LogTenImportReviewResult>(
        context,
        (_) => screen,
        rootNavigator: true,
      );
    }
    return showDialog<LogTenImportReviewResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => screen,
    );
  }

  @override
  ConsumerState<LogTenProImportReviewDialog> createState() =>
      _LogTenProImportReviewDialogState();
}

class _LogTenProImportReviewDialogState
    extends ConsumerState<LogTenProImportReviewDialog> {
  late final Map<int, Map<LogTenFieldAssociation, TextEditingController>>
  _controllers;
  late final Set<int> _ignoredLines;
  late final Set<int> _simulatorLines;

  void _setFieldResolution({
    required LogTenImportIssue issue,
    required String replacement,
  }) {
    setState(() {
      _controllers[issue.lineNumber]![issue.association]!.text = replacement;
      _ignoredLines.remove(issue.lineNumber);
      _simulatorLines.remove(issue.lineNumber);
    });
  }

  @override
  void initState() {
    super.initState();
    _ignoredLines = {...widget.options.ignoredLines};
    _simulatorLines = {
      for (final entry in widget.options.valueOverrides.entries)
        if ((entry.value[LogTenFieldAssociation.flightType] ?? '').trim() ==
            '3')
          entry.key,
    };
    _controllers = <int, Map<LogTenFieldAssociation, TextEditingController>>{};
    for (final issue in widget.issues) {
      _controllers
          .putIfAbsent(
            issue.lineNumber,
            () => <LogTenFieldAssociation, TextEditingController>{},
          )
          .putIfAbsent(
            issue.association,
            () => TextEditingController(
              text:
                  widget.options.valueOverrides[issue.lineNumber]?[issue
                      .association] ??
                  issue.currentValue,
            ),
          );
    }
  }

  @override
  void dispose() {
    for (final line in _controllers.values) {
      for (final controller in line.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _submit() {
    final overrides = <int, Map<LogTenFieldAssociation, String>>{
      for (final entry in widget.options.valueOverrides.entries)
        entry.key: Map<LogTenFieldAssociation, String>.from(entry.value),
    };
    final originalByLine =
        <int, Map<LogTenFieldAssociation, LogTenImportIssue>>{};
    for (final issue in widget.issues) {
      originalByLine.putIfAbsent(
        issue.lineNumber,
        () => <LogTenFieldAssociation, LogTenImportIssue>{},
      )[issue.association] = issue;
    }
    for (final entry in _controllers.entries) {
      for (final fieldEntry in entry.value.entries) {
        final value = fieldEntry.value.text.trim();
        final original =
            originalByLine[entry.key]?[fieldEntry.key]?.currentValue.trim() ??
            '';
        final lineOverrides = overrides.putIfAbsent(
          entry.key,
          () => <LogTenFieldAssociation, String>{},
        );
        if (value.isEmpty || value == original) {
          lineOverrides.remove(fieldEntry.key);
        } else {
          lineOverrides[fieldEntry.key] = value;
        }
      }
    }
    for (final lineNumber in _simulatorLines) {
      overrides.putIfAbsent(
        lineNumber,
        () => <LogTenFieldAssociation, String>{},
      )[LogTenFieldAssociation.flightType] = '3';
    }
    for (final lineNumber in overrides.keys.toList()) {
      if (!_simulatorLines.contains(lineNumber)) {
        overrides[lineNumber]?.remove(LogTenFieldAssociation.flightType);
      }
      if (overrides[lineNumber]?.isEmpty ?? false) {
        overrides.remove(lineNumber);
      }
    }
    AppNavigator.pop(
      context,
      LogTenImportReviewResult(
        valueOverrides: overrides,
        ignoredLines: {..._ignoredLines},
      ),
    );
  }

  bool _isAirportIssue(LogTenImportIssue issue) {
    return issue.association == LogTenFieldAssociation.fromAirport ||
        issue.association == LogTenFieldAssociation.toAirport;
  }

  bool _lineSupportsSimulatorChoice(List<LogTenImportIssue> lineIssues) {
    return lineIssues.any((issue) => issue.canMarkAsSimulator);
  }

  void _setLineAsSimulator(int lineNumber, bool simulator) {
    setState(() {
      if (simulator) {
        _simulatorLines.add(lineNumber);
      } else {
        _simulatorLines.remove(lineNumber);
      }
      _ignoredLines.remove(lineNumber);
    });
  }

  Future<void> _pickAirport(LogTenImportIssue issue) async {
    final selected = await AirportPickerDialog.show(
      context,
      title: issue.association == LogTenFieldAssociation.fromAirport
          ? AppLocalizations.of(context)!.logtenSelectDepartureAirport
          : AppLocalizations.of(context)!.logtenSelectArrivalAirport,
    );
    if (selected == null) return;
    if (!mounted) return;
    final replacement = _airportReplacementCode(selected, issue.currentValue);
    _setFieldResolution(issue: issue, replacement: replacement);
  }

  Future<void> _createAirport(LogTenImportIssue issue) async {
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
    final db = ref.read(databaseProvider);
    final created = await (db.select(
      db.airports,
    )..where((t) => t.id.equals(airportId))).getSingleOrNull();
    if (!mounted || created == null) return;
    if (!mounted) return;
    final replacement = _airportReplacementCode(created, issue.currentValue);
    _setFieldResolution(issue: issue, replacement: replacement);
  }

  bool _isAircraftIssue(LogTenImportIssue issue) {
    return issue.association == LogTenFieldAssociation.registration;
  }

  Future<void> _pickAircraft(
    LogTenImportIssue issue, {
    required bool onlySimulators,
  }) async {
    final selected = await AircraftPickerDialog.show(
      context,
      title: AppLocalizations.of(context)!.logtenSelectAircraft,
      onlySimulators: onlySimulators,
    );
    if (selected == null || !mounted) return;
    _setFieldResolution(
      issue: issue,
      replacement: selected.registration.trim().toUpperCase(),
    );
  }

  Future<void> _createAircraft(
    LogTenImportIssue issue, {
    required bool isSimulator,
  }) async {
    final raw = issue.currentValue.trim().toUpperCase();
    const placeholder = Aircraft(
      id: kPlaceholderId,
      aircraftTypeId: 0,
      registration: '',
      isSimulator: false,
      isFavorite: false,
      isLocked: false,
    );
    final created = await showDialog<dynamic>(
      context: context,
      builder: (_) => AircraftEditScreen(
        item: placeholder,
        isCreate: true,
        initialIsSimulator: isSimulator,
        initialRegistration: raw,
      ),
    );
    if (!mounted || created != true) return;
    final db = ref.read(databaseProvider);
    final row =
        await (db.select(db.aircrafts)
              ..where((t) => t.isSimulator.equals(isSimulator))
              ..orderBy([(t) => OrderingTerm.desc(t.id)])
              ..limit(1))
            .getSingleOrNull();
    if (row == null || !mounted) return;
    _setFieldResolution(
      issue: issue,
      replacement: row.registration.trim().toUpperCase(),
    );
  }

  String _airportReplacementCode(Airport airport, String originalValue) {
    final trimmedOriginal = originalValue.trim().toUpperCase();
    if (trimmedOriginal.length == 3 && (airport.iata ?? '').trim().isNotEmpty) {
      return airport.iata!.trim().toUpperCase();
    }
    return airport.icao.trim().toUpperCase();
  }

  void _ignoreAll() {
    setState(() {
      _ignoredLines.addAll(
        widget.issues.map((issue) => issue.lineNumber),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lineNumbers =
        widget.issues.map((issue) => issue.lineNumber).toSet().toList()..sort();
    final body = ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(l10n.logtenReviewHelpText),
                ),
                TextButton(
                  onPressed: _ignoreAll,
                  child: Text(l10n.logtenIgnoreAllAction),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: lineNumbers.length,
              itemBuilder: (context, index) {
                final lineNumber = lineNumbers[index];
                final lineIssues = widget.issues
                    .where((issue) => issue.lineNumber == lineNumber)
                    .toList(growable: false);
                final supportsSimulatorChoice = _lineSupportsSimulatorChoice(
                  lineIssues,
                );
                final simulatorSelected = _simulatorLines.contains(lineNumber);
                final ignored = _ignoredLines.contains(lineNumber);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.logtenLineLabel(lineNumber),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            FilterChip(
                              selected: ignored,
                              label: Text(l10n.logtenIgnoreLineAction),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _ignoredLines.add(lineNumber);
                                  } else {
                                    _ignoredLines.remove(lineNumber);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (supportsSimulatorChoice) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(l10n.logtenEntryTypeLabel),
                              ChoiceChip(
                                label: Text(l10n.logtenFlightLabel),
                                selected: !simulatorSelected,
                                onSelected: ignored
                                    ? null
                                    : (_) => _setLineAsSimulator(
                                        lineNumber,
                                        false,
                                      ),
                              ),
                              ChoiceChip(
                                label: Text(l10n.logtenSimulatorLabel),
                                selected: simulatorSelected,
                                onSelected: ignored
                                    ? null
                                    : (_) => _setLineAsSimulator(
                                        lineNumber,
                                        true,
                                      ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (simulatorSelected)
                            Text(l10n.logtenReviewSimulatorSelectedHelp),
                          const SizedBox(height: 12),
                        ],
                        for (final issue in lineIssues) ...[
                          if (simulatorSelected && _isAirportIssue(issue))
                            const SizedBox.shrink()
                          else ...[
                            Text(
                              issue.association.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(issue.reason),
                            const SizedBox(height: 12),
                            if (_isAirportIssue(issue))
                              Opacity(
                                opacity: ignored ? 0.6 : 1,
                                child: IgnorePointer(
                                  ignoring: ignored,
                                  child: PickerWithAddInputField(
                                    label: issue.association.label,
                                    valueText:
                                        _controllers[lineNumber]![issue
                                                .association]!
                                            .text
                                            .trim()
                                            .isEmpty
                                        ? l10n.logtenNotSelected
                                        : _controllers[lineNumber]![issue
                                                  .association]!
                                              .text
                                              .trim(),
                                    onTap: () => _pickAirport(issue),
                                    onAdd: () => _createAirport(issue),
                                    addTooltip: l10n.logtenCreateAirportTooltip,
                                  ),
                                ),
                              )
                            else if (_isAircraftIssue(issue))
                              Opacity(
                                opacity: ignored ? 0.6 : 1,
                                child: IgnorePointer(
                                  ignoring: ignored,
                                  child: PickerWithAddInputField(
                                    label: l10n.screenAircraft,
                                    valueText:
                                        _controllers[lineNumber]![issue
                                                .association]!
                                            .text
                                            .trim()
                                            .isEmpty
                                        ? l10n.logtenNotSelected
                                        : _controllers[lineNumber]![issue
                                                  .association]!
                                              .text
                                              .trim(),
                                    onTap: () => _pickAircraft(
                                      issue,
                                      onlySimulators: simulatorSelected,
                                    ),
                                    onAdd: () => _createAircraft(
                                      issue,
                                      isSimulator: simulatorSelected,
                                    ),
                                    addTooltip:
                                        l10n.logtenCreateAircraftTooltip,
                                  ),
                                ),
                              )
                            else
                              TextField(
                                controller:
                                    _controllers[lineNumber]![issue
                                        .association],
                                enabled: !ignored,
                                decoration: InputDecoration(
                                  labelText: l10n.logtenCorrectedValueLabel,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    return SizedBox(
      width: 980,
      child: AdaptiveFormShell(
        onClose: () => AppNavigator.pop(context),
        title: l10n.logtenReviewTitle,
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text(l10n.logtenContinueAction),
          ),
        ],
        contentView: body,
      ),
    );
  }
}
