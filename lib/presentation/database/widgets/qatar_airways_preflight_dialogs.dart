import 'package:flutter/material.dart';
import 'package:simplelog/presentation/shared/widgets/adaptive_form_shell.dart';
import 'package:simplelog/presentation/shared/widgets/dialog_adaptive_presenter.dart';

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

  @override
  void initState() {
    super.initState();
    _pendingCodes = List<String>.from(widget.missingIataCodes);
  }

  Future<void> _createAirport(String code) async {
    setState(() => _busy = true);
    final resolved = await widget.onCreateAirport(code);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (resolved) {
        _pendingCodes.remove(code);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Missing Airports'),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create the missing airports before continuing '
              'the Qatar Airways import.',
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 280,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final code in _pendingCodes)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text(code)),
                            FilledButton(
                              onPressed: _busy
                                  ? null
                                  : () => _createAirport(code),
                              child: const Text('Create airport'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy || _pendingCodes.isNotEmpty
              ? null
              : () => Navigator.of(context).pop(true),
          child: const Text('Continue'),
        ),
      ],
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
  }) async {
    final result = await showLargeDialogScreen<bool>(
      context: context,
      barrierDismissible: false,
      maxWidth: 700,
      builder: (context) => QatarAirwaysMissingAircraftDialog(
        missingAircraft: missingAircraft,
        onCreateAircraft: onCreateAircraft,
      ),
    );
    return result ?? false;
  }

  @override
  State<QatarAirwaysMissingAircraftDialog> createState() =>
      _QatarAirwaysMissingAircraftDialogState();
}

class _QatarAirwaysMissingAircraftDialogState
    extends State<QatarAirwaysMissingAircraftDialog> {
  late final List<QatarAirwaysMissingAircraft> _pendingAircraft;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _pendingAircraft = List<QatarAirwaysMissingAircraft>.from(
      widget.missingAircraft,
    );
  }

  Future<void> _createAircraft(QatarAirwaysMissingAircraft aircraft) async {
    setState(() => _busy = true);
    final resolved = await widget.onCreateAircraft(aircraft);
    if (!mounted) return;
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
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create the missing simulator aircraft before continuing '
                'the Qatar Airways import.',
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _pendingAircraft.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final aircraft = _pendingAircraft[index];
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${aircraft.registration} '
                            '(${aircraft.aircraftTypeCode})',
                          ),
                        ),
                        FilledButton(
                          onPressed: _busy
                              ? null
                              : () => _createAircraft(aircraft),
                          child: const Text('Create aircraft'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return AdaptiveFormShell(
      onClose: _busy ? () {} : () => Navigator.of(context).pop(false),
      longTitle: 'Missing Aircraft',
      shortTitle: 'Missing Aircraft',
      actions: [
        TextButton(
          onPressed: _busy || _pendingAircraft.isNotEmpty
              ? null
              : () => Navigator.of(context).pop(true),
          child: const Text('Continue'),
        ),
      ],
      contentView: body,
    );
  }
}
