import 'dart:isolate';

import 'package:witnet/explorer.dart';
import 'package:witnet_wallet/util/storage/database/database_isolate.dart';
import 'package:witnet_wallet/util/storage/database/database_service.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';
import 'package:witnet_wallet/util/storage/path_provider_interface.dart';

import 'package:witnet_wallet/util/storage/database/account.dart';
import 'package:witnet_wallet/util/storage/database/wallet_storage.dart';
import 'locator.dart';

class DatabaseException {
  DatabaseException({required this.code, required this.message});
  final int code;
  final String message;
}

/// [ApiDatabase] is used to communicate between the database isolate and the
/// rest of the application.
class ApiDatabase {
  late String path;
  Map<String, Wallet> _wallets = {};
  bool initialized = false;
  bool unlocked = false;

  DatabaseIsolate get databaseIsolate => Locator.instance<DatabaseIsolate>();
  PathProviderInterface interface = PathProviderInterface();

  Future<dynamic> _processIsolate(
      {required String method, required Map<String, dynamic> params}) async {
    if (!databaseIsolate.initialized) await databaseIsolate.init();
    final ReceivePort response = ReceivePort();

    databaseIsolate.send(
        method: method, params: params, port: response.sendPort);
    return await response.first.then((value) {
      if (value.runtimeType == DBException) {
        throw value;
      }
      return value;
    });
  }

  Future<bool> masterKeySet() async {
    try {
      var value = await _processIsolate(
        method: 'masterKeySet',
        params: {},
      );
      return value;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyPassword(String password) async {
    try {
      var value = await _processIsolate(
        method: 'verifyPassword',
        params: {'password': password},
      );
      if (value) {
        unlocked = true;
      }
      return value;
    } catch (e) {
      return false;
    }
  }

  Future<String> getKeychain() async {
    try {
      if (unlocked) {
        var value = await _processIsolate(
          method: 'getKeychain',
          params: {},
        );
        return value;
      } else {
        throw Exception('Database locked');
      }
    } catch (e) {
      return '';
    }
  }

  Future<bool> setPassword(
      {String? oldPassword, required String newPassword}) async {
    await _processIsolate(
      method: 'setPassword',
      params: {
        'oldPassword': oldPassword ?? '',
        'newPassword': newPassword,
      },
    );
    return true;
  }

  Future<bool> openDatabase() async {
    await interface.init();
    var fileExists = await interface.fileExists(interface.getDbWalletsPath());
    try {
      var response = await _processIsolate(
        method: 'configure',
        params: {
          'path': interface.getDbWalletsPath(),
          'fileExists': fileExists
        },
      );

      assert(response != null);
      return true;
    } on DBException {
      return false;
    }
  }

  Future<bool> lockDatabase() async {
    try {
      var response = await _processIsolate(
        method: 'lock',
        params: {},
      );
      return response;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addWallet(Wallet wallet) async {
    _wallets[wallet.name] = wallet;
    return await _processIsolate(
        method: 'add', params: {'type': 'wallet', 'value': wallet.jsonMap()});
  }

  Future<bool> addAccount(Account account) async {
    return await _processIsolate(
        method: 'add', params: {'type': 'account', 'value': account.jsonMap()});
  }

  Future<bool> addVtt(ValueTransferInfo transaction) async {
    return await _processIsolate(
        method: 'add', params: {'type': 'vtt', 'value': transaction.jsonMap()});
  }

  Future<WalletStorage> loadWalletsDatabase() async {
    try {
      List<Wallet> wallets =
          await _processIsolate(method: 'getAllWallets', params: {});
      List<Account> accounts =
          await _processIsolate(method: 'getAllAccounts', params: {});

      Map<String, Wallet> walletMap = {};
      for (int i = 0; i < wallets.length; i++) {
        Wallet wallet = wallets[i];
        walletMap[wallet.name] = wallet;
      }

      for (int i = 0; i < accounts.length; i++) {
        Account account = accounts[i];

        int _type = int.parse(account.path.split('/')[4]);
        int _index = int.parse(account.path.split('/').last);
        // external account
        if (_type == 0) {
          walletMap[account.walletName]?.externalAccounts[_index] = account;

          // internal account
        } else if (_type == 1) {
          walletMap[account.walletName]?.internalAccounts[_index] = account;
        }
      }
      _wallets = walletMap;

    } catch (e) {}
    return WalletStorage(
      wallets: _wallets,
      lastSynced: lastSynced,
    );
  }

  Future<bool> updateWallet(Wallet dbWallet) async {
    _wallets[dbWallet.name] = dbWallet;
    return await _processIsolate(
        method: 'update',
        params: {'type': 'wallet', 'value': dbWallet.jsonMap()});
  }

  Future<bool> updateAccount(Account account) async {
    return await _processIsolate(
        method: 'update',
        params: {'type': 'account', 'value': account.jsonMap()});
  }
}
