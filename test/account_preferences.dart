import 'package:my_wit_wallet/util/account_preferences.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:test/test.dart';

void main() {
  AccountPreferencesParams prefs = AccountPreferencesParams('8a7cf20f', 0, {
    '8a7cf20f': '0/0'
  }, {
    0: Account(
        walletName: '8a7cf20f',
        address: 'wit000000000000000000000000000000000000000',
        path: 'M/3h/4919h/0h/0/1')
  });
  AccountPreferencesParams prefs2 = AccountPreferencesParams('8a7cf20f', 2, {
    '8a7cf20f': '0/0'
  }, {
    0: Account(
        walletName: '8a7cf20f',
        address: 'wit000000000000000000000000000000000000000',
        path: 'M/3h/4919h/0h/0/1')
  });
  AccountPreferencesParams prefs3 =
      AccountPreferencesParams('8a7cf20f', 0, {'8a7cf20f': '0/0'}, {});
  Map<AccountPreferences, dynamic> accountPreferences =
      getUpdatedAccountInfo(prefs);
  Map<AccountPreferences, dynamic> accountPreferences2 =
      getUpdatedAccountInfo(prefs2);
  Map<AccountPreferences, dynamic> accountPreferences3 =
      getUpdatedAccountInfo(prefs3);
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
                'with wrong saved preferences',
                () => {
                      expect(accountPreferences2, {
                        AccountPreferences.address:
                            'wit000000000000000000000000000000000000000',
                        AccountPreferences.addressIndex: '0',
                        AccountPreferences.addressList: {'8a7cf20f': '0/0'}
                      }),
                    }),
            test(
                'with wrong saved preferences',
                () => {
                      expect(accountPreferences3, {
                        AccountPreferences.address: null,
                        AccountPreferences.addressIndex: '0',
                        AccountPreferences.addressList: {'8a7cf20f': '0/0'},
                      }),
                    }),
          });
}
