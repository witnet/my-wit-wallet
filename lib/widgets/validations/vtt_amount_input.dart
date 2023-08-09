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
  final int availableNanoWit;
  final bool allowZero;
  final bool allowValidation;
  final int? weightedAmount;

  // Call super.pure to represent an unmodified form input.
  VttAmountInput.pure()
      : availableNanoWit = 0,
        allowZero = false,
        weightedAmount = null,
        allowValidation = false,
        super.pure('');

  // Call super.dirty to represent a modified form input.
  VttAmountInput.dirty(
      {required this.availableNanoWit,
      value = '',
      this.weightedAmount,
      this.allowZero = false,
      this.allowValidation = false})
      : super.dirty(value);

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

  int _witAmountToNanoWitNumber(String amount) {
    try {
      return num.parse(amount != '' ? amount : '0')
          .standardizeWitUnits(
              inputUnit: WitUnit.Wit, outputUnit: WitUnit.nanoWit)
          .toBigInt()
          .toInt();
    } catch (e) {
      print('Error parsing number $e');
      return 0;
    }
  }

  bool _notEnoughFunds({bool avoidWeightedAmountCheck = false}) {
    int balance = this.availableNanoWit;
    int nanoWitAmount;
    if (!avoidWeightedAmountCheck) {
      nanoWitAmount = this.weightedAmount ?? _witAmountToNanoWitNumber(value);
    } else {
      nanoWitAmount = _witAmountToNanoWitNumber(value);
    }
    return balance < nanoWitAmount;
  }

  // Override validator to handle validating a given input value.
  @override
  String? validator(String value, {bool avoidWeightedAmountCheck = false}) {
    if (this.allowValidation) {
      String? errorText;
      if (value.isEmpty) {
        errorText = getErrorText(AmountInputError.empty);
      }
      if (_notEnoughFunds(avoidWeightedAmountCheck: avoidWeightedAmountCheck)) {
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
