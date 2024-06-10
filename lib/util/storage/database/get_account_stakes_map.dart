import 'package:my_wit_wallet/util/storage/database/adapters/transaction_adapter.dart';
import 'package:witnet/schema.dart';

Map<String, List<StakeEntry>> getAccountStakesMap(List<StakeEntry> stakesList) {
  Map<String, List<StakeEntry>> accountStakeMap = {};

  // Creates map to get stakes by account address
  for (int i = 0; i < stakesList.length; i++) {
    //* TODO: get withdrawal or operator address instead of output address
    List<ValueTransferOutput> outputs = stakesList[i].outputs;
    outputs.forEach((output) {
      if (accountStakeMap[output.pkh.address] != null) {
        accountStakeMap[output.pkh.address]!.add(stakesList[i]);
      } else {
        accountStakeMap[output.pkh.address] = [stakesList[i]];
      }
    });
  }
  return accountStakeMap;
}
