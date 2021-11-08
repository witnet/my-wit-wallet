import 'dart:isolate';

import 'package:witnet/witnet.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_isolate.dart';
import 'package:witnet_wallet/shared/locator.dart';

enum KeyType { internal, external }

class Wallet {
  final String name;
  final String? description;

  late Xprv masterXprv;
  late Xprv externalChain;
  late Xprv internalChain;
  final Map<int, Xprv> externalKeys = {};
  final Map<int, Xprv> internalKeys = {};

  Wallet(this.name, this.description);

  static Future<Wallet> fromMnemonic(
      {required String name,
      required String description,
      required String mnemonic}) async {
    final _wallet = Wallet(name, description);
    _wallet._setMasterXprv(Xprv.fromMnemonic(mnemonic: mnemonic));
    return _wallet;
  }

  static Future<Wallet> fromXprvStr(
      {required String name,
      required String description,
      required String xprv}) async {
    final _wallet = Wallet(name, description);
    _wallet._setMasterXprv(Xprv.fromXprv(xprv));
    return _wallet;
  }

  static Future<Wallet> fromEncryptedXprv(
      {required String name,
      required String description,
      required String xprv,
      required String password}) async {
    try {
      final _wallet = Wallet(name, description);
      _wallet._setMasterXprv(Xprv.fromEncryptedXprv(xprv, password));
      return _wallet;
    } catch (e) {
      rethrow;
    }
  }

  void _setMasterXprv(Xprv xprv) {
    masterXprv = xprv;
    internalChain = masterXprv / 3.0 / 4919.0 / 0.0 / 1;
    externalChain = masterXprv / 3.0 / 4919.0 / 0.0 / 0;
  }

  Future<Xprv> generateKey(
      {required int index, KeyType keyType = KeyType.external}) async {
    ReceivePort response = ReceivePort();
    // initialize the crypto isolate if not already done so

    await Locator.instance<CryptoIsolate>().init();
    // send the request

    Locator.instance<CryptoIsolate>().send(
        method: 'generateKey',
        params: {
          'keychain': masterXprv.toSlip32(),
          'index': index,
          'keyType': keyType.toString()
        },
        port: response.sendPort);
    var resp = await response.first.then((value) {
      return value['xprv'] as Xprv;
    });
    switch (keyType) {
      case KeyType.external:
        externalKeys[index] = resp;
        break;
      case KeyType.internal:
        internalKeys[index] = resp;
        break;
    }
    return resp;
  }

  Future<Xprv> getKey({required int index, required KeyType keyType}) async {
    switch (keyType) {
      case KeyType.internal:
        if (!internalKeys.containsKey(index)) {
          await generateKey(index: index, keyType: keyType);
        }
        return internalKeys[index]!;
      case KeyType.external:
        if (!externalKeys.containsKey(index)) {
          await generateKey(index: index, keyType: keyType);
        }
        return externalKeys[index]!;
    }
  }
}
