import 'dart:async';
import 'package:my_wit_wallet/util/storage/database/check_version_compatibility.dart';
import 'package:my_wit_wallet/util/storage/database/get_account_mints_map.dart';
import 'package:my_wit_wallet/util/storage/database/get_account_stakes_map.dart';
import 'package:my_wit_wallet/util/storage/database/get_account_unstakes_map.dart';
import 'package:my_wit_wallet/util/storage/database/get_account_vtts_map.dart';
import 'package:my_wit_wallet/util/storage/database/stats.dart';
import 'package:my_wit_wallet/util/storage/database/adapters/transaction_adapter.dart';
import 'package:sembast/sembast_io.dart';
import 'package:witnet/explorer.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/storage/database/account_repository.dart';
import 'package:my_wit_wallet/util/storage/database/stats_repository.dart';
import 'package:my_wit_wallet/util/storage/database/encrypt/keychain.dart';
import 'package:my_wit_wallet/util/storage/database/encrypt/salsa20/codec.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/util/storage/database/wallet_repository.dart';
import 'package:my_wit_wallet/util/storage/database/transaction_repository.dart';
import 'package:my_wit_wallet/util/storage/database/wallet_storage.dart';

class _DBConfiguration {
  String path;
  late SembastCodec? codec;
  int timeout = 300;

  _DBConfiguration({required this.path, String? password}) {
    if (ENCRYPT_DB == true && password != null) {
      codec = getSembastCodecSalsa20(password: password);
    }
  }

  String get name => this.path.split('/').last;

  void dispose() {
    codec = null;
  }
}

class DatabaseException {
  DatabaseException({required this.code, required this.message});
  final int code;
  final String message;
}

class DatabaseService {
  static final DatabaseService _dbService = DatabaseService._internal();
  DatabaseService._internal();

  factory DatabaseService.instance() {
    return DatabaseService._dbService;
  }

  WalletRepository walletRepository = WalletRepository();
  VttRepository vttRepository = VttRepository();
  AccountRepository accountRepository = AccountRepository();
  MintRepository mintRepository = MintRepository();
  StakeRepository stakeRepository = StakeRepository();
  UnstakeRepository unstakeRepository = UnstakeRepository();
  StatsRepository statsRepository = StatsRepository();

  KeyChain keyChain = KeyChain();

  late Database database;

  String? passwordHash;

  _DBConfiguration? _dbConfig;
  DatabaseFactory dbFactory = databaseFactoryIo;
  bool unlocked = false;

  void dispose() {
    database.close();
    _dbConfig = null;
  }

  Future<bool> configure(
      String path, bool fileExists, String? apiVersion) async {
    if (_dbConfig == null) {
      _dbConfig = _DBConfiguration(
        path: path,
      );
    } else {
      _dbConfig = null;
      _dbConfig = _DBConfiguration(
        path: path,
      );
    }
    DatabaseMode mode;
    if (fileExists) {
      mode = DatabaseMode.existing;
    } else {
      mode = DatabaseMode.create;
    }
    bool allowDBMigration = checkVersionCompatibility(
        apiVersion: apiVersion, compatibleVersion: COMPATIBLE_API_VERSION);

    try {
      _dbService.database = await dbFactory.openDatabase(
          _dbService._dbConfig!.path,
          version: allowDBMigration ? DB_VERSION : DB_PREV_VERSION,
          mode: mode, onVersionChanged: (db, oldVersion, newVersion) async {
        if (newVersion == DB_VERSION_TO_MIGRATE) {
          await migrateDB(db);
        }
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> add(String key, dynamic item) async {
    Map<Type, dynamic> repoMap = {
      Wallet: walletRepository.insertWallet,
      ValueTransferInfo: vttRepository.insertTransaction,
      Account: accountRepository.insertAccount,
      MintEntry: mintRepository.insertTransaction,
      StakeEntry: stakeRepository.insertTransaction,
      UnstakeEntry: unstakeRepository.insertTransaction,
      AccountStats: statsRepository.insertStats,
    };
    if (repoMap.keys.contains(item.runtimeType)) {
      var k = await repoMap[item.runtimeType](item, database);
      print(k);
      return await repoMap[item.runtimeType](item, database);
    } else {
      return false;
    }
  }

  Future<bool> deleteDatabase() async {
    try {
      if (_dbConfig != null) {
        await database.close();
        await dbFactory.deleteDatabase(_dbConfig!.path);
        _dbConfig = null;
      }
      return true;
    } catch (e) {
      print('Error deleting the storage $e');
      return false;
    }
  }

  Future<bool> delete(String key, dynamic item) async {
    Map<Type, dynamic> repoMap = {
      Wallet: walletRepository.deleteWallet,
      ValueTransferInfo: vttRepository.deleteTransaction,
      Account: accountRepository.deleteAccount,
      MintEntry: mintRepository.deleteTransaction,
      StakeEntry: stakeRepository.deleteTransaction,
      UnstakeEntry: unstakeRepository.deleteTransaction,
      AccountStats: statsRepository.deleteStats,
    };
    if (repoMap.keys.contains(item.runtimeType)) {
      return await repoMap[item.runtimeType](key, database);
    } else {
      return false;
    }
  }

  Future<bool> update(String key, dynamic item) async {
    Map<Type, dynamic> repoMap = {
      Wallet: walletRepository.updateWallet,
      ValueTransferInfo: vttRepository.updateTransaction,
      Account: accountRepository.updateAccount,
      MintEntry: mintRepository.updateTransaction,
      StakeEntry: stakeRepository.updateTransaction,
      UnstakeEntry: unstakeRepository.updateTransaction,
      AccountStats: statsRepository.updateStats,
    };
    if (repoMap.keys.contains(item.runtimeType)) {
      return await repoMap[item.runtimeType](key, item, database);
    } else {
      return false;
    }
  }

  Future<dynamic> get(Type type, String key) async {
    Map<Type, dynamic> repoMap = {
      Wallet: walletRepository.getWallet,
      ValueTransferInfo: vttRepository.getTransaction,
      Account: accountRepository.getAccount,
      MintEntry: mintRepository.getTransaction,
      StakeEntry: stakeRepository.getTransaction,
      UnstakeEntry: unstakeRepository.getTransaction,
      AccountStats: statsRepository.getStatsByAddress,
    };
    if (repoMap.keys.contains(type.runtimeType)) {
      return await repoMap[type](key, database);
    } else {
      return false;
    }
  }

  Future<AccountStats?> getStatsByAddress(String address) async {
    try {
      return await statsRepository.getStatsByAddress(database, address);
    } catch (err) {
      print('Error getting stats from address $address :: $err');
      return null;
    }
  }

  Future<bool> masterKeySet() async {
    bool keyExists = await keyChain.keyExists();
    return keyExists;
  }

  Future<bool> verifyPassword(String password) async {
    try {
      bool keyExists = await masterKeySet();
      if (!keyExists) {
        return false;
      }

      String? key = await keyChain.getKey();
      bool valid = await keyChain.validatePassword(key, password);
      if (valid) {
        unlocked = true;
      }

      return valid;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setPassword(String newPassword, String? oldPassword) async {
    try {
      bool success = await keyChain.setKey(newPassword, oldPassword);
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<dynamic> migrateDB(db) async {
    /// Get all Transactions
    final List<ValueTransferInfo> vtts =
        await vttRepository.getAllTransactions(database);

    for (int i = 0; i < vtts.length; i++) {
      ValueTransferInfo _vtt = vtts[i];
      await vttRepository.updateTransaction(_vtt, database);
    }
  }

  Future<dynamic> loadWallets() async {
    /// Get all Wallets

    try {
      final List<Wallet> wallets = await walletRepository.getWallets(database);

      /// Get all Accounts
      final List<Account> accounts =
          await accountRepository.getAccounts(database);

      /// Get all Transactions
      final List<ValueTransferInfo> vtts =
          await vttRepository.getAllTransactions(database);
      final List<MintEntry> mints =
          await mintRepository.getAllTransactions(database);
      final List<StakeEntry> stakes =
          await stakeRepository.getAllTransactions(database);
      final List<UnstakeEntry> unstakes =
          await unstakeRepository.getAllTransactions(database);

      /// Create a map of the Wallets with the wallet.id as the key.
      Map<String, Wallet> walletMap = {};
      Map<String, Account> accountMap = {};
      Map<String, ValueTransferInfo> vttMap = {};
      Map<String, MintEntry> mintMap = {};
      Map<String, StakeEntry> stakeMap = {};
      Map<String, UnstakeEntry> unstakeMap = {};
      for (int i = 0; i < wallets.length; i++) {
        walletMap[wallets[i].id] = wallets[i];
      }

      if (wallets.isNotEmpty) {
        Map<String, List<ValueTransferInfo>> accountVttMap =
            getAccountVttsMap(vtts);
        Map<String, List<MintEntry>> accountMintMap = getAccountMintsMap(mints);
        Map<String, List<StakeEntry>> accountStakesMap =
            getAccountStakesMap(stakes);
        Map<String, List<UnstakeEntry>> accountUnstakesMap =
            getAccountUnstakesMap(unstakes);

        /// Process by account
        for (int i = 0; i < accounts.length; i++) {
          String _walletId = accounts[i].walletId;
          String _address = accounts[i].address;

          /// add the transaction if it is for this account
          if (accountVttMap[_address] != null) {
            accounts[i].vtts.addAll(accountVttMap[_address]!);
          }
          if (accountStakesMap[_address] != null) {
            accounts[i].stakes.addAll(accountStakesMap[_address]!);
          }
          if (accountUnstakesMap[_address] != null) {
            accounts[i].unstakes.addAll(accountUnstakesMap[_address]!);
          }
          if (accounts[i].keyType == KeyType.master) {
            // add the transaction if it is for this account
            if (accountMintMap[_address] != null) {
              accounts[i].mints.addAll(accountMintMap[_address]!);
            }
            try {
              // Load saved node account stats
              final AccountStats? accountStats = await statsRepository
                  .getStatsByAddress(database, accounts[i].address);
              if (accountStats != null) {
                walletMap[accounts[i].walletId]!
                    .setMasterAccountStats(accountStats);
              }
            } catch (e) {
              return DatabaseException(code: e.hashCode, message: '$e');
            }
          }

          /// Add the account to the wallet
          if (walletMap[_walletId] != null) {
            walletMap[_walletId]!.setAccount(accounts[i]);
          }
        }
        accounts.forEach((account) {
          accountMap[account.address] = account;
        });
        vtts.forEach((vtt) {
          vttMap[vtt.hash] = vtt;
        });
        mints.forEach((mint) {
          mintMap[mint.blockHash] = mint;
        });
        stakes.forEach((stake) {
          stakeMap[stake.blockHash] = stake;
        });
        unstakes.forEach((unstake) {
          unstakeMap[unstake.blockHash] = unstake;
        });
      }

      /// Load current wallet and address from preferences
      WalletStorage _walletStorage = WalletStorage(wallets: walletMap);
      _walletStorage.setAccounts(accountMap);
      _walletStorage.setTransactions(vttMap);
      _walletStorage.setMints(mintMap);
      _walletStorage.setStakes(stakeMap);
      _walletStorage.setUnstakes(unstakeMap);
      return _walletStorage;
    } catch (e) {
      return DatabaseException(code: e.hashCode, message: '$e');
    }
  }

  Future<String?> getKey() async {
    if (unlocked) {
      return keyChain.getKey();
    } else {
      return null;
    }
  }

  Future<bool> lock() async {
    keyChain.keyHash = null;
    keyChain.unlocked = false;
    unlocked = false;
    return true;
  }

  Future<ValueTransferInfo?> getVtt(String h) async {
    return await get(ValueTransferInfo, h);
  }

  Future<MintEntry?> getMint(String h) async {
    return await get(MintEntry, h);
  }

  Future<StakeEntry?> getStake(String h) async {
    return await get(StakeEntry, h);
  }

  Future<UnstakeEntry?> getUnstake(String h) async {
    return await get(UnstakeEntry, h);
  }

  Future<Account?> getAccount(String a) async {
    return await get(Address, a);
  }
}
