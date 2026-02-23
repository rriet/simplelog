import 'package:flutter/material.dart';
import 'package:simplelog/data/import/simplelog_import_options.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/hour_input_field.dart';
import 'package:simplelog/presentation/shared/widgets/inputs/number_input_field.dart';

/// Public API documentation.
class SimpleLogImportOptionsDialog extends StatefulWidget {
  /// Public API documentation.
  const SimpleLogImportOptionsDialog({
    required this.fileName,
    super.key,
    this.initial = const SimpleLogImportOptions(),
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final String fileName;
  /// Public API documentation.
  final SimpleLogImportOptions initial;

  /// Public API documentation.
  static Future<SimpleLogImportOptions?> show(
    BuildContext context, {
    required String fileName,
    SimpleLogImportOptions initial = const SimpleLogImportOptions(),
  }) {
    return showDialog<SimpleLogImportOptions>(
      context: context,
      builder: (context) =>
          SimpleLogImportOptionsDialog(fileName: fileName, initial: initial),
    );
  }

  @override
  State<SimpleLogImportOptionsDialog> createState() =>
      _SimpleLogImportOptionsDialogState();
}

class _SimpleLogImportOptionsDialogState
    extends State<SimpleLogImportOptionsDialog> {
  late bool _recalcNight;
  late bool _recalcTotal;
  late bool _recalcTakeoffLanding;
  late bool _recalcCrossCountry;
  late bool _recalcInstrument;
  late bool _recalcIfr;
  late bool _overrideAirports;
  late bool _overrideAircraft;
  late bool _overrideAircraftTypes;

  bool _showConflictResolution = false;
  bool _showRecalculations = false;

  late final TextEditingController _crossCountryThresholdController;
  late final TextEditingController _instrumentPercentController;
  late final TextEditingController _instrumentMinController;
  late final TextEditingController _instrumentSubtractController;
  late final TextEditingController _ifrPercentController;
  late final TextEditingController _ifrMinController;
  late final TextEditingController _ifrSubtractController;
  late final TextEditingController _irp3PercentController;
  late final TextEditingController _irp3SubtractController;
  late final TextEditingController _irp4PercentController;
  late final TextEditingController _irp4SubtractController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _recalcNight = initial.recalculateNightTime;
    _recalcTotal = initial.recalculateTotalTime;
    _recalcTakeoffLanding = initial.recalculateTakeoffLanding;
    _recalcCrossCountry = initial.recalculateCrossCountry;
    _recalcInstrument = initial.recalculateInstrument;
    _recalcIfr = initial.recalculateIfrTime;
    _overrideAirports = initial.overrideAirportValues;
    _overrideAircraft = initial.overrideAircraftValues;
    _overrideAircraftTypes = initial.overrideAircraftTypeValues;

    _crossCountryThresholdController = TextEditingController(
      text: initial.crossCountryThresholdNm.toString(),
    );
    _instrumentPercentController = TextEditingController(
      text: initial.instrumentPercent.toString(),
    );
    _instrumentMinController = TextEditingController(
      text: HourInputField.formatHours(initial.instrumentMinimumMinutes),
    );
    _instrumentSubtractController = TextEditingController(
      text: HourInputField.formatHours(initial.instrumentSubtractMinutes),
    );
    _ifrPercentController = TextEditingController(
      text: initial.ifrPercent.toString(),
    );
    _ifrMinController = TextEditingController(
      text: HourInputField.formatHours(initial.ifrMinimumMinutes),
    );
    _ifrSubtractController = TextEditingController(
      text: HourInputField.formatHours(initial.ifrSubtractMinutes),
    );
    _irp3PercentController = TextEditingController(
      text: initial.irp3Percent.toString(),
    );
    _irp3SubtractController = TextEditingController(
      text: HourInputField.formatHours(initial.irp3SubtractMinutes),
    );
    _irp4PercentController = TextEditingController(
      text: initial.irp4Percent.toString(),
    );
    _irp4SubtractController = TextEditingController(
      text: HourInputField.formatHours(initial.irp4SubtractMinutes),
    );
  }

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
    return Dialog(
      child: SizedBox(
        width: 560,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Import Options',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('File: ${widget.fileName}'),
                      const SizedBox(height: 12),
                      const SizedBox(height: 8),
                      Card(
                        margin: EdgeInsets.zero,
                        child: ExpansionTile(
                          initiallyExpanded: _showRecalculations,
                          onExpansionChanged: (expanded) =>
                              setState(() => _showRecalculations = expanded),
                          title: const Text('Recalculations'),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            8,
                          ),
                          children: [
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Total time (updates PIC/SIC/etc)',
                              ),
                              value: _recalcTotal,
                              onChanged: (value) =>
                                  setState(() => _recalcTotal = value),
                            ),
                            if (_recalcTotal) ...[
                              _CompactFieldRow(
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
                              _CompactFieldRow(
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
                            ],
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Night time'),
                              value: _recalcNight,
                              onChanged: (value) =>
                                  setState(() => _recalcNight = value),
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Takeoff & Landings (day/night)',
                              ),
                              value: _recalcTakeoffLanding,
                              onChanged: (value) =>
                                  setState(() => _recalcTakeoffLanding = value),
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Cross-country'),
                              value: _recalcCrossCountry,
                              onChanged: (value) =>
                                  setState(() => _recalcCrossCountry = value),
                            ),
                            if (_recalcCrossCountry)
                              _CompactFieldRow(
                                fields: [
                                  _CompactFieldSpec.number(
                                    label: 'Cross-Country NM',
                                    controller:
                                        _crossCountryThresholdController,
                                  ),
                                ],
                              ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Instrument time'),
                              value: _recalcInstrument,
                              onChanged: (value) =>
                                  setState(() => _recalcInstrument = value),
                            ),
                            if (_recalcInstrument) ...[
                              _CompactFieldRow(
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
                            ],
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('IFR time'),
                              value: _recalcIfr,
                              onChanged: (value) =>
                                  setState(() => _recalcIfr = value),
                            ),
                            if (_recalcIfr) ...[
                              _CompactFieldRow(
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
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        margin: EdgeInsets.zero,
                        child: ExpansionTile(
                          initiallyExpanded: _showConflictResolution,
                          onExpansionChanged: (expanded) => setState(
                            () => _showConflictResolution = expanded,
                          ),
                          title: const Text('Conflict Resolution'),
                          children: [
                            SwitchListTile(
                              contentPadding: const EdgeInsets.fromLTRB(
                                16,
                                0,
                                16,
                                8,
                              ),
                              title: const Text('Override Airport on Conflict'),
                              value: _overrideAirports,
                              onChanged: (value) =>
                                  setState(() => _overrideAirports = value),
                            ),
                            SwitchListTile(
                              contentPadding: const EdgeInsets.fromLTRB(
                                16,
                                0,
                                16,
                                8,
                              ),
                              title: const Text(
                                'Override Aircraft on Conflict',
                              ),
                              value: _overrideAircraft,
                              onChanged: (value) =>
                                  setState(() => _overrideAircraft = value),
                            ),
                            SwitchListTile(
                              contentPadding: const EdgeInsets.fromLTRB(
                                16,
                                0,
                                16,
                                8,
                              ),
                              title: const Text(
                                'Override Aircraft Type on Conflict',
                              ),
                              value: _overrideAircraftTypes,
                              onChanged: (value) => setState(
                                () => _overrideAircraftTypes = value,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () =>
                          Navigator.of(context).pop(_buildOptions()),
                      child: const Text('Import'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _parsePercent(TextEditingController c, {int fallback = 0}) {
    final value = int.tryParse(c.text.trim()) ?? fallback;
    return value.clamp(0, 100);
  }

  int _parseTime(TextEditingController c) {
    return HourInputField.parseHours(c.text.trim()) ?? 0;
  }

  SimpleLogImportOptions _buildOptions() {
    return SimpleLogImportOptions(
      recalculateNightTime: _recalcNight,
      recalculateTotalTime: _recalcTotal,
      recalculateTakeoffLanding: _recalcTakeoffLanding,
      recalculateCrossCountry: _recalcCrossCountry,
      crossCountryThresholdNm:
          int.tryParse(_crossCountryThresholdController.text.trim()) ?? 50,
      recalculateInstrument: _recalcInstrument,
      instrumentPercent: _parsePercent(_instrumentPercentController),
      instrumentMinimumMinutes: _parseTime(_instrumentMinController),
      instrumentSubtractMinutes: _parseTime(_instrumentSubtractController),
      recalculateIfrTime: _recalcIfr,
      ifrPercent: _parsePercent(_ifrPercentController),
      ifrMinimumMinutes: _parseTime(_ifrMinController),
      ifrSubtractMinutes: _parseTime(_ifrSubtractController),
      irp3Percent: _parsePercent(_irp3PercentController, fallback: 100),
      irp3SubtractMinutes: _parseTime(_irp3SubtractController),
      irp4Percent: _parsePercent(_irp4PercentController, fallback: 100),
      irp4SubtractMinutes: _parseTime(_irp4SubtractController),
      overrideAirportValues: _overrideAirports,
      overrideAircraftValues: _overrideAircraft,
      overrideAircraftTypeValues: _overrideAircraftTypes,
    );
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

class _CompactFieldRow extends StatelessWidget {
  const _CompactFieldRow({required this.fields});

  final List<_CompactFieldSpec> fields;

  @override
  Widget build(BuildContext context) {
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
}
