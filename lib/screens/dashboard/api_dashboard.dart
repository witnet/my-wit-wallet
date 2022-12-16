import 'package:witnet/data_structures.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';

import 'package:witnet_wallet/util/storage/database/wallet_storage.dart';
import 'package:witnet_wallet/widgets/address.dart';

class ApiDashboard {
  WalletStorage? _walletStorage;
  //TODO: define wallet type
  var _currentWallet;
  var _currentAddress;
  List<Utxo> spentUtxos = [];
  ApiDashboard();

  void setWallets(WalletStorage? walletStorage) {
    this._walletStorage = walletStorage;
  }

  void setCurrentAddress(Address address) {
    this._currentAddress = address;
  }

  void setCurrentWalletData(wallet) {
    this._currentWallet = wallet;
  }

  Wallet get currentWallet => _currentWallet;
  Address get currentAddress => _currentAddress;
  WalletStorage? get walletStorage => _walletStorage;
}
