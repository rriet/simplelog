import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Input field for wall-clock time in 24h format (`HH:mm`).
///
/// Valid range is `00:00` to `23:59`.
class ClockTimeInputField extends StatefulWidget {
  /// Public API documentation.
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
/// Public API documentation.

  /// Public API documentation.
  final TextEditingController controller;
  /// Public API documentation.
  final String label;
  /// Public API documentation.
  final int fallbackMinutes;
  /// Public API documentation.
  final ValueChanged<int>? onChangedMinutes;
  /// Public API documentation.
  final VoidCallback? onCleared;
  /// Public API documentation.
  final String? Function(String?)? validator;
  /// Public API documentation.
  final Widget? suffixIcon;
  /// Public API documentation.
  final bool allowEmpty;
  /// Public API documentation.
  final String? errorText;

  /// Public API documentation.
  static String formatMinutesOfDay(int minutes) {
    final safe = minutes.clamp(0, 23 * 60 + 59);
    final hours = safe ~/ 60;
    final mins = safe % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${mins.toString().padLeft(2, '0')}';
  }

  /// Public API documentation.
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
    /// Public API documentation.
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

  /// Public API documentation.
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
        /// Public API documentation.
        final raw = value ?? '';
        /// Public API documentation.
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

/// Public API documentation.
class ClockTimeInputFormatter extends TextInputFormatter {
  /// Public API documentation.
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
