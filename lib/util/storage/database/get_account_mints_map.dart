import 'package:my_wit_wallet/util/storage/database/transaction_adapter.dart';
import 'package:witnet/schema.dart';

Map<String, List<MintEntry>> getAccountMintsMap(List<MintEntry> vttList) {
  Map<String, List<MintEntry>> accountMintMap = {};

  // Creates map to get vtts by account address
  for (int i = 0; i < vttList.length; i++) {
    List<ValueTransferOutput> outputs = vttList[i].outputs;
    outputs.forEach((output) {
      if (accountMintMap[output.pkh.address] != null) {
        accountMintMap[output.pkh.address]!.add(vttList[i]);
      } else {
        accountMintMap[output.pkh.address] = [vttList[i]];
      }
    });
  }
  return accountMintMap;
}
