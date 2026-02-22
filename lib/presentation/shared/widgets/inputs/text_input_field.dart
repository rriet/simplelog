import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Compact reusable text input field.
class TextInputField extends StatelessWidget {
  const TextInputField({
    super.key,
    required this.controller,
    required this.label,
    this.minLines = 1,
    this.maxLines = 1,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.errorText,
  });

  final TextEditingController controller;
  final String label;
  final int? minLines;
  final int? maxLines;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        errorText: errorText,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 24,
          minHeight: 24,
        ),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
