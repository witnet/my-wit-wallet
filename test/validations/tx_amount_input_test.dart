import 'package:flutter/widgets.dart';
import 'package:my_wit_wallet/widgets/validations/tx_amount_input.dart';
import 'package:test/test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  test('Decimal number has more than 9 digits', () async {
    String amount = '0.00000000001';
    TxAmountInput _amount = TxAmountInput.dirty(
        value: amount, availableNanoWit: 1000, allowValidation: true);

    expect(_amount.validator(amount, avoidWeightedAmountCheck: true),
        errorMap[AmountInputError.decimals]);
  });
  test('Not enough Funds', () async {
    String amount = '0.000000001';
    TxAmountInput _amount = TxAmountInput.dirty(
        value: amount, availableNanoWit: 0, allowValidation: true);

    expect(_amount.validator(amount, avoidWeightedAmountCheck: true),
        errorMap[AmountInputError.notEnough]);
  });
  test('Amount cannot be zero', () async {
    String amount = '0';
    TxAmountInput _amount = TxAmountInput.dirty(
        value: amount, availableNanoWit: 0, allowValidation: true);

    expect(_amount.validator(amount, avoidWeightedAmountCheck: true),
        errorMap[AmountInputError.zero]);
  });
  test('Amount can be zero', () async {
    String amount = '0';
    TxAmountInput _amount = TxAmountInput.dirty(
        value: amount,
        availableNanoWit: 0,
        allowValidation: true,
        allowZero: true);

    expect(_amount.validator(amount, avoidWeightedAmountCheck: true), null);
  });
  test('Invalid amount', () async {
    String amount = '0.';
    TxAmountInput _amount = TxAmountInput.dirty(
        value: amount,
        availableNanoWit: 0,
        allowValidation: true,
        allowZero: true);

    expect(_amount.validator(amount, avoidWeightedAmountCheck: true),
        errorMap[AmountInputError.invalid]);
  });
  test('Stake Amount is less than min', () async {
    String amount = '0.2';
    TxAmountInput _amount = TxAmountInput.dirty(
        value: amount,
        availableNanoWit: 0,
        allowValidation: true,
        isStakeAmount: true);

    expect(_amount.validator(amount, avoidWeightedAmountCheck: true),
        errorMap[AmountInputError.lessThanMin]);
  });
  test('Stake Amount is greater than max', () async {
    String amount = '20000000';
    TxAmountInput _amount = TxAmountInput.dirty(
        value: amount,
        availableNanoWit: 200000000000000000,
        allowValidation: true,
        isStakeAmount: true);

    expect(_amount.validator(amount, avoidWeightedAmountCheck: true),
        errorMap[AmountInputError.greaterThanMax]);
  });
}
