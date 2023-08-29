import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';

enum AccountPreferences { address, addressIndex, addressList, isHdWallet }

class AccountPreferencesParams {
  String? currentWalletId;
  Map<WalletPreferences, dynamic>? preferences;
  Map<int, Account> accountList;
  bool isHdWallet;
  AccountPreferencesParams(
      {this.currentWalletId,
      this.preferences,
      required this.accountList,
      required this.isHdWallet});
}

Map<AccountPreferences, dynamic> getUpdatedAccountInfo(
    AccountPreferencesParams params) {
  bool isHdWallet = params.isHdWallet;
  String addressId = isHdWallet ? "0/0" : "m";
  Map<String, dynamic> addressList = {
    '${params.currentWalletId}': isHdWallet ? "0/0" : "m"
  };
  if (params.preferences != null) {
    addressList = params.preferences![WalletPreferences.addressList];
    addressId = params.currentWalletId != null
        ? addressList[params.currentWalletId]
        : params.preferences![WalletPreferences.addressIndex];
  }
  int addressIndex =
      addressId.contains("/") ? int.parse(addressId.split('/').last) : 0;

  bool isAddressIdxInStorage = params.accountList.length > 0 &&
      (addressIndex < params.accountList.length);
  Map<String, dynamic> defaultAccountSettings = {
    ...addressList,
    '${params.currentWalletId}': isHdWallet ? "0/0" : "m",
  };
  String? defaultAddress =
      params.accountList[0] != null ? params.accountList[0]!.address : null;
  return {
    AccountPreferences.address: isAddressIdxInStorage
        ? params.accountList[addressIndex]!.address
        : defaultAddress,
    AccountPreferences.addressIndex:
        isAddressIdxInStorage ? addressIndex.toString() : "0",
    AccountPreferences.addressList:
        isAddressIdxInStorage ? addressList : defaultAccountSettings,
  };
}
