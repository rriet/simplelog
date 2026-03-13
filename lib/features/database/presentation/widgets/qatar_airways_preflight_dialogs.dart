import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';

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
class QatarAirwaysMissingAirportsDialog extends StatefulWidget {
  /// Creates the dialog.
  const QatarAirwaysMissingAirportsDialog({
    required this.missingIataCodes,
    required this.onCreateAirport,
    super.key,
  });

  /// Unique unresolved IATA codes.
  final List<String> missingIataCodes;

  /// Callback that opens airport creation for a code.
  final Future<bool> Function(String iataCode) onCreateAirport;

  /// Opens the dialog and returns `true` when import may continue.
  static Future<bool> show(
    BuildContext context, {
    required List<String> missingIataCodes,
    required Future<bool> Function(String iataCode) onCreateAirport,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => QatarAirwaysMissingAirportsDialog(
        missingIataCodes: missingIataCodes,
        onCreateAirport: onCreateAirport,
      ),
    );
    return result ?? false;
  }

  @override
  State<QatarAirwaysMissingAirportsDialog> createState() =>
      _QatarAirwaysMissingAirportsDialogState();
}

class _QatarAirwaysMissingAirportsDialogState
    extends State<QatarAirwaysMissingAirportsDialog> {
  late final List<String> _pendingCodes;
  bool _busy = false;

  void _setBusy(bool value) {
    setState(() => _busy = value);
  }

  void _applyAirportCreated(String code, bool resolved) {
    setState(() {
      _busy = false;
      if (resolved) {
        _pendingCodes.remove(code);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _pendingCodes = List<String>.from(widget.missingIataCodes);
  }

  Future<void> _createAirport(String code) async {
    _setBusy(true);
    final resolved = await widget.onCreateAirport(code);
    if (!mounted) return;
    _applyAirportCreated(code, resolved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: const Text('Missing Airports'),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.qatarMissingAirportsMessage),
            const SizedBox(height: 12),
            SizedBox(
              height: 280,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final code in _pendingCodes)
                      _buildPendingResolveCodeRow(code),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => AppNavigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy || _pendingCodes.isNotEmpty
              ? null
              : () => AppNavigator.pop(context, true),
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _buildPendingResolveCodeRow(String code) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _PendingResolveRow(
        label: code,
        actionLabel: 'Create airport',
        enabled: !_busy,
        onPressed: () => _createAirport(code),
      ),
    );
  }
}

/// Dialog used to resolve missing simulator aircraft before continuing import.
class QatarAirwaysMissingAircraftDialog extends StatefulWidget {
  /// Creates the dialog.
  const QatarAirwaysMissingAircraftDialog({
    required this.missingAircraft,
    required this.onCreateAircraft,
    super.key,
  });

  /// Unique unresolved simulator registrations.
  final List<QatarAirwaysMissingAircraft> missingAircraft;

  /// Callback that opens aircraft creation for a registration.
  final Future<bool> Function(QatarAirwaysMissingAircraft aircraft)
  onCreateAircraft;

  /// Opens the dialog and returns `true` when import may continue.
  static Future<bool> show(
    BuildContext context, {
    required List<QatarAirwaysMissingAircraft> missingAircraft,
    required Future<bool> Function(QatarAirwaysMissingAircraft aircraft)
    onCreateAircraft,
  }) {
    final screen = QatarAirwaysMissingAircraftDialog(
      missingAircraft: missingAircraft,
      onCreateAircraft: onCreateAircraft,
    );
    final isCompact = MediaQuery.sizeOf(context).width < 600;
    if (isCompact) {
      return AppNavigator.pushMaterial<bool>(
        context,
        (_) => screen,
        rootNavigator: true,
      ).then((value) => value ?? false);
    }
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => screen,
    ).then((value) => value ?? false);
  }

  @override
  State<QatarAirwaysMissingAircraftDialog> createState() =>
      _QatarAirwaysMissingAircraftDialogState();
}

class _QatarAirwaysMissingAircraftDialogState
    extends State<QatarAirwaysMissingAircraftDialog> {
  late final List<QatarAirwaysMissingAircraft> _pendingAircraft;
  bool _busy = false;

  void _setBusy(bool value) {
    setState(() => _busy = value);
  }

  void _applyAircraftCreated(
    QatarAirwaysMissingAircraft aircraft,
    bool resolved,
  ) {
    setState(() {
      _busy = false;
      if (resolved) {
        _pendingAircraft.removeWhere(
          (candidate) => candidate.registration == aircraft.registration,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _pendingAircraft = List<QatarAirwaysMissingAircraft>.from(
      widget.missingAircraft,
    );
  }

  Future<void> _createAircraft(QatarAirwaysMissingAircraft aircraft) async {
    _setBusy(true);
    final resolved = await widget.onCreateAircraft(aircraft);
    if (!mounted) return;
    _applyAircraftCreated(aircraft, resolved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final body = Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.qatarMissingAircraftMessage),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _pendingAircraft.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final aircraft = _pendingAircraft[index];
                    return _buildPendingResolveAircraftRow(aircraft);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return AdaptiveFormShell(
      onClose: _busy ? () {} : () => AppNavigator.pop(context, false),
      longTitle: 'Missing Aircraft',
      shortTitle: 'Missing Aircraft',
      actions: [
        TextButton(
          onPressed: _busy || _pendingAircraft.isNotEmpty
              ? null
              : () => AppNavigator.pop(context, true),
          child: const Text('Continue'),
        ),
      ],
      contentView: body,
    );
  }

  Widget _buildPendingResolveAircraftRow(QatarAirwaysMissingAircraft aircraft) {
    return _PendingResolveRow(
      label: '${aircraft.registration} (${aircraft.aircraftTypeCode})',
      actionLabel: 'Create aircraft',
      enabled: !_busy,
      onPressed: () => _createAircraft(aircraft),
    );
  }
}

class _PendingResolveRow extends StatelessWidget {
  const _PendingResolveRow({
    required this.label,
    required this.actionLabel,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final String actionLabel;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        FilledButton(
          onPressed: enabled ? onPressed : null,
          child: Text(actionLabel),
        ),
      ],
    );
  }
}
