import 'dart:convert';
import 'dart:core';
import 'dart:isolate';

import 'package:witnet/data_structures.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_isolate.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/witnet/wallet/account.dart';
import 'package:witnet_wallet/util/witnet/wallet/wallet.dart';

class DbWallet {
  DbWallet({
    required this.xprv,
    required this.walletName,
    required this.walletDescription,
    required this.externalAccounts,
    required this.internalAccounts,

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
