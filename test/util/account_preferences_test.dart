import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/util/account_preferences.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:test/test.dart';

void main() {
  Map<AccountPreferences, dynamic> accountPreferences = getUpdatedAccountInfo(
    AccountPreferencesParams(
        currentWalletId: '8a7cf20f',
        preferences: {
          WalletPreferences.addressIndex: '0/0',
          WalletPreferences.addressList: {
            '8a7cf20f': '0/0',
          }
        },
        accountList: {
          0: Account(
              walletName: '8a7cf20f',
              address: 'wit000000000000000000000000000000000000000',
              path: 'M/3h/4919h/0h/0/1')
        },
        isHdWallet: true),
  );
  // With not existent index saved
  Map<AccountPreferences, dynamic> accountPreferences2 =
      getUpdatedAccountInfo(AccountPreferencesParams(
          currentWalletId: '8a7cf20f',
          preferences: {
            WalletPreferences.addressIndex: '0/2',
            WalletPreferences.addressList: {
              '8a7cf20f': '0/2',
            }
          },
          accountList: {
            0: Account(
                walletName: '8a7cf20f',
                address: 'wit000000000000000000000000000000000000000',
                path: 'M/3h/4919h/0h/0/1')
          },
          isHdWallet: true));
  // With db deleted
  Map<AccountPreferences, dynamic> accountPreferences3 =
      getUpdatedAccountInfo(AccountPreferencesParams(
          currentWalletId: '8a7cf20f',
          preferences: {
            WalletPreferences.addressIndex: '0/2',
            WalletPreferences.addressList: {
              '8a7cf20f': '0/2',
            }
          },
          accountList: {},
          isHdWallet: true));
  // With deleted prefs
  Map<AccountPreferences, dynamic> accountPreferences4 =
      getUpdatedAccountInfo(AccountPreferencesParams(
          currentWalletId: '8a7cf20f',
          preferences: null,
          accountList: {
            0: Account(
                walletName: '8a7cf20f',
                address: 'wit000000000000000000000000000000000000000',
                path: 'M/3h/4919h/0h/0/1')
          },
          isHdWallet: true));
  Map<AccountPreferences, dynamic> accountPreferences5 =
      getUpdatedAccountInfo(AccountPreferencesParams(
          currentWalletId: '8a7cf20f',
          preferences: null,
          accountList: {
            0: Account(
                walletName: '8a7cf20f',
                address: 'wit000000000000000000000000000000000000000',
                path: 'M/3h/4919h/0h/0/1')
          },
          isHdWallet: false));
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
                        AccountPreferences.addressList: {
                          '8a7cf20f': '0/0',
                        },
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
            test(
                'with deleted preferences and saved db with node address',
                () => {
                      expect(accountPreferences5, {
                        AccountPreferences.address:
                            'wit000000000000000000000000000000000000000',
                        AccountPreferences.addressIndex: '0',
                        AccountPreferences.addressList: {'8a7cf20f': 'm'},
                      }),
                    }),
          });
}
