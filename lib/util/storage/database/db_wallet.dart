import 'dart:core';
import 'dart:isolate';

import 'package:witnet/data_structures.dart';
import 'package:witnet/witnet.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_isolate.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/witnet/wallet/account.dart';
import 'package:witnet_wallet/util/witnet/wallet/balance_info.dart';
import 'package:witnet_wallet/util/witnet/wallet/wallet.dart';

/// DbWallet formats the wallet for the database
///
class DbWallet {
  DbWallet({
    required this.xprv,
    required this.externalXpub,
    required this.internalXpub,
    required this.walletName,
    required this.walletDescription,
    required this.externalAccounts,
    required this.internalAccounts,
    required this.lastSynced,
  }) {
    externalAccounts.forEach((int index, Account account) {
      account.setBalance();
    });
    internalAccounts.forEach((int index, Account account) {
      account.setBalance();
    });
  }

  final String walletName;
  final String walletDescription;
  final String xprv;
  final String externalXpub;
  final String internalXpub;
  int lastSynced = -1;
  Map<int, Account> externalAccounts = {};
  Map<int, Account> internalAccounts = {};
  bool nodeAddressActive = false;

  int addressCount = 0;
  Map<String, Utxo> utxoSet = {};
  void addAccount(
      {required Account account,
      required int index,
      required KeyType keyType}) {
    switch (keyType) {
      case KeyType.internal:
        internalAccounts[index] = account;
        break;
      case KeyType.external:
        externalAccounts[index] = account;
        break;
    }
  }

  Map<String, dynamic> accountMap({required KeyType keyType}) {
    switch (keyType) {
      case KeyType.internal:
        Map<String, dynamic> _int = {};
        internalAccounts.forEach((key, value) {
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

  Future<Account> generateKey(
      {required int index, KeyType keyType = KeyType.external}) async {
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
            Account(address: xpub.address, path: xpub.path!);
        return internalAccounts[index]!;
      case KeyType.external:
        externalAccounts[index] =
            Account(address: xpub.address, path: xpub.path!);
        return externalAccounts[index]!;
    }
  }

  int balanceNanoWit() {
    int _availableBalanceNanoWit = 0;
    int _lockedBalanceNanoWit = 0;

    internalAccounts.forEach((address, account) {
      BalanceInfo balanceInfo = BalanceInfo.fromUtxoList(account.utxos);
      _lockedBalanceNanoWit += balanceInfo.lockedNanoWit;
      _availableBalanceNanoWit += balanceInfo.availableNanoWit;
    });
    externalAccounts.forEach((address, account) {
      BalanceInfo balanceInfo = BalanceInfo.fromUtxoList(account.utxos);
      _lockedBalanceNanoWit += balanceInfo.lockedNanoWit;
      _availableBalanceNanoWit += balanceInfo.availableNanoWit;
    });
    return _availableBalanceNanoWit;
  }
}
