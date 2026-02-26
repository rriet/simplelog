import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/riverpod/async_value_compat_extensions.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/hour_input_field.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/number_input_field.dart';
import 'package:simplelog/state/providers/flight_factoring_settings_provider.dart';

/// Public API documentation.
class FlightFactoringSettingsCard extends ConsumerStatefulWidget {
  /// Public API documentation.
  const FlightFactoringSettingsCard({super.key});

  @override
  ConsumerState<FlightFactoringSettingsCard> createState() =>
      _FlightFactoringSettingsCardState();
}

class _FlightFactoringSettingsCardState
    extends ConsumerState<FlightFactoringSettingsCard> {
  final _crossCountryThresholdController = TextEditingController();
  final _instrumentPercentController = TextEditingController();
  final _instrumentMinController = TextEditingController();
  final _instrumentSubtractController = TextEditingController();
  final _ifrPercentController = TextEditingController();
  final _ifrMinController = TextEditingController();
  final _ifrSubtractController = TextEditingController();
  final _irp3PercentController = TextEditingController();
  final _irp3SubtractController = TextEditingController();
  final _irp4PercentController = TextEditingController();
  final _irp4SubtractController = TextEditingController();

  bool _initialized = false;
  bool _isHydrating = false;
  Timer? _saveDebounce;
  FlightFactoringSettings? _lastHydratedSettings;

  List<TextEditingController> get _controllers => [
    _crossCountryThresholdController,
    _instrumentPercentController,
    _instrumentMinController,
    _instrumentSubtractController,
    _ifrPercentController,
    _ifrMinController,
    _ifrSubtractController,
    _irp3PercentController,
    _irp3SubtractController,
    _irp4PercentController,
    _irp4SubtractController,
  ];

  @override
  void initState() {
    super.initState();
    for (final controller in _controllers) {
      controller.addListener(_onFieldChanged);
    }
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    for (final controller in _controllers) {
      controller.removeListener(_onFieldChanged);
    }
    _crossCountryThresholdController.dispose();
    _instrumentPercentController.dispose();
    _instrumentMinController.dispose();
    _instrumentSubtractController.dispose();
    _ifrPercentController.dispose();
    _ifrMinController.dispose();
    _ifrSubtractController.dispose();
    _irp3PercentController.dispose();
    _irp3SubtractController.dispose();
    _irp4PercentController.dispose();
    _irp4SubtractController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (!_initialized || _isHydrating) return;
    _scheduleSave();
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () {
      unawaited(_saveNow());
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncValue = ref.watch(flightFactoringSettingsProvider);
    final settings = asyncValue.asData?.value;
    if (settings != null &&
        !_isHydrating &&
        (_lastHydratedSettings == null ||
            !_sameSettings(_lastHydratedSettings!, settings))) {
      _isHydrating = true;
      _initialized = true;
      _lastHydratedSettings = settings;
      _crossCountryThresholdController.text = settings.crossCountryThresholdNm
          .toString();
      _instrumentPercentController.text = settings.instrumentPercent.toString();
      _instrumentMinController.text = HourInputField.formatHours(
        settings.instrumentMinimumMinutes,
      );
      _instrumentSubtractController.text = HourInputField.formatHours(
        settings.instrumentSubtractMinutes,
      );
      _ifrPercentController.text = settings.ifrPercent.toString();
      _ifrMinController.text = HourInputField.formatHours(
        settings.ifrMinimumMinutes,
      );
      _ifrSubtractController.text = HourInputField.formatHours(
        settings.ifrSubtractMinutes,
      );
      _irp3PercentController.text = settings.irp3Percent.toString();
      _irp3SubtractController.text = HourInputField.formatHours(
        settings.irp3SubtractMinutes,
      );
      _irp4PercentController.text = settings.irp4Percent.toString();
      _irp4SubtractController.text = HourInputField.formatHours(
        settings.irp4SubtractMinutes,
      );
      _isHydrating = false;
    }

    return Card(
      child: ExpansionTile(
        title: const Text('Calculation Rules'),
        childrenPadding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        children: [
          _compactFieldRow(
            fields: [
              _CompactFieldSpec.number(
                label: 'Cross-Country NM',
                controller: _crossCountryThresholdController,
              ),
            ],
          ),
          _compactFieldRow(
            fields: [
              _CompactFieldSpec.number(
                label: 'Instrument %',
                controller: _instrumentPercentController,
              ),
              _CompactFieldSpec.time(
                label: 'Subtracted',
                controller: _instrumentSubtractController,
              ),
              _CompactFieldSpec.time(
                label: 'Minimum',
                controller: _instrumentMinController,
              ),
            ],
          ),
          _compactFieldRow(
            fields: [
              _CompactFieldSpec.number(
                label: 'IFR %',
                controller: _ifrPercentController,
              ),
              _CompactFieldSpec.time(
                label: 'Subtracted',
                controller: _ifrSubtractController,
              ),
              _CompactFieldSpec.time(
                label: 'Minimum',
                controller: _ifrMinController,
              ),
            ],
          ),
          const Divider(height: 20),
          _compactFieldRow(
            fields: [
              _CompactFieldSpec.number(
                label: 'IRP3 %',
                controller: _irp3PercentController,
              ),
              _CompactFieldSpec.time(
                label: 'IRP3 Time',
                controller: _irp3SubtractController,
              ),
            ],
          ),
          _compactFieldRow(
            fields: [
              _CompactFieldSpec.number(
                label: 'IRP4 %',
                controller: _irp4PercentController,
              ),
              _CompactFieldSpec.time(
                label: 'IRP4 Time',
                controller: _irp4SubtractController,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Calculation rules are saved automatically.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactFieldRow({required List<_CompactFieldSpec> fields}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final count = fields.length;
        final totalSpacing = (count - 1) * spacing;
        final eachWidth = count == 0
            ? constraints.maxWidth
            : (constraints.maxWidth - totalSpacing) / count;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Wrap(
            spacing: spacing,
            runSpacing: 8,
            children: [
              for (final field in fields)
                SizedBox(
                  width: eachWidth,
                  child: field.isTime
                      ? HourInputField(
                          controller: field.controller,
                          label: field.label,
                        )
                      : NumberInputField(
                          controller: field.controller,
                          label: field.label,
                        ),
                ),
            ],
          ),
        );
      },
    );
  }

  FlightFactoringSettings _settingsFromControllers() {
    int percentValue(TextEditingController c, {required int fallback}) {
      return (int.tryParse(c.text.trim()) ?? fallback).clamp(0, 100);
    }

    return FlightFactoringSettings(
      crossCountryThresholdNm:
          int.tryParse(_crossCountryThresholdController.text.trim()) ?? 50,
      instrumentPercent: percentValue(
        _instrumentPercentController,
        fallback: 0,
      ),
      instrumentMinimumMinutes:
          HourInputField.parseHours(_instrumentMinController.text.trim()) ?? 0,
      instrumentSubtractMinutes:
          HourInputField.parseHours(
            _instrumentSubtractController.text.trim(),
          ) ??
          0,
      ifrPercent: percentValue(_ifrPercentController, fallback: 0),
      ifrMinimumMinutes:
          HourInputField.parseHours(_ifrMinController.text.trim()) ?? 0,
      ifrSubtractMinutes:
          HourInputField.parseHours(_ifrSubtractController.text.trim()) ?? 0,
      irp3Percent: percentValue(_irp3PercentController, fallback: 100),
      irp3SubtractMinutes:
          HourInputField.parseHours(_irp3SubtractController.text.trim()) ?? 0,
      irp4Percent: percentValue(_irp4PercentController, fallback: 100),
      irp4SubtractMinutes:
          HourInputField.parseHours(_irp4SubtractController.text.trim()) ?? 0,
    );
  }

  Future<void> _saveNow() async {
    final next = _settingsFromControllers();
    final current = ref.read(flightFactoringSettingsProvider).valueOrNull;
    if (current != null &&
        current.crossCountryThresholdNm == next.crossCountryThresholdNm &&
        current.instrumentPercent == next.instrumentPercent &&
        current.instrumentMinimumMinutes == next.instrumentMinimumMinutes &&
        current.instrumentSubtractMinutes == next.instrumentSubtractMinutes &&
        current.ifrPercent == next.ifrPercent &&
        current.ifrMinimumMinutes == next.ifrMinimumMinutes &&
        current.ifrSubtractMinutes == next.ifrSubtractMinutes &&
        current.irp3Percent == next.irp3Percent &&
        current.irp3SubtractMinutes == next.irp3SubtractMinutes &&
        current.irp4Percent == next.irp4Percent &&
        current.irp4SubtractMinutes == next.irp4SubtractMinutes) {
      return;
    }

    await ref.read(flightFactoringSettingsProvider.notifier).setValue(next);
    _lastHydratedSettings = next;
  }

  bool _sameSettings(
    FlightFactoringSettings a,
    FlightFactoringSettings b,
  ) {
    return a.crossCountryThresholdNm == b.crossCountryThresholdNm &&
        a.instrumentPercent == b.instrumentPercent &&
        a.instrumentMinimumMinutes == b.instrumentMinimumMinutes &&
        a.instrumentSubtractMinutes == b.instrumentSubtractMinutes &&
        a.ifrPercent == b.ifrPercent &&
        a.ifrMinimumMinutes == b.ifrMinimumMinutes &&
        a.ifrSubtractMinutes == b.ifrSubtractMinutes &&
        a.irp3Percent == b.irp3Percent &&
        a.irp3SubtractMinutes == b.irp3SubtractMinutes &&
        a.irp4Percent == b.irp4Percent &&
        a.irp4SubtractMinutes == b.irp4SubtractMinutes;
  }
}

class _CompactFieldSpec {
  const _CompactFieldSpec._({
    required this.label,
    required this.controller,
    required this.isTime,
  });

  const _CompactFieldSpec.number({
    required String label,
    required TextEditingController controller,
  }) : this._(label: label, controller: controller, isTime: false);

  const _CompactFieldSpec.time({
    required String label,
    required TextEditingController controller,
  }) : this._(label: label, controller: controller, isTime: true);

  final String label;
  final TextEditingController controller;
  final bool isTime;
}
