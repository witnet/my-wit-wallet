import 'dart:developer';

import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:witnet/explorer.dart';

String getTransactionLabel(
    List<String?> externalAddresses,
    List<String?> internalAddresses,
    List<InputUtxo> inputs,
    Account? singleAddressAccount) {
  String label = '';
  inputs.forEach((element) {
    if (singleAddressAccount != null &&
        singleAddressAccount.address != element.address) {
      // if single account and the address does not appear in the input list
      label = 'from';
    } else if (!externalAddresses.contains(element.address) &&
        !internalAddresses.contains(element.address) &&
        singleAddressAccount == null) {
      // if is hd wallet and any of the addresses appear in the input list
      label = 'from';
    }
  });
  return label = label == 'from' ? label : 'to';
}
