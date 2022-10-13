import 'package:witnet/data_structures.dart';

import 'package:witnet_wallet/util/storage/database/wallet_storage.dart';

class ApiDashboard {

  WalletStorage? _walletStorage;
  List<Utxo> spentUtxos = [];
  ApiDashboard();

  void setWallets(WalletStorage? walletStorage){
    this._walletStorage = walletStorage;
  }

  WalletStorage? get walletStorage => _walletStorage;

}