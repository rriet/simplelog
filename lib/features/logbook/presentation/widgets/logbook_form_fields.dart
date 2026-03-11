import 'package:flutter/material.dart';
import 'package:simplelog/core/presentation/widgets/inputs/clock_time_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/number_input_field.dart';

/// Shared form widgets for logbook edit screens.
class LabeledClockFieldWithClear extends StatelessWidget {
  const LabeledClockFieldWithClear({
    required this.controller,
    required this.label,
    required this.onChangedMinutes,
    required this.clearTooltip,
    required this.onPressedClear,
    super.key,
    this.onCleared,
    this.allowEmpty = true,
    this.errorText,
    this.clearEnabled = true,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<int> onChangedMinutes;
  final VoidCallback? onCleared;
  final bool allowEmpty;
  final String? errorText;
  final String clearTooltip;
  final VoidCallback? onPressedClear;
  final bool clearEnabled;

  @override
  Widget build(BuildContext context) {
    return ClockTimeInputField(
      controller: controller,
      label: label,
      onChangedMinutes: onChangedMinutes,
      onCleared: onCleared,
      allowEmpty: allowEmpty,
      errorText: errorText,
      suffixIcon: IconButton(
        tooltip: clearTooltip,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints.tightFor(width: 24, height: 24),
        onPressed: clearEnabled ? onPressedClear : null,
        icon: const Icon(Icons.clear),
      ),
    );
  }
}

class TwoColumnFieldRow extends StatelessWidget {
  const TwoColumnFieldRow({
    required this.left,
    required this.right,
    super.key,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 8,
  });

  final Widget left;
  final Widget right;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Expanded(child: left),
        SizedBox(width: spacing),
        Expanded(child: right),
      ],
    );
  }
}

class LabeledNumberFieldPair extends StatelessWidget {
  const LabeledNumberFieldPair({
    required this.leftController,
    required this.leftLabel,
    required this.rightController,
    required this.rightLabel,
    super.key,
  });

  final TextEditingController leftController;
  final String leftLabel;
  final TextEditingController rightController;
  final String rightLabel;

  @override
  Widget build(BuildContext context) {
    return TwoColumnFieldRow(
      left: NumberInputField(controller: leftController, label: leftLabel),
      right: NumberInputField(controller: rightController, label: rightLabel),
    );
  }
}
