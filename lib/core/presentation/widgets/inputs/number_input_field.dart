import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simplelog/core/theme/app_form_controls_theme.dart';

/// Compact numeric input field (integer values).
class NumberInputField extends StatefulWidget {
  /// Creates a numeric input field with shared form styling.
  const NumberInputField({
    required this.controller,
    required this.label,
    super.key,
    this.allowEmpty = false,
    this.enabled = true,
    this.onChanged,
    this.suffixIcon,
    this.errorText,
    this.hintText,
    this.floatingLabelBehavior,
  });

  /// Text controller used by the field.
  final TextEditingController controller;

  /// Field label.
  final String label;

  /// Whether empty values are accepted.
  final bool allowEmpty;

  /// Whether user input is enabled.
  final bool enabled;

  /// Called when the parsed number changes.
  final ValueChanged<int?>? onChanged;

  /// Optional trailing icon widget.
  final Widget? suffixIcon;

  /// Optional external inline error text.
  final String? errorText;

  /// Optional placeholder text.
  final String? hintText;

  /// Label floating behavior override.
  final FloatingLabelBehavior? floatingLabelBehavior;

  /// Parses an integer value from raw text.
  static int? parse(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  @override
  State<NumberInputField> createState() => _NumberInputFieldState();
}

class _NumberInputFieldState extends State<NumberInputField> {
  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncFieldValueFromController);
  }

  @override
  void didUpdateWidget(covariant NumberInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_syncFieldValueFromController);
    widget.controller.addListener(_syncFieldValueFromController);
    _syncFieldValueFromController();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncFieldValueFromController);
    super.dispose();
  }

  void _syncFieldValueFromController() {
    _fieldKey.currentState?.didChange(widget.controller.text);
  }

  String? _validationMessage(String? value) {
    final raw = value ?? '';
    if (widget.allowEmpty && raw.trim().isEmpty) return null;
    if (NumberInputField.parse(raw) == null) return 'Invalid number.';
    return null;
  }

  String? _displayErrorText(String? internalErrorText) {
    final external = widget.errorText;
    if ((external ?? '').trim().isNotEmpty) return external;
    if ((internalErrorText ?? '').trim().isNotEmpty) return internalErrorText;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controlsTheme =
        theme.extension<AppFormControlsTheme>() ??
        AppFormControlsTheme.fallback;
    final colorScheme = theme.colorScheme;

    return FormField<String>(
      key: _fieldKey,
      initialValue: widget.controller.text,
      autovalidateMode: AutovalidateMode.disabled,
      validator: _validationMessage,
      builder: (field) {
        final errorText = _displayErrorText(field.errorText);
        final hasError = (errorText ?? '').trim().isNotEmpty;
        final borderColor = hasError
            ? colorScheme.error
            : colorScheme.outlineVariant;
        final labelColor = hasError
            ? colorScheme.error
            : colorScheme.onSurfaceVariant;
        final showLabel =
            widget.floatingLabelBehavior != FloatingLabelBehavior.never;

        final control = SizedBox(
          height: controlsTheme.compactFieldHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Material(
                  color: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      controlsTheme.compactBorderRadius,
                    ),
                    side: BorderSide(
                      color: borderColor,
                      width: controlsTheme.compactBorderWidth,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: controlsTheme.horizontalContentPadding,
                      vertical: controlsTheme.verticalContentPadding,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: widget.controller,
                            enabled: widget.enabled,
                            keyboardType: TextInputType.number,
                            textAlignVertical: TextAlignVertical.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: controlsTheme.bodyFontSize,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              hintText: widget.hintText,
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: controlsTheme.bodyFontSize,
                              ),
                            ),
                            onChanged: (value) {
                              field.didChange(value);
                              widget.onChanged?.call(
                                NumberInputField.parse(value),
                              );
                            },
                          ),
                        ),
                        if (widget.suffixIcon case final suffixIcon?)
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: controlsTheme.suffixIconMinSize,
                              minHeight: controlsTheme.suffixIconMinSize,
                            ),
                            child: suffixIcon,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (showLabel)
                Positioned(
                  left: controlsTheme.labelOffsetLeft,
                  top: controlsTheme.labelOffsetTop,
                  child: Container(
                    color: colorScheme.surface,
                    padding: EdgeInsets.symmetric(
                      horizontal: controlsTheme.labelChipHorizontalPadding,
                    ),
                    child: Text(
                      widget.label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: labelColor,
                        fontSize: controlsTheme.labelFontSize,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );

        final padded = EdgeInsets.symmetric(
          vertical: controlsTheme.fieldVerticalGap / 2,
        );
        if (!hasError) return Padding(padding: padded, child: control);
        return Padding(
          padding: padded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              control,
              SizedBox(height: controlsTheme.errorTopSpacing),
              Padding(
                padding: EdgeInsets.only(left: controlsTheme.errorLeftPadding),
                child: Text(
                  errorText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                    fontSize: controlsTheme.errorFontSize,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
