import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/presentation/shared/widgets/app_message_dialog.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/hour_input_field.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/number_input_field.dart';
import 'package:simplelog/state/providers/flight_factoring_settings_provider.dart';

class FlightFactoringSettingsCard extends ConsumerStatefulWidget {
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

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final asyncValue = ref.watch(flightFactoringSettingsProvider);
    final settings = asyncValue.asData?.value;
    if (settings != null && !_initialized) {
      _initialized = true;
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
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(onPressed: _save, child: const Text('Save')),
          ),
        ],
      ),
    );
  }

  Widget _compactFieldRow({required List<_CompactFieldSpec> fields}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 8.0;
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

  Future<void> _save() async {
    int percentValue(TextEditingController c, {required int fallback}) {
      return (int.tryParse(c.text.trim()) ?? fallback).clamp(0, 100);
    }

    final next = FlightFactoringSettings(
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
    await ref.read(flightFactoringSettingsProvider.notifier).setValue(next);
    if (!mounted) return;
    await showAppMessageDialog(context, message: 'Factoring settings saved.');
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
