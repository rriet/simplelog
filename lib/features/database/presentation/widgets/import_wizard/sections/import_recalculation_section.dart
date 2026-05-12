import 'package:flutter/material.dart';
import 'package:simplelog/core/presentation/widgets/inputs/hour_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/ifr_factoring_fields_row.dart';
import 'package:simplelog/core/presentation/widgets/inputs/number_input_field.dart';
import 'package:simplelog/features/database/presentation/widgets/import_wizard/import_wizard_section_card.dart';

/// Labels used by the shared recalculation section.
class ImportRecalculationSectionLabels {
  /// Creates a labels container.
  const ImportRecalculationSectionLabels({
    required this.title,
    this.recalculateTotal,
    this.irp3Percent,
    this.irp3Time,
    this.irp4Percent,
    this.irp4Time,
    this.recalculateBlock,
    this.recalculateNight,
    this.recalculateTakeoffLanding,
    this.recalculateCrossCountry,
    this.crossCountryThreshold,
    this.recalculateIfr,
  });

  /// Section title.
  final String title;

  /// Label for total-time recalculation toggle.
  final String? recalculateTotal;

  /// Label for IRP3 percent field.
  final String? irp3Percent;

  /// Label for IRP3 time field.
  final String? irp3Time;

  /// Label for IRP4 percent field.
  final String? irp4Percent;

  /// Label for IRP4 time field.
  final String? irp4Time;

  /// Label for block-time recalculation toggle.
  final String? recalculateBlock;

  /// Label for night-time recalculation toggle.
  final String? recalculateNight;

  /// Label for takeoff/landing recalculation toggle.
  final String? recalculateTakeoffLanding;

  /// Label for cross-country recalculation toggle.
  final String? recalculateCrossCountry;

  /// Label for cross-country threshold input.
  final String? crossCountryThreshold;

  /// Label for IFR recalculation toggle.
  final String? recalculateIfr;
}

/// Shared recalculation UI section used across import sources.
class ImportRecalculationSection extends StatelessWidget {
  /// Creates a recalculation section.
  const ImportRecalculationSection({
    required this.labels,
    required this.initiallyExpanded,
    required this.onExpansionChanged,
    this.recalcTotalValue,
    this.onRecalcTotalChanged,
    this.irp3PercentController,
    this.irp3SubtractController,
    this.irp4PercentController,
    this.irp4SubtractController,
    this.recalcBlockValue,
    this.onRecalcBlockChanged,
    this.recalcNightValue,
    this.onRecalcNightChanged,
    this.recalcTakeoffLandingValue,
    this.onRecalcTakeoffLandingChanged,
    this.recalcCrossCountryValue,
    this.onRecalcCrossCountryChanged,
    this.crossCountryThresholdController,
    this.recalcIfrValue,
    this.onRecalcIfrChanged,
    this.ifrSubtractController,
    this.ifrPercentController,
    this.ifrMinimumController,
    super.key,
  });

  /// Section labels.
  final ImportRecalculationSectionLabels labels;

  /// Whether the section starts expanded.
  final bool initiallyExpanded;

  /// Called when section expansion changes.
  final ValueChanged<bool> onExpansionChanged;

  /// Value for total-time recalculation.
  final bool? recalcTotalValue;

  /// Callback for total-time recalculation.
  final ValueChanged<bool>? onRecalcTotalChanged;

  /// IRP3 percent input.
  final TextEditingController? irp3PercentController;

  /// IRP3 subtract input.
  final TextEditingController? irp3SubtractController;

  /// IRP4 percent input.
  final TextEditingController? irp4PercentController;

  /// IRP4 subtract input.
  final TextEditingController? irp4SubtractController;

  /// Value for block-time recalculation.
  final bool? recalcBlockValue;

  /// Callback for block-time recalculation.
  final ValueChanged<bool>? onRecalcBlockChanged;

  /// Value for night-time recalculation.
  final bool? recalcNightValue;

  /// Callback for night-time recalculation.
  final ValueChanged<bool>? onRecalcNightChanged;

  /// Value for takeoff/landing recalculation.
  final bool? recalcTakeoffLandingValue;

  /// Callback for takeoff/landing recalculation.
  final ValueChanged<bool>? onRecalcTakeoffLandingChanged;

  /// Value for cross-country recalculation.
  final bool? recalcCrossCountryValue;

  /// Callback for cross-country recalculation.
  final ValueChanged<bool>? onRecalcCrossCountryChanged;

  /// Cross-country threshold input.
  final TextEditingController? crossCountryThresholdController;

  /// Value for IFR recalculation.
  final bool? recalcIfrValue;

  /// Callback for IFR recalculation.
  final ValueChanged<bool>? onRecalcIfrChanged;

  /// IFR subtract input.
  final TextEditingController? ifrSubtractController;

  /// IFR percent input.
  final TextEditingController? ifrPercentController;

  /// IFR minimum input.
  final TextEditingController? ifrMinimumController;

  @override
  Widget build(BuildContext context) {
    return ImportWizardSectionCard(
      title: labels.title,
      initiallyExpanded: initiallyExpanded,
      onExpansionChanged: onExpansionChanged,
      children: [
        if (labels.recalculateTotal != null &&
            recalcTotalValue != null &&
            onRecalcTotalChanged != null)
          _buildToggle(
            title: labels.recalculateTotal!,
            value: recalcTotalValue!,
            onChanged: onRecalcTotalChanged!,
          ),
        if (recalcTotalValue == true &&
            labels.irp3Percent != null &&
            labels.irp3Time != null &&
            labels.irp4Percent != null &&
            labels.irp4Time != null &&
            irp3PercentController != null &&
            irp3SubtractController != null &&
            irp4PercentController != null &&
            irp4SubtractController != null) ...[
          _CompactFieldRow(
            fields: [
              _CompactFieldSpec.number(
                label: labels.irp3Percent!,
                controller: irp3PercentController!,
              ),
              _CompactFieldSpec.time(
                label: labels.irp3Time!,
                controller: irp3SubtractController!,
              ),
            ],
          ),
          _CompactFieldRow(
            fields: [
              _CompactFieldSpec.number(
                label: labels.irp4Percent!,
                controller: irp4PercentController!,
              ),
              _CompactFieldSpec.time(
                label: labels.irp4Time!,
                controller: irp4SubtractController!,
              ),
            ],
          ),
        ],
        if (labels.recalculateBlock != null &&
            recalcBlockValue != null &&
            onRecalcBlockChanged != null)
          _buildToggle(
            title: labels.recalculateBlock!,
            value: recalcBlockValue!,
            onChanged: onRecalcBlockChanged!,
          ),
        if (labels.recalculateNight != null &&
            recalcNightValue != null &&
            onRecalcNightChanged != null)
          _buildToggle(
            title: labels.recalculateNight!,
            value: recalcNightValue!,
            onChanged: onRecalcNightChanged!,
          ),
        if (labels.recalculateTakeoffLanding != null &&
            recalcTakeoffLandingValue != null &&
            onRecalcTakeoffLandingChanged != null)
          _buildToggle(
            title: labels.recalculateTakeoffLanding!,
            value: recalcTakeoffLandingValue!,
            onChanged: onRecalcTakeoffLandingChanged!,
          ),
        if (labels.recalculateCrossCountry != null &&
            recalcCrossCountryValue != null &&
            onRecalcCrossCountryChanged != null)
          _buildToggle(
            title: labels.recalculateCrossCountry!,
            value: recalcCrossCountryValue!,
            onChanged: onRecalcCrossCountryChanged!,
          ),
        if (recalcCrossCountryValue == true &&
            crossCountryThresholdController != null &&
            labels.crossCountryThreshold != null)
          _CompactFieldRow(
            fields: [
              _CompactFieldSpec.number(
                label: labels.crossCountryThreshold!,
                controller: crossCountryThresholdController!,
              ),
            ],
          ),
        if (labels.recalculateIfr != null &&
            recalcIfrValue != null &&
            onRecalcIfrChanged != null)
          _buildToggle(
            title: labels.recalculateIfr!,
            value: recalcIfrValue!,
            onChanged: onRecalcIfrChanged!,
          ),
        if (recalcIfrValue == true &&
            ifrSubtractController != null &&
            ifrPercentController != null &&
            ifrMinimumController != null)
          IfrFactoringFieldsRow(
            subtractController: ifrSubtractController!,
            percentController: ifrPercentController!,
            minimumController: ifrMinimumController!,
          ),
      ],
    );
  }

  Widget _buildToggle({
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
