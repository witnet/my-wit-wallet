import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';

import 'account.dart';
import 'database_service.dart';

class DatabaseIsolate {
  static final DatabaseIsolate _databaseIsolate = DatabaseIsolate._internal();
  DatabaseIsolate._internal();

  late Isolate isolate;
  late SendPort sendPort;
  late ReceivePort receivePort;
  bool initialized = false;

  factory DatabaseIsolate.instance() => _databaseIsolate;

  Future<void> init() async {
    if (initialized == false) {
      _databaseIsolate.receivePort = ReceivePort();
      _databaseIsolate.isolate = await Isolate.spawn(
          _dbIsolate, _databaseIsolate.receivePort.sendPort);
      _databaseIsolate.sendPort =
          await _databaseIsolate.receivePort.first as SendPort;

      initialized = true;
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

Map<String, Function(DatabaseService, SendPort, Map<String, dynamic>)>
    methodMap = {
  'configure': _configure,
  'add': _addRecord,
  'delete': _deleteRecord,
  'update': _updateRecord,
  'setPassword': _setPassword,
  'verifyPassword': _verifyPassword,
  'masterKeySet': _masterKeySet,
  'getAllWallets': _getAllWallets,
  'getAllVtts': _getAllVtts,
  'getAllAccounts': _getAllAccounts,
  'getKeychain': _getKeychain,
  'lock': _lock,
};

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
  var value = await dbService.delete(params['value']);
  port.send(value);
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
    case 'vtt':
      value = await dbService.update(VTTransaction.fromJson(params['value']));
      break;
    case 'account':
      value = await dbService.update(Account.fromJson(params['value']));
      break;
    default:
      value = false;
      break;
  }
  port.send(value);
}

Future<void> _getAllWallets(
  DatabaseService dbService,
  SendPort port,
  Map<String, dynamic> params,
) async {
  var value = await dbService.getAllWallets();
  port.send(value);
}

Future<void> _getAllVtts(
  DatabaseService dbService,
  SendPort port,
  Map<String, dynamic> params,
) async {
  var value = await dbService.getAllVtts();
  port.send(value);
}

Future<void> _getAllAccounts(
  DatabaseService dbService,
  SendPort port,
  Map<String, dynamic> params,
) async {
  var value = await dbService.getAllAccounts();
  port.send(value);
}

Future<void> _getKeychain(
  DatabaseService dbService,
  SendPort port,
  Map<String, dynamic> params,
) async {
  var value = await dbService.getKey();
  port.send(dbService.keyChain.keyHash);
}
