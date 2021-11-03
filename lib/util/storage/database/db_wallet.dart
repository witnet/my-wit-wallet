import 'dart:core';
import 'dart:isolate';

import 'package:witnet_wallet/bloc/crypto/crypto_isolate.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/witnet/wallet/wallet.dart';

class DbWallet {
  DbWallet({
    required this.walletName,
    required this.walletDescription,
  });

  final String walletName;
  final String walletDescription;
  String? encryptedMasterXprv;
  late String? masterXprv;
  bool nodeAddressActive = false;
  WalletAddress? nodeAddress;
  List<WalletAddress> externalAddresses = [];
  List<WalletAddress> internalAddresses = [];

  void initialSetup(
      {required String seedSource,
      required String seed,
      String? password}) async {
    /*
    ran one time at wallet creation.
    the rest of the time the wallet is synced.

    generate all addresses and randomize order of query to exporer
     */
    Wallet wallet = Wallet(walletName, walletDescription);
    CryptoIsolate cryptoIsolate = Locator.instance<CryptoIsolate>();
    final receivePort = ReceivePort();
    await cryptoIsolate.init();

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
  }
}

class WalletAddress {
  WalletAddress(this.address, this.path);

  String address;
  String path;
  int? lastBlockSynced;

  List<String> transactions = [];
}
