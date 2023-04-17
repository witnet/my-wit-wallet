import 'dart:convert';
import 'dart:typed_data';
import 'package:sembast/sembast.dart';
import 'package:witnet/utils.dart';

import 'package:witnet/crypto.dart';
import 'package:witnet_wallet/util/storage/database/encrypt/password.dart';

Uint8List _formatData(Uint8List data, [int length = 128, int padByte = 11]) {
  Uint8List _data = Uint8List(length);
  int padLength = _data.length - data.length;
  Uint8List padding = Uint8List(padLength);
  for (int i = 0; i < padLength; i++) {
    padding[i] = padByte;
  }
  _data.setRange(0, data.length, data);
  _data.setRange(data.length, _data.length, padding);
  return _data;
}

class KeyChain {
  final StoreRef _store = StoreRef<String, String>("keychain");
  String? keyHash;
  bool unlocked = false;

  KeyChain();
  Uint8List encode(String password, [bool debug = false]) {
    Uint8List data =
        Uint8List.fromList('{"WITNET":"${Password.hash(password)}"}'.codeUnits);
    Uint8List dat = _formatData(data);
    Uint8List _iv = generateIV();
    Uint8List _salt = generateSalt();
    CodecAES codec = getCodecAES(password, salt: _salt, iv: _iv);
    Uint8List encoded = hexToBytes(codec.encode(dat));
    Uint8List encodedData = concatBytes([_iv, _salt, encoded]);
    keyHash = Password.hash(password);
    if (debug) {
      print('${bytesToHex(_iv)} ${bytesToHex(_salt)} ${bytesToHex(encoded)}');
    }

    return encodedData;
  }

  String? decode(String encoded, String password) {
    Uint8List dat = Uint8List.fromList(hexToBytes(encoded));

    Uint8List iv = dat.sublist(0, 16);
    Uint8List salt = dat.sublist(16, 48);
    Uint8List data = dat.sublist(48);

    CodecAES codec = getCodecAES(password, salt: salt, iv: iv);
    Uint8List decoded = codec.decode(bytesToHex(data)) as Uint8List;

    String plainText;

    try {
      plainText = utf8.decode(decoded).trim();
      keyHash = json.decode(plainText)['WITNET'];
      return plainText;
    } catch (e) {
      return null;
    }
  }

  Future<bool> validatePassword(String encoded, String password) async {
    unlocked = (decode(encoded, password) == null) ? false : true;
    return unlocked;
  }

  Future<bool> keyExists(DatabaseClient databaseClient) async {
    bool exists = false;
    try {
      var value = await _store.record('keychain').get(databaseClient);

      if (value != null) {
        exists = true;
      }
    } catch (e) {
      return false;
    }
    return exists;
  }

  Future<String> getKey(DatabaseClient databaseClient) async {
    return await _store.record('keychain').get(databaseClient) as String;
  }

  Future<bool> setKey(
      {String? oldPassword,
      required String newPassword,
      required DatabaseClient databaseClient}) async {
    bool exists = await keyExists(databaseClient);
    String encodedKey = bytesToHex(encode(newPassword));
    if (exists) {
      String key = await getKey(databaseClient);
      bool valid = await validatePassword(key, oldPassword!);
      if (!valid) {
        return false;
      }

      await _store.record('keychain').add(databaseClient, encodedKey);
    } else {
      await _store.record('keychain').add(databaseClient, encodedKey);
    }
    return true;
  }
}
