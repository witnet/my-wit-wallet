import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';
import 'package:my_wit_wallet/util/extensions/string_extensions.dart';

String getTransactionAddress(
    String label, List<InputUtxo> inputs, List<ValueTransferOutput> outputs) {
  String address = '';
  if (inputs.length < 1)
    return 'genesis';
  else if (label == localization.from && inputs.length > 0) {
    // Set sender address
    address = inputs[0].address.cropMiddle(18);
  } else if (outputs.length > 0) {
    // Set recipient address
    address = outputs[0].pkh.address.cropMiddle(18);
  }
  return address;
}
