import 'package:witnet/crypto.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/utils.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/util/storage/database/wallet_storage.dart';
import 'account.dart';
import 'balance_info.dart';
import 'dart:core';
import 'dart:isolate';

import 'package:witnet/constants.dart';
import 'package:witnet/witnet.dart';
import 'package:my_wit_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:my_wit_wallet/shared/locator.dart';

enum KeyType { internal, external }

class Wallet {
  Wallet({
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
    this.id = '00000000';
    this.externalAccounts.forEach((key, Account account) {
      account.setBalance();
    });

    this.internalAccounts.forEach((key, Account account) {
      account.setBalance();
    });
  }

  late String id;
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

  Map<String, Account> accountMap(KeyType keyType) {
    Map<String, Account> _accounts = {};
    switch (keyType) {
      case KeyType.internal:
        orderAccountsByIndex(internalAccounts).forEach((index, account) {
          _accounts[account.address] = account;
        });
        break;
      case KeyType.external:
        orderAccountsByIndex(externalAccounts).forEach((index, account) {
          _accounts[account.address] = account;
        });
        break;
    }
    return _accounts;
  }

  Map<int, Account> orderAccountsByIndex(Map<int, Account> accountMap) {
    return Map.fromEntries(accountMap.entries.toList()
      ..sort((e1, e2) => e1.key.compareTo(e2.key)));
  }

  List<String> addressList(KeyType keyType) {
    List<String> addresses = [];
    if (keyType == KeyType.external) {
      addresses.addAll(Iterable<String>.generate(
          externalAccounts.length, (i) => externalAccounts[i]!.address));
    } else {
      addresses.addAll(Iterable<String>.generate(
          internalAccounts.length, (i) => internalAccounts[i]!.address));
    }
    return addresses;
  }

  List<String> allAddresses() {
    List<String> _addresses = [];
    _addresses.addAll(addressList(KeyType.external));
    _addresses.addAll(addressList(KeyType.internal));
    return _addresses;
  }

  Map<String, Account> allAccounts() {
    Map<String, Account> _accounts = {};
    _accounts.addAll(accountMap(KeyType.external));
    _accounts.addAll(accountMap(KeyType.internal));
    return _accounts;
  }

  List<ValueTransferInfo> allTransactions() {
    Map<String, ValueTransferInfo> _vttMap = {};
    externalAccounts.forEach((key, account) {
      account.vtts.forEach((vtt) {
        _vttMap[vtt.txnHash] = vtt;
      });
    });
    internalAccounts.forEach((key, account) {
      account.vtts.forEach((vtt) {
        _vttMap[vtt.txnHash] = vtt;
      });
    });
    return _vttMap.values.toList();
  }

  Account? accountByAddress(String address) {
    List<Account> _accounts = allAccounts().values.toList();

    try {
      _accounts.retainWhere((element) => element.address == address);
      return _accounts[0];
    } catch (e) {
      return null;
    }
  }

  static Future<Wallet> fromMnemonic({
    required String name,
    required String description,
    required String mnemonic,
    required String password,
  }) async {
    final _wallet = Wallet(
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
    required String name,
    required String description,
    required String xprv,
    required String password,
  }) async {
    final _wallet = Wallet(
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
    required String name,
    required String description,
    required String xprv,
    required String password,
  }) async {
    try {
      final _wallet = Wallet(
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

    this.internalXpub = _internalXpub.toSlip32();
    this.externalXpub = _externalXpub.toSlip32();

    /// The Wallet ID is the first 4 bytes of the sha256 hash of the Extended Public Key.
    this.id = bytesToHex(sha256(data: Xpub.fromXpub(externalXpub!).key))
        .substring(0, 8);
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
    // send the request
    Locator.instance<CryptoIsolate>().send(
        method: 'generateKey',
        params: {
          'external_keychain': externalXpub,
          'internal_keychain': internalXpub,
          'index': index,
          'keyType': keyType.name
        },
        port: response.sendPort);
    var xpub = await response.first.then((value) {
      return value['xpub'] as Xpub;
    });
    Account _account =
        Account(walletName: name, address: xpub.address, path: xpub.path!);
    _account.walletId = id;
    switch (keyType) {
      case KeyType.internal:
        {
          internalAccounts[index] = _account;
          return internalAccounts[index]!;
        }
      case KeyType.external:
        {
          externalAccounts[index] = _account;
          return externalAccounts[index]!;
        }
    }
  }

  Account getAccount({
    required int index,
    required KeyType keyType,
  }) {
    try {
      switch (keyType) {
        case KeyType.internal:
          return internalAccounts[index]!;
        case KeyType.external:
          return externalAccounts[index]!;
      }
    } catch (e) {
      return defaultAccount;
    }
  }

  Future<Account> updateAccount({
    required int index,
    required KeyType keyType,
    required Account account,
  }) async {
    ApiDatabase db = Locator.instance<ApiDatabase>();
    switch (keyType) {
      case KeyType.internal:
        if (!internalAccounts.containsKey(index)) {
          await generateKey(index: index, keyType: keyType);
        }
        internalAccounts[index] = account;
        await db.updateAccount(account);
        return internalAccounts[index]!;
      case KeyType.external:
        if (!externalAccounts.containsKey(index)) {
          await generateKey(index: index, keyType: keyType);
        }
        externalAccounts[index] = account;
        await db.updateAccount(account);
        return externalAccounts[index]!;
    }
  }

  Map<String, dynamic> accountMapByIndex({
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
      'externalAccounts': accountMapByIndex(keyType: KeyType.external),
      'internalAccounts': accountMapByIndex(keyType: KeyType.internal),
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

    String _id =
        bytesToHex(sha256(data: Xpub.fromXpub(data['externalXpub']).key))
            .substring(0, 8);
    Wallet _wallet = Wallet(
      name: data['name'],
      description: data['description'],
      xprv: data['xprv'],
      externalXpub: data['externalXpub'],
      internalXpub: data['internalXpub'],
      txHashes: [],
      externalAccounts: _externalAccounts,
      internalAccounts: _internalAccounts,
    );

    _wallet.id = _id;
    return _wallet;
  }

  Future<bool> ensureGapLimit() async {
    try {
      /// if the gap limit is not maintained then generate additional accounts
      int lastExternalIndex = externalAccounts.length;
      int externalGap = 0;
      int internalGap = 0;

      /// check the current external gap between used accounts and the last empty account
      for (int i = 0; i < externalAccounts.length; i++) {
        final Account currentAccount = externalAccounts[i]!;
        if (currentAccount.vttHashes.length > 0) {
          externalGap = 0;
        } else {
          externalGap += 1;
        }
      }

      /// generate new external keys until the EXTERNAL_GAP_LIMIT is reached
      while (externalGap < EXTERNAL_GAP_LIMIT) {
        Account _account = await generateKey(
          index: lastExternalIndex,
          keyType: KeyType.external,
        );
        await Locator.instance<ApiDatabase>().addAccount(_account);
        lastExternalIndex += 1;
        externalGap += 1;
      }

      /// check the current internal gap between used accounts and the last empty account
      for (int i = 0; i < internalAccounts.length; i++) {
        final Account currentAccount = internalAccounts[i]!;
        if (currentAccount.vttHashes.length > 0) {
          internalGap = 0;
        } else {
          internalGap += 1;
        }
      }

      int lastInternalIndex = internalAccounts.length;

      /// generate new internal keys until the INTERNAL_GAP_LIMIT is reached
      while (internalGap < INTERNAL_GAP_LIMIT) {
        Account _account = await generateKey(
          index: lastInternalIndex,
          keyType: KeyType.internal,
        );
        await Locator.instance<ApiDatabase>().addAccount(_account);
        lastInternalIndex += 1;
        internalGap += 1;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  void setAccount(Account account) {
    if (account.keyType == KeyType.external) {
      externalAccounts[account.index] = account;
    } else {
      internalAccounts[account.index] = account;
    }
  }

  bool containsAccount(String address) {
    bool response = false;
    externalAccounts.forEach((key, value) {
      if (value.address == address) response = true;
    });
    internalAccounts.forEach((key, value) {
      if (value.address == address) response = true;
    });
    return response;
  }

  void setTransaction(ValueTransferInfo vtt) {
    List<String> _extAddressList = addressList(KeyType.external);
    List<String> _intAddressList = addressList(KeyType.internal);
    List<String> updatedAccounts = [];
    print(_extAddressList);
    for (int i = 0; i < _extAddressList.length; i++) {
      Account account = externalAccounts[i]!;
      if (vtt.containsAddress(account.address)) {
        account.addVtt(vtt);
        externalAccounts[i] = account;
        updatedAccounts.add(account.address);
      }
    }
    for (int i = 0; i < _intAddressList.length; i++) {
      Account account = internalAccounts[i]!;
      if (vtt.containsAddress(account.address)) {
        account.addVtt(vtt);
        internalAccounts[i] = account;
        updatedAccounts.add(account.address);
      }
    }
  }

  void printDebug() {
    print('Wallet');
    print(' ID: $id');
    print(' name: $name');
    print(' description: $description');
    print(' vtt count: ${txHashes.length}');

    print(' External Accounts:');

    externalAccounts.forEach((key, value) {
      print('  ${value.path}\t${value.address} ');
    });
    print(' Internal Accounts:');
    internalAccounts.forEach((key, value) {
      print('  ${value.path}\t${value.address} ');
    });
  }
}
