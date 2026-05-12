import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/features/database/presentation/widgets/import_wizard/sections/import_critical_issues_sheet.dart';

/// Missing simulator aircraft identified during Qatar Airways preflight.
class QatarAirwaysMissingAircraft {
  /// Creates a missing-aircraft entry.
  const QatarAirwaysMissingAircraft({
    required this.registration,
    required this.aircraftTypeCode,
  });

  /// Missing registration from the workbook.
  final String registration;

  /// Aircraft type code found on the same row.
  final String aircraftTypeCode;
}

/// Dialog used to resolve missing airports before continuing import.
class QatarAirwaysMissingAirportsDialog {
  /// Opens the dialog and returns `true` when import may continue.
  static Future<bool> show(
    BuildContext context, {
    required List<String> missingIataCodes,
    required Future<bool> Function(String iataCode) onCreateAirport,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return ImportCriticalPendingItemsSheet.show<String>(
      context,
      title: l10n.qatarMissingAirportsTitle,
      message: l10n.qatarMissingAirportsMessage,
      pendingItems: missingIataCodes,
      actionLabel: l10n.qatarCreateAirportAction,
      continueActionLabel: l10n.qatarContinueAction,
      cancelActionLabel: l10n.cancelAction,
      itemLabelBuilder: (code) => code,
      onResolveItem: onCreateAirport,
    );
  }
}

/// Dialog used to resolve missing simulator aircraft before continuing import.
class QatarAirwaysMissingAircraftDialog {
  /// Opens the dialog and returns `true` when import may continue.
  static Future<bool> show(
    BuildContext context, {
    required List<QatarAirwaysMissingAircraft> missingAircraft,
    required Future<bool> Function(QatarAirwaysMissingAircraft aircraft)
    onCreateAircraft,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return ImportCriticalPendingItemsSheet.show<QatarAirwaysMissingAircraft>(
      context,
      title: l10n.qatarMissingAircraftTitle,
      message: l10n.qatarMissingAircraftMessage,
      pendingItems: missingAircraft,
      actionLabel: l10n.qatarCreateAircraftAction,
      continueActionLabel: l10n.qatarContinueAction,
      cancelActionLabel: l10n.cancelAction,
      itemLabelBuilder: (aircraft) =>
          '${aircraft.registration} (${aircraft.aircraftTypeCode})',
      onResolveItem: onCreateAircraft,
    );
  }
}
