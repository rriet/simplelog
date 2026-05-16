// Stateful form widget; constructor/member docs are intentionally concise.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/info_help_button.dart';
import 'package:simplelog/data/import/unified_import_options.dart';
import 'package:simplelog/features/database/presentation/widgets/import_wizard/sections/import_conflict_resolution_section.dart';
import 'package:simplelog/features/database/presentation/widgets/import_wizard/sections/import_recalculation_section.dart';

/// Shared options dialog shown before non-database imports.
class UnifiedImportOptionsDialog extends StatefulWidget {
  const UnifiedImportOptionsDialog({
    required this.fileName,
    required this.title,
    required this.initial,
    super.key,
  });

  final String fileName;
  final String title;
  final UnifiedImportOptions initial;

  static Future<UnifiedImportOptions?> show(
    BuildContext context, {
    required String fileName,
    required String title,
    required UnifiedImportOptions initial,
  }) {
    final screen = UnifiedImportOptionsDialog(
      fileName: fileName,
      title: title,
      initial: initial,
    );
    final isCompact = MediaQuery.sizeOf(context).width < 600;
    if (isCompact) {
      return AppNavigator.pushMaterial<UnifiedImportOptions>(
        context,
        (_) => screen,
        rootNavigator: true,
      );
    }
    return showDialog<UnifiedImportOptions>(
      context: context,
      builder: (_) => screen,
    );
  }

  @override
  State<UnifiedImportOptionsDialog> createState() =>
      _UnifiedImportOptionsDialogState();
}

class _UnifiedImportOptionsDialogState
    extends State<UnifiedImportOptionsDialog> {
  late bool _recalcTotal;
  late bool _recalcNight;
  late bool _recalcTakeoffLanding;
  late bool _recalcCrossCountry;
  late bool _recalcIfr;
  late bool _overrideAirport;
  late bool _overrideAircraft;
  late bool _overrideType;

  var _showRecalculations = true;
  var _showConflictResolution = true;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _recalcTotal = initial.recalculateTotalTime;
    _recalcNight = initial.recalculateNightTime;
    _recalcTakeoffLanding = initial.recalculateTakeoffLanding;
    _recalcCrossCountry = initial.recalculateCrossCountry;
    _recalcIfr = initial.recalculateIfrTime;
    _overrideAirport = initial.overrideAirportOnConflict;
    _overrideAircraft = initial.overrideAircraftOnConflict;
    _overrideType = initial.overrideTypeOnConflict;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AdaptiveFormShell(
      onClose: () => AppNavigator.pop(context),
      title: widget.title,
      popupMaxWidth: 560,
      actions: [
        TextButton(
          onPressed: () => AppNavigator.pop(context, _buildOptions()),
          child: Text(l10n.simplelogImportAction),
        ),
      ],
      contentView: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(l10n.databaseFileLabel(widget.fileName))),
                InfoHelpButton(
                  title: l10n.databaseImportExportInfoTitle,
                  message: l10n.databaseImportExportInfoMessage,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ImportRecalculationSection(
              labels: ImportRecalculationSectionLabels(
                title: l10n.simplelogRecalculationsTitle,
                recalculateTotal: l10n.simplelogRecalcTotalTimeLabel,
                recalculateNight: l10n.simplelogNightTimeLabel,
                recalculateTakeoffLanding: l10n.simplelogTakeoffLandingsLabel,
                recalculateCrossCountry: l10n.simplelogCrossCountryLabel,
                recalculateIfr: l10n.simplelogIfrTimeLabel,
              ),
              initiallyExpanded: _showRecalculations,
              onExpansionChanged: (expanded) =>
                  setState(() => _showRecalculations = expanded),
              recalcTotalValue: _recalcTotal,
              onRecalcTotalChanged: (v) => setState(() => _recalcTotal = v),
              recalcNightValue: _recalcNight,
              onRecalcNightChanged: (v) => setState(() => _recalcNight = v),
              recalcTakeoffLandingValue: _recalcTakeoffLanding,
              onRecalcTakeoffLandingChanged: (v) =>
                  setState(() => _recalcTakeoffLanding = v),
              recalcCrossCountryValue: _recalcCrossCountry,
              onRecalcCrossCountryChanged: (v) =>
                  setState(() => _recalcCrossCountry = v),
              recalcIfrValue: _recalcIfr,
              onRecalcIfrChanged: (v) => setState(() => _recalcIfr = v),
            ),
            const SizedBox(height: 8),
            ImportConflictResolutionSection(
              title: l10n.simplelogConflictResolutionTitle,
              initiallyExpanded: _showConflictResolution,
              onExpansionChanged: (expanded) =>
                  setState(() => _showConflictResolution = expanded),
              toggles: [
                ImportConflictToggleConfig(
                  label: l10n.simplelogOverrideAirportOnConflict,
                  value: _overrideAirport,
                  onChanged: (v) => setState(() => _overrideAirport = v),
                ),
                ImportConflictToggleConfig(
                  label: l10n.simplelogOverrideAircraftOnConflict,
                  value: _overrideAircraft,
                  onChanged: (v) => setState(() => _overrideAircraft = v),
                ),
                ImportConflictToggleConfig(
                  label: l10n.simplelogOverrideAircraftTypeOnConflict,
                  value: _overrideType,
                  onChanged: (v) => setState(() => _overrideType = v),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  UnifiedImportOptions _buildOptions() {
    return UnifiedImportOptions(
      recalculateTotalTime: _recalcTotal,
      recalculateNightTime: _recalcNight,
      recalculateTakeoffLanding: _recalcTakeoffLanding,
      recalculateCrossCountry: _recalcCrossCountry,
      recalculateIfrTime: _recalcIfr,
      overrideAirportOnConflict: _overrideAirport,
      overrideAircraftOnConflict: _overrideAircraft,
      overrideTypeOnConflict: _overrideType,
    );
  }
}
