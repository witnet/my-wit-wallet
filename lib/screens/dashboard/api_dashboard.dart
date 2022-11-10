import 'dart:developer';

import 'package:witnet/data_structures.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';

import 'package:witnet_wallet/util/storage/database/wallet_storage.dart';

class ApiDashboard {
  WalletStorage? _walletStorage;
  //TODO: define wallet type
  var _currentWallet;
  List<Utxo> spentUtxos = [];
  ApiDashboard();

  void setWallets(WalletStorage? walletStorage) {
    this._walletStorage = walletStorage;
  }

  void setCurrentWalletData(wallet) {
    this._currentWallet = wallet;
  }

  Wallet get currentWallet => _currentWallet;
  WalletStorage? get walletStorage => _walletStorage;
}
