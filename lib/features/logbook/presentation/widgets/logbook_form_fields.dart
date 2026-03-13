import 'package:flutter/material.dart';
import 'package:simplelog/core/presentation/widgets/inputs/clock_time_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/number_input_field.dart';

/// Shared form widgets for logbook edit screens.
class LabeledClockFieldWithClear extends StatelessWidget {
  /// Creates a labeled HH:MM input with a clear button suffix.
  ///
  /// Input:
  /// - [controller]: text controller that owns the displayed time value.
  /// - [label]: field label shown in the input decoration.
  /// - [onChangedMinutes]: called with parsed minutes when user edits time.
  /// - [clearTooltip]: tooltip shown on the clear icon.
  /// - [onPressedClear]: callback invoked when clear icon is tapped.
  /// - [onCleared]: optional callback from [ClockTimeInputField] clear flow.
  /// - [allowEmpty]: whether empty value is accepted.
  /// - [errorText]: optional validation message rendered below the field.
  /// - [clearEnabled]: enables/disables the clear icon action.
  ///
  /// Output:
  /// - Renders a [ClockTimeInputField] configured with a compact clear icon.
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

  /// Text controller holding the HH:MM input value.
  final TextEditingController controller;

  /// Input label shown to the user.
  final String label;

  /// Callback that receives the current value in minutes.
  final ValueChanged<int> onChangedMinutes;

  /// Optional callback triggered when value is cleared.
  final VoidCallback? onCleared;

  /// Whether the input accepts an empty value.
  final bool allowEmpty;

  /// Optional validation error displayed below the input.
  final String? errorText;

  /// Tooltip for the suffix clear action.
  final String clearTooltip;

  /// Clear action callback for the suffix icon.
  final VoidCallback? onPressedClear;

  /// Whether the clear icon button is enabled.
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

/// Two-column row with equal-width children and configurable spacing.
///
/// Output:
/// - A [Row] with `Expanded(left)`, spacer, and `Expanded(right)`.
class TwoColumnFieldRow extends StatelessWidget {
  /// Creates a 2-column row with equal-width children.
  ///
  /// Input:
  /// - [left]: widget rendered in left expanded column.
  /// - [right]: widget rendered in right expanded column.
  /// - [crossAxisAlignment]: vertical alignment for row children.
  /// - [spacing]: horizontal gap between columns.
  const TwoColumnFieldRow({
    required this.left,
    required this.right,
    super.key,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 8,
  });

  /// Left column content.
  final Widget left;

  /// Right column content.
  final Widget right;

  /// Vertical alignment for both columns.
  final CrossAxisAlignment crossAxisAlignment;

  /// Horizontal spacing between columns.
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

/// Reusable pair of labeled numeric inputs rendered in two columns.
///
/// Output:
/// - A [TwoColumnFieldRow] containing two [NumberInputField] widgets.
class LabeledNumberFieldPair extends StatelessWidget {
  /// Creates a reusable pair of labeled numeric inputs in two columns.
  ///
  /// Input:
  /// - [leftController]/[leftLabel]: left number field state and label.
  /// - [rightController]/[rightLabel]: right number field state and label.
  const LabeledNumberFieldPair({
    required this.leftController,
    required this.leftLabel,
    required this.rightController,
    required this.rightLabel,
    super.key,
  });

  /// Controller for the left numeric field.
  final TextEditingController leftController;

  /// Label for the left numeric field.
  final String leftLabel;

  /// Controller for the right numeric field.
  final TextEditingController rightController;

  /// Label for the right numeric field.
  final String rightLabel;

  @override
  Widget build(BuildContext context) {
    return TwoColumnFieldRow(
      left: NumberInputField(controller: leftController, label: leftLabel),
      right: NumberInputField(controller: rightController, label: rightLabel),
    );
  }
}
