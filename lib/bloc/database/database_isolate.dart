import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:witnet_wallet/util/storage/database/database_service.dart';

class DatabaseIsolate {
  static final DatabaseIsolate _databaseIsolate = DatabaseIsolate._internal();
  DatabaseIsolate._internal();

  late Isolate isolate;
  late SendPort sendPort;
  late ReceivePort receivePort;
  bool initialized = false;

  factory DatabaseIsolate.instance() {
    return _databaseIsolate;
  }
  Future<void> init() async {
    _databaseIsolate.receivePort = ReceivePort();
    _databaseIsolate.isolate =
        await Isolate.spawn(dbIsolate, _databaseIsolate.receivePort.sendPort);
    _databaseIsolate.sendPort =
        await _databaseIsolate.receivePort.first as SendPort;
    initialized = true;
  }

  void send(
      {required String method,
      required Map<String, dynamic> params,
      required SendPort port}) {
    sendPort.send(['$method?${json.encode(params)}', port]);
  }
}

void dbIsolate(SendPort sendPort) async {
  // the database service.
  DBService dbService = DBService();
  // open our receive port
  final receivePort = ReceivePort();
  // tell whoever created us what port they can reach us
  sendPort.send(receivePort.sendPort);
  // listen for messages
  await for (var msg in receivePort) {
    var data = msg[0] as String;
    SendPort port = msg[1];
    var method = data.split('?')[0];
    var params = json.decode(data.split('?')[1]);
    switch (method) {
      case 'unlockDatabase':
        await _unlockDatabase(dbService, port, params);
        break;
      case 'configure':
        await _configure(dbService, port, params);
        break;
      case 'readRecord':
        await _readRecord(dbService, port, params);
        break;
      case 'getDatabaseService':
        await _getDatabaseService(dbService, port, params);
        break;
      case 'batchRead':
        await _batchRead(dbService, port, params);
        break;
      case 'writeRecord':
        await _writeRecord(dbService, port, params);
        break;
    }
  }
}

Future<void> _unlockDatabase(
    DBService dbService, SendPort port, Map<String, dynamic> params) async {
  FutureOr<dynamic> tmp =
      await dbService.unlockWallet(params['path'], params['password']);
  if (tmp.runtimeType == DBException) {
    port.send(tmp);
  }
  port.send({'unlocked': true});
}

Future<void> _configure(
    DBService dbService, SendPort port, Map<String, dynamic> params) async {
  dbService.configure(path: params['path'], password: params['password']);
  port.send({'unlocked': true});
}

Future<void> _readRecord(
    DBService dbService, SendPort port, Map<String, dynamic> params) async {
  if (params['type'] == 'String') {
    var value = await dbService.readString(params['key']);
    port.send(value);
  } else if (params['type'] == 'Map<dynamic, dynamic>') {
    var value = await dbService.readMap(params['key']);
    port.send(value);
  }
}

Future<void> _getDatabaseService(
    DBService dbService, SendPort port, Map<String, dynamic> params) async {
  port.send({'dbService': dbService});
}

Future<void> _batchRead(
    DBService dbService, SendPort port, Map<String, dynamic> params) async {
  var readStack = params['read_ops'] as List<Map<String, Type>>;
  var results = [];
  readStack.forEach((op) async {
    results.add(await dbService.readRecord(op['key']!, op['type']!));
  });
  port.send({'results': results});
}

Future<void> _writeRecord(
    DBService dbService, SendPort port, Map<String, dynamic> params) async {
  var result = await dbService.writeRecord(params['key'], params['value']);
  port.send({'result': result});
}
