import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Small convenience wrapper around `TextFormField` with a label and padding.
class FormTextField extends StatelessWidget {
  /// Creates a labeled text form field.
  const FormTextField({
    required this.controller,
    required this.label,
    super.key,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
    this.inputFormatters,
    this.maxLines,
  });

  /// Controller backing the field value.
  final TextEditingController controller;

  /// Localized label shown above the field.
  final String label;

  /// Keyboard type for the underlying input.
  final TextInputType? keyboardType;

  /// Optional validator invoked by a surrounding `Form`.
  final String? Function(String?)? validator;

  /// Optional trailing icon widget.
  final Widget? suffixIcon;

  /// Optional list of input formatters applied to user input.
  final List<TextInputFormatter>? inputFormatters;

  /// Maximum number of lines; `null` falls back to a single line.
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
