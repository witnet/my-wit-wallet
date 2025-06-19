import 'package:flutter/services.dart';
import 'package:witnet/witnet.dart';

class WitAddressFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    String value = newValue.text;

    if (value.length > 42) {
      value = value.substring(0, 42);
    }
    return TextEditingValue(
        text: value,
        selection:
            TextSelection.fromPosition(TextPosition(offset: value.length)));
  }
}

class WitValueFormatter extends TextInputFormatter {
  String formatDecimalNumber(String value, String separator) {
    if (value.startsWith(separator)) value = '0$value';
    String integerPart = value.split(separator)[0];
    String decimalPart = value.split(separator)[1];
    decimalPart =
        decimalPart.length > 9 ? decimalPart.substring(0, 9) : decimalPart;
    return integerPart + '.' + decimalPart;
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    String value = newValue.text;
    if (value.contains('.')) {
      value = formatDecimalNumber(value, '.');
    } else if (value.contains(',')) {
      value = formatDecimalNumber(value, ',');
    }
    int difference = value.length - newValue.text.length;
    return TextEditingValue(
        text: value,
        selection: TextSelection.fromPosition(
            TextPosition(offset: newValue.selection.end + difference)));
  }
}

String? validateWitValue(String? input) {
  if (input != null) {
    if (input.isEmpty) return 'This field is required';
    if (RegExp(r'[a-zA-Z]').hasMatch(input)) return 'Invalid number';
    if (input.contains('.')) {
      if (input.split('.').length != 2) return 'Invalid number';
      if (input.split('.')[1].isEmpty) return 'Invalid number';
      if (!RegExp(r'^[0-9]+(\.[0-9]{1,9})?$').hasMatch(input))
        return 'Amount Error: Only 9 decimal digits supported';
    }
    if (!RegExp(r'^[0-9]{1,10}(\.[0-9]+)?$').hasMatch(input))
      return 'Amount too big';
  }
  return null;
}

String? validateAddress(String? input) {
  if (input != null) {
    if (input.isEmpty) return 'This field is required';
    if (RegExp(r'^wit1[02-9ac-hj-np-z]{38}$').hasMatch(input)) {
      try {
        Address address = Address.fromAddress(input);
        assert(address.address.isNotEmpty);
      } catch (e) {
        return 'Invalid address';
      }
    } else {
      if (input.length < 42) return 'Address not long enough';
      return 'Invalid address';
    }
  }
  return null;
}
