import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';

double getUnstakeMinAmount(int stakedNanoWit) {
  if (stakedNanoWit > MIN_STAKING_AMOUNT_NANOWIT) {
    return 0.000000001;
  } else {
    return MIN_STAKING_AMOUNT_NANOWIT
        .standardizeWitUnits(truncate: -1)
        .toDouble();
  }
}
