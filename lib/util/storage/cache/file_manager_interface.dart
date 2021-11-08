import 'dart:convert';
import 'dart:io' as io;
import 'package:sembast/timestamp.dart';
import 'package:witnet/explorer.dart';

import '../path_provider_interface.dart';

class TransactionCache {
  String _fileName = 'value_transfers';
  String _fileExtension = 'json';
  static final TransactionCache _cache = TransactionCache._internal();

  factory TransactionCache() => _cache;

  TransactionCache._internal();

  Map<String, ValueTransferInfo> transactions = {};

  final PathProviderInterface ppi = PathProviderInterface();

  Future<io.File> get _localFile async =>
      await ppi.localFile(name: _fileName, extension: _fileExtension);

  Future<Map<String, dynamic>> _readFile() async {
    try {
      final io.File file = await _localFile;
      final String contents = await file.readAsString();
      return json.decode(contents);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> init() async {
    try {
      final io.File file = await _localFile;
      if (!await file.exists()) {
      } else {
        final Map<String, dynamic> data = await _readFile();
      }
    } on io.FileSystemException catch (e) {
      if (e.osError!.errorCode == 2) {}
      rethrow;
    }
  }

  bool containsHash(String hash) {
    return transactions.containsKey(hash);
  }

  ValueTransferInfo getVtt(String transactionID) {
    try {
      return transactions[transactionID]!;
    } catch (e) {
      rethrow;
    }
  }

  void addVtt(ValueTransferInfo vti) {
    transactions[vti.txnHash] = vti;
  }

  Future<Map<String, dynamic>> getValue(String key) async {
    try {
      final Map<String, dynamic> data = await _readFile();
      return data[key];
    } catch (error) {
      rethrow;
    }
  }

  String get rawJson => json.encode(jsonMap);

  Map<String, dynamic> get jsonMap {
    final Map<String, dynamic> data = {};
    transactions.forEach((key, value) {
      data[key] = value.jsonMap();
    });
    return data;
  }

  Future<bool> updateCache() async {
    try {
      final io.File file = await _localFile;
      file.writeAsBytes(rawJson.codeUnits);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> clearCache() async {
    try {
      final io.File file = await _localFile;
      file.writeAsString('{}');
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
