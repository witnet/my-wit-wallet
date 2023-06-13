import 'package:my_wit_wallet/util/storage/database/account.dart';

enum AccountPreferences { address, addressIndex, addressList }

class AccountPreferencesParams {
  String walletId;
  int addressIndex;
  Map<String, dynamic> addressList;
  Map<int, Account> externalAccounts;
  AccountPreferencesParams(this.walletId, this.addressIndex, this.addressList,
      this.externalAccounts);
}

Map<AccountPreferences, dynamic> getUpdatedAccountInfo(
    AccountPreferencesParams params) {
  bool isAddressIdxInStorage =
      params.addressIndex <= params.externalAccounts.length;

  return {
    AccountPreferences.address: isAddressIdxInStorage
        ? params.externalAccounts[params.addressIndex]!.address
        : params.externalAccounts[0]!.address,
    AccountPreferences.addressIndex:
        isAddressIdxInStorage ? params.addressIndex.toString() : "0",
    AccountPreferences.addressList: isAddressIdxInStorage
        ? params.addressList
        : {
            ...params.addressList,
            '${params.walletId}': '0/0',
          },
  };
}
