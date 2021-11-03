import 'dart:isolate';

import 'package:witnet_wallet/bloc/database/database_isolate.dart';
import 'package:witnet_wallet/util/storage/database/database_service.dart';
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
      bool databaseExists = await interface.fileExists(path);
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
    } on DBException catch (e) {
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

  Future<Wallet> parseWallet() async {
    String walletName = '';
    String walletDescription = '';
    DatabaseIsolate databaseIsolate = Locator.instance.get<DatabaseIsolate>();
    ReceivePort response = ReceivePort();
    Wallet wallet = Wallet(walletName, walletDescription);
    //wallet.masterXprv =
    var params = [
      {'key': 'xprv', 'value': String},
      {'key': 'external_key', 'type': Map},
    ];
    var vals = await readBatchRecords(values: params);
    return wallet;
  }

  Future<void> syncAccount(Account account) async {}
}
