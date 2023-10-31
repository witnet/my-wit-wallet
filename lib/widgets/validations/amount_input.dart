import 'package:formz/formz.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
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
  AmountInputError.empty: localization.validationEmpty,
  AmountInputError.notEnough: localization.validationEnoughFunds,
  AmountInputError.zero: localization.validationNoZero,
  AmountInputError.invalid: localization.validationInvalidAmount,
  AmountInputError.decimals: localization.validationDecimals,
};

// Extend FormzInput and provide the input type and error type.
class AmountInput extends FormzInput<String, String?> {
  final bool allowZero;
  final bool allowValidation;

  // Call super.pure to represent an unmodified form input.
  AmountInput.pure()
      : allowZero = false,
        allowValidation = false,
        super.pure('');

  // Call super.dirty to represent a modified form input.
  AmountInput.dirty(
      {value = '', this.allowZero = false, this.allowValidation = false})
      : super.dirty(value);

  // Override validator to handle validating a given input value.
  @override
  String? validator(String value, {bool avoidWeightedAmountCheck = false}) {
    final validationUtils = ValidationUtils(errorMap: errorMap);
    if (!this.allowValidation) {
      return null;
    }
    // Check if the amount input is empty
    if (value.isEmpty) {
      return validationUtils.getErrorText(AmountInputError.empty);
    }
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
