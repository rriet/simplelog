import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Public API documentation.
class FormTextField extends StatelessWidget {
  /// Public API documentation.
  const FormTextField({
    required this.controller,
    required this.label,
    super.key,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
    this.inputFormatters,
    this.maxLines,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final TextEditingController controller;
  /// Public API documentation.
  final String label;
  /// Public API documentation.
  final TextInputType? keyboardType;
  /// Public API documentation.
  final String? Function(String?)? validator;
  /// Public API documentation.
  final Widget? suffixIcon;
  /// Public API documentation.
  final List<TextInputFormatter>? inputFormatters;
  /// Public API documentation.
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
