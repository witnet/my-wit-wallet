import 'package:decimal/decimal.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';

Decimal getUnstakeMinAmount(int stakedNanoWit) {
  if (stakedNanoWit == 0) {
    return Decimal.parse('0');
  }
  if (stakedNanoWit > MIN_STAKING_AMOUNT_NANOWIT) {
    if ((stakedNanoWit - MAX_STAKING_AMOUNT_NANOWIT) <
        MIN_STAKING_AMOUNT_NANOWIT) {
      return stakedNanoWit.standardizeWitUnits(truncate: -1);
    }
    return Decimal.parse('0.000000001');
  } else {
    return MIN_STAKING_AMOUNT_NANOWIT.standardizeWitUnits(truncate: -1);
  }
}
