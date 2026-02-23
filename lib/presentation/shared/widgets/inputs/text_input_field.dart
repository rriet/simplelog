import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Compact reusable text input field.
class TextInputField extends StatelessWidget {
  /// Creates a text input field with shared app styling.
  const TextInputField({
    required this.controller,
    required this.label,
    super.key,
    this.minLines = 1,
    this.maxLines = 1,
    this.suffixIcon,
    this.validator,
    this.onChanged,
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

  /// Optional validator callback.
  final String? Function(String?)? validator;

  /// Called when text changes.
  final ValueChanged<String>? onChanged;

  /// Optional keyboard type override.
  final TextInputType? keyboardType;

  /// Optional input formatters.
  final List<TextInputFormatter>? inputFormatters;

  /// Optional external inline error text.
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
