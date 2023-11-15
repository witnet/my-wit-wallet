import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';

Map<String, List<ValueTransferInfo>> getAccountVttsMap(
    List<ValueTransferInfo> vttList) {
  Map<String, List<ValueTransferInfo>> accountVttMap = {};

  // Creates map to get vtts by account address
  for (int i = 0; i < vttList.length; i++) {
    List<InputUtxo> inputs = vttList[i].inputs;
    List<ValueTransferOutput> outputs = vttList[i].outputs;
    inputs.forEach((input) {
      if (accountVttMap[input.address] != null) {
        accountVttMap[input.address]!.add(vttList[i]);
      } else {
        accountVttMap[input.address] = [vttList[i]];
      }
    });
    outputs.forEach((output) {
      if (accountVttMap[output.pkh.address] != null) {
        accountVttMap[output.pkh.address]!.add(vttList[i]);
      } else {
        accountVttMap[output.pkh.address] = [vttList[i]];
      }
    });
  }
  return accountVttMap;
}
