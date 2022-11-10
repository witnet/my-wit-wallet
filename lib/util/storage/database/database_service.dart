import 'dart:async';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet_wallet/constants.dart';
import 'package:witnet_wallet/util/storage/database/account.dart';
import 'package:witnet_wallet/util/storage/database/account_repository.dart';
import 'package:witnet_wallet/util/storage/database/encrypt/keychain.dart';
import 'package:witnet_wallet/util/storage/database/encrypt/salsa20/codec.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';
import 'package:witnet_wallet/util/storage/database/wallet_repository.dart';
import 'package:witnet_wallet/util/storage/database/transaction_repository.dart';

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
      '${this}{"DBException": {"code": $code, "message": $message}}';
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
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
    return true;
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
          await vttRepository.updateTransaction(item.transactionId, _database);
          break;
        case Account:
          await accountRepository.updateAccount(item, _database);
          break;
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<bool> masterKeySet() async {
    bool keyExists = await keyChain.keyExists(_database);
    return keyExists;
  }

  Future<bool> verifyPassword(String password) async {
    try {
      bool keyExists = await masterKeySet();
      if (keyExists) {
        String? key = await keyChain.getKey(_database);

        bool valid = await keyChain.validatePassword(key, password);
        if (valid) {
          unlocked = true;
        }
        return valid;
      }
    } catch (e) {
      return false;
    }
    return false;
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

  Future<List<Account>> getAllAccounts() async {
    final List<Account> accounts =
        await accountRepository.getAccounts(_database);
    return accounts;
  }

  Future<List<Wallet>> getAllWallets() async {
    final List<Wallet> wallets = await walletRepository.getWallets(_database);

    Map<String, Wallet> walletMap = {};
    for (int i = 0; i < wallets.length; i++) {
      walletMap[wallets[i].name] = wallets[i];
    }

    List<Account> accounts = await getAllAccounts();

    for (int i = 0; i < accounts.length; i++) {
      Account account = accounts[i];
      if (account.path.contains('M/3h/4919h/0h/0/')) {
        walletMap[account.walletName]!
                .externalAccounts[int.parse(account.path.split('/').last)] =
            account;
      } else {
        walletMap[account.walletName]!
                .internalAccounts[int.parse(account.path.split('/').last)] =
            account;
      }
    }

    return wallets;
  }

  Future<List<ValueTransferInfo>> getAllVtts() async {
    final List<ValueTransferInfo> transactions =
        await vttRepository.getAllTransactions(_database);
    return transactions;
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
}
