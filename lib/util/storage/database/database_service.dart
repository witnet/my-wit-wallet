import 'dart:async';

import 'package:sembast/blob.dart';
import 'package:witnet/witnet.dart';

import '../../../constants.dart';
import '../path_provider_interface.dart';
import 'encrypt/salsa20/codec.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast.dart';

class _DBConfiguration {
  String path;
  late SembastCodec codec;
  int timeout = 300;

  _DBConfiguration({required this.path, required String password}){
   if (ENCRYPT_DB == true){
     codec = getSembastCodecSalsa20(password: password);
   }
  }

  String get name => this.path.split('/').last;
}

class DBException {
  final int code;
  final String message;
  DBException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => '{"DBException": {"code": $code, "message": $message}}';
}

class DBService {
  //singleton
  static final DBService _dbService = DBService._internal();
  DBService._internal();

  factory DBService() {
    return DBService._dbService;
  }

  late DatabaseMode mode;
  bool initialized = false;
  late Database _database;

  Database get db => _database;

  _DBConfiguration? _dbConfig;
  DatabaseFactory dbFactory = databaseFactoryIo;
  bool unlocked = false;
  factory DBService.db() {
    return _dbService;
  }

  FutureOr<dynamic> unlockWallet(String name, String password) async {
    try {
      _dbService._dbConfig = _DBConfiguration(path: name, password: password);
      _dbService.configure(path: name, password: password);
      String response = await _dbService.openDatabase();
      return response;
    } on DBException catch (e) {
      return DBException(code: -1, message: e.message);
    }
  }

  Future<String> _initDatabase() async {
    try {
      PathProviderInterface interface = PathProviderInterface();
      var fileExists = await interface.fileExists(_dbService._dbConfig!.path);
      DatabaseMode mode;
      if (fileExists) {
        mode = DatabaseMode.existing;
      } else {
        mode = DatabaseMode.create;
      }
      String dbError = '';


      try {
        if(ENCRYPT_DB){
          _dbService._database = await dbFactory.openDatabase(
            _dbService._dbConfig!.path,
            version: 2,
            codec: _dbService._dbConfig!.codec,
            mode: mode,
          )
              .catchError((error) {
            dbError = error.toString();

            /// codes for Sembast Database Exception
            /// [0] bad parameters
            /// [1] not found
            /// [2] invalid codec signature
            /// [3] action failed because db is closed
            throw DBException(code: error.code, message: error.message);
          });
        } else {
          _dbService._database = await dbFactory.openDatabase(
            _dbService._dbConfig!.path,
            version: 2,
            mode: mode,
          ).catchError((error) {
            dbError = error.toString();

            /// codes for Sembast Database Exception
            /// [0] bad parameters
            /// [1] not found
            /// [2] invalid codec signature
            /// [3] action failed because db is closed
            throw DBException(code: error.code, message: error.message);
          });
        }
        _dbService._database = await dbFactory.openDatabase(
          _dbService._dbConfig!.path,
          version: 2,
          mode: mode,
        ).catchError((error) {
          dbError = error.toString();
          throw DBException(code: error.code, message: error.message);
        });
      } on TypeError catch (e) {
        dbError = ' ->${e.toString()}';
        throw DBException(code: -1, message: 'Unable to unlock Wallet.');
      } on DBException {
        rethrow;
      }
      if (dbError != '') {
        throw DBException(code: -2, message: 'Unable to unlock Wallet.');
      } else {


        // Xprv.fromEncryptedXprv('xprv', 'password');
        _dbService.unlocked = true;
      }
      return dbError;
    } on DBException {
      rethrow;
    }
  }

  void dispose() {
    _database.close();
    _dbService._database.close();
    _dbService._dbConfig = null;
    _dbService.dispose();
  }

  void lockDatabase() {
    _database.close();
    _dbService._dbConfig = null;
  }

  Future<void> configure(
      {required String path, required String password}) async {
    if (_dbConfig == null) {
      _dbConfig = _DBConfiguration(path: path, password: password);
    } else {
      _dbConfig = null;
      _dbConfig = _DBConfiguration(path: path, password: password);
    }
  }

  Future<String> openDatabase() async {
    try {
      return await _initDatabase();
    } on DBException {
      rethrow;
    }
  }

  Future<dynamic> writeRecord(dynamic key, dynamic value) async {
    if (unlocked) {
      var store = StoreRef.main();
      assert(key.runtimeType == String || key.runtimeType == int,
          'Key value Must be int or String.');
      await store.record(key).put(_database, value,merge: false);

    } else {
      throw DBException(code: -5, message: 'unable to write $key. $value');
    }
  }

  Future<int> readInt(dynamic key) async {
    return await readRecord(key, int) as int;
  }

  Future<double> readDouble(dynamic key) async {
    return await readRecord(key, double) as double;
  }

  Future<Map<String, Object?>> readMap(dynamic key) async {
    return await readRecord(key, Map) as Map<String, Object?>;
  }

  Future<bool> readBool(dynamic key) async {
    return await readRecord(key, bool) as bool;
  }

  Future<Blob> readBlob(dynamic key) async {
    return await readRecord(key, Blob) as Blob;
  }

  Future<String?> readString(dynamic key) async {
    try {
      return await readRecord(key, String) as String;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> readRecord(dynamic key, Type type) async {
    if (unlocked) {
      final store = StoreRef.main();
      final value = await store.record(key).get(_database);
      if (value == null)
        throw DBException(code: -2, message: 'item $key is not is database.');
      return value;
    } else {
      throw DBException(code: -2, message: 'Database is not unlocked');
    }
  }

  Future<bool> deleteRecord(dynamic key) async {
    if (unlocked) {
      try {
        final store = StoreRef.main();
        // get the records reference
        final record = store.record(key);
        // delete the record
        await record.delete(db);
        // return success
        return true;
      } catch (e) {
        throw DBException(code: -2, message: 'Database Error: ${e.toString()}');
      }
    } else {
      throw DBException(code: -2, message: 'Database is not unlocked');
    }
  }
}
