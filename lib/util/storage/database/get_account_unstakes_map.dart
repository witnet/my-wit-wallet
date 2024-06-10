import 'package:my_wit_wallet/util/storage/database/adapters/transaction_adapter.dart';
import 'package:witnet/schema.dart';

Map<String, List<UnstakeEntry>> getAccountUnstakesMap(
    List<UnstakeEntry> unstakesList) {
  Map<String, List<UnstakeEntry>> accountUnstakeMap = {};

  // Creates map to get unstakes by account address
  for (int i = 0; i < unstakesList.length; i++) {
    //* TODO: get withdrawal or operator address instead of output address
    List<ValueTransferOutput> outputs = unstakesList[i].outputs;
    outputs.forEach((output) {
      if (accountUnstakeMap[output.pkh.address] != null) {
        accountUnstakeMap[output.pkh.address]!.add(unstakesList[i]);
      } else {
        accountUnstakeMap[output.pkh.address] = [unstakesList[i]];
      }
    });
  }
  return accountUnstakeMap;
}
