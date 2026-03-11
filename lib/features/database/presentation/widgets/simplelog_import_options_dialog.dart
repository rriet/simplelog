import 'package:flutter/material.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/inputs/hour_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/number_input_field.dart';
import 'package:simplelog/data/import/simplelog_import_options.dart';

/// Dialog to configure how legacy SimpleLog CSV rows are imported.
///
/// Input: source [fileName] and optional [initial] options.
/// Output: selected [SimpleLogImportOptions] when the user confirms import.
class SimpleLogImportOptionsDialog extends StatefulWidget {
  /// Creates the import options dialog.
  const SimpleLogImportOptionsDialog({
    required this.fileName,
    super.key,
    this.initial = const SimpleLogImportOptions(),
  });

  /// Name shown in the dialog header for user context.
  final String fileName;

  /// Preloaded option values used to initialize controls.
  final SimpleLogImportOptions initial;

  /// Opens the dialog and resolves to the chosen options, or `null` on cancel.
  static Future<SimpleLogImportOptions?> show(
    BuildContext context, {
    required String fileName,
    SimpleLogImportOptions initial = const SimpleLogImportOptions(),
  }) {
    final screen = SimpleLogImportOptionsDialog(
      fileName: fileName,
      initial: initial,
    );
    final isCompact = MediaQuery.sizeOf(context).width < 600;
    if (isCompact) {
      return AppNavigator.pushMaterial<SimpleLogImportOptions>(
        context,
        (_) => screen,
        rootNavigator: true,
      );
    }
    return showDialog<SimpleLogImportOptions>(
      context: context,
      builder: (_) => screen,
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
    final body = SingleChildScrollView(
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
                  title: const Text('Total time (updates PIC/SIC/etc)'),
                  value: _recalcTotal,
                  onChanged: (value) => setState(() => _recalcTotal = value),
                ),
                if (_recalcTotal) ...[
                  _buildPercentTimePairRow(
                    percentLabel: 'IRP3 %',
                    percentController: _irp3PercentController,
                    timeLabel: 'IRP3 Time',
                    timeController: _irp3SubtractController,
                  ),
                  _buildPercentTimePairRow(
                    percentLabel: 'IRP4 %',
                    percentController: _irp4PercentController,
                    timeLabel: 'IRP4 Time',
                    timeController: _irp4SubtractController,
                  ),
                ],
                _buildRecalculationToggle(
                  title: 'Night time',
                  value: _recalcNight,
                  onChanged: (value) => setState(() => _recalcNight = value),
                ),
                _buildRecalculationToggle(
                  title: 'Takeoff & Landings (day/night)',
                  value: _recalcTakeoffLanding,
                  onChanged: (value) =>
                      setState(() => _recalcTakeoffLanding = value),
                ),
                _buildRecalculationToggle(
                  title: 'Cross-country',
                  value: _recalcCrossCountry,
                  onChanged: (value) =>
                      setState(() => _recalcCrossCountry = value),
                ),
                if (_recalcCrossCountry)
                  _CompactFieldRow(
                    fields: [
                      _CompactFieldSpec.number(
                        label: 'Cross-Country NM',
                        controller: _crossCountryThresholdController,
                      ),
                    ],
                  ),
                _buildRecalculationToggle(
                  title: 'Instrument time',
                  value: _recalcInstrument,
                  onChanged: (value) =>
                      setState(() => _recalcInstrument = value),
                ),
                if (_recalcInstrument) ...[
                  _buildPercentTimeMinimumRow(
                    percentLabel: 'Instrument %',
                    percentController: _instrumentPercentController,
                    subtractController: _instrumentSubtractController,
                    minimumController: _instrumentMinController,
                  ),
                ],
                _buildRecalculationToggle(
                  title: 'IFR time',
                  value: _recalcIfr,
                  onChanged: (value) => setState(() => _recalcIfr = value),
                ),
                if (_recalcIfr) ...[
                  _buildPercentTimeMinimumRow(
                    percentLabel: 'IFR %',
                    percentController: _ifrPercentController,
                    subtractController: _ifrSubtractController,
                    minimumController: _ifrMinController,
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
                _buildConflictToggle(
                  title: 'Override Airport on Conflict',
                  value: _overrideAirports,
                  onChanged: (value) =>
                      setState(() => _overrideAirports = value),
                ),
                _buildConflictToggle(
                  title: 'Override Aircraft on Conflict',
                  value: _overrideAircraft,
                  onChanged: (value) =>
                      setState(() => _overrideAircraft = value),
                ),
                _buildConflictToggle(
                  title: 'Override Aircraft Type on Conflict',
                  value: _overrideAircraftTypes,
                  onChanged: (value) =>
                      setState(() => _overrideAircraftTypes = value),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return AdaptiveFormShell(
      onClose: () => AppNavigator.pop(context),
      longTitle: 'Import Options',
      shortTitle: 'Import',
      popupMaxWidth: 560,
      actions: [
        TextButton(
          onPressed: () => AppNavigator.pop(context, _buildOptions()),
          child: const Text('Import'),
        ),
      ],
      contentView: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: body,
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

  Widget _buildRecalculationToggle({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildConflictToggle({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildPercentTimePairRow({
    required String percentLabel,
    required TextEditingController percentController,
    required String timeLabel,
    required TextEditingController timeController,
  }) {
    return _CompactFieldRow(
      fields: [
        _CompactFieldSpec.number(
          label: percentLabel,
          controller: percentController,
        ),
        _CompactFieldSpec.time(
          label: timeLabel,
          controller: timeController,
        ),
      ],
    );
  }

  Widget _buildPercentTimeMinimumRow({
    required String percentLabel,
    required TextEditingController percentController,
    required TextEditingController subtractController,
    required TextEditingController minimumController,
  }) {
    return _CompactFieldRow(
      fields: [
        _CompactFieldSpec.number(
          label: percentLabel,
          controller: percentController,
        ),
        _CompactFieldSpec.time(
          label: 'Subtracted',
          controller: subtractController,
        ),
        _CompactFieldSpec.time(
          label: 'Minimum',
          controller: minimumController,
        ),
      ],
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
