import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/get_localization.dart';

String getTransactionLabel({
  required List<String?> externalAddresses,
  required List<String?> internalAddresses,
  required Account? singleAddressAccount,
  required List<String?> inputsAddresses,
}) {
  String label = '';
  String _from = localization.from;
  String _to = localization.to;
  if (inputsAddresses.length < 1) {
    return _from;
  }
  inputsAddresses.forEach((element) {
    if (singleAddressAccount != null &&
        singleAddressAccount.address != element) {
      // if single account and the address does not appear in the input list
      label = _from;
    } else if (!externalAddresses.contains(element) &&
        !internalAddresses.contains(element) &&
        singleAddressAccount == null) {
      // if is hd wallet and any of the addresses appear in the input list
      label = _from;
    }
  });
  return label = label == _from ? label : _to;
}
