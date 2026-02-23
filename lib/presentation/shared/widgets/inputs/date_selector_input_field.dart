import 'package:flutter/material.dart';

/// Tappable date selector styled as a form input.
class DateSelectorInputField extends StatelessWidget {
  /// Creates a date selector input styled like other form fields.
  const DateSelectorInputField({
    required this.label,
    required this.valueText,
    required this.onTap,
    super.key,
    this.errorText,
  });

  /// Field label.
  final String label;

  /// Selected date text shown in the field.
  final String valueText;

  /// Called when the field is tapped.
  final VoidCallback onTap;

  /// Optional inline validation error.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          errorText: errorText,
          contentPadding: const EdgeInsetsDirectional.fromSTEB(
            12,
            10,
            6,
            10,
          ),
        ),
        child: Text(
          valueText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
