import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:my_wit_wallet/util/storage/database/stats.dart';
import 'package:my_wit_wallet/util/storage/database/transaction_adapter.dart';
import 'package:witnet/explorer.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';

import 'account.dart';
import 'database_service.dart';

Map<String, Function(DatabaseService, SendPort, Map<String, dynamic>)>
    methodMap = {
  'add': _addRecord,
  'configure': _configure,
  'delete': _deleteRecord,
  'deleteDatabase': _deleteDatabase,
  'getKeychain': _getKeychain,
  'getStatsByAddress': _getStatsByAddress,
  'getVtt': _getVtt,
  'getMint': _getMint,
  'loadWallets': _getAllWallets,
  'lock': _lock,
  'masterKeySet': _masterKeySet,
  'setPassword': _setPassword,
  'update': _updateRecord,
  'verifyPassword': _verifyPassword,
};

class DatabaseIsolate {
  static final DatabaseIsolate _databaseIsolate = DatabaseIsolate._internal();
  DatabaseIsolate._internal();

  late Isolate isolate;
  late SendPort sendPort;
  late ReceivePort receivePort;
  bool initialized = false;
  bool loading = false;

  factory DatabaseIsolate.instance() => _databaseIsolate;

  Future<void> init() async {
    loading = true;
    if (initialized == false) {
      _databaseIsolate.receivePort = ReceivePort();
      _databaseIsolate.isolate = await Isolate.spawn(
          _dbIsolate, _databaseIsolate.receivePort.sendPort);
      _databaseIsolate.sendPort =
          await _databaseIsolate.receivePort.first as SendPort;

      initialized = true;
      loading = false;
    }
  }

  void send({
    required String method,
    required Map<String, dynamic> params,
    required SendPort port,
  }) {
    _databaseIsolate.sendPort.send(['$method?${json.encode(params)}', port]);
  }
}

void _dbIsolate(SendPort sendPort) async {
  // open our receive port
  try {
    DatabaseService dbService = DatabaseService.instance();

    ReceivePort receivePort = ReceivePort();

    // tell whoever created us what port they can reach us
    sendPort.send(receivePort.sendPort);

    // listen for messages
    await for (var msg in receivePort) {
      var data = msg[0] as String;
      SendPort port = msg[1];
      var method = data.split('?')[0];
      var params = json.decode(data.split('?')[1]);
      await methodMap[method]!(dbService, port, params);
    }
    receivePort.close();
  } catch (e) {}
}

Future<void> _lock(
  final DatabaseService dbService,
  SendPort port,
  Map<String, dynamic> params,
) async {
  bool locked = await dbService.lock();

  port.send(locked);
}

Future<void> _verifyPassword(
  final DatabaseService dbService,
  SendPort port,
  Map<String, dynamic> params,
) async {
  bool exists = await dbService.verifyPassword(params['password']);
  port.send(exists);
}

Future<void> _masterKeySet(
  final DatabaseService dbService,
  SendPort port,
  Map<String, dynamic> params,
) async {
  bool keySet = await dbService.masterKeySet();
  port.send(keySet);
}

Future<void> _setPassword(
  final DatabaseService dbService,
  SendPort port,
  Map<String, dynamic> params,
) async {
  bool exists = await dbService.setPassword(
      oldPassword: params['oldPassword'], newPassword: params['newPassword']);

  port.send(exists);
}

Future<void> _configure(
  DatabaseService dbService,
  SendPort port,
  Map<String, dynamic> params,
) async {
  dbService.configure(params['path'], params['fileExists']);
  port.send({'unlocked': true});
}

Future<void> _addRecord(
  DatabaseService dbService,
  SendPort port,
  Map<String, dynamic> params,
) async {
  bool value;
  switch (params['type']) {
    case 'wallet':
      value = await dbService.add(Wallet.fromJson(params['value']));
      break;
    case 'vtt':
      value =
          await dbService.add(ValueTransferInfo.fromDbJson(params['value']));
      break;
    case 'account':
      value = await dbService.add(Account.fromJson(params['value']));
      break;
    case 'mint':
      value = await dbService.add(MintEntry.fromJson(params['value']));
      break;
    case 'stats':
      value = await dbService.add(AccountStats.fromJson(params['value']));
      break;
    default:
      value = false;
      break;
  }
  port.send(value);
}

Future<void> _deleteRecord(
  DatabaseService dbService,
  SendPort port,
  Map<String, dynamic> params,
) async {
  bool value;
  switch (params['type']) {
    case 'wallet':
      value = await dbService.delete(Wallet.fromJson(params['value']));
      break;
    case 'vtt':
      value =
          await dbService.delete(ValueTransferInfo.fromDbJson(params['value']));
      break;
    case 'account':
      value = await dbService.delete(Account.fromJson(params['value']));
      break;
    case 'stats':
      value = await dbService.delete(AccountStats.fromJson(params['value']));
      break;
    default:
      value = false;
      break;
  }
  port.send(value);
}

Future<void> _deleteDatabase(DatabaseService dbService, SendPort port,
    Map<String, dynamic> params) async {
  bool databaseDeleted = await dbService.deleteDatabase();
  port.send(databaseDeleted);
}

Future<void> _updateRecord(
  DatabaseService dbService,
  SendPort port,
  Map<String, dynamic> params,
) async {
  bool value;
  switch (params['type']) {
    case 'wallet':
      value = await dbService.update(Wallet.fromJson(params['value']));
      break;
    case 'mint':
      value = await dbService.update(MintEntry.fromJson(params['value']));
      break;
    case 'vtt':
      value =
          await dbService.update(ValueTransferInfo.fromDbJson(params['value']));
      break;
    case 'account':
      value = await dbService.update(Account.fromJson(params['value']));
      break;
    case 'stats':
      value = await dbService.update(AccountStats.fromJson(params['value']));
      break;
    default:
      value = false;
      break;
  }
  port.send(value);
}

Future<void> _getStatsByAddress(DatabaseService dbService, SendPort port,
    Map<String, dynamic> params) async {
  AccountStats? accountStats =
      await dbService.getStatsByAddress(params['address']);
  port.send(accountStats);
}

Future<void> _getAllWallets(
  DatabaseService dbService,
  SendPort port,
  Map<String, dynamic> params,
) async {
  port.send(await dbService.loadWallets());
}

Future<void> _getKeychain(
  DatabaseService dbService,
  SendPort port,
  Map<String, dynamic> params,
) async {
  await dbService.getKey();
  port.send(dbService.keyChain.keyHash);
}

Future<void> _getVtt(
  DatabaseService dbService,
  SendPort port,
  Map<String, dynamic> params,
) async {
  ValueTransferInfo? vtt = await dbService.getVtt(params);
  port.send(vtt);
}

Future<void> _getMint(
  DatabaseService dbService,
  SendPort port,
  Map<String, dynamic> params,
) async {
  MintEntry? mint = await dbService.getMint(params);
  port.send(mint);
}
