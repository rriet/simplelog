import 'package:flutter/services.dart';

/// Forces all entered text to uppercase.
class UpperCaseTextFormatter extends TextInputFormatter {
  /// Creates the formatter.
  const UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
