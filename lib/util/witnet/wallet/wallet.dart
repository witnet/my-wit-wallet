import 'package:witnet/constants.dart';
import 'package:witnet/witnet.dart';
import 'package:my_wit_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:my_wit_wallet/shared/locator.dart';

enum KeyType { internal, external }

class Wallet {
  final String name;

  late Xprv masterXprv;
  late Xprv walletXprv;
  late Xprv internalXprv;
  late Xprv externalXprv;
  late Xpub internalXpub;
  late Xpub externalXpub;
  final Map<int, Xpub> externalKeys = {};
  final Map<int, Xpub> internalKeys = {};

  Wallet(this.name);

  static Future<Wallet> fromMnemonic(
      {required String name, required String mnemonic}) async {
    final _wallet = Wallet(name);
    _wallet._setMasterXprv(Xprv.fromMnemonic(mnemonic: mnemonic));
    return _wallet;
  }

  static Future<Wallet> fromXprvStr(
      {required String name, required String xprv}) async {
    final _wallet = Wallet(name);
    _wallet._setMasterXprv(Xprv.fromXprv(xprv));
    return _wallet;
  }

  static Future<Wallet> fromEncryptedXprv(
      {required String name,
      required String xprv,
      required String password}) async {
    try {
      final _wallet = Wallet(name);
      _wallet._setMasterXprv(Xprv.fromEncryptedXprv(xprv, password));
      return _wallet;
    } catch (e) {
      rethrow;
    }
  }

  void _setMasterXprv(Xprv xprv) {
    masterXprv = xprv;
    walletXprv = xprv / KEYPATH_PURPOSE / KEYPATH_COIN_TYPE / KEYPATH_ACCOUNT;
    externalXprv = walletXprv / 0;
    internalXprv = walletXprv / 1;
    internalXpub = internalXprv.toXpub();
    externalXpub = externalXprv.toXpub();
  }

  Future<Xpub> generateKey(
      {required int index, KeyType keyType = KeyType.external}) async {
    Xpub xpub = await Locator.instance<CryptoIsolate>()
        .send(method: 'generateKey', params: {
      'external_keychain': externalXpub.toSlip32(),
      'internal_keychain': internalXpub.toSlip32(),
      'index': index,
      'keyType': keyType.toString()
    });

    switch (keyType) {
      case KeyType.external:
        externalKeys[index] = xpub;
        break;
      case KeyType.internal:
        internalKeys[index] = xpub;
        break;
    }
    return xpub;
  }

  Future<Xpub> getXpub({required int index, required KeyType keyType}) async {
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
