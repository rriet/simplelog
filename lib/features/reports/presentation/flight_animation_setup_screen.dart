import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/app_message_dialog.dart';
import 'package:simplelog/core/presentation/widgets/inputs/dropdown_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/number_input_field.dart';
import 'package:simplelog/data/models/reports_models.dart';
import 'package:simplelog/features/reports/presentation/providers/reports_repository_provider.dart';

/// Phase-one setup UI for flight animation parameters.
class FlightAnimationSetupScreen extends ConsumerStatefulWidget {
  /// Creates a setup screen for the current reports query.
  const FlightAnimationSetupScreen({
    required this.query,
    super.key,
  });

  /// Reports query whose date range and filters define the flight selection.
  final ReportsQuery query;

  /// Presents the setup UI and returns prepared phase-one data.
  static Future<FlightAnimationSetupResult?> show(
    BuildContext context, {
    required ReportsQuery query,
  }) {
    final screen = FlightAnimationSetupScreen(query: query);
    final compact = MediaQuery.sizeOf(context).width < 600;
    if (compact) {
      return AppNavigator.pushMaterial<FlightAnimationSetupResult>(
        context,
        (_) => screen,
        rootNavigator: true,
        fullscreenDialog: true,
      );
    }
    return showDialog<FlightAnimationSetupResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => screen,
    );
  }

  @override
  ConsumerState<FlightAnimationSetupScreen> createState() =>
      _FlightAnimationSetupScreenState();
}

class _FlightAnimationSetupScreenState
    extends ConsumerState<FlightAnimationSetupScreen> {
  final _durationController = TextEditingController(text: '3');
  FlightAnimationStyle _style = FlightAnimationStyle.manualZoom;
  double _lookBehind = 1;
  double _lookAhead = 1;
  double _cameraSpeed = 0.01;
  double _cameraPadding = 1.8;
  bool _fadePastFlights = false;
  double _fadeDurationPercent = 5;
  double _finalFadeLevelPercent = 5;
  bool _loading = false;
  String? _durationError;

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMMMd();
    final rangeText =
        '${dateFormat.format(widget.query.from.toLocal())} - '
        '${dateFormat.format(widget.query.to.toLocal())}';
    return AdaptiveFormShell(
      title: l10n.flightAnimationTitle,
      popupMaxWidth: 520,
      onClose: _loading ? () {} : () => AppNavigator.pop(context),
      actions: [
        TextButton(
          onPressed: _loading ? null : _prepareFlights,
          child: Text(
            _loading
                ? l10n.flightAnimationSetupLoading
                : l10n.flightAnimationSetupContinue,
          ),
        ),
      ],
      contentView: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.flightAnimationSetupDateRange,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 6),
          Text(rangeText),
          if (widget.query.filters.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              l10n.flightAnimationSetupFiltersApplied(
                widget.query.filters.length,
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 18),
          NumberInputField(
            controller: _durationController,
            label: l10n.flightAnimationSetupDurationLabel,
            errorText: _durationError,
            onChanged: (_) {
              if (_durationError != null) {
                setState(() => _durationError = null);
              }
            },
          ),
          const SizedBox(height: 14),
          DropdownInputField<FlightAnimationStyle>(
            label: l10n.flightAnimationSetupStyleLabel,
            value: _style,
            items: FlightAnimationStyle.values
                .map(
                  (style) => DropdownMenuItem<FlightAnimationStyle>(
                    value: style,
                    child: Text(_styleLabel(style)),
                  ),
                )
                .toList(growable: false),
            onChanged: _loading
                ? (_) {}
                : (value) {
                    if (value == null) return;
                    setState(() => _style = value);
                  },
          ),
          if (_style == FlightAnimationStyle.automatic) ...[
            const SizedBox(height: 14),
            Text(
              '${l10n.flightAnimationSetupLookBehindLabel}:'
              ' ${_lookBehind.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Slider(
              value: _lookBehind,
              max: 5,
              divisions: 50,
              label: _lookBehind.toStringAsFixed(1),
              onChanged: (v) => setState(() => _lookBehind = v),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.flightAnimationSetupLookAheadLabel}:'
              ' ${_lookAhead.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Slider(
              value: _lookAhead,
              max: 5,
              divisions: 50,
              label: _lookAhead.toStringAsFixed(1),
              onChanged: (v) => setState(() => _lookAhead = v),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.flightAnimationSetupCameraSpeedLabel}:'
              ' ${_cameraSpeed.toStringAsFixed(3)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Slider(
              value: _cameraSpeed,
              min: 0.001,
              max: 0.070,
              divisions: 69,
              label: _cameraSpeed.toStringAsFixed(3),
              onChanged: (v) => setState(() => _cameraSpeed = v),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.flightAnimationSetupCameraPaddingLabel}:'
              ' ${_cameraPadding.toStringAsFixed(1)}°',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Slider(
              value: _cameraPadding,
              min: 0.1,
              max: 8,
              divisions: 79,
              label: _cameraPadding.toStringAsFixed(1),
              onChanged: (v) => setState(() => _cameraPadding = v),
            ),
          ],
          const SizedBox(height: 14),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.flightAnimationSetupFadePastFlights),
            value: _fadePastFlights,
            onChanged: (v) => setState(() => _fadePastFlights = v),
          ),
          if (_fadePastFlights) ...[
            const SizedBox(height: 8),
            Text(
              '${l10n.flightAnimationSetupFadeDurationLabel}:'
              ' ${_fadeDurationPercent.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Slider(
              value: _fadeDurationPercent,
              min: 1,
              max: 100,
              divisions: 99,
              label: '${_fadeDurationPercent.toStringAsFixed(0)}%',
              onChanged: (v) => setState(() => _fadeDurationPercent = v),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.flightAnimationSetupFinalFadeLevelLabel}:'
              ' ${_finalFadeLevelPercent.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Slider(
              value: _finalFadeLevelPercent,
              max: 100,
              divisions: 100,
              label: '${_finalFadeLevelPercent.toStringAsFixed(0)}%',
              onChanged: (v) =>
                  setState(() => _finalFadeLevelPercent = v),
            ),
          ],
          if (_loading) ...[
            const SizedBox(height: 18),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }

  Future<void> _prepareFlights() async {
    final l10n = AppLocalizations.of(context)!;
    final duration = NumberInputField.parse(_durationController.text);
    if (duration == null || duration < 1 || duration > 30) {
      setState(() => _durationError = l10n.flightAnimationSetupDurationError);
      return;
    }
    setState(() {
      _loading = true;
      _durationError = null;
    });
    try {
      final flights = await ref
          .read(reportsRepositoryProvider)
          .loadFlightsForAnimation(widget.query);
      if (!mounted) return;
      if (flights.isEmpty) {
        await showAppMessageDialog(
          context,
          title: l10n.flightAnimationSetupNoFlights,
          message: l10n.flightAnimationSetupNoFlightsMessage,
          useRootNavigator: false,
        );
        return;
      }
      if (!mounted) return;
      AppNavigator.pop(
        context,
        FlightAnimationSetupResult(
          durationMinutes: duration,
          style: _style,
          flights: flights,
          lookBehindPercent: _lookBehind,
          lookAheadPercent: _lookAhead,
          cameraSpeed: _cameraSpeed,
          cameraPadding: _cameraPadding,
          fadePastFlights: _fadePastFlights,
          fadeDurationPercent: _fadeDurationPercent,
          finalFadeLevelPercent: _finalFadeLevelPercent,
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      await showAppMessageDialog(
        context,
        title: l10n.flightAnimationTitle,
        message: error.toString(),
        useRootNavigator: false,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _styleLabel(FlightAnimationStyle style) {
    return switch (style) {
      FlightAnimationStyle.manualZoom => 'Manual Zoom',
      FlightAnimationStyle.automatic => 'Automatic',
    };
  }
}
