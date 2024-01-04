import 'package:witnet/explorer.dart';

Map<String, List<ValueTransferInfo>> getAccountVttsMap(
    List<ValueTransferInfo> vttList) {
  Map<String, List<ValueTransferInfo>> accountVttMap = {};
  // Creates map to get vtts by account address
  for (int i = 0; i < vttList.length; i++) {
    List<String> inputs = vttList[i].inputUtxos.map((e) => e.address).toList();
    List<String> outputs =
        vttList[i].outputs.map((e) => e.pkh.address).toList();
    inputs.forEach((inputAddress) {
      if (accountVttMap[inputAddress] != null) {
        accountVttMap[inputAddress]!.add(vttList[i]);
      } else {
        accountVttMap[inputAddress] = [vttList[i]];
      }
    });
    outputs.forEach((outputAddress) {
      if (accountVttMap[outputAddress] != null) {
        accountVttMap[outputAddress]!.add(vttList[i]);
      } else {
        accountVttMap[outputAddress] = [vttList[i]];
      }
    });
  }
  return accountVttMap;
}
