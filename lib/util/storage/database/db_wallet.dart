
import 'dart:core';

import 'package:witnet/data_structures.dart';
import 'package:witnet_wallet/util/witnet/wallet/account.dart';
import 'package:witnet_wallet/util/witnet/wallet/wallet.dart';


/// DbWallet formats the wallet for the database
///
class DbWallet {
  DbWallet({
    required this.xprv,
    required this.externalXpub,
    required this.internalXpub,
    required this.walletName,
    required this.walletDescription,
    required this.externalAccounts,
    required this.internalAccounts,
    required this.lastSynced,

  }){
   externalAccounts.forEach((int index, Account account) {
     account.setBalance();
     balance += account.balance;
   });
   internalAccounts.forEach((int index, Account account) {
     account.setBalance();
     balance += account.balance;
   });
  }

  final String walletName;
  final String walletDescription;
  final String xprv;
  final String externalXpub;
  final String internalXpub;
  int lastSynced = -1;
  Map<int, Account> externalAccounts = {};
  Map<int, Account> internalAccounts = {};
  bool nodeAddressActive = false;
  int balance = 0;
  int addressCount = 0;
  Map<String, Utxo> utxoSet = {};
  void addAccount({required Account account, required int index, required KeyType keyType}){
    switch (keyType){
      case KeyType.internal:
        internalAccounts[index] = account;
        break;
      case KeyType.external:
        externalAccounts[index] = account;
        break;
    }

  }

  Map<String, dynamic> accountMap({required KeyType keyType})  {
    switch (keyType){
      case KeyType.internal:
        Map<String, dynamic> _int = {};
        internalAccounts.forEach((key, value) {
          _int[value.address] = value.jsonMap();
        });
        return _int;
      case KeyType.external:
        Map<String, dynamic> _ext = {};
        externalAccounts.forEach((key, value) {
          _ext[value.address] = value.jsonMap();
        });
        return _ext;
    }
  }
}
