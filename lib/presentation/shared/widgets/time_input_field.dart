import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimeInputField extends StatefulWidget {
  const TimeInputField({
    super.key,
    required this.controller,
    required this.label,
    this.fallbackMinutes = 0,
    this.onChangedMinutes,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final int fallbackMinutes;
  final ValueChanged<int>? onChangedMinutes;
  final String? Function(String?)? validator;

  @override
  State<TimeInputField> createState() => _TimeInputFieldState();

  static String formatMinutes(int minutes) {
    if (minutes <= 0) return '0:00';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '$hours:${mins.toString().padLeft(2, '0')}';
  }

  static int? parseMinutes(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.contains(':')) {
      final parts = trimmed.split(':');
      if (parts.length != 2) return null;
      final hours = int.tryParse(parts[0]);
      final minutes = int.tryParse(parts[1]);
      if (hours == null || minutes == null) return null;
      return hours * 60 + minutes;
    }
    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    final raw = int.tryParse(digits);
    if (raw == null) return null;
    if (digits.length <= 2) {
      return raw;
    }
    final hours = raw ~/ 100;
    final mins = raw % 100;
    return hours * 60 + mins;
  }
}

class _TimeInputFieldState extends State<TimeInputField> {
  final FocusNode _focusNode = FocusNode();

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
    }
  }

  Future<void> _pickTime() async {
    final currentMinutes =
        TimeInputField.parseMinutes(widget.controller.text) ??
            widget.fallbackMinutes;
    final currentHour = currentMinutes ~/ 60;
    final currentMinute = currentMinutes % 60;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
    );
    if (!mounted || picked == null) return;
    final total = picked.hour * 60 + picked.minute;
    widget.controller.text = TimeInputField.formatMinutes(total);
    widget.onChangedMinutes?.call(total);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 600;
    if (isCompact) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(widget.label),
        subtitle: Text(widget.controller.text),
        trailing: const Icon(Icons.schedule),
        onTap: _pickTime,
      );
    }

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.number,
      inputFormatters: const [TimeInputFormatter()],
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        final parsed = TimeInputField.parseMinutes(value);
        if (parsed != null) {
          widget.onChangedMinutes?.call(parsed);
        }
      },
      validator: widget.validator,
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
