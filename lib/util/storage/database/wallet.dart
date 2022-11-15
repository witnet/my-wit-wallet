import 'dart:ffi';

import 'package:witnet/data_structures.dart';

import 'account.dart';
import 'balance_info.dart';
import 'dart:core';
import 'dart:isolate';

import 'package:witnet/constants.dart';
import 'package:witnet/witnet.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:witnet_wallet/shared/locator.dart';

enum KeyType { internal, external }

class Wallet {
  Wallet({
    required this.id,
    required this.name,
    this.description,
    this.xprv,
    this.externalXpub,
    this.internalXpub,
    required this.txHashes,
    required this.externalAccounts,
    required this.internalAccounts,
    this.lastSynced = -1,
  }) {
    this.externalAccounts.forEach((key, Account account) {
      account.setBalance();
    });

    this.internalAccounts.forEach((key, Account account) {
      account.setBalance();
    });
  }

  final String id;
  final String name;
  final String? description;
  late List<String?> txHashes;
  late String? xprv;
  late String? externalXpub;
  late String? internalXpub;

  late Xpub _internalXpub;
  late Xpub _externalXpub;

  final Map<int, Xpub> externalKeys = {};
  final Map<int, Xpub> internalKeys = {};
  int lastSynced;

  Map<int, Account> externalAccounts = {};
  Map<int, Account> internalAccounts = {};

  static Future<Wallet> fromMnemonic({
    required String id,
    required String name,
    required String description,
    required String mnemonic,
    required String password,
  }) async {
    final _wallet = Wallet(
      id: id,
      name: name,
      description: description,
      txHashes: [],
      externalAccounts: {},
      internalAccounts: {},
    );
    _wallet._setMasterXprv(Xprv.fromMnemonic(mnemonic: mnemonic), password);
    return _wallet;
  }

  static Future<Wallet> fromXprvStr({
    required String id,
    required String name,
    required String description,
    required String xprv,
    required String password,
  }) async {
    final _wallet = Wallet(
      id: id,
      name: name,
      description: description,
      xprv: xprv,
      txHashes: [],
      externalAccounts: {},
      internalAccounts: {},
    );
    _wallet._setMasterXprv(Xprv.fromXprv(xprv), password);
    return _wallet;
  }

  static Future<Wallet> fromEncryptedXprv({
    required String id,
    required String name,
    required String description,
    required String xprv,
    required String password,
  }) async {
    try {
      final _wallet = Wallet(
        id: id,
        name: name,
        description: description,
        xprv: xprv,
        txHashes: [],
        externalAccounts: {},
        internalAccounts: {},
      );
      _wallet._setMasterXprv(Xprv.fromEncryptedXprv(xprv, password), password);
      return _wallet;
    } catch (e) {
      rethrow;
    }
  }

  void _setMasterXprv(Xprv xprv, String password) {
    Xprv walletXprv =
        xprv / KEYPATH_PURPOSE / KEYPATH_COIN_TYPE / KEYPATH_ACCOUNT;
    Xprv externalXprv = walletXprv / 0;
    Xprv internalXprv = walletXprv / 1;
    this.xprv = xprv.toEncryptedXprv(password: password);
    _internalXpub = internalXprv.toXpub();
    _externalXpub = externalXprv.toXpub();

    internalXpub = _internalXpub.toSlip32();
    externalXpub = _externalXpub.toSlip32();
  }

  void addAccount({
    required Account account,
    required int index,
    required KeyType keyType,
  }) {
    switch (keyType) {
      case KeyType.internal:
        internalAccounts[index] = account;
        break;
      case KeyType.external:
        externalAccounts[index] = account;
        break;
    }
  }

  BalanceInfo balanceNanoWit() {
    List<Utxo> _utxos = [];

    internalAccounts.forEach((address, account) {
      _utxos.addAll(account.utxos);
    });
    externalAccounts.forEach((address, account) {
      _utxos.addAll(account.utxos);
    });
    return BalanceInfo.fromUtxoList(_utxos);
  }

  Future<Account> generateKey({
    required int index,
    KeyType keyType = KeyType.external,
  }) async {
    ReceivePort response = ReceivePort();
    // initialize the crypto isolate if not already done so

    await Locator.instance<CryptoIsolate>().init();
    // send the request

    Locator.instance<CryptoIsolate>().send(
        method: 'generateKey',
        params: {
          'external_keychain': externalXpub,
          'internal_keychain': internalXpub,
          'index': index,
          'keyType': keyType.toString()
        },
        port: response.sendPort);
    var xpub = await response.first.then((value) {
      return value['xpub'] as Xpub;
    });
    switch (keyType) {
      case KeyType.internal:
        internalAccounts[index] =
            Account(walletName: name, address: xpub.address, path: xpub.path!);
        return internalAccounts[index]!;
      case KeyType.external:
        externalAccounts[index] =
            Account(walletName: name, address: xpub.address, path: xpub.path!);
        return externalAccounts[index]!;
    }
  }

  Future<Account> getAccount({
    required int index,
    required KeyType keyType,
  }) async {
    switch (keyType) {
      case KeyType.internal:
        if (!internalAccounts.containsKey(index)) {
          await generateKey(index: index, keyType: keyType);
        }
        return internalAccounts[index]!;
      case KeyType.external:
        if (!externalAccounts.containsKey(index)) {
          await generateKey(index: index, keyType: keyType);
        }
        return externalAccounts[index]!;
    }
  }

  Map<String, dynamic> accountMap({
    required KeyType keyType,
  }) {
    switch (keyType) {
      case KeyType.internal:
        Map<String, dynamic> _int = {};
        internalAccounts.forEach((int key, Account value) {
          _int[value.address] = value.jsonMap();
        });
        return _int;
      case KeyType.external:
        Map<String, dynamic> _ext = {};
        externalAccounts.forEach((key, value) {
          _ext[value.address] = value.jsonMap();
        });
        return _ext;
    }
  }

  Map<String, dynamic> jsonMap() {
    return {
      'id': id,
      'name': name,
      'description': description ?? '',
      'xprv': xprv,
      'externalXpub': externalXpub,
      'internalXpub': internalXpub,
      'externalAccounts': accountMap(keyType: KeyType.external),
      'internalAccounts': accountMap(keyType: KeyType.internal),
    };
  }

  factory Wallet.fromJson(Map<String, dynamic> data) {
    Map<int, Account> _externalAccounts = {};
    Map<int, Account> _internalAccounts = {};
    if (data.containsKey('externalAccounts')) {
      for (int i = 0; i < data['externalAccounts'].keys.length; i++) {
        String account = data['externalAccounts'].keys.toList()[i];

        _externalAccounts[i] =
            Account.fromJson(data['externalAccounts'][account]);
      }
    }
    if (data.containsKey('internalAccounts')) {
      for (int i = 0; i < data['internalAccounts'].keys.length; i++) {
        String account = data['internalAccounts'].keys.toList()[i];
        _internalAccounts[i] =
            Account.fromJson(data['internalAccounts'][account]);
      }
    }

    _externalAccounts.entries.toList();
    return Wallet(
      id: data['id'] ?? data['name'],
      name: data['name'],
      description: data['description'],
      xprv: data['xprv'],
      externalXpub: data['externalXpub'],
      internalXpub: data['internalXpub'],
      txHashes: [],
      externalAccounts: _externalAccounts,
      internalAccounts: _internalAccounts,
    );
  }
}
