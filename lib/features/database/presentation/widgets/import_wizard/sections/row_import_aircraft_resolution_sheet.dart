// Stateful resolution form; field-level docs would be repetitive noise.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:simplelog/core/constants/app_constants.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/inputs/picker_with_add_input_field.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/import/pipeline/row_import_aircraft_issue.dart';
import 'package:simplelog/features/aircraft/presentation/aircraft_edit_screen.dart';
import 'package:simplelog/features/aircraft/presentation/widgets/aircraft_picker_dialog.dart';

/// Shared missing-aircraft resolution sheet for row-based imports.
class RowImportAircraftResolutionSheet extends StatefulWidget {
  const RowImportAircraftResolutionSheet({
    required this.db,
    required this.title,
    required this.issues,
    super.key,
  });

  final AppDatabase db;
  final String title;
  final List<RowImportAircraftIssue> issues;

  static Future<RowImportAircraftResolution?> show(
    BuildContext context, {
    required AppDatabase db,
    required String title,
    required List<RowImportAircraftIssue> issues,
  }) {
    final screen = RowImportAircraftResolutionSheet(
      db: db,
      title: title,
      issues: issues,
    );
    final compact = MediaQuery.sizeOf(context).width < 600;
    if (compact) {
      return AppNavigator.pushMaterial<RowImportAircraftResolution>(
        context,
        (_) => screen,
        rootNavigator: true,
      );
    }
    return showDialog<RowImportAircraftResolution>(
      context: context,
      barrierDismissible: false,
      builder: (_) => screen,
    );
  }

  @override
  State<RowImportAircraftResolutionSheet> createState() =>
      _RowImportAircraftResolutionSheetState();
}

class _RowImportAircraftResolutionSheetState
    extends State<RowImportAircraftResolutionSheet> {
  late final Map<int, String> _replacements;
  late final Set<int> _skippedLines;
  late final List<RowImportAircraftIssue> _pendingIssues;

  @override
  void initState() {
    super.initState();
    _replacements = <int, String>{};
    _skippedLines = <int>{};
    _pendingIssues = List<RowImportAircraftIssue>.from(widget.issues);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AdaptiveFormShell(
      onClose: () => AppNavigator.pop(context),
      title: widget.title,
      popupMaxWidth: 760,
      actions: [
        TextButton(
          onPressed: _submit,
          child: Text(l10n.logtenContinueAction),
        ),
      ],
      contentView: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingIssues.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          final issue = _pendingIssues[index];
          final isSkipped = _skippedLines.contains(issue.lineNumber);
          final value = _replacements[issue.lineNumber]?.trim() ?? '';
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.logtenLineLabel(issue.lineNumber)),
                  const SizedBox(height: 4),
                  Text(issue.reason),
                  const SizedBox(height: 8),
                  if (!isSkipped)
                    PickerWithAddInputField(
                      label: issue.kind == RowImportAircraftKind.simulator
                          ? l10n.logtenSimulatorLabel
                          : l10n.screenAircraft,
                      valueText: value.isEmpty ? l10n.logtenNotSelected : value,
                      onTap: () => _pickAircraft(issue),
                      onAdd: () => _createAircraft(issue),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            if (_skippedLines.contains(issue.lineNumber)) {
                              _skippedLines.remove(issue.lineNumber);
                            } else {
                              _skippedLines.add(issue.lineNumber);
                            }
                          });
                        },
                        child: Text(
                          isSkipped
                              ? l10n.waderReviewIncludeLineAction
                              : l10n.waderReviewIgnoreLineAction,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    AppNavigator.pop(
      context,
      RowImportAircraftResolution(
        replacements: _replacements,
        skippedLines: _skippedLines,
      ),
    );
  }

  Future<void> _pickAircraft(RowImportAircraftIssue issue) async {
    final selected = await AircraftPickerDialog.show(
      context,
      title: AppLocalizations.of(context)!.logtenSelectAircraft,
      onlySimulators: issue.kind == RowImportAircraftKind.simulator,
    );
    if (selected == null || !mounted) {
      return;
    }
    setState(() {
      _replacements[issue.lineNumber] = selected.registration
          .trim()
          .toUpperCase();
      _skippedLines.remove(issue.lineNumber);
    });
    await _refreshPendingIssues();
  }

  Future<void> _createAircraft(RowImportAircraftIssue issue) async {
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
        initialIsSimulator: issue.kind == RowImportAircraftKind.simulator,
        initialRegistration: issue.registration,
      ),
    );
    if (!mounted || created != true) {
      return;
    }
    final row =
        await (widget.db.select(widget.db.aircrafts)
              ..where(
                (t) => t.registration.equals(issue.registration.toUpperCase()),
              )
              ..limit(1))
            .getSingleOrNull();
    if (!mounted || row == null) {
      return;
    }
    setState(() {
      _replacements[issue.lineNumber] = row.registration.trim().toUpperCase();
      _skippedLines.remove(issue.lineNumber);
    });
    await _refreshPendingIssues();
  }

  Future<void> _refreshPendingIssues() async {
    final existingKeys = <String>{
      for (final aircraft in await widget.db.select(widget.db.aircrafts).get())
        _aircraftIdentityKey(
          aircraft.registration.trim().toUpperCase(),
          aircraft.isSimulator,
        ),
    };
    final next = <RowImportAircraftIssue>[];
    for (final issue in _pendingIssues) {
      if (_skippedLines.contains(issue.lineNumber)) {
        next.add(issue);
        continue;
      }
      final replacement = _replacements[issue.lineNumber]?.trim().toUpperCase();
      if (replacement != null && replacement.isNotEmpty) {
        continue;
      }
      final issueKey = _aircraftIdentityKey(
        issue.registration.trim().toUpperCase(),
        issue.kind == RowImportAircraftKind.simulator,
      );
      if (existingKeys.contains(issueKey)) {
        continue;
      }
      next.add(issue);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _pendingIssues
        ..clear()
        ..addAll(next);
    });
  }

  String _aircraftIdentityKey(String registration, bool isSimulator) {
    return '$registration|${isSimulator ? 1 : 0}';
  }
}
