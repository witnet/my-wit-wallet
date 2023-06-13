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
  bool isAddressIdxInStorage = params.externalAccounts.length > 0 &&
      (params.addressIndex <= params.externalAccounts.length);
  Map<String, dynamic> defaultAccountSettings = {
    ...params.addressList,
    '${params.walletId}': '0/0',
  };
  String? defaultAddress = params.externalAccounts[0] != null
      ? params.externalAccounts[0]!.address
      : null;
  return {
    AccountPreferences.address: isAddressIdxInStorage
        ? params.externalAccounts[params.addressIndex]!.address
        : defaultAddress,
    AccountPreferences.addressIndex:
        isAddressIdxInStorage ? params.addressIndex.toString() : "0",
    AccountPreferences.addressList:
        isAddressIdxInStorage ? params.addressList : defaultAccountSettings,
  };
}
