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
    SendPort replyToPort = msg[1];
    var method = data.split('?')[0];
    var params = json.decode(data.split('?')[1]);
    switch (method) {
      case 'unlockDatabase':
        var tmp =
            await dbService.unlockWallet(params['path'], params['password']);
        if (tmp.runtimeType == DBException) {
          replyToPort.send(tmp);
        }
        replyToPort.send({'unlocked': true});
        break;
      case 'configure':
        dbService.configure(path: params['path'], password: params['password']);
        replyToPort.send({'unlocked': true});
        break;
      case 'readRecord':
        if (params['type'] == 'String') {
          var value = await dbService.readString(params['key']);
          replyToPort.send(value);
        } else if (params['type'] == 'Map<dynamic, dynamic>') {
          var value = await dbService.readMap(params['key']);
          replyToPort.send(value);
        }
        break;
      case 'getDatabaseService':
        replyToPort.send({'dbService': dbService});
        break;
      case 'batchRead':
        var readStack = params['read_ops'] as List<Map<String, Type>>;
        var results = [];
        readStack.forEach((op) async {
          results.add(await dbService.readRecord(op['key']!, op['type']!));
        });
        replyToPort.send({'results': results});
        break;
      case 'writeRecord':
        var result =
            await dbService.writeRecord(params['key'], params['value']);
        replyToPort.send({'result': result});
    }
  }
}
