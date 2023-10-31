import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/widgets/validations/vtt_amount_input.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:my_wit_wallet/util/get_localization.dart';

enum FeeInputError { minFee }

Map<FeeInputError, String> errorMap = {
  FeeInputError.minFee: localization.validationMinFee,
};

class FeeAmountInput extends VttAmountInput {
  final int availableNanoWit;
  final int? weightedAmount;
  final bool allowZero;
  final bool allowValidation;
  final int vttAmount;
  final int? minFee;

  // Call super.pure to represent an unmodified form input.
  FeeAmountInput.pure()
      : availableNanoWit = 0,
        allowZero = false,
        weightedAmount = null,
        vttAmount = 0,
        minFee = null,
        allowValidation = false,
        super.pure();

  // Call super.dirty to represent a modified form input.
  FeeAmountInput.dirty(
      {required this.availableNanoWit,
      value = '',
      this.weightedAmount,
      this.vttAmount = 0,
      this.minFee,
      this.allowZero = false,
      this.allowValidation = false})
      : super.dirty(
            value: value,
            allowZero: allowZero,
            allowValidation: allowValidation,
            availableNanoWit: availableNanoWit,
            weightedAmount: weightedAmount);

  // Override notEnoughFunds to handle validating taking into account the vttAmount
  @override
  bool notEnoughFunds({bool avoidWeightedAmountCheck = false}) {
    int nanoWitAmount = super
        .getNanoWitAmount(avoidWeightedAmountCheck: avoidWeightedAmountCheck);
    return this.availableNanoWit < (nanoWitAmount + this.vttAmount);
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
    if (this.minFee != null &&
        super.witAmountToNanoWitNumber(value) <= this.minFee!) {
      return '${validationUtils.getErrorText(FeeInputError.minFee)} ${this.minFee!.standardizeWitUnits(outputUnit: WitUnit.Wit)} WIT';
    }
    return null;
  }
}
