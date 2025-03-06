import 'package:my_wit_wallet/util/storage/database/adapters/transaction_adapter.dart';

Map<String, List<StakeEntry>> getAccountStakesMap(List<StakeEntry> stakesList) {
  Map<String, List<StakeEntry>> accountStakeMap = {};

  // Creates map to get stakes by account address
  for (int i = 0; i < stakesList.length; i++) {
    if (accountStakeMap.containsKey(stakesList[i].withdrawer)) {
      accountStakeMap[stakesList[i].withdrawer]!.add(stakesList[i]);
    } else {
      accountStakeMap[stakesList[i].withdrawer] = [stakesList[i]];
    }
  }
  return accountStakeMap;
}
