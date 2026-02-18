import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimeInputField extends StatefulWidget {
  const TimeInputField({
    super.key,
    required this.controller,
    required this.label,
    this.fallbackMinutes = 0,
    this.onChangedMinutes,
    this.onCleared,
    this.validator,
    this.suffixIcon,
    this.forceTextField = false,
    this.allowEmpty = false,
    this.maxHours,
  });

  final TextEditingController controller;
  final String label;
  final int fallbackMinutes;
  final ValueChanged<int>? onChangedMinutes;
  final VoidCallback? onCleared;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final bool forceTextField;
  final bool allowEmpty;
  final int? maxHours;

  @override
  State<TimeInputField> createState() => _TimeInputFieldState();

  static String formatMinutes(int minutes) {
    if (minutes <= 0) return '0:00';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '$hours:${mins.toString().padLeft(2, '0')}';
  }

  static int? parseMinutes(String value, {int? maxHours}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.contains(':')) {
      final parts = trimmed.split(':');
      if (parts.length != 2) return null;
      final hours = int.tryParse(parts[0]);
      final minutes = int.tryParse(parts[1]);
      if (hours == null || minutes == null) return null;
      if (minutes < 0 || minutes > 59 || hours < 0) return null;
      if (maxHours != null && hours > maxHours) return null;
      return hours * 60 + minutes;
    }
    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
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
    if (maxHours != null && hours > maxHours) return null;
    return hours * 60 + mins;
  }

  static bool isValidTimeText(
    String value, {
    bool allowEmpty = false,
    int? maxHours,
  }) {
    final trimmed = value.trim();
    if (allowEmpty && trimmed.isEmpty) return true;
    return parseMinutes(trimmed, maxHours: maxHours) != null;
  }
}

class _TimeInputFieldState extends State<TimeInputField> {
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
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
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
      final fallback = TimeInputField.formatMinutes(widget.fallbackMinutes);
      widget.controller.text = fallback;
      widget.onChangedMinutes?.call(widget.fallbackMinutes);
      _fieldKey.currentState?.validate();
      return;
    }

    if (!TimeInputField.isValidTimeText(
      text,
      allowEmpty: widget.allowEmpty,
      maxHours: widget.maxHours,
    )) {
      _fieldKey.currentState?.validate();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _focusNode.requestFocus();
      });
      return;
    }

    _fieldKey.currentState?.validate();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: _fieldKey,
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.number,
      inputFormatters: const [TimeInputFormatter()],
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        suffixIcon: widget.suffixIcon,
      ),
      onChanged: (value) {
        final parsed = TimeInputField.parseMinutes(value);
        if (parsed != null) {
          widget.onChangedMinutes?.call(parsed);
        } else if (widget.allowEmpty && value.trim().isEmpty) {
          widget.onCleared?.call();
        }
      },
      autovalidateMode: AutovalidateMode.disabled,
      validator: (value) {
        final raw = value ?? '';
        if (!TimeInputField.isValidTimeText(
          raw,
          allowEmpty: widget.allowEmpty,
          maxHours: widget.maxHours,
        )) {
          final hoursHint = widget.maxHours != null
              ? ' and hours must be between 00 and ${widget.maxHours!.toString().padLeft(2, '0')}'
              : '';
          return 'Invalid time. Minutes must be between 00 and 59$hoursHint.';
        }
        return widget.validator?.call(value);
      },
    );
  }
}

class TimeInputFormatter extends TextInputFormatter {
  const TimeInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final minutes = int.tryParse(digits) ?? 0;
    final hours = digits.length <= 2 ? 0 : minutes ~/ 100;
    final mins = digits.length <= 2 ? minutes : minutes % 100;
    final text = '$hours:${mins.toString().padLeft(2, '0')}';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
