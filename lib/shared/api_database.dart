import 'dart:isolate';

import 'package:witnet_wallet/bloc/database/database_isolate.dart';
import 'package:witnet_wallet/util/storage/database/database_service.dart';
import 'package:witnet_wallet/util/storage/database/db_wallet.dart';
import 'package:witnet_wallet/util/storage/path_provider_interface.dart';
import 'package:witnet_wallet/util/witnet/wallet/account.dart';
import 'package:witnet_wallet/util/witnet/wallet/wallet.dart';

import 'locator.dart';

class DatabaseException {
  DatabaseException({required this.code, required this.message});
  final int code;
  final String message;
}

class ApiDatabase {
  DBService? database;
  late String path;
  Future<DBService?> getDb() async {
    DatabaseIsolate databaseIsolate = Locator.instance.get<DatabaseIsolate>();
    await databaseIsolate.init();
  }

  Future<bool> unlockDatabase(
      {required String name, required String password}) async {
    try {
      PathProviderInterface interface = PathProviderInterface();
      await interface.init();
      path = interface.getWalletPath(name);

      DatabaseIsolate databaseIsolate = Locator.instance.get<DatabaseIsolate>();
      if (!databaseIsolate.initialized) await databaseIsolate.init();
      ReceivePort response = ReceivePort();
      bool unlocked = false;
      databaseIsolate.send(
          method: 'unlockDatabase',
          params: {'path': path, 'password': password},
          port: response.sendPort);
      await response.first.then((value) {
        if (value.runtimeType == DBException) {
          throw value;
        }
        var val = value as Map<String, dynamic>;

        if (val.containsKey('unlocked')) {
          unlocked = true;
        }
      });
      if (unlocked) {
        return true;
      } else {
        return false;
      }
    } on DBException {
      rethrow;
    } on DatabaseException {
      rethrow;
    }
  }

  Future<bool> createDatabase(
      {required String path, required String password}) async {
    try {
      DatabaseIsolate databaseIsolate = Locator.instance.get<DatabaseIsolate>();
      if (!databaseIsolate.initialized) await databaseIsolate.init();
      ReceivePort resp = ReceivePort();
      databaseIsolate.send(
          method: 'configure',
          params: {'path': path, 'password': password},
          port: resp.sendPort);
      var respValue = await resp.first.then((value) => value);
      assert(respValue != null);
      return true;
    } on DBException {
      return false;
    }
  }

  Future<List<dynamic>> readBatchRecords(
      {required List<Map<String, Object?>> values}) async {
    try {
      DatabaseIsolate databaseIsolate = Locator.instance.get<DatabaseIsolate>();
      ReceivePort response = ReceivePort();
      databaseIsolate.send(
          method: 'batchRead',
          params: {'read_ops': values},
          port: response.sendPort);
    } catch (e) {
      /// TODO
    }
    return [];
  }

  Future<dynamic> readDatabaseRecord(
      {required dynamic key, required Type type}) async {
    try {
      DatabaseIsolate databaseIsolate = Locator.instance.get<DatabaseIsolate>();
      ReceivePort response = ReceivePort();
      databaseIsolate.send(
          method: 'readRecord',
          params: {'key': key, 'type': type.toString()},
          port: response.sendPort);
      var val = await response.first.then((value) => value);
      return val;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> writeDatabaseRecord(
      {required dynamic key, required dynamic value}) async {
    try {
      DatabaseIsolate databaseIsolate = Locator.instance.get<DatabaseIsolate>();
      ReceivePort response = ReceivePort();
      databaseIsolate.send(
          method: 'writeRecord',
          params: {'key': key, 'value': value},
          port: response.sendPort);
      var resp = await response.first.then((value) {
        return value;
      });
      if (value == resp) {
        throw DatabaseException(code: -1, message: 'Record does not exist.');
      }
    } on DBException {
      rethrow;
    }
  }

  Future<bool> deleteRecord({required dynamic key}) async {
    try {
      return await database!.deleteRecord(key);
    } on DatabaseException {
      rethrow;
    }
  }

  Future<bool> lockDatabase() async {
    if (database != null) {
      database!.lockDatabase();
      return true;
    }
    return false;
  }


  Future<void> syncAccount(Account account) async {}

  Future<void> saveDbWallet(DbWallet dbWallet) async{
    await writeDatabaseRecord(key: 'xprv', value: dbWallet.xprv);
    await writeDatabaseRecord(key: 'name', value: dbWallet.walletName);
    await writeDatabaseRecord(key: 'external_xpub', value: dbWallet.externalXpub);
    await writeDatabaseRecord(key: 'internal_xpub', value: dbWallet.internalXpub);
    await writeDatabaseRecord(key: 'description', value: dbWallet.walletDescription);
    await writeDatabaseRecord(key: 'external_accounts', value: dbWallet.accountMap(keyType: KeyType.external));
    await writeDatabaseRecord(key: 'internal_accounts', value: dbWallet.accountMap(keyType: KeyType.internal));
    await writeDatabaseRecord(key: 'last_synced', value: dbWallet.lastSynced);

  }
  Future<DbWallet> loadWallet() async{
    String xprv = await readDatabaseRecord(key: 'xprv', type: String);
    String externalXpub = await readDatabaseRecord(key: 'external_xpub', type: String);
    String internalXpub = await readDatabaseRecord(key: 'internal_xpub', type: String);
    String description = await readDatabaseRecord(key: 'description', type: String);
    String name = await readDatabaseRecord(key: 'name', type: String);
    Map<String, dynamic> externalAccounts = await readDatabaseRecord(key: 'external_accounts', type: Map);
    Map<String, dynamic> internalAccounts = await readDatabaseRecord(key: 'internal_accounts', type: Map);

    Map<int, Account> xt = {};
    externalAccounts.forEach((address, account) {
      account as Map<String, Object?>;
      Account _account = Account.fromJson(account);
      _account.setBalance();
      xt[int.parse(_account.path.split('/').last)] = _account;
    });

    // parse into structure
    Map<int, Account> nt = {};
    internalAccounts.forEach((address, account) {
      account as Map<String, Object?>;
      Account _account = Account.fromJson(account);
      _account.setBalance();
      nt[int.parse(_account.path.split('/').last)] = _account;

    });
    return DbWallet(
      xprv: xprv,
      walletName: name,
      externalAccounts: xt,
      internalAccounts: nt,
      externalXpub: externalXpub,
      internalXpub: internalXpub,
      walletDescription: description,
      lastSynced: -1,
    );
  }


}
