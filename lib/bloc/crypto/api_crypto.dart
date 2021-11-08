import 'dart:isolate';

import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/witnet/wallet/wallet.dart';

import 'crypto_isolate.dart';

enum SeedSource { mnemonic, xprv, encryptedXprv }

class ApiCrypto {
  late String walletName;
  late String walletDescription;
  late String seed;
  late String seedSource;
  late String password;
  ApiCrypto();

  void setInitialWalletData(String walletName, String walletDescription,
      String seed, String seedSource, String password) {
    this.walletName = walletName;
    this.walletDescription = walletDescription;
    this.seed = seed;
    this.seedSource = seedSource;
    this.password = password;
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
      print(e);
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
