import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/util/account_preferences.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:test/test.dart';

void main() {
  Map<AccountPreferences, dynamic> accountPreferences =
      getUpdatedAccountInfo(AccountPreferencesParams('8a7cf20f', {
    WalletPreferences.addressIndex: '0/0',
    WalletPreferences.addressList: {
      '8a7cf20f': '0/0',
    }
  }, {
    0: Account(
        walletName: '8a7cf20f',
        address: 'wit000000000000000000000000000000000000000',
        path: 'M/3h/4919h/0h/0/1')
  }));
  // With not existent index saved
  Map<AccountPreferences, dynamic> accountPreferences2 =
      getUpdatedAccountInfo(AccountPreferencesParams('8a7cf20f', {
    WalletPreferences.addressIndex: '0/2',
    WalletPreferences.addressList: {
      '8a7cf20f': '0/2',
    }
  }, {
    0: Account(
        walletName: '8a7cf20f',
        address: 'wit000000000000000000000000000000000000000',
        path: 'M/3h/4919h/0h/0/1')
  }));
  // With db deleted
  Map<AccountPreferences, dynamic> accountPreferences3 =
      getUpdatedAccountInfo(AccountPreferencesParams('8a7cf20f', {
    WalletPreferences.addressIndex: '0/2',
    WalletPreferences.addressList: {
      '8a7cf20f': '0/2',
    }
  }, {}));
  // With deleted prefs
  Map<AccountPreferences, dynamic> accountPreferences4 =
      getUpdatedAccountInfo(AccountPreferencesParams('8a7cf20f', null, {
    0: Account(
        walletName: '8a7cf20f',
        address: 'wit000000000000000000000000000000000000000',
        path: 'M/3h/4919h/0h/0/1')
  }));
  group(
      'getAccountPreferences',
      () => {
            test(
                'with correctly saved preferences',
                () => {
                      expect(accountPreferences, {
                        AccountPreferences.address:
                            'wit000000000000000000000000000000000000000',
                        AccountPreferences.addressIndex: '0',
                        AccountPreferences.addressList: {'8a7cf20f': '0/0'}
                      }),
                    }),
            test(
                'with not found address index in saved preferences',
                () => {
                      expect(accountPreferences2, {
                        AccountPreferences.address:
                            'wit000000000000000000000000000000000000000',
                        AccountPreferences.addressIndex: '0',
                        AccountPreferences.addressList: {'8a7cf20f': '0/0'}
                      }),
                    }),
            test(
                'with deleted db and saved preferences',
                () => {
                      expect(accountPreferences3, {
                        AccountPreferences.address: null,
                        AccountPreferences.addressIndex: '0',
                        AccountPreferences.addressList: {'8a7cf20f': '0/0'},
                      }),
                    }),
            test(
                'with deleted preferences and saved db',
                () => {
                      expect(accountPreferences4, {
                        AccountPreferences.address:
                            'wit000000000000000000000000000000000000000',
                        AccountPreferences.addressIndex: '0',
                        AccountPreferences.addressList: {'8a7cf20f': '0/0'},
                      }),
                    }),
          });
}
