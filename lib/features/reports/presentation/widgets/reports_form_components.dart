import 'package:flutter/material.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/inputs/clock_time_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/date_selector_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/dropdown_input_field.dart';

/// Generic dropdown form field for enum-like report selectors.
class ReportsEnumDropdownField<T> extends StatelessWidget {
  /// Creates a dropdown field for selecting one value from [options].
  ///
  /// Input:
  /// - [value]: currently selected option.
  /// - [label]: field label displayed in input decoration.
  /// - [options]: all selectable values.
  /// - [optionLabel]: maps each option to its UI label.
  /// - [onChanged]: called when user selects a non-null option.
  ///
  /// Output:
  /// - A compact [DropdownInputField] with truncation handling.
  const ReportsEnumDropdownField({
    required this.value,
    required this.label,
    required this.options,
    required this.optionLabel,
    required this.onChanged,
    super.key,
  });

  /// Currently selected value.
  final T value;

  /// Input label displayed above/inside the dropdown.
  final String label;

  /// Selectable options rendered in the dropdown menu.
  final List<T> options;

  /// Label builder for menu items and selected display text.
  final String Function(T value) optionLabel;

  /// Callback invoked when selection changes.
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownInputField<T>(
      label: label,
      value: value,
      items: options
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: _DropdownOverflowText(optionLabel(item)),
            ),
          )
          .toList(growable: false),
      onChanged: (next) {
        if (next != null) {
          onChanged(next);
        }
      },
    );
  }
}

/// Horizontal row with date picker on the left and HH:MM input on the right.
class DateAndHourRow extends StatelessWidget {
  /// Creates the date/time pair row used in report filter forms.
  ///
  /// Input:
  /// - [dateLabel]: label for date selector.
  /// - [dateValueText]: formatted date shown in selector.
  /// - [onPickDate]: callback executed when date selector is tapped.
  /// - [timeController]: controller for the time text field.
  /// - [onTimeChanged]: callback receiving time in minutes.
  /// - [timeLabel]: optional label for the time field.
  ///
  /// Output:
  /// - A 2-column [Row] combining [DateSelectorInputField] and
  ///   [ClockTimeInputField].
  const DateAndHourRow({
    required this.dateLabel,
    required this.dateValueText,
    required this.onPickDate,
    required this.timeController,
    required this.onTimeChanged,
    super.key,
    this.timeLabel = 'Hour',
  });

  /// Label for the date selector.
  final String dateLabel;

  /// Formatted date text shown in the selector field.
  final String dateValueText;

  /// Tap handler to pick a date.
  final VoidCallback onPickDate;

  /// Controller for the time input.
  final TextEditingController timeController;

  /// Callback that receives the changed time in minutes.
  final ValueChanged<int> onTimeChanged;

  /// Label for the time input.
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DateSelectorInputField(
            label: dateLabel,
            valueText: dateValueText,
            onTap: onPickDate,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClockTimeInputField(
            controller: timeController,
            label: timeLabel,
            onChangedMinutes: onTimeChanged,
          ),
        ),
      ],
    );
  }
}

/// Confirmation dialog with one primary top-right action.
class ReportsConfirmActionDialog extends StatelessWidget {
  /// Creates a compact confirm dialog for report actions.
  ///
  /// Input:
  /// - [title]: dialog title.
  /// - [actionLabel]: primary action text (returns `true` when pressed).
  /// - [message]: body message shown in the dialog content.
  ///
  /// Output:
  /// - An [AdaptiveFormShell] dialog that pops `false` on close and `true` on
  ///   primary action.
  const ReportsConfirmActionDialog({
    required this.title,
    required this.actionLabel,
    required this.message,
    super.key,
  });

  /// Dialog title text.
  final String title;

  /// Label for the primary confirmation action.
  final String actionLabel;

  /// Body message shown in dialog content.
  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      child: AdaptiveFormShell(
        onClose: () => AppNavigator.pop(context, false),
        title: title,
        fullScreen: false,
        actions: [
          TextButton(
            onPressed: () => AppNavigator.pop(context, true),
            child: Text(actionLabel),
          ),
        ],
        contentView: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(message),
        ),
      ),
    );
  }
}

/// Reusable dialog shell for reports sub-forms with a single action button.
class ReportsDialogScaffoldSection extends StatelessWidget {
  /// Creates a titled dialog section with one action button and custom content.
  ///
  /// Input:
  /// - [title]: header title.
  /// - [actionLabel]: action button text in header row.
  /// - [onAction]: callback invoked when header action is pressed.
  /// - [content]: dialog body widget.
  /// - [maxWidth]: max popup width used by [AdaptiveFormShell].
  ///
  /// Output:
  /// - An [AdaptiveFormShell] with a single primary top-right action.
  const ReportsDialogScaffoldSection({
    required this.title,
    required this.actionLabel,
    required this.onAction,
    required this.content,
    super.key,
    this.maxWidth = 520,
  });

  /// Header title text.
  final String title;

  /// Header action button label.
  final String actionLabel;

  /// Callback for the header action button.
  final VoidCallback onAction;

  /// Body widget rendered below the header.
  final Widget content;

  /// Target dialog width.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return AdaptiveFormShell(
      title: title,
      onClose: () => AppNavigator.pop(context),
      fullScreen: false,
      popupMaxWidth: maxWidth,
      actions: [
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
      contentView: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(child: content),
      ),
    );
  }
}

/// Basic labeled [TextFormField] used by reports dialogs.
class ReportsLabeledInputField extends StatelessWidget {
  /// Creates a labeled text input for reports forms.
  ///
  /// Input:
  /// - [controller]: field text controller.
  /// - [label]: label text in decoration.
  /// - [keyboardType]: optional keyboard type hint.
  ///
  /// Output:
  /// - A standard outlined [TextFormField].
  const ReportsLabeledInputField({
    required this.controller,
    required this.label,
    super.key,
    this.keyboardType,
  });

  /// Controller for the input text.
  final TextEditingController controller;

  /// Label displayed for the text field.
  final String label;

  /// Optional keyboard type to optimize input method.
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _DropdownOverflowText extends StatelessWidget {
  const _DropdownOverflowText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );
  }
}
