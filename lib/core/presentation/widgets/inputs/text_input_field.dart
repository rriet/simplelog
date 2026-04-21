import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simplelog/core/theme/app_form_controls_theme.dart';

/// Compact reusable text input field.
class TextInputField extends StatefulWidget {
  /// Creates a text input field with shared app styling.
  const TextInputField({
    required this.controller,
    required this.label,
    super.key,
    this.minLines = 1,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.autofocus = false,
    this.readOnly = false,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType,
    this.inputFormatters,
    this.errorText,
  });

  /// Text controller used by the field.
  final TextEditingController controller;

  /// Field label.
  final String label;

  /// Minimum visible lines.
  final int? minLines;

  /// Maximum visible lines.
  final int? maxLines;

  /// Optional trailing icon widget.
  final Widget? suffixIcon;

  /// Optional leading icon widget.
  final Widget? prefixIcon;

  /// Optional validator callback.
  final String? Function(String?)? validator;

  /// Called when text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field.
  final ValueChanged<String>? onSubmitted;

  /// Called when the field is tapped.
  final VoidCallback? onTap;

  /// Optional focus node override.
  final FocusNode? focusNode;

  /// Whether the field should autofocus.
  final bool autofocus;

  /// Whether the field is read only.
  final bool readOnly;

  /// Text capitalization strategy.
  final TextCapitalization textCapitalization;

  /// Optional keyboard type override.
  final TextInputType? keyboardType;

  /// Optional input formatters.
  final List<TextInputFormatter>? inputFormatters;

  /// Optional external inline error text.
  final String? errorText;

  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncFieldValueFromController);
  }

  @override
  void didUpdateWidget(covariant TextInputField oldWidget) {
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

  String? _displayErrorText(String? internalErrorText) {
    final external = widget.errorText;
    if ((external ?? '').trim().isNotEmpty) return external;
    if ((internalErrorText ?? '').trim().isNotEmpty) return internalErrorText;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isSingleLine =
        (widget.minLines ?? 1) == 1 && (widget.maxLines ?? 1) == 1;
    final theme = Theme.of(context);
    final controlsTheme =
        theme.extension<AppFormControlsTheme>() ??
        AppFormControlsTheme.fallback;
    final colorScheme = theme.colorScheme;

    return FormField<String>(
      key: _fieldKey,
      initialValue: widget.controller.text,
      autovalidateMode: AutovalidateMode.disabled,
      validator: widget.validator,
      builder: (field) {
        final errorText = _displayErrorText(field.errorText);
        final hasError = (errorText ?? '').trim().isNotEmpty;
        final borderColor = hasError
            ? colorScheme.error
            : colorScheme.outlineVariant;
        final labelColor = hasError
            ? colorScheme.error
            : colorScheme.onSurfaceVariant;

        final fieldPadding = EdgeInsets.symmetric(
          horizontal: controlsTheme.horizontalContentPadding,
          vertical: controlsTheme.verticalContentPadding,
        );

        final input = Padding(
          padding: fieldPadding,
          child: Row(
            crossAxisAlignment: isSingleLine
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              if (widget.prefixIcon case final prefixIcon?) ...[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: controlsTheme.suffixIconMinSize,
                    minHeight: controlsTheme.suffixIconMinSize,
                  ),
                  child: prefixIcon,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  autofocus: widget.autofocus,
                  readOnly: widget.readOnly,
                  textCapitalization: widget.textCapitalization,
                  minLines: widget.minLines,
                  maxLines: widget.maxLines,
                  textAlignVertical: isSingleLine
                      ? TextAlignVertical.center
                      : TextAlignVertical.top,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: controlsTheme.bodyFontSize,
                  ),
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
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
                    widget.onChanged?.call(value);
                  },
                  onSubmitted: widget.onSubmitted,
                  onTap: widget.onTap,
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
        );

        final shell = Stack(
          fit: StackFit.passthrough,
          clipBehavior: Clip.none,
          children: [
            Material(
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
              child: input,
            ),
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
        );

        final control = isSingleLine
            ? SizedBox(height: controlsTheme.compactFieldHeight, child: shell)
            : ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: controlsTheme.compactFieldHeight,
                ),
                child: shell,
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
