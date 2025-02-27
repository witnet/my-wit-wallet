import 'package:my_wit_wallet/util/storage/database/adapters/transaction_adapter.dart';

Map<String, List<UnstakeEntry>> getAccountUnstakesMap(
    List<UnstakeEntry> unstakesList) {
  Map<String, List<UnstakeEntry>> accountUnstakeMap = {};

  // Creates map to get unstakes by account address
  for (int i = 0; i < unstakesList.length; i++) {
    if (accountUnstakeMap.containsKey(unstakesList[i].withdrawer)) {
      accountUnstakeMap[unstakesList[i].withdrawer]!.add(unstakesList[i]);
    } else {
      accountUnstakeMap[unstakesList[i].withdrawer] = [unstakesList[i]];
    }
    if (accountUnstakeMap.containsKey(unstakesList[i].validator)) {
      accountUnstakeMap[unstakesList[i].validator]!.add(unstakesList[i]);
    } else {
      accountUnstakeMap[unstakesList[i].validator] = [unstakesList[i]];
    }
  }
  return accountUnstakeMap;
}
