import 'package:my_wit_wallet/widgets/validations/vtt_amount_input.dart';

class FeeAmountInput extends VttAmountInput {
  final int availableNanoWit;
  final int? weightedAmount;
  final bool allowZero;
  final bool allowValidation;
  final int vttAmount;

  // Call super.pure to represent an unmodified form input.
  FeeAmountInput.pure()
      : availableNanoWit = 0,
        allowZero = false,
        weightedAmount = null,
        vttAmount = 0,
        allowValidation = false,
        super.pure();

  // Call super.dirty to represent a modified form input.
  FeeAmountInput.dirty(
      {required this.availableNanoWit,
      value = '',
      this.weightedAmount,
      this.vttAmount = 0,
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
    String? error = super
        .validator(value, avoidWeightedAmountCheck: avoidWeightedAmountCheck);
    if (error != null) {
      return error;
    }
    return null;
  }
}
