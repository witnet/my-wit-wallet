import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:witnet/explorer.dart';

String getTransactionLabel(
    List<String?> externalAddresses,
    List<String?> internalAddresses,
    List<InputUtxo> inputs,
    Account? singleAddressAccount,
    BuildContext? context) {
  String label = '';
  String _from = context != null ? localization.from : "from";
  String _to = context != null ? localization.to : "to";
  if (inputs.length < 1) {
    return _from;
  }
  inputs.forEach((element) {
    if (singleAddressAccount != null &&
        singleAddressAccount.address != element.address) {
      // if single account and the address does not appear in the input list
      label = _from;
    } else if (!externalAddresses.contains(element.address) &&
        !internalAddresses.contains(element.address) &&
        singleAddressAccount == null) {
      // if is hd wallet and any of the addresses appear in the input list
      label = _from;
    }
  });
  return label = label == _from ? label : _to;
}
