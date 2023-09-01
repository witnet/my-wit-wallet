import 'dart:core';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:witnet/explorer.dart';

enum MasterAccountStats {
  blocks,
  details,
  data_requests_solved,
  data_requests_launched,
  value_transfers,
}

class AccountStats {
  AddressBlocks? blocks;
  Map<String, dynamic>? details;
  Map<String, dynamic>? drSolved;
  Map<String, dynamic>? drLaunched;

  AccountStats(
      {required this.address,
      required this.walletId,
      this.blocks,
      this.details,
      this.drSolved,
      this.drLaunched});

  KeyType get keyType {
    return KeyType.master;
  }

  final String address;
  final String walletId;

  factory AccountStats.fromJson(Map<String, dynamic> data) {
    AccountStats account = AccountStats(
      walletId: data['walletId'],
      address: data['address'],
      blocks: data['blocks'],
      details: data['details'],
      drSolved: data['drSolved'],
      drLaunched: data['drLaunched'],
    );
    return account;
  }

  Map<String, dynamic> jsonMap() {
    return {
      'walletId': walletId,
      'address': address,
      'blocks': blocks != null ? blocks!.jsonMap() : null,
      'details': details,
      'drSolved': drSolved,
      'drLaunched': drLaunched,
    };
  }
}
