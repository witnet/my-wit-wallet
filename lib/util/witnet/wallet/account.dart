import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';

class Account {
  Account({required this.address, required this.path});

  int balance = 0;
  int lastSynced = -1;
  void setBalance() {
    int _balance = 0;
    utxos.forEach((element) {
      _balance += element.value;
    });
    balance = _balance;
  }


  final String path;
  final String address;
  List<String> vttHashes = [];
  Map<String, ValueTransferInfo> valueTransfers = {};
  List<Utxo> utxos = [];

  @override
  String toString() => '{"address": $address, "path": $path}';

  factory Account.fromJson(Map<String, dynamic> data) {
    List<Utxo> _utxos =
        List<Utxo>.from(data['utxos'].map((x) => Utxo.fromJson(x)));

    Map<String, ValueTransferInfo> _vtts = {};
    Map<String, dynamic> dbTrxns = data['value_transfer_transactions'];
    dbTrxns.forEach((key, value) {
      _vtts[key] = ValueTransferInfo.fromDbJson(value);
    });

    Account account = Account(address: data['address'], path: data['path']);
    account.utxos = _utxos;
    account.vttHashes = List<String>.from(data['value_transfer_hashes']);
    account.valueTransfers.addAll(_vtts);
    account.lastSynced = data['last_synced'];
    return account;
  }
  ValueTransferInfo addDbTransaction(Map<String, Object?> data) {
    ValueTransferInfo vti = ValueTransferInfo.fromDbJson(data);
    valueTransfers[vti.txnHash] = vti;
    return valueTransfers[vti.txnHash]!;
  }

  Map<String, dynamic> jsonMap() {
    List<Map<String, dynamic>> _utxos = [];
    utxos.forEach((element) {
      _utxos.add(element.jsonMap());
    });

    Map<String, dynamic> vtts = {};
    valueTransfers.forEach((key, value) {
      vtts[key] = value.jsonMap();
    });
    setBalance();
    return {
      "address": address,
      'path': path,
      'utxos': _utxos.toList(),
      'balance': balance,
      'value_transfer_hashes': vttHashes.toList(),
      'value_transfer_transactions': vtts,
      'last_synced': lastSynced,
    };
  }
}

class NodeAccount extends Account {
  NodeAccount(address) : super(address: address, path: 'm');
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
