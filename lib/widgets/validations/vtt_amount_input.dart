import 'package:formz/formz.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';

// Define input validation errors
enum AmountInputError {
  empty,
  notEnough,
  invalid,
  zero,
  decimals,
  invalidNumber
}

Map<AmountInputError, String> errorMap = {
  AmountInputError.empty: 'Please input an amount',
  AmountInputError.notEnough: 'Not enough Funds',
  AmountInputError.zero: 'Amount cannot be zero',
  AmountInputError.invalid: 'Invalid amount',
  AmountInputError.decimals: 'Only 9 decimal digits supported',
};

// Extend FormzInput and provide the input type and error type.
class VttAmountInput extends FormzInput<String, String?> {
  final int availableNanoWit;
  final bool allowZero;
  final bool allowValidation;
  final int? weightedAmount;
  final int vttAmount;

  // Call super.pure to represent an unmodified form input.
  VttAmountInput.pure()
      : availableNanoWit = 0,
        allowZero = false,
        weightedAmount = null,
        vttAmount = 0,
        allowValidation = false,
        super.pure('');

  // Call super.dirty to represent a modified form input.
  VttAmountInput.dirty(
      {required this.availableNanoWit,
      value = '',
      this.weightedAmount,
      this.vttAmount = 0,
      this.allowZero = false,
      this.allowValidation = false})
      : super.dirty(value);

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
    return balance < (nanoWitAmount + this.vttAmount);
  }

  // Override validator to handle validating a given input value.
  @override
  String? validator(String value, {bool avoidWeightedAmountCheck = false}) {
    final validationUtils = ValidationUtils(errorMap: errorMap);
    if (!this.allowValidation) {
      return null;
    }
    // Check if the amount input is empty
    if (value.isEmpty)
      return validationUtils.getErrorText(AmountInputError.empty);
    // Check if the amount is a number
    if (RegExp(r'[a-zA-Z]').hasMatch(value))
      return validationUtils.getErrorText(AmountInputError.invalid);
    // Check if the amount has decimals
    if (value.contains('.')) {
      // Check if the decimal amount is valid
      if (value.split('.').length != 2 || value.split('.')[1].isEmpty)
        return validationUtils.getErrorText(AmountInputError.invalid);
      // Check if the amount has more than nine decimals
      if (!RegExp(r'^\d+\.?\d{1,9}$').hasMatch(value))
        return validationUtils.getErrorText(AmountInputError.decimals);
    }
    if (_notEnoughFunds(avoidWeightedAmountCheck: avoidWeightedAmountCheck))
      return validationUtils.getErrorText(AmountInputError.notEnough);
    // Check if the amount is zero
    if (value.isNotEmpty && !this.allowZero) {
      try {
        if (num.parse(value) == 0)
          return validationUtils.getErrorText(AmountInputError.zero);
      } catch (e) {
        return validationUtils.getErrorText(AmountInputError.invalid);
      }
    }
    return null;
  }
}
