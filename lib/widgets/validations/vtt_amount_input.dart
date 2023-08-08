import 'package:formz/formz.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';

// Define input validation errors
enum AmountInputError { empty, notEnough, invalid, zero }

Map<AmountInputError, String?> errorText = {
  AmountInputError.empty: 'Please input an amount',
  AmountInputError.notEnough: 'Not enough Funds',
  AmountInputError.zero: 'Amount cannot be zero',
  AmountInputError.invalid: 'Invalid amount',
};

String? getErrorText(AmountInputError error) {
  return errorText[error];
}

// Extend FormzInput and provide the input type and error type.
class VttAmountInput extends FormzInput<String, String?> {
  // Call super.pure to represent an unmodified form input.
  VttAmountInput.pure()
      : availableNanoWit = 0,
        allowZero = false,
        allowValidation = false,
        super.pure('');

  // Call super.dirty to represent a modified form input.
  VttAmountInput.dirty(
      {required this.availableNanoWit,
      value = '',
      this.allowZero = false,
      this.allowValidation = false})
      : super.dirty(value);
  final int availableNanoWit;
  final bool allowZero;
  final bool allowValidation;

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

  num _amountToNumber(String amount) {
    try {
      return num.parse(amount != '' ? amount : '0');
    } catch (e) {
      print('Error parsing number $e');
      return 0;
    }
  }

  bool _notEnoughFunds(int availableNanoWit, String amount) {
    int balance = availableNanoWit;
    int nanoWitAmount = _amountToNumber(amount)
        .standardizeWitUnits(
            inputUnit: WitUnit.Wit, outputUnit: WitUnit.nanoWit)
        .toBigInt()
        .toInt();
    return balance < nanoWitAmount;
  }

  // Override validator to handle validating a given input value.
  @override
  String? validator(String value) {
    if (this.allowValidation) {
      String? errorText;
      if (value.isEmpty) {
        errorText = getErrorText(AmountInputError.empty);
      }
      if (_notEnoughFunds(this.availableNanoWit, value)) {
        errorText = getErrorText(AmountInputError.notEnough);
      }
      errorText = errorText ?? validateWitValue(value);
      if (value.isNotEmpty && !this.allowZero) {
        try {
          if (num.parse(value) == 0) {
            errorText = errorText ?? getErrorText(AmountInputError.zero);
          }
        } catch (e) {
          return errorText = getErrorText(AmountInputError.invalid);
        }
      }
      return errorText;
    }
    return null;
  }
}
