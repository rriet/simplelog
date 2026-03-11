import 'package:flutter/material.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/inputs/clock_time_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/date_selector_input_field.dart';

class ReportsEnumDropdownField<T> extends StatelessWidget {
  const ReportsEnumDropdownField({
    required this.value,
    required this.label,
    required this.options,
    required this.optionLabel,
    required this.onChanged,
    super.key,
  });

  final T value;
  final String label;
  final List<T> options;
  final String Function(T value) optionLabel;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: options
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: _DropdownOverflowText(optionLabel(item)),
            ),
          )
          .toList(growable: false),
      selectedItemBuilder: (context) => options
          .map((item) => _DropdownSelectedText(optionLabel(item)))
          .toList(growable: false),
      onChanged: (next) {
        if (next != null) {
          onChanged(next);
        }
      },
    );
  }
}

class DateAndHourRow extends StatelessWidget {
  const DateAndHourRow({
    required this.dateLabel,
    required this.dateValueText,
    required this.onPickDate,
    required this.timeController,
    required this.onTimeChanged,
    super.key,
    this.timeLabel = 'Hour',
  });

  final String dateLabel;
  final String dateValueText;
  final VoidCallback onPickDate;
  final TextEditingController timeController;
  final ValueChanged<int> onTimeChanged;
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

class ReportsConfirmActionDialog extends StatelessWidget {
  const ReportsConfirmActionDialog({
    required this.title,
    required this.actionLabel,
    required this.message,
    super.key,
  });

  final String title;
  final String actionLabel;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      child: AdaptiveFormShell(
        onClose: () => AppNavigator.pop(context, false),
        longTitle: title,
        shortTitle: title,
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

class ReportsDialogScaffoldSection extends StatelessWidget {
  const ReportsDialogScaffoldSection({
    required this.title,
    required this.actionLabel,
    required this.onAction,
    required this.content,
    super.key,
    this.maxWidth = 520,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;
  final Widget content;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: maxWidth,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  TextButton(onPressed: onAction, child: Text(actionLabel)),
                ],
              ),
              const SizedBox(height: 8),
              content,
            ],
          ),
        ),
      ),
    );
  }
}

class ReportsLabeledInputField extends StatelessWidget {
  const ReportsLabeledInputField({
    required this.controller,
    required this.label,
    super.key,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
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

class _DropdownSelectedText extends StatelessWidget {
  const _DropdownSelectedText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
    );
  }
}
