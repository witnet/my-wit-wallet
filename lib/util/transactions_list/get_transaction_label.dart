import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:witnet/explorer.dart';

String getTransactionLabel(
    List<String?> externalAddresses,
    List<String?> internalAddresses,
    List<InputUtxo> inputs,
    Account? singleAddressAccount,
    BuildContext? context) {
  String label = '';
  String _from = context != null ? AppLocalizations.of(context)!.from : "from";
  String _to = context != null ? AppLocalizations.of(context)!.to : "to";
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
