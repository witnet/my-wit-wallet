import 'dart:core';

import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/transaction_adapter.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/util/utxo_list_to_string.dart';
import 'package:quiver/core.dart';

import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';
import 'balance_info.dart';

abstract class _Account {
  _Account();

  String toString();

  Map<String, dynamic> jsonMap();

  List<Utxo> utxos = [];
  List<ValueTransferInfo> vtts = [];
  List<MintEntry> mints = [];

  int get hashCode;

  @override
  bool operator ==(Object other);
}

int pathToIndex(int depth, String path) =>
    path.contains("/") ? int.parse(path.split('/')[depth]) : 0;

class Account extends _Account {
  Account(
      {required this.walletName, required this.address, required this.path});

  BalanceInfo? _balanceInfo;

  BalanceInfo get balance {
    _balanceInfo = _balanceInfo ?? BalanceInfo.fromUtxoList(utxos);
    return _balanceInfo!;
  }

  late final String walletId;
  final String walletName;
  final String path;

  int get index => pathToIndex(5, path);

  KeyType get keyType {
    if (path.contains("/")) {
      return (pathToIndex(4, path) == 0) ? KeyType.external : KeyType.internal;
    }
    return KeyType.master;
  }

  final String address;
  List<String> vttHashes = [];
  List<String> mintHashes = [];

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
    account.walletId = data['walletId'];
    account.vttHashes = List<String>.from(data['value_transfer_hashes']);
    if (data.containsKey("mint_hashes")) {
      account.mintHashes = List<String>.from(data['mint_hashes']);
    } else {
      account.mintHashes = [];
    }

    account.utxos = _utxos;
    return account;
  }

  Future<bool> setBalance() async {
    try {
      this.balance;
      return true;
    } catch (e) {
      return false;
    }
  }

  bool updateUtxos(List<Utxo> newUtxos) {
    if (!isTheSameList(utxos, newUtxos)) {
      if (newUtxos.isNotEmpty) {
        utxos.clear();
        utxos.addAll(newUtxos);
      } else {
        utxos.clear();
      }
    }
    return true;
  }

  bool setVtts(List<ValueTransferInfo> allVtts) {
    vtts.clear();
    try {
      allVtts.forEach((vtt) {
        if (vtt.containsAddress(address)) {
          vtts.add(vtt);
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  bool sameUtxoList(List<Utxo> utxoList) {
    int currentLength = this.utxos.length;
    int newLength = utxoList.length;
    bool isSameList = true;
    if (currentLength == newLength) {
      utxoList.forEach((element) {
        bool containsUtxo =
            rawJsonUtxosList(this.utxos).contains(element.toRawJson());
        if (!containsUtxo) {
          isSameList = false;
        }
      });
    } else {
      isSameList = false;
    }
    return isSameList;
  }

  Future<bool> addMint(MintEntry mintEntry) async {
    try {
      ApiDatabase database = Locator.instance<ApiDatabase>();
      mintHashes.add(mintEntry.blockHash);
      mints.add(mintEntry);
      await database.addMint(mintEntry);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addVtt(ValueTransferInfo vtt) async {
    ApiDatabase database = Locator.instance<ApiDatabase>();
    bool addedVtt = false;
    vtt.inputs.forEach((input) {
      if (input.address == address) {
        if (!addedVtt) {
          vttHashes.add(vtt.txnHash);
          vtts.add(vtt);
        }
      }
    });
    vtt.outputs.forEach((output) {
      if (output.pkh.address == address) {
        if (!addedVtt) {
          vttHashes.add(vtt.txnHash);
          vtts.add(vtt);
        }
      }
    });
    if (await database.getVtt(vtt.txnHash) == null) {
      await database.addVtt(vtt);
    } else {
      await database.updateVtt(this.walletId, vtt);
    }
    await database.updateAccount(this);
    return addedVtt;
  }

  Future<bool> deleteVtt(ValueTransferInfo vtt) async {
    ApiDatabase database = Locator.instance<ApiDatabase>();
    try {
      vttHashes.removeWhere((hash) => hash == vtt.txnHash);
      vtts.removeWhere((_vtt) => _vtt.txnHash == vtt.txnHash);
      await database.updateAccount(this);
    } catch (e) {
      return false;
    }
    return true;
  }

  @override
  Map<String, dynamic> jsonMap() {
    List<Map<String, dynamic>> _utxos = [];
    utxos.forEach((element) {
      _utxos.add(element.jsonMap());
    });

    return {
      'walletId': walletId,
      'walletName': walletName,
      "address": address,
      'path': path,
      'utxos': _utxos.toList(),
      'balance': balance.jsonMap(),
      'value_transfer_hashes': vttHashes.toList(),
      'mint_hashes': mintHashes.toList(),
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

bool isTheSameList(List<Utxo> a, List<Utxo> b) {
  int currentLength = a.length;
  int newLength = b.length;
  bool isSameList = true;
  if (currentLength == newLength) {
    b.forEach((element) {
      bool containsUtxo = rawJsonUtxosList(a).contains(element.toRawJson());
      if (!containsUtxo) {
        isSameList = false;
      }
    });
  } else {
    isSameList = false;
  }
  return isSameList;
}
