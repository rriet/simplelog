// Stateful resolution form; field-level docs would be repetitive noise.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:simplelog/core/constants/app_constants.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/inputs/picker_with_add_input_field.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/import/pipeline/row_import_airport_issue.dart';
import 'package:simplelog/features/airports/presentation/airport_edit_screen.dart';
import 'package:simplelog/features/airports/presentation/widgets/airport_picker_dialog.dart';

/// Shared airport resolution sheet for row-based imports.
class RowImportAirportResolutionSheet extends StatefulWidget {
  const RowImportAirportResolutionSheet({
    required this.db,
    required this.title,
    required this.issues,
    super.key,
  });

  final AppDatabase db;
  final String title;
  final List<RowImportAirportIssue> issues;

  static Future<RowImportAirportResolution?> show(
    BuildContext context, {
    required AppDatabase db,
    required String title,
    required List<RowImportAirportIssue> issues,
  }) {
    final screen = RowImportAirportResolutionSheet(
      db: db,
      title: title,
      issues: issues,
    );
    final compact = MediaQuery.sizeOf(context).width < 600;
    if (compact) {
      return AppNavigator.pushMaterial<RowImportAirportResolution>(
        context,
        (_) => screen,
        rootNavigator: true,
      );
    }
    return showDialog<RowImportAirportResolution>(
      context: context,
      barrierDismissible: false,
      builder: (_) => screen,
    );
  }

  @override
  State<RowImportAirportResolutionSheet> createState() =>
      _RowImportAirportResolutionSheetState();
}

class _RowImportAirportResolutionSheetState
    extends State<RowImportAirportResolutionSheet> {
  late final Map<int, Map<RowImportAirportField, String>> _replacements;
  late final Set<int> _skippedLines;
  late final List<RowImportAirportIssue> _pendingIssues;

  @override
  void initState() {
    super.initState();
    _replacements = <int, Map<RowImportAirportField, String>>{};
    _skippedLines = <int>{};
    _pendingIssues = List<RowImportAirportIssue>.from(widget.issues);
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
          final value =
              _replacements[issue.lineNumber]?[issue.field]?.trim() ?? '';
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
                      label: issue.field == RowImportAirportField.departure
                          ? l10n.waderFieldDepartureAirport
                          : l10n.waderFieldArrivalAirport,
                      valueText: value.isEmpty ? l10n.logtenNotSelected : value,
                      onTap: () => _pickAirport(issue),
                      onAdd: () => _createAirport(issue),
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
      RowImportAirportResolution(
        replacements: _replacements,
        skippedLines: _skippedLines,
      ),
    );
  }

  Future<void> _pickAirport(RowImportAirportIssue issue) async {
    final selected = await AirportPickerDialog.show(
      context,
      title: issue.field == RowImportAirportField.departure
          ? AppLocalizations.of(context)!.logtenSelectDepartureAirport
          : AppLocalizations.of(context)!.logtenSelectArrivalAirport,
    );
    if (selected == null || !mounted) {
      return;
    }
    if (mounted) {
      setState(() {
        _replacements.putIfAbsent(issue.lineNumber, () => {});
        _replacements[issue.lineNumber]![issue.field] =
            _replacementCodeForIssue(
              issue,
              selected,
            );
        _skippedLines.remove(issue.lineNumber);
      });
    }
    await _refreshPendingIssues();
  }

  Future<void> _createAirport(RowImportAirportIssue issue) async {
    final raw = issue.code.trim().toUpperCase();
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
    if (mounted) {
      setState(() {
        _replacements.putIfAbsent(issue.lineNumber, () => {});
        _replacements[issue.lineNumber]![issue.field] =
            _replacementCodeForIssue(
              issue,
              created,
            );
        _skippedLines.remove(issue.lineNumber);
      });
    }
    await _refreshPendingIssues();
  }

  Future<void> _refreshPendingIssues() async {
    final knownIcaoCodes = <String>{};
    final knownIataCodes = <String>{};
    for (final airport in await widget.db.select(widget.db.airports).get()) {
      knownIcaoCodes.add(airport.icao.trim().toUpperCase());
      final iata = (airport.iata ?? '').trim().toUpperCase();
      if (iata.isNotEmpty) {
        knownIataCodes.add(iata);
      }
    }
    final next = <RowImportAirportIssue>[];
    for (final issue in _pendingIssues) {
      if (_skippedLines.contains(issue.lineNumber)) {
        next.add(issue);
        continue;
      }
      final replacement = _replacements[issue.lineNumber]?[issue.field]
          ?.trim()
          .toUpperCase();
      if (replacement != null && replacement.isNotEmpty) {
        continue;
      }
      final code = issue.code.trim().toUpperCase();
      final missing = issue.reason.toLowerCase().contains('missing');
      final validCode = issue.codeKind == RowImportAirportCodeKind.iata
          ? RegExp(r'^[A-Z0-9]{3}$').hasMatch(code)
          : RegExp(r'^[A-Z0-9]{4}$').hasMatch(code);
      final knownCodes = issue.codeKind == RowImportAirportCodeKind.iata
          ? knownIataCodes
          : knownIcaoCodes;
      if (!missing && validCode && knownCodes.contains(code)) {
        continue;
      }
      next.add(issue);
    }
    if (!mounted) return;
    if (mounted) {
      setState(() {
        _pendingIssues
          ..clear()
          ..addAll(next);
      });
    }
  }

  String _replacementCodeForIssue(
    RowImportAirportIssue issue,
    Airport airport,
  ) {
    if (issue.codeKind == RowImportAirportCodeKind.iata) {
      final iata = (airport.iata ?? '').trim().toUpperCase();
      if (iata.isNotEmpty) {
        return iata;
      }
    }
    return airport.icao.trim().toUpperCase();
  }
}
