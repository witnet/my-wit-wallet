import 'dart:isolate';

import 'package:witnet/data_structures.dart';
import 'package:witnet/schema.dart';
import 'package:witnet/witnet.dart';
import 'package:witnet_wallet/screens/dashboard/api_dashboard.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';

import 'package:witnet_wallet/util/storage/database/account.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';
import 'package:witnet_wallet/util/storage/database/wallet_storage.dart';
import 'crypto_bloc.dart';

enum SeedSource { mnemonic, xprv, encryptedXprv }

// used to call the isolate thread from anywhere in the main app
class ApiCrypto {
  late String? id;
  late String? walletName;
  late String? walletDescription;
  late String? seed;
  late String? seedSource;
  late String? password;
  ApiCrypto();

  void setInitialWalletData(
      String id,
      String walletName,
      String walletDescription,
      String seed,
      String seedSource,
      String password) {
    this.id = id;
    this.walletName = walletName;
    this.walletDescription = walletDescription;
    this.seed = seed;
    this.seedSource = seedSource;
    this.password = password;
  }

  void clearInitialWalletData() {
    this.walletName = null;
    this.walletDescription = null;
    this.seed = null;
    this.seedSource = null;
    this.password = null;
  }

  Future<String> generateMnemonic(int wordCount, String language) async {
    try {
      CryptoIsolate cryptoIsolate = Locator.instance<CryptoIsolate>();
      var receivePort = ReceivePort();
      await cryptoIsolate.init();
      cryptoIsolate.send(
          method: 'generateMnemonic',
          params: {
            'wordCount': wordCount,
            'language': language,
          },
          port: receivePort.sendPort
      );
      return await receivePort.first.then((value) {
        return value;
      });
    } catch (e) {
      print('Error $e');
      rethrow;
    }
  }

  Future<Account> generateAccount(
      String walletName, KeyType keyType, int index) async {
    try {
      CryptoIsolate cryptoIsolate = Locator.instance<CryptoIsolate>();

      WalletStorage walletStorage =
          Locator.instance<ApiDashboard>().walletStorage!;
      Wallet wallet = walletStorage.wallets[walletName]!;
      final receivePort = ReceivePort();

      cryptoIsolate.send(
        method: 'generateKey',
        params: {
          'keyType': 'internal',
          'external_keychain': wallet.externalXpub,
          'internal_keychain': wallet.internalXpub,
          'index': index
        },
        port: receivePort.sendPort,
      );
      Xpub xpub = await receivePort.first.then((value) {
        var val = value as Map<String, dynamic>;
        var _xpub = val['xpub'];
        return _xpub;
      });
      return Account(
          walletName: walletName, address: xpub.address, path: xpub.path!);
    } catch (e) {
      rethrow;
    }
  }

  Future<Wallet> initializeWallet() async {
    try {
      CryptoIsolate cryptoIsolate = Locator.instance.get<CryptoIsolate>();
      ApiDatabase db = Locator.instance<ApiDatabase>();
      // get master key
      String key = await db.getKeychain();

      final receivePort = ReceivePort();
      print({
        'id': walletName,
        'seedSource': seedSource,
        'walletName': walletName,
        'walletDescription': walletDescription,
        'seed': seed,
        'password': key,
      });
      cryptoIsolate.send(
          method: 'initializeWallet',
          params: {
            'id': walletName,
            'walletName': walletName,
            'walletDescription': walletDescription,
            'seedSource': seedSource,
            'seed': seed,
            'password': key,
          },
          port: receivePort.sendPort);
      clearInitialWalletData();
      Wallet dbWallet = await receivePort.first.then((value) {
        var val = value as Map<String, dynamic>;
        var _wallet = val['wallet'];
        return _wallet;
      });

      return dbWallet;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<KeyedSignature>> signTransaction(
    List<Utxo> utxos,
    WalletStorage walletStorage,
    String transactionId,
  ) async {
    Map<String, List<String>> _signers = {};

    // get master key
    ApiDatabase db = Locator.instance<ApiDatabase>();
    String key = await db.getKeychain();

    /// loop through utxos
    for (int i = 0; i < utxos.length; i++) {
      Utxo currentUtxo = utxos.elementAt(i);

      /// loop through every wallet
      for (int k = 0; k < walletStorage.wallets.length; k++) {
        Wallet currentWallet = walletStorage.wallets.values.elementAt(k);

        /// loop though every external account
        currentWallet.externalAccounts.forEach((index, account) {
          if (account.utxos.contains(currentUtxo)) {
            if (_signers.containsKey(currentWallet.xprv)) {
              _signers[currentWallet.xprv]!.add(account.path);
            } else {
              _signers[currentWallet.xprv!] = [account.path];
            }
          }
        });

        /// loop though every internal account
        currentWallet.internalAccounts.forEach((index, account) {
          if (account.utxos.contains(currentUtxo)) {
            if (_signers.containsKey(currentWallet.xprv)) {
              _signers[currentWallet.xprv]!.add(account.path);
            } else {
              _signers[currentWallet.xprv!] = [account.path];
            }
          }
        });
      }
    }
    final receivePort = ReceivePort();
    CryptoIsolate cryptoIsolate = Locator.instance.get<CryptoIsolate>();
    cryptoIsolate.send(
        method: 'signTransaction',
        params: {
          'password': key,
          'signers': _signers,
          'transaction_id': transactionId
        },
        port: receivePort.sendPort);
    List<KeyedSignature> signatures = await receivePort.first;
    return signatures;
  }
}
