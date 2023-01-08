import 'package:witnet/data_structures.dart';
import 'package:witnet_wallet/util/storage/database/account.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';

import 'package:witnet_wallet/util/storage/database/wallet_storage.dart';

class ApiDashboard {
  WalletStorage? _walletStorage;
  //TODO: define wallet type
  Wallet? _currentWallet;
  Account? _currentAccount;
  List<Utxo> spentUtxos = [];
  ApiDashboard();

  void setWallets(WalletStorage? walletStorage) {
    this._walletStorage = walletStorage;
  }

  void setCurrentAccount(Account account) {
    this._currentAccount = account;
  }

  void setCurrentWalletData(wallet) {
    this._currentWallet = wallet;
  }
  Wallet? get currentWallet => _currentWallet;
  set currentWallet(Wallet? wallet) {
    _currentWallet = wallet;
  }

  Account? get currentAccount => _currentAccount;
  WalletStorage? get walletStorage => _walletStorage;
}
