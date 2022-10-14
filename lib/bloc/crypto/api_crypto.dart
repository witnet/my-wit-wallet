import 'dart:isolate';

import 'package:witnet/witnet.dart';
import 'package:witnet_wallet/screens/dashboard/api_dashboard.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/storage/database/db_wallet.dart';
import 'package:witnet_wallet/util/witnet/wallet/account.dart';
import 'package:witnet_wallet/util/witnet/wallet/wallet.dart';

import 'crypto_bloc.dart';

enum SeedSource { mnemonic, xprv, encryptedXprv }

class ApiCrypto {
  late String? walletName;
  late String? walletDescription;
  late String? seed;
  late String? seedSource;
  late String? password;
  ApiCrypto();

  void setInitialWalletData(String walletName, String walletDescription,
      String seed, String seedSource, String password) {
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
          port: receivePort.sendPort);
      String mnemonic = await receivePort.first.then((value) {
        return value;
      });
      return mnemonic;
    } catch (e) {
      rethrow;
    }
  }

  Future<Account> generateAccount(KeyType keyType, int index) async {
    try {
      CryptoIsolate cryptoIsolate = Locator.instance<CryptoIsolate>();

      DbWallet dbWallet = Locator.instance<ApiDashboard>().dbWallet!;

      final receivePort = ReceivePort();

      cryptoIsolate.send(
        method: 'generateKey',
        params: {
          'keyType': 'internal',
          'external_keychain': dbWallet.externalXpub,
          'internal_keychain': dbWallet.internalXpub,
          'index': index
        },
        port: receivePort.sendPort,
      );
      Xpub xpub = await receivePort.first.then((value) {
        var val = value as Map<String, dynamic>;
        var _xpub = val['xpub'];
        return _xpub;
      });
      return Account(address: xpub.address, path: xpub.path!);
    } catch (e) {
      rethrow;
    }
  }

  Future<Wallet> initializeWallet() async {
    try {
      CryptoIsolate cryptoIsolate = Locator.instance<CryptoIsolate>();

      final receivePort = ReceivePort();

      cryptoIsolate.send(
          method: 'initializeWallet',
          params: {
            'seedSource': seedSource,
            'walletName': walletName,
            'walletDescription': walletDescription,
            'seed': seed,
            'password': password,
          },
          port: receivePort.sendPort);

      Wallet wallet = await receivePort.first.then((value) {
        var val = value as Map<String, dynamic>;
        var _wallet = val['wallet'];
        return _wallet;
      });
      return wallet;
    } catch (e) {
      rethrow;
    }
  }
}
