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

class DBException {
  final int code;
  final String message;
  DBException({
    required this.code,
    required this.message,
  });
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

  late Database _database;

  String? passwordHash;

  _DBConfiguration? _dbConfig;
  DatabaseFactory dbFactory = databaseFactoryIo;
  bool unlocked = false;

  void dispose() {
    _database.close();
    _dbConfig = null;
  }

  Future<void> configure(
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

    _dbService._database = await dbFactory.openDatabase(
        _dbService._dbConfig!.path,
        version: allowDBMigration ? DB_VERSION : DB_PREV_VERSION,
        mode: mode, onVersionChanged: (db, oldVersion, newVersion) async {
      if (newVersion == DB_VERSION_TO_MIGRATE) {
        await migrateDB(db);
      }
    });
  }

  Future<bool> add(dynamic item) async {
    try {
      switch (item.runtimeType) {
        case Wallet:
          await walletRepository.insertWallet(item, _database);
          break;
        case ValueTransferInfo:
          await vttRepository.insertTransaction(item, _database);
          break;
        case Account:
          await accountRepository.insertAccount(item, _database);
          break;
        case MintEntry:
          await mintRepository.insertTransaction(item, _database);
          break;
        case StakeEntry:
          await stakeRepository.insertTransaction(item, _database);
          break;
        case UnstakeEntry:
          await unstakeRepository.insertTransaction(item, _database);
          break;
        case AccountStats:
          await statsRepository.insertStats(item, _database);
          break;
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<bool> deleteDatabase() async {
    try {
      if (_dbConfig != null) {
        await _database.close();
        await dbFactory.deleteDatabase(_dbConfig!.path);
        _dbConfig = null;
      }
      return true;
    } catch (e) {
      print('Error deleting the storage $e');
      return false;
    }
  }

  Future<bool> delete(dynamic item) async {
    try {
      switch (item.runtimeType) {
        case Wallet:
          await walletRepository.deleteWallet(item.id, _database);
          break;
        case ValueTransferInfo:
          await vttRepository.deleteTransaction(item.hash, _database);
          break;
        case Account:
          await accountRepository.deleteAccount(item.address, _database);
          break;
        case MintEntry:
          await mintRepository.deleteTransaction(item.hash, _database);
          break;
        case StakeEntry:
          await stakeRepository.deleteTransaction(item.hash, _database);
          break;
        case UnstakeEntry:
          await unstakeRepository.deleteTransaction(item.hash, _database);
          break;
        case AccountStats:
          await statsRepository.deleteStats(item.address, _database);
          break;
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<bool> update(dynamic item) async {
    try {
      switch (item.runtimeType) {
        case Wallet:
          await walletRepository.updateWallet(item.id, _database);
          break;
        case ValueTransferInfo:
          await vttRepository.updateTransaction(item, _database);
          break;
        case Account:
          await accountRepository.updateAccount(item, _database);
          break;
        case MintEntry:
          await mintRepository.updateTransaction(item, _database);
          break;
        case StakeEntry:
          await stakeRepository.updateTransaction(item, _database);
          break;
        case UnstakeEntry:
          await unstakeRepository.updateTransaction(item, _database);
          break;
        case AccountStats:
          await statsRepository.updateStats(item, _database);
          break;
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<AccountStats?> getStatsByAddress(String address) async {
    try {
      return await statsRepository.getStatsByAddress(_database, address);
    } catch (err) {
      print('Error getting stats from address $address :: $err');
      return null;
    }
  }

  Future<bool> masterKeySet() async {
    bool keyExists = await keyChain.keyExists(_database);
    return keyExists;
  }

  Future<bool> verifyPassword(String password) async {
    try {
      bool keyExists = await masterKeySet();
      if (!keyExists) {
        return false;
      }

      String? key = await keyChain.getKey(_database);
      bool valid = await keyChain.validatePassword(key, password);
      if (valid) {
        unlocked = true;
      }

      return valid;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setPassword(
      {required String oldPassword, required String newPassword}) async {
    try {
      bool success = await keyChain.setKey(
          oldPassword: oldPassword,
          newPassword: newPassword,
          databaseClient: _database);
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<dynamic> migrateDB(db) async {
    /// Get all Transactions
    final List<ValueTransferInfo> transactions =
        await vttRepository.getAllTransactions(db);

    for (int i = 0; i < transactions.length; i++) {
      ValueTransferInfo _vtt = transactions[i];
      await vttRepository.updateTransaction(_vtt, db);
    }
  }

  Future<dynamic> loadWallets() async {
    /// Get all Wallets

    try {
      final List<Wallet> wallets = await walletRepository.getWallets(_database);

      /// Get all Accounts
      final List<Account> accounts =
          await accountRepository.getAccounts(_database);

      /// Get all Transactions
      final List<ValueTransferInfo> transactions =
          await vttRepository.getAllTransactions(_database);
      final List<MintEntry> mints =
          await mintRepository.getAllTransactions(_database);
      final List<StakeEntry> stakes =
          await stakeRepository.getAllTransactions(_database);
      final List<UnstakeEntry> unstakes =
          await unstakeRepository.getAllTransactions(_database);

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
            getAccountVttsMap(transactions);
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
                  .getStatsByAddress(_database, accounts[i].address);
              if (accountStats != null) {
                walletMap[accounts[i].walletId]!
                    .setMasterAccountStats(accountStats);
              }
            } catch (e) {
              return DBException(code: e.hashCode, message: '$e');
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
        transactions.forEach((vtt) {
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
      return DBException(code: e.hashCode, message: '$e');
    }
  }

  Future<String?> getKey() async {
    if (unlocked) {
      return keyChain.getKey(_database);
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

  Future<ValueTransferInfo?> getVtt(params) async {
    return await vttRepository.getTransaction(params["hash"], _database);
  }

  Future<MintEntry?> getMint(params) async {
    return await mintRepository.getTransaction(params["hash"], _database);
  }

  Future<StakeEntry?> getStake(params) async {
    return await stakeRepository.getTransaction(params["hash"], _database);
  }

  Future<UnstakeEntry?> getUnstake(params) async {
    return await unstakeRepository.getTransaction(params["hash"], _database);
  }

  Future<Account?> getAccount(params) async {
    return await accountRepository.getAccount(params["address"], _database);
  }
}
