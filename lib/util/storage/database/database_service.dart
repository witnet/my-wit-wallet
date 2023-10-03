import 'dart:async';
import 'package:my_wit_wallet/util/storage/database/stats.dart';
import 'package:my_wit_wallet/util/storage/database/transaction_adapter.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast.dart';
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

  @override
  String toString() =>
      '$this{"DBException": {"code": $code, "message": $message}}';
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

  Future<void> configure(String path, bool fileExists) async {
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
    _dbService._database = await dbFactory.openDatabase(
      _dbService._dbConfig!.path,
      version: 2,
      mode: mode,
    );
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
      if (_dbConfig != null) await dbFactory.deleteDatabase(_dbConfig!.path);
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
          await vttRepository.deleteTransaction(item.txnHash, _database);
          break;
        case Account:
          await accountRepository.deleteAccount(item.address, _database);
          break;
        case MintEntry:
          await mintRepository.deleteTransaction(item.txnHash, _database);
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

  Future<WalletStorage> loadWallets() async {
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

      /// Create a map of the Wallets with the wallet.id as the key.
      Map<String, Wallet> walletMap = {};
      Map<String, Account> accountMap = {};
      Map<String, ValueTransferInfo> vttMap = {};
      Map<String, MintEntry> mintMap = {};
      for (int i = 0; i < wallets.length; i++) {
        walletMap[wallets[i].id] = wallets[i];
      }

      if (wallets.isNotEmpty) {
        /// Process by account
        for (int i = 0; i < accounts.length; i++) {
          String _walletId = accounts[i].walletId;
          String _address = accounts[i].address;
          for (int j = 0; j < transactions.length; j++) {
            /// add the transaction if it is for this account
            if (transactions[j].containsAddress(_address)) {
              accounts[i].vtts.add(transactions[j]);
            }
          }

          if (accounts[i].keyType == KeyType.master) {
            for (int j = 0; j < mints.length; j++) {
              /// add the transaction if it is for this account
              if (mints[j].containsAddress(_address)) {
                accounts[i].mints.add(mints[j]);
              }
              // Load saved node account stats
              final AccountStats? accountStats = await statsRepository
                  .getStatsByAddress(_database, accounts[i].address);
              if (accountStats != null) {
                walletMap[accounts[i].walletId]!
                    .setMasterAccountStats(accountStats);
              }
            }
          }

          /// Set the account balance since the transactions are set.
          await accounts[i].setBalance();

          /// Add the account to the wallet
          if (walletMap[_walletId] != null) {
            walletMap[_walletId]!.setAccount(accounts[i]);
          }
        }
        accounts.forEach((account) {
          accountMap[account.address] = account;
        });
        transactions.forEach((vtt) {
          vttMap[vtt.txnHash] = vtt;
        });
        mints.forEach((mint) {
          mintMap[mint.blockHash] = mint;
        });
      }

      /// Load current wallet and address from preferences
      WalletStorage _walletStorage = WalletStorage(wallets: walletMap);
      _walletStorage.setAccounts(accountMap);
      _walletStorage.setTransactions(vttMap);
      _walletStorage.setMints(mintMap);

      return _walletStorage;
    } catch (e) {
      print(e);
      return WalletStorage(wallets: {});
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
}
