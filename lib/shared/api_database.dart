import 'package:my_wit_wallet/bloc/explorer/api_explorer.dart';
import 'package:my_wit_wallet/util/account_preferences.dart';
import 'package:my_wit_wallet/util/preferences.dart';
import 'package:my_wit_wallet/util/storage/database/stats.dart';
import 'package:my_wit_wallet/util/storage/log.dart';
import 'package:witnet/explorer.dart';
import 'package:my_wit_wallet/util/storage/database/database_service.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/util/storage/path_provider_interface.dart';

import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/storage/database/wallet_storage.dart';
import 'package:my_wit_wallet/util/storage/database/adapters/transaction_adapter.dart';
import 'locator.dart';

enum WalletPreferences { walletId, addressIndex, addressList }

/// [ApiDatabase] is used to communicate between the database isolate and the
/// rest of the application.
class ApiDatabase {
  late String path;
  bool initialized = false;
  bool unlocked = false;

  late WalletStorage walletStorage;
  bool walletsLoaded = false;

  DatabaseService get db => Locator.instance<DatabaseService>();
  DebugLogger get logger => Locator.instance<DebugLogger>();
  ApiExplorer get explorer => Locator.instance<ApiExplorer>();
  PathProviderInterface interface = PathProviderInterface();

  Future<bool> masterKeySet() async {
    return await db.masterKeySet();
  }

  Future<void> updateCurrentWallet(
      {String? currentWalletId,
      bool isHdWallet = false,
      bool isNewWallet = false,
      bool isUpdatedWallet = false}) async {
    ApiDatabase db = Locator.instance<ApiDatabase>();
    WalletStorage walletStorage = db.walletStorage;
    Map<WalletPreferences, dynamic>? preferences =
        await getCurrentWalletPreferences();
    bool currentWalletNotSaved = (isUpdatedWallet || isNewWallet) &&
        currentWalletId != null &&
        preferences != null &&
        preferences[WalletPreferences.addressList][currentWalletId] == null;

    // If localStorage is deleted, it resets preferences of the wallet to default values
    if (currentWalletNotSaved) {
      await setPreferences(
          currentWalletId,
          AddressEntry(
              walletId: currentWalletId,
              addressIdx: isHdWallet ? 0 : null,
              keyType: isHdWallet ? '0' : 'm'));
      preferences = await getCurrentWalletPreferences();
    }
    final walletIdToSet =
        preferences != null && !isUpdatedWallet && !isNewWallet
            ? preferences[WalletPreferences.walletId]
            : currentWalletId;

    // set new wallet in storage
    walletStorage.setCurrentWallet(walletIdToSet);

    // get account preferences taking into account corrupted localStorage
    Map<AccountPreferences, dynamic> accountPreferences;
    accountPreferences = getUpdatedAccountInfo(
      AccountPreferencesParams(
        currentWalletId: walletIdToSet,
        preferences: preferences,
        accountList: walletStorage.currentWallet.masterAccount != null
            ? {0: walletStorage.currentWallet.masterAccount!}
            : walletStorage.currentWallet.externalAccounts,
        isHdWallet: walletStorage.currentWallet.masterAccount == null,
      ),
    );

    // set new current wallet and account in local storage
    if (isNewWallet || isUpdatedWallet && currentWalletId != null) {
      await setPreferences(
          walletIdToSet,
          AddressEntry(
              walletId: walletIdToSet,
              addressIdx: isHdWallet
                  ? int.tryParse(
                      accountPreferences[AccountPreferences.addressIndex])
                  : null,
              keyType: isHdWallet ? '0' : 'm'));
    }
    // set account in storage
    setCurrentAddress(
        walletIdToSet,
        accountPreferences[AccountPreferences.address],
        accountPreferences[AccountPreferences.addressList]);
  }

  Future<Map<WalletPreferences, dynamic>?> getCurrentWalletPreferences() async {
    return await ApiPreferences.getCurrentWalletPreferences();
  }

  Future<void> setPreferences(walletId, AddressEntry entry) async {
    await ApiPreferences.setWalletAndAccountInPreferences(walletId, entry);
  }

  void setCurrentAddress(
      walletId, address, Map<String, dynamic> addressList) async {
    walletStorage.setCurrentAccount(address);
    walletStorage.setCurrentAddressList(addressList);
  }

  Future<bool> verifyPassword(String password) async {
    try {
      bool isValidPasssword = await db.verifyPassword(password);
      if (isValidPasssword) {
        unlocked = true;
      }
      return isValidPasssword;
    } catch (e) {
      return false;
    }
  }

  // Check if can login
  Future<bool> verifyLogin(String password) async {
    try {
      String? key = await getKeychain();
      var value = await verifyPassword(password);
      // Avoid validating the password when importing a new wallet and a keychain is already unlocked
      return key != '' ? true : value;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getKeychain() async {
    try {
      if (unlocked) {
        return await db.getKey();
      } else {
        throw Exception('Database locked');
      }
    } catch (e) {
      return '';
    }
  }

  Future<bool> setPassword(String newPassword,
      [String? oldPassword = null]) async {
    return await db.setPassword(newPassword, oldPassword);
  }

  Future<bool> openDatabase() async {
    try {
      await interface.init();
      String? version;
      bool fileExists =
          await interface.fileExists(interface.getDbWalletsPath());
      version = await explorer.getVersion();
      return await db.configure(
        interface.getDbWalletsPath(),
        fileExists,
        version,
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> lockDatabase() async {
    return await db.lock();
  }

  Future<bool> addStats(AccountStats accountStats) async {
    return await db.add(accountStats.address, accountStats);
  }

  Future<bool> deleteStats(AccountStats accountStats) async {
    return await db.delete(accountStats.address, accountStats);
  }

  Future<bool> updateStats(AccountStats accountStats) async {
    return await db.update(accountStats.address, accountStats);
  }

  Future<AccountStats?> getStatsByAddress(String address) async {
    return await db.getStatsByAddress(address);
  }

  Future<bool> addWallet(Wallet wallet) async {
    return await db.add(wallet.id, wallet);
  }

  Future<bool> deleteWallet(Wallet wallet) async {
    return await db.delete(wallet.id, wallet);
  }

  Future<bool> deleteAllWallets() async {
    return await db.deleteDatabase();
  }

  Future<bool> addAccount(Account account) async {
    return await db.add(account.address, account);
  }

  Future<bool> addVtt(ValueTransferInfo transaction) async {
    return await db.add(transaction.hash, transaction);
  }

  Future<bool> addStake(StakeEntry transaction) async {
    return await db.add(transaction.hash, transaction);
  }

  Future<bool> addUnstake(UnstakeEntry transaction) async {
    return await db.add(transaction.hash, transaction);
  }

  Future<bool> addMint(MintEntry entry) async {
    return await db.add(entry.blockHash, entry);
  }

  Future<StakeEntry?> getStake(String h) async {
    return await db.getStake(h);
  }

  Future<UnstakeEntry?> getUnstake(String h) async {
    return await db.getUnstake(h);
  }

  Future<ValueTransferInfo?> getVtt(String h) async {
    return await db.getVtt(h);
  }

  Future<Account?> getAccount(String h) async {
    return await db.getAccount(h);
  }

  Future<MintEntry?> getMint(String h) async {
    return await db.getMint(h);
  }

  Future getAllVtts() async {
    try {
      return await db.vttRepository.getAllTransactions(db.database);
    } catch (err) {
      print('Error getting vtts:: $err');
    }
  }

  Future<WalletStorage> loadWalletsDatabase() async {
    /// Get all Wallets
    final result = await db.loadWallets();
    if (result.runtimeType == WalletStorage) {
      WalletStorage storage = result;
      walletStorage = storage;
    } else {
      // db isolate can return a DBException
      logger
          .log('There was a DBException loading the wallets ${result.message}');
      walletStorage = WalletStorage(wallets: {});
    }
    return walletStorage;
  }

  Future<bool> updateWallet(Wallet wallet) async {
    walletStorage.wallets[wallet.id] = wallet;
    return await db.update(wallet.id, wallet);
  }

  Future<bool> updateVtt(ValueTransferInfo vtt) async {
    return await db.update(vtt.hash, vtt);
  }

  Future<void> addOrUpdateVttInDB(ValueTransferInfo vtt) async {
    if (await getVtt(vtt.hash) == null) {
      await addVtt(vtt);
    } else {
      await updateVtt(vtt);
    }
  }

  Future<bool> updateMint(MintEntry mint) async {
    return await db.update(mint.blockHash, mint);
  }

  Future<bool> updateStake(StakeEntry stake) async {
    return await db.update(stake.hash, stake);
  }

  Future<bool> updateUnstake(UnstakeEntry unstake) async {
    return await db.update(unstake.hash, unstake);
  }

  Future<bool> deleteVtt(ValueTransferInfo vtt) async {
    return await db.delete(vtt.hash, vtt);
  }

  Future<bool> deleteStake(StakeEntry stake) async {
    return await db.delete(stake.hash, stake);
  }

  Future<bool> deleteUnstake(UnstakeEntry unstake) async {
    return await db.delete(unstake.hash, unstake);
  }

  Future<bool> updateAccount(Account account) async {
    return await db.update(account.address, account);
  }

  Future<WalletStorage> getWalletStorage([bool reload = false]) async {
    if (reload) {
      walletStorage = await loadWalletsDatabase();
      return walletStorage;
    }
    if (walletsLoaded) {
      return walletStorage;
    } else {
      walletStorage = await loadWalletsDatabase();
      return walletStorage;
    }
  }
}
