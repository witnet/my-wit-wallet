import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:my_wit_wallet/widgets/validations/amount_input.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';

// Define input validation errors
enum AmountInputError {
  empty,
  notEnough,
  invalid,
  zero,
  decimals,
  invalidNumber,
}

Map<AmountInputError, String> errorMap = {
  AmountInputError.empty: 'Please input an amount',
  AmountInputError.notEnough: 'Not enough Funds',
  AmountInputError.zero: 'Amount cannot be zero',
  AmountInputError.invalid: 'Invalid amount',
  AmountInputError.decimals: 'Only 9 decimal digits supported',
};

// Extend FormzInput and provide the input type and error type.
class VttAmountInput extends AmountInput {
  final int availableNanoWit;
  final int? weightedAmount;
  final bool allowZero;
  final bool allowValidation;

  // Call super.pure to represent an unmodified form input.
  VttAmountInput.pure()
      : availableNanoWit = 0,
        allowZero = false,
        weightedAmount = null,
        allowValidation = false,
        super.pure();

  // Call super.dirty to represent a modified form input.
  VttAmountInput.dirty(
      {required this.availableNanoWit,
      value = '',
      this.weightedAmount,
      this.allowZero = false,
      this.allowValidation = false})
      : super.dirty(
            value: value,
            allowZero: allowZero,
            allowValidation: allowValidation);

  int witAmountToNanoWitNumber(String amount) {
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

  int getNanoWitAmount({bool avoidWeightedAmountCheck = false}) {
    int nanoWitAmount;
    if (!avoidWeightedAmountCheck) {
      nanoWitAmount = this.weightedAmount ?? witAmountToNanoWitNumber(value);
    } else {
      nanoWitAmount = witAmountToNanoWitNumber(value);
    }
    return nanoWitAmount;
  }

  bool notEnoughFunds({bool avoidWeightedAmountCheck = false}) {
    int nanoWitAmount =
        getNanoWitAmount(avoidWeightedAmountCheck: avoidWeightedAmountCheck);
    return this.availableNanoWit < nanoWitAmount;
  }

  // Override validator to handle validating a given input value.
  @override
  String? validator(String value, {bool avoidWeightedAmountCheck = false}) {
    final validationUtils = ValidationUtils(errorMap: errorMap);
    String? error = super
        .validator(value, avoidWeightedAmountCheck: avoidWeightedAmountCheck);
    if (error != null) {
      return error;
    }
    if (notEnoughFunds(avoidWeightedAmountCheck: avoidWeightedAmountCheck))
      return validationUtils.getErrorText(AmountInputError.notEnough);
    return null;
  }
}
