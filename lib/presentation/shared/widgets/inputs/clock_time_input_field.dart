import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Input field for wall-clock time in 24h format (`HH:mm`).
///
/// Valid range is `00:00` to `23:59`.
class ClockTimeInputField extends StatefulWidget {
  /// Creates a clock-time input field.
  const ClockTimeInputField({
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

  /// Text controller bound to the formatted `HH:mm` value.
  final TextEditingController controller;
  /// Input label shown in the field decoration.
  final String label;
  /// Value emitted when input is empty and focus is lost.
  final int fallbackMinutes;
  /// Callback receiving parsed minutes-of-day on valid changes.
  final ValueChanged<int>? onChangedMinutes;
  /// Callback fired when field is cleared and [allowEmpty] is true.
  final VoidCallback? onCleared;
  /// Optional additional validator called after built-in validation.
  final String? Function(String?)? validator;
  /// Optional suffix widget.
  final Widget? suffixIcon;
  /// Whether empty text is considered valid.
  final bool allowEmpty;
  /// External error text override.
  final String? errorText;

  /// Formats minutes-of-day into `HH:mm`.
  static String formatMinutesOfDay(int minutes) {
    final safe = minutes.clamp(0, 23 * 60 + 59);
    final hours = safe ~/ 60;
    final mins = safe % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${mins.toString().padLeft(2, '0')}';
  }

  /// Parses `HH:mm` or compact numeric input into minutes-of-day.
  static int? parseMinutesOfDay(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.contains(':')) {
      final parts = trimmed.split(':');
      if (parts.length != 2) return null;
      final hours = int.tryParse(parts[0]);
      final minutes = int.tryParse(parts[1]);
      if (hours == null || minutes == null) return null;
      if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) return null;
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
    if (hours > 23 || mins > 59) return null;
    return hours * 60 + mins;
  }

  /// Returns whether [value] is a valid clock text.
  static bool isValidClockText(String value, {bool allowEmpty = false}) {
    final trimmed = value.trim();
    if (allowEmpty && trimmed.isEmpty) return true;
    return parseMinutesOfDay(trimmed) != null;
  }

  @override
  State<ClockTimeInputField> createState() => _ClockTimeInputFieldState();
}

class _ClockTimeInputFieldState extends State<ClockTimeInputField> {
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
      final fallback = ClockTimeInputField.formatMinutesOfDay(
        widget.fallbackMinutes,
      );
      widget.controller.text = fallback;
      widget.onChangedMinutes?.call(widget.fallbackMinutes);
      _fieldKey.currentState?.validate();
      return;
    }

    final parsed = ClockTimeInputField.parseMinutesOfDay(text);
    if (parsed == null) {
      _fieldKey.currentState?.validate();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _focusNode.requestFocus();
      });
      return;
    }

    widget.controller.text = ClockTimeInputField.formatMinutesOfDay(parsed);
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
      inputFormatters: const [ClockTimeInputFormatter()],
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
        final parsed = ClockTimeInputField.parseMinutesOfDay(value);
        if (parsed != null) {
          widget.onChangedMinutes?.call(parsed);
        } else if (widget.allowEmpty && value.trim().isEmpty) {
          widget.onCleared?.call();
        }
      },
      autovalidateMode: AutovalidateMode.disabled,
      validator: (value) {
        final raw = value ?? '';
        if (!ClockTimeInputField.isValidClockText(
          raw,
          allowEmpty: widget.allowEmpty,
        )) {
          return 'Invalid time. Use 00:00 to 23:59.';
        }
        return widget.validator?.call(value);
      },
    );
  }
}

/// Input formatter that keeps clock-time text in `HH:mm` shape.
class ClockTimeInputFormatter extends TextInputFormatter {
  /// Creates the formatter.
  const ClockTimeInputFormatter();

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
    final text =
        '${hours.toString().padLeft(2, '0')}:'
        '${mins.toString().padLeft(2, '0')}';

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
