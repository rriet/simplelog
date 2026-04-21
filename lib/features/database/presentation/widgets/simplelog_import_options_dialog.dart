import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/inputs/hour_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/ifr_factoring_fields_row.dart';
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
  late bool _recalcIfr;
  late bool _overrideAirports;
  late bool _overrideAircraft;
  late bool _overrideAircraftTypes;

  bool _showConflictResolution = false;
  bool _showRecalculations = false;

  late final TextEditingController _crossCountryThresholdController;
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
    _recalcIfr = initial.recalculateIfrTime;
    _overrideAirports = initial.overrideAirportValues;
    _overrideAircraft = initial.overrideAircraftValues;
    _overrideAircraftTypes = initial.overrideAircraftTypeValues;

    _crossCountryThresholdController = TextEditingController(
      text: initial.crossCountryThresholdNm.toString(),
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
    final l10n = AppLocalizations.of(context)!;
    final body = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.databaseFileLabel(widget.fileName)),
          const SizedBox(height: 12),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: ExpansionTile(
              initiallyExpanded: _showRecalculations,
              onExpansionChanged: (expanded) =>
                  setState(() => _showRecalculations = expanded),
              title: Text(l10n.simplelogRecalculationsTitle),
              childrenPadding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                8,
              ),
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.simplelogRecalcTotalTimeLabel),
                  value: _recalcTotal,
                  onChanged: (value) => setState(() => _recalcTotal = value),
                ),
                if (_recalcTotal) ...[
                  _buildPercentTimePairRow(
                    percentLabel: l10n.simplelogIrp3PercentLabel,
                    percentController: _irp3PercentController,
                    timeLabel: l10n.simplelogIrp3TimeLabel,
                    timeController: _irp3SubtractController,
                  ),
                  _buildPercentTimePairRow(
                    percentLabel: l10n.simplelogIrp4PercentLabel,
                    percentController: _irp4PercentController,
                    timeLabel: l10n.simplelogIrp4TimeLabel,
                    timeController: _irp4SubtractController,
                  ),
                ],
                _buildRecalculationToggle(
                  title: l10n.simplelogNightTimeLabel,
                  value: _recalcNight,
                  onChanged: (value) => setState(() => _recalcNight = value),
                ),
                _buildRecalculationToggle(
                  title: l10n.simplelogTakeoffLandingsLabel,
                  value: _recalcTakeoffLanding,
                  onChanged: (value) =>
                      setState(() => _recalcTakeoffLanding = value),
                ),
                _buildRecalculationToggle(
                  title: l10n.simplelogCrossCountryLabel,
                  value: _recalcCrossCountry,
                  onChanged: (value) =>
                      setState(() => _recalcCrossCountry = value),
                ),
                if (_recalcCrossCountry)
                  _CompactFieldRow(
                    fields: [
                      _CompactFieldSpec.number(
                        label: l10n.simplelogCrossCountryNmLabel,
                        controller: _crossCountryThresholdController,
                      ),
                    ],
                  ),
                _buildRecalculationToggle(
                  title: l10n.simplelogIfrTimeLabel,
                  value: _recalcIfr,
                  onChanged: (value) => setState(() => _recalcIfr = value),
                ),
                if (_recalcIfr) ...[
                  IfrFactoringFieldsRow(
                    subtractController: _ifrSubtractController,
                    percentController: _ifrPercentController,
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
              title: Text(l10n.simplelogConflictResolutionTitle),
              children: [
                _buildConflictToggle(
                  title: l10n.simplelogOverrideAirportOnConflict,
                  value: _overrideAirports,
                  onChanged: (value) =>
                      setState(() => _overrideAirports = value),
                ),
                _buildConflictToggle(
                  title: l10n.simplelogOverrideAircraftOnConflict,
                  value: _overrideAircraft,
                  onChanged: (value) =>
                      setState(() => _overrideAircraft = value),
                ),
                _buildConflictToggle(
                  title: l10n.simplelogOverrideAircraftTypeOnConflict,
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
      title: l10n.simplelogImportOptionsTitle,
      popupMaxWidth: 560,
      actions: [
        TextButton(
          onPressed: () => AppNavigator.pop(context, _buildOptions()),
          child: Text(l10n.simplelogImportAction),
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
