import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  ThousandsSeparatorInputFormatter({String? pattern, String? locale})
      : _formatter = pattern != null
            ? NumberFormat(pattern, locale)
            : NumberFormat.decimalPattern(locale ?? 'vi_VN');

  final NumberFormat _formatter;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final onlyDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (onlyDigits.isEmpty) {
      return newValue.copyWith(text: '', selection: const TextSelection.collapsed(offset: 0));
    }

    final number = int.parse(onlyDigits);
    final newText = _formatter.format(number);

    // Try to keep the cursor near the end proportionally
    final selectionIndex = newText.length - (oldValue.text.length - oldValue.selection.end).clamp(0, newText.length);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selectionIndex.clamp(0, newText.length)),
    );
  }
}


