import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      widget.controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.controller.text.length,
      );
      return;
    }

    final text = widget.controller.text.trim();
    if (widget.allowEmpty && text.isEmpty) {
      _fieldKey.currentState?.validate();
      widget.onCleared?.call();
      return;
    }

    if (text.isEmpty) {
      final fallback = HourInputField.formatHours(widget.fallbackMinutes);
      widget.controller.text = fallback;
      widget.onChangedMinutes?.call(widget.fallbackMinutes);
      _fieldKey.currentState?.validate();
      return;
    }

    final parsed = HourInputField.parseHours(text);
    if (parsed == null) {
      _fieldKey.currentState?.validate();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _focusNode.requestFocus();
      });
      return;
    }

    widget.controller.text = HourInputField.formatHours(parsed);
    widget.onChangedMinutes?.call(parsed);
    _fieldKey.currentState?.validate();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: _fieldKey,
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.number,
      inputFormatters: const [HourInputFormatter()],
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        errorText: widget.errorText,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 24,
          minHeight: 24,
        ),
        suffixIcon: widget.suffixIcon,
      ),
      onChanged: (value) {
        final parsed = HourInputField.parseHours(value);
        if (parsed != null) {
          widget.onChangedMinutes?.call(parsed);
        } else if (widget.allowEmpty && value.trim().isEmpty) {
          widget.onCleared?.call();
        }
      },
      autovalidateMode: AutovalidateMode.disabled,
      validator: (value) {
        final raw = value ?? '';
        if (!HourInputField.isValidHoursText(
          raw,
          allowEmpty: widget.allowEmpty,
        )) {
          return 'Invalid hours. Minutes must be between 00 and 59.';
        }
        return widget.validator?.call(value);
      },
    );
  }
}

/// Public API documentation.
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
