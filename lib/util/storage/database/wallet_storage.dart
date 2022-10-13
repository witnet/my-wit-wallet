import 'package:witnet/data_structures.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';

import 'balance_info.dart';

/// DbWallet formats the wallet for the database
///
class WalletStorage {
  WalletStorage({
    required this.wallets,
    required this.lastSynced,
  });

  int lastSynced = -1;
  bool nodeAddressActive = false;

  int addressCount = 0;
  Map<String, Utxo> utxoSet = {};
  Map<String, Wallet> wallets;

  void addWallet({required Wallet wallet}) {}


  BalanceInfo balanceNanoWit() {
    List<Utxo> _utxos = [];

    for (int i = 0; i < wallets.length; i++) {
      Wallet currentWallet = wallets.values.elementAt(i);

      currentWallet.internalAccounts.forEach((key, account) {
        _utxos.addAll(account.utxos);
      });
      currentWallet.externalAccounts.forEach((key, account) {
        _utxos.addAll(account.utxos);
      });
    }
    return BalanceInfo.fromUtxoList(_utxos);
  }
}
