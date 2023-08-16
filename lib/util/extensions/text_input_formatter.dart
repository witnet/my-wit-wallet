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
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    String value = newValue.text;
    if (value.contains('.')) {
      if (value.startsWith('.')) value = '0$value';
      String leftPart = value.split('.')[0];
      String rightPart = value.split('.')[1];
      rightPart = rightPart.length > 9 ? rightPart.substring(0, 9) : rightPart;
      value = leftPart + "." + rightPart;
    }
    return TextEditingValue(
        text: value,
        selection:
            TextSelection.fromPosition(TextPosition(offset: value.length)));
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
