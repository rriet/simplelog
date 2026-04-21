import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/presentation/widgets/inputs/hour_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/ifr_factoring_fields_row.dart';
import 'package:simplelog/core/presentation/widgets/inputs/number_input_field.dart';
import 'package:simplelog/core/riverpod/async_value_compat_extensions.dart';
import 'package:simplelog/features/settings/presentation/widgets/settings_expandable_info_trailing.dart';
import 'package:simplelog/state/providers/flight_factoring_settings_provider.dart';

/// Editable card for import/flight calculation factors.
///
/// Collects percentage/time thresholds and auto-saves them to
/// [flightFactoringSettingsProvider].
class FlightFactoringSettingsCard extends ConsumerStatefulWidget {
  /// Creates the card widget.
  const FlightFactoringSettingsCard({
    super.key,
    this.showTitle = true,
    this.initiallyExpanded = false,
  });

  /// Whether the internal expansion tile title should be shown.
  final bool showTitle;

  /// Whether the expansion tile should start opened.
  final bool initiallyExpanded;

  @override
  ConsumerState<FlightFactoringSettingsCard> createState() =>
      _FlightFactoringSettingsCardState();
}

class _FlightFactoringSettingsCardState
    extends ConsumerState<FlightFactoringSettingsCard> {
  final ExpansibleController _expansionController = ExpansibleController();
  final _crossCountryThresholdController = TextEditingController();
  final _ifrPercentController = TextEditingController();
  final _ifrMinController = TextEditingController();
  final _ifrSubtractController = TextEditingController();
  final _irp3PercentController = TextEditingController();
  final _irp3SubtractController = TextEditingController();
  final _irp4PercentController = TextEditingController();
  final _irp4SubtractController = TextEditingController();

  bool _initialized = false;
  bool _isHydrating = false;
  late bool _isExpanded = widget.initiallyExpanded;
  Timer? _saveDebounce;
  FlightFactoringSettings? _lastHydratedSettings;

  List<TextEditingController> get _controllers => [
    _crossCountryThresholdController,
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
    _ifrPercentController.dispose();
    _ifrMinController.dispose();
    _ifrSubtractController.dispose();
    _irp3PercentController.dispose();
    _irp3SubtractController.dispose();
    _irp4PercentController.dispose();
    _irp4SubtractController.dispose();
    _expansionController.dispose();
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
    final l10n = AppLocalizations.of(context)!;
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
        initiallyExpanded: widget.initiallyExpanded,
        title: widget.showTitle
            ? Text(l10n.autoUi008)
            : const SizedBox.shrink(),
        controller: _expansionController,
        onExpansionChanged: (expanded) {
          setState(() => _isExpanded = expanded);
        },
        trailing: SettingsExpandableInfoTrailing(
          controller: _expansionController,
          isExpanded: _isExpanded,
          helpTitle: l10n.settingsCalculationRulesHelpTitle,
          helpMessage: l10n.settingsCalculationRulesHelpBody,
        ),
        tilePadding: widget.showTitle
            ? null
            : const EdgeInsets.symmetric(
                horizontal: 8,
              ),
        childrenPadding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        children: [
          _compactFieldRow(
            fields: [
              _CompactFieldSpec.number(
                label: l10n.simplelogCrossCountryNmLabel,
                controller: _crossCountryThresholdController,
              ),
            ],
          ),
          const Divider(height: 20),
          IfrFactoringFieldsRow(
            subtractController: _ifrSubtractController,
            percentController: _ifrPercentController,
            minimumController: _ifrMinController,
          ),
          const Divider(height: 20),
          _compactFieldRow(
            fields: [
              _CompactFieldSpec.time(
                label: l10n.settingsCalculationRulesIrp3ReductionLabel,
                controller: _irp3SubtractController,
              ),
              _CompactFieldSpec.number(
                label: l10n.simplelogIrp3PercentLabel,
                controller: _irp3PercentController,
              ),
            ],
          ),
          _compactFieldRow(
            fields: [
              _CompactFieldSpec.time(
                label: l10n.settingsCalculationRulesIrp4ReductionLabel,
                controller: _irp4SubtractController,
              ),
              _CompactFieldSpec.number(
                label: l10n.simplelogIrp4PercentLabel,
                controller: _irp4PercentController,
              ),
            ],
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
