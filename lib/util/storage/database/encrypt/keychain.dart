import 'package:my_wit_wallet/bloc/crypto/api_crypto.dart';
import 'package:sembast/sembast.dart';

import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/database_service.dart';

ApiCrypto apiCrypto = Locator.instance.get<ApiCrypto>();
DatabaseClient databaseClient =
    Locator.instance.get<DatabaseService>().database;

class KeyChain {
  final StoreRef _store = StoreRef<String, String>("keychain");
  String? keyHash;
  bool unlocked = false;

  KeyChain();
  Future<String> encode(String password, [bool debug = false]) async {
    return await apiCrypto.encodeKeychain(password: password);
  }

  Future<String?> decode(String encoded, String password) async {
    String encoded = await encode(password);
    String? decoded =
        await apiCrypto.decodeKeychain(encoded: encoded, password: password);
    return decoded;
  }

  Future<bool> validatePassword(
      String xprv, String encoded, String password) async {
    String? valid = await decode(encoded, password);
    unlocked = valid != null ? true : false;
    return unlocked;
  }

  Future<bool> keyExists() async {
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

  Future<String> getKey() async {
    Object? result = await _store.record('keychain').get(databaseClient);
    try {
      return result as String;
    } catch (e) {
      return '';
    }
  }

  Future<bool> setKey(
      String xprv, String newPassword, String? oldPassword) async {
    bool exists = await keyExists();
    String encodedKey = await encode(newPassword);
    if (exists) {
      String key = await getKey();
      bool valid = await validatePassword(xprv, key, oldPassword!);
      if (!valid) {
        return false;
      }
    }
    await _store.record('keychain').add(databaseClient, encodedKey);
    return true;
  }
}
