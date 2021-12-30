

import 'package:witnet/data_structures.dart';
import 'package:witnet_wallet/util/storage/database/db_wallet.dart';

class ApiDashboard {

  DbWallet? _dbWallet;
  List<Utxo> spentUtxos = [];
  ApiDashboard();

  void setDbWallet(DbWallet? dbWallet){
    this._dbWallet = dbWallet;
  }

  DbWallet? get dbWallet => _dbWallet;

}