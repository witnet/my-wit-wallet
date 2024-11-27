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
  lessThanMin,
  greaterThanMax
}

Map<AmountInputError, String> errorMap = {
  AmountInputError.empty: 'Please input an amount',
  AmountInputError.notEnough: 'Not enough Funds',
  AmountInputError.zero: 'Amount cannot be zero',
  AmountInputError.invalid: 'Invalid amount',
  AmountInputError.decimals: 'Only 9 decimal digits supported',
  AmountInputError.lessThanMin: 'The amount is less than the minimum required',
  AmountInputError.greaterThanMax:
      'The amount is greater than the maximum allowed'
};

// Extend FormzInput and provide the input type and error type.
class TxAmountInput extends AmountInput {
  final int availableNanoWit;
  final bool allowZero;
  final bool allowValidation;
  final bool isStakeAmount;

  // Call super.pure to represent an unmodified form input.
  TxAmountInput.pure()
      : availableNanoWit = 0,
        allowZero = false,
        isStakeAmount = false,
        allowValidation = false,
        super.pure();

  // Call super.dirty to represent a modified form input.
  TxAmountInput.dirty(
      {required this.availableNanoWit,
      value = '',
      this.allowZero = false,
      this.isStakeAmount = false,
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

  int getNanoWitAmount() {
    return witAmountToNanoWitNumber(value);
  }

  bool notEnoughFunds({bool avoidWeightedAmountCheck = false}) {
    int nanoWitAmount = getNanoWitAmount();
    return this.availableNanoWit < nanoWitAmount;
  }

  bool get lessThanMinimum =>
      getNanoWitAmount() < MIN_STAKING_AMOUNT_NANOWIT.toInt();
  bool get greaterThanMaximum =>
      getNanoWitAmount() > MAX_STAKING_AMOUNT_NANOWIT.toInt();

  // Override validator to handle validating a given input value.
  @override
  String? validator(String value, {bool avoidWeightedAmountCheck = false}) {
    final validationUtils = ValidationUtils(errorMap: errorMap);
    String? error = super
        .validator(value, avoidWeightedAmountCheck: avoidWeightedAmountCheck);
    if (error != null) {
      return error;
    }

    if (isStakeAmount && greaterThanMaximum) {
      return validationUtils.getErrorText(AmountInputError.greaterThanMax);
    }
    if (isStakeAmount && lessThanMinimum) {
      return validationUtils.getErrorText(AmountInputError.lessThanMin);
    }
    if (notEnoughFunds(avoidWeightedAmountCheck: avoidWeightedAmountCheck))
      return validationUtils.getErrorText(AmountInputError.notEnough);
    return null;
  }
}
