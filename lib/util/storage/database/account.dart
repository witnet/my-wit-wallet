import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';

import 'balance_info.dart';
import 'dart:core';
import 'package:quiver/core.dart';

abstract class _Account {
  _Account();

  String toString();

  Map<String, dynamic> jsonMap();

  BalanceInfo balance();

  List<Utxo> utxos = [];
  int lastSynced = -1;

  int get hashCode;

  @override
  bool operator ==(Object other);
}

class Account extends _Account {
  Account(
      {required this.walletName, required this.address, required this.path});

  BalanceInfo? _balanceInfo;

  BalanceInfo balance() {
    _balanceInfo = _balanceInfo ?? BalanceInfo.fromUtxoList(utxos);
    return _balanceInfo!;
  }

  final String walletName;
  final String path;
  final String address;
  List<String> vttHashes = [];
  List<Utxo> utxos = [];

  @override
  String toString() => '{"address": $address, "path": $path}';


  factory Account.fromJson(Map<String, dynamic> data) {
    List<Utxo> _utxos =
        List<Utxo>.from(data['utxos'].map((x) => Utxo.fromJson(x)));

    Account account = Account(
      walletName: data['walletName'],
      address: data['address'],
      path: data['path'],
    );
    account.vttHashes = List<String>.from(data['value_transfer_hashes']);
    account.utxos = _utxos;
    account.lastSynced = data['last_synced'];
    return account;
  }

  Future<bool> setBalance() async {
    try {
      this.balance();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Map<String, dynamic> jsonMap() {
    List<Map<String, dynamic>> _utxos = [];
    utxos.forEach((element) {
      _utxos.add(element.jsonMap());
    });

    return {
      'walletName': walletName,
      "address": address,
      'path': path,
      'utxos': _utxos.toList(),
      'balance': balance().jsonMap(),
      'value_transfer_hashes': vttHashes.toList(),
      'last_synced': lastSynced,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is Account &&
        walletName == other.walletName &&
        address == other.address;
  }

  @override
  int get hashCode => hash4(walletName.hashCode, address.hashCode,
      vttHashes.hashCode, utxos.hashCode);
}

class NodeAccount extends Account {
  NodeAccount(String walletName, String address)
      : super(walletName: walletName, address: address, path: 'm');

  Map<String, MintInfo> mints = {};
  Map<String, dynamic> commits = {};
  Map<String, dynamic> reveals = {};
  Map<String, TallyTxn> tallies = {};
  int eligibility = 0;
  int reputation = 0;
}

List<Utxo> utxos = [];
int lastSynced = -1;
Map<String, dynamic> transactions = {
  "value_transfer_transactions": {},
  "mint_transactions": {},
  "reveal_transactions": {},
  "commit_transactions": {},
  "tally_transactions": {},
  "data_request_transactions": {},
};
