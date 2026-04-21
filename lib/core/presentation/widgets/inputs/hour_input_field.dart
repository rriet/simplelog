import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simplelog/core/theme/app_form_controls_theme.dart';

/// Input field for elapsed hours in `h:mm` format.
///
/// This is not a wall-clock time field. Hours can grow beyond 24.
class HourInputField extends StatefulWidget {
  /// Creates an elapsed-hours input field.
  const HourInputField({
    required this.controller,
    required this.label,
    super.key,
    this.fallbackMinutes = 0,
    this.onChangedMinutes,
    this.onCleared,
    this.validator,
    this.suffixIcon,
    this.allowEmpty = false,
    this.readOnly = false,
    this.errorText,
  });

  /// Text controller that stores the field value.
  final TextEditingController controller;

  /// Field label.
  final String label;

  /// Fallback value used when the field loses focus empty.
  final int fallbackMinutes;

  /// Called when a valid elapsed-time value is parsed.
  final ValueChanged<int>? onChangedMinutes;

  /// Called when the field is cleared and empty values are allowed.
  final VoidCallback? onCleared;

  /// Optional extra validator.
  final String? Function(String?)? validator;

  /// Optional trailing icon widget.
  final Widget? suffixIcon;

  /// Whether an empty value is accepted.
  final bool allowEmpty;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Optional inline validation error controlled externally.
  final String? errorText;

  /// Formats elapsed minutes as `h:mm`.
  static String formatHours(int minutes) {
    if (minutes <= 0) return '0:00';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '$hours:${mins.toString().padLeft(2, '0')}';
  }

  /// Parses `h:mm` or compact numeric text into elapsed minutes.
  static int? parseHours(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.contains(':')) {
      final parts = trimmed.split(':');
      if (parts.length != 2) return null;
      final hours = int.tryParse(parts[0]);
      final minutes = int.tryParse(parts[1]);
      if (hours == null || minutes == null) return null;
      if (hours < 0 || minutes < 0 || minutes > 59) return null;
      return hours * 60 + minutes;
    }
    final digits = trimmed.replaceAll(RegExp('[^0-9]'), '');
    if (digits.isEmpty) return null;
    final raw = int.tryParse(digits);
    if (raw == null) return null;
    if (digits.length <= 2) {
      if (raw > 59) return null;
      return raw;
    }
    final hours = raw ~/ 100;
    final mins = raw % 100;
    if (mins > 59) return null;
    return hours * 60 + mins;
  }

  /// Returns `true` when the text can be parsed as elapsed time.
  static bool isValidHoursText(String value, {bool allowEmpty = false}) {
    final trimmed = value.trim();
    if (allowEmpty && trimmed.isEmpty) return true;
    return parseHours(trimmed) != null;
  }

  @override
  State<HourInputField> createState() => _HourInputFieldState();
}

class _HourInputFieldState extends State<HourInputField> {
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
    widget.controller.addListener(_syncFieldValueFromController);
  }

  @override
  void didUpdateWidget(covariant HourInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_syncFieldValueFromController);
    widget.controller.addListener(_syncFieldValueFromController);
    _syncFieldValueFromController();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncFieldValueFromController);
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  void _syncFieldValueFromController() {
    _fieldKey.currentState?.didChange(widget.controller.text);
  }

  String? _validationMessage(String? value) {
    final raw = value ?? '';
    if (!HourInputField.isValidHoursText(raw, allowEmpty: widget.allowEmpty)) {
      return 'Invalid hours. Minutes must be between 00 and 59.';
    }
    return widget.validator?.call(value);
  }

  String? _displayErrorText(String? internalErrorText) {
    final external = widget.errorText;
    if ((external ?? '').trim().isNotEmpty) return external;
    if ((internalErrorText ?? '').trim().isNotEmpty) return internalErrorText;
    return null;
  }

  void _handleFocusChange() {
    if (widget.readOnly) return;

    if (_focusNode.hasFocus) {
      widget.controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.controller.text.length,
      );
      return;
    }

    final text = widget.controller.text.trim();
    if (widget.allowEmpty && text.isEmpty) {
      _syncFieldValueFromController();
      _fieldKey.currentState?.validate();
      widget.onCleared?.call();
      return;
    }

    if (text.isEmpty) {
      final fallback = HourInputField.formatHours(widget.fallbackMinutes);
      widget.controller.text = fallback;
      _syncFieldValueFromController();
      widget.onChangedMinutes?.call(widget.fallbackMinutes);
      _fieldKey.currentState?.validate();
      return;
    }

    final parsed = HourInputField.parseHours(text);
    if (parsed == null) {
      _syncFieldValueFromController();
      _fieldKey.currentState?.validate();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _focusNode.requestFocus();
      });
      return;
    }

    widget.controller.text = HourInputField.formatHours(parsed);
    _syncFieldValueFromController();
    widget.onChangedMinutes?.call(parsed);
    _fieldKey.currentState?.validate();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputTheme =
        theme.extension<AppFormControlsTheme>() ??
        AppFormControlsTheme.fallback;
    final colorScheme = theme.colorScheme;
    final compactHeight = inputTheme.resolvedCompactFieldHeight(
      context,
      baseTextStyle: theme.textTheme.bodyMedium,
    );
    final effectiveBodyFontSize = inputTheme.resolvedBodyFontSize(
      context,
      baseTextStyle: theme.textTheme.bodyMedium,
      controlHeight: compactHeight,
    );

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

        final control = SizedBox(
          height: compactHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Material(
                  color: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      inputTheme.compactBorderRadius,
                    ),
                    side: BorderSide(
                      color: borderColor,
                      width: inputTheme.compactBorderWidth,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: inputTheme.horizontalContentPadding,
                      vertical: inputTheme.verticalContentPadding,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: widget.controller,
                            focusNode: _focusNode,
                            readOnly: widget.readOnly,
                            keyboardType: TextInputType.number,
                            textAlignVertical: TextAlignVertical.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: effectiveBodyFontSize,
                            ),
                            inputFormatters: const [HourInputFormatter()],
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (value) {
                              field.didChange(value);
                              final parsed = HourInputField.parseHours(value);
                              if (parsed != null) {
                                widget.onChangedMinutes?.call(parsed);
                              } else if (widget.allowEmpty &&
                                  value.trim().isEmpty) {
                                widget.onCleared?.call();
                              }
                            },
                          ),
                        ),
                        if (widget.suffixIcon case final suffixIcon?)
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: inputTheme.suffixIconMinSize,
                              minHeight: inputTheme.suffixIconMinSize,
                            ),
                            child: suffixIcon,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: inputTheme.labelOffsetLeft,
                top: inputTheme.labelOffsetTop,
                child: Container(
                  color: colorScheme.surface,
                  padding: EdgeInsets.symmetric(
                    horizontal: inputTheme.labelChipHorizontalPadding,
                  ),
                  child: Text(
                    widget.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: labelColor,
                      fontSize: inputTheme.labelFontSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

        final padded = EdgeInsets.symmetric(
          vertical: inputTheme.fieldVerticalGap / 2,
        );
        if (!hasError) return Padding(padding: padded, child: control);
        return Padding(
          padding: padded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              control,
              SizedBox(height: inputTheme.errorTopSpacing),
              Padding(
                padding: EdgeInsets.only(left: inputTheme.errorLeftPadding),
                child: Text(
                  errorText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                    fontSize: inputTheme.errorFontSize,
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

/// Input formatter that forces numeric entry into `h:mm` shape.
class HourInputFormatter extends TextInputFormatter {
  /// Creates a formatter that enforces `h:mm` display while typing.
  const HourInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp('[^0-9]'), '');
    if (digits.isEmpty) {
      return TextEditingValue.empty;
    }

    final raw = int.tryParse(digits) ?? 0;
    final hours = digits.length <= 2 ? 0 : raw ~/ 100;
    final mins = digits.length <= 2 ? raw : raw % 100;
    final text = '$hours:${mins.toString().padLeft(2, '0')}';

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
